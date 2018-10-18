function setslicenum(hObject, eventdata, handles)

global zStack_Interface
global gui_CaImageViewer

if strcmpi(eventdata.Key, 'return') || strcmpi(eventdata.Key, 'Routed')
    numslices = str2num(zStack_Interface.SlicesEdit.String);
    currentframe = str2num(gui_CaImageViewer.figure.handles.Frame_EditableText.String);
    currentslice = mod(currentframe,numslices);
    if currentslice == 0
        currentslice = numslices;
    end
    zStack_Interface.CurrentSliceEdit.String = currentslice;
else
end