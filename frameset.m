function frameset(hObject, eventdata)

if strcmpi(eventdata.Key, 'return')
    
    global gui_CaImageViewer
    
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
% 
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', ImageNum);

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
    end
   
    PlaceImages(channel1, channel2, 'Adjuster');
else
end