function [Correlations, Classified, Trial] = NHanalyAlignBehavior(varargin)

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


va = varargin;


if isfield(va{1}, 'DispatcherData')
    Behavior = va{1};
    Fluor = va{2};
else
    Behavior = va{2};
    Fluor = va{1};
end

if isfield(Behavior, 'StartAtTrial')
    firsttrial = Behavior.StartAtTrial;
else
    firsttrial = 1;
end

numberofTrials = length(firsttrial:length(Behavior.Behavior_Frames));
lasttrial = length(Behavior.Behavior_Frames);
numberofROIs = length(Fluor.roi_trace_df);% AR changed from "numberofSpines" to "numberofROIs, "dF_over_F" to "roi_trace_df"
% numberofDendrites = size(Fluor.Dendrite_dFoF,1);% AR 05072018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determine the framework of all of the data acquisition, as defined by
%%% Dispatcher

imagingframestouse = [];
behaviorframestouse = [];
trialstouse = zeros(numberofTrials,1);

ch = find(strcmp(Behavior.xsg_data.channel_names,'Trial_number'));
bitcode = parse_behavior_bitcode(Behavior.xsg_data.channels(:,ch));
bitcode_offset = [bitcode.behavior_trial_num]-(1:length(bitcode));

for i = firsttrial:lasttrial
    if abs(bitcode_offset(i))>=2
        continue
    end
    i_bitcode = i-bitcode_offset(i);
    start_trial = round(bitcode(i_bitcode).xsg_sec*1000);
    t0 = Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.bitcode(1);
    end_trial = start_trial+round((Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(2,1)-t0)*1000);
    trial_movement{i} = Behavior.lever_force_smooth(start_trial:end_trial);
    trial_activity{i} = Fluor.caEvents(1,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1)); %% AR changed from "Fluot.Processed_dFoF_DendriteSubtracted(1"
    if ~mod(Behavior.Behavior_Frames{i}.states.state_0(1,2),1); %%% Test if integer value (any integer value put into 'mod' (e.g. mod(3,1)) returns zero. Any non-integer returns a nonzero. So using a 'not' boolean means the value is an integer)
        trial_frames(i,1:2) = [Behavior.Behavior_Frames{i}.states.state_0(1,2), Behavior.Behavior_Frames{i}.states.state_0(2,1)];
        imagingframestouse = [imagingframestouse,Behavior.Behavior_Frames{i}.states.state_0(1,2):Behavior.Behavior_Frames{i}.states.state_0(2,1)];  %%% Designates the imaging frames to use according to when Dispatcher starts each trials
        beh_trial_frames(i,1:2) = [Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(1,2),  Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(2,1)];
        behaviorframestouse = [behaviorframestouse, Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(1,2): Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(2,1)];
        trialstouse(i,1) = 1;
    else
        trial_frames(i,1:2) = nan(1,2);
        trialstouse(i,1) = 0;
    end
end

startframes = trial_frames(2:end,1);
endframes = trial_frames(1:end-1,2);
trial_gaps = startframes-endframes;

overlaps = find(trial_gaps<0);
extreme_overlaps = find(trial_gaps<-1);

if ~isempty(overlaps)
    disp([num2str(length(overlaps)), ' trials are overlapping by one...might shift alignment slightly!']);
else
end
if ~isempty(extreme_overlaps)
    disp([num2str(length(extreme_overlaps)), ' trials are significantly overlapping! This might be a big problem!']);
else
end

imagingframestouse = unique(imagingframestouse);
behaviorframestouse = unique(behaviorframestouse);

if imagingframestouse(end)>length(Fluor.roi_trace)       %%% Occasionally, the behavior goes longer than the imaging, so cut off the frames to use variable at the last imaging frame % AR changed "SynapseOnlyBinarized" to "roi_trace" 
    behaviorstoppoint = find(imagingframestouse == length(Fluor.roi_trace));% AR changed "SynapseOnlyBinarized" to "roi_trace" 
    if isempty(behaviorstoppoint)
        for i = 1:length(Fluor.roi_trace)% AR changed "SynapseOnlyBinarized" to "roi_trace" 
            lengthvector(1,i) = length(Fluor.roi_trace(1:i));% AR changed "SynapseOnlyBinarized" to "roi_trace" 
        end
        C = intersect(imagingframestouse,lengthvector);
        behaviorstoppoint = find(imagingframestouse == C(end));
    end
    imagingframestouse = imagingframestouse(1:behaviorstoppoint);
end

seek = 1; found = 0;
while found == 0        %%% Find the first integer value to use
    if logical(mod(imagingframestouse(seek),1))
        seek = seek+1;
    else
        found = 1;
        starterframe = seek;
    end
end

allpossibleframes = imagingframestouse(starterframe):imagingframestouse(end);
skippedframes = allpossibleframes(~ismember(allpossibleframes,imagingframestouse));
 
if ~isempty(skippedframes)
    warning('Some imaging frames were skipped during this experiment!')
%     valstosort = [imagingframestouse, skippedframes];
%     [imagingframestouse sortedindices] = sort(valstosort);
%     blankframes = zeros(1,length(imagingframestouse)+length(skippedframes));
    
%     for s = 1:numberofROIs    %% AR changed from "numberofSpines" to "numberofROIs
%         extendeddata = [Fluor.Processed_dFoF(s,:), blankframes];   
%         FramedProcessed_dFoF(s,1:length(extendeddata(sortedindices))) = extendeddata(sortedindices);
        blankdata = zeros(numberofROIs,length(imagingframestouse)+length(skippedframes)); %% AR changed from "numberofSpines" to "numberofROIs"
        tempdata = blankdata;
        tempdata(:,imagingframestouse) = Fluor.Processed_dFoF(:,imagingframestouse);
        FramedProcessed_dFoF = tempdata(:,imagingframestouse(1):imagingframestouse(end));
%     end
    
%     for s = 1:numberofSpines
%         extendeddata = [Fluor.Processed_dFoF_DendriteSubtracted(s,:), blankframes];
%         FramedProcessed_dFoF_DendriteSubtracted(s,1:length(extendeddata(sortedindices))) = extendeddata(sortedindices);
        tempdata = blankdata;
        tempdata(:,imagingframestouse) = Fluor.Processed_dFoF_DendriteSubtracted(:,imagingframestouse);
        FramedProcessed_dFoF_DendriteSubtracted =tempdata(:,imagingframestouse(1):imagingframestouse(end));
%     end
    
    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.OverallSpineActivity(:,imagingframestouse);
    FramedOverallROIActivity = tempdata(:,imagingframestouse(1):imagingframestouse(end)); % AR changed "FramedOverallspineActivity" to "FramedOverallROIActivity"
    
%     useddata = Fluor.OverallROIActivity(:,imagingframestouse); %% AR
%     changed from "Spine" to "ROI"
%     extendeddata = [useddata, repmat(blankframes,numberofROIs,1)]; %%%
%     add nans ("blankframes") onto the end of the data %% AR changed from
%     "numberofSpines"
%         FramedOverallSpineActivity = extendeddata(:,sortedindices);
    
    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.SynapseOnlyBinarized(:,imagingframestouse);
    FramedSynapseOnlyBinarized = tempdata(:,imagingframestouse(1):imagingframestouse(end));
    

    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.SynapseOnlyBinarized_DendriteSubtracted(:,imagingframestouse);
    FramedSynapseOnlyBinarized_DendriteSubtracted = tempdata(:,imagingframestouse(1):imagingframestouse(end));
    
    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.CausalBinarized(:,imagingframestouse);
    FramedCausalBinarized = tempdata(:,imagingframestouse(1):imagingframestouse(end));
    
    blankdata = zeros(numberofDendrites,length(imagingframestouse)+length(skippedframes));
    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.Processed_Dendrite_dFoF(:,imagingframestouse);
    FramedDendrite_dFoF = tempdata(:,imagingframestouse(1):imagingframestouse(end));
    
    tempdata = blankdata;
    tempdata(:,imagingframestouse) = Fluor.Dendrite_Binarized(:,imagingframestouse);
    FramedDendrite_Binarized = tempdata(:,imagingframestouse(1):imagingframestouse(end));
else
    FramedProcessed_dFoF = Fluor.Processed_dFoF(:,imagingframestouse);
    
    FramedProcessed_dFoF_DendriteSubtracted = Fluor.Processed_dFoF_DendriteSubtracted(:,imagingframestouse);

    FramedOverallROIActivity = Fluor.OverallSpineActivity(:,imagingframestouse);
    FramedSynapseOnlyBinarized = Fluor.SynapseOnlyBinarized(:,imagingframestouse);
    FramedSynapseOnlyBinarized_DendriteSubtracted = Fluor.SynapseOnlyBinarized_DendriteSubtracted(:,imagingframestouse);
    FramedCausalBinarized = Fluor.CausalBinarized(:,imagingframestouse);
    FramedDendrite_dFoF = Fluor.Processed_Dendrite_dFoF(:,imagingframestouse);
    FramedDendrite_Binarized = Fluor.Dendrite_Binarized(:,imagingframestouse);
end

numframes = size(FramedProcessed_dFoF,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Change buffer region around which to ignore dendritic events
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AR added % to all the below 05072018
% % for i = 1:length(Fluor.SpineDendriteGrouping)
%     dendtimebuffer = 30;
%     
%     widerdend = FramedDendrite_Binarized(i,:);
%     rises = find(diff(FramedDendrite_Binarized(i,:))>0);
%     falls = find(diff(FramedDendrite_Binarized(i,:))<0);
% 
%     earlier_rises = rises-dendtimebuffer;
%         earlier_rises(earlier_rises<1) = 1;
%     later_falls = falls+dendtimebuffer;
%         later_falls(later_falls>length(FramedDendrite_Binarized(i,:))) = length(FramedDendrite_Binarized(i,:));
% 
%     for p = 1:length(earlier_rises)
%         widerdend(earlier_rises(p):rises(p)) = 1;
%     end
%     for p = 1:length(later_falls)
%         widerdend(falls(p):later_falls(p)) = 1;
%     end
% 
%     for j = 1:length(Fluor.SpineDendriteGrouping{i})
%         spineno = Fluor.SpineDendriteGrouping{i}(j);
%         FramedSynapseOnlyBinarized(spineno, :) = FramedSynapseOnlyBinarized(spineno,:)-widerdend;
%         FramedSynapseOnlyBinarized(spineno, FramedSynapseOnlyBinarized(spineno,:)<1) = 0;
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Find start and end times for different reads

im_freq = 30.49;    %%% This is always the imaging frequency at 12.1x zoom
% im_freq = 29.96;    %%% at 8.5x
beh_sample_freq = 1000;   %%% There are usually 1000x more frames in the lever measurement 

LastImagingFrameTime = Behavior.Frame_Times(imagingframestouse(end));
LastImagingFrameTime = LastImagingFrameTime/60;                                        %%% Time in minutes;

start_frame = round(Behavior.Frame_Times(imagingframestouse(1))*beh_sample_freq);      %%% Gives the time that the first imaging frame was acquired in terms of lever frames
end_frame = round(Behavior.Frame_Times(imagingframestouse(end))*beh_sample_freq);

ImagingDuration = numframes/im_freq;    %%% Find duration of imaging by taking the total number of frames and dividing by the imaging frequency
ImagingDuration = ImagingDuration/60;   %%% Convert to minutes
max_Beh_Time = length(Behavior.lever_force_smooth)/1000/60;
interval = max_Beh_Time/length(Behavior.lever_force_smooth);

imaged_beh_window = Behavior.lever_force_smooth(start_frame:end_frame);
imaged_binary_behavior = Behavior.lever_active(start_frame:end_frame);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Downsample Behavior %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n, d] = rat(numframes/length(imaged_beh_window));

compressed_imagedleverframes = resample(imaged_beh_window,n,d);
    compbehframes = length(compressed_imagedleverframes);
    
binary_behavior = resample(double(imaged_binary_behavior),n,d);

if compbehframes ~= numframes
    if compbehframes<numframes
        compressed_imagedleverframes = [0,compressed_imagedleverframes];
        binary_behavior = [0, binary_behavior];
        compbehframes = numframes;
    elseif compbehframes>numframes
        compressed_imagedleverframes = compressed_imagedleverframes(2:end);
        binary_behavior = binary_behavior(2:end);
        compbehframes = numframes;
    end
end

compressed_behavior_duration = compbehframes/im_freq/60;
compressed_behavior_time_interval = 0:(compressed_behavior_duration/(compbehframes-1)):compressed_behavior_duration;

% binary_behavior_full = resample(double(Behavior.lever_active),n,d); %%% Needed for future comparison to cue, rewards, etc., since the imaged_binary_behavior window is shifted

binary_behavior(binary_behavior<0.5) = 0;
binary_behavior(binary_behavior>=0.5) = 1;

% binary_behavior_full(binary_behavior_full<0.5) = 0;
% binary_behavior_full(binary_behavior_full>0.5) = 1;
% binary_behavior_full = binary_behavior_full(1:end-1);

compressed_behavior_framerate = length(compressed_imagedleverframes)/(max_Beh_Time*60); %%% Update the behavioral frame rate to correspond to the compressed data (should basically be the same as imaging frequency)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%
%%% Plot behavior %%%
%%%%%%%%%%%%%%%%%%%%%

scsz = get(0, 'ScreenSize');
AlignPlot = figure('Position', scsz);


% if length(Fluor.dF_over_F)+(12-mod(length(Fluor.dF_over_F), 6))<=60
%     h2 = subplot(10,6,(length(Fluor.dF_over_F)+(12-mod(length(Fluor.dF_over_F), 6))):60); hold on;
%     imstart = imagingframestouse(1)/im_freq/60;
%     plot(compressed_behavior_time_interval, (-1*binary_behavior+median(compressed_imagedleverframes)), 'Color', blue)
%     plot(compressed_behavior_time_interval, compressed_imagedleverframes, 'k')
%     xlabel('Time (min)');
%     ylabel('Lever Force');
% else

figure(LeverTracePlots.figure);
h2 = subplot(2,7,Fluor.Session); hold on;
imstart = imagingframestouse(1)/im_freq/60;
plot(compressed_behavior_time_interval, (-1*binary_behavior+median(compressed_imagedleverframes)), 'Color', blue)
plot(compressed_behavior_time_interval, compressed_imagedleverframes, 'k')
xlabel('Time (min)');
ylabel('Lever Force');
title(['Session ', num2str(Fluor.Session)])
% end

successes = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot movement with cues, rewards, and punishments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bitcode = parse_behavior_bitcode(Behavior.xsg_data.channels(:,3));

figure(AlignPlot);
for i = 1:numberofTrials
%     start_trial = bitcode(j).xsg_sec*1000;
%     t0 = Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.bitcode(1);
%     end_trial = round(start_trial+(Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.state_0(2,1)-t0)*1000);
% 
    %%% Filter trials for which the timing is off
    if i < numberofTrials %%% if any early trial has values that are larger than the next trial, there is an error, and you should exclude this trial
        if Behavior.Behavior_Frames{i}.states.cue(1) > Behavior.Behavior_Frames{i+1}.states.cue(1)
            trialstouse(i) = 0;
        end
    end
    if i>1  %%% If any trial has start values that are less than the termination of the previous trial, there is an error, and you should exclude this trial
        if Behavior.Behavior_Frames{i}.states.cue(1) < Behavior.Behavior_Frames{i-1}.states.cue(2)
            trialstouse(i) = 0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if trialstouse(i)
        cue(1:2,i) = Behavior.Behavior_Frames{i}.states.cue/im_freq/60;
        cue(1:2,i) = cue(1:2,i)-imstart;
%         bitcode_cue(1:2,i) = (start_trial+(Behavior.DispatcherData.saved_history.ProtocolsSection_parsed_events{i}.states.cue-t0)*1000)
        if ~isempty(Behavior.Behavior_Frames{i}.states.reward)
            result(1:2,i) = Behavior.Behavior_Frames{i}.states.reward(1)/im_freq/60;
            result(1:2,i) = result(1:2,i) - imstart;
            outcome(1,i) = 'o';
            plot(h2, result(1,i):result(2,i), -2, '.g')
            successes = successes + 1;
        else
            result(1:2,i) = Behavior.Behavior_Frames{i}.states.punish(1)/im_freq/60;
            result(1:2,i) = result(1:2,i)-imstart;
            outcome(1,i) = 'x';
            plot(h2, result(1,i):result(2,i), -2, 'xr', 'Linewidth', 2)
        end
        plot(h2,cue(1,i):0.001:cue(2,i), -2*ones(1,length(cue(1,i):0.001:cue(2,i))), '-m', 'LineWidth', 2)
    else
    end
end
text(compressed_behavior_duration,-0.25, ['Rewards = ', num2str(successes)])

xlim([0-2*imstart, max_Beh_Time])


%%%%%%%%%%%%%%%%%%%%%
%%% Plot Activity %%%
%%%%%%%%%%%%%%%%%%%%%

OverallROI_Data = zeros(numframes, numberofROIs); % AR changed from "numberofSpines" to "numberofROIs" and "Spine_data" to ROI_data"
ROI_Data = zeros(numframes,numberofROIs); % AR changed from "numberofSpines" to "numberofROIs and "Spine_data" to ROI_data"
% spine_Data_DendriteSubtracted = zeros(numframes,numberofROIs); % AR changed from "numberofSpines" to "numberofROIs
causal_Data = zeros(numframes,numberofROIs); % AR changed from "numberofSpines" to "numberofROIs
% Dend = zeros(numberofDendrites, numframes);

if length(Fluor.OverallROIActivity)<imagingframestouse(end);
    im_framestouse = imagingframestouse(1:find(imagingframestouse==length(Fluor.OverallROIActivity)));
    im_numframes = length(im_framestouse);
else
    im_framestouse = imagingframestouse;
    im_numframes = numframes;
end

for s = 1:length(Fluor.roi_trace_df) % AR changed "Fluor.dF_over_F" to "roi_trace_df"
    outcome_pos = max(Fluor.Processed_dFoF(s,:));
    OverallROI_Data(1:im_numframes,s) = FramedOverallROIActivity(s,:);   %%% Used binarized spine data prior to excluding periods of dendritic activity
    ROI_Data(1:im_numframes,s) = FramedSynapseOnlyBinarized(s,:);
    spine_Data_DendriteSubtracted(1:im_numframes,s) = FramedSynapseOnlyBinarized_DendriteSubtracted(s,:);
    causal_Data(1:im_numframes,s) = FramedCausalBinarized(s,:);
    
    if s>60
        continue
    end
    
    col1 = mod(s-1, length(colorj))+1;
    h1 = subplot(10,6,s); hold on;
    imagetime = LastImagingFrameTime-imstart;
    plot([0:(imagetime/numframes):(imagetime-(imagetime/numframes))], FramedProcessed_dFoF(s,:), 'color', colorj{col1})
    xlabel('Time (min)');
    ylabel('\DeltaF_S_p_i_n_e/F_0');
   
    
    for i = 1:numberofTrials
        if trialstouse(i)
            if strcmpi(outcome(1,i),'o')
                plot(h1,result(1,i):result(2,i), outcome_pos+1, '.g', 'LineWidth', 2)
            else
                plot(h1,result(1,i):result(2,i), outcome_pos+1, 'xr', 'LineWidth', 2)
            end
            plot(h1,cue(1,i):0.001:cue(2,i), ones(1,length(cue(1,i):0.001:cue(2,i)))*(outcome_pos+1), '-m', 'LineWidth', 1)
        else
        end
    end
    ylim([-1 outcome_pos+5])
    xlim([-1 ImagingDuration+1])
end

if size(ROI_Data,1)~= length(binary_behavior)
    ROI_Data = ROI_Data(1:length(binary_behavior),:);
end
% if size(spine_Data_DendriteSubtracted,1)~=length(binary_behavior)
%     spine_Data_DendriteSubtracted = spine_Data_DendriteSubtracted(1:length(binary_behavior),:);
% end
if size(causal_Data,1)~= length(binary_behavior)
    causal_Data = causal_Data(1:length(binary_behavior),:);
end
if size(OverallROI_Data,1)~= length(binary_behavior)
    OverallROI_Data = OverallROI_Data(1:length(binary_behavior),:);
end


%%% Make the dendrite graph occupy the remaining row of graphs by counting
%%% up to the nearest multiple of 6
% t = 1;
% while mod(numberofROIs+t,6) ~= 0  % AR changed from "numberofSpines" to "numberofROIs
%     t = t+1;
% end
% 
% max_d = max(max(FramedDendrite_dFoF));
% if s >=60
%     disp('Too many spines to display')
%     for i = 1:numberofDendrites
%         Dend(i,:) = FramedDendrite_Binarized(i,:);
%         Dend(isnan(Dend)) = 0;
%     end
% else
%     h3 = subplot(10,6,(numberofROIs+1):(numberofROIs+t)); hold on; % AR changed from "numberofSpines" to "numberofROIs
%     for i = 1:size(Fluor.Dendrite_Binarized,1)
%         grayer = i-1;
%         plot([0:(imagetime/numframes):(imagetime-(imagetime/numframes))],FramedDendrite_dFoF(i,:), 'color', [(0+grayer*.10),(0+grayer*.10),(0+grayer*.10)])
%         Dend(i,1:im_numframes) = FramedDendrite_Binarized(i,:);
%         Dend(isnan(Dend)) = 0;
%     end
%     for i = 1:numberofTrials
%         if trialstouse(i)
%             if strcmpi(outcome(1,i),'o')
%                 plot(h3,result(1,i):result(2,i), max_d+1, '.g', 'LineWidth', 2)
%             else
%                 plot(h3,result(1,i):result(2,i), max_d+1, 'xr', 'LineWidth', 2)
%             end
%             plot(h3,cue(1,i):0.001:cue(2,i), ones(1,length(cue(1,i):0.001:cue(2,i)))*(max_d+1), '-m', 'LineWidth', 1)
%         end
%     end
%         ylim([-1 max_d+5])
%         xlim([-1 ImagingDuration+1])
% end
% 
% if size(Dend,2) ~= length(binary_behavior)
%     Dend = Dend(:,1:length(binary_behavior));
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make a larger window for behavioral/activity correlations (activity
%%% might precede behavior!!

%%% Spine-activity-triggered movement average
% for i = 1:length(allrise)
%     if allrise(i)+5000<length(newcompressed)
%         SAT(i,1:5000) = newcompressed(allrise(i):allrise(i)+5000);
%     else
%         SAT(i,1:5000) = nan(1,5000);
%         SAT(i,1:length(newcompressed(allrise(i):end))) = newcompressed(allrise(i):end);
%     end
% end

window = 0.5; %%% 500ms
window_frame = round(compressed_behavior_framerate*window);

temp1 = binary_behavior;
temp2 = find(diff(binary_behavior)>0);  %% Find all rises
temp3 = temp2-round(window_frame);      %% Shift start point of movement to 500ms prior to start (for activity correlation purposes)
temp3(temp3<0)= 1;
temp3(temp3==0) = 1;
temp4 = find(diff(binary_behavior)<0);  %% Find all falls
temp5 = temp4+round(window_frame);      %% Extend the movement window by 500ms
temp5(temp5>length(binary_behavior)) = length(binary_behavior);

%%% Extend pre-event window
for i = 1:length(temp2)
    temp1(temp3(i):temp2(i)) = 1;
end

%%% Extend post-event window
% for i = 1:length(temp4)
%     temp1(temp4(i):temp5(i)) = 1;
% end

wide_window = temp1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Define Successful/Rewarded Presses %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reward = 0;
punish = 0;

binarycue = zeros(1,length(binary_behavior));
successful_behavior = zeros(1,length(binary_behavior));
    reward_delivery = zeros(1,length(binary_behavior));
failed_behavior = zeros(1,length(binary_behavior));
    punishment = zeros(1,length(binary_behavior));
    
triallength = zeros(1,length(Behavior.Behavior_Frames));

correction = imagingframestouse(1)-1;

overallsignaltouse = FramedProcessed_dFoF;
dendsub_signaltouse = FramedProcessed_dFoF_DendriteSubtracted;
binarized_signaltouse = ROI_Data';
binarized_dendsub_signaltouse = spine_Data_DendriteSubtracted';

for i = firsttrial:length(Behavior.Behavior_Frames)
    if trialstouse(i)
        %%% Rewarded trials
        if ~isempty(Behavior.Behavior_Frames{i}.states.reward) && Behavior.Behavior_Frames{i}.states.reward(1) < imagingframestouse(end)   %%% If a reward was received 

            reward = reward+1;

            starttrial = Behavior.Behavior_Frames{i}.states.state_0(1,2)-correction;
            startcue = Behavior.Behavior_Frames{i}.states.cue(1)-correction;
            endcue = Behavior.Behavior_Frames{i}.states.cue(2)-correction;
            startreward = Behavior.Behavior_Frames{i}.states.reward(1)-correction;
            startmovement = startcue+find(sign(diff(binary_behavior(startcue:startreward))) == 1, 1,'last'); %%% Find the last positive derivative, indicating the final increase to an active position prior to reward
            endtrial = Behavior.Behavior_Frames{i}.states.state_0(2,1)-correction;
            endlicking = endcue+round(2*im_freq);    %%% Add four seconds for estimating when reward is received ()Estimated from Takaki's paper 

            if endtrial > length(binary_behavior)
                endtrial = length(binary_behavior);
                endlicking = length(binary_behavior);
            end

            if i < length(Behavior.Behavior_Frames)
                if length(binary_behavior) <= endcue
                    break
                end
            end

            if i < length(Behavior.Behavior_Frames)
                if length(binary_behavior) <= startcue;
                    break
                end
            end

            if length(overallsignaltouse)<= endcue
                break
            end
            if endcue<startcue+10
                startmovement = startreward;
            end

            binarycue(startcue:endcue) = 1;

            if isempty(startmovement)
                if i == length(Behavior.Behavior_Frames) || length(binary_behavior) <= endtrial                       %%% Only for the last trial
                    endmovement = startmovement+find(sign(diff(binary_behavior(startcue:end))) == -1, 1,'first');           %%% Find the first negative derivitive, indicating the cessation of the current movement
                else
                    if startcue < 500
                        rewindpoint = 0;
                    else
                        rewindpoint = 500;
                    end
                    startmovement = (startcue-rewindpoint) + find(sign(diff(binary_behavior(startcue-rewindpoint:endcue))) == 1, 1,'last');
                    endmovement = startmovement + find(sign(diff(binary_behavior(startcue:endtrial))) == -1, 1,'first'); %%% Find the first negative derivitive, indicating the cessation of the current movement
                    successful_behavior(1,startmovement:endmovement) = binary_behavior(startmovement:endmovement);
                end
            else
                if i == length(Behavior.Behavior_Frames) || length(binary_behavior) <= startcue
                    endmovement = startmovement + find(sign(diff(binary_behavior(startmovement:end))) == -1, 1,'last'); %%% Find the first negative derivitive, indicating the cessation of the current movement
                else
                    endmovement = startmovement + find(sign(diff(binary_behavior(startmovement:endtrial))) == -1, 1,'first'); %%% Find the first negative derivitive after 
                    successful_behavior(1,startmovement:endmovement) = binary_behavior(startmovement:endmovement);
                    reward_delivery(1,startreward:endlicking) = 1;
                end
            end


            if Fluor.NumberofSpines ~= length(Fluor.Fluorescence_Measurement);
                Fluor.NumberofSpines = length(Fluor.Fluorescence_Measurement);
            end
            Trial{i}.trialactivity = overallsignaltouse(:,starttrial:endlicking);
            Trial{i}.trialbinaryactivity = binarized_signaltouse(:,starttrial:endlicking);
            Trial{i}.trialdendsubactivity = dendsub_signaltouse(:,starttrial:endlicking); 
            Trial{i}.trialbinarydendsubactivity = binarized_dendsub_signaltouse(:,starttrial:endlicking);
            triallength(1,i) = length(startcue:endlicking);
                Trial{i}.TrialStart = starttrial;
                Trial{i}.CueStart = startcue-starttrial;
                Trial{i}.CueEnd = endcue-starttrial;
                Trial{i}.MovementStart = startmovement-starttrial;
                Trial{i}.MovementEnd = endmovement-starttrial;
                Trial{i}.Result = 'Reward';
                Trial{i}.ResultStart = Behavior.Behavior_Frames{i}.states.reward(1)-correction;
                Trial{i}.ResultEnd = Behavior.Behavior_Frames{i}.states.reward(2)-correction;
                Trial{i}.EndLicking = endlicking-starttrial;
            Trial{i}.cueactivity = binarized_signaltouse(startcue:endcue);
                alltrialframes = starttrial:endtrial;
                allmovement = binary_behavior(starttrial:endtrial);
                alltrialmovementframes = alltrialframes(logical(allmovement));
            Trial{i}.allmovementduringtrialactivity = binarized_signaltouse(:,starttrial:endtrial).*repmat(binary_behavior(starttrial:endtrial)', Fluor.NumberofSpines,1);
            Trial{i}.movementduringcueactivity = binarized_signaltouse(:,startcue:endcue).*repmat(binary_behavior(startcue:endcue)', Fluor.NumberofSpines,1);
            Trial{i}.successactivity{reward} = binarized_signaltouse(startcue:endlicking);
            Trial{i}.failureactivity{reward} = [];

            %%% Unrewarded trials
        elseif isempty(Behavior.Behavior_Frames{i}.states.reward)

            punish = punish+1;

            starttrial = Behavior.Behavior_Frames{i}.states.state_0(1,2)-correction;
            startcue = Behavior.Behavior_Frames{i}.states.cue(1)-correction; 
            endcue = Behavior.Behavior_Frames{i}.states.cue(2)-correction;
            startpunish = Behavior.Behavior_Frames{i}.states.punish(1)-correction;
            endtrial = Behavior.Behavior_Frames{i}.states.state_0(2,1)-correction;

            if endtrial > length(binary_behavior)
                endtrial = length(binary_behavior);
            end

            if i < length(Behavior.Behavior_Frames)
                if length(binary_behavior) <= endcue 
                    break
                end
            end

            binarycue(startcue:endcue) = 1;

            failed_behavior(1,starttrial:endtrial) = binary_behavior(starttrial:endtrial);
            punishment(1,startpunish:endtrial) = 1;

            if i < length(Behavior.Behavior_Frames)
                if length(binary_behavior) <= startcue;
                    break
                end
            end

            if length(overallsignaltouse)<= endcue
                break
            end

            endlicking = startpunish+round(4*im_freq); 

            Trial{i}.trialactivity = overallsignaltouse(:,starttrial:endtrial);
            Trial{i}.trialbinaryactivity = binarized_signaltouse(:,starttrial:endtrial);
            Trial{i}.trialdendsubactivity = dendsub_signaltouse(:,starttrial:endtrial);
            Trial{i}.trialbinarydendsubactivity = binarized_dendsub_signaltouse(:,starttrial:endtrial);
            triallength(1,i) = length(starttrial:endtrial);
                Trial{i}.TrialStart = starttrial;
                Trial{i}.CueStart = startcue-starttrial;
                Trial{i}.CueEnd = endcue-starttrial;
                Trial{i}.MovementStart = [];
                Trial{i}.MovementEnd = [];
                Trial{i}.Result = 'Punish';
                Trial{i}.ResultStart = Behavior.Behavior_Frames{i}.states.cue(2);
                Trial{i}.ResultEnd = Behavior.Behavior_Frames{i}.states.punish(2);
                Trial{i}.EndLicking = [];
            Trial{i}.cueactivity = binarized_signaltouse(:,startcue:endcue);
            Trial{i}.allmovementduringtrialactivity = binarized_signaltouse(:,starttrial:endtrial).*repmat(binary_behavior(starttrial:endtrial)', Fluor.NumberofSpines,1);
            Trial{i}.movementduringcueactivity = binarized_signaltouse(:,startcue:endcue).*repmat(binary_behavior(startcue:endcue)', Fluor.NumberofSpines,1);
            Trial{i}.successfulmovementactivity = [];
            Trial{i}.failureactivity{punish} = binarized_signaltouse(:,starttrial:endtrial);
        end
    else
        Trial{i}.trialactivity = [];
        Trial{i}.trialbinaryactivity = [];
        Trial{i}.trialbinarydendsubactivity = [];
            Trial{i}.TrialStart = [];
            Trial{i}.CueStart = [];
            Trial{i}.CueEnd = [];
            Trial{i}.MovementStart = [];
            Trial{i}.MovementEnd = [];
            Trial{i}.Result = [];
            Trial{i}.ResultStart = [];
            Trial{i}.ResultEnd = [];
            Trial{i}.EndLicking = [];
        Trial{i}.cueactivity = [];
        Trial{i}.allmovementduringtrialactivity = [];
        Trial{i}.movementduringcueactivity = [];
        Trial{i}.successactivity = {};
        Trial{i}.failureactivity= {};
    end
end

if length(successful_behavior)<length(imagingframestouse)
    successful_behavior(length(successful_behavior)+1:imagingframestouse(end)) = 0;
end
% successful_behavior = successful_behavior(imagingframestouse);
successful_behavior(isnan(successful_behavior)) = 0;
if length(successful_behavior)~=length(binary_behavior)
    successful_behavior = successful_behavior(1:length(binary_behavior));
end

if length(failed_behavior)<length(imagingframestouse)
    failed_behavior(length(failed_behavior)+1:imagingframestouse(end)) = 0;
end
% failed_behavior = failed_behavior(imagingframestouse);
failed_behavior(isnan(failed_behavior)) = 0;
if length(failed_behavior)~=length(binary_behavior)
    failed_behavior = failed_behavior(1:length(binary_behavior));
end

binarycue = binarycue(1:length(binary_behavior));

%%% Make a larger window for behavioral/activity correlations (activity
%%% might precede behavior!!)

temp1 = successful_behavior;
temp2 = find(diff(successful_behavior)>0); %% Find all rises
temp3 = temp2-round(window_frame);         %% Shift start point of movement to 200ms prior to start (for activity correlation purposes)
temp3(temp3<0)= 1;
temp3(temp3==0)=1;
temp4 = find(diff(successful_behavior)<0); %% Find all falls
temp5 = temp4+round(window_frame);         %% Extend the movement window by 500ms
temp5(temp5>length(successful_behavior)) = length(successful_behavior);

for i = 1:length(temp2)
    temp1(temp3(i):temp2(i)) = 1;
end
for i = 1:length(temp4)
    temp1(temp4(i):temp5(i)) = 1;
end

wide_succ_window = temp1;

if length(wide_succ_window) ~=length(binary_behavior)
    wide_succ_window = wide_succ_window(1:length(binary_behavior));
end

% wide_succ_window = wide_succ_window 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OverallROI_Data(isnan(OverallROI_Data)) = 0;
ROI_Data(isnan(ROI_Data)) = 0;
spine_Data_DendriteSubtracted(isnan(spine_Data_DendriteSubtracted)) = 0;
Dend(isnan(Dend)) = 0;

%%% Pick spine data to use for behavioral correlation! This is the data
%%% that will be used for all behavioral associations, including all
%%% cluster/behavior correlations!!!!!!!

spinedatatouse = ROI_Data;
DendSubspinedatatouse = spine_Data_DendriteSubtracted;

%%%
%%% Opt to separate cue into subdivisions
%%%

movementduringcue = binarycue'.*binary_behavior;
% binarycue = binarycue.*binary_behavior';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pre-movement/success periods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% choose starting matrix (all behavior or just successful behavior, e.g.)
b = binary_behavior;

window = 0.2; %%% 500ms
window_frame = round(compressed_behavior_framerate*window);

temp1 = b;
temp2 = find(diff(temp1)>0); %% Find all rises
temp3 = temp2-window_frame;         %% Shift start point of movement to Xms prior to start (for activity correlation purposes)
temp3(temp3<0)= 1;
temp3(temp3==0)=1;

for i = 1:length(temp2)
    temp1(temp3(i):temp2(i)) = 1;
end

temp1 = temp1-binary_behavior;
temp1(temp1<0) = 0;

premovement = temp1';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[r_Overallspine, p_Overallspine] = corrcoef([binarycue', binary_behavior,wide_window, premovement', successful_behavior',wide_succ_window',movementduringcue, reward_delivery', punishment', OverallROI_Data, Dend']);
[r_spine, p_spine] = corrcoef([binarycue',binary_behavior,wide_window, premovement', successful_behavior',wide_succ_window',movementduringcue,reward_delivery',punishment', spinedatatouse, Dend']);
[r_DSspine, p_DSspine] = corrcoef([binarycue',binary_behavior,wide_window, premovement', successful_behavior',wide_succ_window',movementduringcue,reward_delivery',punishment', DendSubspinedatatouse, Dend']);

[Classified.CueSpines,~,~] = mv_related_classifi(spinedatatouse, binarycue, 'cue');
[Classified.MovementSpines,~, ~] = mv_related_classifi(spinedatatouse, binary_behavior', 'movement');
[Classified.MovementDuringCueSpines, ~,~] = mv_related_classifi(spinedatatouse, movementduringcue', 'movement-during-cue');
[Classified.PreSuccessSpines,~,~] = mv_related_classifi(spinedatatouse, premovement, 'premovement');
[Classified.SuccessSpines,~,~] = mv_related_classifi(spinedatatouse, successful_behavior, 'successful movement');
[Classified.RewardSpines,~,~] = mv_related_classifi(spinedatatouse,reward_delivery, 'reward');
[Classified.MovementSpLiberal, ~, ~] = mv_related_classifi(spinedatatouse, wide_window', 'extended movement');

[Classified.DendSub_CueSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, binarycue, 'cue');
[Classified.DendSub_MovementSpines,~, ~] = mv_related_classifi(DendSubspinedatatouse, binary_behavior', 'movement');
[Classified.DendSub_MovementDuringCueSpines, ~,~] = mv_related_classifi(DendSubspinedatatouse, movementduringcue', 'movement-during-cue');
[Classified.DendSub_PreSuccessSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, premovement, 'premovement');
[Classified.DendSub_SuccessSpines,~,~] = mv_related_classifi(DendSubspinedatatouse, successful_behavior, 'successful movement');
[Classified.DendSub_RewardSpines,~,~] = mv_related_classifi(DendSubspinedatatouse,reward_delivery, 'reward');
[Classified.DendSub_MovementSpLiberal, ~, ~] = mv_related_classifi(DendSubspinedatatouse, wide_window', 'extended movement');

[Classified.CueDends, ~, ~] = mv_related_classifi(Dend', binarycue, 'cue (dendrite)');
[Classified.MovementDends, ~, ~] = mv_related_classifi(Dend', binary_behavior', 'movement (dendrite)');
[Classified.PreSuccessDends, ~,~] = mv_related_classifi(Dend', premovement, 'premovement (dendrite)');
[Classified.SuccessDends, ~, ~] = mv_related_classifi(Dend', successful_behavior, 'successful movement (dendrite)');
[Classified.MovementDuringCueDends, ~, ~] = mv_related_classifi(Dend', movementduringcue', 'movement during cue (dendrite)');
[Classified.RewardDends, ~, ~] = mv_related_classifi(Dend', reward_delivery, 'reward (dendrite)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spineLabel{1,1} = 'Cue';
spineLabel{1,2} = 'Movement';
spineLabel{1,3} = '(Wider)';
spineLabel{1,4} = 'Premovement';
spineLabel{1,5} = 'Successes';
spineLabel{1,6} = '(Wider)';
spineLabel{1,7} = 'MovDurCue';
spineLabel{1,8} = 'Reward';
spineLabel{1,9} = 'Punishment';

otherfeatures =  length({binarycue', binary_behavior,wide_window, premovement', successful_behavior',wide_succ_window',movementduringcue, reward_delivery', punishment'}); %%% Make sure that this list is updated each time you add a feature into the correlation matrix!

counter = length(spineLabel);
for i = 1:numberofROIs    % AR changed from "numberofSpines" to "numberofROIs
    counter = counter+1;
    spineLabel{1,counter} = ['Spine ', num2str(i)];
end
for i = 1:size(Dend,1)
    counter = counter+1;
    spineLabel{1,counter} = ['Dendrite ', num2str(i)];
end
% HeatMap(r_spine, 'ColorMap', 'hot', 'RowLabels', spineLabel, 'ColumnLabels', spineLabel);
HMap = figure; imagesc(r_spine)
set(gcf, 'colormap', hot);
set(gca, 'XTick', [1:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures]) % AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'XTickLabel', [0:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures])% AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'YTick', [1:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures])% AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'YTickLabel', spineLabel)
colorbar
title(['Session', num2str(Fluor.Session)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SpineActMovePeriods = DendSubspinedatatouse.*repmat(binary_behavior,1,size(DendSubspinedatatouse,2));
SpineActStillPeriods = DendSubspinedatatouse.*~repmat(binary_behavior,1,size(DendSubspinedatatouse,2));

[r_mov, ~] = corrcoef(SpineActMovePeriods);
[r_still, ~] = corrcoef(SpineActStillPeriods);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Correlations.OverallSpineCorrelations = r_Overallspine;
Correlations.OverallSpinePValues = p_Overallspine;
Correlations.SpineCorrelations = r_spine;
Correlations.SpinePValues = p_spine;
Correlations.DendSubtractedSpineCorrelations = r_DSspine;
Correlations.DendSubtractedSpinePValues = p_DSspine;
Correlations.SpineDuringMovePeriods = r_mov;
Correlations.SpineDuringStillPeriods = r_still;
Correlations.BinarizedBehavior = binary_behavior;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


causal_Data(isnan(causal_Data)) = 0;


[r_causal, p_causal] = corrcoef([binarycue',binary_behavior,wide_window, premovement', successful_behavior',wide_succ_window',movementduringcue,reward_delivery',punishment', spinedatatouse, Dend']);

[Classified.CausalMovementSpines, ~, ~] = mv_related_classifi(causal_Data, binary_behavior', 'causal movement');
[Classified.CausalMovementSpLiberal, ~,~] = mv_related_classifi(causal_Data, wide_window', 'extended causal movement');


% HeatMap(r_spine, 'ColorMap', 'hot', 'RowLabels', spineLabel, 'ColumnLabels', spineLabel);
HMap2 = figure; imagesc(r_causal)
set(gcf, 'colormap', hot);
set(gca, 'XTick', [1:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures]) % AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'XTickLabel', [0:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures]) % AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'YTick', [1:length(Fluor.roi_trace_df)+size(Dend,1)+otherfeatures]) % AR chnaged "dF_over_F" to "roi_trace_df"
set(gca, 'YTickLabel', spineLabel)
colorbar
title(['Session', num2str(Fluor.Session)])

Correlations.CausalCorrelations = r_causal;
Correlations.CausalPValues = p_causal;

% Shift = mean(timeDiff);
% formatSpec = 'The peak correlation would shift the data by an average of %4.2f min\n';
% fprintf(formatSpec, Shift);
% % 
% pause;
try
    close(AlignPlot)
    close(HMap)
    close(HMap2)
catch
end

disp(['Done with session ', num2str(Fluor.Session)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%









