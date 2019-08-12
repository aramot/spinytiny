function [Movements] = ExtractMovementswithKnownBounds(levertrace, framesofinterest, rewardperiods, TimingValues ,ImagingFrequency)

secondspremovementstart = TimingValues.SecondsPreMovement; %%% When looking at just behavior, move back Xs before the start of the movement period;
secondspostmovementstart = TimingValues.SecondsPostMovement;

% startbufferwindow = round(60*0.5);
% stopbufferwindow = round(60*secondspostmovement); 

startbufferwindow = round(ImagingFrequency*secondspremovementstart); 
stopbufferwindow = round(ImagingFrequency*secondspostmovementstart);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%% Aligned to actual rewarded press
% for i = 1:length(framesofinterest)
%     rewardstart = framesofinterest{i}(1)+find(rewardperiods(framesofinterest{i}), 1, 'first');
%     likelymovementwindow = rewardstart+15;
%     if likelymovementwindow > length(levertrace)
%         likelymovementwindow = length(levertrace);
%     end
%     [~, ind] = min(levertrace(rewardstart:likelymovementwindow));
%     movementpeak = rewardstart+ind;
%     movementstart = movementpeak-startbufferwindow;
%     movementend = movementstart+stopbufferwindow;
%     if movementend>length(levertrace)
%         movementend = length(levertrace);
%     end
%     ExtractedMovements{i} = levertrace(movementstart:movementend);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(framesofinterest)
    if framesofinterest{i}(1)-startbufferwindow < 1
        start = 1;
    else
        start = framesofinterest{i}(1)-startbufferwindow;
    end
    if start+stopbufferwindow >length(levertrace)
        stop = length(levertrace);
    else
        stop = start+stopbufferwindow;
    end
    if length(start:stop)< stopbufferwindow+1   %%% For when the movements are near the end of the recording session
        windowdiff = (stopbufferwindow+1)-length(start:stop);
        ExtractedMovements{i} = [levertrace(start:stop); levertrace(stop)*ones(windowdiff,1)];
    else
        ExtractedMovements{i} = levertrace(start:stop);
    end
end


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