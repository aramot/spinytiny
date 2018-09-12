function [Mdl, PredictedMovement, PredictionAccuracy] = PredictMovementfromSpineAct(SpineData,MovementData)

datalength = length(SpineData); 
numdatablocks = 10;
windowlength = floor(datalength/numdatablocks);
subdivisions = [windowlength*ones(1,numdatablocks)];

evenmovementtrace = MovementData(1:sum(subdivisions));
movementtracepieces = mat2cell(evenmovementtrace', 1, subdivisions);

evenactivitytraces = SpineData(:,1:sum(subdivisions));
numspines = size(SpineData,1);
activitytracepieces = mat2cell(evenactivitytraces, numspines, subdivisions);

testset = randi(10,1,1);
trainingset = setdiff(1:10,testset);

SelectedSpineData = cell2mat(activitytracepieces(trainingset));
SelectedMovementData = cell2mat(movementtracepieces(trainingset));

hyperopts = struct('AcquisitionFunctionName', 'expected-improvement-plus');
[Mdl, FitInfo, HyperparameterOptimzationResults] = fitrlinear(SelectedSpineData', SelectedMovementData, 'OptimizeHyperParameters', 'auto', 'HyperparameterOptimizationOptions', hyperopts);

TestActivityData = cell2mat(activitytracepieces(testset));
TestMovementData = cell2mat(movementtracepieces(testset));

PredictedMovement = predict(Mdl, TestActivityData');

predictioncorrelation = corrcoef(TestMovementData, PredictedMovement);

PredictionAccuracy = (predictioncorrelation(1,2)).^2;

