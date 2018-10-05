function AveragePrediction(varargin)

animalnames = varargin;
lookforfiles = cellfun(@(x) strcat(x, '_PredictionModel'), animalnames, 'uni', false);

for i = 1:length(lookforfiles)
    files(i) = fastdir('C:\Users\Komiyama\Desktop\Output Data',lookforfiles{i});
end

for i = 1:length(files)
    load(files{i});
end

figure; hold on;

allarray = nan(length(files), 14);

for i = 1:length(files)
    eval(['usedsessions = find(~cell2mat(cellfun(@isempty,' files{i}(1:end-4), ',''uni'', false)));'])
    sessionstr = cell2mat(cellfun(@(x) strcat(x, ','), strsplit(num2str(usedsessions)), 'uni', false));
    eval(['allarray(i,[',sessionstr(1:end-1),']) = cell2mat(cellfun(@(x) x(:).PredictionAccuracy,',files{i}(1:end-4), '(~cell2mat(cellfun(@isempty,',files{i}(1:end-4),', ''uni'', false))), ''uni'', false));'])
end

plot(allarray'); flex_plot(1:14, allarray, 'parametric', 'k', 2);
ylabel('Prediction Accuray (R^2)')
xlabel('Session')


