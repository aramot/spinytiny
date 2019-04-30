animal = 'NH051';

Experimenter = 'Nathan';
Analyzer = 'Nathan';
filestart = ['Z:\People'];

files = fastdir('E:/ActivitySummary', animal, 'Poly');


for f = 1:length(files)
    
    Date = regexp(files{f}, '[0-9]{6}', 'match'); Date = Date{1};

    targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, animal, filesep, Date, filesep, 'summed'];
    
    filepattern = fastdir(targetdir, 'summed_50', 'Analyzed'); filepattern = filepattern{1};
    
    CaImage_File_info = imfinfo(filepattern);
    timecourse_image_number = numel(CaImage_File_info);

    TifLink = Tiff(filepattern, 'r');

    for i = 1:timecourse_image_number
        TifLink.setDirectory(i);
        currentimageseries(:,:,i) = TifLink.read();
    end
    clear TifLink
    clear currentimageseries
    
    immax = max(currentimageseries, [], 3);
    imfig = figure; im_ax = axes; currentimage = imagesc(immax);
    
    ROIfile = fastdir(targetdir, 'DrawnBy');
    if length(ROIfile)>1
        filesdrawnbyuser = find(~cellfun(@isempty, cellfun(@(x) regexp(x, Analyzer, 'once'), ROIfile, 'uni', false)));
        if length(filesdrawnbyuser) == 1
            ROIfile = ROIfile{filesdrawnbyuser};
        else
            dirc = dir(targetdir);
            dirc = dirc(~cellfun(@isdir,{dirc(:).name}));
            dirc = dirc(cell2mat(cellfun(@(x) ~isempty(regexp(x, 'DrawnBy')), {dirc(:).name}, 'uni', false)));
            [~,I] = max([dirc(:).datenum]);
            if ~isempty(I)
                latestfile = dirc(I).name;
            end
            ROIfile = latestfile; 
        end
    else
        ROIfile = ROIfile{1};
    end
    load([targetdir, '\', ROIfile])
    eval(['ROIfile = ', ROIfile(1:end-4), ';']);

    if isstruct(ROIfile.ROIPosition{1})
        method = 'new';
    else
        method = 'old';
    end
    
    for roi = 1:length(ROIfile.SpineROIs)
        switch method 
            case 'old'
                ROIcenter = [ROIfile.ROIPosition{roi+1}(1)+ROIfile.ROIPosition{roi+1}(3)/2, ROIfile.ROIPosition{roi+1}(2)+ROIfile.ROIPosition{roi+1}(4)/2]; %%% Don't forget that position 1 in this cell is actually ROI0/background ROI!!!! 
                ROIwidth = ROIfile.ROIPosition{roi+1}(3);
                ROIheight = ROIfile.ROIPosition{roi+1}(4);
                if ROIwidth>ROIheight
                    majoraxis = ROIwidth;
                    minoraxis = ROIheight;
                else
                    majoraxis = ROIheight;
                    minoraxis = ROIwidth;
                end
                currentROI = drawellipse(im_ax,'Center', ROIcenter, 'SemiAxes', [majoraxis, minoraxis], 'Interactions', 'none', 'Color', 'w', 'FaceAlpha', 0);
                ROImask = createMask(currentROI, immax);
                ROIreg = find(ROImask);
                
            case 'new'
                ROIcenter = ROIfile.ROIPosition{roi+1}.Center;
        end
    end

end