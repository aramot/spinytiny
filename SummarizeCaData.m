function [analyzed, poly] = SummarizeCaData(File, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function takes ROI information extracted using CaImageViewer and
%%% summarizes the intensity traces over the timecourse. The primary trace
%%% extraction method is performed using function 'AnalyzeTrace2'. This
%%% function handles file loading, parameter setting, and all basic signal
%%% processing post-extraction (including event detection). 

%%% Inputs: "Experimenter" and "File" are required, as they direct this
%%% function to the appropriate directory. "Experimenter" should be the
%%% user's first name as it appears on the server. "File" should be the
%%% filename structure: AA0DD_YYMMDD where AA = user itials, 0DD = animal
%%% number, and YYMMDD is the date of the experiment (example:
%%% NH052_190315).
%%%
%%% Other input arguments:
%%% currentsession: The session of the experiment; critical for
%%% longitudinal experiments;
%%% 
%%% ImagingSensor: when using a sensor other than GCaMP, it must be
%%% indicated here
%%%
%%% Opto: When using optogenetics, indicate "true"
%%%
%%% showFig: Indicate whether figures should be made to visualize data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ========================================================================
p = inputParser;

defaultExperimenter = 'Nathan';
defaultAnalyzer = 'Nathan';
validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x>0);
defaultsession = 1;
defaultsensor = 'GCaMP';
defaultOpto = false;
defaultshowFigoption = false;
defaultRouter = 'Original';

addRequired(p, 'File',@ischar);

addParameter(p, 'Experimenter', defaultExperimenter, @ischar);
addParameter(p, 'Analyzer', defaultAnalyzer, @ischar);
addParameter(p, 'currentsession',defaultsession, validScalarPosNum)
addParameter(p, 'ImagingSensor', defaultsensor, @ischar);
addParameter(p, 'Opto', defaultOpto, @islogical);
addParameter(p, 'showFig', defaultshowFigoption, @islogical);
addParameter(p, 'Router', defaultRouter, @ischar);

parse(p, File, varargin{:})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Router = p.Results.Router;
Experimenter = p.Results.Experimenter;
Analyzer = p.Results.Analyzer;
ImagingSensor = p.Results.ImagingSensor;
currentsession = p.Results.currentsession;
showFig = p.Results.showFig;
isOpto = p.Results.Opto;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Color Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lgray = [0.50 0.51 0.52];               brown = [0.28 0.22 0.14];
gray = [0.50 0.51 0.52];                lbrown = [0.59 0.45 0.28];
yellow = [1.00 0.76 0.05];              orange = [0.95 0.40 0.13];
lgreen = [0.55 0.78 0.25];              green = [0.00 0.43 0.23];
lblue = [0.00 0.68 0.94];               blue = [0.00 0.33 0.65];
magenta = [0.93 0.22 0.55];             purple = [0.57 0.15 0.56];
pink = [0.9 0.6 0.6];                   lpurple  = [0.7 0.15 1];
red = [0.85 0.11 0.14];                 black = [0 0 0];
dred = [0.6 0 0];                       dorange = [0.8 0.3 0.03];
bgreen = [0 0.6 0.7];

colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 
Scrsz = get(0, 'Screensize');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Find the file being called %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% First, preserve the called file name details, around which a
%%% constrained naming pattern can be based (saved file name is not always
%%% the same pattern, so impose your own pattern)

experimenter_initials = regexp(File, '[A-Z]{2,3}', 'match');
experimenter_initials = experimenter_initials{1};
animal = regexp(File, [experimenter_initials, '\d+[^_]'], 'match');
animal = animal{1};
Date = regexp(File, '\d{4,6}', 'match');
Date = Date{1};

FileOptions.Experimenter = Experimenter;
FileOptions.Analyzer = Analyzer;
FileOptions.IsOpto = isOpto;
FileOptions.Router = Router;

[FileInfo] = FindRawDataFile(File, FileOptions);

switch Router
    case 'Original'
        dirtouse = FileInfo.dirtouse;
        filetoload = FileInfo.filetoload;
        load([dirtouse,'\',filetoload])
        try
            eval(['File =', filetoload(1:end-4), ';'])    %%% Filename should always have the file extension at the end, in format .xyz; exclude these characters, as they are not included in the workspace
        catch
            temp = who(['*', experimenter_initials, '*']);
            eval(['File =', temp{1}, ';']);
        end
        filename = regexp(File.Filename, '.tif', 'split');
        filename = filename{1};
        File.Filename = filename;
    case 'Redo'
        dirtouse = FileInfo.dirtouse;
        load(FileInfo.PreviousFile)
        summaryfile = [File, '_Summary'];
        eval(['File = ', summaryfile, ';'])
        clear(summaryfile)
end
analyzed = File;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% =====================================================================%%
%%% Pull imaging bout information: for some sensors, like iGluSNFR, there
%%% appears to be photoactivation for a few seconds after starting imaging;
%%% these frames should be blanked. (Note, this code is slow and is 
%%% probably a waste of time for other sensors, e.g. GCaMP)

if strcmpi(ImagingSensor, 'GluSNFR')
    switch Router
        case 'Original'
            filebits = regexp(dirtouse, filesep, 'split');
            if isempty(filebits{end})   %%% happens when the path name ends with a file seperator ("\"); regexp takes the component after the split, even if it's empty
                filebits = filebits(1:end-1);
            end
            uponefolder = fullfile(filebits{1:end-1});
            [Options.ImageFramesatBoutSeparations] = FindNewAcquisitionStart(uponefolder);
            analyzed.ImageFramesatBoutSeparations = Options.ImageFramesatBoutSeparations;   %%% Change this after re-running the analysis the first time! Much easier if this is a saved variable!
        case 'Redo'
            Options.ImageFramesatBoutSeparations = File.ImageFramesatBoutSeparations;
    end
else
    Options.ImageFramesatBoutSeparations = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Controlled variables
%%%%%%%%%%%%%%%%%%%%%%%%

analyzed.UsePreviousPreferences = 0;

foldertouse = 'E:\ActivitySummary';

if analyzed.UsePreviousPreferences
    cd(foldertouse)
    try
        load([animal, '_', Date, '_Summary']);
        eval(['SummaryFile = ', animal, '_', Date, '_Summary;'])
    catch
        return
    end
    spinethreshmultiplier = SummaryFile.spinethresholdmultiplier;
    spinesmoothwindow = SummaryFile.spinesmoothwindow;
    Dendthreshmultiplier = SummaryFile.Dendthreshmultiplier;
    dendsmoothwindow = SummaryFile.dendsmoothwindow;  
    ClusterThresh = 0.5;
    SpectralLengthConstant = SummaryFile.SpectralLengthConstant;
else
    if strcmpi(ImagingSensor, 'GCaMP')
        spinethreshmultiplier = 3;       %%% stdev multiplier for event detection
        ImagingFrequency = 30.49;
        smooth_window_in_seconds = 0.5;
    elseif strcmpi(ImagingSensor, 'GluSnFR')
        spinethreshmultiplier = 2;       %%% 
        ImagingFrequency = 58.30;
        smooth_window_in_seconds = 0.5;
    end 
    spinesmoothwindow = round(ImagingFrequency)*smooth_window_in_seconds;
    Dendthreshmultiplier = 3;
    dendsmoothwindow = spinesmoothwindow;
    alphaminimum = 0.5;
    polypercentrequirement = 0.75;
    ClusterThresh = 0.5;
    SpectralLengthConstant = 10;
end

analyzed.spinethresholdmultiplier = spinethreshmultiplier;
analyzed.spinesmoothwindow = spinesmoothwindow;
analyzed.Dendthreshmultiplier = Dendthreshmultiplier;
analyzed.dendsmoothwindow = dendsmoothwindow;
analyzed.ClusterThresh = ClusterThresh;
analyzed.SpectralLengthConstant = SpectralLengthConstant;
analyzed.ImagingSensor = ImagingSensor;

%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %%% Select which spine to plot %%%
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if File.NumberofSpines ==  0 || File.NumberofSpines ~= length(File.Fluorescence_Measurement)
    File.NumberofSpines = length(File.Fluorescence_Measurement);
    analyzed.NumberofSpines = length(File.Fluorescence_Measurement);
end
% 
SpineNo = randi(File.NumberofSpines,1); %%% Will choose a random spine from the available ones for this file
% SpineNo = 20;  %%% Manually select spine to be considered
if SpineNo>File.NumberofSpines
    SpineNo = randi(File.NumberofSpines,1); %%% Will choose a random spine from the available ones for this file
end

DendNum = File.NumberofDendrites;
DendriteChoice =  find(~cell2mat(cellfun(@(x) isempty(find(x == SpineNo,1)), File.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located

%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select which spine data to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Options:    1) File.Fluorescence_Measurement %%% Raw data
%%%             2) File.deltaF                   %%% Baseline-subtracted
%%%             3) File.dF_over_F                %%% Baseline-sub and div.
%%%             4) File.SynapticEvents           %%% All above + dend-subtract

spinetraceoption = 1;

if spinetraceoption == 1
    spinedatatouse = File.Fluorescence_Measurement;
    correspondingnewdata = analyzed.Fluorescence_Measurement; %%% The "new" data is sometimes changed in parallel, and this should always be accounted for
elseif spinetraceoption == 2
    spinedatatouse = File.deltaF;
    correspondingnewdata = analyzed.deltaF;
elseif spinetraceoption == 3
    spinedatatouse = File.dF_over_F;
    correspondingnewdata = analyzed.dF_over_F;
elseif spinetraceoption ==4
    spinedatatouse = File.SynapticEvents;
    correspondingnewdata = analyzed.SynapticEvents;
end

%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spinedriftbaseline = zeros(length(File.Fluorescence_Measurement),length(File.Fluorescence_Measurement{1}));
processed_dFoF = zeros(length(File.Fluorescence_Measurement),length(File.Fluorescence_Measurement{1}));
numberofSpines = File.NumberofSpines;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Options.SmoothWindow = spinesmoothwindow;
Options.TraceOption = spinetraceoption;
Options.ImagingSensor = ImagingSensor; 
Options.ImagingFrequency = ImagingFrequency;
Options.Threshold = spinethreshmultiplier;
Options.BeingAnalyzed = 'Spine';


%% ========================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Process Trace %%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numberofSpines
    [spinedriftbaseline(i,:), processed_dFoF(i,:)] = AnalyzeTrace(spinedatatouse{i}, Options);
end

analyzed.Processed_dFoF = processed_dFoF;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% Event detection %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[square, floored, threshold, Method] =  DetectEvents2(processed_dFoF, Options);

frequency = nan(numberofSpines,1);
for i = 1:numberofSpines
    frequency(i,1) = (nnz(diff(square(i,:)>0.5)>0)/((length(File.Time)/ImagingFrequency)/60))';
end

analyzed.ActivityMap = square;
analyzed.Frequency = frequency;
analyzed.SpineThresholds = threshold;
analyzed.ThresholdMethod = Method;


%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 1 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Raw data and estimated baseline

if showFig
    figure('Position', [10, Scrsz(4)/2.5,Scrsz(3)/2,Scrsz(4)/2]); 
    rawplot = subplot(2,2,1:2);
    plot(File.Time, spinedatatouse{SpineNo}, 'Color', [0.2 0.2 0.2]); hold on;
    axpos = get(rawplot, 'Position');
    plot(File.Time, spinedriftbaseline(SpineNo, :), 'Color', red, 'Linewidth', 3)
    ylabel(['Raw trace for spine no. ', num2str(SpineNo)])
    title('Example of event detection')
    legend({'Raw Data', 'Baseline'}, 'Location', 'SouthEastOutside');
else
end

%%% Processed data and event counts

if showFig
    procplot = subplot(2,2,3:4);
    hold on; plot(File.Time, processed_dFoF(SpineNo,:), 'Color',[0.2 0.2 0.2], 'LineWidth', 1);
    linkaxes([rawplot,procplot], 'x');
    plot(File.Time, threshold.UpperThreshold(SpineNo)*square(SpineNo,:),'Color', lblue, 'LineWidth', 2);
    k = threshold.UpperThreshold(SpineNo)*ones(1,length(File.Time));
    plot(File.Time, k', '--', 'Color', lgreen, 'LineWidth', 2)
    xlabel('Frames')
    ylabel(['Smoothed dF/F for spine no. ', num2str(SpineNo)])
else
end

%% ========================================================================
%%%%%%%%%%%%%%%%%%%%%%%% Amplitude Calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%

amp = zeros(1,length(File.Fluorescence_Measurement));
for i = 1:size(square,1)
%     [peaks, loc] = findpeaks(smooth(floored(i,:),10), 'MinPeakDistance', 5);   %%% The "floored" variable is used to count events, and so should be used to find the corresponding amplitude
    bounds = find(diff([Inf,square(i,:),Inf]));
    event_separated_binarydata = mat2cell(square(i,:)', diff(bounds));
    periodswithevents = cellfun(@any, event_separated_binarydata);
    event_separated_floored_data = mat2cell(floored(i,:)', diff(bounds));
    amplitude = cellfun(@(x) prctile(x,99), event_separated_floored_data(periodswithevents));
    amp(1,i) = mean(amplitude);
end

analyzed.MeanEventAmp = amp;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dendrite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% Dendthreshmultiplier = 0.5;
%%%%%%%%%%%
%%%%%%%%%%%%%%%%

Ddriftbaseline = zeros(DendNum,length(File.Dendrite_dFoF(1,:)));
processed_Dendrite = zeros(DendNum, length(File.Dendrite_dFoF(1,:)));
Damp = zeros(DendNum,1);
Dfreq = zeros(DendNum,1);
globaldendriteevents = cell(1,DendNum);

cumulativepolypoints = cumsum(File.DendritePolyPointNumber);
File.Poly_Fluorescence_Measurement = File.Poly_Fluorescence_Measurement(~cell2mat(cellfun(@(x) isempty(x), File.Poly_Fluorescence_Measurement, 'UniformOutput', false))); %%% Remove any empty cells
% if length(File.Poly_Fluorescence_Measurement) ~= sum(File.DendritePolyPointNumber)
%     disp(['File ', File.Filename, ' has weird poly point problems... check it, broh'])
%     return
% end

Pdriftbaseline = zeros(cumulativepolypoints(end),length(File.Dendrite_dFoF(1,:)));

compiledDendData = zeros(DendNum, length(File.Dendrite_dFoF));
compiledProcessedDendData = zeros(DendNum, length(File.Dendrite_dFoF));
dendritedatatouse = zeros(DendNum, length(File.Dendrite_dFoF));
rawpoly = cell(1,cumulativepolypoints(end));
processed_PolyROI = cell(1,cumulativepolypoints(end));

for i = 1:DendNum

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%
    %%% Perform event detection for EACH dendritic ROI
    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if i == 1
        polyptstouse = 1:cumulativepolypoints(i);
    else
        polyptstouse = cumulativepolypoints(i-1)+1:cumulativepolypoints(i);
    end


    for j = polyptstouse(1):polyptstouse(end)
        
        rawpoly{j} = File.Poly_Fluorescence_Measurement{j};
        
        %%%%%%%%%%%%%%%%%%%%%%
        
        Options.SmoothWindow = dendsmoothwindow;
        Options.TraceOption = 1;
        Options.BeingAnalyzed = 'Poly';

        %%%%%%%%%%%%%%
        [Pdriftbaseline(i,:), processed_PolyROI{j}] = AnalyzeTrace(rawpoly{j}, Options);
        %%%%%%%%%%%%%%
        
    end
%     poly.PolyROI_Binarized{i} = square_Poly; 
    poly.Processed_PolyROI{i} = cell2mat(processed_PolyROI(polyptstouse));

    compiledDendData(i,:) = nanmean(cell2mat(rawpoly(polyptstouse)'));
    compiledProcessedDendData(i,:) = nanmean(cell2mat(processed_PolyROI(polyptstouse)),2);
    
%     globaldendevents = sum(square_Poly{i});
%     globaldendevents(globaldendevents<polypercentrequirement*size(square_Poly{i},1)) = 0;     %%% If > x% of the PolyROIs are active, it's probably a true global dendrite event
%     globaldendevents(globaldendevents~=0) = 1;
%         
%     globaldendriteevents{i} = globaldendevents;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%
    %%% Perform event detection for the dendrite as a whole
    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dendritedatatouse(i,:) = compiledDendData(i,:); 

    Options.SmoothWindow = dendsmoothwindow;
    Options.TraceOption = 1;
    Options.Threshold = Dendthreshmultiplier;
    Options.BeingAnalyzed = 'Dendrite';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Ddriftbaseline(i,:), processed_Dendrite(i,:)] = AnalyzeTrace(dendritedatatouse(i,:), Options);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[square_Dend, floored_Dend, ~] =  DetectEvents2(processed_Dendrite, Options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dglobal = zeros(DendNum,length(processed_Dendrite(1,:)));
dendtimebuffer = round(ImagingFrequency/4);

for i = 1:File.NumberofDendrites
%     bound = find(diff([Inf, square_Dend(i,:), Inf])~=0);
%     epochs = mat2cell(square_Dend(i,:)', diff(bound));
%     polyepoch = mat2cell(square_Poly{i}', diff(bound));
%     Dglobal(i,:) = cell2mat(cellfun(@(x,y) x*y, cellfun(@(x) sum(x)>0.1*length(x), cellfun(@round, cellfun(@mean, polyepoch, 'UniformOutput', false), 'UniformOutput', false), 'UniformOutput', false), epochs, 'Uni', false));
% %     Dglobal(i,:) = square_Dend(i,:).*globaldendriteevents{i};
    
    Dglobal(i,:) = square_Dend(i,:);
          
    rises = find(diff(Dglobal(i,:))>0);
    falls = find(diff(Dglobal(i,:))<0);

    earlier_rises = rises-dendtimebuffer;
        earlier_rises(earlier_rises<1) = 1;
    later_falls = falls+dendtimebuffer;
        later_falls(later_falls>length(Dglobal(i,:))) = length(Dglobal(i,:));

    for p = 1:length(earlier_rises)
        Dglobal(i,earlier_rises(p):rises(p)) = 1;
    end
    for p = 1:length(later_falls)
        Dglobal(i,falls(p):later_falls(p)) = 1;
    end
end


for i = 1:size(floored_Dend,1)
    [Dpeaks, ~] = findpeaks(smooth(floored_Dend(i,:),10), 'MinPeakDistance', 5);   %%% The "floored" variable is used to count events, and so should be used to find the corresponding amplitude
    Damp(i,1) = mean(Dpeaks);
    Dfreq(i,1) = length(peaks);
end

%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 2 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

if showFig
    figure('Position', [10, 50 ,Scrsz(3)/2,Scrsz(4)/2]); hold on;
    rawdend = subplot(2,2,1:2);
    plot(File.Time, dendritedatatouse(DendriteChoice,:), 'Color', [0.2 0.2 0.2]);
    hold on; 
    plot(File.Time, Ddriftbaseline(DendriteChoice,:), 'r', 'LineWidth', 2);
    legend({'Raw Data', 'Baseline'}, 'Location', 'SouthEastOutside')
    
    xlabel('Frames')
    ylabel(['Raw Trace for Dendrite ', num2str(DendriteChoice)])
    
    procdend = subplot(2,2,3:4);
    plot(File.Time, processed_Dendrite(DendriteChoice,:), 'Color', [0.2 0.2 0.2]); hold on;
%     plot(File.Time(Dend_Locations{DendriteChoice}), Dend_Peaks{DendriteChoice}+0.05, 'kv', 'markerfacecolor', lgreen);
    plot(File.Time, square_Dend(DendriteChoice,:)*1.5, 'Color', blue, 'Linewidth', 2)
    plot(File.Time, Dglobal(DendriteChoice,:)*1.5, 'Color', orange, 'Linewidth', 2)
    
    legend({'Processed Data', 'Binary Activity', 'Global Event'}, 'Location', 'SouthEastOutside')        
    pause(0.1)
    axpos2 = get(procdend, 'Position');
    set(rawdend, 'Position', [axpos2(1), axpos(2), axpos2(3), axpos(4)])
    set(procdend, 'Box', 'on')

%     plot(File.Time, m, '--', 'Color', purple)
    linkaxes([rawplot, procplot,rawdend, procdend], 'x');

    xlabel('Frames')
    ylabel(['Events for Dendrite ', num2str(DendriteChoice)])
    title('Example of event detection')

else
end

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

Dglobal(Dglobal>1) = 1;

analyzed.Dendrite_Binarized = Dglobal;
analyzed.Processed_Dendrite_dFoF = processed_Dendrite;
% analyzed.Baseline_Subtracted_Dend = BaselineSubtractedDend;
analyzed.Compiled_Dendrite_Fluorescence_Measurement = compiledDendData;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Dendrite Subtraction (comment out if unwanted) %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(File.Fluorescence_Measurement) ~= File.SpineDendriteGrouping{end}(end)
    File.SpineDendriteGrouping{end} = File.SpineDendriteGrouping{end}(1):length(File.Fluorescence_Measurement);
    analyzed.SpineDendriteGrouping{end} = analyzed.SpineDendriteGrouping{end}(1):length(analyzed.Fluorescence_Measurement);
end
% 

analyzed = DendriteSubtraction(analyzed, 'Initial');

if showFig
    axes(procplot)
    plot(analyzed.Floored_DendriteSubtracted(SpineNo, :), 'Color', 'r', 'Linewidth', 1.5)
    legend({'Processed Data', 'Binary Activity', 'Threshold', 'Dend-subtracted'}, 'Location', 'SouthEastOutside')
    pause(0.1)
    axpos3 = get(procplot, 'Position');
    set(rawplot, 'Position', [axpos3(1), axpos(2), axpos3(3), axpos(4)])
    set(procplot, 'Box', 'on')
end

% figure; %% plot 100 random fits
% for i = 1:100
%     subplot(10,10,i); hold on;
%     randspine = randi(numberofSpines);
%     parentDend = find(~cell2mat(cellfun(@(x) isempty(find(x == randspine,1)), File.SpineDendriteGrouping, 'Uni', false)));
%     plot(processed_Dendrite(parentDend,:), processed_dFoF(randspine,:), 'ok')
%     alphapos = find(File.SpineDendriteGrouping{find(~cell2mat(cellfun(@(x) isempty(find(x == randspine,1)), File.SpineDendriteGrouping, 'Uni', false)))}==randspine);
%     plot(min(processed_Dendrite(parentDend,:)):max(processed_Dendrite(parentDend,:))/100:max(processed_Dendrite(parentDend,:)), alpha{parentDend}(2, alphapos).*[min(processed_Dendrite(parentDend,:)):max(processed_Dendrite(parentDend,:))/100:max(processed_Dendrite(parentDend,:))], 'r', 'Linewidth', 2)
%     text(-max(processed_Dendrite(parentDend,:)), max(processed_dFoF(randspine,:)), ['S ', num2str(randspine), ',D ', num2str(parentDend)], 'Fontsize', 8, 'Color', 'b')
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 3 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

causal = zeros(numberofSpines,size(square,2));
back = 10;   %%% Number of frames prior to a dendritic event that a spine must be active to be considered "causal"

synapseOnlyActivity = zeros(numberofSpines,length(square));
synapticEvents = zeros(numberofSpines, length(square));
synapseOnlyFreq = zeros(numberofSpines,1);
withAPs = zeros(numberofSpines, length(square));
withAPsFreq = zeros(numberofSpines,1);

for i = 1:numberofSpines
    for j = 1:DendNum
        if ~isempty(find(File.SpineDendriteGrouping{j} == i,1))
            onDend = j;
            %%%
            %%%
            %%%
            %%% This is the last decision variable on whether to use
            %%% dendrite-corrected or dendrite-removed data!!!
            %%%
            if strcmpi(ImagingSensor, 'GCaMP')
                    synapticEvents(i,:) = analyzed.SynapseOnlyBinarized_DendriteSubtracted(i,:)-square_Dend(onDend,:);
            elseif strcmpi(ImagingSensor, 'GluSNFR')
                    synapticEvents(i,:) = square(i,:);
            end
            synapseOnlyActivity(i,:) = processed_dFoF(i,:).*synapticEvents(i,:);
%             synapticEvents(i,:) = square_Ds(i,:);
            %%%
            %%%
            %%%
            %%%
            %%%
            synapticEvents(i,synapticEvents(i,:)<1) = 0;
            synapseOnlyFreq(i,1) = (nnz(diff(synapticEvents(i,:)>0.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
            %%%
            withAPs(i,:) = analyzed.SynapseOnlyBinarized_DendriteSubtracted(i,:)+logical(square_Dend(onDend,:));   %%% Add binarized spine data to dendrite data to illustrate when dendrite and spines are co-firing
            %%%
            withAPsFreq(i,1) = (nnz(diff(withAPs(i,:)>1.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
            withAPs(i,(withAPs(i,:)==1)) = 0;
            withAPs(i,(withAPs(i,:)==2)) = 1;
%             dendOnly(i,:) = square_Dend(onDend,:)-square(i,:);
            withAPtimes = find(withAPs(i,:));
            causalwindows = withAPtimes-back;
            for n = 1:length(causalwindows)
                causal(i,withAPtimes(n):causalwindows(n)) = 1;
            end
            causal(i,:) = causal(i,:)-Dglobal(onDend,:);
        else
        end
    end
end

if showFig
    rasterfig = figure('Position', [Scrsz(3)/2, Scrsz(4)/2.5,Scrsz(3)/2,Scrsz(4)/2]); 
    if strcmpi(ImagingSensor, 'GCaMP')
        rasterdata = analyzed.SynapseOnlyBinarized_DendriteSubtracted;
    elseif strcmpi(ImagingSensor, 'GluSNFR')
        rasterdata = square;
    end
    rasterdata(isnan(rasterdata))=0;
    imagesc(rasterdata)
    set(rasterfig, 'ColorMap', hot)
    xlabel('Frames');
    ylabel('Spine number');
    xlim([0 size(square,2)+1]);
    ylim([0 numberofSpines+1]);
    title('Synaptic Events For All Spines');
end

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

Dfrequency = zeros(DendNum, 1);
for i = 1:DendNum
    Dfrequency(i,1) = (nnz(diff(square_Dend(i,:)>0.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
end

disp(['Dendritic Frequencies: ', num2str(Dfrequency(:)')])

synapticEvents(synapticEvents<0) = 0;
synapseOnlyActivity(synapseOnlyActivity<0) = 0;

analyzed.Dendritic_Frequency = Dfrequency;
analyzed.Dendritic_Amp = Damp;
analyzed.SynapseOnlyActivity = synapseOnlyActivity;
analyzed.SynapseOnlyBinarized = synapticEvents;
analyzed.OverallSpineActivity = square;
analyzed.SynapseOnlyFreq = synapseOnlyFreq;
analyzed.SpikeTimedEvents = withAPsFreq;
analyzed.CausalBinarized = causal;

% spec = 'Approximately %2.0f percent of spines showed co-active firing\n';
% fprintf(spec, coactive_percentage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 4 : Spatial Analysis %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Current measurements can be found on the imaging computer; 512x512 and
%%% 1024x1024 images are taken of a fluorescent ruler. Pixels per micron at
%%% 1x zoom at 1024x1024 = 1; at 512x512 = 0.5


%%% Note: none of this is necessary when redoinganalyis, as this should
%%% have already been accurately calculated, and just adds to analysis time
%%% otherwise; 

dirtouse = FileInfo.dirtouse;

seps = strfind(dirtouse, filesep);
separation_indices = [0,seps,length(dirtouse)];
file_subdivs = mat2cell(dirtouse, 1, diff(separation_indices));

experiment = regexp(FileInfo.filetoload, '[A-Z]{2,3}\d+[_]\d+', 'match');
experiment = experiment{1};
animal = experiment(1:5);
date = regexp(dirtouse, '\d{6}', 'match'); 
if ~isempty(date)
    date = date{1};
    date_address = find(cellfun(@any, regexp(file_subdivs, date)));
    date_spec_folder = fullfile(file_subdivs{1:date_address});

    sample_image_file = fastdir(date_spec_folder, '1_summary.mat');
    load([date_spec_folder, sample_image_file{1}], 'info_first');
    zoomvalueline = regexp(info_first.Software, 'SI.hRoiManager.scanZoomFactor = \d+.\d+', 'match');
    zoomvalue = regexp(zoomvalueline{1}, '\d+.\d+', 'match'); zoomvalue = zoomvalue{1};
    File.ZoomValue = zoomvalue;
    analyzed.ZoomValue = zoomvalue;
    clear info_first
else
    manualzoominput = inputdlg('No raw data files; enter zoom', 'Zoom value', 1, {'12.1'});
    zoomvalue = str2num(manualzoominput{1});
end

switch Router
    case 'Original'
        pixpermicron = 0.5;
%         if ~isempty(strfind(File.Filename, 'ZL')) || ~isempty(strfind(File.Filename, 'PY'))
%             File.ZoomValue = 8.5;
%         end
        if isfield(File, 'ZoomValue')
            if File.ZoomValue ~= 0
                if ischar(File.ZoomValue)
                    File.ZoomValue = str2num(File.ZoomValue);
                end
                pixpermicron = (pixpermicron*File.ZoomValue);
            end
        end
        SpineToSpineDistance = nan(numberofSpines,numberofSpines);

        %%% Correlate spines on the same dendrite as a function of dendritic
        %%% distance between them

        if DendNum ~= length(File.DendritePolyPointNumber)
            error('The polyline ROIs are not binned correctly; this file needs to be re-analyzed!')
        end
        counter = 1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ROIfile = fastdir(dirtouse, 'DrawnBy', 'Volume');
        if isempty(ROIfile)
            dirtouse = uigetdir([],'Select path for ROI file');
            ROIfile = fastdir(dirtouse, 'DrawnBy', 'Volume');
        end
        if length(ROIfile)>1
            filesdrawnbyuser = find(~cellfun(@isempty, cellfun(@(x) regexp(x, Analyzer, 'once'), ROIfile, 'uni', false)));
            if length(filesdrawnbyuser) == 1
                ROIfile = ROIfile{filesdrawnbyuser};
            else
                dirc = dir(dirtouse);
                dirc = dirc(~cellfun(@isdir,{dirc(:).name}));
                dirc = dirc(cell2mat(cellfun(@(x) ~isempty(regexp(x, 'DrawnBy')), {dirc(:).name}, 'uni', false)));
                [~,I] = max([dirc(:).datenum]);
                if ~isempty(I)
                    latestfile = dirc(I).name;
                end
                ROIfile = latestfile; 
            end
        else
            ROIfile = ROIfile{1};
        end
        load([dirtouse, '\', ROIfile])
        eval(['ROIfile = ', ROIfile(1:end-4), ';']);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if isstruct(ROIfile.ROIPosition{1})
            method = 'new';
        else
            method = 'old';
        end

        for i = 1:File.NumberofDendrites
            Branch{i}(1,1) = 0;

            switch method
                case 'old'
                    PolyX_center{i}(1,1) = File.PolyLinePos{counter}(1)+File.PolyLinePos{counter}(3)/2; %%% The old method of ROI drawing used rectangles, which has a 1x4 position dimension [x,y,w,h]
                    PolyY_center{i}(1,1) = File.PolyLinePos{counter}(2)+File.PolyLinePos{counter}(4)/2;
                case 'new'
                    PolyX_center{i}(1,1) = File.PolyLinePos{counter}(1);     %%% The new way of drawing ROIs uses ellipse objects, which return the coordinates of the center of the ellipse [x,y];
                    PolyY_center{i}(1,1) = File.PolyLinePos{counter}(2);
            end
            Pix_Dist{i}(1,1) = 0;
            Mic_Dist{i}(1,1) = 0;
            for j = 2:File.DendritePolyPointNumber(i)
                counter = counter+1;
                switch method
                    case 'old'
                        PolyX_center{i}(1,j) = File.PolyLinePos{counter}(1)+File.PolyLinePos{counter}(3)/2;
                        PolyY_center{i}(1,j) = File.PolyLinePos{counter}(2)+File.PolyLinePos{counter}(4)/2;
                    case 'new'
                        PolyX_center{i}(1,j) = File.PolyLinePos{counter}(1);
                        PolyY_center{i}(1,j) = File.PolyLinePos{counter}(2);
                end
                Pix_Dist{i}(1,j) = sqrt((PolyX_center{i}(1,j)-PolyX_center{i}(j-1)).^2 + (PolyY_center{i}(j)-PolyY_center{i}(j-1)).^2);
                Mic_Dist{i}(1,j) = Pix_Dist{i}(1,j)/pixpermicron;
            end
            counter = counter+1;
            for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
                switch method 
                    case 'old'
                        spine_pos{j} = [File.ROIPosition{j+1}(1)+File.ROIPosition{j+1}(3)/2, File.ROIPosition{j+1}(2)+File.ROIPosition{j+1}(4)/2]; %%% Don't forget that position 1 in this cell is actually ROI0/background ROI!!!! 
                    case 'new'
                        spine_pos{j} = ROIfile.ROIPosition{j+1}.Center;
                        analyzed.ROIPosition{j+1} = [ROIfile.ROIPosition{j+1}.Center, 0, 0];
                end
                [~, index] = min(sqrt(((PolyX_center{i}-spine_pos{j}(1)).^2)+(PolyY_center{i}-spine_pos{j}(2)).^2)); %%% Find the closest ROI along the dendrite (usually spaced evenly and regularly enough that it should be right at the base of the spine, more or less)
        %         spine_address{j} = [PolyX_center{i}(1,index), PolyY_center{i}(1,index)]; %%% Set a spine's "address" as that point along the dendrite, found above
                spine_address{j}.Dendrite = i;
                spine_address{j}.Index = index;
            end
            if length(File.SpineDendriteGrouping{i})>1
                for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end-1)
                    for k = (j+1):File.SpineDendriteGrouping{i}(end)
                        [val, ~] = sort([spine_address{j}.Index,spine_address{k}.Index]);
                        lower = val(1);
                        higher = val(2);
                        SpineToSpineDistance(j,k) = abs(sum(Mic_Dist{spine_address{j}.Dendrite}(lower:higher))-Mic_Dist{spine_address{j}.Dendrite}(lower));  %%% Find the sum of linear distances from the current point to the nearby spine
                    end
                end 
            else
            end
        end
        nonnan = find(~isnan(SpineToSpineDistance)); %% Find the indices for  non-NaN values
        Distances = SpineToSpineDistance(nonnan);
        analyzed.DendriteLengthValues = Mic_Dist;
        analyzed.SpineToSpineDistance = Distances;
        analyzed.DistanceHeatMap = SpineToSpineDistance;
        clear ROIfile;
    case 'Redo'

        nonnan = find(~isnan(File.DistanceHeatMap));
end


analyzed.SpineAddresses = spine_address;

[r_all, ~] = corrcoef(square');
r_all(isnan(r_all)) = 0;
OverallCorrelations = r_all;
% OverallPvalue = p_all;

[r, p] = corrcoef(analyzed.SynapseOnlyBinarized_DendriteSubtracted');
r(isnan(r)) = 0;
SpineToSpineCorrelation = r;
SpineToSpinePValue = p;

[r_AP, p_AP] = corrcoef(withAPs');
r_AP(isnan(r_AP)) = 0;
SpwAPCorrelation = r_AP;
SpwAP_PValue = p_AP;

[r_causal, p_causal] = corrcoef(causal');
r_causal(isnan(r_causal)) = 0;
CausalCorrelation = r_causal;
CausalPValue = p_causal;


if strcmpi(ImagingSensor, 'GCaMP')
        Correlations = SpineToSpineCorrelation;
elseif strcmpi(ImagingSensor, 'GluSNFR')
        Correlations = OverallCorrelations;
else
end
pValues = SpineToSpinePValue(nonnan);
wAPCorrelations = SpwAPCorrelation(nonnan);
SpwAP_PValue = SpwAP_PValue(nonnan);
CausalCorrelations = CausalCorrelation(nonnan);
CausalPValues = CausalPValue(nonnan);


analyzed.OverallCorrelationsHeatMap = OverallCorrelations;
analyzed.OverallCorrelation = OverallCorrelations(nonnan);
analyzed.SpineToSpineCorrelation = Correlations(nonnan);
analyzed.CorrelationHeatMap = SpineToSpineCorrelation;
analyzed.PValueHeatMap = SpineToSpinePValue;
analyzed.CausalHeatMap = CausalCorrelation;
analyzed.CausalPValueHeatMap = CausalPValue;
analyzed.SpinewithAP_Correlation = wAPCorrelations;
analyzed.SpineToSpine_PValues = pValues;
analyzed.SpinewithAP_PValues = SpwAP_PValue;
analyzed.CausalCorrelations = CausalCorrelations;
analyzed.CausalPValues = CausalPValues;

%% ========================================================================
%%%%%%%%%% Correlate distant spines on separate dendrites %%%%%%%%%%%%%%%%%

switch Router
    case 'Original'
        if length(File.SpineDendriteGrouping) > 1
            FarSpineDist = nan(File.SpineDendriteGrouping{end-1}(end), File.SpineDendriteGrouping{end}(end)); %%% Pre-allocate NaNs so that unused indices are NaN and not zero (to disambiguate data from place holders)
            FarSpineCorrelation = nan(File.SpineDendriteGrouping{end-1}(end), File.SpineDendriteGrouping{end}(end));
        else
            FarSpineDist = [];
            FarSpineCorrelation = [];
        end

        if File.NumberofDendrites > 1 
            nofSp = File.NumberofSpines;
            nofD = File.NumberofDendrites;
            farCorr = nan(nofSp, nofSp);
            farDist = nan(nofSp, nofSp);     
            for DendCount = 1:nofD-1                                                                        %%% For each dendrite
                sptarg = 1; %%% spine that is being compared to all others (in 1v2, 1v3, etc. setup)
                for j = File.SpineDendriteGrouping{DendCount}(1):File.SpineDendriteGrouping{DendCount}(end) %%% For each spine on the current dendrite
                    spcomp = 1; %%% comparator spine
                    for k = File.SpineDendriteGrouping{DendCount+1}(1):File.SpineDendriteGrouping{end}(end) %%% Compare to each spine on a different dendrite
                        FarSpineDist(j,k) = sqrt((spine_pos{j}(1)-spine_pos{k}(1)).^2 + (spine_pos{j}(2)-spine_pos{k}(2)).^2); 
                        FarSpineDist(j,k) = FarSpineDist(j,k)/pixpermicron;
                        if sum(synapticEvents(j,:))>0 && sum(synapticEvents(k,:))>0
                            [r, p] = corrcoef(synapticEvents(j,:)', synapticEvents(k,:)');
                            FarSpineCorrelation(j,k) = r(1,2);
                            FarPValue(j,k) = p(1,2);
                        else
                            FarSpineCorrelation(j,k) = 0;
                            FarPValue(j,k) = 1;
                        end
                        spcom = spcomp+1;
                    end
                    sptarg = sptarg + 1;
                end
            end
        else
            FarSpineDist = 0;
            FarSpineCorrelation = 0;
        end
        nonNaN = find(~isnan(FarSpineDist));
        FarCorrelations = FarSpineCorrelation(nonNaN);
        FarDistances = FarSpineDist(nonNaN);
case 'Redo'
    FarDistances = File.FarSpineToSpineDistance;
    FarCorrelations = Correlations(find(isnan(File.DistanceHeatMap)));
end

analyzed.FarSpineToSpineDistance = FarDistances;
analyzed.FarSpineToSpineCorrelation = FarCorrelations;

%% ========================================================================

if showFig
    figure('Position', [Scrsz(3)/2, 50 ,Scrsz(3)/2,Scrsz(4)/2]); 
    subplot(1,3,1)
        plot(Distances, Correlations(nonnan), 'ok')
    %     plot(BottomGroup(:,1), BottomGroup(:,2), 'o', 'Color', [0.2 0.2 0.2]); hold on;
    %     plot(MiddleGroup(:,1), MiddleGroup(:,2), 'o', 'Color', red)
    %     plot(TopGroup(:,1), TopGroup(:,2), 'o', 'Color', lblue)
        xlabel('Proximity of Spines (um)')
        ylabel('Correlation')
        ylim([-0.05 1])
        title('Spine on the same dendrite')
    subplot(1,3,2)
        plot(FarDistances, FarCorrelations, 'or')
        ylim([-0.05 1])
        xlabel('Proximity of Spines (um)')
        ylabel('Correlation')
        title('Spines on separate dendrites')
    subplot(1,3,3)
        plot(Distances, CausalCorrelations, 'o', 'Color', lblue)
    %     plot(BottomCausalGroup(:,1), BottomCausalGroup(:,2), 'o', 'Color', [0.2 0.2 0.2]); hold on;
    %     plot(MiddleCausalGroup(:,1), MiddleCausalGroup(:,2), 'o', 'Color', red)
    %     plot(TopCausalGroup(:,1), TopCausalGroup(:,2), 'o', 'Color', lblue)
        xlabel('Proximity of Spines (um)')
        ylabel('Correlation')
        title('Events Causing APs')
        ylim([-0.05 1])
else
end


if showFig
    windowwidth = Scrsz(3)/2;
    windowheight = Scrsz(4)/2;
    figure('Position', [(Scrsz(3)/2)-windowwidth/2, (Scrsz(4)/2)-windowheight/2, windowwidth, windowheight])
    for i = 1:numberofSpines
        subplot(ceil(sqrt(numberofSpines)),ceil(sqrt(numberofSpines)),i); hold on;
        parentdend = find(~cell2mat(cellfun(@(x) isempty(find(x == i,1)), File.SpineDendriteGrouping, 'Uni', false)));
        plot(processed_Dendrite(parentdend,:), processed_dFoF(i,:), 'ok')
        x = 0:ceil(max(processed_Dendrite(parentdend,:)));
        spineparsedaddress = cell2mat(cellfun(@(x) (find(x == i,1)), File.SpineDendriteGrouping, 'Uni', false));
        ycalc1 = analyzed.Alphas{parentdend}(2,spineparsedaddress)*x;
        justslope = plot(x,ycalc1, 'r');
        x2 = [ones(length(x),1),x'];
        ycalc2 = x2*analyzed.Alphas{parentdend}(:,spineparsedaddress);
        slopeandint = plot(x,ycalc2,'b');
        if i == numberofSpines
            legend([justslope,slopeandint], {'Slope only', 'Slope with int'})
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Section %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gui_KomiyamaLabHub
cd(gui_KomiyamaLabHub.DefaultActivityFolder)
analyzed.Session = currentsession;
if isOpto
    savefile = [animal, '_' Date, '_OptoSummary'];
    polyfile = [animal, '_',Date, '_OptoPolySummary'];
    eval([savefile, '= analyzed;']);
    eval([polyfile, '= poly;']);
else
    savefile = [animal, '_' Date, '_Summary'];
    polyfile = [animal, '_',Date, '_PolySummary'];
    eval([savefile, '= analyzed;']);
    eval([polyfile, '= poly;']);
end

% save(savefile, savefile, '-v7.3')
save(savefile, savefile);
save(polyfile, polyfile, '-v7.3');

disp([animal, '_', Date, ' (session ', num2str(analyzed.Session),')',' analysis complete'])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [choice] = accept(hObject, eventdata, handles)
setappdata(gcf, 'choice', 0);
uiresume

function choice = reject(hObject, eventdata, handles)
setappdata(gcf, 'choice', 1);
uiresume