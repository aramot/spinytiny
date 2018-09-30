function FinalizeROI(hObject, eventdata, ROInum)

%%% This function is generally designed to manipulate the eliptical ROIs
%%% created using the function DrawROI. 

program = get(gcf);

running = program.FileName;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize: set parameters based on the parent function

global gui_CaImageViewer
glovar = gui_CaImageViewer;
axes1 = glovar.figure.handles.GreenGraph;
axes2 = glovar.figure.handles.RedGraph;
twochannels = get(glovar.figure.handles.TwoChannels_CheckBox, 'Value');


newROI = findobj(gcf, 'Type', 'images.roi.ellipse', 'Tag', ['tempROI', num2str(ROInum)]);
newROIpos = newROI.Center;
newROIsemiaxes = newROI.SemiAxes;
newROIRotationAngle = newROI.RotationAngle;
newROIAspectRatio = newROI.AspectRatio;
oldROIpos = round(get(gui_CaImageViewer.ROI(ROInum+1), 'Position'));

%%% Correction Factor
correctionfactor = -1;

adjustedpos = [oldROIpos(1)+newROIpos(1)+correctionfactor, oldROIpos(2)+newROIpos(2)+correctionfactor];
try
    close('Auto zoom window');
catch
end
axes(gui_CaImageViewer.figure.handles.GreenGraph)

%%% Delete any ROI features with the same tag
delete(findobj('Type', 'rectangle', '-and', 'Tag', ['ROI', num2str(ROInum), ' Starter']))
%         delete(findobj('Type', 'rectangle', '-and', 'Tag', ['BackgroundROI', num2str(ROInum)]))
delete(findobj('Type', 'text', '-and', 'Tag', ['ROI', num2str(ROInum), ' Text Starter']))

InsertOpt = get(glovar.figure.handles.InsertSpine_ToggleButton,'Value');
if InsertOpt
    ROInum = glovar.InsertPoint;
    AllROIs = flipud(findobj('Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}, '-and', '-not', {'-regexp', 'Tag', 'Background'},'-and', '-not', 'Tag', ['ROI0']));
    AllROItexts = flipud(findobj('Type', 'text', '-and', {'-regexp', 'Tag', 'ROI'}));
    AllROItexts = AllROItexts(2:end);
    AllBackgrounds = nan(1,length(gui_CaImageViewer.BackgroundROI));
    AllBackgrounds(logical(~isnan(gui_CaImageViewer.BackgroundROI))) = flipud(findobj('Type', 'rectangle', '-and', {'-regexp', 'Tag', 'Background'}));    
    AllBackgrounds = AllBackgrounds(2:end); %%% ignore "background ROI/ROI0;
    oldpositions = get(AllROIs, 'Position');
    oldBGpositions = cell(1,length(gui_CaImageViewer.BackgroundROI));
    oldBGpositions(logical(~isnan(AllBackgrounds))) = get(AllBackgrounds(logical(~isnan(AllBackgrounds))), 'Position');
    delete(AllROIs(ROInum:end))
    delete(AllROItexts(ROInum:end))
    Backgroundstodelete = AllBackgrounds(ROInum:end);
    delete(Backgroundstodelete(logical(~isnan(Backgroundstodelete))))
end

%%%%%%%%%%%%%%%%%%%%
%%% Draw final ROI
%%%%%%%%%%%%%%%%%%%%

cmap = glovar.CurrentCMap; 

switch cmap
    case 'RGB'
        linecolor = 'b';
    case 'Jet'
        linecolor = 'w';
    case 'Hot'
        linecolor = 'c';
    case 'Fire'
        linecolor = 'g'; 
end

showlabels = get(gui_CaImageViewer.figure.handles.ShowLabels_ToggleButton, 'Value');

if showlabels
    labelopt = num2str(ROInum);
else
    labelopt = '';
end

if gui_CaImageViewer.NewSpineAnalysis
    gui_CaImageViewer.ROI(ROInum+1) = drawellipse('Center', adjustedpos(1:2), 'SemiAxes', newROIsemiaxes, 'RotationAngle', newROIRotationAngle, 'AspectRatio', newROIAspectRatio,...
        'Tag', ['ROI', num2str(ROInum)], 'Color', linecolor, 'HandleVisibility', 'on', 'Label', labelopt, 'Linewidth', 1, 'FaceAlpha', 0, 'InteractionsAllowed', 'none');
    roiget = get(gui_CaImageViewer.ROI(ROInum+1));
    c = roiget.UIContextMenu;
    uimenu(c, 'Label', 'Set as eliminated', 'Callback', @CategorizeSpines);
    uimenu(c, 'Label', 'Set as active', 'Callback', @CategorizeSpines);

    gui_CaImageViewer.NewSpineAnalysisInfo.SpineList = [gui_CaImageViewer.NewSpineAnalysisInfo.SpineList, 1];
else
    %%%
    gui_CaImageViewer.ROI(ROInum+1) = drawellipse('Center', adjustedpos(1:2), 'SemiAxes', newROIsemiaxes, 'RotationAngle', newROIRotationAngle, 'AspectRatio', newROIAspectRatio,...
        'Tag', ['ROI', num2str(ROInum)], 'Color', linecolor, 'HandleVisibility', 'on', 'Label', labelopt, 'Linewidth', 1, 'FaceAlpha', 0, 'InteractionsAllowed', 'none');
    roiget = get(gui_CaImageViewer.ROI(ROInum+1));
    c = roiget.UIContextMenu;
    uimenu(c, 'Label', 'Add Surround Background', 'Callback', @ModifyROI);
    uimenu(c, 'Label', 'Remove Surround Background', 'Callback', @ModifyROI);
    uimenu(c, 'Label', 'Set as eliminated', 'Callback', @CategorizeSpines);
    uimenu(c, 'Label', 'Set as active', 'Callback', @CategorizeSpines);

    %%%
%     if gui_CaImageViewer.UsingSurroundBackground
%         surroundoffset = gui_CaImageViewer.SurroundBackgroundBuffer;
%         gui_CaImageViewer.BackgroundROI(ROInum+1) = rectangle('Position', [adjustedpos(1)-surroundoffset/2, adjustedpos(2)-surroundoffset/2, adjustedpos(3)+surroundoffset, adjustedpos(4)+surroundoffset], 'EdgeColor', 'w', 'Curvature', [1 1], 'Tag', ['BackgroundROI', num2str(ROInum)], 'Linewidth', 0.75);
%     else
%         gui_CaImageViewer.BackgroundROI(ROInum+1) = NaN;
%     end
end

% gui_CaImageViewer.ROItext(ROInum+1) = text(adjustedpos(1)-4, adjustedpos(2)-3, num2str(ROInum), 'color', 'white', 'Tag', ['ROI', num2str(ROInum), ' Text'],'ButtonDownFcn', 'DeleteROI', 'Fontsize', 6);
set(gui_CaImageViewer.figure.handles.InsertSpine_ToggleButton, 'Value', 0);
set(gui_CaImageViewer.figure.handles.InsertSpine_ToggleButton, 'Enable', 'off');

if InsertOpt %%% Redraw the deleted ROIs, now with the numbers increased by 1
    c1 = uicontextmenu;
    uimenu(c1, 'Label', 'Add Surround Background', 'Callback', @ModifyROI);
    uimenu(c1, 'Label', 'Remove Surround Background', 'Callback', @ModifyROI);
    for a = ROInum:length(oldpositions)
        gui_CaImageViewer.ROI(a+2) = drawellipse('Center', adjustedpos(1:2), 'SemiAxes', newROIsemiaxes, 'RotationAngle', newROIRotationAngle, 'AspectRatio', newROIAspectRatio, 'Tag', ['ROI', num2str(a+1)], 'UIContextMenu', c, 'Color', linecolor, 'HandleVisibility', 'on', 'Label', labelopt, 'Linewidth', 1, 'FaceAlpha', 0);
%         if ~isempty(oldBGpositions{a})
%             gui_CaImageViewer.BackgroundROI(a+2) = rectangle('Position', oldBGpositions{a}, 'EdgeColor', 'w', 'Curvature', [1 1], 'Tag', ['BackgroundROI', num2str(a+1)], 'Linewidth', 0.75);
%         else
%             gui_CaImageViewer.BackgroundROI(a+2) = NaN;
%         end
    end
end    