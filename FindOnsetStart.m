function [onset_time, MovAlignedActivity, Individual_Trials] = FindOnsetStart(Movement, RawActivity, BinarizedActivity, PreMovWindow, PostMovWindow)

if isempty(RawActivity) || isempty(BinarizedActivity)
    onset_time = []; 
    MovAlignedActivity = [];
    Individual_Trials = []; 
    return
end

Movement = reshape(Movement,1,length(Movement));
frames = 1:length(Movement);
NumberofROIs = size(RawActivity,1);

any_single_frame_blocks = find(abs((diff([0,diff([~Movement(1), Movement])])))==2); %%% If the "movement active" classification moves from 0->1->0 or vice-versa over 3 frames, this results in a single frame of movement-active or inactive, which doesn't work for the following calculations, so just remove this period

if ~isempty(any_single_frame_blocks)
    Movement(any_single_frame_blocks) = Movement(any_single_frame_blocks-1);
end

MovBound = find(diff([~Movement(1), Movement, ~Movement(end)]~=0));

AllLeverPeriodsSeparated = mat2cell(Movement', diff(MovBound));
framenumcheck = cellfun(@length, AllLeverPeriodsSeparated)>1; AllLeverPeriodsSeparated = AllLeverPeriodsSeparated(framenumcheck);
AllRawActivitySeparatedbyMovementPeriods = mat2cell(RawActivity', diff(MovBound)); AllRawActivitySeparatedbyMovementPeriods = AllRawActivitySeparatedbyMovementPeriods(framenumcheck);
AllBinarizedActivitySeparatedbyMovementPeriods = mat2cell(BinarizedActivity', diff(MovBound)); AllBinarizedActivitySeparatedbyMovementPeriods = AllBinarizedActivitySeparatedbyMovementPeriods(framenumcheck);
FramesSeparated = mat2cell(frames', diff(MovBound)); FramesSeparated = FramesSeparated(framenumcheck);

MovPeriods = AllLeverPeriodsSeparated(cell2mat(cellfun(@any, AllLeverPeriodsSeparated, 'uni', false)));
ActivityDuringNonMovPeriods = cell2mat(AllRawActivitySeparatedbyMovementPeriods(~cell2mat(cellfun(@any, AllLeverPeriodsSeparated, 'uni', false))));


ActivityDuringMovementsforAllROIs = cellfun(@(x,y) any(repmat(x,1,NumberofROIs)) & any(y), AllLeverPeriodsSeparated, AllBinarizedActivitySeparatedbyMovementPeriods, 'uni', false);

for spine = 1:NumberofROIs
    %======================================================================
    %%% Run this section if you want to include all movements (not just
    %%% those with activity). You will need to remove movements that are
    %%% too close together, which the function of most the following code
    FramesDuringMovPeriods{spine} = FramesSeparated(cell2mat(cellfun(@(x,y) any(x), AllLeverPeriodsSeparated, ActivityDuringMovementsforAllROIs, 'uni', false)));
    movements_to_keep = 1:length(FramesDuringMovPeriods{spine});
    too_close_movements = find(diff(cellfun(@(x) x(1), FramesDuringMovPeriods{spine}))<=PreMovWindow+PostMovWindow)';
    tcm_interval = diff(too_close_movements);
    while any(too_close_movements)
        non_consecutive_addresses = find([tcm_interval inf]>1);
        length_of_consecutive_sequences = diff([0 non_consecutive_addresses]);
        movs_separated_by_consecutive_adjacent = mat2cell(too_close_movements', length_of_consecutive_sequences);
        movements_to_exclude = [];
        for m = 1:length(movs_separated_by_consecutive_adjacent)
            if length(movs_separated_by_consecutive_adjacent{m})>1
                if mod(length(movs_separated_by_consecutive_adjacent{m}),2)==1
                    movements_to_exclude = [movements_to_exclude; movs_separated_by_consecutive_adjacent{m}(2:2:end)];
                else
                    movements_to_exclude = [movements_to_exclude; movs_separated_by_consecutive_adjacent{m}(1:2:end)];
                end
            else
                movements_to_exclude = [movements_to_exclude; movs_separated_by_consecutive_adjacent{m}];
            end
        end
        movements_to_keep = setdiff(movements_to_keep, movements_to_exclude);
        too_close_movements = movements_to_keep(logical(diff(cellfun(@(x) x(1), FramesDuringMovPeriods{spine}(movements_to_keep)))<=PreMovWindow+PostMovWindow));
        tcm_interval = diff(too_close_movements);
    end
    FramesDuringMovPeriods{spine} = FramesDuringMovPeriods{spine}(movements_to_keep);
    %======================================================================
    %%% Run this section if you only want to look at "active" movements;
    %%% i.e. those movements that are coincident with activity (used in
    %%% determining onset timing).
%     FramesDuringMovPeriods{spine} = FramesSeparated(cell2mat(cellfun(@(x,y) any(x) & any(y(spine)), AllLeverPeriodsSeparated, ActivityDuringMovementsforAllROIs, 'uni', false)));
    %=======================================================================
    ExpandedWindows{spine} = cellfun(@(x) x(1)-PreMovWindow:x(1)+PostMovWindow,FramesDuringMovPeriods{spine}, 'uni', false);
end

MovAlignedActivity = nan(NumberofROIs, PreMovWindow+PostMovWindow+1);
MedianMovAlignedActivity = nan(NumberofROIs, PreMovWindow+PostMovWindow+1);
TempActivity = cell(NumberofROIs,1);
for spine = 1:NumberofROIs
    TempActivity{spine} = nan(length(ExpandedWindows{spine}),length(-PreMovWindow:PostMovWindow));
    for movs = 1:length(ExpandedWindows{spine})
        if any(ExpandedWindows{spine}{movs}<1)
            continue
        end
        if any(ExpandedWindows{spine}{movs}>length(RawActivity))
            continue
        end
        TempActivity{spine}(movs,:) = RawActivity(spine,ExpandedWindows{spine}{movs});
    end
    if ~isempty(TempActivity{spine})
        MovAlignedActivity(spine,:) = nanmean(TempActivity{spine},1);
        MedianMovAlignedActivity(spine,:) = nanmedian(TempActivity{spine},1);
    end
end

Individual_Trials = TempActivity;

% Find Baseline Activity
NoMov = ~Movement;
NoMovNoAct = logical(repmat(NoMov,size(BinarizedActivity,1),1).*~BinarizedActivity);
for i = 1:NumberofROIs
    BaselineAct{i} = RawActivity(i,NoMovNoAct(i,:));
end

%%% This method of finding onset timing is derived from Peters et al., and
%%% finds consecutive frames that rise above the noise level. 
% 
% for spine = 1:size(RawActivity,1)
%     for frame = 1:length(MovAlignedActivity)
%         for shuff = 1:10000
%             rand_baseline_val = BaselineAct{spine}(randi([1,length(BaselineAct{spine})]));
%             score(shuff,1) = MovAlignedActivity(spine,frame)>rand_baseline_val;
%         end
%         frame_p_val(spine,frame) = 1-sum(score)/length(score);
%         frame_significant(spine,frame) = frame_p_val(spine,frame)<0.05;
% %         frame_significant(spine,frame) = MovAlignedActivity(spine,frame)>2.5*nanstd(BaselineAct{spine});
%     end
%     if any(frame_significant(spine,:))
%         if ~isempty(find(movsum(frame_significant(spine,:),[0 4])==5, 1, 'first'))
%             onset_time(spine) = find(movsum(frame_significant(spine,:),[0 4])==5, 1, 'first')-PreMovWindow;
%         else
%             onset_time(spine) = nan;
%         end
%     else
%         onset_time(spine) = nan;
%     end
% end


%%% This method is Takaki's suggestion: find "clear excitatory peak" then
%%% find the first point before that where the velocity trace falls below zero; the
%%% first positive point after that is onset. 

for spine = 1:size(RawActivity,1)
    start_search = PreMovWindow-90; %%% Set a window over which peaks are considered accetably close to movement onset
    [pks,locs] = findpeaks(MovAlignedActivity(spine,start_search:PreMovWindow+PostMovWindow), 'MinPeakHeight', nanmedian(MovAlignedActivity(spine,:))+nanstd(MovAlignedActivity(spine,:)), 'MinPeakDistance', 30);
    locs = locs+start_search-1;
    if ~isempty(pks)
        peaks_within_range = locs(abs(locs-PreMovWindow)<=90);  %%% Limit the peaks to those occurring within 1.5s
        amp_of_peaks_within_range = pks(abs(locs-PreMovWindow)<=90);
%         [~,ind] = nanmin(abs(peaks_within_range-PreMovWindow));   %%% Find the peaks that's closest to movement
        [~,ind] = nanmax([(1./abs(peaks_within_range-PreMovWindow))+amp_of_peaks_within_range]);
        targetpeak = peaks_within_range(ind); 
        if isempty(targetpeak)
            onset_time(spine) = nan;
            continue
        end
%         onset_time(spine) = (targetpeak-find(MedianMovAlignedActivity(spine,targetpeak:-1:1) <= nanmedian(RawActivity(spine,:)), 1, 'first')) - PreMovWindow;
        smooth_act = smooth(MovAlignedActivity(spine,:),10,'rloess')';
        activity_velocity = diff([smooth_act(1), smooth_act ,smooth_act(end)]);
%         activity_velocity = diff([MovAlignedActivity(spine,1), MovAlignedActivity(spine,:),MovAlignedActivity(spine,end)]);
        end_of_rising_phase = find(smooth_act(targetpeak:-1:1) <= 0.75*smooth_act(targetpeak), 1, 'first');
        if isempty(end_of_rising_phase)
            onset_time(spine) = nan;
            continue
        end
        onset_time(spine) = ((targetpeak-(end_of_rising_phase-1))-find(activity_velocity(targetpeak-end_of_rising_phase:-1:1) <= 0 | smooth_act(targetpeak-end_of_rising_phase:-1:1)<nanmedian(MovAlignedActivity(spine,1:PreMovWindow-1)), 1, 'first')) - PreMovWindow;
%         onset_time(spine) = ((targetpeak-(end_of_rising_phase-1))-find(activity_velocity(targetpeak-end_of_rising_phase:-1:1) <= 0 & smooth_act(targetpeak-end_of_rising_phase:-1:1)<= nanmedian(MovAlignedActivity(spine,1:PreMovWindow-1))+nanstd(MovAlignedActivity(spine,1:PreMovWindow-1)), 1, 'first')) - PreMovWindow;
    else
        onset_time(spine) = nan;
    end
end

 k = 1;

