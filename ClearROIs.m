function ClearROIs(Assumption, hObject, eventdata)

program = get(gcf);

running = program.FileName;


if strcmpi(Assumption, 'AssumeAll')
    choice = 'Both';
else
    Scrsz = get(0, 'Screensize');
    d = dialog('Position', [(Scrsz(3)/2)-125 Scrsz(4)/2-75 250 150], 'Name', 'Clear what?');
    txt = uicontrol('Parent', d, 'Style', 'text', 'Position', [10 100 230 30], 'String', 'Which ROIs do you want to clear?');
    btn1 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [35 30 50 25], 'String', 'Spines', 'Callback', @ClearWhat);
    btn2 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [85.5 30 70 25], 'String', 'Dendrites', 'Callback', @ClearWhat);
    btn3 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [156 30 50 25], 'String', 'Both', 'Callback', @ClearWhat);
    uiwait(d)
    choice = get(d, 'UserData');
    delete(d);
end


if ~isempty(regexp(running, 'CaImageViewer'))
    global gui_CaImageViewer
    glovar = gui_CaImageViewer;
elseif ~isempty(regexp(running, 'FluorescenceSuite'));
    global gui_FluorescenceSuite
    glovar = gui_FluorescenceSuite;
end



if strcmpi(choice, 'Spines')
    
    glovar.NewSpineAnalysisInfo.SpineList = [];
    glovar.Spine_Number = 0;
    ROIboxes = findobj(program.Children, 'Type', 'images.roi.ellipse', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'});
    Textboxes = findobj(program.Children, 'Type', 'text');
    glovar.ROI = [];
    glovar.BackgroundROI = [];
    
    for i = 1:length(ROIboxes)
        delete(ROIboxes(i));
    end
    
    for i = 1:length(Textboxes)
        delete(Textboxes(i));
    end
    
elseif strcmpi(choice, 'Dendrites')
    
    glovar.Dendrite_Number = 0;
    glovar.Dendrite_ROIs = 0;
    glovar.SpineDendriteGrouping = [];
    
    ROIboxes = findobj(program.Children, 'Type', 'images.roi.ellipse', '-and', '-regexp', 'Tag', 'Dendrite');
    Lineboxes = findobj(program.Children, 'Type', 'line');
    
    for i = 1:length(ROIboxes)
        delete(ROIboxes(i));
    end

    for i = 1:length(Lineboxes)
        delete(Lineboxes(i));
    end
    
    glovar.PolyROI = [];
    glovar.PolyLinePos = [];
    glovar.PolyLineVertices = [];
    glovar.PolyLine = [];
    glovar.DendritePolyPointNumber = 0;

elseif strcmpi(choice, 'Both')  
    twochannels = get(glovar.figure.handles.TwoChannels_CheckBox);

    glovar.NewSpineAnalysisInfo.SpineList = [];
    glovar.Spine_Number = 0;
    glovar.Dendrite_Number = 0;
    glovar.Dendrite_ROIs = 0;

    ROIboxes = findobj(program.Children, 'Type', 'images.roi.ellipse');
    Textboxes = findobj(program.Children, 'Type', 'text');
    Lineboxes = findobj(program.Children, 'Type', 'line');


    for i = 1:length(ROIboxes)
        delete(ROIboxes(i));
    end

    for i = 1:length(Textboxes)
        delete(Textboxes(i));
    end

    for i = 1:length(Lineboxes)
        delete(Lineboxes(i));
    end

    glovar.PolyROI = [];
    glovar.PolyLinePos = [];
    glovar.PolyLineVertices = [];
    glovar.PolyLine = [];
    glovar.DendritePolyPointNumber = 0;
    glovar.ROI = [];
    glovar.BackgroundROI = [];
end

if ~isempty(regexp(running, 'CaImageViewer'))
    gui_CaImageViewer = glovar;
elseif ~isempty(regexp(running, 'FluorescenceSuite'));
    gui_FluorescenceSuite = glovar;
end

function [choice] = ClearWhat(hObject, eventdata, ~)

button = get(hObject);

choice = button.String;

sourcewindow = button.Parent;

set(sourcewindow, 'UserData', choice);

uiresume

% glovar = rmfield(glovar, 'ROI');