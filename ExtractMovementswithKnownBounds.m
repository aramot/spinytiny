function [Movements] = ExtractMovementswithKnownBounds(levertrace, framesofinterest, rewardperiods)

startbufferwindow = 10;
stopbufferwindow = 90;

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
    if framesofinterest{i}(end)+stopbufferwindow >length(levertrace)
        stop = length(levertrace);
    else
        stop = framesofinterest{i}(end)+stopbufferwindow;
    end
    ExtractedMovements{i} = levertrace(start:stop);
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
        ExtractedMovements{i} = [ExtractedMovements{i}; max(ExtractedMovements{i})*ones(lengthdiff,1)];
    end
end


Movements = cell2mat(ExtractedMovements);