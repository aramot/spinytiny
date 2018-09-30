function [ch1image, ch2image] = PlaceImages(channel1, channel2, CommandSource)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global gui_CaImageViewer


%%% Initialize basic image parameters by pulling data from GUI

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

GreenUpper = str2num(get(gui_CaImageViewer.figure.handles.UpperLUT_EditableText, 'String'));
    if GreenUpper > 1
        set(gui_CaImageViewer.figure.handles.UpperLUT_EditableText, 'String', '1');
        GreenUpper =1;
    elseif GreenUpper < 0
        set(gui_CaImageViewer.figure.handles.UpperLUT_EditableText, 'String', '0.1');
        GreenUpper = 0.1;
    end
GreenLower = str2num(get(gui_CaImageViewer.figure.handles.LowerLUT_EditableText, 'String'));
    if GreenLower > 1
        set(gui_CaImageViewer.figure.handles.LowerLUT_EditableText, 'String', '0.9');
        GreenLower =0.9;
    elseif GreenLower < 0
        set(gui_CaImageViewer.figure.handles.LowerLUT_EditableText, 'String', '0');
        GreenLower = 0;
    end
RedUpper = str2num(get(gui_CaImageViewer.figure.handles.RedUpperLUT_EditableText, 'String'));
    if RedUpper > 1
        set(gui_CaImageViewer.figure.handles.RedUpperLUT_EditableText, 'String', '1');
        RedUpper =1;
    elseif RedUpper < 0
        set(gui_CaImageViewer.figure.handles.RedUpperLUT_EditableText, 'String', '0.1');
        RedUpper = 0.1;
    end
RedLower =str2num(get(gui_CaImageViewer.figure.handles.RedLowerLUT_EditableText, 'String'));
    if RedLower > 1
        set(gui_CaImageViewer.figure.handles.RedLowerLUT_EditableText, 'String', '1');
        RedLower =1;
    elseif RedLower < 0
        set(gui_CaImageViewer.figure.handles.RedLowerLUT_EditableText, 'String', '0.1');
        RedLower = 0.1;
    end
    
    
green_gamma = str2num(get(gui_CaImageViewer.figure.handles.GreenGamma_EditableText, 'String'));
red_gamma = str2num(get(gui_CaImageViewer.figure.handles.RedGamma_EditableText, 'String'));
    
Green_Figure = gui_CaImageViewer.figure.handles.GreenGraph;
Red_Figure = gui_CaImageViewer.figure.handles.RedGraph;

filterwindow = str2num(get(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String'));

%%%% Find images in the axes, if they exist
GreenChild = findobj(Green_Figure, 'Type', 'image');
RedChild = findobj(Red_Figure, 'Type', 'image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mapchoice = gui_CaImageViewer.CurrentCMap;

if strcmpi(CommandSource, 'Loader')
    channel1 = channel1{1};
    if strcmpi(mapchoice, 'RGB')
        if size(channel1,3)>1
            channel1 = channel1(:,:,2);
        else
        end
        dubconv_im = double(channel1);
        gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
        gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
        ch1image = gui_CaImageViewer.ch1image;
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
        else
        end
        if filterwindow > 1
            ch1image = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image);
        else
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        ch1image = channel1;
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        ch1image = channel1;
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        ch1image = channel1;
        set(Green_Figure, 'XTick', []);
        set(Green_Figure, 'YTick', []);
        colormap(fire);
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            caxis manual
        end
    end
    %%%% Channel 2 (Red) Image %%%%
    if twochannels ;
        channel2 = channel2{1};
        dubconv_im = double(gui_CaImageViewer.Red_Image{1});
        gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
        gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));    
        ch2image = gui_CaImageViewer.ch2image;
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
        else        
        end
    else
        ch2image = [];
    end
    
    if ~gui_CaImageViewer.LoadedFile
        figure(gui_CaImageViewer.figure.handles.figure1)
        axes(Green_Figure);
        cla;
        set(Green_Figure, 'XLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},1)+0.5]);
        set(Green_Figure, 'YLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},2)+0.5]);
        image(ch1image, 'CDataMapping', 'scaled');
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        gui_CaImageViewer.ch1image = ch1image;
        if twochannels
            axes(Red_Figure);
            cla;
            set(Red_Figure, 'XLim', [0.5, size(gui_CaImageViewer.Red_Image{1},1)+0.5]);
            set(Red_Figure, 'YLim', [0.5, size(gui_CaImageViewer.Red_Image{1},2)+0.5]);
            image(ch2image, 'CDataMapping', 'scaled');
            set(Red_Figure, 'XTick', [])
            set(Red_Figure, 'YTick', [])
            gui_CaImageViewer.ch1image = ch1image;
        end
    else
        set(GreenChild, 'CData', ch1image);
        gui_CaImageViewer.ch1image = ch1image;
        set(RedChild, 'CData', ch2image);
        gui_CaImageViewer.ch2image = ch2image;
    end
elseif strcmpi(CommandSource, 'Smoother');
    
    ImageNum = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value');
    
    axes(Green_Figure);
    
    if strcmpi(mapchoice, 'RGB')
        if size(channel1,3)>1
            channel1 = channel1(:,:,2);
        else
        end
        dubconv_im = double(channel1);
        gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
        gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
        ch1image = gui_CaImageViewer.ch1image;
        ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', ch1image)
        caxis([GreenLower, GreenUpper])
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1);
        set(Green_Figure, 'XTick', []);
        set(Green_Figure, 'YTick', []);
        colormap(fire);
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            caxis manual
        end
    end
       
    %%%% Channel 2 (Red) Image %%%%
    if twochannels == 1
        dubconv_im = double(gui_CaImageViewer.Red_Image{1});
        gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
        gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));    
        ch2image = gui_CaImageViewer.ch2image;
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
        else        
        end
        set(RedChild, 'CData', ch2image)
        caxis([RedLower, RedUpper])
    else
        ch2image = [];
    end
    
elseif strcmpi(CommandSource, 'Slider');
    
    ImageNum = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value');
    Merge = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');
    
    axes(Green_Figure);
    
    if strcmpi(mapchoice, 'RGB')
        if ~Merge
            if size(channel1,3)>1
                channel1 = channel1(:,:,2);
            end
            dubconv_im = double(channel1);
            gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            ch1image = gui_CaImageViewer.ch1image;
            ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image)
            caxis([GreenLower, GreenUpper])
        elseif Merge
            gui_CaImageViewer.ch1image = channel1;
            ch1image = gui_CaImageViewer.ch1image;
            ch1image = imadjust(ch1image, [RedLower GreenLower 0; RedUpper GreenUpper 0.001],[], green_gamma);
            ch1image(:,:,1) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,1));
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image);
            caxis([GreenLower, GreenUpper])
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        if get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value')
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            caxis manual
        end
    end
   
    %%%% Channel 2 (Red) Image %%%%
    if twochannels == 1;
        axes(Red_Figure);
        if size(channel2,3)>1
            channel2 = channel2(:,:,1);
        else
        end
        dubconv_im = double(channel2);
        gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
        gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));    
        ch2image = gui_CaImageViewer.ch2image;
        ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
        set(RedChild, 'CData', ch2image)
        caxis([RedLower, RedUpper])
    else
    end
elseif strcmpi(CommandSource, 'Stretcher')
        ch1image = gui_CaImageViewer.ch1image;
        axes(Green_Figure);
        image(ch1image, 'CDataMapping', 'scaled')
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    elseif strcmpi(CommandSource, 'Square')
        ch1image = gui_CaImageViewer.ch1image;
        axes(Green_Figure);
        imshow(ch1image);
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
elseif strcmpi(CommandSource, 'Adjuster')
    ImageNum = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value');
    Merge = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');
    
    axes(Green_Figure);
    
    if strcmpi(mapchoice, 'RGB')
        if ~Merge
            if size(channel1,3)>1
                channel1 = channel1(:,:,2);
            end
            dubconv_im = double(channel1);
            gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            ch1image = gui_CaImageViewer.ch1image;
            ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image)
            caxis([GreenLower, GreenUpper])
        elseif Merge
            gui_CaImageViewer.ch1image = channel1;
            ch1image = gui_CaImageViewer.ch1image;
            ch1image = imadjust(ch1image, [RedLower GreenLower 0; RedUpper GreenUpper 0.001],[], green_gamma);
            ch1image(:,:,1) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,1));
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image);
            caxis([GreenLower, GreenUpper])
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        end
    end
   
    %%%% Channel 2 (Red) Image %%%%
    if twochannels == 1;
        axes(Red_Figure);
        if size(channel2,3)>1
            channel2 = channel2(:,:,1);
        else
        end
        dubconv_im = double(channel2);
        gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
        gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));    
        ch2image = gui_CaImageViewer.ch2image;
        ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
        set(RedChild, 'CData', ch2image)
        caxis([RedLower, RedUpper])
    else
    end
end

