function [DriftBaseline, ProcessedData] = AnalyzeTrace(Data, Options)
    
filterwindow = Options.SmoothWindow;
traceoption = Options.TraceOption;

%%%%%%%%% Return outputs in the case of eliminated spines/placeholder ROIs
if sum(isnan(Data)) == length(Data)
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
    DriftBaseline = zeros(1,length(Data));
    ProcessedData = Data;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fix data near zero

raw = Data;
if any(raw<1)
    raw = raw + abs(min(raw));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pad data for protecting edges while estimating baseline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fornoise = raw;
roundnum = 1;
if strcmpi(Options.ImagingSensor, 'GCaMP')
        downsample_ratio = 20;
        windowsize = 30;
        stepforKDE = 20;
elseif strcmpi(Options.ImagingSensor, 'GluSNFR')
        downsample_ratio = 20;
        windowsize = 60;
        stepforKDE = 20;
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Stop when analyzing:
%%% (for debugging purposes)

switch Options.BeingAnalyzed
    case 'Spine'
        k = 1;
    case 'Poly'
        k = 1;
    case 'Dendrite'
        k = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% First, construct a bounded
%%% curve (roughly estimating baseline
%%% around which a simulated baseline
%%% can be used to pad the data, which
%%% reduces edge effects of estimation

est_base = baseline_kde(raw', downsample_ratio, round(Options.ImagingFrequency*30), stepforKDE)';

if strcmpi(Options.ImagingSensor, 'GluSNFR')
    if ~isempty(Options.ImageFramesatBoutSeparations)
        SecondsPostStarttoIgnore = 2;
        AcqStartPoints = [1;Options.ImageFramesatBoutSeparations];
        IgnoreWindows = AcqStartPoints + ceil(SecondsPostStarttoIgnore*Options.ImagingFrequency);
        for bout = 1:size(AcqStartPoints,1)
            if AcqStartPoints(bout)>length(raw)
                continue
            end
            if IgnoreWindows(bout)>length(raw)
                IgnoreWindows(bout) = length(raw);
            end
            raw(AcqStartPoints(bout):IgnoreWindows(bout)) = est_base(AcqStartPoints(bout):IgnoreWindows(bout))+(std(raw)/3)*randn(1,length(AcqStartPoints(bout):IgnoreWindows(bout)));
        end
    end
end

pad_length = 1000;
paddeddata = [est_base(randi([1 1000], 1,pad_length)), raw, est_base(randi([length(est_base)-pad_length, length(est_base)], 1,pad_length))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Baseline %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Kernel Density Estimation (Aki's method) %%%
truebaseline_kde = baseline_kde(paddeddata',downsample_ratio,windowsize,stepforKDE);    %%% inputs = data,downsample ratio, window size, step
truebaseline_kde = truebaseline_kde(pad_length+1:end-pad_length);
DriftBaseline = truebaseline_kde; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline Subtraction                                                        %%% Baseline-subtracted value
blsub = raw-DriftBaseline';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Baseline division (if using raw traces)
if traceoption == 1 
    if nanmedian(DriftBaseline)~= 0
        dFoF = blsub./DriftBaseline';
%             blsub(blsub<0) = 0;
        rawmed = nanmedian(dFoF);
        rawspread = nanstd(dFoF);
    else
        blsub = blsub+1;
        DriftBaseline = DriftBaseline+1;
        dFoF = blsub./DriftBaseline';
%             blsub(blsub<0) = 0;
        rawmed = nanmedian(dFoF);
        rawspread = nanstd(dFoF);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Final variable
    pad_length = 500;
    
    newbaseline = baseline_kde(dFoF',downsample_ratio,windowsize,stepforKDE);    %%% inputs = data,downsample ratio, window size, step
    paddeddata = [newbaseline(randi([1 1000], 1,pad_length))', dFoF, newbaseline(randi([length(dFoF)-500, length(dFoF)], 1,pad_length))'];
    
%     smooth_padded = smooth(paddeddata, filterwindow, 'loess');
    smooth_padded = smooth(paddeddata, filterwindow);
    processed_dFoF = smooth_padded(pad_length+1:end-pad_length);
%     processed_dFoF = dFoF;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

ProcessedData = processed_dFoF;