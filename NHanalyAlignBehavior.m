function [Correlations, Classified, Trial, PredictionModel] = NHanalyAlignBehavior(varargin)

%%% Note: The data contained in the behavior file is confusing, but is
%%% organized in the following way:
%%% All of the lever measurements are given in terms of behavioral frames
%%% as acquired by Dispatcher. These are acquired at 10,000Hz, then down-
%%% sampled to 1000Hz.
%%% The image alignment portion (Behavior_Frames, Imaged_Trials, and
%%% Frame_Times) are given in terms of image frames. To find when the image
%%% frame was acquired in terms of the lever press, reference the image
%%% number as an index of the "Frame_Times" field. 
%%% e.g. The initial cue is given by Behavior.Behavior_Frames{1}.states.cue
%%% This value gives a number that references the IMAGE FRAME, and so
%%% referencing the Frame_Times subfield with this number as an index will
%%% give the behavioral frame (1/1000X). Thus:
%%% Behavior.Frame_Times(Behavior_Frames{1}.states.cue(1))*1,000 gives the
%%% BEHAVIOR FRAME at which the cue was given. 

global LeverTracePlots


Correlations = [];
Classified = [];
Trial = [];
PredictionModel = [];

va = varargin;

%%%%%%%%%%%%%%%%%%%%%%
%%Color Information%%%
%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    red = [0.93 0.11 0.14];     black = [0 0 0];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,magenta,orange,brown,lbrown};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(va{1}, 'DispatcherData')
    Behavior = va{1};
    Fluor = va{2};
else
    Behavior = va{2};
    Fluor = va{1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determine the framework of all of the data acquisition, as defined by
%%% Dispatcher

if isfield(Behavior, 'StartAtTrial')
    firsttrial = Behavior.StartAtTrial;
else
    firsttrial = 1;
end

numberofTrials = length(firsttrial:length(Behavior.Behavior_Frames));
lasttrial = length(Behavior.Behavior_Frames);
numberofSpines = length(Fluor.dF_over_F);
numberofDendrites = size(Fluor.Dendrite_dFoF,1);

imagingframestouse = [];
behaviorframestouse = [];
trialstouse = zeros(numberofTrials,1);

ch = find(strcmp(Behavior.xsg_data.channel_names,'Trial_number'));
bitcode = parse_behavior_bitcode(Behavior.xsg_data.channels(:,ch),10000,Fluor.Session);
bitcode_offset = [bitcode.behavior_trial_num]-(1:length(bitcode));

if ~isempty(find(abs(diff(bitcode_offset))>1, 1))
    trialerror = find(abs(diff(bitcode_offset))>1)+1;
    if length(trialerror) > 1
        trialerror = trialerror(1);
    end
    if trialerror<20            %%% This assumes that if the jump is early, then something bad happened with the early sessions, so you can start recording after this point
        firsttrial = trialerror;
    else
        lasttrial = trialerror-1;
    end
end
 
reward = 0;
punish = 0;

used_trial = [];

countedasfirsttrial = find([bitcode.behavior_trial_num]==1);

if length(countedasfirsttrial) > 1 && firsttrial == 1 && countedasfirsttrial(end)<100   
    firsttrial = countedasfirsttrial(end);
end


for i = firsttrial:lasttrial
    %%% Trial-skip Contingency section
    if i>length(Behavior.Behavior_Frames)
        continue
    end
    if ~Behavior.Imaged_Trials(i)
        continue
    end
    if i>length(bitcode_offset)
        continue
    end
    if bitcode_offset(i) == bitcode(end).behavior_trial_num    %%% Occasionally, the first trial is accidentally overwritten, and this becomes counted as the last trial
        continue
    end
    if Behavior.Behavior_Frames{i}.states.state_0(2,1)-Behavior.Behavior_Frames{i}.states.state_0(1,2)<=1
        continue
    end
    if length(Fluor.Processed_dFoF)< Behavior.Behavior_Frames{i}.states.state_0(1,2) || length(Fluor.Processed_dFoF)<Behavior.Behavior_Frames{i}.states.state_0(2,1)
        continue
    end
    %%% Behavior Section
    i_bitcode = i-abs(bitcode_offset(i));
    if sum(ismember(used_trial, i_bitcode))
        continue
    end
    used_trial = [used_trial; i_bitcode];
    if i_bitcode<=0
        continue
    end
    start_trial = round(bitcode(i_bitcode).xsg_sec*1000);
    t0 = Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.bitcode(1);
    end_trial = start_trial+round((Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(2,1)-t0)*1000);
    if start_trial > length(Behavior.lever_force_smooth) || end_trial > length(Behavior.lever_force_smooth)
        continue
    end
    trial_lever_force{i} = Behavior.lever_force_smooth(start_trial:end_trial);
    trial_binary_behavior{i} = Behavior.lever_active(start_trial:end_trial);
    %%% Activity Section

    Trial_dFoF{i} = Fluor.Processed_dFoF(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_dFoF_DendriteSubtracted{i} = Fluor.Processed_dFoF_DendriteSubtracted(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_OverallSpineActivity{i} = Fluor.OverallSpineActivity(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_SynapseOnlyBinarized{i} = Fluor.SynapseOnlyBinarized(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_CausalBinarized{i} = Fluor.CausalBinarized(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_SynapseOnlyBinarized_DendriteSubtracted{i} = Fluor.SynapseOnlyBinarized_DendriteSubtracted(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_Dendrite_dFoF{i} = Fluor.Dendrite_dFoF(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    Trial_Dendrite_Binarized{i} = Fluor.Dendrite_Binarized(:,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1));
    
    %%% Trial Specific Section
    starttrial_imframes = Behavior.Behavior_Frames{i}.states.state_0(1,2);
    endtrial_imframes = Behavior.Behavior_Frames{i}.states.state_0(2,1)-starttrial_imframes;
    startcue = Behavior.Behavior_Frames{i}.states.cue(1,1)-starttrial_imframes;
        if startcue == 0
            startcue = 1;
        end
    endcue = Behavior.Behavior_Frames{i}.states.cue(1,2)-starttrial_imframes;
        cuemat = zeros(1,length(start_trial:end_trial));
        cuemat(startcue:endcue) = 1;
    trial_binary_cue{i} = cuemat;
    Trial{i}.trialactivity = Trial_dFoF{i}(:,1:end);
    Trial{i}.trialbinaryactivity = Trial_SynapseOnlyBinarized{i}(:,1:end);
    Trial{i}.trialdendsubactivity = Trial_dFoF_DendriteSubtracted{i}(:,1:end); 
    Trial{i}.trialbinarydendsubactivity = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(:,1:end);
    triallength(1,i) = length(startcue:endtrial_imframes);
    Trial{i}.TrialStart = starttrial_imframes;
    Trial{i}.CueStart = startcue-starttrial_imframes;
    Trial{i}.CueEnd = endcue-starttrial_imframes;
    reward_period{i} = zeros(size(Trial{i}.trialactivity,2),1);
    punish_period{i} = zeros(size(Trial{i}.trialactivity,2),1);
    numimframes = size(Trial{i}.trialactivity,2);
    [n, d] = rat(numimframes/length(trial_lever_force{i}));
    DownsampleRatios{i} = [n,d];
    trial_movement_downsampled{i} = resample(trial_lever_force{i},n,d);
    trial_binary_behavior_downsampled{i} = resample(double(trial_binary_behavior{i}),n,d);
    trial_cue_downsampled{i} = resample(trial_binary_cue{i},n,d);
        %%% Correct edge-effects of resampling
        trial_movement_downsampled{i}(1:10) = repmat(median(Behavior.lever_force_smooth),1,10); %%% Cannot assume that the baseline is zero for the raw lever data
        trial_movement_downsampled{i}(end-9:end) = repmat(median(Behavior.lever_force_smooth),1,10);
        trial_binary_behavior_downsampled{i}(trial_binary_behavior_downsampled{i}>=0.5) = 1;
        trial_binary_behavior_downsampled{i}(trial_binary_behavior_downsampled{i}<0.5) = 0;
        trial_cue_downsampled{i}(trial_cue_downsampled{i}>=0.5) = 1;
        trial_cue_downsampled{i}(trial_cue_downsampled{i}<0.5) = 0;
        if length(trial_movement_downsampled{i})~=size(Trial{i}.trialactivity,2)
            trial_movement_downsampled{i} = trial_movement_downsampled{i}(1:size(Trial{i}.trialactivity,2));
        end
        if length(trial_binary_behavior_downsampled{i}) ~= size(Trial{i}.trialactivity,2)
            trial_binary_behavior_downsampled{i} = trial_binary_behavior_downsampled{i}(1:size(Trial{i}.trialactivity,2));
        end
        if length(trial_cue_downsampled{i}) ~= size(Trial{i}.trialactivity,2)
            trial_cue_downsampled{i} = trial_cue_downsampled{i}(1:size(Trial{i}.trialactivity,2));
        end
    if ~isempty(Behavior.Behavior_Frames{i}.states.reward)
        reward = reward+1;
        trial_rewarded_presses{i} = double(trial_binary_behavior{i});
        startreward = Behavior.Behavior_Frames{i}.states.reward(1)-starttrial_imframes;
        if startreward == 0
            startreward = 1;
        end
        reward_period{i}(startreward:endtrial_imframes) = 1;
        startmovement = startcue+find(sign(diff(trial_binary_behavior_downsampled{i}(startcue:startreward))) == 1, 1,'last');   %%% needs to be in terms of imaging frames, so use downsampled
        if isempty(startmovement)
            startmovement = startcue;
        end
        endmovement = startmovement + find(sign(diff(trial_binary_behavior_downsampled{i}(startcue:endtrial_imframes))) == -1, 1,'first');
        if isempty(endmovement)
            endmovement = startmovement + 1000;
        end
        Trial{i}.MovementStart = startmovement-starttrial_imframes;
        Trial{i}.MovementEnd = endmovement-starttrial_imframes;
        Trial{i}.Result = 'Reward';
        Trial{i}.ResultStart = startreward;
        Trial{i}.ResultEnd = Behavior.Behavior_Frames{i}.states.reward(2)-starttrial_imframes;
        Trial{i}.EndLicking = endtrial_imframes;
        Trial{i}.cueactivity = Trial_dFoF_DendriteSubtracted{i}(startcue:endcue);
        alltrialframes = 1:endtrial_imframes;
        allmovement = trial_binary_behavior{i}(1:endtrial_imframes);
        alltrialmovementframes = alltrialframes(logical(allmovement));
        Trial{i}.successactivity{reward} = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(startcue:endtrial_imframes);
    else
        punish = punish+1;
        trial_rewarded_presses{i} = zeros(length(trial_binary_behavior{i}),1);
        startpunish = Behavior.Behavior_Frames{i}.states.punish(1)-starttrial_imframes;
        if startpunish == 0
            startpunish = 1;
        end
        punish_period{i}(startpunish:endtrial_imframes) = 1;
        startmovement = [];
        endmovement = [];
        Trial{i}.MovementStart = [];
        Trial{i}.MovementEnd = [];
        Trial{i}.Result = 'Punish';
        Trial{i}.ResultStart = startpunish;
        Trial{i}.ResultEnd = Behavior.Behavior_Frames{i}.states.punish(2)-starttrial_imframes;
        Trial{i}.EndLicking = [];
        Trial{i}.cueactivity = Trial_dFoF_DendriteSubtracted{i}(startcue:endcue);
%         if Trial{i}.ResultStart == 0 || Trial{i}.ResultEnd == 0
%             alltrialframes = 1:endtrial_imframes;
%             allmovement = trial_binary_behavior{i}(1:endtrial_imframes);
%             alltrialmovementframes = alltrialframes(logical(allmovement));
%             Trial{i}.failureactivity{punish} = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(startcue:endtrial_imframes);
%             continue
%         end
        alltrialframes = 1:endtrial_imframes;
        allmovement = trial_binary_behavior{i}(1:endtrial_imframes);
        alltrialmovementframes = alltrialframes(logical(allmovement));
        Trial{i}.failureactivity{punish} = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(startcue:endtrial_imframes);
    end
    trial_rewarded_presses_downsampled{i} = resample(trial_rewarded_presses{i},n,d);
    trial_rewarded_presses_downsampled{i}(trial_rewarded_presses_downsampled{i}>=0.5) = 1;
    trial_rewarded_presses_downsampled{i}(trial_rewarded_presses_downsampled{i}<0.5) = 0;
    if length(trial_rewarded_presses_downsampled{i}) ~= size(Trial{i}.trialactivity,2)
        trial_rewarded_presses_downsampled{i} = trial_rewarded_presses_downsampled{i}(1:size(Trial{i}.trialactivity,2));
    end
    Trial{i}.allmovementduringtrialactivity = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(:,1:end).*repmat(trial_movement_downsampled{i}(1:end)', Fluor.NumberofSpines,1);
    Trial{i}.movementduringcueactivity = zeros(Fluor.NumberofSpines,length(Trial_SynapseOnlyBinarized_DendriteSubtracted{i}));
    Trial{i}.movementduringcueactivity(:,startcue:endcue) = Trial_SynapseOnlyBinarized_DendriteSubtracted{i}(:,startcue:endcue).*repmat(trial_movement_downsampled{i}(startcue:endcue)', Fluor.NumberofSpines,1);
    if ~mod(Behavior.Behavior_Frames{i}.states.state_0(1,2),1) %%% Test if integer value (any integer value put into 'mod' (e.g. mod(3,1)) returns zero. Any non-integer returns a nonzero. So using a 'not' boolean means the value is an integer)
        trial_frames(i,1:2) = [Behavior.Behavior_Frames{i}.states.state_0(1,2), Behavior.Behavior_Frames{i}.states.state_0(2,1)];
        imagingframestouse = [imagingframestouse,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1)];  %%% Designates the imaging frames to use according to when Dispatcher starts each trials
        trialstouse(i,1) = 1;
    else
        trial_frames(i,1:2) = nan(1,2);
        trialstouse(i,1) = 0;
    end
    
    figure(LeverTracePlots.figure);
    h2 = subplot(2,7,Fluor.Session); hold on;
    plot(trial_frames(i,1):trial_frames(i,2), (-1*trial_binary_behavior_downsampled{i}+0.5),'Color', blue)
    plot(trial_frames(i,1):trial_frames(i,2), trial_movement_downsampled{i},'k')
    if strcmpi(Trial{i}.Result, 'Reward')
        plot(starttrial_imframes+Trial{i}.ResultStart, min(trial_movement_downsampled{i}), '.g')
    else
        plot(starttrial_imframes+Trial{i}.ResultStart, min(trial_movement_downsampled{i}), 'xr')
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main Variable Selection Section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('trial_cue_downsampled') || ~exist('trial_binary_behavior_downsampled')
    Correlations = [];
    Classified = [];
    Trial = [];
    PredictionModel= [];
    return
end

binarycue = cell2mat(trial_cue_downsampled);
lever_movement = cell2mat(trial_movement_downsampled');
binary_behavior = cell2mat(trial_binary_behavior_downsampled');
floored_behavior = abs(lever_movement).*binary_behavior;
successful_behavior = cell2mat(trial_rewarded_presses_downsampled');
OverallSpine_Data = cell2mat(Trial_OverallSpineActivity);
Dend = cell2mat(Trial_Dendrite_Binarized);
spinedatatouse = cell2mat(Trial_SynapseOnlyBinarized);
causal_Data = cell2mat(Trial_CausalBinarized);
DendSubspinedatatouse = cell2mat(Trial_SynapseOnlyBinarized_DendriteSubtracted);
movementduringcue = binarycue.*binary_behavior';
reward_delivery = cell2mat(reward_period');
punishment = cell2mat(punish_period');

floored_spine_data =  spinedatatouse.*cell2mat(Trial_dFoF);
floored_dendsub_spine_data = DendSubspinedatatouse.*cell2mat(Trial_dFoF_DendriteSubtracted);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Broaden select binarized variables' activity window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% choose starting matrix (all behavior or just successful behavior, e.g.)
b = binary_behavior;
if b(end)==1
    b(end)=0;
end

window_frame = 30;

%%% Set a pre-movement window
temp1 = b; temp2 = find(diff(b)>0); temp3 = temp2-window_frame; temp3(temp3<0)= 1; temp3(temp3==0)=1;
for i = 1:length(temp2)
    temp1(temp3(i):temp2(i)) = 1;
end
temp1 = temp1-binary_behavior;
temp1(temp1<0) = 0;
premovement = temp1';

%%% Broaden movement in general

temp1 = b;
temp2 = find(diff(b)>0); 
temp3 = temp2-round(window_frame); 
temp3(temp3<=0)= 1;
temp3(temp3==0) = 1;
temp4 = find(diff(b)<0); 
temp5 = temp4+round(window_frame);
    
for i = 1:length(temp2)
    temp1(temp3(i):temp5(i)) = 1;
end
if length(temp1)>length(b)
    temp1 = temp1(1:length(b));
end
wide_window = temp1;

%%% Broaden rewarded presses
b = successful_behavior;
if b(end)==1
    b(end)=0;
end
temp1 = b;
temp2 = find(diff(b)>0); 
temp3 = temp2-round(window_frame); 
temp3(temp3<0)= 1;
temp3(temp3==0) = 1;
temp4 = find(diff(b)<0); 
temp5 = temp4+round(window_frame);      

for i = 1:length(temp2)
    temp1(temp3(i):temp5(i)) = 1;
end
if length(temp1)>length(b)
    temp1 = temp1(1:length(b));
end
wide_succ_window = temp1;

%%%% Correlation Coefficients %%%

[r_Overallspine, p_Overallspine] = corrcoef([binarycue', binary_behavior,wide_window, premovement', successful_behavior,wide_succ_window,movementduringcue', reward_delivery, punishment, OverallSpine_Data', Dend']);
[r_spine, p_spine] = corrcoef([binarycue',binary_behavior,wide_window, premovement', successful_behavior,wide_succ_window,movementduringcue',reward_delivery,punishment, spinedatatouse', Dend']);
[r_DSspine, p_DSspine] = corrcoef([binarycue',binary_behavior,wide_window, premovement', successful_behavior,wide_succ_window,movementduringcue',reward_delivery,punishment, DendSubspinedatatouse', Dend']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SpineActMovePeriods = spinedatatouse'.*repmat(binary_behavior,1,size(DendSubspinedatatouse,1));
SpineActStillPeriods = spinedatatouse'.*~repmat(binary_behavior,1,size(DendSubspinedatatouse,1));

[r_mov, ~] = corrcoef(SpineActMovePeriods);
[r_still, ~] = corrcoef(SpineActStillPeriods);
[r_causal, p_causal] = corrcoef([binarycue', binary_behavior,wide_window, premovement', successful_behavior,wide_succ_window,movementduringcue', reward_delivery, punishment, causal_Data', Dend']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Save Correlation Variables in Structure %%%%%%%%%%%%%%%%%%%%%

Correlations.OverallSpineCorrelations = r_Overallspine;
Correlations.OverallSpinePValues = p_Overallspine;
Correlations.SpineCorrelations = r_spine;
Correlations.SpinePValues = p_spine;
Correlations.DendSubtractedSpineCorrelations = r_DSspine;
Correlations.DendSubtractedSpinePValues = p_DSspine;
Correlations.SpineDuringMovePeriods = r_mov;
Correlations.SpineDuringStillPeriods = r_still;
Correlations.LeverMovement = lever_movement;
Correlations.BinarizedBehavior = binary_behavior;
Correlations.CausalCorrelations = r_causal;
Correlations.CausalPValues = p_causal;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Statistical Classification of ROIs 


[Classified.CueSpines,~,~] = mv_related_classifi(spinedatatouse, binarycue, 'cue');
[Classified.MovementSpines,~, ~] = mv_related_classifi(spinedatatouse, binary_behavior', 'movement');
[Classified.MovementDuringCueSpines, ~,~] = mv_related_classifi(spinedatatouse, movementduringcue, 'movement-during-cue');
[Classified.PreSuccessSpines,~,~] = mv_related_classifi(spinedatatouse, premovement, 'premovement');
[Classified.SuccessSpines,~,~] = mv_related_classifi(spinedatatouse, successful_behavior', 'successful movement');
[Classified.RewardSpines,~,~] = mv_related_classifi(spinedatatouse,reward_delivery', 'reward');
[Classified.MovementSpLiberal, ~, ~] = mv_related_classifi(spinedatatouse, wide_window', 'extended movement');

[Classified.DendSub_CueSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, binarycue, 'cue');
[Classified.DendSub_MovementSpines,~, ~] = mv_related_classifi(DendSubspinedatatouse, binary_behavior', 'movement');
[Classified.DendSub_MovementDuringCueSpines, ~,~] = mv_related_classifi(DendSubspinedatatouse, movementduringcue, 'movement-during-cue');
[Classified.DendSub_PreSuccessSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, premovement, 'premovement');
[Classified.DendSub_SuccessSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, successful_behavior', 'successful movement');
[Classified.DendSub_RewardSpines,~,~] = mv_related_classifi(DendSubspinedatatouse,reward_delivery', 'reward');
[Classified.DendSub_MovementSpLiberal, ~, ~] = mv_related_classifi(DendSubspinedatatouse, wide_window', 'extended movement');

[Classified.CueDends, ~, ~] = mv_related_classifi(Dend', binarycue, 'cue (dendrite)');
[Classified.MovementDends, ~, ~] = mv_related_classifi(Dend', binary_behavior', 'movement (dendrite)');
[Classified.PreSuccessDends, ~,~] = mv_related_classifi(Dend', premovement, 'premovement (dendrite)');
[Classified.SuccessDends, ~, ~] = mv_related_classifi(Dend', successful_behavior', 'successful movement (dendrite)');
[Classified.MovementDuringCueDends, ~, ~] = mv_related_classifi(Dend', movementduringcue, 'movement during cue (dendrite)');
[Classified.RewardDends, ~, ~] = mv_related_classifi(Dend', reward_delivery', 'reward (dendrite)');

[Classified.CausalMovementSpines, ~, ~] = mv_related_classifi(causal_Data, binary_behavior', 'causal movement');
[Classified.CausalMovementSpLiberal, ~,~] = mv_related_classifi(causal_Data, wide_window', 'extended causal movement');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Spine Reliability %%%

bound = find(diff([Inf; binary_behavior; Inf])~=0);
allperiods = mat2cell(binary_behavior, diff(bound));
moveperiods = allperiods(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiods, 'uni', false)));
movespines = find(Classified.MovementSpines);
counter = 1;
AllSpineReliability = nan(numberofSpines,1);
MovementSpineReliability = nan(length(movespines),1);


for i = 1:numberofSpines
    allspineactivity_separated = mat2cell(spinedatatouse(i,:)', diff(bound));
    spineactivity_moveperiods = allspineactivity_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiods, 'uni', false)));
    numberofmovementswithspineactivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), moveperiods, spineactivity_moveperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
    AllSpineReliability(counter, 1) = numberofmovementswithspineactivity/length(moveperiods);
    counter = counter+1;
end

Classified.AllSpineReliability = AllSpineReliability;

for i = 1:length(movespines)
    movespineactivity_separated = mat2cell(spinedatatouse(movespines(i),:)', diff(bound));
    movespineactivity_moveperiods = movespineactivity_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiods, 'uni', false)));
    numberofmovementswithmovespineactivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), moveperiods, movespineactivity_moveperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
    MovementSpineReliability(counter, 1) = numberofmovementswithmovespineactivity/length(moveperiods);
    counter = counter+1;
end
   
Classified.MovementSpineReliability = MovementSpineReliability;

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Multiple linear regression of spine activity data with movement %%%%%%%

%%%% Data options:
%%%% Spine activity data: Raw traces, floored traces (only activity
%%%% periods, preserves event amplitudes), binary traces, 
%%%% Movement data: Raw traces, floored traces WITH pushes and pulls
%%%% preserved, floored traces withOUT differentiating pushes and pulls,
%%%% binarized data

activitydataformodel = spinedatatouse;
movementdataformodel = binary_behavior;

% animal = regexp(Fluor.Filename, '[A-Z]{2,3}\d+', 'match'); animal = animal{1};
% 
% if isfolder(['C:/Users/Komiyama/Desktop/Output Data/', animal, ' New Spine Analysis'])
%     persistent longitudinalModel
%     fieldsource = fastdir(['C:/Users/Komiyama/Desktop/Output Data/', animal, ' New Spine Analysis'], 'Field');
%     filecount = 1;
%     for f = 1:length(fieldsource)
%         load(['C:/Users/Komiyama/Desktop/Output Data/', animal, ' New Spine Analysis/', fieldsource{f}])
%         fieldnumber = regexp(fieldsource{f}, '\d+.Spine');
%         eval(['FieldData{', num2str(filecount), '} = SpineRegistry;']);
%         clear SpineRegistry
%         filecount = filecount+1;
%     end
%     currentdate = regexp(Fluor.Filename, '[0-9]{4,6}', 'match');
%     for i = 1:length(FieldData)
%         if sum(cell2mat(cellfun(@(x) strfind(x,currentdate), FieldData{i}.DatesAcquired, 'uni', false)))   %%% if the current file date is found within the current field data
%             datesused = sortrows(FieldData{i}.DatesAcquired);
%             instance = find(cell2mat(cellfun(@(x) ~isempty(logical(strfind(x,currentdate))), datesused, 'uni', false)));
%             if instance >1   %%% If the current file is the second instance of longitudinal data, USE THE FIRST INSTANCE'S MODEL!
%                 Model = longitudinalModel{i}{1};
%                 PredictedMovement = predict(Model, activitydataformodel');
%                 predictioncorrelation = corrcoef(movementdataformodel, PredictedMovement);
%                 PredictionAccuracy = (predictioncorrelation(1,2)).^2;
%                 if isnan(PredictionAccuracy)
%                     PredictionAccuracy = 0;
%                 end
%             else
%                [Model,~, PredictionAccuracy] = PredictMovementfromSpineAct(activitydataformodel, movementdataformodel); 
%                longitudinalModel{i}{instance} = Model;
%             end
%         end
%     end
% else
    [Model,~, PredictionAccuracy] = PredictMovementfromSpineAct(activitydataformodel, movementdataformodel);
% end

PredictionModel.Model = Model;
PredictionModel.PredictionAccuracy = PredictionAccuracy;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Done with session ', num2str(Fluor.Session)])

