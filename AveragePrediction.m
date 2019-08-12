function AveragePrediction(varargin)

animalnames = varargin;
lookforfiles = cellfun(@(x) strcat(x, '_PredictionModel'), animalnames, 'uni', false);

pathchoice = 'C:\Users\Komiyama\Desktop\Output Data';
cd(pathchoice)

sensorused = inputdlg('Enter Sensor', '', 1,{'GCaMP'});
sensorused = sensorused{1};

for i = 1:length(lookforfiles)
    files(i) = fastdir(pathchoice,lookforfiles{i});
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

considersessions = ones(1,14);
considersessions([4,5,9,10,14]) = 0;
considersessions = logical(considersessions);
sessions = 1:14; %sessions = sessions(:,considersessions);

allarray(:,~considersessions) = nan;

plot(sessions, allarray'); flex_plot(sessions, allarray, 'parametric', 'k', 2);
ylabel('Prediction Accuray (R^2)')
xlabel('Session')
xlim([0 15])


%%%%% Update the file ('LongitudinalSpineTypeSummary') as more data is
%%%%% added; this file is automatically generated from the
%%%%% TrialActivityAnalysis code, and can be saved after running said code
%%%%% with the same animals used here

load([sensorused, '_TrialFeatures'])
ClusteredSpinesBeta = cell(1,14);
NonClusteredSpineBeta = cell(1,14);
MovementSpinesBeta = cell(1,14);
NonMovementSpineBeta = cell(1,14);
NewSpinesBeta = cell(1,14);
for filenum = 1:length(files)
    eval(['currentfile = ', files{filenum}(1:end-4)])
    for session = find(~cellfun(@isempty, currentfile))
%         ClusteredSpinesBeta{session} = [ClusteredSpinesBeta{session}; currentfile{session}.Model.Beta(TrialFeatures.ClusteredSpinesbyAnimal{session}{filenum})];
%         NonClusteredSpineBeta{session} = [NonClusteredSpineBeta{session}; currentfile{session}.Model.Beta(find(~ismember([1:size(currentfile{session}.Model.Beta,1)], TrialFeatures.ClusteredSpinesbyAnimal{session}{filenum}))')];
        MovementSpinesBeta{session} = [MovementSpinesBeta{session}; currentfile{session}.Model.Beta(TrialFeatures.StatSpinesbyAnimal{session}{filenum})];
        NonMovementSpineBeta{session} = [NonMovementSpineBeta{session}; currentfile{session}.Model.Beta(find(~ismember([1:size(currentfile{session}.Model.Beta,1)], TrialFeatures.StatSpinesbyAnimal{session}{filenum}))')];
    end
end
% 
figure; 
% subplot(1,2,1);
% a = flex_plot(sessions, ClusteredSpinesBeta(:,considersessions),'parametric', 'k', 2);
% b = flex_plot(sessions, NonClusteredSpineBeta(:,considersessions), 'parametric', 'r', 2);
% legend([a,b], 'Clustered Spines', 'Nonclustered Spines')
% xlabel('Session')
% ylabel('Mean Coefficients')
% title('Betas for Clustered Spines')

MovementSpinesBeta(~considersessions) = {nan};
NonMovementSpineBeta(~considersessions) = {nan};
subplot(1,2,2);
a = flex_plot(sessions, MovementSpinesBeta,'parametric', 'k', 2);
b = flex_plot(sessions, NonMovementSpineBeta, 'parametric', 'r', 2);
legend([a,b], 'Movement Spines', 'Nonclustered Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Betas for Movement Spines')



