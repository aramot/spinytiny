function ViewSelectSlices(hObject, eventdata, handles)

global gui_CaImageViewer
global zStack_Interface


if hObject.Value 
    currentslice = char(zStack_Interface.CurrentSliceEdit.String);
    numslices = char(zStack_Interface.SlicesEdit.String);
    
    if gui_CaImageViewer.figure.handles.TwoChannels_CheckBox.Value
        gui_CaImageViewer.figure.handles.TwoChannels_CheckBox.Value = 0;
        axes(gui_CaImageViewer.figure.handles.RedGraph);
        cla
        gui_CaImageViewer.figure.handles.RedGraph.Visible = 'off';
        Green_loc = gui_CaImageViewer.GreenGraph_loc;
        Red_loc = gui_CaImageViewer.RedGraph_loc;
        gui_CaImageViewer.GraphPlacement = [Green_loc(1), Green_loc(2), Green_loc(3)+(Red_loc(1)-(Green_loc(1)+Green_loc(3))+Red_loc(3)), Green_loc(4)];
        intergraphdistance = Red_loc(1)-(Green_loc(1)+Green_loc(3));
        set(gui_CaImageViewer.figure.handles.GreenGraph, 'Position', [Green_loc(1), Green_loc(2), Green_loc(3)+Red_loc(3)+intergraphdistance, Green_loc(4)])
    end

    SliceFocus = inputdlg({['Slices to view (1-', numslices,'; can enter up to 2):']}, 'Input', 1, {currentslice});
    SliceFocus = regexp(SliceFocus, '[0-9]+_*', 'match'); SliceFocus = SliceFocus{1};
    zStack_Interface.CurrentSliceEdit.String = num2str(str2double(SliceFocus));
    imageserieslength = length(gui_CaImageViewer.GCaMP_Image);

    if length(SliceFocus) == 1
        SliceFocus = str2double(SliceFocus{1});
        zStack_Interface.LimittoSlice = 1;
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', SliceFocus);
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', SliceFocus);
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength-mod(imageserieslength,SliceFocus));
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(str2num(numslices)/(imageserieslength-1)) (str2num(numslices)*4/(imageserieslength-1))]);
        
        channel1 = gui_CaImageViewer.GCaMP_Image{SliceFocus};
        PlaceImages(channel1, [], 'Slider');
    elseif length(SliceFocus) > 1
        if length(SliceFocus)>2
            SliceFocus = SliceFocus{1:2};
        end
        zStack_Interface.LimittoSlice = 1;
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', str2double(SliceFocus{1}));
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', str2double(SliceFocus{1}));
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength-mod(imageserieslength,str2double(SliceFocus{1})));
        set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(str2double(numslices)/(imageserieslength-1)) (str2double(numslices)*4/(imageserieslength-1))]);
        
        channel1 = gui_CaImageViewer.GCaMP_Image{str2double(SliceFocus{1})};
        channel2 = gui_CaImageViewer.GCaMP_Image{str2double(SliceFocus{2})};
        gui_CaImageViewer.figure.handles.GreenGraph.Position = gui_CaImageViewer.GreenGraph_loc;
        gui_CaImageViewer.figure.handles.RedGraph.Position = gui_CaImageViewer.RedGraph_loc;
        gui_CaImageViewer.figure.handles.TwoChannels_CheckBox.Value = 1;
        gui_CaImageViewer.figure.handles.RedGraph.Visible = 'on';
        PlaceImages(channel1, channel2, 'Slider');

    else
    end
    
else
    %%% Reset to single-channel, full-series mode
    if gui_CaImageViewer.figure.handles.TwoChannels_CheckBox.Value
        gui_CaImageViewer.figure.handles.TwoChannels_CheckBox.Value = 0;
        axes(gui_CaImageViewer.figure.handles.RedGraph);
        cla
        gui_CaImageViewer.figure.handles.RedGraph.Visible = 'off';
        Green_loc = gui_CaImageViewer.GreenGraph_loc;
        Red_loc = gui_CaImageViewer.RedGraph_loc;
        gui_CaImageViewer.GraphPlacement = [Green_loc(1), Green_loc(2), Green_loc(3)+(Red_loc(1)-(Green_loc(1)+Green_loc(3))+Red_loc(3)), Green_loc(4)];
        intergraphdistance = Red_loc(1)-(Green_loc(1)+Green_loc(3));
        set(gui_CaImageViewer.figure.handles.GreenGraph, 'Position', [Green_loc(1), Green_loc(2), Green_loc(3)+Red_loc(3)+intergraphdistance, Green_loc(4)])
    end
    imageserieslength = length(gui_CaImageViewer.GCaMP_Image);
    zStack_Interface.LimittoSlice = 0;
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', 1);
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength);
    set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(1/(imageserieslength-1)) (1*4/(imageserieslength-1))]);
    setslicenum(hObject)
end