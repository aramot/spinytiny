function DisplayProjection(Type)

global gui_CaImageViewer
global zStack_Interface

switch Type
    case 'Max'
        ischecked = get(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value');
    case 'Ave'
        ischecked = get(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value');
end
set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String',1);
        

ImageNum = str2double(get(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String'));
twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');
filterwindow = str2double(get(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String'));
merged = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');

if ishandle(zStack_Interface.figure)
    SliceFocus = regexp(zStack_Interface.CurrentSliceEdit.String, '[0-9]+_*', 'match');
    if zStack_Interface.LimittoSlice
        numslices = str2double(zStack_Interface.SlicesEdit.String);
        currentslice = str2double(SliceFocus{1});
        allmults = currentslice:numslices:length(gui_CaImageViewer.GCaMP_Image);       
        if isempty(find(allmults==ImageNum,1))
            [~, ind] = min(abs(allmults-ImageNum));
            ImageNum = allmults(ind);
        end
    else
        allmults = 1:length(gui_CaImageViewer.GCaMP_Image);
    end
    if length(SliceFocus)>1
        z_diff = str2double(SliceFocus{2})-str2double(SliceFocus{1});
    else
        z_diff = 0;
    end
end

if ischecked
    switch Type
        case 'Max'
            set(gui_CaImageViewer.figure.handles.AveProjection_CheckBox, 'Value', 0);
        case 'Ave'
            set(gui_CaImageViewer.figure.handles.MaxProjection_CheckBox, 'Value', 0);
    end
    if ishandle(zStack_Interface.figure)
        im = gui_CaImageViewer.GCaMP_Image(allmults);
    else
        im = gui_CaImageViewer.GCaMP_Image;
    end
    im = cat(3, im{:});
    switch Type
        case 'Max'
            improj = max(im, [], 3); 
        case 'Ave'
            improj = mean(im, 3);
    end
    
    if twochannels
        if ishandle(zStack_Interface.figure)
            overlim = (allmults+z_diff>length(gui_CaImageViewer.GCaMP_Image));
            if any(overlim)
                allmults = allmults(~overlim);
            end
            Rim = gui_CaImageViewer.GCaMP_Image(allmults+z_diff);
        else
            Rim = gui_CaImageViewer.Red_Image;
        end
        Rim = cat(3,Rim{:});
        switch Type
            case 'Max'
                Rimproj = max(Rim, [], 3);
            case 'Ave'
                Rimproj = mean(Rim, 3);
        end
    end
    
    
    if filterwindow == 1
    
        channel1 = improj;
        if twochannels && ~merged
            channel2 = Rimproj;
        elseif twochannels && merged
            channel1 = repmat(double(channel1)/max(max(double(channel1))),[1 1 3]);
            channel1(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            channel1(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            channel1(:,:,1) = double(Rimproj)/max(max(double(Rimproj)));
            channel2 = [];
        else
            channel2 = [];
        end

        CommandSource = 'Slider';

        %%%%%%%%%
        PlaceImages(channel1,channel2, CommandSource);
        %%%%%%%%%
    
    else
        smoothing_green = filter2(ones(filterwindow, filterwindow)/filterwindow^2, improj);
        channel1 = smoothing_green;
        if twochannels  && ~merged
            smoothing_red = filter2(ones(filterwindow, filterwindow)/filterwindow^2, Rimproj);
            channel2 = smoothing_red;
        elseif twochannels && merged
            channel1 = repmat(double(channel1)/max(max(double(channel1))),[1 1 3]);
            channel1(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            channel1(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            smoothing_red = filter2(ones(filterwindow, filterwindow)/filterwindow^2, Rimproj);
            channel1(:,:,1) = double(smoothing_red)/max(max(double(smoothing_red)));
            channel2 = [];
        else
            channel2 = [];
        end

        CommandSource = 'Slider';

        %%%%%%%%%
        PlaceImages(channel1,channel2, CommandSource);
        %%%%%%%%%
    end
else
    channel1 = gui_CaImageViewer.GCaMP_Image{ImageNum};
    
    if twochannels && ~merged
        if ishandle(zStack_Interface.figure)
            channel2 = gui_CaImageViewer.GCaMP_Image{ImageNum+z_diff};
        else
            channel2 = gui_CaImageViewer.Red_Image{ImageNum};
        end
    elseif twochannels && merged
            channel1 = repmat(double(channel1)/max(max(double(channel1))),[1 1 3]);
            channel1(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            channel1(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            channel1(:,:,1) = double(gui_CaImageViewer.Red_Image{ImageNum})/max(max(double(gui_CaImageViewer.Red_Image{ImageNum})));
            channel2 = [];
        else
            channel2 = [];
    end
        
    CaImageSlider(ImageNum);
end