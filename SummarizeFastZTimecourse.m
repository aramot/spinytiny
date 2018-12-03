function SummarizeFastZTimecourse(data)


Options.DriftBaselineSmoothWindow = 1800;
Options.BaselineSmoothWindow = 450;
Options.SmoothWindow = 10;
Options.TraceOption = 1;
Options.ValuesLimitforBaseline = 2;
Options.ValuesLimitforNoise = 1;
Options.ImagingSensor = 'GCaMP'; 

numberofROIs = length(data.Fluorescence_Measurement);

maxlength = max(cellfun(@length, data.Fluorescence_Measurement));
differentlengths = cell2mat(cellfun(@(x) length(x)<maxlength, data.Fluorescence_Measurement,'uni', false));
if any(differentlengths)
    numdiffs = find(differentlengths);
    lengthdiffs = cellfun(@(x) abs(maxlength-length(x)), data.Fluorescence_Measurement(differentlengths), 'uni', false);
    for j = 1:length(numdiffs)
        data.Fluorescence_Measurement{numdiffs(j)} = [data.Fluorescence_Measurement{numdiffs(j)}, nanmedian(data.Fluorescence_Measurement{numdiffs(j)})*ones(1,lengthdiffs{j})];
    end
end
for i = 1:length(data.Fluorescence_Measurement)
    Options.BeingAnalyzed = data.ROILabels{i};
    [thresh(i,1), driftbaseline(i,:), processed_dFoF(i,:)] = AnalyzeTrace(data.Fluorescence_Measurement{i}, Options);
end

%%% Variable initiation
floored = zeros(numberofROIs, length(processed_dFoF));

for i = 1:numberofROIs
    temp = processed_dFoF(i,:); %%% This value will be used as a "floored" term, which has zeros below the threshold. It will subsequenctly be used as a binarized term by setting all threshold values to 1.
    temp(temp<thresh(i,1)) = 0;
    floored(i,:) = temp;
    temp(temp<thresh(i,1)) = nan;
    tamp = temp;
    tamp(isnan(tamp)) = 0;
    tamp = smooth(tamp,30);
    dtamp = diff(tamp);     %%% first derivative of the binarized data
    dtamp = [0;dtamp];
    dtamp(dtamp>0) = 1; dtamp(dtamp<0) = -1;
    d2tamp = diff(dtamp);
    d2tamp = [0;d2tamp];    %%% Second derivative of the binarized data (concavity)
    d2tamp(d2tamp>0) = 1; d2tamp(d2tamp<0) = -1;
    temp(d2tamp>0) = nan; %% For plateau spikes, when the 2nd derivative is positive (concave up, corresponding to dips), punch a 'hole' in the data, so that multiple peaks will be counted
    ternarized(i,:) = temp;
    square = floored; 
    square(square~=0) = 1;
    temp = square(i,:)+ternarized(i,:); %% Can remove 'ternarized' to get rid of plateau spike summing
    both(i,:) = temp;
    temp2 = (diff(temp)>0.1)>0;
    temp3 = [0, temp2];          %%% Any use of 'diff' shortens the vector by 1
    smeared = smooth(temp3, 5);  %%% Smoothing factor is taken from the reported decay constant of GCaMP6f (~150ms), converted to frames 
    smeared(smeared>0) = 1;
    trueeventcount(i,:) = smeared;
end

figure; f1 = axes; plot(cell2mat(data.Fluorescence_Measurement)')
figure; f2 = axes; hold on;  %plot(processed_dFoF(:,:)');
for i = 1:numberofROIs
    plot((i+(i*0.25))+processed_dFoF(i,:)); 
end
figure; f3 = axes; hold on;
for i=1:numberofROIs
    plot((i+(i*0.25))+square(i,:)); 
end

linkaxes([f1,f2,f3],'x')

somataROIs = cell2mat(cellfun(@(x) strcmpi(x,'Soma'), data.ROILabels, 'uni', false));

if length(find(somataROIs))>1
    allsomata = find(somataROIs);
    for i= 1:length(allsomata)
        currentpairing = inputdlg({['Which dendrites are on cell ', num2str(i),'?:']}, 'Cell Pairing', 1, {'Dend Nums'});
        currentpairing = regexp(currentpairing, '[0-9]+_*', 'match'); currentpairing = cell2mat(cellfun(@str2num, currentpairing{1}, 'uni', false));
        CellPairing{i} = currentpairing;
    end
else
    CellPairing{1} = find(~somataROIs);
end

a.Processed_dFoF = processed_dFoF;
a.Binarized_Data = trueeventcount;
a.CellDendritePairing = CellPairing;

animal = regexp(data.Filename, '[A-Z]{2,3}0*[0-9]*', 'match'); animal = animal{1};
field = regexp(data.Filename, '[_][A-Z]{1}[0-9]{1}[_]', 'match'); 
if isempty(field)
    field = regexp(data.Filename, '[A-Z]{1}[0-9]{1}', 'match');
end
field = field{1}(2:end-1);

save_fname = [animal, '_', field, '_ZSeriesSummary'];

eval([save_fname, ' = a']);
sourcefolder = cd;
alldatafolder = 'E:\ActivitySummary';

save(save_fname, save_fname);
cd(alldatafolder)
save(save_fname, save_fname);
cd(sourcefolder)

