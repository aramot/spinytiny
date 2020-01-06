function SDHistogram(varargin)

h1 = waitbar(0, 'Initializing...');

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    activitydir = 'E:\ActivitySummary';
    cd(activitydir)
end

SpineSD = cell(1,length(varargin));

for animal = 1:length(varargin)
    waitbar(animal/length(varargin),h1, ['Animal ', num2str(animal), '/', num2str(length(varargin))])
    experimentname = varargin{animal}; 
    activitydata = fastdir(activitydir, {experimentname, 'Summary'}, {'Poly', 'ZSeries'});
    for act = 1:length(activitydata)
        load(activitydata{act})
        eval(['Thresholds = ', activitydata{act}(1:end-4), '.SpineThresholds;'])
        clear(activitydata{act}(1:end-4))
        SpineSD{animal} = [SpineSD{animal}, Thresholds.LowerThreshold];
    end
end

close(h1)

binedges = [0:0.01:0.5];
WorkingFigure = findobj('Type', 'Figure', 'Name', 'SD Histogram');
if ~isempty(WorkingFigure)
    figure(WorkingFigure)
    hold on; 
    histogram(cell2mat(SpineSD), 'BinEdges', binedges, 'normalization', 'probability')
else    
    figure('Name', 'SD Histogram'); 
    xlabel('Standard Deviation of Fluorescence Traces')
    ylabel('Probability')
    histogram(cell2mat(SpineSD), 'BinEdges', binedges, 'normalization', 'probability')
end
