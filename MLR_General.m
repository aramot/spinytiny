ResponseVariable = NStoAllSpinesDistances<=5;
Predictors = [AllEarlyMRSwrtNSs, AllLateMRSwrtNSs, persistentMRSs, gainedMRSs, AllPlasticityIndiceswrtNS];

datalength = length(ResponseVariable); 
numdatablocks = 10;
windowlength = floor(datalength/numdatablocks);
subdivisions = windowlength*ones(1,numdatablocks);

even = ResponseVariable(1:sum(subdivisions));
Responsepieces = mat2cell(even', 1, subdivisions);

evenPredictors = Predictors(1:sum(subdivisions),:);
numVars = size(Predictors,2);
Predictorpieces = mat2cell(evenPredictors, subdivisions, numVars);

test_fraction = (2/numdatablocks)*numdatablocks;
testset = randi(10,test_fraction,1);            %%% Pick a random block of 20% of the data for testing
while length(unique(testset))<test_fraction     %%% Ensure that the number of random variables actually corresponds to the desired fraction of data being used as the test set
    testset = randi(10,test_fraction,1);
end
trainingset = setdiff(1:10,testset);%%% The other 80% being for training

SelectedPredictorData = cell2mat(Predictorpieces(trainingset));
    SelectedPredictorData = reshape(SelectedPredictorData, length(SelectedPredictorData), numVars);
SelectedResponseData = cell2mat(Responsepieces(trainingset));
    SelectedResponseData = reshape(SelectedResponseData, length(SelectedResponseData), 1);

hyperopts = struct('AcquisitionFunctionName', 'expected-improvement-plus');

[Mdl, FitInfo, HyperparameterOptimzationResults] = fitclinear(SelectedPredictorData, SelectedResponseData, 'OptimizeHyperParameters', 'auto', 'HyperparameterOptimizationOptions', hyperopts);
TestPredictorData = cell2mat(Predictorpieces(testset));
    TestPredictorData = reshape(TestPredictorData, length(TestPredictorData), numVars);
TestResponseData = cell2mat(Responsepieces(testset));
    TestResponseData = reshape(TestResponseData, length(TestResponseData), 1);

PredictedResponse = predict(Mdl, TestPredictorData);

predictioncorrelation = corrcoef([TestResponseData, PredictedResponse]);

PredictionAccuracy = (predictioncorrelation(1,2)).^2;
if isnan(PredictionAccuracy)
    PredictionAccuracy = 0;
end
