function DeclareROI(hObject, eventdata, source)
global gui_CaImageViewer

ROI_tag = hObject.Tag;
ROI_num = regexp(ROI_tag, '\d+', 'match');
ROI_num = str2num(ROI_num{1});

gui_CaImageViewer.ClickedROI = ROI_num;