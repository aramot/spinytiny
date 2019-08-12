function [framenumatboutdividers] = FindNewAcquisitionStart(imfilesfolder)
cd(imfilesfolder)
filestoscan = fastdir(imfilesfolder, '_summary.mat');
while isempty(filestoscan)
    imfilesfolder = uigetdir();
    filestoscan = fastdir(imfilesfolder, '_summary.mat');
end
imfilestoscan = fastdir(imfilesfolder, '_corrected.tif');
acquisition_bout_divisions = find(diff(str2num(cell2mat(cellfun(@(x) x(2:end-1),cellfun(@(x) regexp(x, '_[0]{3,4}[0-9]{1,2}_', 'match'), filestoscan), 'uni', false))))); %%% Finds the last file in a current imaging acquisition bout (should be 5 min each)
if ~isempty(acquisition_bout_divisions)
    lastaqlength = cellfun(@length, cellfun(@(x) imfinfo(x), [imfilestoscan(acquisition_bout_divisions); imfilestoscan(end)], 'uni', false));
    acquisition_bout_divisions = [acquisition_bout_divisions; length(filestoscan)];
    framenumatboutdividers = ((acquisition_bout_divisions-1)*800)+lastaqlength;
else
    framenumatboutdividers = [];
end
