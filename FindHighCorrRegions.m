function highcorrwindows = FindHighCorrRegions(x,y,ImagingFrequency,window_in_sec,corr_thresh)

%%% Find moving correlation value over set window
[rmov] = movcorr(x', y', round(ImagingFrequency*window_in_sec));
rmov(rmov>corr_thresh) = 1; rmov(rmov<corr_thresh) = 0;
rmov(x<=0 | y<=0) = 0;

%%% Join binarized regions of high correlation that
%%% are close together
gap_allowance = round(ImagingFrequency*0.25); 
rmov_switch = diff([0;rmov;0]);
rmov_starts = find(rmov_switch == 1);
rmov_stops = find(rmov_switch == -1)-1;
rmov_movement_times = rmov_stops - ...
    rmov_starts;
rmov_intermovement_times = rmov_starts(2:end) - ...
    rmov_stops(1:end-1);
rmov_fill = rmov_intermovement_times < gap_allowance;
for i = find(rmov_fill)'
    rmov(rmov_stops(i): ...
        rmov_starts(i+1)) = 1;
end

highcorrwindows = rmov;

% hc_window_bounds = find(diff([Inf; rmov; Inf]));
% hc_windows_sep = mat2cell(rmov, diff(hc_window_bounds));
% x_sep = mat2cell(x', diff(hc_window_bounds));
% y_sep = mat2cell(y', diff(hc_window_bounds));
% 
% hc_windows_sep(cellfun(@(x,y) any(x<0) | any(y<0), x_sep,y_sep)) = 0;
% 
% hichcorrwindows = vertcat(hc_windows_sep);


