function a = NHanalySummarizeBehavior(File,session)

%%%% This function accepts all Behavior files that are generated from the
%%%% function 'NHanalyLeverPressBehavior', which simply summarizes the
%%%% behavioral results for a specific day. To summary the behavior over
%%%% multiple days, use all of the corresponding files as input arguments
%%%% to this function. **** If you want to assign session numbers to each
%%%% of the files used, make the last input argument an array of said
%%%% numbers. Otherwise, the program will assume sequential order.

global LeverTracePlots
global BehaviorParameters

range = BehaviorParameters.Range; 

%%% Performance %%% 
% 
rewards = 0;
moveatstartfault = 0;

figure(LeverTracePlots.figure)

maxtrialnum = 110;


if sum(cell2mat(strfind(File.xsg_data.channel_names, 'Lick')))
    [n,d] = rat(1000/10000);
    lickdata_resample = resample(File.xsg_data.channels(:,3), n,d);
    [b,k] = butter(4,(5/500), 'low');
    File.lick_data_smooth = filtfilt(b,k,lickdata_resample);
else
    File.lick_data_smooth = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialize variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

used_trial = [];
rxnTime = [];
CuetoRew = [];
trial_length = [];
movedurationbeforecue = [];
MovementMat = [];
NumberofMovementsDuringITIPreIgnoredTrials = [];
FractionITISpentMovingPreIgnoredTrials = [];
NumberofMovementsDuringITIPreRewardedTrials = [];
FractionITISpentMovingPreRewardedTrials = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ch = logical(strcmp(File.xsg_data.channel_names,'Trial_number'));
bitcode = parse_behavior_bitcode(File.xsg_data.channels(:,ch), 10000, session);
trials = File.DispatcherData.saved.ProtocolsSection_n_done_trials;
if isempty(bitcode)
    disp(['Could not extract bitcode information from session ', num2str(session)])
    a.MovementMat = NaN;
    a.MovementAve = NaN;
    a.MovingAtTrialStartFaults = NaN;
    a.MoveDurationBeforeIgnoredTrials = NaN;
    a.NumberofMovementsDuringITIPreIgnoredTrials = NaN;
    a.FractionITISpentMovingPreIgnoredTrials = NaN;
    a.NumberofMovementsDuringITIPreRewardedTrials = NaN;
    a.FractionITISpentMovingPreRewardedTrials = NaN;
    a.rewards = NaN;
    a.AveRxnTime = NaN;
    a.AveCueToRew = NaN;
    a.Trials = NaN;
return
end
movements_only = File.lever_force_smooth.*File.lever_active;
boundary_frames = find(diff([Inf; File.lever_active;Inf])~=0);
% if boundary_frames(1) == 1
%     boundary_frames = boundary_frames(2:end);
% end

%==========================================================================
lever_bound_separated = mat2cell(File.lever_active, diff(boundary_frames));

MovementBlocks = lever_bound_separated(cell2mat(cellfun(@any, lever_bound_separated, 'uni', false)));

MovementDuration = cellfun(@length, MovementBlocks);

%==========================================================================


bitcode_offset = [bitcode.behavior_trial_num]-(1:length(bitcode));
numtrials = length(File.DispatcherData.saved_history.ProtocolsSection_parsed_events)
CRMovementDuration = nan(1,numtrials);
for trialnumber = 1:numtrials %%% For every trial(the first trial often has incorrect information)
    if trialnumber>maxtrialnum
        continue
    end
    if trialnumber > length(bitcode)
        continue
    end
%             i_bitcode=find([bitcode.behavior_trial_num]==trialnumber,1);
%             if(isempty(i_bitcode)) continue; end
    i_bitcode = trialnumber-abs(bitcode_offset(trialnumber));
    if i_bitcode<=0
        continue
    end
    if sum(ismember(used_trial, i_bitcode))
        continue
    end
    used_trial = [used_trial; i_bitcode];
    if i_bitcode<=0
        continue
    end
    start_trial(trialnumber) = round(bitcode(i_bitcode).xsg_sec*1000);
    t0 = File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.bitcode(1);
    end_trial(trialnumber) = start_trial(trialnumber)+round((File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.state_0(2,1)-t0)*1000); %%% Subtract the starting point of each trial  (t0) on Dispatcher's terms so as to align it with the start point according to the .xsg data

    if ~isempty(File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.reward) %%% If the trial was rewarded
        rewards = rewards+1;
        reward_time = round(start_trial(trialnumber)+(File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.reward(1)-t0)*1000);
        result_time(trialnumber) = reward_time;
        if result_time(trialnumber) == 0
            result_time(trialnumber) = 1;
        end
        cue_start = round(start_trial(trialnumber)+(File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.cue(1)-t0)*1000);
        if cue_start >= length(File.lever_force_smooth) || reward_time >= length(File.lever_force_smooth)
            continue
        end

        if end_trial(trialnumber)>length(File.lever_force_smooth)
            end_trial(trialnumber) = length(File.lever_force_smooth);
        end

        File.movement{rewards} = File.lever_force_smooth(cue_start:end_trial(trialnumber));
        File.PastThreshRewTrials{rewards} = File.lever_force_smooth(cue_start:end_trial(trialnumber)).*File.lever_active(cue_start:end_trial(trialnumber));  %%% Binarizes lever motion for a particular cue period

        %%%%%%%%%%%%%%%%%%%%%%%%%
        %==================================================================
        [File,UsedTrialInfo, fault,IgnoredTrialInfo] = ProfileRewardedMovements(File, boundary_frames,session, trialnumber, rewards,cue_start, result_time, end_trial);
        CRMovementDuration(trialnumber) = UsedTrialInfo.CRMovementLength;
        %==================================================================
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
        if fault == 1 || fault == 2   %%% Fault type 1 signifies trials in which the animal was moving at the beginning of the cue
            moveatstartfault = moveatstartfault+1;
            movedurationbeforecue(rewards,1) = IgnoredTrialInfo.movedurationbeforecue;
            NumberofMovementsDuringITIPreIgnoredTrials(rewards,1) = IgnoredTrialInfo.numberofmovementssincelasttrial;
            FractionITISpentMovingPreIgnoredTrials(rewards,1) = IgnoredTrialInfo.FractionITISpentMoving;
            NumberofMovementsDuringITIPreRewardedTrials(rewards,1) = NaN;
            FractionITISpentMovingPreRewardedTrials(rewards,1) = NaN;
        else
            movedurationbeforecue(rewards,1) = 0;
            NumberofMovementsDuringITIPreIgnoredTrials(rewards,1) = NaN;
            FractionITISpentMovingPreIgnoredTrials(rewards,1) = NaN;
            NumberofMovementsDuringITIPreRewardedTrials(rewards,1) = UsedTrialInfo.numberofmovementssincelasttrial;
            FractionITISpentMovingPreRewardedTrials(rewards,1) = UsedTrialInfo.FractionITISpentMoving;
        end
        if fault
            continue
        end
        %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%

        trial_length(rewards,1) = UsedTrialInfo.trial_length;
        rxnTime(rewards,1) = UsedTrialInfo.rxnTime;
        CuetoRew(rewards,1) = UsedTrialInfo.cs2r;
    else
        result_time(trialnumber) = round(start_trial(trialnumber)+(File.DispatcherData.saved_history.ProtocolsSection_parsed_events{trialnumber}.states.punish(1)-t0)*1000);
        if result_time(trialnumber) == 0
            result_time(trialnumber) = 1;
        end
    end
end
% end
AveRxnTime = nanmean(rxnTime);
AveCueToRew = nanmean(CuetoRew);
trial_length(trial_length == 0) = NaN;
% if ~isempty(trial_length)
%     range = min(trial_length);
% else
%     range = range;
% end

movedurationbeforecue = movedurationbeforecue(logical(movedurationbeforecue))./1000;

axes(LeverTracePlots.CurrentAxes)
numtrackedmovements = 0;
for rewardedtrial = 1:rewards 
    try
        if ~isempty(File.SuccessfulMovements{rewardedtrial})
            MovementMat(rewardedtrial,1:range) = File.SuccessfulMovements{rewardedtrial}(1:range);
            MovementMat(MovementMat==0) = nan;
            plot(MovementMat(rewardedtrial,1:range), 'k');
            drawnow;
        else
            MovementMat(rewardedtrial,1:range) = nan(1,range);
        end
    catch
        MovementMat(rewardedtrial,1:range) = nan(1,range);
        disp(['Movement was not tracked for trial ', num2str(rewardedtrial), ' from session ', num2str(session)])
    end
    if sum(~isnan(MovementMat(rewardedtrial,:))) > 100
        numtrackedmovements = numtrackedmovements+1;
    end
end

%%%%
MinMovementNumContingency = numtrackedmovements > 0;
%%%%

if rewards ~= 0 && MinMovementNumContingency
    MovementAve = nanmean(MovementMat(:,1:range),1);
    plot(MovementAve(1:range), 'r', 'Linewidth', 2); drawnow;
    ylim([-2.5 0])
    title(['Session', num2str(session)])
else
    MovementMat(~isnan(MovementMat)) = nan;
    if ~isnan(range)
        MovementAve = nan(1,range);
    else
        MovementAve = [];
    end
end

a.MovementMat = MovementMat;
a.MovementAve = MovementAve;
a.MovementDuration = MovementDuration;
a.CuedRewardedMovementDuration = CRMovementDuration;
a.rewards = rewards;
a.MovingAtTrialStartFaults = moveatstartfault;
a.AveRxnTime = AveRxnTime;
a.AveCueToRew = AveCueToRew;
a.Trials = trials;
a.MoveDurationBeforeIgnoredTrials = movedurationbeforecue; 
a.NumberofMovementsDuringITIPreIgnoredTrials = NumberofMovementsDuringITIPreIgnoredTrials;
a.FractionITISpentMovingPreIgnoredTrials = FractionITISpentMovingPreIgnoredTrials;
a.NumberofMovementsDuringITIPreRewardedTrials = NumberofMovementsDuringITIPreRewardedTrials;
a.FractionITISpentMovingPreRewardedTrials = FractionITISpentMovingPreRewardedTrials;

