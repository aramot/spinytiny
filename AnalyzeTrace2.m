function [DriftBaseline, ProcessedData] = AnalyzeTrace2(Data, Options)

[roi_trace_df, roi_trace_baseline] = AP_baselineEstimationNHedited(Data,Options);

dFoF = roi_trace_df;
DriftBaseline = roi_trace_baseline; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Final variable

smoothwindow = Options.SmoothWindow;

processed_dFoF = smooth(dFoF, smoothwindow, 'loess');


ProcessedData = processed_dFoF;

% ProcessedData = dFoF;
