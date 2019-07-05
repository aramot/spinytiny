function FinalizeROI(hObject, eventdata, ROInum)

%%% This function is generally designed to finalize the eliptical ROIs
%%% created using the function DrawROI. In most cases, this function simply
%%% adds a finalize version of the fine-tuned ellipse drawn in the pop-up
%%% menu after initializing "DrawROI", adding the ellipse to the
%%% CaImageViewer main window and tacking on context menus and listener
%%% functions for the future manipulation of the ROI. Thus, each ROI
%%% requires 1) the initial drawing, including embedding an appropriate ROI
%%% tag, 2) addition of conetext menus, which are created by uicontextmenu,
%%% then modified by adding menu elements with uimenu, and 3) adding
%%% listener functions, including an option for deleting the ROI, and a
%%% generalized mechanism for declaring and storing the ROI number that was
%%% clicked, which allows flexible access for any called functions

program = get(gcf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize: set parameters based on the parent function

global gui_CaImageViewer
glovar = gui_CaImageViewer;

axes1 = glovar.figure.handles.GreenGraph;
axes2 = glovar.figure.handles.RedGraph;
twochannels = get(glovar.figure.handles.TwoChannels_CheckBox, 'Value');
Merge = get(gui_CaImageViewer.figure.handles.Merge_ToggleButton, 'Value');


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If inserting an ROI on a dendrite, first delete all of the ROIs that come
%%% after the new ROI (the ROI number being decided based on the closest
%%% existing ROI to the one being drawn (performed in DrawROI) so that they
%%% can be redrawn with their updated ROI number/tag.

InsertOpt = get(glovar.figure.handles.InsertSpine_ToggleButton,'Value');
if InsertOpt 
    AllROIs = flipud(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}, '-and', '-not', {'-regexp', 'Tag', 'Background'},'-and', '-not', 'Tag', ['ROI0']));
    AllBackgrounds = nan(1,length(gui_CaImageViewer.BackgroundROI));
    AllBackgrounds(logical(~isnan(gui_CaImageViewer.BackgroundROI))) = flipud(findobj('Type', 'rectangle', '-and', {'-regexp', 'Tag', 'Background'}));    
    AllBackgrounds = AllBackgrounds(2:end); %%% ignore "background ROI/ROI0;
    oldpositions = get(AllROIs, 'Position');
    oldsemiaxes = get(AllROIs, 'SemiAxes');
    oldrotations = get(AllROIs, 'Rotation');
    oldAR = get(AllROIs, 'AspectRatio');
    oldBGpositions = cell(1,length(gui_CaImageViewer.BackgroundROI));
    oldBGpositions(logical(~isnan(AllBackgrounds))) = get(AllBackgrounds(logical(~isnan(AllBackgrounds))), 'Position');
    delete(AllROIs(ROInum:end))
    if twochannels
        AllCh2ROIs = flipud(findobj(gui_CaImageViewer.figure.handles.RedGraph, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}, '-and', '-not', {'-regexp', 'Tag', 'Background'},'-and', '-not', 'Tag', ['ROIred0']));
        delete(AllCh2ROIs(ROInum:end))
    end
    Backgroundstodelete = AllBackgrounds(ROInum:end);
    delete(Backgroundstodelete(logical(~isnan(Backgroundstodelete))))
end

%%% Delete any ROI features with the same tag
delete(findobj('Type', 'rectangle', '-and', 'Tag', ['ROI', num2str(ROInum), ' Starter']))
%         delete(findobj('Type', 'rectangle', '-and', 'Tag', ['BackgroundROI', num2str(ROInum)]))
delete(findobj('Type', 'text', '-and', 'Tag', ['ROI', num2str(ROInum), ' Text Starter']))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Draw final ROI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    gui_CaImageViewer.ROIlistener{ROInum+1} = listener(findobj(gui_CaImageViewer.ROI(ROInum+1)), 'DeletingROI', @DeleteROI);
    addlistener(findobj(gui_CaImageViewer.ROI(ROInum+1)), 'ROIClicked', @DeclareROI);
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
    if twochannels
        if ~Merge
            axes(axes2)
            gui_CaImageViewer.ROIred(ROInum+1) = drawellipse('Center', adjustedpos(1:2), 'SemiAxes', newROIsemiaxes, 'RotationAngle', newROIRotationAngle, 'AspectRatio', newROIAspectRatio,...
            'Tag', ['ROIred', num2str(ROInum)], 'Color', 'c', 'HandleVisibility', 'on', 'Label', labelopt, 'Linewidth', 1, 'FaceAlpha', 0, 'InteractionsAllowed', 'none');
        end
    else
    end
    gui_CaImageViewer.ROIlistener{ROInum+1} = listener(findobj(gui_CaImageViewer.ROI(ROInum+1)), 'DeletingROI', @DeleteROI);
    addlistener(findobj(gui_CaImageViewer.ROI(ROInum+1)), 'ROIClicked', @DeclareROI)
%     if gui_CaImageViewer.UsingSurroundBackground
%         surroundoffset = gui_CaImageViewer.SurroundBackgroundBuffer;
%         gui_CaImageViewer.BackgroundROI(ROInum+1) = rectangle('Position', [adjustedpos(1)-surroundoffset/2, adjustedpos(2)-surroundoffset/2, adjustedpos(3)+surroundoffset, adjustedpos(4)+surroundoffset], 'EdgeColor', 'w', 'Curvature', [1 1], 'Tag', ['BackgroundROI', num2str(ROInum)], 'Linewidth', 0.75);
%     else
%         gui_CaImageViewer.BackgroundROI(ROInum+1) = NaN;
%     end
end

set(gui_CaImageViewer.figure.handles.InsertSpine_ToggleButton, 'Value', 0);
set(gui_CaImageViewer.figure.handles.InsertSpine_ToggleButton, 'Enable', 'off');
set(gui_CaImageViewer.figure.handles.EditSpines_ToggleButton, 'Value', 0)

if InsertOpt %%% Redraw the deleted ROIs, now with the numbers increased by 1
    for a = ROInum:length(oldpositions)
        gui_CaImageViewer.ROI(a+2) = drawellipse('Center', oldpositions{a}(1:2), 'SemiAxes', oldsemiaxes{a}, 'RotationAngle', oldrotations{a}, 'AspectRatio', oldAR{a}, 'Tag', ['ROI', num2str(a+1)], 'UIContextMenu', c, 'Color', linecolor, 'HandleVisibility', 'on', 'Label', num2str(a+1), 'Linewidth', 1, 'FaceAlpha', 0, 'InteractionsAllowed', 'none');
        roiget = get(gui_CaImageViewer.ROI(a+2));
        c = uicontextmenu;
        uimenu(c, 'Label', 'Add Surround Background', 'Callback', @ModifyROI);
        uimenu(c, 'Label', 'Remove Surround Background', 'Callback', @ModifyROI);
        uimenu(c, 'Label', 'Set as eliminated', 'Callback', @CategorizeSpines);
        uimenu(c, 'Label', 'Set as active', 'Callback', @CategorizeSpines);
        roiget.UIContextMenu = c;
        gui_CaImageViewer.ROIlistener{a+2} = listener(findobj(gui_CaImageViewer.ROI(a+2)), 'DeletingROI', @DeleteROI);
        addlistener(findobj(gui_CaImageViewer.ROI(a+2)), 'ROIClicked', @DeclareROI)
        if twochannels
            axes(axes2)
            gui_CaImageViewer.ROIred(a+2) = drawellipse('Center', oldpositions{a}(1:2), 'SemiAxes', oldsemiaxes{a}, 'RotationAngle', oldrotations{a}, 'AspectRatio', oldAR{a}, 'Tag', ['ROIred', num2str(a+1)], 'UIContextMenu', c, 'Color', 'c', 'HandleVisibility', 'on', 'Label', num2str(a+1), 'Linewidth', 1, 'FaceAlpha', 0, 'InteractionsAllowed', 'none');
            roiget = get(gui_CaImageViewer.ROI(a+2));
            c = roiget.UIContextMenu;
            uimenu(c, 'Label', 'Add Surround Background', 'Callback', @ModifyROI);
            uimenu(c, 'Label', 'Remove Surround Background', 'Callback', @ModifyROI);
            uimenu(c, 'Label', 'Set as eliminated', 'Callback', @CategorizeSpines);
            uimenu(c, 'Label', 'Set as active', 'Callback', @CategorizeSpines);
            roiget.UIContextMenu = c;
            gui_CaImageViewer.ROIlistener{a+2} = listener(findobj(gui_CaImageViewer.ROI(a+2)), 'DeletingROI', @DeleteROI);
            axes(axes1)
        end
    end
end  
