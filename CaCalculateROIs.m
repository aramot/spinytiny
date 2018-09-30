function CaCalculateROIs(~, eventData)

global gui_CaImageViewer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize: acquire values pertinent to the upcoming calculations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wb = waitbar(0, 'Finding & organizing ROIs...');
% steps  = 5;

Frame_num = str2num(get(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String'));

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

program = get(gcf);

running = program.FileName;
  
DendNum = gui_CaImageViewer.Dendrite_Number;

filterwindow = str2num(get(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String'));


if ispc
    save_directory = gui_CaImageViewer.save_directory;
else
    nameparts = regexp(gui_CaImageViewer.save_directory, filesep, 'split');
    linuxstarter = '/usr/local/lab/';
    save_directory = [filesep,nameparts{2}, filesep, nameparts{3}, filesep, nameparts{4}, filesep, nameparts{5}, filesep, nameparts{6}, filesep, nameparts{7},filesep, nameparts{8}, filesep, nameparts{9}, filesep, nameparts{10}, filesep];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Determine if ROIs have been drawn, and exist in the appropriate format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

if isfield (gui_CaImageViewer, 'ROI')
    if ~isempty(gui_CaImageViewer.ROI)
        for i = 1:length(gui_CaImageViewer.ROI)
            if ishandle(gui_CaImageViewer.ROI(i))
                existing_ROI{i} = get(gui_CaImageViewer.ROI(i));
            else
                error('No ROIs have been drawn, or they have been cleared. Redraw or recover');
            end
        end
    else
        error('No ROIs have been drawn');
    end
else
    error('No ROIs have been drawn');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Gather file information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fullfname = [save_directory, gui_CaImageViewer.filename];
pathname = save_directory;

ext = strfind(fullfname, '_summed_50.tif');
if ~isempty(ext)
    fullfname = fullfname(1:ext-1);
end
summed = strfind(pathname, 'summed');
if ~isempty(summed)
    pname = pathname(1:end-7);
else % Added for when the ROI is drawn on raw movies. Aki 171012
    pname = pathname;  
end

fname = regexp(fullfname, '\w+00[0]*\d+_\d+', 'match');
feat_sep = regexp(fname{1}, '_');           %%% File identifiers are separated by underscores
filegeneral = fname{1}(1:feat_sep(end-1)-1);
firstimfile = fname{1}(1:feat_sep(end)-1);    %%% Use the last underscore as an indicator of where the filename is separated for frame bin numbers (e.g. NH002(animal)_160316(date)_001(acquisition/experiment)_001(frame bin))
animal = regexp(fullfname, '[A-Z]{2,3}0*[0-9]*', 'match');
animal = animal{1};
fullfname = [pname,filegeneral];
numberofzerosusedinnaming = length(regexp(fname{1}(feat_sep(end):end), '0'));
CaImage_File_info = imfinfo([pname,firstimfile,'_',repmat('0', 1,numberofzerosusedinnaming),'1_corrected.tif']);

D = dir(pname);
if isempty(D)
    if strcmp(pname(end), filesep)
        newpname = pname(1:end-1);
    end
    D = dir(newpname);
end

timecourse_image_number = 0;
acquisition_step = [];
frame_bin_count = [];
for i = 1:length(D)
    if ~isempty(strfind(D(i).name, 'corrected.tif'))
        timecourse_image_number = timecourse_image_number + 1;
        feat_step = regexp(D(i).name, '_');
        acquisition_step = [acquisition_step; D(i).name(feat_step(2)+1:feat_step(3)-1)];
        frame_bin_count = [frame_bin_count; D(i).name(feat_step(3)+1:feat_step(4)-1)];
    else
    end
end
steps = timecourse_image_number*length(CaImage_File_info);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If more than one dendrite is analyzed, break up spines accordingly %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DendNum > 1
    prompt = cell(1,DendNum);
    for i = 1:length(prompt)
        prompt{i} = ['Spines on dendrite ', num2str(i)];
    end
    name = 'Spine Grouping';
    numlines = 1;
    defaultanswer = cell(1,DendNum);
    for i = 1:length(defaultanswer)
        if ~isempty(gui_CaImageViewer.SpineDendriteGrouping)
            first = min(gui_CaImageViewer.SpineDendriteGrouping{i});
            last = max(gui_CaImageViewer.SpineDendriteGrouping{i});
            defaultanswer{i} = sprintf('%d:%d', first, last);
        else
            defaultanswer{i} = '';
        end
    end
    s_d_grouping = inputdlg(prompt, name, numlines, defaultanswer);
    for i = 1:DendNum
        DendSpines{i} = str2num(s_d_grouping{i});
    end
else 
    DendSpines{1} = 1:length(existing_ROI)-1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(existing_ROI{1})
    error('Draw ROI0')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Initialize variables (for speed) %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% ROIs
ROI_stamp = cell(1,length(existing_ROI));
% ROI_pos = cell(1,length(existing_ROI));
% x_r = cell(1,length(existing_ROI));
% y_r = cell(1,length(existing_ROI));
% x_c = cell(1,length(existing_ROI));
% y_c = cell(1,length(existing_ROI));
x1 = cell(1,length(existing_ROI));
y1 = cell(1,length(existing_ROI));
ROIreg = cell(1,length(existing_ROI));

%%% PolyROIs
PolyROI_pos = cell(1,length(gui_CaImageViewer.PolyROI));
% Polyx_r = cell(1,length(gui_CaImageViewer.PolyROI));
% Polyy_r = cell(1,length(gui_CaImageViewer.PolyROI));
Polyx_c = cell(1,length(gui_CaImageViewer.PolyROI));
Polyy_c = cell(1,length(gui_CaImageViewer.PolyROI));
% Polyx1 = cell(1,length(gui_CaImageViewer.PolyROI));
% Polyy1 = cell(1,length(gui_CaImageViewer.PolyROI));
PolyROIreg = cell(1,length(gui_CaImageViewer.PolyROI));

% xsize = size(gui_CaImageViewer.GCaMP_Image{1},1);
xsize = size(gui_CaImageViewer.ch1image,1);
ysize = size(gui_CaImageViewer.ch1image,2);

islong = gui_CaImageViewer.figure.handles.Longitudinal_CheckBox.Value;
newspineanalysis = gui_CaImageViewer.NewSpineAnalysis;

if newspineanalysis || islong
    terminus = regexp(save_directory, animal, 'end');
    targ_folder = save_directory(1:terminus);
    currentfield = gui_CaImageViewer.NewSpineAnalysisInfo.CurrentImagingField;
    if isempty(currentfield)
        cf = inputdlg('No field number found; Enter field number:', '1', 1);
        currentfield = str2num(cf{1});
        gui_CaImageViewer.NewSpineAnalysisInfo.CurrentImagingField = currentfield; 
    end
    drawer = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');
    if ~isempty(drawer)
        userspecificpart = [drawer,'_'];
    else
        userspecificpart = [];
    end
    load([targ_folder, filesep,userspecificpart,'Imaging Field ', num2str(currentfield), ' Spine Registry'])
    if isempty(gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate)
        date = regexp(save_directory, '[0-9]{6}', 'match'); date = date{1};
    else
        date = gui_CaImageViewer.NewSpineAnalysisInfo.CurrentDate;
    end
    instanceofappearance = logical(strcmpi(SpineRegistry.DatesAcquired, date));
    SpineList = SpineRegistry.Data(:,instanceofappearance); %%% Note: Although the first ROI is always ROI0 (background), this is excluded (wrt indexing) for the final variables, so a direct translation of spine number is possible here
    nullspines = find(SpineList==0);
        Fluorescence_Intensity = cell(length(SpineList),1);
        Total_Intensity = cell(length(SpineList),1);
        Pixel_Number = cell(length(SpineList),1);
        Fluorescence_Measurement = cell(length(SpineList),1);
        Surround_Measurement = cell(length(SpineList),1);
else
    Fluorescence_Intensity = cell(length(gui_CaImageViewer.ROI)-1,1);
    Total_Intensity = cell(length(gui_CaImageViewer.ROI)-1,1);
    Pixel_Number = cell(length(gui_CaImageViewer.ROI)-1,1);
    Fluorescence_Measurement = cell(length(gui_CaImageViewer.ROI)-1,1);
    Surround_Measurement = cell(length(gui_CaImageViewer.ROI)-1,1);
    SpineList = ones(length(existing_ROI),1);
end

Poly_Fluorescence_Intensity = cell(length(gui_CaImageViewer.PolyROI),1);
Poly_Total_Intensity = cell(length(gui_CaImageViewer.PolyROI),1);
Poly_Pixel_Number = cell(length(gui_CaImageViewer.PolyROI),1);
Poly_Fluorescence_Measurement= cell(length(gui_CaImageViewer.PolyROI),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Create ROI masks %%%

waitbar(1/steps, wb, 'Creating ROI masks...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Define primary ROIs %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allROIobjects = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}));

for i = 1:length(existing_ROI)
%     ROI_stamp{i} = get(gui_CaImageViewer.ROI(i), 'Position');    %%%%% Same as ROI_pos, but used this for consistency between programs...
%     ROI_pos{i} = ROI_stamp{i};                                   %%%%% Returns coordinate position of ROI with format [x y w h]
%     x_r{i} = ROI_pos{i}(3)/2;                                    %%%%% x radius being w/2
%     y_r{i} = ROI_pos{i}(4)/2;                                    %%%%% y radius being y/2
%     x_c{i} = ROI_pos{i}(1)+ROI_pos{i}(3)/2;                      %%%%% x center being the x coordinate (bottom left corner) + the radius of the ROI (finds the center)
%     y_c{i} = ROI_pos{i}(2)+ROI_pos{i}(4)/2;                      %%%%% y center being the y coordinate (bottom left corner) + the radius of the ROI (finds the center)
%     theta = (0:1/20:1)*2*pi;
%     x1{i} = round(sqrt(x_r{i}^2*y_r{i}^2./(x_r{i}^2*sin(theta).^2 + y_r{i}^2*cos(theta).^2)).*cos(theta) + x_c{i});    %%%%% Derives from the formula for an ellipse, wherein X(theta) = a * cos(theta)  
%     y1{i} = round(sqrt(x_r{i}^2*y_r{i}^2./(x_r{i}^2*sin(theta).^2 + y_r{i}^2*cos(theta).^2)).*sin(theta) + y_c{i});    %%%%% Derives from the formula for an ellipse, wherein Y(theta) = b * sin(theta)
%     ROImask{i} = roipoly(xsize,ysize, x1{i}, y1{i});
    ROImask{i} = createMask(allROIobjects(i), gui_CaImageViewer.GCaMP_Image{1});    %%% Create a mask based on the elliptical features of the drawn ROI and size of the first image
    ROIreg{i} = find(ROImask{i}(:));
    if gui_CaImageViewer.UsingSurroundBackground
        if i > 1
            if ~isnan(gui_CaImageViewer.BackgroundROI(i))
                BG_surround_stamp{i} = get(gui_CaImageViewer.BackgroundROI(i), 'Position');
                bgx_r{i} = BG_surround_stamp{i}(3)/2;
                bgy_r{i} = BG_surround_stamp{i}(4)/2;
                bgx_c{i} = BG_surround_stamp{i}(1)+BG_surround_stamp{i}(3)/2;
                bgy_c{i} = BG_surround_stamp{i}(2)+BG_surround_stamp{i}(4)/2;
                bgx1{i} = round(sqrt(bgx_r{i}^2*bgy_r{i}^2./(bgx_r{i}^2*sin(theta).^2 + bgy_r{i}^2*cos(theta).^2)).*cos(theta) + bgx_c{i});    %%%%% Derives from the formula for an ellipse, wherein X(theta) = a * cos(theta)  
                bgy1{i} = round(sqrt(bgx_r{i}^2*bgy_r{i}^2./(bgx_r{i}^2*sin(theta).^2 + bgy_r{i}^2*cos(theta).^2)).*sin(theta) + bgy_c{i});    %%%%% Derives from the formula for an ellipse, wherein Y(theta) = b * sin(theta)
                BGmask{i} = roipoly(xsize, ysize, bgx1{i},bgy1{i})-roipoly(xsize,ysize, x1{i}, y1{i});
                BGreg{i} = find(BGmask{i}(:));
            else
                BGreg{i} = [];
            end
        else
            BGreg{i} = [];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Define Dendrite ROIs %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pix_per_micronat20x = 10.666;
zoom = get(gui_CaImageViewer.figure.handles.Zoom_EditableText, 'String');
zoom = str2num(zoom);
pixpermic = pix_per_micronat20x*zoom/20;

waitbar(2/steps, wb, 'Locating dendrite ROIs...');

allDendriticROIObjects = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', '-and', {'-regexp', 'Tag', 'Dendrite'}));

if isfield(gui_CaImageViewer, 'PolyROI')
    DendROIs = findobj('-regexp', 'Tag', 'Dendrite \d');
    DendROIs = get(DendROIs, 'Tag');
        for i = 1:DendNum
            counter = 1;
            for j = 1:length(DendROIs)
                dendrites = regexp(DendROIs(j), ['Dendrite ', num2str(i)]);
                if ~isempty(dendrites{1})
                    Group{i}{counter} = DendROIs(j);
                    counter = counter+1;
                end
            end
        end

    DendPPNum= gui_CaImageViewer.DendritePolyPointNumber;

    CummulativeDist = 0; %%% Build the length of dendrite
    for i = 1:length(gui_CaImageViewer.PolyROI)
        if ishandle(gui_CaImageViewer.PolyROI{i})
%             PolyROI_pos{i} = gui_CaImageViewer.PolyLinePos{i};
%             Polyx_r{i} = PolyROI_pos{i}(3)/2;                                %%%%% x radius being w/2
%             Polyy_r{i} = PolyROI_pos{i}(4)/2;                                %%%%% y radius being y/2
%             Polyx_c{i} = PolyROI_pos{i}(1)+PolyROI_pos{i}(3)/2;              %%%%% x center being the x coordinate + the width of the ROI (going from edge to edge)
%             Polyy_c{i} = PolyROI_pos{i}(2)+PolyROI_pos{i}(4)/2;              %%%%% y center being the y coordinate + the width of the ROI (going from edge to edge)
                Polyx_c{i} = allDendriticROIObjects(i).Center(1);
                Polyy_c{i} = allDendriticROIObjects(i).Center(2);
%             Polytheta = (0:1/20:1)*2*pi;
%             Polyx1{i} = round(sqrt(Polyx_r{i}^2*Polyy_r{i}^2./(Polyx_r{i}^2*sin(theta).^2 + Polyy_r{i}^2*cos(theta).^2)).*cos(theta) + Polyx_c{i});    %%%%% Derives from the formula for an ellipse, wherein X(theta) = a * cos(theta)  
%             Polyy1{i} = round(sqrt(Polyx_r{i}^2*Polyy_r{i}^2./(Polyx_r{i}^2*sin(theta).^2 + Polyy_r{i}^2*cos(theta).^2)).*sin(theta) + Polyy_c{i});    %%%%% Derives from the formula for an ellipse, wherein Y(theta) = b * sin(theta)
%             PolyROImask{i} = roipoly(xsize,ysize, Polyx1{i}, Polyy1{i});
            PolyROImask{i} = createMask(allDendriticROIObjects(i), gui_CaImageViewer.GCaMP_Image{1});
            if i == 1
                Pix_Dist{i} = 0;
                Mic_Dist{i} = 0;
            else
                Pix_Dist{i} = sqrt((Polyx_c{i}-Polyx_c{i-1}).^2 + (Polyy_c{i}-Polyy_c{i-1}).^2);
                Mic_Dist{i} = Pix_Dist{i}/pixpermic;
            end
            PolyROIreg{i} = find(PolyROImask{i}(:));
            CummulativeDist = CummulativeDist+Mic_Dist{i};
            Poly_Dist{i} = CummulativeDist;
        end
    end
end

    default_upper = str2num(get(gui_CaImageViewer.figure.handles.UpperLUT_EditableText, 'String'));
    default_lower = str2num(get(gui_CaImageViewer.figure.handles.LowerLUT_EditableText, 'String'));

    waitbar(3/steps, wb, 'Caclulating raw fluorescence values...');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Calculate all ROI values %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~isempty(gui_CaImageViewer.SelectedStopFrame)
        imseriesend = gui_CaImageViewer.SelectedStopFrame;
    else
        imseriesend = inf;
    end

    if ~isempty(gui_CaImageViewer.IgnoreFrames)
        flagframes = gui_CaImageViewer.IgnoreFrames;
    else
        flagframes = [];
    end

        actual_image_counter = 1;
        I_handles = [];
        for i = 1:length(gui_CaImageViewer.PolyROI)
            if ishandle(gui_CaImageViewer.PolyROI{i})
                I_handles(end+1) = i;
            end
        end
        for j = 1:timecourse_image_number
            if actual_image_counter>=imseriesend
                break
            end
            imnum = frame_bin_count(j,:);
            filepattern = [fullfname, '_',acquisition_step(j,:),'_',imnum, '_corrected.tif'];
            if j == 1 || j ==2 || j == timecourse_image_number || ismember(j,find(diff(acquisition_step(:,end)))) %%% Length of each file assumed to be constant UNLESS it's the start of a new acquisition (or in some cases the second image, since the first one is sometimes overwritten)
                CaImage_File_info = imfinfo(filepattern);
            else
            end
            all_images = read_tiff(filepattern,CaImage_File_info);

            for k = 1:length(CaImage_File_info)

                if any(actual_image_counter == flagframes)
                    Background_Mean_Int = NaN;
                    for i = 2:length(existing_ROI)
                        Fluorescence_Measurement{i-1}(1,actual_image_counter) = NaN;
                    end
                    for i = I_handles
                        Poly_Fluorescence_Measurement{i}(1,actual_image_counter) = NaN;
                    end
                    for i = 1:DendNum
                        if i == 1
                            dendgroup = 1:DendPPNum(1,i);
                        else
                            dendgroup = (DendPPNum(1,i-1)+1):(DendPPNum(1,i-1)+DendPPNum(1,i));
                        end
                        Mean_Dend(i,actual_image_counter) = NaN;
                    end
                    actual_image_counter = actual_image_counter+1;
                    continue
                end
                current_image = all_images(:,:,k);
                isNaNPossible = isa(current_image,'float');

                Background_Intensity = current_image(ROIreg{1}); %%% Assumes that the first ROI (actually labeled 'ROI 0') is the background
                if(isNaNPossible);Background_Intensity = Background_Intensity(~isnan(Background_Intensity));end
                Total_Background_Intensity = sum(Background_Intensity(:));
                Background_Pixel_num = Total_Background_Intensity/nanmean(Background_Intensity(:));
                Background_Mean_Int = nanmean(Background_Intensity(:));

                if twochannels == 1
                    Background_Red = current_image(ROIreg{1},2);
                    Total_Background_Red = sum(Background_Red(:));
                    Background_Mean_Red = nanmean(Background_Red(:));
                end

                %%% 

                for i = 2:length(existing_ROI) %%% Should cover all spines...
                    Fluorescence_Intensity{i-1} = current_image(ROIreg{i});
                    if(isNaNPossible);Fluorescence_Intensity{i-1} = Fluorescence_Intensity{i-1}(~isnan(Fluorescence_Intensity{i-1}));end
                    Total_Intensity{i-1} = sum(Fluorescence_Intensity{i-1}(:));
                    if(isNaNPossible);Fluorescence_Intensity{i-1}(isnan(Fluorescence_Intensity{i-1})) = 0;end
                    tmp_mean_intensity = sloppy_mean(Fluorescence_Intensity{i-1}(:));
                    Pixel_Number{i-1} = Total_Intensity{i-1}/tmp_mean_intensity;
                    if gui_CaImageViewer.UsingSurroundBackground
                        if ~isempty(BGreg{i})
                            Surround_Intensity = current_image(BGreg{i});
                            Total_Surround_Intensity{i-1} = sum(Surround_Intensity);
                            tmp_surround_intensity = sloppy_mean(Surround_Intensity(:));
                            Surround_Pixel = Total_Surround_Intensity{i-1}/tmp_surround_intensity;
                            Surround_Measurement{i-1}(1,actual_image_counter) = (tmp_surround_intensity-Background_Mean_Int)*Surround_Pixel;
                            Fluorescence_Measurement{i-1}(1,actual_image_counter) = ((tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{i-1})-Surround_Measurement{i-1}(1,actual_image_counter);
                        else
                            Fluorescence_Measurement{i-1}(1,actual_image_counter) = (tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{i-1};
                        end
                    else
                        Fluorescence_Measurement{i-1}(1,actual_image_counter) = (tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{i-1};
                    end
                    if twochannels == 1
                        Red_Intensity{i-1} = current_image(ROIreg{i},2);
                        Total_Red_Intensity{i-1} = sum(Red_Intensity{i-1}(:));
                        Red_Measurement{i-1}(1,actual_image_counter) = (nanmean(Red_Intensity{i-1}(:))-Background_Mean_Red)*Pixel_Number{i-1};
                    end
                end

                if isfield(gui_CaImageViewer, 'PolyROI')
                    for i = I_handles
                        Poly_Fluorescence_Intensity{i} = current_image(PolyROIreg{i});
                        if(isNaNPossible);Poly_Fluorescence_Intensity{i} = Poly_Fluorescence_Intensity{i}(~isnan(Poly_Fluorescence_Intensity{i}));end
                        Poly_Total_Intensity{i} = sum(Poly_Fluorescence_Intensity{i}(:));
                        if(isNaNPossible);Poly_Fluorescence_Intensity{i}(isnan(Poly_Fluorescence_Intensity{i}(:))) = 0;end
                        tmp_mean_intensity = sloppy_mean(Poly_Fluorescence_Intensity{i}(:));
                        Poly_Pixel_Number{i} = Poly_Total_Intensity{i}/tmp_mean_intensity;
                        Poly_Fluorescence_Measurement{i}(1,actual_image_counter) = (tmp_mean_intensity-Background_Mean_Int)*Poly_Pixel_Number{i};
                        PolyFMat(i,actual_image_counter) = Poly_Fluorescence_Measurement{i}(1,actual_image_counter);
                        if twochannels == 1
                            Poly_Red_Intensity{i} = current_image(PolyROIreg{i},2);
                            Poly_Red_Measurement{i}(1,actual_image_counter) = (nanmean(Poly_Red_Intensity{i}(:))-Background_Mean_Red)*Poly_Pixel_Number{i};
                            Poly_Total_Red_Intensity{i} = sum(Poly_Red_Intensity{i}(:));
                        end
                    end
                end
                for i = 1:DendNum
                    if i == 1
                        dendgroup = 1:DendPPNum(1,i);
                    else
                        dendgroup = (DendPPNum(1,i-1)+1):(DendPPNum(1,i-1)+DendPPNum(1,i));
                    end
                    Mean_Dend(i,actual_image_counter) = nanmean(PolyFMat(dendgroup,actual_image_counter),1);
                end
                actual_image_counter = actual_image_counter + 1;
                if(mod(actual_image_counter,20)==0)
                    waitbar(actual_image_counter/steps, wb, ['Processing image ', num2str(actual_image_counter)])
                end
            end
        end
        Time = 1:actual_image_counter-1;
        gui_CaImageViewer.imageserieslength = actual_image_counter-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For new spine analysis, ROI number must be kept constant; if there are
%%% ROIs that appear one one day and not another, populate that ROIs cell
%%% with NaNs the length of the imaging time course

if newspineanalysis || islong
    experimentlength = length(Fluorescence_Measurement{1});
    nullspinedata = nan(1,experimentlength);
    insert = mat2cell(repmat(nullspinedata,length(nullspines),1),ones(length(nullspines),1),experimentlength);
    Fluorescence_Intensity(nullspines) = insert;
    Total_Intensity(nullspines) = insert;
    Pixel_Number(nullspines) = insert;
    Fluorescence_Measurement(nullspines) = insert;    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Define Baseline %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bl = 'All';     %%% If you want a different baseline, indicate here

if twochannels == 1
    baselineFrames = [];
else
    if strcmpi(bl, 'All')
        bl = 1:actual_image_counter -1;
    else
        bl = str2num(bl);
    end
    baselineFrames = bl;
end

a.BaselineFrames = bl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Find baselines %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbar((steps-4)/steps, wb, 'Calculating baselines...');

spine_baseline = zeros(1,length(Fluorescence_Measurement));

for i = 1:length(Fluorescence_Measurement)
    roundstodo = 10;
    thisround = 1;
    trace = Fluorescence_Measurement{i};
    med = median(trace);
    spread = std(trace);
    while thisround<roundstodo
        trace(trace>med+3*spread) = med+3*spread;
        trace(trace<med-3*spread) = med-3*spread;
        thisround = thisround+1;
    end        
    spine_baseline(1,i) = median(trace);
end

dend_baseline(1,i) = zeros(1,DendNum);
  
for i = 1:DendNum
    roundstodo = 10;
    thisround = 1;
    trace = Mean_Dend(i,:);
    med = median(trace);
    spread = std(trace);
    while thisround<roundstodo
        trace(trace>med+3*spread) = med+3*spread;
        trace(trace<med-3*spread) = med-3*spread;
        thisround = thisround+1;
    end        
    dend_baseline(1,i) = median(trace);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Delta Values %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

deltaF = cell(1,length(Fluorescence_Measurement));
deltaDend = nan(DendNum, length(Mean_Dend));
dF_over_F = cell(1,length(Fluorescence_Measurement));

for i = 1:length(existing_ROI)-1
    deltaF{i} = Fluorescence_Measurement{i}-spine_baseline(1,i);
    for j = 1:DendNum
        deltaDend(j,:) = (Mean_Dend(j,:)-dend_baseline(1,j))/dend_baseline(1,j);
    end
    if twochannels == 1
        deltaR{i} = Red_Measurement{i} / nanmean(Red_Measurement{i}(baselineFrames));
        dF_over_F{i} = (deltaF{i}./deltaR{i})/(nanmean(Fluorescence_Measurement{i}(baselineFrames))./nanmean(Red_Measurement{i}(baselineFrames)));
    else
        dF_over_F{i} = deltaF{i}/spine_baseline(1,i);
    end
end

if ~isfield(gui_CaImageViewer, 'PolyLine')
    gui_CaImageViewer.PolyLine = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zoomval = str2num(get(gui_CaImageViewer.figure.handles.Zoom_EditableText, 'String'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Save %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fullfname = gui_CaImageViewer.filename;

a.deltaF = deltaF;
a.dF_over_F = dF_over_F;
a.Time = Time;
a.Fluorescence_Intensity = Fluorescence_Intensity;
a.Total_Intensity = Total_Intensity;
a.Pixel_Number = Pixel_Number;
a.Fluorescence_Measurement = Fluorescence_Measurement;
a.Filename = fullfname;
% a.Poly_deltaF = Poly_deltaF;
% a.Poly_dF_over_F = Poly_dF_over_F;
a.Poly_Fluorescence_Intensity = Poly_Fluorescence_Intensity;
a.Poly_Total_Intensity = Poly_Total_Intensity;
a.Poly_Pixel_Number = Poly_Pixel_Number;
a.Poly_Fluorescence_Measurement = Poly_Fluorescence_Measurement;
a.Dendrite_Fluorescence_Measurement = Mean_Dend;
a.Dendrite_dFoF = deltaDend;
a.ZoomValue = zoomval;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a.IsLongitudinal = islong;

%%% for restoring ROIs
try
    a.SpineROIs = gui_CaImageViewer.ROI;
    a.SpineROItext = gui_CaImageViewer.ROItext;
    a.PolyROI = gui_CaImageViewer.PolyROI;
    a.PolyLines = gui_CaImageViewer.PolyLine;
    a.PolyLinePos = gui_CaImageViewer.PolyLinePos;
    a.PolyLineVertices = gui_CaImageViewer.PolyLineVertices;
    a.NumberofDendrites = DendNum;
    a.NumberofSpines = gui_CaImageViewer.Spine_Number;
    a.DendritePolyPointNumber = DendPPNum;
    a.SpineDendriteGrouping = DendSpines;
    a.ROIPosition = ROI_stamp;
    a.PolyLinePosition = PolyROI_pos;
    a.PolyLineDistances = Poly_Dist;
catch
    disp(['Could not save all ROIs during analysis. Make sure you''ve saved them before you clear them!'])
end

if twochannels == 1
    a.Red_Intensity = Red_Intensity;
    a.Total_Red_Intensity = Total_Red_Intensity;
    a.Red_Measurement = Red_Measurement;
    a.Poly_Red_Intensity = Poly_Red_Intensity;
    a.Poly_Total_Red_Intensity = Poly_Total_Red_Intensity;
    a.Poly_Red_Measurement = Poly_Red_Measurement;
end

user = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');

if gui_CaImageViewer.NewSpineAnalysis 
    analysis_tidbits = '_Longitudinal_Analyzed_By';
else
    analysis_tidbits = '_Analyzed_By';
end

try
    fullfname = fullfname(1:length(fullfname)-4);
    save_fname = [fullfname, analysis_tidbits , user];
    evalc([save_fname, '= a']);
    start_dir = cd;
    target_dir = save_directory;
    cd(target_dir);
    save(save_fname, save_fname);
catch
    fullfname = altname;
    save_fname = [fullfname, analysis_tidbits, user];
    evalc([save_fname, '= a']);
    start_dir = cd;
    target_dir = save_directory;
    cd(target_dir);
    save(save_fname, save_fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitbar((steps-5)/steps, wb, 'Generating plots...');

%%%%%%%%%%%%%%%%%%%%%%
%%Color Information%%%
%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    red = [0.93 0.11 0.14];     black = [0 0 0];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,magenta,orange,brown,lbrown};

%%% Figure 1: dF/F0 of spines and their respective dendrites

close(wb);
    
timecourse_h = figure;
hold on;

numsub = ceil(sqrt(length(existing_ROI)));

sub1 = numsub;
sub2 = numsub;

for i = 1:length(existing_ROI)-1
    subplot(sub1,sub2,i)
    onDend = 1;
    for j = 1:DendNum
        if ~isempty(find(DendSpines{j} == i))   
            plot(Time, deltaDend(j,:), 'k', 'LineWidth', 2); hold on;
            onDend = j;
        else
        end
    end
    col1 = mod(i-1, length(colorj))+1;
    trace_fig = plot(Time, dF_over_F{i}, 'color', colorj{col1}, 'LineWidth', 2); hold on;
    k = zeros(1,length(Time));
    plot(Time,k, '--k')
    xlabel('Time(sec)');
    ylabel('\DeltaF');
    xlim([0 length(Time)]);
    forleg{i} = ['Spine # ', num2str(i), ' on dend ', num2str(onDend)];
    title(['Spine # ', num2str(i), ' on dend. ', num2str(onDend)]);
end

scrsz = get(0, 'ScreenSize');
set(timecourse_h, 'Position', [0, scrsz(2), scrsz(3)/2, scrsz(4)]);

if twochannels == 1
    uncaging_times = [0:2:58];
    Pulse_mark_max = max(get(trace_fig, 'YData'));
    Pulse_mark_min = min(get(trace_fig, 'Ydata'));

    for i = 1:length(uncaging_times)
        line([uncaging_times(i), uncaging_times(i)], [Pulse_mark_min, Pulse_mark_max], 'linewidth', 0.5, 'Color', 'black')
    end
end

function y = sloppy_mean(x,dim)

    if(nargin<2)  % from official mean of Matlab R2014a
        % preserve backward compatibility with 0x0 empty
        if isequal(x,[])
            y = sum(x,flag)/0;
            return
        end
        dim = find(size(x)~=1,1);
        if isempty(dim), dim = 1; end
    end
    y = sum(x,dim)/size(x,dim);

function temp_fn = tempname_if_on_network(fn)
    persistent isNetworkDrive isNetworkDriveBackup
    
    
    switch(fn)
        case 'on'
            isNetworkDrive=isNetworkDriveBackup;
        case 'off'
            isNetworkDrive = false;
        otherwise 
            if(islogical(isNetworkDrive)&&~isNetworkDrive)
                temp_fn=[];
                return;
            end
            temp_fn = '';
            if(isunix && ~ismac)
                temp_fn = tempname('/dev/shm/');
            elseif(ispc)
                if(isempty(isNetworkDrive))
                    isNetworkDrive = containers.Map('KeyType','char','ValueType','logical');
                    drives = java.io.File('').listRoots();
                    for i=1:numel(drives)
                        isNetworkDrive(char(drives(i))) = ...
                           strcmp('Network Drive',char(javax.swing.filechooser.FileSystemView.getFileSystemView().getSystemTypeDescription(drives(i)))); 
                    end
                    isNetworkDriveBackup=isNetworkDrive;
                end
                ffn = upper(char(java.io.File(fn).getAbsoluteFile()));
                if(length(ffn)>2 && (strcmp(ffn(1:2),'\\') || isNetworkDrive.isKey(ffn(1:3)) && isNetworkDrive(ffn(1:3))))
                    temp_fn = tempname;
                end
            end
    end
    
function [stack,info] = read_tiff(fn,info_all)

    if(nargin<1)
        [filename, pathname]=uigetfile({'*.tiff;*.tif','Tiff Files(*.tiff, *.tif)'},'Select Tiff file');
        fn = fullfile(pathname,filename);
    end
    
    ch=1;
    n_ch=1;
    
    if(nargin<2)
        info_all=[];
    end
    
    temp_fn = tempname_if_on_network(fn);
    if(~isempty(temp_fn))
        copyfile(fn,temp_fn);
        file_to_read = temp_fn;
        file_to_delete = temp_fn;
    else
        file_to_read = fn;
        file_to_delete = '';
    end
    
    try
        if(isempty(info_all))
            info_all = imfinfo(file_to_read);
        end

        last_frame = floor(length(info_all)/n_ch)*n_ch;
        if(last_frame ~= length(info_all))
            warning('Total frames are not a multiple of n_ch.');
        end
        load_frames = bsxfun(@plus,ch(:),0:n_ch:last_frame-1);

        if(isempty(load_frames))
            warning('No frame to read');
            stack=[];
            info = info_all([]);
            frame_tag = [];
        else
            info=info_all(load_frames(1,:));
            
            first_frame = imread(file_to_read,'tiff','index',load_frames(1));
            stack = zeros(size(first_frame,1),size(first_frame,2),size(load_frames,2),size(load_frames,1),class(first_frame));
            i_frame=1;i_ch=1;
            if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                    && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                stack(:,:,i_frame,i_ch)=first_frame;
            else
                stack(:,:,i_frame,i_ch)=NaN;
            end
            for i_ch=2:size(load_frames,1)
                if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                        && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                    stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
                else
                    stack(:,:,i_frame,i_ch)=NaN;
                end
            end
            for i_frame = 2:size(load_frames,2)
                for i_ch=1:size(load_frames,1)
                    if(info_all(load_frames(i_ch,i_frame)).Width == size(first_frame,2) ...
                            && info_all(load_frames(i_ch,i_frame)).Height == size(first_frame,1))
                        stack(:,:,i_frame,i_ch) = imread(file_to_read,'tiff','index',load_frames(i_ch,i_frame));
                    else
                        stack(:,:,i_frame,i_ch)=NaN;
                    end
                end
            end
        end
        if(~isempty(file_to_delete))
            delete(file_to_delete);
        end
    catch e
        if(~isempty(file_to_delete))
            delete(file_to_delete);
        end
        rethrow(e)
    end