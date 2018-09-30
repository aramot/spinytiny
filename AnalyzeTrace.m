function [Threshold, DriftBaseline, ProcessedData] = AnalyzeTrace(Data, Options)
    
    driftbaselinesmoothwindow = Options.DriftBaselineSmoothWindow;
    baselinesmoothwindow = Options.BaselineSmoothWindow;
    smoothwindow = Options.SmoothWindow;
    valueslimitfornoise = Options.ValuesLimitforNoise;
    valueslimitforbaseline = Options.ValuesLimitforBaseline;
    traceoption = Options.TraceOption;
    BeingAnalyzed = Options.BeingAnalyzed;
    
   %%% Data with NaN cannot be smoothed well, so find and fix any NaNs
    if any(isnan(Data))
        Data(isnan(Data)) = 0;
    end
    
    if sum(Data) == 0
        Threshold = 1;
        DriftBaseline = zeros(1,length(Data));
        ProcessedData = Data;
        return
    end
    
    Data(Data<0) = 0;
    
    %%% Values at the ends can mess up smoothing; set the first few to the
    %%% median of the first 1000 frames
    
    Data(1:10) = Data(randi([20,100],1,10));
    Data(end-9:end) = Data(randi([length(Data)-100,length(Data)-20],1,10));
    raw = Data;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Pad data for protecting edges while estimating baseline
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fornoise = raw;
    roundnum = 1;
    roundstodo = 10;
    rawmed = nanmedian(raw);
    rawspread = nanstd(raw);
    while roundnum<=roundstodo 
        fornoise(fornoise>rawmed+(rawspread)) = rawmed+(rawspread);      %%% Cap off large and small values to pinch the data towards the true baseline
        fornoise(fornoise<rawmed-(rawspread)) = rawmed-(rawspread);      %%%
            rawspread = nanstd(fornoise);
            rawmed = nanmedian(fornoise);
        roundnum = roundnum+1;
    end
    
    padlength = 2000;
    pad_start = randi([1,length(fornoise)],1,padlength);
    pad_end = randi([1,length(fornoise)],1,padlength);
    padded_data = [fornoise(pad_start), raw, fornoise(pad_end)];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%% Baseline %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%% Kernel Density Estimation (Aki's method) %%%
    switch BeingAnalyzed
        case 'Spine'
            windowsize = 30;
        case 'Poly'
            windowsize = 30;
        case 'Dendrite'
            windowsize = 30;
    end
    truebaseline = baseline_kde(padded_data',20,windowsize,20);    %%% inputs = downsample ratio, window size, step
    truebaseline = truebaseline(padlength+1:end-padlength);
    DriftBaseline = truebaseline;
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Baseline Subtraction
    
    if any(truebaseline<=0)
        constant = abs(min(truebaseline))+max(abs(truebaseline));
        raw = raw+constant;
        truebaseline = truebaseline+constant;
    end
    
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
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Final variable
            
            filterorder = 11;        %%% Polynomial order with which to filter the final signal. This will depend on the imaging frequency as well as the noise of the signal. 
            
            if ~mod(smoothwindow,2)
                smoothwindow = smoothwindow+1;
            else
            end
    
            processed_dFoF = sgolayfilt(dFoF,filterorder,smoothwindow);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        fornoise = processed_dFoF;
        rawmed = nanmedian(processed_dFoF);
        rawspread = nanstd(processed_dFoF);
        
            
        roundnum = 1;
        roundstodo = 50;
        while roundnum<=roundstodo 
            fornoise(fornoise>rawmed+(valueslimitfornoise*rawspread)) = rawmed+(valueslimitfornoise*rawspread);      %%% Cap off large and small values to pinch the data towards the true baseline
            fornoise(fornoise<rawmed-(valueslimitfornoise*rawspread)) = rawmed-(valueslimitfornoise*rawspread);      %%%
                rawspread = nanstd(fornoise);
                rawmed = nanmedian(fornoise);
            roundnum = roundnum+1;
        end
    end
             
%     spread = rawmed+spinevalueslimitfornoise*nanstd(fornoise);
    spread = nanmax(fornoise);
    
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
    
    if isempty(pks)
        thresh = 1;
    else
        switch BeingAnalyzed
            case 'Spine';
                spinethresh = 0.5;
                if spread < spinethresh
                    thresh = spinethresh;
                else
                    thresh = spread;
                end
            case 'Poly';
                dendthresh = 0.5;
                if spread < dendthresh
                    thresh = dendthresh;
                else
                    thresh = spread;
                end
            case 'Dendrite'
                dendthresh = 0.5;
                if spread < dendthresh
                    thresh = dendthresh;
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