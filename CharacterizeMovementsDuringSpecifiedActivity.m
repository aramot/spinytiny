function [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(activitytrace, MovementBlocks,OtherVariables)

%==========================================================================
switch OtherVariables.LearningPhase
    case 'Late'
        boundstouse = MovementBlocks.boundstouse;
        allmovementbounds = MovementBlocks.AllMovementBoundsLate;
        allmovementperiods = MovementBlocks.AllMovementPeriodsLate;
        allperiodblocks = MovementBlocks.allperiodblocks;
        frames_during_targetperiods = MovementBlocks.frames_during_targetperiods;
        levertrace = MovementBlocks.levertraceLate;
        binarizedlever = MovementBlocks.binarizedleverLate;
        successtrace = MovementBlocks.successtraceLate;
        rewardperiods = MovementBlocks.rewardperiodsLate;
        blocksatcriteria = MovementBlocks.targetblocksmeetingcriteriaLate;
    case 'Early'
        boundstouse = MovementBlocks.boundstouseEarly;
        allmovementbounds = MovementBlocks.AllMovementBoundsEarly;
        allmovementperiods = MovementBlocks.AllMovementPeriodsEarly;
        allperiodblocks = MovementBlocks.allperiodblocksEarly;
        frames_during_targetperiods = MovementBlocks.frames_during_targetperiodsEarly;
        levertrace = MovementBlocks.levertraceEarly;
        binarizedlever = MovementBlocks.binarizedleverEarly;
        successtrace = MovementBlocks.successtraceEarly;
        rewardperiods = MovementBlocks.rewardperiodsEarly;
        blocksatcriteria = MovementBlocks.targetblocksmeetingcriteriaEarly;
end

TimingValues = OtherVariables.TimingValues;
ImagingFrequency = OtherVariables.ImagingFrequency;
IsMovementRewarded = OtherVariables.IsMovementRewarded;
FocusOn = OtherVariables.Focus;
%==========================================================================
trace_separated = mat2cell(activitytrace', diff(boundstouse));                                          %%% Separate the co-active trace according to the boundaries defined above (e.g. all movements or successful movements); should be the full length of the data
trace_during_targetperiods = trace_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));   %%% Parse the co-active trace into only those regions of interest defined above (e.g. the traces that correspond to the periods of movement or success)
trace_during_targetperiods = trace_during_targetperiods(blocksatcriteria);
ActivityDuringMovement_Addresses  = find(cellfun(@any, trace_during_targetperiods));                    %%% Find periods of activity among the trace already separated into the target periods (i.e. periods are already separated into target periods, e.g. movements, agnostic to activity; find these target periods that contain co-activity)
% TargetMovementswithCoactivity = lever_trace_during_targetperiods(ActivtiyDuringMovement_Addresses );  %%% These are the full movement traces corresponding to cluster co-activity; probably not as useful as the refined version found below using ExtractMovementswithKnownBounds;
%==========================================================================
levervelocity = [0;diff(levertrace)];
%%% Remove "buzzes" in lever velocity data that come from discontinuous
%%% readings
[~,tf] = rmoutliers(levervelocity, 'movmedian', 20);
levervelocity(tf) = nan; 
nanx = isnan(levervelocity); t = 1:numel(levervelocity);
levervelocity(nanx) = interp1(t(~nanx), levervelocity(~nanx), t(nanx));
velocity_during_movement_periods = mat2cell(levervelocity, diff(boundstouse));
velocity_during_movement_periods = velocity_during_movement_periods(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
%==========================================================================
lever_during_movement_periods = mat2cell(levertrace, diff(boundstouse));
lever_during_movement_periods = lever_during_movement_periods(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
frames_during_movements_list = cell2mat(frames_during_targetperiods);
%==========================================================================
% Find activity onset timing and filter for movements that have activity 
% within a certain window (if chosen in options)

if OtherVariables.UseMaxMoveLengthCutoff
    activitystart = cellfun(@(x) find(x,1,'first'), trace_during_targetperiods(ActivityDuringMovement_Addresses));
    if any(activitystart==1)
        pre_move_start_blocks = find(activitystart==1);
        for pm = 1:length(pre_move_start_blocks)
            pickupframe = frames_during_targetperiods{ActivityDuringMovement_Addresses(pre_move_start_blocks(pm))}(1);
            if pickupframe == 1
                continue
            end
            rewind = find(activitytrace(pickupframe:-1:1)==0, 1,'first');
            if isempty(rewind)
                activitystart(pre_move_start_blocks(pm)) = 1-pickupframe;
            else
                activitystart(pre_move_start_blocks(pm)) = 1-rewind;
            end
        end
    end
    max_acceptable_onset = round(ImagingFrequency*3);
    activity_within_movementwindow = activitystart <= max_acceptable_onset;
    originallength = length(ActivityDuringMovement_Addresses);
    ActivityDuringMovement_Addresses = ActivityDuringMovement_Addresses(activity_within_movementwindow);
    MovementInfo.FractionMovementswithActivityAfterWindow = sum(~activity_within_movementwindow)/originallength;
    activitystart = activitystart(activity_within_movementwindow);
else
    MovementInfo.FractionMovementswithActivityAfterWindow = 0;
    activitystart = cellfun(@(x) find(x,1,'first'), trace_during_targetperiods(ActivityDuringMovement_Addresses));
end

lags = [-150 -50 0 50 150]; 
lags = ceil(ImagingFrequency./(1000./lags));

if ~isempty(activitystart)
    MovementInfo.ActivityStartRelativetoMovement = activitystart./ImagingFrequency;
    MovementInfo.ActivityStartNormalized = activitystart./cellfun(@length, frames_during_targetperiods(ActivityDuringMovement_Addresses));
    %%% Correct for timing starts for positive and negative (e.g. activity
    %%% starting 2 frames into movement A, and enduring into movement B
    %%% after 64 frames would give a different start frame when using the
    %%% below cellfun equation for targetframes (probably the dumb way to
    %%% do this). 
    activitystart(activitystart>0) = activitystart(activitystart>0)-1;
    activitystart(activitystart<0) = activitystart(activitystart<0)+1;
    %%%
    targetframes = cellfun(@(x,y) x(1)+y, frames_during_targetperiods(ActivityDuringMovement_Addresses), mat2cell(activitystart, ones(1,length(activitystart)),1));
    targetframes(targetframes<1) = 1;
    [targetframes, kept_activity_starts] = unique(targetframes);
    ActivityDuringMovement_Addresses = ActivityDuringMovement_Addresses(kept_activity_starts);
    MovementInfo.LeverPositionatActivityOnset = nan(length(targetframes),length(lags));
    MovementInfo.LeverVelocityatActivityOnset = nan(length(targetframes),length(lags));
    MovementInfo.LeverVelocityatRandomLags = nan(length(targetframes),length(lags));
    for i = 1:length(lags)
        %%% If the added lag gets a value outside of the current movement,
        %%% ignore this value
        containedwithinsamemov = cellfun(@(x,y) ismember(x,y), num2cell(targetframes+lags(i)),cellfun(@(x) vertcat(x'), frames_during_targetperiods(ActivityDuringMovement_Addresses), 'uni', false));
        valid_targetframes = targetframes(containedwithinsamemov);
        %%%
        if any(valid_targetframes+lags(i)>length(levertrace)) %%% If there are any target frames (after adding the lags) that exceed the length of the trace, filter these out, but leave the data structure assuming use of all lag values
            tempmat = nan(length(valid_targetframes),1);
            tempmat(valid_targetframes+lags(i)<length(levertrace)) = levertrace(valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i));
            MovementInfo.LeverPositionatActivityOnset(:,i) = tempmat;
            tempmat = nan(length(valid_targetframes),1);
            tempmat(valid_targetframes+lags(i)<length(levertrace)) = levervelocity(valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i));
            MovementInfo.LeverVelocityatActivityOnset(:,i) = tempmat;
            %%% Extract peri-event regions of the trace for showing slope
            start = valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i)-6; 
            stop = valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i)+6; 
            startfilt = start(start > 0 & start < length(levertrace) & stop < length(levertrace));
            stopfilt = stop(start > 0 & start < length(levertrace) & stop < length(levertrace));
            start = startfilt; stop = stopfilt;
            MovementInfo.LeverSlopeTraces{i} = cell2mat(cellfun(@(x) levertrace(x), arrayfun(@(x,y) x:y, start, stop, 'uni', false), 'uni', false)');
        else
            if any(valid_targetframes+lags(i)<1) %%% If using negative lags (i.e. movement parameters preceeding activity), you might have values lower than the start frame
                tempmat = nan(length(valid_targetframes),1);
                tempmat(valid_targetframes+lags(i)>0) = levertrace(valid_targetframes(valid_targetframes+lags(i)>0)+lags(i));
                MovementInfo.LeverPositionatActivityOnset(:,i) = tempmat; 
                tempmat = nan(length(valid_targetframes),1);
                tempmat(valid_targetframes+lags(i)>0) = levervelocity(valid_targetframes(valid_targetframes+lags(i)>0)+lags(i));
                MovementInfo.LeverVelocityatActivityOnset(:,i) = tempmat;
                %%% Extract peri-event regions of the trace for showing slope
                start = valid_targetframes(valid_targetframes+lags(i)>0)+lags(i)-6;
                stop = valid_targetframes(valid_targetframes+lags(i)>0)+lags(i)+6;
                startfilt = start(start > 0 & start < length(levertrace) & stop < length(levertrace));
                stopfilt = stop(start > 0 & start < length(levertrace) & stop < length(levertrace));
                start = startfilt; stop = stopfilt;
                MovementInfo.LeverSlopeTraces{i} = cell2mat(cellfun(@(x) levertrace(x), arrayfun(@(x,y) x:y, start, stop, 'uni', false), 'uni', false)');
            else %%% If none of the above exceptions apply, treat all lags normally
                MovementInfo.LeverPositionatActivityOnset(containedwithinsamemov,i) = levertrace(valid_targetframes+lags(i));
                MovementInfo.LeverVelocityatActivityOnset(containedwithinsamemov,i) = levervelocity(valid_targetframes+lags(i));
                %%% Extract peri-event regions of the trace for showing slope
                start = valid_targetframes+lags(i)-6; 
                stop = valid_targetframes+lags(i)+6; 
                startfilt = start(start > 0 & start < length(levertrace) & stop < length(levertrace));
                stopfilt = stop(start > 0 & start < length(levertrace) & stop < length(levertrace));
                start = startfilt; stop = stopfilt; 
                MovementInfo.LeverSlopeTraces{i} = cell2mat(cellfun(@(x) levertrace(x), arrayfun(@(x,y) x:y, start, stop, 'uni', false), 'uni', false)');
            end
        end
%         randlag = randi([lags(1) lags(end)],length(valid_targetframes),1);
%         while any(valid_targetframes+randlag > length(levertrace))
%             randlag(valid_targetframes+randlag > length(levertrace)) = randi([lags(1) lags(end)], sum(valid_targetframes+randlag > length(levertrace)),1);
%         end
%         while any(valid_targetframes+randlag < 1)
%             randlag(valid_targetframes+randlag < 1) = randi([lags(1) lags(end)], sum(valid_targetframes+randlag < 1),1);
%         end
        MovementInfo.LeverVelocityatRandomLags(containedwithinsamemov,i) = cellfun(@(x) x(randi([1 length(x)])), velocity_during_movement_periods(ActivityDuringMovement_Addresses(containedwithinsamemov)));
%         MovementInfo.MeanSpeedofMovementPeriods
    end
    MovementInfo.MeanSpeedofActMovementPeriods = nanmedian(cellfun(@nanmedian, cellfun(@abs, velocity_during_movement_periods(ActivityDuringMovement_Addresses), 'uni', false)));
    MovementInfo.MeanSpeedofOtherMovementPeriods = nanmedian(cellfun(@nanmedian, cellfun(@abs, velocity_during_movement_periods(setdiff(1:length(velocity_during_movement_periods),ActivityDuringMovement_Addresses)), 'uni', false)));
else
    MovementInfo.ActivityStartRelativetoMovement = nan;
    MovementInfo.ActivityStartNormalized = nan(1,length(lags));
    MovementInfo.LeverPositionatActivityOnset = nan(1,length(lags));
    MovementInfo.LeverVelocityatActivityOnset = nan(1,length(lags));
    MovementInfo.LeverSlopeTraces = cell(1,length(lags));
    MovementInfo.LeverVelocityatRandomLags = nan(1,length(lags));
    MovementInfo.MeanSpeedofActMovementPeriods = nan;
    MovementInfo.MeanSpeedofOtherMovementPeriods = nanmedian(cellfun(@nanmedian, cellfun(@abs, velocity_during_movement_periods, 'uni', false)));
end

%==========================================================================
% Find the  activity onset when movements are shuffled

shuffnum = 10;
ShuffledActivityOnset = cell(1,shuffnum);
ShuffledLeverPositionatOnset = cell(1,shuffnum);
ShuffledLeverVelocityatOnset = cell(1,shuffnum);
frames = 1:length(levertrace);
%%% Array the size of frames during movements with each value corresponding
%%% to the associated movement number; see shuffling of lever velocity
%%% below for use. 
countmat = 1:length(frames_during_targetperiods);
movs_list_by_frame = cell2mat(arrayfun(@(x,y) y*ones(1,x), cellfun(@length, frames_during_targetperiods), countmat', 'uni', false)');
%%%
if OtherVariables.DoShuffling && ~isempty(activitystart)
    for shuff = 1:shuffnum
        [shfmovs,I,~] = shake(allperiodblocks);
        %%% Break up frame numbers into the same subdivisions as the
        %%% shuffled movements
        original_frames = mat2cell(frames, 1, cellfun(@length, shfmovs)');
        frames_shuff = original_frames(I); %%% Make the frames the same as the shuffled movement blocks, so that you can actually access the associated movement traces
        original_frames = original_frames(cell2mat(cellfun(@any, shfmovs, 'uni', false)));
        frames_shuff = frames_shuff(cell2mat(cellfun(@any, shfmovs, 'uni', false)));
        %%% Break up activity into the same subdivisions (but DON'T ascribe
        %%% the same shuffled indices! This would UNshuffle the data)
        activity_redivided = mat2cell(activitytrace, 1, cellfun(@length, shfmovs)');
        trace_with_shuff_movs = activity_redivided(cell2mat(cellfun(@any, shfmovs, 'uni', false))); %%% Extract the activity blocks (broken up according to shuffled movement trace) that actually have the pseudo-movement signals (i.e. contain 1s)
        ActivityDuringShuffle = find(cellfun(@any, trace_with_shuff_movs));
        shuffledonsettiming = cellfun(@(x) find(x,1,'first'), trace_with_shuff_movs(ActivityDuringShuffle))';
        %%%
        if any(shuffledonsettiming==1) %%% For any cases in which the activity starts at the pseudo-movement start frame
            pre_move_start_blocks = find(shuffledonsettiming==1);
            for pm = 1:length(pre_move_start_blocks)
                pickupframe = original_frames{ActivityDuringShuffle(pre_move_start_blocks(pm))}(1); %%% Access the original activity frames to find when the activity really started; Change back to 'frames_shuff' for original values 5/28/2020
                if pickupframe == 1
                    continue
                end
                rewind = find(activitytrace(pickupframe:-1:1)==0, 1,'first')-1;   %%% Back up until you find when the movement stops (i.e. the trace first equals 0), then subtract one to correct for finding the first '1' in reverse (e.g. if activity starts at frame 10, and you're moving back from frame 15, then the first zero would be found after moving back 6 places; you actually want to move back 5 places
                if isempty(rewind)
                    shuffledonsettiming(pre_move_start_blocks(pm)) = 2-pickupframe;
                else
                    shuffledonsettiming(pre_move_start_blocks(pm)) = 2-rewind;
                end
            end
        end
        if OtherVariables.UseMaxMoveLengthCutoff
            ActivityDuringShuffle = ActivityDuringShuffle(shuffledonsettiming <= max_acceptable_onset);
            shuffledonsettiming = shuffledonsettiming(shuffledonsettiming <= max_acceptable_onset);
        end
        if ~isempty(shuffledonsettiming)
            targetframes = cellfun(@(x,y) x(1)+y-1, original_frames(ActivityDuringShuffle)', mat2cell(shuffledonsettiming, ones(1,length(shuffledonsettiming)),1));
            targetframes(targetframes<1) = 1;
            [targetframes,ind] = unique(targetframes);
            shuffledonsettiming = shuffledonsettiming(ind);
            ActivityDuringShuffle = ActivityDuringShuffle(ind);
            ShuffledActivityOnset{shuff} = shuffledonsettiming;
            NormOnsetTime{shuff} = shuffledonsettiming./cellfun(@length, frames_shuff(ActivityDuringShuffle)');
        else
            ShuffledActivityOnset{shuff} = nan;
        end
        %==================================================================\
    end
    %%% For shuffling activity onset for lever position/velocity, it should
    %%% be equivalent to just take random time points from the trace (the
    %%% number of such points being equal to the number of activity events)
    %%% 
    for shuff = 1:100
        numEvents = length(find(diff(activitytrace)>0));
        shuff_activity_start = randi([1, length(cell2mat(lever_during_movement_periods))], 1,numEvents);
        ShuffledLeverPositionatOnset{shuff} = nan(length(shuff_activity_start),length(lags));
        ShuffledLeverVelocityatOnset{shuff} = nan(length(shuff_activity_start),length(lags));
        for i = 1:length(lags)
%             movs_of_int = nan(length(shuff_activity_start),1);
%             for j = 1:length(shuff_activity_start)
%                 movs_of_int(j) = find(cellfun(@(x) ismember(frames_during_movements_list(shuff_activity_start(j)), x), frames_during_targetperiods));
%             end
            %%% Looping is VERY slow here, so make an array the size of the
            %%% number of frames, with each value corresponding to which
            %%% movement that frame falls into. Then call that frame with
            %%% the shuffled values. 
            movs_of_int = movs_list_by_frame(shuff_activity_start);
            containedwithinsamemov = cellfun(@(x,y) ismember(x,y), reshape(num2cell(frames_during_movements_list(shuff_activity_start)+lags(i)),length(movs_of_int),1),reshape(cellfun(@(x) vertcat(x'), frames_during_targetperiods(movs_of_int), 'uni', false),length(movs_of_int),1));
            valid_targetframes = frames_during_movements_list(shuff_activity_start(containedwithinsamemov));
            if any(valid_targetframes+lags(i)>length(levertrace)) %%% Ensure that none of the captured values fall outside of the trace 
                tempmat = nan(length(valid_targetframes),1);
                tempmat(valid_targetframes<length(levertrace)) = levertrace(valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i)); %%% Just fill in those values that don't fall outside of the range of the trace, leave the rest as NaNs
                ShuffledLeverPositionatOnset{shuff}(:,i) = tempmat;
                tempmat = nan(length(valid_targetframes),1);
                tempmat(valid_targetframes+lags(i)<length(levertrace)) = levervelocity(valid_targetframes(valid_targetframes+lags(i)<length(levertrace))+lags(i)); %%% Just fill in those values that don't fall outside of the range of the trace, leave the rest as NaNs
                ShuffledLeverVelocityatOnset{shuff}(:,i) = tempmat;
            else
                if any(valid_targetframes+lags(i)<1) %%% Ensure that none of the captured values fall before the trace start
                    tempmat = nan(length(valid_targetframes),1);
                    tempmat(valid_targetframes+lags(i)>0) = levertrace(valid_targetframes(valid_targetframes+lags(i)>0)+lags(i)); %%% Just fill in those values that don't fall outside of the range of the trace, leave the rest as NaNs
                    ShuffledLeverPositionatOnset{shuff}(:,i) = tempmat;
                    tempmat = nan(length(valid_targetframes),1);
                    tempmat(valid_targetframes+lags(i)>0) = levervelocity(valid_targetframes(valid_targetframes+lags(i)>0)+lags(i)); %%% Just fill in those values that don't fall outside of the range of the trace, leave the rest as NaNs
                    ShuffledLeverVelocityatOnset{shuff}(:,i) = tempmat;
                else
                    ShuffledLeverPositionatOnset{shuff}(containedwithinsamemov,i) = levertrace(valid_targetframes+lags(i)); %%% Using frames during movement ensures that the shuffled values fall within movements, which is the only fair comparison for activity within movements
                    ShuffledLeverVelocityatOnset{shuff}(containedwithinsamemov,i) = levervelocity(valid_targetframes+lags(i));
                end
            end
        end
    end
    MovementInfo.ShuffledActivityStartTime = cell2mat(ShuffledActivityOnset')./ImagingFrequency;
    MovementInfo.ShuffledActivityStartNormalized = cell2mat(NormOnsetTime');
    MovementInfo.ActivityStartHypothesisTest = nanmean(MovementInfo.ActivityStartRelativetoMovement)<nanmean(cell2mat(ShuffledActivityOnset'));
    MovementInfo.ShuffledLeverPositionatActivityOnset = vertcat(ShuffledLeverPositionatOnset{:});
    MovementInfo.ShuffledLeverVelocityatActivityOnset = vertcat(ShuffledLeverVelocityatOnset{:});
else
    MovementInfo.ShuffledActivityStartTime = nan(1,length(lags));
    MovementInfo.ShuffledActivityStartNormalized = nan(1,length(lags));
    MovementInfo.ActivityStartHypothesisTest = nan(1,length(lags));
    MovementInfo.ShuffledLeverPositionatActivityOnset = nan(1,length(lags));
    MovementInfo.ShuffledLeverVelocityatActivityOnset = nan(1,length(lags));
end
%==========================================================================

framesofinterest = frames_during_targetperiods(ActivityDuringMovement_Addresses);
actualactivityduringblocksofinterest = trace_during_targetperiods(ActivityDuringMovement_Addresses );

if ~isempty(framesofinterest)
    [MovementswithActivity,UsedBlocks] = ExtractMovementswithKnownBounds(levertrace, binarizedlever, framesofinterest, actualactivityduringblocksofinterest,rewardperiods, TimingValues, ImagingFrequency);
    ActivityDuringMovement_Addresses = ActivityDuringMovement_Addresses(UsedBlocks);
else
    MovementswithActivity = [];
    ActivityDuringMovement_Addresses = [];
end

%%% Regardless of the focus (e.g. all movements vs. cued-rewarded
%%% movements), it only makes sense to look at the fraction of all
%%% movements with specified activity that are rewarded (i.e. 100% of cued
%%% -rewarded movements are obviously rewarded...)
rewstart = diff([0;rewardperiods]); rewstart(rewstart<0)= 0;

switch FocusOn
    case 'All'
        if ~isempty(framesofinterest)
            IsSpecifiedMovementRewarded = cell2mat(cellfun(@(x) any(rewstart(x)), framesofinterest(UsedBlocks), 'uni', false));
            for shf = 1:1000 %%% Find the chance level of cluster co-activity occurring during a rewarded movement
                SimRew = shake(IsMovementRewarded);
                chance(shf) = sum(SimRew(ActivityDuringMovement_Addresses))/length(ActivityDuringMovement_Addresses);
            end
            ChanceReward = nanmedian(chance);
        else
            IsSpecifiedMovementRewarded = [];
            ChanceReward = NaN;
        end
    case {'Rewarded', 'CuedRewarded'}   %%% In the case of considering only CR Movements, e.g., then obviously 100% would be rewarded, so consider all movements first to calculate the fraction rewarded. 
        frames = 1:length(activitytrace);
        trace_separated = mat2cell(activitytrace', diff(allmovementbounds));   %%% Separate the co-active trace according to the boundaries defined above (e.g. all movements or successful movements); should be the full length of the data
        frames_separated = mat2cell(frames', diff(allmovementbounds));
        trace_during_targetperiods = trace_separated(cell2mat(cellfun(@any, allmovementperiods, 'uni', false)));   %%% Parse the co-active trace into only those regions of interest defined above (e.g. the traces that correspond to the periods of movement or success)
        frames_during_targetperiods = frames_separated(cell2mat(cellfun(@any, allmovementperiods, 'uni', false)));
        ActivityDuringAllMovement_Addresses  = find(cellfun(@any, trace_during_targetperiods));  %%% Find periods of activity among the trace already separated into the target periods (i.e. periods are already separated into target periods, e.g. movements, agnostic to co-activity; find these target periods that contain co-activity)
        framesofinterest = frames_during_targetperiods(ActivityDuringAllMovement_Addresses);
        if ~isempty(framesofinterest)
            IsSpecifiedMovementRewarded = cell2mat(cellfun(@(x) any(rewstart(x)), framesofinterest, 'uni', false));
            for shf = 1:100 %%% Find the chance level of cluster co-activity occurring during a rewarded movement
                SimRew = shake(IsMovementRewarded);
                chance(shf) = sum(SimRew(ActivityDuringAllMovement_Addresses))/length(ActivityDuringAllMovement_Addresses);
            end
            ChanceReward = nanmedian(chance);
        else
            IsSpecifiedMovementRewarded = [];
            ChanceReward = NaN;
        end
end

% if isempty(ActivityDuringMovement_Addresses)
%     ActivityDuringMovement_Addresses = NaN;
% end

MovementInfo.ActivityDuringMovement_Addresses = ActivityDuringMovement_Addresses;
MovementInfo.MovementTracesOccurringwithActivity = MovementswithActivity;
MovementInfo.ChanceReward = ChanceReward;
MovementInfo.IsSpecifiedMovementRewarded = IsSpecifiedMovementRewarded;
