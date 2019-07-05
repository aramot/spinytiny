function [dirtouse, filetoload] = FindRawDataFile(File, Experimenter, Analyzer, isOpto)


experimenter_initials = regexp(File, '[A-Z]{2}', 'match');
experimenter_initials = experimenter_initials{1};
folder = regexp(File, [experimenter_initials, '\d+[^_]'], 'match');
folder = folder{1};
Date = regexp(File, '\d{4,6}', 'match');
Date = Date{1};
dirtouse = cd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
    filestart = ['Z:', filesep, 'People'];
elseif isunix
    filestart = [filesep,'usr',filesep,'local',filesep,'lab', filesep, 'People'];
else
    error('Operating system not recognized as PC or Unix; terminating');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exception cases for other users whose paths are set up differently
%%% (probably a more elegant way to do this...

switch Experimenter
    case 'Assaf'
        targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, folder, filesep, Date, filesep, 'motion_corrected_tiffs', filesep, 'GFP', filesep, 'summed'];
    case 'Pantong'
        targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, folder, filesep, Date, filesep, 'Snfr', filesep, 'summed'];
    otherwise
        if isOpto
            targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, folder, filesep, Date, filesep,'Optoping',filesep, 'summed'];
        else
            targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, folder, filesep, Date, filesep, 'summed'];
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfolder(targetdir)
    dirtouse = targetdir;
    cd(targetdir)
    files = fastdir(targetdir, {'Analyzed', Analyzer});
    check = 0;    
    if isempty(files)
        files = fastdir(targetdir, {'Analyzed'});
        if ~isempty(files)
            if length(files)>1
                latestfile = findlatestfile(targetdir, files);
                filetoload = latestfile;
                check = 1;
            else
                filetoload = files{1};
            end
        else
            [dirtouse, filetoload] = NoFileFound(folder, Date);
        end
    else
        if length(files)>1      
            latestfile = findlatestfile(targetdir, files);
            filetoload = latestfile;
            check = 1;
        else
            filetoload = files{1};
            check = 1;
        end
        if ~check
            [dirtouse, filetoload] = NoFileFound(folder,Date);
        end
    end
else
    [dirtouse, filetoload] = NoFileFound(folder);
end

function latestfile = findlatestfile(targetdir, files)

for i = 1:length(files)
    file_info = dir(files{i});
    filedate(i) = file_info.datenum;
end
[~,I] = max(filedate);
latestfile = files{I};

function [dirtouse, filetoload] = NoFileFound(folder,Date)

disp('Raw data file not found; PULLING FROM PREVIOUS ANALYSIS!!')
dirtouse = 'E:\ActivitySummary';
cd(dirtouse)
files = fastdir(cd, {folder, Date}, {'Poly'});
filetoload = files{1};
