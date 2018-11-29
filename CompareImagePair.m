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


%%% If there are more than two axes selected, ignore 
if length(selectedaxes)>2
    selectedaxes = selectedaxes(1:2);
end

selectedaxes = flipud(selectedaxes);
imageserieslength = 2;

%%% You will be projecting two images to the main CaImageViewer window, so
%%% set the slider value to 2 so that they are scroll-able
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', imageserieslength);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(1/(imageserieslength-1)) (32/(imageserieslength-1))]);  %%% The Slider Step values indicate the minor and major transitions, which should be represented by the desired transition as the numerator and the length of the series as the denominator
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);

set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', '1');

%%% Pull images from selected axes
for i = 1:length(selectedaxes)
    im{i} = uint16(get(get(selectedaxes(i), 'Children'), 'CData'));
end
for i = 1:length(selectedaxes)
    date(i,1:6) = get(get(selectedaxes(i), 'Title'), 'String');
end
[~, ind] = sortrows(date); %% Sort images according to date
im = im(ind);
%%%%%%%%%%%%%%%%%%%%%%%
centeredimage = im{1};      %%% When initially drawing the ROIs, it makes sense to start with session 1 being the comparator. However...
mobileimage = im{2};        %%% When moving ROIs, you usually move session 1 ROIs to match the position of session 2, so for this purpose it usually makes sense for the mobile image to be from session 1 
%%%%%%%%%%%%%%%%%%%%%%%

alignchoice = get(findobj('Tag', 'Alignment_CheckBox'), 'Value');

if alignchoice 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %[RESULTS, WARP, WARPEDiMAGE] = ECC(IMAGE, TEMPLATE, LEVELS, NOI, TRANSFORM, DELTA_P_INIT)
    levels = 3;
    iterations = 25;
    delta_p_init = zeros(2,3); delta_p_init(1,1) = 1; delta_p_init(2,2) = 1;
    [~, ~, shiftedimage] = ecc(mobileimage, centeredimage,levels,iterations, 'affine', delta_p_init);
    
    %%% Calculate inverse warp matrix to match the opposite direction for
    %%% shifting ROIs
    ROIShift_centeredimage = im{2};
    ROIShift_mobileimage = im{1};
    [~, warpmatrix, ~] = ecc(ROIShift_mobileimage, ROIShift_centeredimage,levels,iterations, 'affine', delta_p_init);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
else
    shiftedimage = uint16(mobileimage);
end


figure('Name', 'Side-by-side Comparison','Position', [336,285,1217,522], 'NumberTitle', 'off');  
im1 = axes('Units', 'Normalized','Position', [0.05 0.05 0.4 0.9], 'XTick', [], 'YTick', []); 
imshow(centeredimage,[]); colormap(fire);
title('Image 1')
im2 = axes('Units', 'Normalized','Position', [0.55 0.05 0.4 0.9], 'XTick', [], 'YTick', []);
imshow(shiftedimage, []); colormap(fire);
title('Image 2')

figure('Name', 'Side-by-side Comparison','Position', [336,255,1217,522], 'NumberTitle', 'off');  
im3 = axes('Units', 'Normalized','Position', [0.05 0.05 0.4 0.9], 'XTick', [], 'YTick', []); 
imshow(im2double(mobileimage)/max(im2double(mobileimage(:)))-im2double(centeredimage)/max(im2double(centeredimage(:))),[]); 
title('Image difference pre-correction', 'Fontsize', 12)
im4 = axes('Units', 'Normalized','Position', [0.55 0.05 0.4 0.9], 'XTick', [], 'YTick', []); 
imshow(im2double(shiftedimage)/max(im2double(shiftedimage(:)))-im2double(centeredimage)/max(im2double(centeredimage(:))),[]);
title('Image difference post-correction', 'Fontsize', 12)

figure('Name', 'RGB Overlap','Position', [336,255,1217,522], 'NumberTitle', 'off');  
im1pre = im2double(centeredimage)/max(im2double(centeredimage(:)));
im1pre3 = zeros(size(centeredimage,1),size(centeredimage,1), 3);
im1pre3(1:end,1:end,1) = im1pre;
im2post = im2double(shiftedimage)/max(im2double(shiftedimage(:)));
im2post3 = zeros(size(centeredimage,1),size(centeredimage,1), 3);
im2post3(1:end,1:end,2) = im2post;
im5 = axes('Units', 'Normalized','XTick', [], 'YTick', []); 
imshow(im1pre3+im2post3)
title('Color-coded alignment', 'Fontsize', 12)
linkaxes([im1,im2,im3,im4,im5, gui_CaImageViewer.figure.handles.GreenGraph], 'xy')

placeimage{1} = centeredimage;
placeimage{2} = shiftedimage;

gui_CaImageViewer.GCaMP_Image = placeimage;

PlaceImages(shiftedimage, [], 'Slider')



gui_CaImageViewer.NewSpineAnalysisInfo.WarpMatrix = warpmatrix;


    %%%% Set up parameters in an accessible substructure within the main GUI
    selectedaxes = flipud(selectedaxes);
    for i = 1:length(selectedaxes)
        date(i,1:6) = get(get(selectedaxes(i), 'Title'), 'String');
    end
    
    [sorteddates, sort_index] = sortrows(date);
     
    gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', sorteddates(1,:), '\summed\'];

    [sorteddates, sort_index] = sortrows(date);
   
    gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal, '\', sorteddates(1,:), '\summed\'];

    gui_CaImageViewer.NewSpineAnalysis = 1;
    gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate = sorteddates(1,:);
    gui_CaImageViewer.NewSpineAnalysisInfo.MultipleDates = sorteddates;

    [sorteddates, sort_index] = sortrows(date);
   




