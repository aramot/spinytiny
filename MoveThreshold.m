function File = MoveThreshold(File)

NumberofSpines = File.NumberofSpines;
ShiftValue = 0.25;   %%% Choose the value by which you want to change the threshold;
ImagingFrequency = 60;

for s = 1:NumberofSpines
    ParentDend =  logical(~cell2mat(cellfun(@(x) isempty(find(x == s,1)), File.SpineDendriteGrouping, 'Uni', false))); 
    OldSpineThreshold = File.SpineThreshold(s);
    NewSpineThreshold = ShiftValue;
    File.ModifiedSpineThreshold = NewSpineThreshold;
    CurrentSpineActivity = File.Processed_dFoF(s,:);
    [square, ~,trueeventcount, ~, ~] = DetectEvents(CurrentSpineActivity, NewSpineThreshold);
    NewActivityTrace = square-File.Dendrite_Binarized(ParentDend,:);
    NewActivityTrace(NewActivityTrace<0) = 0;
    File.SynapseOnlyBinarized(s,:) = NewActivityTrace;
    File.Frequency(s) = (nnz(diff(trueeventcount>0.5)>0)/((length(File.Time)/ImagingFrequency)/60))';
    CurrentDendSubSpineActivity = File.Processed_dFoF_DendriteSubtracted(s,:);
    [square, ~,trueeventcount, ~, ~] = DetectEvents(CurrentDendSubSpineActivity, NewSpineThreshold);
    File.SynapseOnlyBinarized_DendriteSubtracted(s,:) = square;
    File.Frequency_DendriteSubtracted(s) = (nnz(diff(trueeventcount>0.5)>0)/((length(File.Time)/ImagingFrequency)/60))';
end