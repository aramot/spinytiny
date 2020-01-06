function AmpHistogram(varargin)

h1 = waitbar(0, 'Initializing...');

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    activitydir = 'E:\ActivitySummary';
    cd(activitydir)
end

SpineAmp = cell(1,length(varargin));


for animal = 1:length(varargin)
    waitbar(animal/length(varargin),h1, ['Animal ', num2str(animal), '/', num2str(length(varargin))])
    experimentname = varargin{animal}; 
    activitydata = fastdir(activitydir, {experimentname, 'Summary'}, {'Poly', 'ZSeries'});
    for act = 1:length(activitydata)
        load(activitydata{act})
        eval(['Amplitudes = ', activitydata{act}(1:end-4), '.MeanEventAmp;'])
        clear(activitydata{act}(1:end-4))
        SpineAmp{animal} = [SpineAmp{animal}, Amplitudes];
    end
end

save('810 Spine Amplitude Distribution', 'SpineAmp')
close(h1)
figure; histogram(cell2mat(SpineAmp))
