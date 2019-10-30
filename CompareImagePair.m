function warpmatrix = CompareImagePair(~,~)

global gui_CaImageViewer

selectedaxes = findobj(gcf, 'XColor', [0 1 0]);     %%% Finds the selected axes based on the color set to 'XColor' in function HighLightAxis)

figtitle = regexp(get(gcf, 'Name'), '[A-Z]{2,3}0+\d+', 'match');
if ~isempty(figtitle)
    experiment = figtitle{1};
    animal = experiment;
else
    animal = regexp(gui_CaImageViewer.filename, '[A-Z]{2,3}[0-9]*', 'match');
    animal = animal{1};
end

experimenter = regexp(gui_CaImageViewer.save_directory, ['People.\w+'], 'match');
experimenter = experimenter{1};
experimenter = experimenter(strfind(experimenter, '\')+1:end);
selectedaxes = flipud(selectedaxes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pull images,date,and field info from selected axes
for i = 1:length(selectedaxes)
    im{i} = uint16(get(get(selectedaxes(i), 'Children'), 'CData'));
    date(i,1:6) = get(get(selectedaxes(i), 'Title'), 'String');
    fieldindicator{i} = selectedaxes(i).XLabel.String;
end
fieldindicator = fieldindicator(~cellfun(@isempty, fieldindicator));
possiblefieldnumbers = unique(cellfun(@(x) x(end), cellfun(@(x) regexp(x, 'field [0-9]','match'), fieldindicator)));
if length(possiblefieldnumbers)>1
    fieldnumber = str2num(mode(possiblefieldnumbers));
else
    fieldnumber = str2num(possiblefieldnumbers);
end

[~, ind] = sortrows(date); %% Sort images according to date
im = im(ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageserieslength = length(im);

%%% You will be projecting two images to the main CaImageViewer window, so
%%% set the slider value to 2 so that they are scroll-able
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [1/(imageserieslength-1) imageserieslength/(imageserieslength-1)]);  %%% The Slider Step values indicate the minor and major transitions, which should be represented by (Desired Step)/(Max Step-Min Step)
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);

set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', '1');

%%%%%%%%%%%%%%%%%%%%%%%
centeredimage = im{1};      %%% When initially drawing the ROIs, it makes sense to start with session 1 being the comparator. However...
mobileimage = cell(1,length(im));
warpmatrix = cell(1,length(im));
shiftedimage = cell(1,length(im));
%%%%%%%%%%%%%%%%%%%%%%%

alignchoice = get(findobj('Tag', 'Alignment_CheckBox'), 'Value');
refheight = size(centeredimage,1);

if alignchoice 
    for al = 2:length(im)
        mobileimage = im{al};        %%% When moving ROIs, you usually move session 1 ROIs to match the position of session 2, so for this purpose it usually makes sense for the mobile image to be from session 1 
        imheight = size(mobileimage,1);
        imwidth = size(mobileimage,2);
        if imheight~=refheight
            heightdiff = abs(refheight-imheight);
            mobileimage = [zeros(heightdiff/2,imwidth); mobileimage; zeros(heightdiff/2,imwidth)];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %[RESULTS, WARP, WARPEDiMAGE] = ECC(IMAGE, TEMPLATE, LEVELS, NOI, TRANSFORM, DELTA_P_INIT)
        levels = 5 ;
        iterations =25;
        delta_p_init = zeros(2,3); delta_p_init(1,1) = 1; delta_p_init(2,2) = 1;
    %     [~, ~, shiftedimage] = ecc(mobileimage, centeredimage,levels,iterations, 'affine', delta_p_init);
        [~, ~, shiftedimage{al}] = ecc(mobileimage, centeredimage,levels,iterations, 'affine');
        %%% Calculate inverse warp matrix to match the opposite direction for
        %%% shifting ROIs
        ROIShift_centeredimage = mobileimage;
        ROIShift_mobileimage = centeredimage;
        [~, warpmatrix{al}, ~] = ecc(ROIShift_mobileimage, ROIShift_centeredimage,levels,iterations, 'affine', delta_p_init);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
else
    for al = 2:length(im)
        warpmatrix{al} = [];
        shiftedimage{al} = uint16(mobileimage);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 1: Side by Side Comparison of Corrected Images %%%%%%%%%%%%%%%%%

figure('Name', 'Side-by-side Comparison','Position', [336,285,1217,522], 'NumberTitle', 'off'); 
imwidth = 0.8/length(im);
im_ax{1} = axes('Units', 'Normalized','Position', [0.05 0.05 imwidth 0.9], 'XTick', [], 'YTick', []); 
imshow(centeredimage,[]); colormap(fire);
title('Image 1')
ax_count = 2;
for al = 2:length(im)
    x_pos = 0.05+((al-1)*0.05)+((al-1)*imwidth);
    im_ax{ax_count} = axes('Units', 'Normalized','Position', [x_pos 0.05 imwidth 0.9], 'XTick', [], 'YTick', []);
    imshow(shiftedimage{al}, []); colormap(fire);
    title(['Image ', num2str(al)])
    ax_count = ax_count+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 2: Images differences pre- and post- correction %%%%%%%%%%%%%%%%

figure('Name', 'Image Difference Pre- and Post-Correction','Position', [336,255,1217,522], 'NumberTitle', 'off');  
im_ax{ax_count} = axes('Units', 'Normalized','Position', [0.05 0.05 imwidth 0.9], 'XTick', [], 'YTick', []); 
imshow(im2double(mobileimage)/max(im2double(mobileimage(:)))-im2double(centeredimage)/max(im2double(centeredimage(:))),[]); 
title('Image difference pre-correction', 'Fontsize', 12)
for al = 2:length(im)
    x_pos = 0.05+((al-1)*0.05)+((al-1)*imwidth);
    im_ax{ax_count} = axes('Units', 'Normalized','Position', [x_pos 0.05 imwidth 0.9], 'XTick', [], 'YTick', []); 
    ax_count = ax_count+1;
    imshow(im2double(shiftedimage{al})/max(im2double(shiftedimage{al}(:)))-im2double(centeredimage)/max(im2double(centeredimage(:))),[]);
    title('Image difference post-correction', 'Fontsize', 12)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 3: Color-coded alignment (RGB image corresponding to channels

OverlapFig = figure('Name', 'RGB Overlap','Position', [336,255,1217,522], 'NumberTitle', 'off');  
normalized_centeredimage = im2double(centeredimage)/max(im2double(centeredimage(:)));
centeredimage_RGB = zeros(size(centeredimage,1),size(centeredimage,1), 3);
centeredimage_RGB(1:end,1:end,1) = normalized_centeredimage;
RGBim = centeredimage_RGB;
for al = 2:length(im)
    normalized_shiftedimage = im2double(shiftedimage{al})/max(im2double(shiftedimage{al}(:)));
    shiftedimage_RGB = zeros(size(shiftedimage{al},1),size(shiftedimage{al},1), 3);
    shiftedimage_RGB(1:end,1:end,al) = normalized_shiftedimage;
    RGBim = RGBim+shiftedimage_RGB;
end
im_ax{ax_count} = axes('Units', 'Normalized','XTick', [], 'YTick', []);
imshow(RGBim)
title('Color-coded alignment', 'Fontsize', 12)
linkaxes([im_ax{:}, gui_CaImageViewer.figure.handles.GreenGraph], 'xy')
if length(im)==2
    OverlapFig.UserData.CAxis = [0 0 0; 1 1 0.001];
elseif length(im)==3
    OverlapFig.UserData.CAxis = [0 0 0; 1 1 1];
end
OverlapFig.UserData.OriginalImage = RGBim;

placeimage = cell(1,length(im));
placeimage{1} = centeredimage;
for al = 2:length(im)
    placeimage{al} = shiftedimage{al};
end

gui_CaImageViewer.GCaMP_Image = placeimage;

PlaceImages(shiftedimage{end}, [], 'Slider')

gui_CaImageViewer.NewSpineAnalysisInfo.WarpMatrix = warpmatrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Set up parameters in an accessible substructure within the main GUI
selectedaxes = flipud(selectedaxes);
for i = 1:length(selectedaxes)
    date(i,1:6) = get(get(selectedaxes(i), 'Title'), 'String');
end

[sorteddates, ~] = sortrows(date);

gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', sorteddates(1,:), '\summed\'];

gui_CaImageViewer.NewSpineAnalysis = 1;
gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate = sorteddates(1,:);
gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates = sorteddates;

   




