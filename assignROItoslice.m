function assignROItoslice(hObject, eventdata, handles)

global zStack_Interface

currentslice = str2num(zStack_Interface.CurrentSliceEdit.String);
currentROI = zStack_Interface.SelectedROI;

zStack_Interface.ROITable.Data(currentROI,2) = currentslice;
