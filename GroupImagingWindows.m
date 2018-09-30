function GroupImagingWindows(~,~)

global gui_CaImageViewer

selectedaxes = findobj(gcf, 'XColor', [0 1 0]);     %%% Finds the selected axes based on the color set to 'XColor' in function HighLightAxis
imagingfieldlabel = get(findobj(gcf,'Type', 'uicontrol', 'Style', 'edit'), 'String');

for i = 1:length(selectedaxes)
    dates(i,:) = get(get(selectedaxes(i), 'Title'), 'String');
    axes(selectedaxes(i))
    xlabel(['Imaging field ', imagingfieldlabel], 'Color', 'k');
end

%%%%% Move to parent folder

fullpath = gui_CaImageViewer.save_directory;
allseps = strfind(fullpath, filesep);
stepsup = 2;
newpath = fullpath(1:allseps(end-stepsup)-1); %%% move two steps up in the path directory to get bath to the main animal folder (e.g. Z:/People/Nathan/Data/NH004 instead of Z:/People/Nathan/Data/NH004/160316/summed)
cd(newpath)

%%%%%%
files = dir(newpath);

drawer = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');
if ~isempty(drawer)
    userspecificpart = [drawer,'_'];
else
    userspecificpart = [];
end

try
    targ = fastdir(newpath,[userspecificpart, 'Imaging Field ', imagingfieldlabel, ' Spine Registry']);
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
    if ~isfield(SpineRegistry, 'ColumnNames')
        SpineRegistry.ColumnNames = cellfun(@(x) ['Day ', num2str(x)], mat2cell(1:length(selectedaxes), 1, ones(1,length(selectedaxes))), 'Uni', false);
    end
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
            [monthval, monthind] = sort(month);
            SpineRegistry.DatesAcquired = dates(monthind);
        else
            [dayval, dayind] = sort(day);
            SpineRegistry.DatesAcquired = dates(dayind);
        end
    end
end

save([userspecificpart, 'Imaging Field ', imagingfieldlabel, ' Spine Registry'], 'SpineRegistry')

% cd(fullpath)

nextimagingwindow = num2str(str2num(imagingfieldlabel)+1);
set(findobj(gcf, 'Type', 'uicontrol', 'Style', 'edit'), 'String', nextimagingwindow);


