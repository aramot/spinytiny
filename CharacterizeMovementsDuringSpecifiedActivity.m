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

AlignmentMethod = 1;
%%% Alignment method 1: Align to rewarded presses
%%% Alignment method 2: No alignment (just take window)
%%% Alignment method 3: Align to largest movement in block
%%% Alignment method 4: Align to peak activity

trace_separated = mat2cell(activitytrace', diff(boundstouse));   %%% Separate the co-active trace according to the boundaries defined above (e.g. all movements or successful movements); should be the full length of the data
trace_during_targetperiods = trace_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));   %%% Parse the co-active trace into only those regions of interest defined above (e.g. the traces that correspond to the periods of movement or success)
trace_during_targetperiods = trace_during_targetperiods(blocksatcriteria);
ActivityDuringMovement_Addresses  = find(cellfun(@any, trace_during_targetperiods));  %%% Find periods of co-activity among the trace already separated into the target periods (i.e. periods are already separated into target periods, e.g. movements, agnostic to co-activity; find these target periods that contain co-activity)
% TargetMovementswithCoactivity = lever_trace_during_targetperiods(ActivtiyDuringMovement_Addresses ); %%% These are the full movement traces corresponding to cluster co-activity; probably not as useful as the refined version found below using ExtractMovementswithKnownBounds;
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
            for shf = 1:100 %%% Find the chance level of cluster co-activity occurring during a rewarded movement
                SimRew = shake(IsMovementRewarded);
                chance(shf) = sum(SimRew(ActivityDuringMovement_Addresses))/length(ActivityDuringMovement_Addresses);
            end
            ChanceReward = nanmedian(chance);
        else
            IsSpecifiedMovementRewarded = [];
            ChanceReward = NaN;
        end
    case {'Rewarded', 'CuedRewarded'}
        frames = 1:length(activitytrace);
        trace_separated = mat2cell(activitytrace', diff(allmovementbounds));   %%% Separate the co-active trace according to the boundaries defined above (e.g. all movements or successful movements); should be the full length of the data
        frames_separated = mat2cell(frames', diff(allmovementbounds));
        trace_during_targetperiods = trace_separated(cell2mat(cellfun(@any, allmovementperiods, 'uni', false)));   %%% Parse the co-active trace into only those regions of interest defined above (e.g. the traces that correspond to the periods of movement or success)
        frames_during_targetperiods = frames_separated(cell2mat(cellfun(@any, allmovementperiods, 'uni', false)));
        ActivityDuringAllMovement_Addresses  = find(cellfun(@any, trace_during_targetperiods));  %%% Find periods of co-activity among the trace already separated into the target periods (i.e. periods are already separated into target periods, e.g. movements, agnostic to co-activity; find these target periods that contain co-activity)
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
