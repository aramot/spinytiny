function DeleteROI(hObject, eventData)

global gui_CaImageViewer

clicktype = get(gcbf, 'SelectionType');

if strcmp(clicktype, 'alt')
    ROI_tag = get(gco, 'Tag');
    ROI_num = regexp(ROI_tag, '\d+', 'match');
    ROI_num = str2num(ROI_num{1});
    delete(findobj('Tag', ROI_tag));
    oldspines = gui_CaImageViewer.ROI;
    oldsurrounds = gui_CaImageViewer.BackgroundROI;
        oldsurrounds(oldsurrounds==0) = NaN;
    oldspinetext = gui_CaImageViewer.ROItext;
    delete(findobj('Tag', 'ROI confine'));
    AllROIs = flipud(findobj('Type', 'rectangle', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}, '-and', '-not', {'-regexp', 'Tag', 'Background'}));         %%% ***** NOTE: this captures the ROIs in reverse order (i.e. top--> bottom is arranged as last-->first
    AllBackgrounds = nan(1,length(oldsurrounds));
    AllBackgrounds(logical(~isnan(oldsurrounds))) = flipud(findobj('Type', 'rectangle', '-and', {'-regexp', 'Tag', 'Background'}));    
    gui_CaImageViewer.ROI = [];                                                                   %%% Need to restructure the spine data array to account for the deletion
    gui_CaImageViewer.ROItext = [];
    gui_CaImageViewer.BackgroundROI = [];
    
    if ROI_num == 0
        gui_CaImageViewer.ROI = oldspines(2:end,:); % Need to include ROI0, which is actually the first in the list (oldspines(1))
        delete(AllROIs(1));
    elseif ROI_num < length(oldspines)-1
        gui_CaImageViewer.ROI(1:ROI_num) = oldspines(1:ROI_num);                  %%% captures all the spines from the first to the one before the one being deleted
        gui_CaImageViewer.ROItext(1:ROI_num) = oldspinetext(1:ROI_num);
        gui_CaImageViewer.ROI(ROI_num+1:length(oldspines)-1) = oldspines((ROI_num+2):length(oldspines)); %%% captures all the spines after the one being deleted and shifts it to fill the place of the one being deleted
        gui_CaImageViewer.ROItext(ROI_num+1:length(oldspines)-1) = oldspinetext((ROI_num+2):length(oldspines));
        
        delete(AllROIs(ROI_num+1));
        AllROIs = flipud(findobj('Type', 'rectangle', '-and', '-not', {'-regexp', 'Tag', 'Dendrite'}, '-and', '-not', {'-regexp', 'Tag', 'Background'}));
        for t = ROI_num:length(AllROIs)
            set(AllROIs(t), 'Tag', ['ROI', num2str(t-1)]);
            AllROItext = findobj('Tag', ['ROI', num2str(t), ' Text']);
            set(AllROItext, 'String', [num2str(t-1)]);
            set(AllROItext, 'Tag', ['ROI', num2str(t-1), ' Text'])
        end
        gui_CaImageViewer.Spine_Number = gui_CaImageViewer.Spine_Number-1;

        %%% Repeat the same for associated background ROIs
        
        if length(oldsurrounds) >1
            gui_CaImageViewer.BackgroundROI(1:ROI_num) = oldsurrounds(1:ROI_num);                  %%% captures all the spines from the first to the one before the one being deleted
            gui_CaImageViewer.BackgroundROI(ROI_num+1:length(oldspines)-1) = oldsurrounds((ROI_num+2):length(oldsurrounds)); %%% captures all the spines after the one being deleted and shifts it to fill the place of the one being deleted
            try
                delete(AllBackgrounds(ROI_num+1));
            catch
            end
            AllBackgrounds = flipud(findobj('Type', 'rectangle', '-and', {'-regexp', 'Tag', 'Background'}));
            for t = ROI_num:length(AllBackgrounds)
                set(AllBackgrounds(t), 'Tag', ['BackgroundROI', num2str(t-1)]);
            end
        end
            
    elseif ROI_num == length(oldspines)-1
        gui_CaImageViewer.ROI = oldspines(1:ROI_num);
        gui_CaImageViewer.ROItext = oldspinetext(1:ROI_num);
        gui_CaImageViewer.Spine_Number = gui_CaImageViewer.Spine_Number-1;
        delete(AllROIs(length(AllROIs)));
        if ~isempty(oldsurrounds)
            gui_CaImageViewer.BackgroundROI = oldsurrounds(1:ROI_num);
            if ~isnan(oldsurrounds(ROI_num+1))
                delete(AllBackgrounds(length(AllBackgrounds)))
            else
            end
        end
    end
end