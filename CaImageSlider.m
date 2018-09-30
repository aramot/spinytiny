function CaImageSlider(ImageNum)

global gui_CaImageViewer

ImageNum = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value');

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

set(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value', 0);
set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gui_CaImageViewer.NewSpineAnalysis
    animal = regexp(gui_CaImageViewer.filename, '[A-Z]{2,3}[0-9]*', 'match');
    animal = animal{1};
    experimenter = regexp(gui_CaImageViewer.save_directory, ['People.\w+'], 'match');
    experimenter = experimenter{1};
    experimenter = experimenter(strfind(experimenter, '\')+1:end);
    if ~isempty(gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates)
        dates = gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates;
        gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', dates(ImageNum,:), '\summed\'];
        mostlikelyfile = fastdir(gui_CaImageViewer.save_directory, 'summed_50.tif');
        gui_CaImageViewer.filename = mostlikelyfile{1};
        gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate = dates(ImageNum,:);
    else
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if ImageNum > gui_CaImageViewer.imageserieslength
    ImageNum = gui_CaImageViewer.imageserieslength;
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', gui_CaImageViewer.imageserieslength);
elseif ImageNum < 1
    ImageNum = 1;
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);
end


%%% Modify and filter the new frame like the previous one(s) %%%

filterwindow = str2num(get(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String'));
if ~isnumeric(filterwindow)
    filterwindow = 1;
end


if ~isinteger(ImageNum)
    ImageNum = ceil(ImageNum);
end

merged = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');

if filterwindow == 1;
    
    channel1 = double(gui_CaImageViewer.GCaMP_Image{ImageNum});
    if twochannels && ~merged
        channel2 = gui_CaImageViewer.Red_Image{ImageNum};
    elseif twochannels && merged
        channel1 = repmat(channel1/max(max(channel1)),[1 1 3]);
        channel1(:,:,1) = zeros(size(channel1,1), size(channel1,2));
        channel1(:,:,3) = zeros(size(channel1,1), size(channel1,2));
        channel1(:,:,1) = double(gui_CaImageViewer.Red_Image{ImageNum})/max(max(double(gui_CaImageViewer.Red_Image{ImageNum})));
        channel2 = [];
    else
        channel2 = [];
    end
    
    CommandSource = 'Slider';
    
    %%%%%%%%%
    PlaceImages(channel1,channel2, CommandSource);
    %%%%%%%%%
    
else
    smoothing_green = filter2(ones(filterwindow, filterwindow)/filterwindow^2, gui_CaImageViewer.GCaMP_Image{ImageNum});
    channel1 = smoothing_green;
    if twochannels 
        smoothing_red = filter2(ones(filterwindow, filterwindow)/filterwindow^2, gui_CaImageViewer.Red_Image{ImageNum});
        channel2 = smoothing_red;
    else
        channel2 = [];
    end

    CommandSource = 'Slider';

    %%%%%%%%%
    PlaceImages(channel1,channel2, CommandSource);
    %%%%%%%%%
end


%%% Place all existing ROIs on the new frame %%%

% PlaceROIs(ROI_stamp, coordinates);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', num2str(ImageNum));
set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', ImageNum);
