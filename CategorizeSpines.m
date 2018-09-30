function CategorizeSpine(source, callbackdata)

global gui_CaImageViewer

source = get(source);
ROInum = regexp(get(gco, 'Tag'), '[0-9]*', 'match'); ROInum = str2num(ROInum{1});

if isfield(source, 'Label')
    switchitem = source.Label;
else
    switchitem = source.Text;
end

switch switchitem
    case 'Set as eliminated'
        set(gco, 'FaceColor',[1 0 0]) 
        gui_CaImageViewer.NewSpineAnalysisInfo.SpineList(ROInum) = 0; % what about case of new spines?-ZL
    case 'Set as active'
        set(gco, 'FaceColor', 'none')
        gui_CaImageViewer.NewSpineAnalysisInfo.SpineList(ROInum) = 1; %cancel out the marked "eliminated" spines-ZL
end


