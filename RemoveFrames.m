function RemoveFrames(~,~,~)

global gui_CaImageViewer

framestocut = inputdlg('Exclude frames (use image number) :', 'Cut frame', 1, {'1'});

framestocut = str2num(framestocut{1});

imagestocut = framestocut; %%% The downsampled-by-50 number is applicable to the images being displayed, and so should be stored, but is not applicable (directly) to the actual frames

if length(framestocut) == 1
    framestocut = framestocut*50;
    framestocut = (framestocut(1)-49):framestocut(1);
else
    framestocut = framestocut*50;
    framestocut = (framestocut(1)-49):framestocut(end);
end

gui_CaImageViewer.GCaMP_Image = gui_CaImageViewer.GCaMP_Image(setdiff([1:length(gui_CaImageViewer.GCaMP_Image)], imagestocut));

gui_CaImageViewer.IgnoreFrames = framestocut; 
