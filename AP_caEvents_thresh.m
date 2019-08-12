function [caEvents, CalcThreshold, Method] = AP_caEvents_thresh(df_matrix,Options)
% caEvent_matrix = AP_caEvents_thresh(df_matrix,thresh,type)
% Create a matrix of calcium events from raw df/f traces
% 'thresh' - noise multiplier threshold
%
% method: 
% 0 (default) = zero inactive portions of the trace
% 1 = zero the trace when df/f is falling
% 2 = retain max-min df of increasing active df/f portions

method = 0;

sensor = Options.ImagingSensor;
thresh = Options.Threshold;
if strcmpi(sensor, 'GCaMP')
    ImagingFrequency = 30.49;
elseif strcmpi(sensor, 'GluSNFR')
    ImagingFrequency = 58.30;
end
seconds_to_smooth = 1;
smoothwindow = round(ImagingFrequency*seconds_to_smooth);

num_cells = size(df_matrix,1);

% Discard cells that contain all NaNs and zero occasional NaNs (is this ok?)
discard_cells = false(num_cells,1);
discard_cells(all(isnan(df_matrix),2)) = true;
df_matrix(isnan(df_matrix)) = 0;

use_cells = find(~discard_cells);

% Initialize calcium events matrix
caEvents = nan(size(df_matrix));

% Set threshold parameters
thresh_lower_lim = 0.01;
if isstruct(thresh)
    UseThreshMethod = 'Value';  %%% For using pre-calculated threshold values
    Upper = thresh.UpperThreshold;
    Lower = thresh.LowerThreshold;
else
    UseThreshMethod = 'Multiplier'; %%% For using a multiplier of the noise
    Upper = thresh;
    Lower = 1;
end

for curr_cell = use_cells'
    Method(curr_cell,1) = 1;
    curr_trace = df_matrix(curr_cell,:);
    
    temp_smooth = smooth(curr_trace,smoothwindow ,'loess')';
    
    %noise_est = mean(abs(df_matrix(curr_cell,:) - temp_smooth));
    % NEW NOISE EST: the std of (mirrored) below-zero df/f values
    below_zero_trace = curr_trace(curr_trace < 0);
    noise_est = std([below_zero_trace -below_zero_trace]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% NH edited %%% set minimum value (important for silent spines)
    switch UseThreshMethod %%% If passing a list of pre-calculated spine thresholds (i.e. when using dendrite subtraction, a point at which thresholds have already been established), simply use that threshold as opposed to calculating it anew
        case 'Value'
            high_thresh = Upper(curr_cell);
            lo_thresh = Lower(curr_cell);
            if Upper<thresh_lower_lim
                high_thresh = thresh_lower_lim;
            end
        case 'Multiplier'
            high_thresh = noise_est*thresh;
            lo_thresh = noise_est*Lower;
            artifact_lim = abs(prctile(below_zero_trace,5));  %%% Attempts to account for movement artifacts by considering the largest negative deflection in the data, and assuming anything within this territory could be an artifact
            if high_thresh<artifact_lim
                high_thresh = artifact_lim;
                Method(curr_cell,1) = 2;
            end
            if high_thresh<thresh_lower_lim
                high_thresh = thresh_lower_lim;
                Method(curr_cell,1) = 3;
            end
    end
    CalcThreshold.LowerThreshold(1,curr_cell) = lo_thresh;
    CalcThreshold.UpperThreshold(1,curr_cell) = high_thresh;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    thresh_lo = temp_smooth > lo_thresh;
    thresh_hi = temp_smooth > high_thresh;
    
    % fill in hi-threshold portions where lo threshold is not crossed (dips
    % down but not to baseline, so continuously active portion)
    
    % find edges of long-smooth above-thresh periods
    thresh_lo_start = diff([0 thresh_lo 0]) == 1;
    thresh_lo_stop = diff([0 thresh_lo 0]) == -1;
    thresh_hi_start = diff([0 thresh_hi 0]) == 1;
    thresh_hi_stop = diff([0 thresh_hi 0]) == -1;
    
    thresh_hi_start_idx = find(thresh_hi_start);
    thresh_hi_stop_idx = find(thresh_hi_stop);
    
    %%% Locate transitions from low threshold to high threshold (NH)
    thresh_lo_hi_smooth_idx = arrayfun(@(x,y) ...
        x-find(thresh_lo_start(x:-1:1),1)+1:y, ...
        thresh_hi_start_idx,thresh_hi_stop_idx,'uni',false);
    
    % don't bother trying to find activity that starts before imaging or
    % continues after last frame
    exclude_activity = cellfun(@(x) any(x(x <= 1 | ...
        x >= length(curr_trace))),thresh_lo_hi_smooth_idx);
    
    % refine start times of activity to when df/f goes above hi thresh
    thresh_lo_hi_raw_idx = cellfun(@(x) x(1) +...
        find(curr_trace(x:end) > high_thresh,1) - ...
        find(curr_trace(x(1)+find(curr_trace(x:end) > high_thresh,1):-1:1) < high_thresh*1,1): ...
        x(end),thresh_lo_hi_smooth_idx(~exclude_activity),'uni',false);
    
    % again, filter out events that overlap with beginning or end
    exclude_activity_2 = cellfun(@(x) any(x(x <= 1 | ...
        x >= length(curr_trace))),thresh_lo_hi_raw_idx);
    thresh_lo_hi_raw_idx(exclude_activity_2) = [];
    
    % find continuous active portions after this process      
    active_trace = zeros(size(curr_trace));
    active_trace(horzcat(thresh_lo_hi_raw_idx{:})) = true;
    
    active_idx = arrayfun(@(x,y) x:y,find(diff([0 active_trace 0]) == 1), ...
        find(diff([0 active_trace 0]) == -1),'uni',false);
    
    % Create trace from chosen method
    switch method
        % 0 (default) = retain over-threshold, zero others
        case 0
            over_thresh_frames = horzcat(active_idx{:});
            caEvents(curr_cell,:) = 0;
            caEvents(curr_cell,over_thresh_frames) = curr_trace(over_thresh_frames);
            
        % 1 = retain over-threshold & increasing, zero others
        case 1
            thresh_lo_hi_rising = cellfun(@(x) x(diff([0 temp_smooth(x)]) > 0), ...
                active_idx,'uni',false);
            
            over_thresh_frames = horzcat(thresh_lo_hi_rising{:});
            
            caEvents(curr_cell,:) = 0;
            caEvents(curr_cell,over_thresh_frames) = curr_trace(:,over_thresh_frames);
            
        % 2 = retain ddf of over-threshold & increasing portions
        case 2
            % find rising portions
            thresh_lo_hi_rising = cellfun(@(x) x(diff([0 temp_smooth(x)]) > 0), ...
                active_idx,'uni',false);
            % split rising portions
            active_rising_trace = zeros(size(curr_trace));
            active_rising_trace(horzcat(thresh_lo_hi_rising{:})) = true;            
            active_rising_idx = arrayfun(@(x,y) x:y,find(diff([0 active_rising_trace 0]) == 1), ...
                find(diff([0 active_rising_trace 0]) == -1),'uni',false);
    
            thresh_lo_hi_rising_ddf = cellfun(@(x) repmat((max(curr_trace(x)) - ...
                min(curr_trace(x))),1,length(x)),active_rising_idx,'uni',false);
            
            over_thresh_frames = horzcat(active_rising_idx{:});
            over_thresh_values = horzcat(thresh_lo_hi_rising_ddf{:});
            
            caEvents(curr_cell,:) = 0;
            caEvents(curr_cell,over_thresh_frames) = over_thresh_values;
    end    
end










