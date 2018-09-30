function Drag_Poly(hObject, eventdata, ROInum);

global gui_CaImageViewer

currentTag = get(gco, 'Tag');
SelectedPolyROI = regexp(currentTag, 'PolyROI ', 'split'); SelectedPolyROI = str2num(SelectedPolyROI{2});
SelectedDend = regexp(currentTag, 'Dendrite [0-9]*', 'match'); SelectedDend = regexp(SelectedDend{1}, '[0-9]{1,2}', 'match'); SelectedDend = SelectedDend{1};
PolyLine = findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type','Line', '-and', {'-regexp', 'Tag', SelectedDend});
LineX = get(PolyLine, 'XData');
LineY = get(PolyLine, 'YData');

if str2double(SelectedDend) > 1
    otherdendROIs = 0;
    for i = 1:str2num(SelectedDend)-1
        otherdendROIs = otherdendROIs + length(get(findobj(gui_CaImageViewer.figure.handles.GreenGraph, 'Type','Line', '-and', {'-regexp', 'Tag', num2str(i)}), 'XData'));
    end
    PolyROItoRemove = SelectedPolyROI;
else
    PolyROItoRemove = SelectedPolyROI;
end

clicktype = get(gcbf, 'SelectionType');

if strcmpi(clicktype, 'alt')
    delete(gco)
    leftover_polyROI = flipud(findobj('Type', 'rectangle', '-and', {'-regexp', 'Tag', ['Dendrite ', SelectedDend, ' PolyROI']}));
    for i = SelectedPolyROI:length(leftover_polyROI)
        set(leftover_polyROI(i), 'Tag', ['Dendrite ', SelectedDend, ' PolyROI ', num2str(i)])
    end
    LineX(PolyROItoRemove) = [];
    LineY(PolyROItoRemove) = [];
    delete(PolyLine);
    gui_CaImageViewer.PolyLine(str2num(SelectedDend)) = line(LineX,LineY, 'Tag', ['PolyLine ', SelectedDend], 'color', 'cyan');
    gui_CaImageViewer.PolyLine(str2num(SelectedDend)) = gui_CaImageViewer.PolyLine(str2num(SelectedDend))-1;
else
    point1 = get(gca, 'CurrentPoint');  %%% Button down detected and position parameters stored (x, y, width, height)
    point1 = point1(1,1:2);             %%% Extract x and y

    RoiRect = get(gco, 'Position');     %%% Get placement of current object on screen
    rectFig = get(gcf, 'Position');     %%% Get position of current figure on the screen
    rectAx = get(gca, 'Position');      %%% Get position of current axes on the screen

    scrnsz = get(0,'ScreenSize');


    if point1(1)>(RoiRect(1)+2*RoiRect(3)/3) && point1(2)> (RoiRect(2)+2*RoiRect(4)/3) %%%resize
        rbbox;
        point2 = get(gca, 'CurrentPoint');
        point2 = point2(1,1:2);
        RoiRect(3) = point2(1)-RoiRect(1);
        RoiRect(4) = point2(2)-RoiRect(2);
        RoiRect_final = [RoiRect(1), RoiRect(2), point2(1)-RoiRect(1), point2(2)-RoiRect(2)];
    else %%% drag
        rbbox;      %%% initiate function to detect transition from button press to button release
        point2 = get(gca, 'CurrentPoint');
        point2 = point2(1,1:2);
        RoiRect_new = [point2(1)-(RoiRect(3)/2), point2(2)-RoiRect(4), RoiRect(3), RoiRect(4)];
        RoiRect_final = dragrect(RoiRect_new);
    end

    Roi_Rect_tag = get(gco, 'Tag');
    RoiN = Roi_Rect_tag(end);
    RoiN_tag = [Roi_Rect_tag, ' Text'];
    Texts  = findobj('Tag', RoiN_tag);

    set(gco, 'Position', RoiRect_final);
    RoiText_final = [RoiRect_final(1)-2, RoiRect_final(2)-2];
    set(Texts, 'Position', RoiText_final);

    if ~isempty(strfind(Roi_Rect_tag, 'red'))
        other_graph = regexp(Roi_Rect_tag, 'red', 'split');
        other_graph = [other_graph{1}, other_graph{2}];
        Other_Rect_tag = other_graph;
        Other_RoiN_tag = [other_graph, ' Text'];
    elseif isempty(strfind(Roi_Rect_tag, 'red'))
        other_graph = [Roi_Rect_tag(1:3), 'red', Roi_Rect_tag(4)];
        Other_Rect_tag = other_graph;
        Other_RoiN_tag = [other_graph, ' Text'];
    end

    newX = RoiRect_final(1)+RoiRect_final(3)/2;
    newY = RoiRect_final(2)+RoiRect_final(4)/2;
    LineX(PolyROItoRemove) = newX;
    LineY(PolyROItoRemove) = newY;
    delete(PolyLine);
    gui_CaImageViewer.PolyLine(str2num(SelectedDend)) = line(LineX,LineY, 'Tag', ['PolyLine ', SelectedDend], 'color', 'cyan');
end


