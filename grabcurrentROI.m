function grabcurrentROI(hObject, eventdata, handles)

global zStack_Interface

if ~isempty(eventdata.Indices)  %%% This function is also called by any other interaction with the table, so limit it to only those interactions in which a cell is selected
    if eventdata.Indices(2) == 1 %% If selecting the first column
        zStack_Interface.SelectedROI = hObject.Data(eventdata.Indices(1),eventdata.Indices(2));
    else
    end
end