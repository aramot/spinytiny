function SpilloverAnalysis(SummaryData, PolySummary)

numROIs = size(SummaryData.Processed_dFoF,1);
for ROI = 1:numROIs
    ClosestPolyPoint = SummaryData.SpineAddresses{ROI}.Index;
    PolyROISeparation = cell2mat(SummaryData.PolyLineDistances);
    DistancefromCurrent = abs(PolyROISeparation-PolyROISeparation(ClosestPolyPoint));
    FlooredDistance = floor(DistancefromCurrent);
    eventstartpoints = find(diff(SummaryData.OverallSpineActivity(ROI,:))>0);
    eventstoppoints = find(diff(SummaryData.OverallSpineActivity(ROI,:))<0);
    for eventnum = 1:length(eventstartpoints)
        EventAmp{ROI}(1,eventnum) = max(SummaryData.Processed_dFoF(ROI,eventstartpoints(eventnum):eventstoppoints(eventnum)));
        BoutonResponse{ROI}(1,eventnum) = nanmean(SummaryData.Processed_dFoF(ROI,eventstartpoints(eventnum):eventstoppoints(eventnum)));
        meanPolyResponse = nanmedian(PolySummary.Processed_PolyROI{1}(eventstartpoints(eventnum):eventstoppoints(eventnum),:),1);
        DistanceBins = unique(FlooredDistance);
        DistanceResponse{ROI}(eventnum,:) = nan(1,max(DistanceBins)+1);
        for distbins = 1:length(DistanceBins)
            DistanceResponse{ROI}(eventnum,DistanceBins(distbins)+1) = nanmean(meanPolyResponse(find(FlooredDistance==DistanceBins(distbins))));
        end
    end
end

figure; hold on; 

for i = 1:size(PolySummary.Processed_PolyROI{1},2)
    plot(PolySummary.Processed_PolyROI{1}(:,i)+(PolyROISeparation(i)))
end
for i = 1:numROIs
    plot(SummaryData.Processed_dFoF(i,:)+PolyROISeparation(SummaryData.SpineAddresses{i}.Index), 'k', 'linewidth', 2);
end

MedianDistanceResponse = cellfun(@nanmedian, DistanceResponse, 'uni', false);
figure; hold on;

maxlength = max(cellfun(@length, MedianDistanceResponse));
MedArray = nan(numROIs,maxlength);
for i = 1:numROIs
    MedArray(i, find(MedianDistanceResponse{i})) = MedianDistanceResponse{i};
    plot(MedianDistanceResponse{i})
end

plot(nanmedian(MedArray,1), 'k', 'linewidth', 2)

analyzed.DistanceResponse = DistanceResponse;
analyzed.EventAmp = EventAmp;
analyzed.BoutonResponse = BoutonResponse;
analyzed.MedianDistanceResponse = MedArray;

Filename = SummaryData.Filename;
experiment = regexp(Filename, '[A-Z]{2,3}\d+[_]\d+', 'match');
savefile = [experiment{1}, '_SpilloverAnalysis'];

global gui_KomiyamaLabHub
cd(gui_KomiyamaLabHub.DefaultOutputFolder)

eval([savefile, ' = analyzed;'])
save(savefile, savefile)