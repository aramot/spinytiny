function TurnOffTools

global gui_CaImageViewer

ZoomInButton = findobj(gui_CaImageViewer.figure.handles.figure1,'Tag', 'ZoomIn_ToggleTool');
ZoomOutButton = findobj(gui_CaImageViewer.figure.handles.figure1, 'Tag', 'ZoomOut_ToggleTool');
PanButton = findobj(gui_CaImageViewer.figure.handles.figure1, 'Tag', 'Pan_ToggleTool');

set(gui_CaImageViewer.figure.handles.ZoomIn_ToggleTool, 'state', 'off'); putdowntext('zoomin',ZoomInButton)
set(gui_CaImageViewer.figure.handles.ZoomOut_ToggleTool, 'state', 'off'); putdowntext('zoomout', ZoomOutButton)
set(gui_CaImageViewer.figure.handles.Pan_ToggleTool, 'state', 'off'); putdowntext('pan', PanButton)
