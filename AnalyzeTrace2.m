function [Threshold, DriftBaseline, ProcessedData] = AnalyzeTrace2(Data, Options)


driftbaselinesmoothwindow = Options.DriftBaselineSmoothWindow;
baselinesmoothwindow = Options.BaselineSmoothWindow;
smoothwindow = Options.SmoothWindow;
valueslimitfornoise = Options.ValuesLimitforNoise;
valueslimitforbaseline = Options.ValuesLimitforBaseline;
traceoption = Options.TraceOption;
BeingAnalyzed = Options.BeingAnalyzed;

[roi_trace_df, roi_trace_baseline] = AP_baselineEstimationNHedited(Data,Options.ImagingFrequency);

dFoF = roi_trace_df;
DriftBaseline = roi_trace_baseline; 


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Final variable

    filterorder = 3;        %%% Polynomial order with which to filter the final signal. This will depend on the imaging frequency as well as the noise of the signal. 
    filterwindow = 30;
    
    processed_dFoF = smooth(dFoF, filterwindow);


Threshold = 3;
ProcessedData = processed_dFoF;
