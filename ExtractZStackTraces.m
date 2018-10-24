function CaCalculateROIs(~, eventData)

global gui_CaImageViewer
global zStack_Interface

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize: acquire values pertinent to the upcoming calculations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wb = waitbar(0, 'Finding & organizing ROIs...');
% steps  = 5;

twochannels = get(gui_CaImageViewer.figure.handles.TwoChannels_CheckBox, 'Value');

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
        allROItypes = [gui_CaImageViewer.ROI,gui_CaImageViewer.ROIother];
        for i = 1:length(allROItypes)
            if ishandle(allROItypes)
                existing_ROI{i} = get(allROItypes(i));
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

[fname, pname] = uigetfile('.tif', 'Select First File in Time Series');
feat_sep = regexp(fname, '_');           %%% File identifiers are separated by underscores
filegeneral = fname(1:feat_sep(end-1)-1);
firstimfile = fname(1:feat_sep(end)-1);    %%% Use the last underscore as an indicator of where the filename is separated for frame bin numbers (e.g. NH002(animal)_160316(date)_001(acquisition/experiment)_001(frame bin))
animal = regexp(fullfname, '[A-Z]{2,3}0*[0-9]*', 'match');
animal = animal{1};
fullfname = [pname,filegeneral];
numberofzerosusedinnaming = length(regexp(fname(feat_sep(end):end), '0'));
CaImage_File_info = imfinfo([pname,firstimfile,'_',repmat('0', 1,numberofzerosusedinnaming),'1.tif']);

D = fastdir(cd, filegeneral);

timecourse_image_number = 0;
acquisition_step = [];
frame_bin_count = [];
for i = 1:length(D)
    timecourse_image_number = timecourse_image_number + 1;
    feat_step = regexp(D{i}, '_');
    acquisition_step = [acquisition_step; D{i}(feat_step(end-1)+1:feat_step(end)-1)];
    frame_bin_count = [frame_bin_count; D{i}(feat_step(end)+1:end-4)];
end
steps = timecourse_image_number*length(CaImage_File_info);


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
ROImask = cell(1,length(existing_ROI));
ROIreg = cell(1,length(existing_ROI));


% xsize = size(gui_CaImageViewer.GCaMP_Image{1},1);
xsize = size(gui_CaImageViewer.ch1image,1);
ysize = size(gui_CaImageViewer.ch1image,2);

islong = gui_CaImageViewer.figure.handles.Longitudinal_CheckBox.Value;
newspineanalysis = gui_CaImageViewer.NewSpineAnalysis;


Fluorescence_Intensity = cell(length(existing_ROI)-1,1);
Total_Intensity = cell(length(existing_ROI)-1,1);
Pixel_Number = cell(length(existing_ROI)-1,1);
Fluorescence_Measurement = cell(length(existing_ROI)-1,1);
Surround_Measurement = cell(length(existing_ROI)-1,1);
SpineList = ones(length(existing_ROI)-1,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Create ROI masks %%%

waitbar(1/steps, wb, 'Creating ROI masks...');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Define primary ROIs %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allROIobjects = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi'));

for i = 1:length(existing_ROI)
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

pix_per_micronat20x = 4.65;
zoom = get(gui_CaImageViewer.figure.handles.Zoom_EditableText, 'String');
zoom = str2num(zoom);
pixpermic = pix_per_micronat20x*zoom/20;


default_upper = str2num(get(gui_CaImageViewer.figure.handles.UpperLUT_EditableText, 'String'));
default_lower = str2num(get(gui_CaImageViewer.figure.handles.LowerLUT_EditableText, 'String'));

waitbar(3/steps, wb, 'Caclulating raw fluorescence values...');

ROISliceAssignment = zStack_Interface.ROITable.Data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate all ROI values %%%
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
    filepattern = [fullfname, '_',acquisition_step(j,:),'_',imnum, '.tif'];
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
        %%% Find ROIs that were drawn in the current slice
        numslices = str2num(zStack_Interface.SlicesEdit.String);
        currentslice = mod(actual_image_counter,numslices);
        if currentslice == 0
            currentslice = numslices;
        end
        ROIsinthisSlice = find(ROISliceAssignment(:,2) == currentslice);
        sliceframe = ceil(actual_image_counter/numslices);
        
        for i = 1:length(ROIsinthisSlice) %%% Should cover all spines...
            Fluorescence_Intensity{ROIsinthisSlice(i)} = current_image(ROIreg{ROIsinthisSlice(i)+1});
            if(isNaNPossible);Fluorescence_Intensity{ROIsinthisSlice(i)} = Fluorescence_Intensity{ROIsinthisSlice(i)}(~isnan(Fluorescence_Intensity{ROIsinthisSlice(i)}));end
            Total_Intensity{ROIsinthisSlice(i)} = sum(Fluorescence_Intensity{ROIsinthisSlice(i)}(:));
            if(isNaNPossible);Fluorescence_Intensity{ROIsinthisSlice(i)}(isnan(Fluorescence_Intensity{ROIsinthisSlice(i)})) = 0;end
            tmp_mean_intensity = sloppy_mean(Fluorescence_Intensity{ROIsinthisSlice(i)}(:));
            Pixel_Number{ROIsinthisSlice(i)} = Total_Intensity{ROIsinthisSlice(i)}/tmp_mean_intensity;
            if gui_CaImageViewer.UsingSurroundBackground
                if ~isempty(BGreg{i})
                    Surround_Intensity = current_image(BGreg{i});
                    Total_Surround_Intensity{ROIsinthisSlice(i)} = sum(Surround_Intensity);
                    tmp_surround_intensity = sloppy_mean(Surround_Intensity(:));
                    Surround_Pixel = Total_Surround_Intensity{ROIsinthisSlice(i)}/tmp_surround_intensity;
                    Surround_Measurement{ROIsinthisSlice(i)}(1,sliceframe) = (tmp_surround_intensity-Background_Mean_Int)*Surround_Pixel;
                    Fluorescence_Measurement{ROIsinthisSlice(i)}(1,sliceframe) = ((tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{ROIsinthisSlice(i)})-Surround_Measurement{ROIsinthisSlice(i)}(1,sliceframe);
                else
                    Fluorescence_Measurement{ROIsinthisSlice(i)}(1,sliceframe) = (tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{ROIsinthisSlice(i)};
                end
            else
                Fluorescence_Measurement{ROIsinthisSlice(i)}(1,sliceframe) = (tmp_mean_intensity-Background_Mean_Int)*Pixel_Number{ROIsinthisSlice(i)};
            end
            if twochannels == 1
                Red_Intensity{ROIsinthisSlice(i)} = current_image(ROIreg{ROIsinthisSlice(i)-1},2);
                Total_Red_Intensity{ROIsinthisSlice(i)} = sum(Red_Intensity{ROIsinthisSlice(i)}(:));
                Red_Measurement{ROIsinthisSlice(i)}(1,sliceframe) = (nanmean(Red_Intensity{ROIsinthisSlice(i)}(:))-Background_Mean_Red)*Pixel_Number{ROIsinthisSlice(i)};
            end
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

waitbar((steps-4)/steps, wb, 'Saving Variables...');
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zoomval = str2num(get(gui_CaImageViewer.figure.handles.Zoom_EditableText, 'String'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Save %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fullfname = gui_CaImageViewer.filename;

a.Time = Time;
a.Fluorescence_Intensity = Fluorescence_Intensity;
a.Total_Intensity = Total_Intensity;
a.Pixel_Number = Pixel_Number;
a.Fluorescence_Measurement = Fluorescence_Measurement;
a.Filename = fullfname;
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
    save_fname(save_fname=='-') = '_';
    evalc([save_fname, '= a']);
    start_dir = cd;
    target_dir = save_directory;
    cd(target_dir);
    save(save_fname, save_fname);
catch
    altname = save_fname;
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

for i = 1:length(Fluorescence_Measurement)
    plot(Fluorescence_Measurement{i})
end


scrsz = get(0, 'ScreenSize');
set(timecourse_h, 'Position', [0, scrsz(2), scrsz(3)/2, scrsz(4)]);

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