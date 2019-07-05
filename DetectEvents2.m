function [square, floored,trueeventcount, topspikes, both] =  DetectEvents2(data, threshold)

data(isnan(data)) = 0;

caEvents = AP_caEvents_thresh(data,threshold,0);

floored = caEvents;
    d2floored = [zeros(size(floored,1),2), diff(floored,2,2)];
    d2floored(d2floored<0) = -1; d2floored(d2floored>0) = 1;
    for sample = 1:size(d2floored,1)
        d2floored_smooth(sample,:) = smooth(d2floored(sample,:), 30, 'loess');
    end
    topspikes = floored; topspikes(d2floored_smooth>=0.1) = 0;
    ternarized = topspikes; ternarized(ternarized~=0) = 1;
square = caEvents; square(square~=0) = 1;
    both = square+(0.5*ternarized);
trueeventcount = square;
