function [Threshold, DriftBaseline, ProcessedData] = AnalyzeTrace(Data, Options)
    
driftbaselinesmoothwindow = Options.DriftBaselineSmoothWindow;
baselinesmoothwindow = Options.BaselineSmoothWindow;
smoothwindow = Options.SmoothWindow;
valueslimitfornoise = Options.ValuesLimitforNoise;
valueslimitforbaseline = Options.ValuesLimitforBaseline;
traceoption = Options.TraceOption;
BeingAnalyzed = Options.BeingAnalyzed;

%%%%%%%%% Return outputs in the case of eliminated spines/placeholder ROIs
if sum(isnan(Data)) == length(Data)
    Threshold = 0.5;
    DriftBaseline = zeros(1,length(Data));
    ProcessedData = zeros(1,length(Data));
    return
end

%%% Data with NaN cannot be smoothed well, so find and fix any NaNs

if any(isnan(Data))
   firstactualvalue = find(~isnan(Data),1,'first'); %%% If something is wrong with the early frames, they can be excluded; the code to do this makes these values NaN, so replace them with a baseline estimation from later data points
   if firstactualvalue > 10
       Data(1:firstactualvalue-1) = baseline_kde(Data(firstactualvalue:firstactualvalue+firstactualvalue-2)', 20, 30, 20);
   end
   Data(isnan(Data)) = nanmedian(Data);
end

if sum(Data) == 0
    Threshold = 1;
    DriftBaseline = zeros(1,length(Data));
    ProcessedData = Data;
    return
end


switch Options.ImagingSensor
    case 'GluSnFR'
        datamin = min(Data);
        Data = Data+abs(datamin)+1;
end

%%% Values at the ends can mess up smoothing; set the first few to the
%%% median of the first 1000 frames

Data(1:10) = Data(randi([20,100],1,10));
Data(end-9:end) = Data(randi([length(Data)-100,length(Data)-20],1,10));
raw = Data;

%%% Correct for large drift

% raw = raw-smooth(raw,driftbaselinesmoothwindow)'+nanmedian(raw); %%% Correct for slow drift, then restore data to original scale

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fix data near zero

if any(raw<0)
    raw = raw + abs(min(raw))+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pad data for protecting edges while estimating baseline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fornoise = raw;
roundnum = 1;
switch Options.ImagingSensor
    case 'GCaMP'
        roundstodo = 1;
        multiplier = 1.5;
        windowsize = 30;
        stepforKDE = 20;
    case 'GluSnFR'
        roundstodo = 1;
        multiplier = 1.5;
        windowsize = 5;
        stepforKDE = 5;
end
rawmed = nanmedian(raw);
rawspread = nanstd(raw);

while roundnum<=roundstodo 
    switch BeingAnalyzed
        case 'Soma'
            fornoise(fornoise>rawmed+(rawspread)) = rawmed+(rawspread);
                rawspread = nanstd(fornoise);
                rawmed = nanmedian(fornoise);
            roundnum = roundnum+1;
        otherwise
            fornoise(fornoise>rawmed+(multiplier*rawspread)) = rawmed+(multiplier*rawspread);      %%% Cap off large and small values to pinch the data towards the true baseline
            fornoise(fornoise<rawmed-(multiplier*rawspread)) = rawmed-(multiplier*rawspread);      %%%
                rawspread = nanstd(fornoise);
                rawmed = nanmedian(fornoise);
            roundnum = roundnum+1;
    end
end

padlength = 2000;
switch BeingAnalyzed
    case 'Soma'
        activitylevel = 'High';
        switch activitylevel
            case 'High'
                ascendingvalues = sort(fornoise);
                putative_resting_state = ascendingvalues(1:300);
                pad_start = randi([1,length(putative_resting_state)],1,padlength);
                pad_end = randi([1,length(putative_resting_state)],1,padlength);
                padded_data = [putative_resting_state(pad_start),raw, putative_resting_state(pad_end)];
            case 'Low'
                pad_start = randi([1,length(fornoise)],1,padlength);
                pad_end = randi([1,length(fornoise)],1,padlength);
                padded_data = [fornoise(pad_start), raw, fornoise(pad_end)];
        end
    otherwise
        pad_start = randi([1,length(fornoise)],1,padlength);
        pad_end = randi([1,length(fornoise)],1,padlength);
        padded_data = [fornoise(pad_start), fornoise, fornoise(pad_end)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Baseline %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Kernel Density Estimation (Aki's method) %%%
switch BeingAnalyzed
    case 'Soma'
    switch activitylevel
        case 'High'
            [~,lo] = envelope(padded_data, 300, 'peak');
            truebaseline = lo;
            truebaseline = truebaseline(padlength+1:end-padlength)';
            DriftBaseline = truebaseline;
        case 'Low'
            truebaseline = baseline_kde(padded_data',20,windowsize,20);    %%% inputs = downsample ratio, window size, step
            truebaseline = truebaseline(padlength+1:end-padlength);
            DriftBaseline = truebaseline;
    end
    otherwise
        truebaseline = baseline_kde(padded_data',20,windowsize,stepforKDE);    %%% inputs = downsample ratio, window size, step
        truebaseline = truebaseline(padlength+1:end-padlength);
        DriftBaseline = truebaseline;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Baseline Subtraction

% if any(truebaseline<=0)
%     constant = abs(min(truebaseline))+abs(nanmedian(raw));
%     raw = raw+constant;
%     truebaseline = truebaseline+constant;
%     if any(raw<=0)
%         shiftfactor = abs(min(raw))+1;
%         raw = raw+shiftfactor;
%         truebaseline = truebaseline+shiftfactor;
%     end
% end

%     blsub = driftsub-truebaseline;                                                             %%% Baseline-subtracted value
blsub = raw-truebaseline';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline division (if using raw traces)

if traceoption == 1 
    if nanmedian(truebaseline)~= 0
        dFoF = blsub./truebaseline';
%             blsub(blsub<0) = 0;
        rawmed = nanmedian(dFoF);
        rawspread = nanstd(dFoF);
    else
        blsub = blsub+1;
        truebaseline = truebaseline+1;
        dFoF = blsub./truebaseline';
%             blsub(blsub<0) = 0;
        rawmed = nanmedian(dFoF);
        rawspread = nanstd(dFoF);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Final variable

    filterorder = 3;        %%% Polynomial order with which to filter the final signal. This will depend on the imaging frequency as well as the noise of the signal. 
    filterwindow = smoothwindow;
    
    if ~mod(filterwindow,2)
        filterwindow = filterwindow+1;
    else
    end
    
    switch Options.ImagingSensor
        case 'GCaMP'
            processed_dFoF = sgolayfilt(dFoF,filterorder,filterwindow);
        case 'GluSnFR'
            processed_dFoF = smooth(dFoF, filterwindow);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fornoise = processed_dFoF;
    rawmed = nanmedian(processed_dFoF);
    rawspread = nanstd(processed_dFoF);


    roundnum = 1;
%     roundstodo = 2;
    while roundnum<=roundstodo 
        fornoise(fornoise>rawmed+(valueslimitfornoise*rawspread)) = rawmed+(valueslimitfornoise*rawspread);      %%% Cap off large and small values to pinch the data towards the true baseline
        fornoise(fornoise<rawmed-(valueslimitfornoise*rawspread)) = rawmed-(valueslimitfornoise*rawspread);      %%%
            rawspread = nanstd(fornoise);
            rawmed = nanmedian(fornoise);
        roundnum = roundnum+1;
    end
end

%     spread = rawmed+spinevalueslimitfornoise*nanstd(fornoise);
spread = 3*std(fornoise);

med = nanmedian(fornoise);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Noise Estimation %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Adjust spine threshold multiplier based on processed data for each
%%% spine

%%% Estimate signal by finding peaks
pks = findpeaks(processed_dFoF, 'MinPeakHeight', spread, 'MinPeakDistance', 200,'sortstr', 'descend');

%     [f, xi] = ksdensity(blsub);
%     lowerlimit = prctile(xi,75);

switch Options.ImagingSensor
    case 'GCaMP'
        spinethresh = 0.25;
        dendthresh = 0.25;
        somathresh = 0.25;
    case 'GluSnFR'
        spinethresh = 0.25;
        dendthresh = 0.25;
        somathresh = 0.25;
end

if isempty(pks)
    thresh = 1;
else
    switch BeingAnalyzed
        case 'Spine'
            if spread < spinethresh
                thresh = spinethresh;
            else
                thresh = spread;
            end
        case 'Poly'
            if spread < dendthresh
                thresh = dendthresh;
            else
                thresh = spread;
            end
        case 'Dendrite'
            if spread < dendthresh
                thresh = dendthresh;
            else
                thresh = spread;
            end
        case 'Soma'
            if spread < somathresh
                thresh = somathresh;
            else
                thresh = spread;
            end
    end

    signal = nanmean(pks);
    noise = spread;
    StN = signal/noise;
%         maxaddition = 1;
end

Threshold = thresh;
ProcessedData = processed_dFoF;