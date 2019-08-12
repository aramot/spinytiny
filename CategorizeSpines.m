function CategorizeSpine(source, callbackdata)

global gui_CaImageViewer

source = get(source);
% ROInum = regexp(get(gco, 'Tag'), '[0-9]*', 'match'); ROInum = str2num(ROInum{1});
ROInum = gui_CaImageViewer.ClickedROI;

if isfield(source, 'Label')
    switchitem = source.Label;
else
    switchitem = source.Text;
end

ROIobject = findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', 'Tag', ['ROI', num2str(ROInum)]);

switch switchitem
    case 'Set as eliminated'
        ROIobject.FaceAlpha = 1;
        ROIobject.Color = 'r';
        ROIobject.StripeColor = 'w';
        gui_CaImageViewer.NewSpineAnalysisInfo.SpineList(ROInum) = 0;
    case 'Set as active'
        ROIobject.FaceAlpha = 0;
        ROIobject.Color = 'w';
        ROIobject.StripeColor = 'none';
        gui_CaImageViewer.NewSpineAnalysisInfo.SpineList(ROInum) = 1;
end


