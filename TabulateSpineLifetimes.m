function TabulateSpineLifetimes(~,~)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global gui_CaImageViewer

selectedaxes = findobj(gcf, 'XColor', [0 1 0]);     %%% Finds the selected axes based on the color set to 'XColor' in function HighLightAxis

fieldlabel = regexp(get(get(selectedaxes(1),'XLabel'), 'String'), '\d+', 'match'); currentimagingfield = fieldlabel{1};

%%% Define experiment 
figtitle = regexp(get(gcf, 'Name'), '[A-Z]{2,3}0+\d+', 'match');
if ~isempty(figtitle)
    experiment = figtitle{1};
    animal = experiment;
else
    experiment = regexp(gui_CaImageViewer.filename, '[A-Z]{2}\d+[_]\d+', 'match');
    experiment = experiment{1};
    animal = experiment(1:5);
end
currentuser = get(gui_CaImageViewer.figure.handles.figure1, 'UserData');
if ~isempty(currentuser)
    useroption = [currentuser, '_'];
end

%%% Find spine lifetimes data specific to the current imaging field
currentimagingfield = gui_CaImageViewer.NewSpineAnalysisInfo.CurrentImagingField;
terminus = regexp(gui_CaImageViewer.save_directory, animal, 'end');
targ_folder = gui_CaImageViewer.save_directory(1:terminus);
load([targ_folder, filesep, useroption,'Imaging Field ', num2str(currentimagingfield), ' Spine Registry'])

%%% Collect and organize data for tabulation
data = SpineRegistry.Data;
cnames = SpineRegistry.ColumnNames;
cformat = SpineRegistry.ColumnFormat;
spinelist = 1:size(SpineRegistry.Data,1);
rownames = cellfun(@(x) ['Spine ', num2str(x)], num2cell(spinelist), 'Uni', false);

%%% Use <html> to define data contents; this allows color to be adjusted per cell 
colorcell = @(value) ['<html><table border=0 width=400 bgcolor=#',repmat('FF',1,1-value),'00',repmat('FF',1,value),'00','><TR><TD style=""><input type = "checkbox" ' repmat('checked',1,value) '/></TD></TR> </table></html>'];
figure('Name', ['Spine Lifetimes for imaging field ', num2str(currentimagingfield)], 'NumberTitle', 'off');
uitable('data',arrayfun(colorcell,data,'uniformoutput',false), 'Units', 'Normalized', 'Position', [0 0 1 1], 'ColumnName', cnames, 'RowName', rownames);

end

