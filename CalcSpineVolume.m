function CalcSpineVolume

global gui_CaImageViewer

SpineROIs = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}));

AveBox = get(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value');

if ~AveBox
    set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 1)
    DisplayProjection('Ave')
end

BackgroundROI = SpineROIs(1); %%% Assumes that the first ROI (actually labeled 'ROI 0') is the background
BackgroundMask = createMask(BackgroundROI, gui_CaImageViewer.ch1image);
Backgroundreg = find(BackgroundMask);   %%% Number of points within the mask can be considered the number of pixels, and therefore the area of the ROI
Background_Intensity = nanmean(gui_CaImageViewer.ch1image(Backgroundreg)); 

for sp = 2:length(SpineROIs)
    currentROI = SpineROIs(sp);
    ROImask = createMask(currentROI, gui_CaImageViewer.ch1image);
    ROIreg = find(ROImask);
    ROIIntensity(sp-1) = (nanmean(gui_CaImageViewer.ch1image(ROIreg))-Background_Intensity).*length(ROIreg);
end

final.RawROIIntensity = ROIIntensity;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Dendrite Normalization Section %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PolyROIs = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', {'-regexp', 'Tag', 'Dendrite'}));

for p = 1:length(PolyROIs)
    PolyX_center(p,1) = PolyROIs(p).Center(1);     
    PolyY_center(p,1) = PolyROIs(p).Center(2);
    currentROI = PolyROIs(p);
    ROImask = createMask(currentROI, gui_CaImageViewer.ch1image);
    ROIreg = find(ROImask);
    PolyROIIntensity(p) = (nanmean(gui_CaImageViewer.ch1image(ROIreg))-Background_Intensity).*length(ROIreg);
end

for sp = 2:length(SpineROIs)
    spine_pos = SpineROIs(sp).Center;        
    [~, index] = sort(sqrt(((PolyX_center-spine_pos(1)).^2)+(PolyY_center-spine_pos(2)).^2));
    localdend = nanmean(PolyROIIntensity(index(1:4)));
    DendriteNormalizedSpineIntensity(sp-1) = ROIIntensity(sp-1)/localdend;
end

final.DendriteNormalizedSpineIntensity = DendriteNormalizedSpineIntensity;

filename = gui_CaImageViewer.filename;

filesearchpattern = regexp(filename, '[A-Z]{2,3}0[0-9]{2,3}_[0-9]{4,6}', 'match'); filesearchpattern = filesearchpattern{1};

savefilepattern = [filesearchpattern, '_SpineIntensitySummary'];

eval([savefilepattern, ' = final;'])

animal = regexp(filesearchpattern, '[A-Z]{2,3}0[0-9]{2,3}', 'match'); animal = animal{1};

repositing_folder = ['C:\Users\Komiyama\Desktop\Output Data\', animal, ' Spine Volume Data'];

if isfolder(repositing_folder)
    cd(repositing_folder)
else
    mkdir(repositing_folder)
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

fname = [filesearchpattern, '_SpineVolumeROIs', '_DrawnBy', drawer];
eval([fname,'= a'])

target_dir = gui_CaImageViewer.save_directory;
cd(target_dir);

save(fname, fname)
