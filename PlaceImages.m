function [ch1image, ch2image] = PlaceImages(channel1, channel2, CommandSource)

global gui_CaImageViewer
global zStack_Interface

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For all operations that call this funcion - with the exception of the
%%% initial imaging loading, a uiobject is used. Make this the current
%%% object at the end of calling this function to easily resume normal
%%% operations

if strcmpi(CommandSource, 'Slider')
    current_uiobject = 'ImageSlider_Slider';
elseif ~strcmpi(CommandSource, 'Loader') 
    current_uiobject = get(gco, 'Tag');
else 
    current_uiobject = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize basic image parameters by pulling data from GUI

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');
scale = get(gui_CaImageViewer.figure.handles.Autoscale_CheckBox, 'Value');

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Find images in the axes, if they exist
GreenChild = findobj(Green_Figure, 'Type', 'image');
RedChild = findobj(Red_Figure, 'Type', 'image');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mapchoice = gui_CaImageViewer.CurrentCMap;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmpi(CommandSource, 'Loader')
    channel1 = channel1{1};
    figure(gui_CaImageViewer.figure.handles.figure1)
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
        if scale
            ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
        else
        end
        if filterwindow > 1
            ch1image = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        else
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        ch1image = channel1;
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        ch1image = channel1;
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        ch1image = channel1;
        set(Green_Figure, 'XTick', []);
        set(Green_Figure, 'YTick', []);
        colormap(fire);
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            caxis manual
        end
    end
    %%%% Channel 2 Image %%%%
    if twochannels
        channel2 = channel2{1};
        dubconv_im = double(gui_CaImageViewer.Red_Image{1});
        gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
        gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
        gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));    
        ch2image = gui_CaImageViewer.ch2image;
        if scale
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
            gui_CaImageViewer.ch2image = ch2image;
        end
    else
        set(GreenChild, 'CData', ch1image);
        gui_CaImageViewer.ch1image = ch1image;
        set(RedChild, 'CData', ch2image);
        gui_CaImageViewer.ch2image = ch2image;
    end
elseif strcmpi(CommandSource, 'Smoother')
    
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
        if scale
            ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
        else
        end
        channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        set(GreenChild, 'CData', ch1image)
        caxis([GreenLower, GreenUpper])
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1);
        set(Green_Figure, 'XTick', []);
        set(Green_Figure, 'YTick', []);
        colormap(fire);
        if scale
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
        if scale
            ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
        else        
        end
        set(RedChild, 'CData', ch2image)
        caxis([RedLower, RedUpper])
    else
        ch2image = [];
    end
    
elseif strcmpi(CommandSource, 'Slider')
    
    ImageNum = get(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value');
    Merge = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');
    
    axes(Green_Figure);
    
    if strcmpi(mapchoice, 'RGB')
        if ~Merge || (Merge && ~twochannels)
            if size(channel1,3)>1
                channel1 = channel1(:,:,2);
            end
            dubconv_im = double(channel1);
            gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            ch1image = gui_CaImageViewer.ch1image;
            if scale
                ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
            end
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image)
            if scale
                caxis([GreenLower, GreenUpper])
            end
        elseif Merge && twochannels
            gui_CaImageViewer.ch1image = channel1;
            ch1image = gui_CaImageViewer.ch1image;
            if scale
                ch1image = imadjust(ch1image, [RedLower GreenLower 0; RedUpper GreenUpper 0.001],[], green_gamma);
            end
            ch1image(:,:,1) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,1));
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image);
            if scale
                caxis([GreenLower, GreenUpper])
            end
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(jet)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(hot)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
        end
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
        end
        set(GreenChild, 'CData', channel1)
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        if scale
            caxis auto
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            caxis manual
        end
    end
   
    %%%% Channel 2 (Red) Image %%%%
    if twochannels && ~Merge
        axes(Red_Figure);
        if size(channel2,3)>1
            channel2 = channel2(:,:,1);
        else
        end
        dubconv_im = double(channel2);
        if ishandle(zStack_Interface.figure)
            gui_CaImageViewer.ch2image = channel2;
            channel2 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel2);
            ch2image = channel2;
            gui_CaImageViewer.ch2image = ch2image;
        else
            gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
            gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));
            ch2image = gui_CaImageViewer.ch2image;
            if scale
                ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
            end
            channel2 = ch2image;
            gui_CaImageViewer.ch2image = ch2image;
        end
        if isempty(RedChild)
            axes(Red_Figure);
            set(Red_Figure, 'XLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},1)+0.5]);
            set(Red_Figure, 'YLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},2)+0.5]);
            image(ch2image, 'CDataMapping', 'scaled');
            set(Red_Figure, 'XTick', [])
            set(Red_Figure, 'YTick', [])
            pause(0.1)
            caxis manual
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            set(RedChild, 'CData', channel2)
            pause(0.1)
            caxis manual
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        end
    else
    end
elseif strcmpi(CommandSource, 'Stretcher')
        ch1image = gui_CaImageViewer.ch1image;
        axes(Green_Figure);
        image(ch1image, 'CDataMapping', 'scaled')
        set(Green_Figure, 'XTick', [])
        set(Green_Figure, 'YTick', [])
        colormap(fire)
        caxis manual
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
        if ~Merge || (Merge && ~twochannels)
            if size(channel1,3)>1
                channel1 = channel1(:,:,2);
            end
            dubconv_im = double(channel1);
            gui_CaImageViewer.ch1image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch1image(:,:,1) = zeros(size(channel1,1), size(channel1,2));
            gui_CaImageViewer.ch1image(:,:,3) = zeros(size(channel1,1), size(channel1,2));
            ch1image = gui_CaImageViewer.ch1image;
            if scale
                ch1image = imadjust(ch1image, [0 GreenLower 0; 0.001 GreenUpper 0.001],[], green_gamma);
            end
            if filterwindow>1
                ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            end
            set(GreenChild, 'CData', ch1image)
            caxis([GreenLower, GreenUpper])
        elseif Merge && twochannels
            gui_CaImageViewer.ch1image = channel1;
            ch1image = gui_CaImageViewer.ch1image;
            if scale
                ch1image = imadjust(ch1image, [RedLower GreenLower 0; RedUpper GreenUpper 0.001],[], green_gamma);
            end
            ch1image(:,:,1) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,1));
            ch1image(:,:,2) = filter2(ones(filterwindow, filterwindow)/filterwindow^2, ch1image(:,:,2));
            set(GreenChild, 'CData', ch1image);
            caxis([GreenLower, GreenUpper])
        end
    elseif strcmpi(mapchoice, 'Jet')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
            set(GreenChild, 'CData', channel1)
            set(Green_Figure, 'XTick', [])
            set(Green_Figure, 'YTick', [])
            colormap(jet)
        end
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    elseif strcmpi(mapchoice, 'Hot')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
            set(GreenChild, 'CData', channel1)
            set(Green_Figure, 'XTick', [])
            set(Green_Figure, 'YTick', [])
            colormap(hot)
        end
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    elseif strcmpi(mapchoice, 'Fire')
        gui_CaImageViewer.ch1image = channel1;
        if filterwindow>1
            channel1 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel1);
            set(GreenChild, 'CData', channel1)
            set(Green_Figure, 'XTick', [])
            set(Green_Figure, 'YTick', [])
            colormap(fire)
        end
        caxis auto
        maps = caxis;
        caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Handle second channel, if applicable
    if twochannels && ~Merge
        axes(Red_Figure);
        if size(channel2,3)>1
            channel2 = channel2(:,:,1);
        else
        end
        dubconv_im = double(channel2);
        if ishandle(zStack_Interface.figure)
            gui_CaImageViewer.ch2image = channel2;
            channel2 = filter2(ones(filterwindow, filterwindow)/filterwindow^2, channel2);
            ch2image = channel2;
            gui_CaImageViewer.ch2image = ch2image;
        else
            gui_CaImageViewer.ch2image = repmat(dubconv_im/max(max(dubconv_im)),[1 1 3]);
            gui_CaImageViewer.ch2image(:,:,2) = zeros(size(channel2,1), size(channel2,2));
            gui_CaImageViewer.ch2image(:,:,3) = zeros(size(channel2,1), size(channel2,2));
            ch2image = gui_CaImageViewer.ch2image;
            if scale
                ch2image = imadjust(ch2image, [RedLower 0 0; RedUpper 0.001 0.001],[],red_gamma);
                channel2 = ch2image;
                gui_CaImageViewer.ch2image = ch2image;
            end
        end
        if isempty(RedChild)
            axes(Red_Figure);
            set(Red_Figure, 'XLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},1)+0.5]);
            set(Red_Figure, 'YLim', [0.5, size(gui_CaImageViewer.GCaMP_Image{1},2)+0.5]);
            image(ch2image, 'CDataMapping', 'scaled');
            set(Red_Figure, 'XTick', [])
            set(Red_Figure, 'YTick', [])
            pause(0.1)
            caxis manual
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        else
            set(RedChild, 'CData', channel2)
            pause(0.1)
            caxis manual
            maps = caxis;
            caxis([GreenLower*maps(2), GreenUpper*maps(2)]);
        end
    else
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OverlapFig = findobj('Type', 'figure', 'Name', 'RGB Overlap');
    if length(OverlapFig)>1
        OverlapFig = OverlapFig(1);
    end
    if ImageNum<4
        if ~isempty(OverlapFig)
            AdjLow = GreenLower;
            AdjHigh = GreenUpper;
            OverlapAx = get(OverlapFig, 'Children');
            
            
            axes(OverlapAx)
            OverlapAxProp = get(OverlapAx);
            OverlapImage = OverlapFig.UserData.OriginalImage;
            CurrentImage = OverlapAxProp.Children.CData;
            OldCAxis = OverlapFig.UserData.CAxis; OldRed = OldCAxis(:,1); OldGreen = OldCAxis(:,2); OldBlue = OldCAxis(:,3);
            if ImageNum == 3 %%% Channel 3/Session 3 is blue!
               NewCAxis = [OldRed(1) OldGreen(1) AdjLow; OldRed(2) OldGreen(2) AdjHigh];
               NewIm = imadjust(OverlapImage, NewCAxis, [], green_gamma);
               OverlapFig.UserData.CAxis = NewCAxis;
            elseif ImageNum == 2 %%% Channel 2/Session 2 is green!
               NewCAxis = [OldRed(1) AdjLow OldBlue(1); OldRed(2) AdjHigh OldBlue(2)];
               NewIm = imadjust(OverlapImage, NewCAxis,[], green_gamma);
               OverlapFig.UserData.CAxis = NewCAxis;
            elseif ImageNum == 1 %%% Channel 1/Session 1 is red!
               NewCAxis = [AdjLow OldGreen(1) OldBlue(1); AdjHigh OldGreen(2) OldBlue(2)];
               NewIm = imadjust(OverlapImage, NewCAxis, [], green_gamma);
               OverlapFig.UserData.CAxis = NewCAxis;
            else 
               NewIm = CurrentImage;
            end
            OverlapAxProp.Children.CData = NewIm;
        end
    end
end

if ~isempty(current_uiobject)
    eval(['uicontrol(gui_CaImageViewer.figure.handles.', current_uiobject,')'])
end

end

