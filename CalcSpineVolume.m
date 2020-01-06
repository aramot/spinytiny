function CalcSpineVolume

global gui_CaImageViewer

SpineROIs = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}));

imagetype = gui_CaImageViewer.BeingDisplayed;

switch imagetype
    case 'TimeSeries'
        AveBox = get(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value');

        if ~AveBox
            set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 1)
            DisplayProjection('Ave')
        end

        if length(size(gui_CaImageViewer.ch1image))>2
            imtouse = gui_CaImageViewer.ch1image(:,:,2);
        else
            imtouse = gui_CaImageViewer.ch1image;
        end
    case 'SessionComparison'
        imtouse = gui_CaImageViewer.ch1image;
end

BackgroundROI = SpineROIs(1); %%% Assumes that the first ROI (actually labeled 'ROI 0') is the background
BackgroundMask = createMask(BackgroundROI, imtouse);
Backgroundreg = find(BackgroundMask);   %%% Number of points within the mask can be considered the number of pixels, and therefore the area of the ROI
Background_Intensity = imtouse(Backgroundreg);
Background99thPrctile = prctile(Background_Intensity,99);
MeanBackgroundIntensity = nanmean(imtouse(Backgroundreg)); 

final.MeanBackgroundIntensity = MeanBackgroundIntensity;

for sp = 2:length(SpineROIs)
    currentROI = SpineROIs(sp);
    ROImask = createMask(currentROI, imtouse);
    ROIreg = find(ROImask);
    ROI_intensity = imtouse(ROIreg);   
%     ROIIntensity(sp-1) = (nanmean(ROI_intensity)).*sum((ROI_intensity-Background_Intensity)>Background_Intensity);
    IntInt(sp-1) = sum(ROI_intensity(ROI_intensity>Background99thPrctile)-Background99thPrctile);  %%% If you have each indivdual pixel value, the integrand is just the sum of the intensity values of each pixel
    MeanInt(sp-1) = nanmean(ROI_intensity);
    %%% save image of spine
    [r,c] = find(ROImask);
    spineimage{sp-1} = imtouse(min(r):max(r), min(c):max(c));
end

final.SpineImages = spineimage;
final.IntegratedIntensity = IntInt;
final.MeanROIIntensity = MeanInt;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Dendrite Normalization Section %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PolyROIs = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', {'-regexp', 'Tag', 'Dendrite'}));

for p = 1:length(PolyROIs)
    PolyX_center(p,1) = PolyROIs(p).Center(1);     
    PolyY_center(p,1) = PolyROIs(p).Center(2);
    currentROI = PolyROIs(p);
    ROImask = createMask(currentROI, imtouse);
    ROIreg = find(ROImask);
    ROI_intensity = imtouse(ROIreg)-MeanBackgroundIntensity;    %%% You only want to consider the brightness of the dendrite, not 'volume', so integrated intensity should not be considered (plus, it's much more sensitive to ROI size)
    PolyROIIntensity(p) = nanmean(ROI_intensity);
end

final.PolyROIIntensity = PolyROIIntensity;

numberofnearbyPolyROIstoconsider = 5;
for sp = 2:length(SpineROIs)
    spine_pos = SpineROIs(sp).Center;        
    [~, index] = sort(sqrt(((PolyX_center-spine_pos(1)).^2)+(PolyY_center-spine_pos(2)).^2));
    localdend = nanmean(PolyROIIntensity(index(1:numberofnearbyPolyROIstoconsider)));
    DendriteNormalizedIntegratedSpineIntensity(sp-1) = IntInt(sp-1)/localdend;
    DendriteNormalizedMeanSpineIntensity(sp-1) = MeanInt(sp-1)/localdend;
end

final.DendriteNormalizedIntegratedSpineIntensity = DendriteNormalizedIntegratedSpineIntensity;
final.DendriteNormalizedMeanSpineIntensity = DendriteNormalizedMeanSpineIntensity;

filename = gui_CaImageViewer.filename;

currentdate = gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate;

animal = regexp(filename, '[A-Z]{2,3}0[0-9]{2,3}', 'match'); animal = animal{1};

filepattern = [animal, '_', currentdate];

savefilepattern = [filepattern, '_SpineIntensitySummary'];

eval([savefilepattern, ' = final;'])

repositing_folder = ['C:\Users\Komiyama\Desktop\Output Data\', animal, ' Spine Volume Data'];

if isfolder(repositing_folder)
    cd(repositing_folder)
else
    mkdir(repositing_folder)
    cd(repositing_folder)
end

save(savefilepattern, savefilepattern)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% ROI Saving Section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

drawer = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');

a.SpineROIs = gui_CaImageViewer.ROI;
a.SpineROItext = gui_CaImageViewer.ROItext;
a.PolyROI = gui_CaImageViewer.PolyROI;
a.BackgroundROIs = gui_CaImageViewer.BackgroundROI;

try
    a.PolyLines = gui_CaImageViewer.PolyLine;
catch
    a.PolyLines = [];
end

for sp = 1:length(SpineROIs)
    a.ROIPosition{sp} = get(SpineROIs(sp));
end
a.PolyLinePosition = gui_CaImageViewer.PolyLinePos;
a.PolyROIPos = gui_CaImageViewer.PolyLinePos;
a.PolyLineVertices = gui_CaImageViewer.PolyLineVertices;
a.NumberofSpines = gui_CaImageViewer.Spine_Number;
a.OtherROIs = gui_CaImageViewer.ROIother;
a.OtherROINumber = length(gui_CaImageViewer.ROIother);
a.NumberofDendrites = gui_CaImageViewer.Dendrite_Number;
a.DendritePolyPointNumber = gui_CaImageViewer.DendritePolyPointNumber;

fname = [filepattern, '_SpineVolumeROIs', '_DrawnBy', drawer];
eval([fname,'= a'])

target_dir = gui_CaImageViewer.save_directory;
cd(target_dir);

save(fname, fname)
