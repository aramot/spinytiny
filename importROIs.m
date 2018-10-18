function importROIs(hObject, eventdata, handles)

global gui_CaImageViewer
global zStack_Interface

numROIs = length(gui_CaImageViewer.ROI)-1;

% set(zStack_Interface.ROITable,'String', cellfun(@num2str, mat2cell(1:numROIs,1,ones(1,numROIs)), 'uni', false))

olddata = zStack_Interface.ROITable.Data;

if size(olddata,1) ~= numROIs
    zStack_Interface.ROITable.Data(1:numROIs,1) = [1:numROIs];
end