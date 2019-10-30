function [roi_trace_df roi_trace_baseline] = AP_baselineEstimationNHedited(roi_trace_long,Options)
% [roi_trace_df roi_trace_baseline] = AP_baselineEstimation(roi_trace_long,framerate)
% roi_trace_df: the df/f normalized trace
% roi_trace_baseline (optional): the estimated baseline of the trace

framerate = Options.ImagingFrequency;

baseline_est_runs = 2;

[num_rois num_frames] = size(roi_trace_long);
roi_trace_df = nan(size(roi_trace_long));
roi_trace_baseline = nan(size(roi_trace_long));

   
if ~any(roi_trace_long)
    roi_trace_df = zeros(1,length(roi_trace_long));
    roi_trace_baseline = zeros(1,length(roi_trace_long));
return
end

if any(roi_trace_long<1)
    roi_trace_long = roi_trace_long+(1-min(roi_trace_long));
end
curr_trace = roi_trace_long;
    
    
    % if there's a NaN in the current trace, which happens for instance
    % when the ROI is off of the screen during this day, ignore this ROI
    % CHANGED AP160203: in old L2/3 data, sometimes (during scope
    % adjustment?) a few nans, so have cutoff value, not any
%     max_nans = 30;
%     if sum(isnan(curr_trace)) > max_nans
%         roi_trace_df = nan(1,size(roi_trace_df,2));
%         
%     end
    
    % AP160203: BUT, if there are nans, interpolate across for smoothing
    if any(isnan(curr_trace))
        curr_trace = inpaint_nans(curr_trace);
        roi_trace_long = curr_trace;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    est_base = baseline_kde(curr_trace', 20, round(Options.ImagingFrequency), 20)'; %%% estimate baseline over 1-min window

    if strcmpi(Options.ImagingSensor, 'GluSNFR')
        if ~isempty(Options.ImageFramesatBoutSeparations)
            SecondsPostStarttoIgnore = 2;
            AcqStartPoints = [1;Options.ImageFramesatBoutSeparations];
            IgnoreWindows = AcqStartPoints + ceil(SecondsPostStarttoIgnore*Options.ImagingFrequency);
            for bout = 1:size(AcqStartPoints,1)
                if AcqStartPoints(bout)>length(curr_trace)
                    continue
                end
                if IgnoreWindows(bout)>length(curr_trace)
                    IgnoreWindows(bout) = length(curr_trace);
                end
                curr_trace(AcqStartPoints(bout):IgnoreWindows(bout)) = est_base(AcqStartPoints(bout):IgnoreWindows(bout))+(std(curr_trace)/3)*randn(1,length(AcqStartPoints(bout):IgnoreWindows(bout)));
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Estimate baseline, get rid of active zones, run baseine again.
    for baseline_est = 1:baseline_est_runs
        
        % 1) Take long moving average to get general moving baseline, and
        % produce the first df estimate.
        
        % amount to smooth for baseline estimation, in minutes
        baseline_smooth_min = 1;
        baseline_smooth_frames = round(baseline_smooth_min*60*framerate);
        if size(curr_trace,2) <= baseline_smooth_frames%TK: if too short, consider 1/3 as window
            baseline_smooth_frames = round(size(curr_trace,2) / 3);
        end
        % smooth by moving average to flatten activity
        baseline_smooth = ...
            smooth(curr_trace,baseline_smooth_frames)';
        % copy the ends for reliable smooth points, not near edges
        smooth_reliable = ceil(baseline_smooth_frames/2);
        baseline_smooth(1:smooth_reliable) = ...
            baseline_smooth(smooth_reliable);
        baseline_smooth(end-smooth_reliable:end) = ...
            baseline_smooth(end-smooth_reliable);
        
        % create initial df estimate to find the mode
        baseline_smooth_df = curr_trace - baseline_smooth;
        
        % 2) Find mode or gaussian fit of loess smoothed trace and get the
        % average noise by raw-smoothed
        
        % amount to loess smooth, usually one second looks pretty good
        % -------> actually, it was that 30 frames looks pretty good,
        % regardless of framerate (which makes sense)
        noise_smooth_sec = 1;
        %noise_smooth_frames = round(noise_smooth_sec*framerate);
        noise_smooth_frames = 30;
        % loess smooth on the original trace
        noise_smooth = ...
            smooth(curr_trace,noise_smooth_frames,'loess')';
        % loess smooth on the df estimate
        noise_smooth_df= ...
            smooth(baseline_smooth_df,noise_smooth_frames,'loess')';
        % estimate baseline by mode (since drifts should already be fixed)
        noise_smooth_mode = mode(round(noise_smooth_df));
        
        % try to find baseline by gaussian fitting trace (even though
        % usually not gaussian, and definitely not on the first run)
        norm_fit_obj = gmdistribution.fit(noise_smooth_df',1);
        dx = (max(noise_smooth_df')-min(noise_smooth_df'))/length(noise_smooth_df');
        x = min(noise_smooth_df'):dx:max(noise_smooth_df');
        x = x(1:end-1); % it adds an extra
        norm_fit = pdf(norm_fit_obj,x');
        noise_smooth_mode2 = x(norm_fit == max(norm_fit));
        if abs(noise_smooth_mode - noise_smooth_mode2)<100
            noise_smooth_mode = noise_smooth_mode2;
        end
        
        noise_std = std(baseline_smooth_df-noise_smooth_df);
        
        % 3) Get rid of active times, and re-estimate the baseline.
        % Take where the trace goes above and below some lever as activity in some
        % direction, and restimate mode ignoring things around these points.
            
        % take 2x std above and below as "activity" bounds. if this is one
        % of the preliminary estimates, then only worry about things going
        % over threshold.
        lb = noise_smooth_mode + baseline_smooth - 2*noise_std;
        ub = noise_smooth_mode + baseline_smooth + 2*noise_std;
        if baseline_est < baseline_est_runs
            bound_indx = noise_smooth > ub;
        else
            bound_indx = noise_smooth > ub | noise_smooth < lb;
        end
        % index everything within n seconds of active zones
        activity_surround_sec = 5;
        activity_surround_frames = round(activity_surround_sec*framerate);
        % do this by convolving with filter the size of surround, taking >0's
        activity_surround_kernel = ones(1,round(activity_surround_frames/2));
        active_surround_frames = conv2(+bound_indx,activity_surround_kernel,'same');
        active_indx_surround_curr = bound_indx;
        active_indx_surround_curr(active_surround_frames > 0) = true;
        
        % define which frames are being looked at - first iter is all
        % frames, also initialize the full active frame index
        if baseline_est == 1
            curr_trace_indx = [1:length(curr_trace)];
            active_indx_surround = false(1,size(roi_trace_long,2));
        end
        
        % update the final index for active frames
        active_indx_surround(curr_trace_indx) = active_indx_surround_curr;
                   
        % update which frames will be looked at in the next iteration
        curr_trace_indx = curr_trace_indx(~active_indx_surround_curr);
       
        % truncate out the active parts, use that for next iteration    
        inactive_trace_trunk = curr_trace(~active_indx_surround_curr);
        curr_trace = inactive_trace_trunk;
                        
%         set the current trace to be only inactive parts with interpolated
%         fluorescence between them, use this for future estimations
%         inactive_trace = NaN(size(curr_trace));
%         inactive_trace(~active_indx_surround) = ...
%             curr_trace(~active_indx_surround);
%         make first and last frames equal first and last values
%         inactive_trace(1) = ...
%             curr_trace(find(~active_indx_surround,1));
%         inactive_trace(end) = ...
%             curr_trace(find(~active_indx_surround,1,'last'));
%         active_indx_surround(1) = 0;
%         active_indx_surround(end) = 0;
%         interpolate between active regions
%         inactive_trace =  ...
%             interp1(find(~active_indx_surround), ...
%             inactive_trace(~active_indx_surround), ...
%             [1:length(curr_trace)]);
%         curr_trace = inactive_trace;
        
    end
    
    % if (incredibly rare - and the cells are probably filled anyway)
    % active 95% of the time, skip the cell
    if length(curr_trace) <= 0.05*length(roi_trace_long)
        roi_trace_df = nan(1,size(roi_trace_df,2));
    end
    
    % the current trace is once again the raw trace
    curr_trace = roi_trace_long;
    
    whole_noise_smooth = ...
        smooth(curr_trace,noise_smooth_frames,'loess')';
    
    % with the active parts indexed, fill a vector with only inactive
    % frames smoothed by previous large-scale amount    
    inactive_baseline_smooth_part = [];
    inactive_baseline_smooth_part = ...
        smooth(whole_noise_smooth(~active_indx_surround), ...
        baseline_smooth_frames);
    
    % copy the ends for reliable smooth points, not near edges
    smooth_reliable = ceil(baseline_smooth_frames/2);
%      if size(baseline_smooth,2) <= smooth_reliable%TK: if too short, consider 1/3 as edge
%          smooth_reliable = round(size(baseline_smooth,2) / 4);
%      end

     if smooth_reliable >= length(inactive_baseline_smooth_part)%TK: if too short, consider 1/3 as edge
         smooth_reliable = round(size(inactive_baseline_smooth_part,1) / 3);
     end
    inactive_baseline_smooth_part(1:smooth_reliable) = ...
        inactive_baseline_smooth_part(smooth_reliable);
    inactive_baseline_smooth_part(end-smooth_reliable:end) = ...
        inactive_baseline_smooth_part(end-smooth_reliable);
    inactive_baseline_smooth = NaN(size(curr_trace));
    inactive_baseline_smooth(~active_indx_surround) = ...
        inactive_baseline_smooth_part;
     
    % make the first and last frames equal the first and last values
    inactive_baseline_smooth(1) = inactive_baseline_smooth_part(1);
    inactive_baseline_smooth(end) = inactive_baseline_smooth_part(end);
    active_indx_surround(1) = 0;
    active_indx_surround(end) = 0;
    
    % interpolate between active sites
    inactive_baseline_full = [];
    inactive_baseline_full = ...
        interp1(find(~active_indx_surround), ...
        inactive_baseline_smooth(~active_indx_surround), ...
        [1:length(inactive_baseline_smooth)]);
    
    % make another df estimate based on inactive baseline
    inactive_df = curr_trace - inactive_baseline_full;
    
    % 4) At this point, all drift should be compensated for and all active
    % zones should have been ignored for baselinining. Do one final global
    % baseline estimation by again finding active zones and finding the
    % mode as the baseline.
    
    inactive_df_smooth = smooth(inactive_df,noise_smooth_frames,'loess')';
    noise_std2 = std(abs(inactive_df - inactive_df_smooth));
    lb = -2*noise_std2;
    ub = 2*noise_std2;
    baseline_indx = inactive_df_smooth > ub | inactive_df_smooth < lb;
    
    % index everything within n seconds of active zones
    activity_surround_sec = 5;
    activity_surround_frames = round(activity_surround_sec*framerate);
    % do this by convolving with filter the size of surround, taking >0's
    activity_surround_kernel = ones(1,round(activity_surround_frames/2));
    active_surround_frames = conv2(+baseline_indx,activity_surround_kernel,'same');
    active_indx_surround = baseline_indx;
    active_indx_surround(active_surround_frames > 0) = true;
    
    baseline_offset = ...
        mode(round(inactive_df_smooth(~active_indx_surround)));
    
    % if (incredibly rare - and the cells are probably filled anyway)
    % active 95% of the time, skip the cell
    if sum(active_indx_surround) >= 0.95*length(active_indx_surround);
        roi_trace_df = nan(1,size(roi_trace_df,2));
    end
    
    % try gaussian fitting (it really should be a gaussian by now)
    norm_fit_obj = gmdistribution.fit(inactive_df_smooth(~active_indx_surround)',1);
    dx = (max(inactive_df_smooth(~active_indx_surround)')-min(inactive_df_smooth(~active_indx_surround)'))/length(inactive_df_smooth(~active_indx_surround)');
    x = min(inactive_df_smooth(~active_indx_surround)'):dx:max(inactive_df_smooth(~active_indx_surround)');
    x = x(1:end-1); % it adds an extra
    norm_fit = pdf(norm_fit_obj,x');
    baseline_offset2 = x(norm_fit == max(norm_fit));
    if abs(baseline_offset2 - baseline_offset)<100
        baseline_offset = baseline_offset2;
    end
    
        
    % 5) Create the final baseline trace, then do the final normalization
    
    final_baseline = inactive_baseline_full+baseline_offset;
    roi_trace_df = ...
        (roi_trace_long - final_baseline) ./ final_baseline;
    roi_trace_baseline = final_baseline;
