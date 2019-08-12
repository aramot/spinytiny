function frameset(hObject, eventdata)

if strcmpi(eventdata.Key, 'return')
    
    global gui_CaImageViewer
    global zStack_Interface

    twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');
    
    aveproj = get(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value');
    maxproj = get(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value');
% 
    ImageNum = str2num(get(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String'));
    if ImageNum > length(gui_CaImageViewer.GCaMP_Image)
        ImageNum = length(gui_CaImageViewer.GCaMP_Image);
        set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', num2str(ImageNum));
    end
    merged = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');
    
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% zStack Section
    if ishandle(zStack_Interface.figure)
        SliceFocus = regexp(zStack_Interface.CurrentSliceEdit.String, '[0-9]+_*', 'match');
        if zStack_Interface.LimittoSlice
            numslices = str2num(zStack_Interface.SlicesEdit.String);
            currentslice = str2double(SliceFocus{1});
            allmults = [currentslice:numslices:length(gui_CaImageViewer.GCaMP_Image)];       
            if isempty(find(allmults==ImageNum,1))
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
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', ImageNum);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if aveproj || maxproj
        channel1 = gui_CaImageViewer.ch1image;
        if twochannels
            channel2 = gui_CaImageViewer.ch2image;
        else
            channel2 = [];
        end
    else
        channel1 = double(gui_CaImageViewer.GCaMP_Image{ImageNum});
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
    end
   
    PlaceImages(channel1, channel2, 'Adjuster');
else
end