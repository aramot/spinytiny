function ClipImageSeriesLength(~,~,currentlength)

global gui_CaImageViewer
%%% current length pulled from full length of gui_CaImageViewer.GCaMP_Image

newimageseriesvalues = inputdlg('Show through image:', 'Image timecourse clipper', 1, {num2str(currentlength)});

newimageseriesvalues = str2num(newimageseriesvalues{1});
if length(newimageseriesvalues)>1
    newseriesstart = newimageseriesvalues(1);
    newseriesend = newimageseriesvalues(end);
    newserieslength = length(newimageseriesvalues);
else
    newseriesstart = 1;
    newseriesend = newimageseriesvalues(1);
    newserieslength = length(1:newimageseriesvalues);
end

gui_CaImageViewer.imageserieslength = newserieslength;

gui_CaImageViewer.GCaMP_Image = gui_CaImageViewer.GCaMP_Image(newseriesstart:newseriesend);

set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Value', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Min', 1);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'Max', newserieslength);
set(gui_CaImageViewer.figure.handles.ImageSlider_Slider, 'SliderStep', [(1/(newserieslength-1)) (20/(newserieslength-1))]);  %%% The Slider Step values indicate the minor and major transitions, which should be represented by the desired transition as the numerator and the length of the series as the denominator
set(gui_CaImageViewer.figure.handles.Frame_EditableText, 'String', 1);
set(gui_CaImageViewer.figure.handles.SmoothingFactor_EditableText, 'String', '1');
