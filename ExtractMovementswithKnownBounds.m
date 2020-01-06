function [Movements,UsedBlocks] = ExtractMovementswithKnownBounds(levertrace, binarizedlever, framesofinterest, actualactivityduringblocksofinterest, rewardperiods, TimingValues ,ImagingFrequency)

secondspremovementstart = TimingValues.SecondsPreMovement; %%% When looking at just behavior, move back Xs before the start of the movement period;
secondspostmovementstart = TimingValues.SecondsPostMovement;

% startbufferwindow = round(60*0.5);
% stopbufferwindow = round(60*secondspostmovement); 

startbufferwindow = round(ImagingFrequency*secondspremovementstart); 
stopbufferwindow = round(ImagingFrequency*secondspostmovementstart);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Method 1: Align to rewarded press
% %%%%%%%%%%%% Aligned to actual rewarded press (not applicable if
% %%%%%%%%%%%% inspecting all movements)
UsedBlocks = [];
% 
for i = 1:length(framesofinterest)
    movementstart = framesofinterest{i}(1); %%% These frames are define by when the movement starts in an acceptable cue period, so frame 1 = movement onset
%     rewardstart = find(rewardperiods(framesofinterest{i}), 1, 'first')+movementstart;
    %%% Choose whether to start from movement start or reward start!
    start = movementstart-startbufferwindow;
%     start = rewardstart-startbufferwindow;
    if start<1
        startbuffershift = levertrace(1)*ones(abs(start)+1,1);
        start = 1;
    else
        startbuffershift = [];
    end
    stop = start+(startbufferwindow+stopbufferwindow)-length(startbuffershift);
    if stop > length(levertrace)
        stopbuffer = levertrace(end)*ones(abs(stop-length(levertrace)),1);
        stop = length(levertrace);
    else
        stopbuffer = [];
    end
    ExtractedMovements{i} = [startbuffershift; levertrace(start:stop); stopbuffer];
    targetdifference = TimingValues.TargetLength-length(ExtractedMovements{i});
    if targetdifference
        if targetdifference>0
            ExtractedMovements{i} = [ExtractedMovements{i}; ExtractedMovements{i}(end)*ones(targetdifference,1)];
        else
            ExtractedMovements{i} = [ExtractedMovements{i}(1:end+targetdifference)];
        end
    end
    UsedBlocks = [UsedBlocks, i];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% No alignment; take contiguous movement trace over specifed
%%%%%%%%%%%%% window
% for i = 1:length(framesofinterest)
%     %%% Start point
%     if framesofinterest{i}(1)-startbufferwindow < 1
%         start = 1;
%         startbuffershift = levertrace(framesofinterest{i}(1))*ones(abs(framesofinterest{i}(1)-startbufferwindow)+1,1);
%     else
%         start = framesofinterest{i}(1)-startbufferwindow;
%         startbuffershift = [];
%     end
%     %%% Stop point
%     if framesofinterest{i}(1)+stopbufferwindow >length(levertrace)
%         stop = length(levertrace);
%         stopbuffer = levertrace(end)*ones(abs(framesofinterest{i}(1)+stopbufferwindow-length(levertrace)),1);
%     else
%         stop = framesofinterest{i}(1)+stopbufferwindow;
%         stopbuffer = [];
%     end
%     ExtractedMovements{i} = [startbuffershift; levertrace(start:stop);stopbuffer];
%     targetdifference = TimingValues.TargetLength-length(ExtractedMovements{i});
%     if targetdifference
%         ExtractedMovements{i} = [ExtractedMovements{i}; ExtractedMovements{i}(end)*ones(targetdifference,1)];
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Align to activity
% UsedBlocks = [];
% for i = 1:length(framesofinterest)
%     startpoint = 1;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Aligned to NEAREST movement in the block
% UsedBlocks = [];
% ExtractedMovements = cell(1,length(framesofinterest));
% for i = 1:length(framesofinterest)
%     if length(levertrace(framesofinterest{i}))<5
%         continue
%     end
%     if isempty(findpeaks(abs(levertrace(framesofinterest{i}))))
%        continue
%     end
%     [peaks, locs] = findpeaks(-levertrace); 
%     
%     
% %     [~,zeropoint] = min(levertrace(framesofinterest{i}));
%     if framesofinterest{i}(zeropoint)-startbufferwindow<1
%         start = 1;
%         startbuffershift = levertrace(framesofinterest{i}(1))*ones(abs(framesofinterest{i}(zeropoint)-startbufferwindow)+1,1);
%     else
%         start = framesofinterest{i}(zeropoint)-startbufferwindow;
%         startbuffershift = [];
%     end
%     stop = framesofinterest{i}(zeropoint)+stopbufferwindow;
%     if stop>length(levertrace)
%         stop = length(levertrace);
%         stopbuffer = levertrace(end)*ones(abs(framesofinterest{i}(zeropoint)+stopbufferwindow-length(levertrace)),1);
%     else
%         stopbuffer = [];
%     end
%     ExtractedMovements{i} = [startbuffershift; levertrace(start:stop); stopbuffer];
%     targetdifference = TimingValues.TargetLength-length(ExtractedMovements{i});
%     if targetdifference
%         ExtractedMovements{i} = [ExtractedMovements{i}; ExtractedMovements{i}(end)*ones(targetdifference,1)];
%     end
%     UsedBlocks = [UsedBlocks, i];
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Aligned to largest movement in the block
% UsedBlocks = [];
% ExtractedMovements = cell(1,length(framesofinterest));
% for i = 1:length(framesofinterest)
%     if length(levertrace(framesofinterest{i}))<5
%         continue
%     end
%     if isempty(findpeaks(abs(levertrace(framesofinterest{i}))))
%        continue
%     end
%     [~,zeropoint] = min(levertrace(framesofinterest{i}));
%     if framesofinterest{i}(zeropoint)-startbufferwindow<1
%         start = 1;
%         startbuffershift = levertrace(framesofinterest{i}(1))*ones(abs(framesofinterest{i}(zeropoint)-startbufferwindow)+1,1);
%     else
%         start = framesofinterest{i}(zeropoint)-startbufferwindow;
%         startbuffershift = [];
%     end
%     stop = framesofinterest{i}(zeropoint)+stopbufferwindow;
%     if stop>length(levertrace)
%         stop = length(levertrace);
%         stopbuffer = levertrace(end)*ones(abs(framesofinterest{i}(zeropoint)+stopbufferwindow-length(levertrace)),1);
%     else
%         stopbuffer = [];
%     end
%     ExtractedMovements{i} = [startbuffershift; levertrace(start:stop); stopbuffer];
%     targetdifference = TimingValues.TargetLength-length(ExtractedMovements{i});
%     if targetdifference
%         ExtractedMovements{i} = [ExtractedMovements{i}; ExtractedMovements{i}(end)*ones(targetdifference,1)];
%     end
%     UsedBlocks = [UsedBlocks, i];
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0); %%% Function for finding when data crosses zero
% count = 1;
% for i = 1:length(framesofinterest)
%     relative_act_start = find(diff([0;actualactivityduringblocksofinterest{i};0])>0);
%     actual_act_start = framesofinterest{i}(relative_act_start);
%     startwindow = round(ImagingFrequency*0.25);
%     stopwindow = round(ImagingFrequency*1);
% %     if length(actual_act_start)>1
% %         actbounds = find(diff([Inf, actualactivityduringblocksofinterest{i},Inf]));
% %         actblocks = mat2cell(actualactivityduringblocksofinterest{i},actbounds);
% %         frameblocks = mat2cell(framesofinterest{i}', diff(actbounds));
% %         frameblockswithact = frameblocks(cellfun(@any, actblocks));
% %         for act = 1:length(actual_act_start)
% %             thisactstart = frameblockswithact{act}(1);
% %             thisactend = frameblockswithacct{act}(end);
% %             [~,peak_ind] = min(levertrace(thisactstart-startwindow:thisactend+stopwindow));
% %             target = thisactstart-startwindow+peak_ind;
% %             start = target-startbufferwindow;
% %             stop = target+stopbufferwindow;
% %             if stop > length(levertrace)
% %                 stop = length(levertrace);
% %                 stopbuffer = levertrace(end)*ones(abs(target+stopbufferwindow-length(levertrace)),1);
% %             else
% %                 stopbuffer = [];
% %             end
% %             ExtractedMovements{count} = [levertrace(start:stop); stopbuffer];
% %             count = count+1;
% %         end
% %     else
% %         relative_act_end = find(diff(actualactivityduringblocksofinterest{i})<0);
% %         actual_act_end = framesofinterest{i}(relative_act_end);
% %         if actual_act_start-startwindow<1
% %             continue
% %         end
% % %         [~, peak_ind] = min(levertrace(actual_act_start-startwindow:actual_act_end+stopwindow));
% %         targetdata = levertrace(actual_act_start-startwindow:actual_act_end+stopwindow);
% %         [pks,locs] = findpeaks(abs(targetdata), 'MinPeakProminence', 0.1)
% %         target = actual_act_start-startwindow+peak_ind;
% %         start = target-startbufferwindow;
% %         stop = target+stopbufferwindow;
% %         if stop > length(levertrace)
% %             stop = length(levertrace);
% %             stopbuffer = levertrace(end)*ones(abs(target+stopbufferwindow-length(levertrace)),1);
% %         else
% %             stopbuffer = [];
% %         end
% %         ExtractedMovements{count} = [levertrace(start:stop); stopbuffer];
% %     end
%     [~,locs] = findpeaks(abs(levertrace(framesofinterest{i})), 'MinPeakProminence', 0.1);
%     for act = 1:length(relative_act_start)
%         timeoffsetfromact = locs-relative_act_start(act);
%         locs = locs(timeoffsetfromact>-startwindow);
%         target = framesofinterest{i}(locs(1));
%         start = target-startbufferwindow;
%         if start<1
%             start = 1;
%             startbuffer = levertrace(1)*ones(abs(target-startbufferwindow)+1,1);
%         else
%             startbuffer = [];
%         end
%         stop = target+stopbufferwindow;
%         if stop>length(levertrace)
%             stop = length(levertrace);
%             stopbuffer = levertrace(end)*ones(abs(target+stopbufferwindow-length(levertrace)),1);
%         else
%             stopbuffer = [];
%         end
%         ExtractedMovements{count} = [startbuffer; levertrace(start:stop); stopbuffer];
%         count = count+1;
%     end
%     count = count+1;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% for i = 1:length(framesofinterest)
%     ExtractedMovements{i} = levertrace(framesofinterest{i});
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxlength = max(cell2mat(cellfun(@length, ExtractedMovements, 'uni', false)));

for i = 1:length(ExtractedMovements)
    if isempty(ExtractedMovements{i})
        ExtractedMovements{i} = nan(maxlength,1);
    end
    if length(ExtractedMovements{i})<maxlength
        lengthdiff = maxlength-length(ExtractedMovements{i});
        ExtractedMovements{i} = [ExtractedMovements{i}; nan(lengthdiff,1)];
    end
end


Movements = cell2mat(ExtractedMovements);