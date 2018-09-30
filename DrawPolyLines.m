function DrawPolyLines(hObject, eventdata, DendriteNum)

program = get(gcf);

global gui_CaImageViewer
glovar = gui_CaImageViewer;
axes1 = glovar.figure.handles.GreenGraph;
axes2 = glovar.figure.handles.RedGraph;
twochannels = get(glovar.figure.handles.TwoChannels_CheckBox, 'Value');

User = get(glovar.figure.handles.figure1, 'UserData');

%%% Since you are drawing multiple dendrite polylines, you need to be able
%%% to delete specific lines/circles that correspond to the dendrite that's
%%% being overwritten (if applicable)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cmap = glovar.CurrentCMap;

if strcmpi(cmap, 'Jet') || strcmpi(cmap, 'Fire') || strcmpi(cmap, 'Hot')
    linecolor = 'c';
else
    linecolor = 'r';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Delete old lines and ROIs %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if DendriteNum > glovar.Dendrite_Number
    glovar.Dendrite_Number = DendriteNum;
end

if DendriteNum <= glovar.Dendrite_Number 
    ROIboxes = flipud(findobj(program.Children, '-regexp', 'Tag',  ['Dendrite ', num2str(DendriteNum)]));
    ROIlines = flipud(findobj(program.Children, 'Type', 'Line', '-or', 'Tag', 'PolyLine '));

    boxtags = get(ROIboxes, 'Tag');
    linetags = get(ROIlines,'Tag');
    
    a = [];
    
    if DendriteNum == 1
        ROIcounter = 1;
    else
        ROIcounter = glovar.DendritePolyPointNumber(DendriteNum-1)+1;
    end
    
    for i = 1:length(ROIboxes)
        delete(ROIboxes(i));
        ROIcounter = ROIcounter+1;
    end

    glovar.Dendrite_ROIs = glovar.Dendrite_ROIs-length(a);
    
    for i = 1:length(ROIlines)
        if size(linetags,1) > 1
            c{i} = regexp(linetags(i), ['PolyLine ', num2str(DendriteNum)]);
        else
            c{i} = regexp(linetags, ['PolyLine ', num2str(DendriteNum)]);
        end
        if length(ROIlines)>1
            if ~isempty(c{i}{1})
                delete(ROIlines(i));
            else
            end
        else
            if ~isempty(c{1})
                delete(ROIlines(i))
            end
        end
    end
else
end

glovar.Dendrite_ROIs = length(glovar.PolyROI);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[x, y] = getline; %%% trace around the dendrite to specify the general area

xmin = floor(min(x)-10);
xmax = ceil(max(x)+10);
ymin = floor(min(y)-10);
ymax = ceil(max(y)+10);

if glovar.NewSpineAnalysis
    immax = glovar.ch1image;
else
    im = glovar.GCaMP_Image;
    im = cat(3, im{:});
    immax = max(im, [], 3);
end

if xmin<=0
    xmin = 1;
end
if xmax>length(immax)
    xmax = length(immax);
end
if ymin<=0
    ymin = 1;
end
if ymax>length(immax)
    ymax = length(immax);
end

scrsz = get(0, 'ScreenSize');

dendwindow = figure('Position', scrsz); imagesc(immax(ymin:ymax, xmin:xmax)); colormap(cmap)
set(gca, 'XTick', [], 'YTick', []);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = []; y = [];

%%% Draw line along dendrite by adding regularly spaced points along its
%%% length; note: double-clicks can cause early termination, so remove this
%%% functionality with a "listener" function


%     h = addlistener(handle(gcf), 'WindowButtonDownFcn', 'PostSet', @changedWBDFcn);
%     [x, y] = getline; close(dendwindow);
%     delete(h)

[x, y] = getline; close(dendwindow);

x = x+xmin;
y = y+ymin;

oldpolypointnumber = glovar.DendritePolyPointNumber;
    if isempty(oldpolypointnumber)
        oldpolypointnumber = 0;
    end
glovar.DendritePolyPointNumber(DendriteNum) = length(x);

if length(oldpolypointnumber) ~= length(glovar.DendritePolyPointNumber)
    newdend = 1;
else
    newdend = 0;
end

radius = 3;

axes(axes1)

%%% Correction Factor may change depending on zoom
correctionfactor = 2;
x = x-correctionfactor;
y = y-correctionfactor;
%%%

glovar.PolyLine(DendriteNum) = line(x,y, 'Tag', ['PolyLine ', num2str(DendriteNum)], 'color', 'cyan');

if glovar.Dendrite_ROIs == 0
    ExistingDROIs = 0;
    glovar.Dendrite_ROIs = length(x);
    Dendrite_ROIs = glovar.Dendrite_ROIs;
else
    ExistingDROIs = glovar.Dendrite_ROIs;
    glovar.Dendrite_ROIs = glovar.Dendrite_ROIs + length(x);
    Dendrite_ROIs = glovar.Dendrite_ROIs;
end

    tempPos = glovar.PolyLinePos;
    tempROI = glovar.PolyROI;
    glovar.PolyLinePos = cell(1,sum(glovar.DendritePolyPointNumber));
    glovar.PolyROI = cell(1,sum(glovar.DendritePolyPointNumber));
    
    combin = mat2cell([x,y], ones(size(x,1),1), 2);
    combinpos = mat2cell([x-radius,y-radius,radius*2*ones(length(x),1), radius*2*ones(length(y),1)], ones(size(x,1),1), 4);

for i = 1:glovar.Dendrite_Number
    
    if i == 1
        newindex = 1:glovar.DendritePolyPointNumber(1);
        oldindex = 1:oldpolypointnumber(1);
    elseif i == DendriteNum
        newindex = newindex(end)+1:newindex(end)+glovar.DendritePolyPointNumber(i);
        if ~newdend
            oldindex = oldindex(end)+1:oldindex(end)+oldpolypointnumber(i);
        end
    else
        newindex = newindex(end)+1:newindex(end)+glovar.DendritePolyPointNumber(i);
        oldindex = oldindex(end)+1:oldindex(end)+oldpolypointnumber(i);
    end
    
    if i == DendriteNum
        pause(0.5)
        glovar.PolyLinePos(newindex(1):newindex(end)) = cellfun(@(x) x(:)', combinpos, 'UniformOutput', false);
        for j = 1:length(newindex)
            ROInum = newindex(j);
            glovar.PolyROI{ROInum} = rectangle('Position', glovar.PolyLinePos{newindex(j)}, 'EdgeColor', linecolor, 'Tag', ['Dendrite ', num2str(DendriteNum), ' PolyROI ', num2str(j)], 'Curvature', [1 1], 'ButtonDownFcn', {@Drag_Poly, ROInum});
        end
    else
        glovar.PolyLinePos(newindex) = cellfun(@(x) x(:)', tempPos(oldindex(1):oldindex(end)), 'UniformOutput', false);
        glovar.PolyROI(newindex) = cellfun(@(x) x, tempROI(oldindex(1):oldindex(end)), 'UniformOutput', false);
    end
    
%     glovar.PolyLineVertices{i} = [x(i-ExistingDROIs), y(i-ExistingDROIs)];
%     glovar.PolyLinePos{i} = [x(i-ExistingDROIs)-radius, y(i-ExistingDROIs)-radius, radius*2, radius*2];
    
end

if twochannels == 1

    axes(axes2)
    glovar.RedPolyLine = line(x,y, 'Tag', 'PolyLine', 'color', 'cyan');

    for i = 1:length(x);
        glovar.RedPolyLinePos{i} = [x(i)-radius, y(i)-radius, radius*2, radius*2];
        ROInum = i;
        glovar.RedPolyROI{i} = rectangle('Position', glovar.RedPolyLinePos{i}, 'EdgeColor', 'cyan', 'Tag', ['Dendrite ', num2str(DendriteNum), ' RedPolyROI', num2str(i)], 'Curvature', [1 1],'ButtonDownFcn', {@Drag_Poly, ROInum});
    end

end

set(glovar.figure.handles.DendritePolyLines_ToggleButton, 'Value', 0);
set(glovar.figure.handles.output, 'WindowButtonDownFcn', []);

 %%% Overwrite the previous existing global workspace with the newly imprinted one
 
gui_CaImageViewer = glovar;

