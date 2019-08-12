function [square, floored,trueeventcount, threshold, Method] =  DetectEvents2(data, Options)

data(isnan(data)) = 0;

[caEvents, threshold, Method] = AP_caEvents_thresh(data,Options);

floored = caEvents;
    d2floored = [zeros(size(floored,1),2), diff(floored,2,2)];
    d2floored(d2floored<0) = -1; d2floored(d2floored>0) = 1;
    for sample = 1:size(d2floored,1)
        d2floored_smooth(sample,:) = smooth(d2floored(sample,:), 30, 'loess');
    end
square = caEvents; square(square~=0) = 1;
trueeventcount = square;
