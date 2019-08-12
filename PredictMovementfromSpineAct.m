function [Mdl, PredictedMovement, PredictionAccuracy] = PredictMovementfromSpineAct(SpineData,MovementData)

datalength = length(SpineData); 
numdatablocks = 10;
windowlength = floor(datalength/numdatablocks);
subdivisions = windowlength*ones(1,numdatablocks);

evenmovementtrace = MovementData(1:sum(subdivisions));
movementtracepieces = mat2cell(evenmovementtrace', 1, subdivisions);

evenactivitytraces = SpineData(:,1:sum(subdivisions));
numspines = size(SpineData,1);
activitytracepieces = mat2cell(evenactivitytraces, numspines, subdivisions);

testset = randi(10,1,1);            %%% Pick a random block of 20% of the data for testing
trainingset = setdiff(1:10,testset);%%% The other 80% being for training

SelectedSpineData = cell2mat(activitytracepieces(trainingset));
SelectedMovementData = cell2mat(movementtracepieces(trainingset));

hyperopts = struct('AcquisitionFunctionName', 'expected-improvement-plus');

%%%% Fitting section: Note, if using binarized data, use classification
%%%% (fitclinear); if using continuous data, use fitrlinear

%%% Automatic hyperparameter tuning

if ~any(SpineData(:)>0 & SpineData(:)<1) && ~any(MovementData(:)>0 & MovementData(:)<1) %%% Works for binarized data: fitclinear is linear classifier
    [Mdl, FitInfo, HyperparameterOptimzationResults] = fitclinear(SelectedSpineData', SelectedMovementData, 'OptimizeHyperParameters', 'auto', 'HyperparameterOptimizationOptions', hyperopts);
    TestActivityData = cell2mat(activitytracepieces(testset));
    TestMovementData = cell2mat(movementtracepieces(testset));
    
    PredictedMovement = predict(Mdl, TestActivityData');
    
    conmat = confusionmat(TestMovementData, PredictedMovement); %%% Confusion matrix, which displays accuracy of classification algorithm
    
    if length(conmat)<2
        TruePosRate = 0;
    else
        TruePosRate = conmat(2,2)/sum(conmat(2,:)); %%% Finds true positive rate (confusion matrix for binary decisions: (1,1)=true neg; (1,2)= false neg; (2,1) = false pos
    end
    
    predictioncorrelation = corrcoef(TestMovementData, PredictedMovement);

    PredictionAccuracy = (predictioncorrelation(1,2)).^2;
    if isnan(PredictionAccuracy)
        PredictionAccuracy = 0;
    end
else
    [Mdl, FitInfo, HyperparameterOptimzationResults] = fitrlinear(SelectedSpineData', SelectedMovementData, 'OptimizeHyperParameters', 'auto', 'HyperparameterOptimizationOptions', hyperopts);
    TestActivityData = cell2mat(activitytracepieces(testset));
    TestMovementData = cell2mat(movementtracepieces(testset));    
    
    PredictedMovement = predict(Mdl, TestActivityData');

    predictioncorrelation = corrcoef(TestMovementData, PredictedMovement);

    PredictionAccuracy = (predictioncorrelation(1,2)).^2;
    if isnan(PredictionAccuracy)
        PredictionAccuracy = 0;
    end
end

%%% Manual Hyperparameter Selection

% Lambda = [0,logspace(-5,1,20)];
% 
% [Mdl, FitInfo] = fitrlinear(SelectedSpineData', SelectedMovementData, 'Learner', 'leastsquares', 'Regularization', 'lasso','Lambda', Lambda, 'HyperparameterOptimizationOptions', hyperopts);
% 
% TestActivityData = cell2mat(activitytracepieces(testset));
% TestMovementData = cell2mat(movementtracepieces(testset));
% 
% PredictedMovement = predict(Mdl, TestActivityData');
% 
% predictioncorrelation = corrcoef(TestMovementData, PredictedMovement);
% 
% PredictionAccuracy = (predictioncorrelation(1,2)).^2;

