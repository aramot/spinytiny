function RefreshPolyLine(hObject, eventData)

global gui_CaImageViewer

ROInum = eventData.Source.Tag;
SelectedPolyROI = regexp(ROInum, 'PolyROI ', 'split'); SelectedPolyROI = str2num(SelectedPolyROI{2});
SelectedDend = regexp(ROInum, 'Dendrite [0-9]*', 'match'); SelectedDend = regexp(SelectedDend{1}, '[0-9]{1,2}', 'match'); SelectedDend = SelectedDend{1};
PolyLine = findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type','Line', '-and', {'-regexp', 'Tag', SelectedDend});
LineX = get(PolyLine, 'XData');
LineY = get(PolyLine, 'YData');

newROIcenter = eventData.CurrentCenter;

LineX(SelectedPolyROI) = newROIcenter(1);
LineY(SelectedPolyROI) = newROIcenter(2);

delete(PolyLine)
gui_CaImageViewer.PolyLine(str2num(SelectedDend)) = line(gui_CaImageViewer.figure.handles.GreenGraph,LineX,LineY, 'Tag', ['PolyLine ', SelectedDend], 'color', 'cyan');

