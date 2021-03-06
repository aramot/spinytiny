function CaImageSlider(ImageNum)

global gui_CaImageViewer
global zStack_Interface

ImageNum = ceil(get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value'));
SliderMax = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max');

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

set(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value', 0);
set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 0);


if ishandle(zStack_Interface.figure)
    SliceFocus = regexp(zStack_Interface.CurrentSliceEdit.String, '[0-9]+_*', 'match');
    if zStack_Interface.LimittoSlice
        numslices = str2num(zStack_Interface.SlicesEdit.String);
        currentslice = str2double(SliceFocus{1});
        allmults = [currentslice:numslices:length(gui_CaImageViewer.GCaMP_Image)];       
        if isempty(find(allmults==ImageNum))
            [~, ind] = min(abs(allmults-ImageNum));
            ImageNum = allmults(ind);
        end
    else
    end
    if length(SliceFocus)>1
        z_diff = str2double(SliceFocus{2})-str2double(SliceFocus{1});
    else
        z_diff = 0;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gui_CaImageViewer.NewSpineAnalysis && ~(SliderMax>3) %%% If a full image series is loaded, then SliderMax will be the number of images; If, on the other hand, multiple-session image comparisons are laoded, then SliderMax will typically be 2-3 
    animal = regexp(gui_CaImageViewer.filename, '[A-Z]{2,3}[0-9]*', 'match');
    animal = animal{1};
    experimenter = regexp(gui_CaImageViewer.save_directory, ['People.\w+'], 'match');
    experimenter = experimenter{1};
    experimenter = experimenter(strfind(experimenter, '\')+1:end);
    if ~isempty(gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates)
        dates = gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates;
        switch experimenter
            case 'Assaf'
                gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', dates(ImageNum,:),'\motion_corrected_tiffs\GFP\summed\'];
            case 'Pantong'
                gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', dates(ImageNum,:),'\snfr\summed\'];
            otherwise
                gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', dates(ImageNum,:), '\summed\'];
        end
%         mostlikelyfile = fastdir(gui_CaImageViewer.save_directory, 'summed_50.tif');
%         gui_CaImageViewer.filename = mostlikelyfile{1};
        gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate = dates(ImageNum,:);
    else
    end
    gui_CaImageViewer.NewSpineAnalysisInfo.CurrentSession = ImageNum;
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

if filterwindow == 1
    channel1 = double(gui_CaImageViewer.GCaMP_Image{ImageNum});
else
    smoothing_green = filter2(ones(filterwindow, filterwindow)/filterwindow^2, gui_CaImageViewer.GCaMP_Image{ImageNum});
    channel1 = smoothing_green;
end

if twochannels && ~merged
    if ishandle(zStack_Interface.figure)
        channel2 = double(gui_CaImageViewer.GCaMP_Image{ImageNum+z_diff});
    else
        channel2 = double(gui_CaImageViewer.Red_Image{ImageNum});
    end
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
%     
%     if twochannels && ~merged
%         if ishandle(zStack_Interface.figure)
%             smoothing_red = filter2(ones(filterwindow, filterwindow)/filterwindow^2, gui_CaImageViewer.GCaMP_Image{ImageNum+z_diff});
%         else
%             smoothing_red = filter2(ones(filterwindow, filterwindow)/filterwindow^2, gui_CaImageViewer.Red_Image{ImageNum});
%         end
%         channel2 = smoothing_red;
%     elseif twochannels && merged
%         redim = double(gui_CaImageViewer.Red_Image{ImageNum})/max(max(double(gui_CaImageViewer.Red_Image{ImageNum})));
%         channel1 = repmat(smoothing_green/max(max(smoothing_green)),[1 1 3]);
%         channel1(:,:,1) = zeros(size(channel1,1), size(channel1,2));
%         channel1(:,:,3) = zeros(size(channel1,1), size(channel1,2));
%         channel1(:,:,1) = filter2(ones(filterwindow,filterwindow)/filterwindow^2, redim);
%         channel2 = [];
%     else
%         channel2 = [];
%     end
% 
%     CommandSource = 'Slider';
% 
%     %%%%%%%%%
%     PlaceImages(channel1,channel2, CommandSource);
%     %%%%%%%%%
% end


%%% Place all existing ROIs on the new frame %%%

% PlaceROIs(ROI_stamp, coordinates);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', num2str(ImageNum));
set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', ImageNum);


if ishandle(zStack_Interface.figure)
    numslices = str2num(zStack_Interface.SlicesEdit.String);
    currentframe = str2num(gui_CaImageViewer.figure.handles.Frame_EditableText.String);
    if length(SliceFocus) == 1
        currentslice = mod(currentframe,numslices);
        if currentslice == 0
            currentslice = numslices;
        end
        zStack_Interface.CurrentSliceEdit.String = currentslice;
    else
    end
end

