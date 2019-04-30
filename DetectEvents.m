function [square, floored,trueeventcount, riders, both] =  DetectEvents(data, threshold)

%%% Variable initiation
numberofSpines = size(data,1);
floored = zeros(numberofSpines, size(data,2));
riderthresh = 1;
riderthresh2 = 2;


for i = 1:numberofSpines
    temp = data(i,:); %%% This value will be used as a "floored" term, which has zeros below the threshold. It will subsequenctly be used as a binarized term by setting all threshold values to 1.
    temp(temp<threshold(i,1)) = 0;
    floored(i,:) = temp;
    temp(temp<threshold(i,1)) = nan;
    tamp = temp;
    tamp(isnan(tamp)) = 0;
    tamp = smooth(tamp,30);
    dtamp = diff(tamp);     %%% first derivative of the binarized data
    dtamp = [0;dtamp];
    dtamp(dtamp>0) = 1; dtamp(dtamp<0) = -1;
    d2tamp = diff(dtamp);
    d2tamp = [0;d2tamp];    %%% Second derivative of the binarized data (concavity)
    d2tamp(d2tamp>0) = 1; d2tamp(d2tamp<0) = -1;
    temp(d2tamp>0) = nan; %% For plateau spikes, when the 2nd derivative is positive (concave up, corresponding to dips), punch a 'hole' in the data, so that multiple peaks will be counted
    riders(i,:) = temp;
end

%%% Set all events = 1, making square pulses corresponding to
%%% activity

square = [];
ternarized = riders;

ternarized(isnan(ternarized)) = 0;
ternarized(ternarized~=0) = riderthresh2-1.5;

for i = 1:numberofSpines
    temp = floored(i,:);   %%% This value will eventually be used to define "synapse only" events, which only requires knowledge of when spines are above a threshold (e.g. spikes riding on top of activity need not be considered)
    temp(temp>0)= 1;
    square(i,:) = temp;
    temp = [];
    temp = square(i,:)+ternarized(i,:); %% Can remove 'ternarized' to get rid of plateau spike summing
    both(i,:) = temp;
    temp2 = (diff(temp)>0.1)>0;
    temp3 = [0, temp2];          %%% Any use of 'diff' shortens the vector by 1
    smeared = smooth(temp3, 5);  %%% Smoothing factor is taken from the reported decay constant of GCaMP6f (~150ms), converted to frames 
    smeared(smeared>0) = 1;
    trueeventcount(i,:) = smeared;
end