function [square, floored, threshold, Method] =  DetectEvents2(data, Options)

data(isnan(data)) = 0;

[caEvents, threshold, Method] = AP_caEvents_thresh(data,Options);

floored = caEvents;
square = caEvents; square(square~=0) = 1;

