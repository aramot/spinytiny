function ModifyROI(source, callbackdata)

global gui_CaImageViewer

source = get(source);
ROInum = regexp(get(gco, 'Tag'), '[0-9]*', 'match'); ROInum = str2num(ROInum{1});

switch source.Label
    case 'Add Surround Background'
        delete(findobj(gcf, 'Type', 'Rectangle', '-and', {'-regexp', 'Tag', ['BackgroundROI', num2str(ROInum)]}))
        parentROI = findobj('Type', 'rectangle', '-and', 'Tag', ['ROI', num2str(ROInum)]);
        Fl_ROI = get(parentROI, 'Position');
        surroundoffset = gui_CaImageViewer.SurroundBackgroundBuffer;
        gui_CaImageViewer.BackgroundROI(ROInum+1) = rectangle('Position', [Fl_ROI(1)-surroundoffset/2, Fl_ROI(2)-surroundoffset/2, Fl_ROI(3)+surroundoffset, Fl_ROI(4)+surroundoffset], 'EdgeColor', 'w', 'Curvature', [1 1], 'Tag', ['BackgroundROI', num2str(ROInum)], 'Linewidth', 0.5);
        gui_CaImageViewer.UsingSurroundBackground = 1;
        uistack(parentROI, 'top')
    case 'Remove Surround Background'
        delete(findobj(gcf, 'Type', 'Rectangle', '-and', {'-regexp', 'Tag', ['BackgroundROI', num2str(ROInum)]}))
        gui_CaImageViewer.BackgroundROI(ROInum+1) = NaN;
        if isempty(find(~isnan(gui_CaImageViewer.BackgroundROI),1))
           gui_CaImageViewer.UsingSurroundBackground = 0;
        end
end