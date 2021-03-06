function GroupImagingWindows(~,~)

global gui_CaImageViewer

selectedaxes = findobj(gcf, 'XColor', [0 1 0]);     %%% Finds the selected axes based on the color set to 'XColor' in function HighLightAxis
imagingfieldlabel = get(findobj(gcf,'Type', 'uicontrol', 'Style', 'edit'), 'String');

for i = 1:length(selectedaxes)
    dates(i,:) = get(get(selectedaxes(i), 'Title'), 'String');
    axes(selectedaxes(i))
    xlabel(['Imaging field ', imagingfieldlabel], 'Color', 'k');
end

gui_CaImageViewer.NewSpineAnalysisInfo.CurrentImagingField = str2num(imagingfieldlabel);

dates = sortrows(dates);

figtitle = regexp(get(gcf, 'Name'), '[A-Z]{2,3}0+\d+', 'match');
if ~isempty(figtitle)
    experiment = figtitle{1};
    animal = experiment;
else
    if ~isempty(gui_CaImageViewer.filename)
        animal = regexp(gui_CaImageViewer.filename, '[A-Z]{2,3}[0-9]*', 'match');
    else
        a = get(gcf);
        animal = regexp(a.FileName, '[A-Z]{2,3}0*[1-9]*', 'match');
    end
    animal = animal{1};
end

%%%%% Move to parent folder

if isfield(gui_CaImageViewer, 'save_directory')
    if ~isempty(gui_CaImageViewer.save_directory)
        experimenter = regexp(gui_CaImageViewer.save_directory, ['People.\w+'], 'match');
    else
    end
else
    a = get(gcf);
    experimenter = regexp(a.FileName, ['People.\w+'], 'match');
end
experimenter = experimenter{1};
experimenter = experimenter(strfind(experimenter, '\')+1:end);

    switch experimenter
        case 'Assaf'
            gui_CaImageViewer.save_directory = ['Z:\People\', experimenter, '\Data\', animal];
        otherwise
            gui_CaImageViewer.save_directory = ['Z:\People\',experimenter,'\Data\', animal];
    end

fullpath = gui_CaImageViewer.save_directory;
allseps = strfind(fullpath, filesep);
animal_handle_location = strfind(fullpath, animal);
animal_handle_start = find(allseps-animal_handle_location>0,1);
if ~isempty(animal_handle_start)
    parentpath = fullpath(1:animal_handle_start-1);
else
    parentpath = fullpath;
end
    
cd(fullpath)

%%%%%%

drawer = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');
if ~isempty(drawer)
    userspecificpart = [drawer,'_'];
else
    userspecificpart = [];
end

try
    targ = fastdir(parentpath,[userspecificpart, 'Imaging Field ', imagingfieldlabel, ' Spine Registry']);
    load(targ{1})
    registryexists = 1;
catch
    registryexists = 0;
end

%%%% Construct features for building a table to show spine lifetimes over
%%%% each imaging field

if ~registryexists
    SpineRegistry.ColumnNames = cellfun(@(x) ['Day ', num2str(x)], mat2cell(1:length(selectedaxes), 1, ones(1,length(selectedaxes))), 'Uni', false);
    SpineRegistry.Data = [];
    SpineRegistry.ColumnFormat = repmat({'logical'}, 1, length(selectedaxes));
    SpineRegistry.ColumnEditable = true(1,length(selectedaxes));
    SpineRegistry.RowName = [];
    SpineRegistry.DatesAcquired = flipud(mat2cell(dates,ones(1,length(selectedaxes)), 6));
else
    if ~isfield(SpineRegistry, 'Data')
        SpineRegistry.Data = [];
    end
    if ~isfield(SpineRegistry, 'ColumnFormat')
        SpineRegistry.ColumnFormat = repmat({'logical'}, 1, length(selectedaxes));
    end
    if ~isfield(SpineRegistry, 'ColumnEditable')
        SpineRegistry.ColumnEditable = true(1,length(selectedaxes));
    end
    if ~isfield(SpineRegistry, 'RowName')
        SpineRegistry.RowName = [];
    end
    if ~isfield(SpineRegistry, 'DatesAcquired')
        dates = mat2cell(dates,ones(1,length(selectedaxes)), 6);
        month = cellfun(@(x) x(3:4), dates, 'uni', false);
        day = cellfun(@(x) x(5:6), dates, 'uni', false);
        if length(unique(month))>1
            [~, monthind] = sort(month);
            SpineRegistry.DatesAcquired = dates(monthind);
        else
            [~, dayind] = sort(day);
            SpineRegistry.DatesAcquired = dates(dayind);
        end
    end
end

save([userspecificpart, 'Imaging Field ', imagingfieldlabel, ' Spine Registry'], 'SpineRegistry')

% cd(fullpath)

nextimagingwindow = num2str(str2num(imagingfieldlabel)+1);
set(findobj(gcf, 'Type', 'uicontrol', 'Style', 'edit'), 'String', nextimagingwindow);


