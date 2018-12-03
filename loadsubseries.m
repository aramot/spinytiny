function loadsubseries(hObject, eventdata, ~)

global gui_CaImageViewer
global zStack_Interface

%%% Initialize/reset parameters and settings when loading new file

set(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value', 0);
set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 0);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Enable', 'on');
set(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value', 0)
gui_CaImageViewer.NewSpineAnalysis = 0;
gui_CaImageViewer.SelectedStopFrame = [];
gui_CaImageViewer.IgnoreFrames = [];
handles = gui_CaImageViewer.figure.handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filename, pathname] = uigetfile('.tif');

if isnumeric(pathname) && isnumeric(filename)
    return
end

fname = [pathname, filename];
CaImage_File_info = imfinfo(fname);
timecourse_image_number = numel(CaImage_File_info);


gui_CaImageViewer.filename = filename;
gui_CaImageViewer.save_directory = pathname;
cd(pathname)
twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Set Image Properties %%%

Green_Frame = 1;
Red_Frame = 1;

gui_CaImageViewer.GCaMP_Image = [];
gui_CaImageViewer.Red_Image = [];

h = waitbar(0, 'Loading Image ');
TifLink = Tiff(fname, 'r');

Green_loc = gui_CaImageViewer.GreenGraph_loc;
Red_loc = gui_CaImageViewer.RedGraph_loc;

if twochannels
    set(gui_CaImageViewer.figure.handles.RedGraph, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.Channel2_StaticText, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.RedUpperLUT_EditableText, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.RedLowerLUT_EditableText, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.RedGamma_EditableText, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.RedGamma_StaticText, 'Visible', 'on')
    set(gui_CaImageViewer.figure.handles.GreenGraph, 'Units', 'normalized')
    set(gui_CaImageViewer.figure.handles.RedGraph, 'Units', 'normalized')
    figure(gui_CaImageViewer.figure.handles.figure1)
    axes(gui_CaImageViewer.figure.handles.GreenGraph);
    set(gui_CaImageViewer.figure.handles.GreenGraph, 'Position', [Green_loc(1), Red_loc(2), Red_loc(3), Red_loc(4)]);      %%% If an image using only 1 channel is already loaded, the "green" graph overlays the red, but the size of the original axes is maintained in the "red" graph.
    set(gui_CaImageViewer.figure.handles.RedGraph, 'Position', [Red_loc(1), Red_loc(2),  Red_loc(3), Red_loc(4)]);
        SliceFocus = regexp(zStack_Interface.CurrentSliceEdit.String, '[0-9]+_*', 'match');
    if zStack_Interface.LimittoSlice
        numslices = str2num(zStack_Interface.SlicesEdit.String);
        currentslice = str2double(SliceFocus{1});
        allmults = [currentslice:numslices:length(gui_CaImageViewer.GCaMP_Image)];       
    else
    end
    if length(SliceFocus)>1
        z_diff = str2double(SliceFocus{2})-str2double(SliceFocus{1});
    else
        z_diff = 0;
    end
    channel1 = gui_CaImageViewer.GCaMP_Image(allmults);
    channel2 = gui_CaImageViewer.Red_Image(allmults+z_diff);
else
    for i = 1:timecourse_image_number
        TifLink.setDirectory(i);
        gui_CaImageViewer.GCaMP_Image{1,Green_Frame} = TifLink.read();
        Green_Frame = Green_Frame+1;
        waitbar(Green_Frame/timecourse_image_number,h,['Loading Image ', num2str(Green_Frame)]);
    end
    if ~gui_CaImageViewer.LoadedFile || Green_loc(3) == Red_loc(3)
        set(gui_CaImageViewer.figure.RedGraph, 'Visible', 'off')
        set(gui_CaImageViewer.figure.Channel2_StaticText, 'Visible', 'off')
        set(gui_CaImageViewer.figure.RedUpperLUT_EditableText, 'Visible', 'off')
        set(gui_CaImageViewer.figure.RedLowerLUT_EditableText, 'Visible', 'off')
        set(gui_CaImageViewer.figure.RedGamma_EditableText, 'Visible', 'off')
        set(gui_CaImageViewer.figure.RedGamma_StaticText, 'Visible', 'off')
        gui_CaImageViewer.GraphPlacement = [Green_loc(1), Green_loc(2), Green_loc(3)+(Red_loc(1)-(Green_loc(1)+Green_loc(3))+Red_loc(3)), Green_loc(4)];
        set(gui_CaImageViewer.figure.GreenGraph, 'Units', 'normalized')
        figure(gui_CaImageViewer.figure.handles.figure1)
        axes(gui_CaImageViewer.figure.handles.GreenGraph);
        intergraphdistance = Red_loc(1)-(Green_loc(1)+Green_loc(3));
        set(handles.GreenGraph, 'Position', [Green_loc(1), Green_loc(2), Green_loc(3)+Red_loc(3)+intergraphdistance, Green_loc(4)])
    else
    end
    channel1 = gui_CaImageViewer.GCaMP_Image;
    channel2 = [];
end

close(h)

CommandSource = 'Loader';

[~, ~] = PlaceImages(channel1, channel2, CommandSource);

imageserieslength = size(gui_CaImageViewer.GCaMP_Image, 2);
gui_CaImageViewer.imageserieslength = imageserieslength;

set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(1/(imageserieslength-1)) (32/(imageserieslength-1))]);  %%% The Slider Step values indicate the minor and major transitions, which should be represented by the desired transition as the numerator and the length of the series as the denominator
set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', 1);
set(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String', '1');

set(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String', 1);

set(gui_CaImageViewer.figure.handles.output, 'WindowButtonDownFcn', [])

gui_CaImageViewer.LoadedFile = 1;