function [File,trial_length,cs2r, rxnTime, fault,IgnoredTrialInfo] = ProfileRewardedMovements(File, boundary_frames,session, trialnumber, rewards,cue_start, result_time, end_trial)


%%% Discard any trials for which the animal is already moving 
if any(File.lever_active(cue_start-100:cue_start)) 
    disp(['Animal was moving at the beginning of trial ', num2str(trialnumber), ' from session ', num2str(session)]);
    File.SuccessfulMovements{rewards} = [];
    cs2r = [];
    trial_length = [];
    rxnTime = [];
    fault = 1;  %%% Classify fault as type 1; still works as boolean operator, but can be used to count different error types ;
    movestartbeforecue = find(diff(File.lever_active(1:cue_start))>0,1, 'last');
    IgnoredTrialInfo.movedurationbeforecue = length(movestartbeforecue:cue_start);
    if trialnumber>1
        if result_time(trialnumber-1) == 0
            result_time(trialnumber-1) = 1;
        end
        IgnoredTrialInfo.FractionITISpentMoving = sum(File.lever_active(result_time(trialnumber-1):cue_start))/length(File.lever_active(result_time(trialnumber-1):cue_start));
        if IgnoredTrialInfo.FractionITISpentMoving == 1
            IgnoredTrialInfo.numberofmovementssincelasttrial = 1;
        else
            IgnoredTrialInfo.numberofmovementssincelasttrial = length(find(diff(File.lever_active(result_time(trialnumber-1):cue_start))>0));
        end
    else
        IgnoredTrialInfo.FractionITISpentMoving = sum(File.lever_active(1:cue_start))/length(File.lever_active(1:cue_start));
        if IgnoredTrialInfo.FractionITISpentMoving == 1;
            IgnoredTrialInfo.numberofmovementssincelasttrial = 1;
        else
            IgnoredTrialInfo.numberofmovementssincelasttrial = length(find(diff(File.lever_active(1:cue_start))>0));
        end
    end
    return
else
    IgnoredTrialInfo.movedurationbeforecue = 0;
end

%%% Keep uncommented only if NOT ignoring any movements 
IgnoredTrialInfo.movedurationbeforecue = 0;
%%%

if length(File.movement{rewards}) < 1000 || cue_start == end_trial(trialnumber)
    File.SuccessfulMovements{rewards} = [];
    cs2r = [];
    trial_length = [];
    rxnTime = [];
    fault = 2;  %%% Classify fault as type 2; still works as boolean operator, but can be used to count different error types ;
	return
end

File.CueStarttoReward{rewards} = File.lever_force_smooth(cue_start:result_time(trialnumber));
cs2r = length(File.CueStarttoReward{rewards})/1000;

%%% The following are all ways to determine the beginning of
%%% a movement... select based on what works!
    temp = find(boundary_frames < result_time(trialnumber));     %%% The finds the boundaries for all contiguous movements. Using this as a criterion means that the time from movement start to reward can be very variable
    if isempty(temp)
        File.SuccessfulMovements{rewards} = [];
        cs2r = [];
        trial_length = [];
        rxnTime = [];
        fault = 2;  %%% Classify fault as type 3; still works as boolean operator, but can be used to count different error types ;
        return
    end
    if boundary_frames(temp(end))<400
        baseLine_start = length(1:boundary_frames(temp(end)));
    else
        baseLine_start = 400;
    end
    successful_mvmt_start = boundary_frames(temp(end))-baseLine_start; 
    if successful_mvmt_start == 0
        successful_mvmt_start = 1;
    end
    rise = find(File.CueStarttoReward{rewards}> median(File.CueStarttoReward{rewards}),1);        %%% Add option to only include the final successful movement! Find the last value that is below the threshold (in this case, since lever position is negative, find the last value that is greater that the median)

if isempty(rise)
    rise = 1;
end
%           
if baseLine_start<400
    shift = abs(baseLine_start-400);
else
    shift = 0;
end

trialstopwindow = 3000;
if successful_mvmt_start+(trialstopwindow-shift) > length(File.lever_force_smooth)
    endingbuffer = nan(abs(length(File.lever_force_smooth)-(successful_mvmt_start+(trialstopwindow-shift))),1);
    File.lever_force_smooth = [File.lever_force_smooth; endingbuffer];
end
File.SuccessfulMovements{rewards} = [nan(shift,1);File.lever_force_smooth(successful_mvmt_start:successful_mvmt_start+(trialstopwindow-shift))];
if ~isempty(File.lick_data_smooth)
    File.PostSuccessLicking{rewards} = [nan(shift,1); File.lick_data_smooth(successful_mvmt_start:successful_mvmt_start+5000)];
else
    File.PostSuccessLicking{rewards} = [];
end

trial_length = length(File.SuccessfulMovements{rewards});
if trial_length == 0
    dbstop
end

rxnTime = find(File.PastThreshRewTrials{rewards}, 1, 'first')/1000; %%% Reaction time in seconds (Starts at cue and ends at motion start) (note that this data is downsampled from ephus' 10,000Hz to 1,000Hz by Andy's code)

if isempty(rxnTime)
    rxnTime = 0;
end

fault = 0;
