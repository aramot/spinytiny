function [analyzed, poly] = SummarizeCaData(Experimenter, ImagingSensor, File, currentsession, showFig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function takes ROI information extracted using CaImageViewer and
%%% summarizes the intensity traces over the timecourse. The primary trace
%%% extraction method is performed using function 'AnalyzeTrace'. This
%%% function handles file loading, parameter setting, and all basic signal
%%% processing post-extraction (including event detection). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(~exist('Experimenter','var'))
    Experimenter = 'Nathan'; % User defaults to 'Nathan' if not defined
end

if(~exist('ImagingType','var'))
    ImagingSensor = 'GCaMP'; % default to show figure
end

if(~exist('File', 'var'))
    error('No file specified; either enter a filename, or use the variable itself as the input')
end

if(~exist('currentsession', 'var'))
    currentsession = 1;
    warning('Session was not specified. Defaulting to 1');
end

if(~exist('showFig','var'))
    showFig = 1; % default to show figure
end

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    Analyzer = 'Nathan';
else
    Analyzer = Experimenter;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Color Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    pink = [0.9 0.6 0.6];       lpurple  = [0.7 0.15 1];
    red = [0.85 0.11 0.14];     black = [0 0 0];
    dred = [0.6 0 0];          dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    

isbeingcalled = length(dbstack)>1;  %%% if the number of programs in 'dbstack' is greater than 1, then this file is being called by another function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Find the file being called %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if isstruct(File)
    experimenter_initials = File.Filename(1:2);
    folder = regexp(File.Filename, [experimenter_initials, '000?\d+'], 'match');
    folder = folder{1};
    Date = regexp(File.Filename, '_\d+_', 'match');
    Date = Date{1};
%     cd(['Z:\People\Nathan\Data\', folder, Date(2:end-1), '\summed'])
else
    experimenter_initials = regexp(File, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}', 'match');
    experimenter_initials = experimenter_initials{1};
    folder = regexp(File, [experimenter_initials, '\d+[^_]'], 'match');
    folder = folder{1};
    Date = regexp(File, '\d{6}', 'match');
    Date = Date{1};
    if ispc
        filestart = ['Z:', filesep, 'People'];
    elseif isunix
        filestart = [filesep,'usr',filesep,'local',filesep,'lab', filesep, 'People'];
    else
        error('Operating system not recognized as PC or Unix; terminating');
    end
    targetdir = [filestart, filesep, Experimenter, filesep, 'Data', filesep, folder, filesep, Date, filesep, 'summed'];
    if isdir(targetdir)
        cd(targetdir)
        files = dir(cd);
        check = 0;
        
        for i = 1:length(files)
            if ~isempty(regexp(files(i).name,['_summed_50_Analyzed_By', Analyzer])) || ~isempty(regexp(files(i).name,['_summed_50Analyzed_By', Analyzer]))
                load(files(i).name)
                check = 1;
            end
        end
        if ~check   %%% If no files were found using the above criteria
            for i = 1:length(files)
                if ~isempty(regexp(files(i).name, '_summed_50_Analyzed'))
                    load(files(i).name)
                    check = 1;
                else
                end
            end
        else
        end
        if ~check
            disp('Raw data file not found; PULLING FROM PREVIOUS ANALYSIS!!')
            cd('E:\ActivitySummary')
            files = dir(cd);
            for i = 1:length(files)
                if ~isempty(regexp(files(i).name, [folder, '_', Date])) && ~isempty(regexp(files(i).name,'_Summary')) && isempty(regexp(files(i).name,'Poly'))
                    load(files(i).name)
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% set "file" data to be used
        try
            eval(['File =' folder, '_', Date, '_001_001_summed_50_Analyzed;'])
        catch
            temp = who(['*', experimenter_initials, '*']);
            eval(['File =', temp{1}, ';']);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        disp('COULD NOT LINK TO TARGET DIRECTORY; PULLING FROM PREVIOUS ANALYSIS!!')
        cd('E:\ActivitySummary')
        files = dir(cd);
        for i = 1:length(files)
            if ~isempty(regexp(files(i).name, [folder, '_', Date])) && ~isempty(regexp(files(i).name,'_Summary')) && isempty(regexp(files(i).name,'Poly'))
                load(files(i).name)
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% set "file" data to be used
        try
            eval(['File =' folder, '_', Date, '_Summary;'])
        catch
            temp = who(['*', experimenter_initials, '*']);
            eval(['File =', temp{1}, ';']);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

filename = regexp(File.Filename, '.tif', 'split');
filename = filename{1};
File.Filename = [folder, '_', Date(3:end), '_001_001_summed_50_Analyzed'];

analyzed = File;
Scrsz = get(0, 'Screensize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%%%%%%%%%%%%%%%%%%%%%%%%
%%% Controlled variables
%%%%%%%%%%%%%%%%%%%%%%%%

analyzed.UsePreviousPreferences = 0;

foldertouse = 'E:\ActivitySummary';

% if ~a.UsePreviousPreferences
% 
%     d = dialog('Position', [(Scrsz(3)/2)-125 Scrsz(4)/2-75 250 150], 'Name', 'Whoa there...');
%     txt = uicontrol('Parent', d, 'Style', 'text', 'Position', [10 100 230 30], 'String', 'You are about to redo analysis and overwrite all parameters... continue?');
%     btn1 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [27.5 30 70 25], 'String', 'Accept!', 'Callback', @accept);
%     btn2 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [142.5 30 70 25], 'String', 'Ner', 'Callback', @reject);
%     uiwait(d)
%     choice = getappdata(d,'choice');
%     delete(d);
% 
% a.UsePreviousPreferences = choice;
% 
% else
% end

if analyzed.UsePreviousPreferences
    cd(foldertouse)
    try
        load([folder, '_', Date, '_Summary']);
        eval(['SummaryFile = ', folder, '_', Date, '_Summary;'])
    catch
        return
    end
    
    spinethreshmultiplier = SummaryFile.spinethresholdmultiplier;
    spinevalueslimitforbaseline = SummaryFile.spinevalueslimitforbaseline;
    spinevalueslimitfornoise = SummaryFile.spinevalueslimitfornoise;
    driftbaselinesmoothwindow = SummaryFile.driftbaselinesmoothwindow;
    spinebaselinesmoothwindow = SummaryFile.spinebaselinesmoothwindow;
    spinesmoothwindow = SummaryFile.spinesmoothwindow;
    Dendthreshmultiplier = SummaryFile.Dendthreshmultiplier;
    Dendvalueslimitforbaseline = SummaryFile.Dendvalueslimitforbaseline;
    Dendvalueslimitfornoise = SummaryFile.Dendvalueslimitfornoise;
    dendbaselinesmoothwindow = SummaryFile.dendbaselinesmoothwindow;
    dendsmoothwindow = SummaryFile.dendsmoothwindow;  
%     ClusterThresh = SummaryFile.ClusterThresh;
    ClusterThresh = 0.5;
    SpectralLengthConstant = SummaryFile.SpectralLengthConstant;
%     SpectralLengthConstant = 10;
else
    spinethreshmultiplier = 2*ones(1,length(File.dF_over_F));       %%% multiplier to binarize events
    spinevalueslimitforbaseline = 2;                                %%% for capping values to estimate baseline
    spinevalueslimitfornoise = 1;
    driftbaselinesmoothwindow = 1800;
    spinebaselinesmoothwindow = 450;
    if strcmpi(ImagingSensor, 'GCaMP')
        ImagingFrequency = 30.49;
        spinesmoothwindow = 60;
    elseif strcmpi(ImagingSensor, 'GluSnFR')
        ImagingFrequency = 120;
        spinesmoothwindow = 15;
    end 
    polythreshmultiplier = 2*ones(1,length(File.Poly_Fluorescence_Measurement));
    Dendthreshmultiplier = 2*ones(1,File.NumberofDendrites);
    DendSubthreshmultiplier = ones(1,length(File.dF_over_F));
    Dendvalueslimitforbaseline = 2;
    Dendvalueslimitfornoise = spinevalueslimitfornoise;
    dendbaselinesmoothwindow = 450;
    dendsmoothwindow = spinesmoothwindow;
    alphaminimum = 0.5;

    polypercentrequirement = 0.75;
    ClusterThresh = 0.5;
    SpectralLengthConstant = 10;
end


analyzed.spinethresholdmultiplier = spinethreshmultiplier;
analyzed.spinevalueslimitforbaseline = spinevalueslimitforbaseline;
analyzed.spinevalueslimitfornoise = spinevalueslimitfornoise;
analyzed.driftbaselinesmoothwindow = driftbaselinesmoothwindow;
analyzed.spinebaselinesmoothwindow = spinebaselinesmoothwindow;
analyzed.spinesmoothwindow = spinesmoothwindow;
analyzed.Dendthreshmultiplier = Dendthreshmultiplier;
analyzed.Dendvalueslimitforbaseline = Dendvalueslimitforbaseline;
analyzed.Dendvalueslimitfornoise = Dendvalueslimitfornoise;
analyzed.dendbaselinesmoothwindow = dendbaselinesmoothwindow;
analyzed.dendsmoothwindow = dendsmoothwindow;
analyzed.ClusterThresh = ClusterThresh;
analyzed.SpectralLengthConstant = SpectralLengthConstant;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select which spine to plot %%%

if File.NumberofSpines ==  0 || File.NumberofSpines ~= length(File.deltaF)
    File.NumberofSpines = length(File.deltaF);
    analyzed.NumberofSpines = length(File.deltaF);
end
% 
SpineNo = randi(File.NumberofSpines,1); %%% Will choose a random spine from the available ones for this file
SpineNo = 5;  %%% Manually select spine to be considered


DendNum = File.NumberofDendrites;
% DendriteChoice = 2;
% DendriteChoice = randi(DendNum,1);
DendriteChoice =  find(~cell2mat(cellfun(@(x) isempty(find(x == SpineNo,1)), File.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Search for spines that were not
%%% properly analyzed (this is now
%%% mostly obsolete)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if length(File.dF_over_F) ~= length(File.MeanEventAmp)
%     spinesnotanalyzed = length(File.dF_over_F) - length(File.MeanEventAmp);
%     if spinesnotanalyzed>1
%         disp(['More than one spine was not properly analyzed for the file ', File.Filename(1:10), '; Check analysis'])
%     else
%         pickup = length(File.MeanEventAmp)+spinesnotanalyzed;
%         old_alpha = robustfit(File.Dendrite_dFoF(File.NumberofDendrites,:),File.dF_over_F{pickup});
%         File.Alphas{File.NumberofDendrites}(1:2,pickup) = old_alpha;
%         deltaF_subtracted = File.dF_over_F{pickup}-(old_alpha(1)+old_alpha(2)*File.Dendrite_dFoF(File.NumberofDendrites,:));
%         analyzed.Alphas = File.Alphas;
%         analyzed.SynapticEvents{pickup} = deltaF_subtracted;
%         File.SynapticEvents{pickup} = deltaF_subtracted;
%         File.SpineDendriteGrouping{end} = [File.SpineDendriteGrouping{end},pickup];
%         analyzed.SpineDendriteGrouping{end} = [File.SpineDendriteGrouping{end},pickup];
%     end  
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Describe the basic shape of each calcium trace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


truebaseline = zeros(length(File.deltaF),length(File.deltaF{1}));
spinedriftbaseline = zeros(length(File.deltaF),length(File.deltaF{1}));
processed_dFoF = zeros(length(File.deltaF),length(File.deltaF{1}));
all = zeros(length(File.deltaF),length(File.deltaF{1}));
med = zeros(length(File.deltaF),1);
spread = zeros(length(File.deltaF),1);
binarized = zeros(length(File.deltaF),length(File.deltaF{1}));
amp = zeros(1,length(File.deltaF));
freq = zeros(1,length(File.deltaF),1);

numberofSpines = size(binarized,1);


%%% Trace extraction and smoothing

spine_thresh = zeros(numberofSpines,1);
static_thresh_dend = zeros(File.NumberofDendrites,1);

Options.DriftBaselineSmoothWindow = driftbaselinesmoothwindow;
Options.BaselineSmoothWindow = spinebaselinesmoothwindow;
Options.SmoothWindow = spinesmoothwindow;
Options.TraceOption = spinetraceoption;
Options.ValuesLimitforBaseline = spinevalueslimitforbaseline;
Options.ValuesLimitforNoise = spinevalueslimitfornoise;
Options.BeingAnalyzed = 'Spine';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:numberofSpines
    [spine_thresh(i,1), spinedriftbaseline(i,:), processed_dFoF(i,:)] = AnalyzeTrace(spinedatatouse{i}, Options);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% Event detection %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Variable initiation
floored = zeros(numberofSpines, length(spinedatatouse{1}));
thresh = spine_thresh;
riderthresh = 1;
riderthresh2 = 2;

for i = 1:numberofSpines
    temp = processed_dFoF(i,:); %%% This value will be used as a "floored" term, which has zeros below the threshold. It will subsequenctly be used as a binarized term by setting all threshold values to 1.

    temp(temp<spine_thresh(i,1)) = 0;
    floored(i,:) = temp;
    temp(temp<thresh(i,1)) = nan;
    tamp = temp;
    tamp(isnan(tamp)) = 0;
    tamp = smooth(tamp,30);
    dtamp = diff(tamp);     %%% first derivative of the binarized data
    dtamp = [0;dtamp];
    dtamp(dtamp>0) = 1; dtamp(dtamp<0) = -1;
    d2tamp = diff(dtamp);
    d2tamp = [0;d2tamp];    %%% Second derivative of the binarized data (concavity)
    d2tamp(d2tamp>0) = 1; d2tamp(d2tamp<0) = -1;
    temp(d2tamp>0) = nan; %% For plateau spikes, when the 2nd derivative is positive (concave up, corresponding to dips), punch a 'hole' in the data, so that multiple peaks will be counted
    riders(i,:) = temp;
end

%%% Set all events = 1, making square pulses corresponding to
%%% activity

square = [];
ternarized = riders;

ternarized(isnan(ternarized)) = 0;
ternarized(ternarized~=0) = riderthresh2-1.5;

for i = 1:numberofSpines
    temp = floored(i,:);   %%% This value will eventually be used to define "synapse only" events, which only requires knowledge of when spines are above a threshold (e.g. spikes riding on top of activity need not be considered)
    temp(temp>0)= 1;
    square(i,:) = temp;
    temp = [];
    temp = square(i,:)+ternarized(i,:); %% Can remove 'ternarized' to get rid of plateau spike summing
    both(i,:) = temp;
    temp2 = (diff(temp)>0.1)>0;
    temp3 = [0, temp2];          %%% Any use of 'diff' shortens the vector by 1
    smeared = smooth(temp3, 5);  %%% Smoothing factor is taken from the reported decay constant of GCaMP6f (~150ms), converted to frames 
    smeared(smeared>0) = 1;
    trueeventcount(i,:) = smeared;
end

analyzed.SpineThreshold = thresh;
analyzed.StandardDeviationofNoise = spread;


%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 1 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Raw data and estimated baseline

if showFig == 1
    k = zeros(1,length(File.Time));
    k(1:end) = thresh(SpineNo,1);
    m = ones(1,length(File.Time))*med(SpineNo,1);
    fig1 = figure('Position', [10, Scrsz(4)/2.5,Scrsz(3)/2,Scrsz(4)/2]); 
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

if showFig == 1
    procplot = subplot(2,2,3:4);
    hold on; plot(File.Time, processed_dFoF(SpineNo,:), 'Color',[0.2 0.2 0.2], 'LineWidth', 1);
    linkaxes([rawplot,procplot], 'x');
    topspikes = riders(SpineNo,:);
    plot(1:length(File.Time), topspikes, 'Color', dred, 'LineWidth', 2);
    plot(File.Time, both(SpineNo,:)*(med(SpineNo,1)+thresh(SpineNo,1)), 'Color', yellow, 'LineWidth', 2)
    plot(File.Time, trueeventcount(SpineNo,:)*(med(SpineNo,1)+thresh(SpineNo,1)),'Color', lblue, 'LineWidth', 2);
    plot(File.Time, k', '--', 'Color', lgreen, 'LineWidth', 2)
    plot(File.Time, m, '--', 'Color', purple)
    xlabel('Frames')
    ylabel(['Smoothed dF/F for spine no. ', num2str(SpineNo)])
else
end

if showFig == 1
else
end


for i = 1:numberofSpines
    frequency(i,1) = (nnz(diff(trueeventcount(i,:)>0.5)>0)/((length(File.Time)/ImagingFrequency)/60))';
end


for i = 1:size(floored,1)
    [peaks, loc] = findpeaks(smooth(floored(i,:),10), 'MinPeakDistance', 5);   %%% The "floored" variable is used to count events, and so should be used to find the corresponding amplitude
    spine_peaks{i} = peaks;
    peak_loc{i} = loc;
    bin = zeros(1,length(spinedatatouse{i}));
    bin(loc) = 1;
    binarized(i,:) = bin;
    amp(1,i) = mean(peaks);
    freq(1,i) = length(peaks);
end

if ~isfield(File, 'SpineDendriteGrouping')
    if File.NumberofDendrites == 1
        File.SpineDendriteGrouping{1} = 1:numberofSpines;
    else
        disp('SpineDendriteGrouping field is absent!!!')
    end
end

analyzed.ActivityMap = trueeventcount;
analyzed.MeanEventAmp = amp;
analyzed.AllSpineAmpData = spine_peaks;

analyzed.EventNumber = frequency;
analyzed.Frequency = frequency;
analyzed.Processed_dFoF = processed_dFoF;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Dendrite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%
%%%%%%%%%%%
% Dendthreshmultiplier = 0.5;
%%%%%%%%%%%
%%%%%%%%%%%%%%%%

Dtruebaseline = zeros(DendNum,length(File.Dendrite_dFoF(1,:)));
Ddriftbaseline = zeros(DendNum,length(File.Dendrite_dFoF(1,:)));
processed_Dendrite = zeros(DendNum, length(File.Dendrite_dFoF(1,:)));
Dthresh = zeros(DendNum,1);
Dmed = zeros(DendNum,1);
Dspread = zeros(DendNum,1);
Damp = zeros(DendNum,1);
Dfreq = zeros(DendNum,1);
globaldendriteevents = cell(1,DendNum);

cumulativepolypoints = cumsum(File.DendritePolyPointNumber);
File.Poly_Fluorescence_Measurement = File.Poly_Fluorescence_Measurement(~cell2mat(cellfun(@(x) isempty(x), File.Poly_Fluorescence_Measurement, 'UniformOutput', false))); %%% Remove any empty cells
if length(File.Poly_Fluorescence_Measurement) ~= sum(File.DendritePolyPointNumber)
    disp(['File ', File.Filename, ' has weird poly point problems... check it, broh'])
    return
end

Pdriftbaseline = zeros(cumulativepolypoints(end),length(File.Dendrite_dFoF(1,:)));
Pthresh = zeros(cumulativepolypoints(end),1);


square_Poly = cell(1,DendNum);
floored_Poly = cell(1,DendNum);
compiledDendData = zeros(DendNum, length(File.Dendrite_dFoF));
compiledProcessedDendData = zeros(DendNum, length(File.Dendrite_dFoF));
dendritedatatouse = zeros(DendNum, length(File.Dendrite_dFoF));
rawpoly = cell(1,cumulativepolypoints(end));
processed_PolyROI = cell(1,cumulativepolypoints(end));

static_thresh_poly = zeros(cumulativepolypoints(end),1);

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
        
        temp = File.Poly_Fluorescence_Measurement{j};
        try
            temp(isnan(temp)) = nanmean([temp(find(isnan(temp))-1),temp(find(isnan(temp))+1)]);
        catch
            temp(isnan(temp)) = 0;
        end
        
        temp(1:10) = temp(randi([20,100],1,10)); temp(end-9:end) = temp(randi([length(temp)-100,length(temp)-20],1,10));
        File.Poly_Fluorescence_Measurement{j} = temp;
        poly.Poly_Fluorescence_Measurement{j} = temp;
        
        rawpoly{j} = temp;
        
        %%%%%%%%%%%%%%%%%%%%%%
        
        Options.DriftBaselineSmoothWindow = driftbaselinesmoothwindow;
        Options.BaselineSmoothWindow = dendbaselinesmoothwindow;
        Options.SmoothWindow = dendsmoothwindow;
        Options.TraceOption = 1;
        Options.ValuesLimitforBaseline = Dendvalueslimitforbaseline;
        Options.ValuesLimitforNoise = Dendvalueslimitfornoise;
        Options.BeingAnalyzed = 'Poly';


        [Pthresh(j,1), Pdriftbaseline(i,:), processed_PolyROI{j}] = AnalyzeTrace(rawpoly{j}, Options);

        
        %%% Binarization    
        floored_Poly{i}(j-polyptstouse(1)+1,:) = zeros(1,length(processed_PolyROI{j}));
        
        temp = processed_PolyROI{j};
            
        temp(temp<Pthresh(j,1)) = 0;

        floored_Poly{i}(j-polyptstouse(1)+1,:) = temp;
        temp(temp>0) = 1;
        
        square_Poly{i}(j-polyptstouse(1)+1,:) = temp;
        poly.PolyROI_Binarized{i}(j-polyptstouse(1)+1,:) = square_Poly;        
    end
    
    compiledDendData(i,:) = nanmean(cell2mat(rawpoly(polyptstouse)'));
    compiledProcessedDendData(i,:) = nanmean(cell2mat(processed_PolyROI(polyptstouse)),2);
    
    globaldendevents = sum(square_Poly{i});
    globaldendevents(globaldendevents<polypercentrequirement*size(square_Poly{i},1)) = 0;     %%% If > x% of the PolyROIs are active, it's probably a true global dendrite event
    globaldendevents(globaldendevents~=0) = 1;
        
    globaldendriteevents{i} = globaldendevents;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%
    %%% Perform event detection for the dendrite as a whole
    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dendritedatatouse(i,:) = compiledDendData(i,:); 

    Options.DriftBaselineSmoothWindow = driftbaselinesmoothwindow;
    Options.BaselineSmoothWindow = dendbaselinesmoothwindow;
    Options.SmoothWindow = dendsmoothwindow;
    Options.TraceOption = 1;
    Options.ValuesLimitforBaseline = Dendvalueslimitforbaseline;
    Options.ValuesLimitforNoise = Dendvalueslimitfornoise;
    Options.BeingAnalyzed = 'Dendrite';


    [Dthresh(i,1), Ddriftbaseline(i,:), processed_Dendrite(i,:)] = AnalyzeTrace(dendritedatatouse(i,:), Options);

    floored_Dend = zeros(DendNum,length(processed_Dendrite(1,:)));
    Driders = zeros(DendNum,length(processed_Dendrite(1,:)));

end

analyzed.DendriteThreshold = Dthresh;

for i = 1:File.NumberofDendrites
    temp = processed_Dendrite(i,:);
    
    temp(temp<Dthresh(i,1)) = 0;
    
    floored_Dend(i,:) = temp;
    temp(temp<Dthresh(i,1)) = nan;
    tamp = temp;
    tamp(isnan(tamp)) = 0;
    tamp = smooth(tamp,20);
    dtamp = diff(tamp);
    dtamp(dtamp>0) = 1; dtamp(dtamp<0) = -1;
    d2tamp = diff(dtamp);
    d2tamp(d2tamp>0) = 1; d2tamp(d2tamp<0) = -1;
    temp(d2tamp>0) = nan;   %%% For plateau spikes, when the 1st derivative is negative (val. decreasing) and 2nd derivative is positive (concave up, corresponding to dips), punch a 'hole' in the data, so that multiple peaks will be counted
    Driders(i,:) = temp;    %%% Used to determine when events start, NOT to indicate when the dendrite is active (i.e. represents event onsets, not active periods)
end

square_Dend = zeros(DendNum,length(processed_Dendrite(1,:)));
Dboth = zeros(DendNum,length(processed_Dendrite(1,:)));
Dglobal = zeros(DendNum,length(processed_Dendrite(1,:)));
ternarized_Dend = Driders;

ternarized_Dend(isnan(ternarized_Dend)) = 0;
ternarized_Dend(ternarized_Dend~=0) = riderthresh2-0.5;

% Driderstop(~isnan(Driderstop)) = riderthresh2-1.5;
% Driderstop(isnan(Driderstop)) = 0;

for i = 1:File.NumberofDendrites
    temp = floored_Dend(i,:);
    temp(temp~=0) = 1;            
    
    square_Dend(i,:) = temp;
    
    bound = find(diff([Inf, square_Dend(i,:), Inf])~=0);
    epochs = mat2cell(square_Dend(i,:)', diff(bound));
    polyepoch = mat2cell(square_Poly{i}', diff(bound));
    
    Dglobal(i,:) = cell2mat(cellfun(@(x,y) x*y, cellfun(@(x) sum(x)>0.1*length(x), cellfun(@round, cellfun(@mean, polyepoch, 'UniformOutput', false), 'UniformOutput', false), 'UniformOutput', false), epochs, 'Uni', false));
        
%     Dglobal(i,:) = square_Dend(i,:).*globaldendriteevents{i};
    
    temp = ternarized_Dend(i,:);
    temp(temp~=0) = 1;            
        
    ternarized_Dend(i,:) = temp;
    
    temp = square_Dend(i,:)+ternarized_Dend(i,:);
    Dboth(i,:) = temp;
    temp2 = (diff(Dboth(i,:))>0.1)>0;
    temp3 = [0, temp2];          %%% Any use of 'diff' shortens the vector by 1; correct for this
    Dsmeared = smooth(temp3, 5); %%% Smoothing factor is taken from the reported decay constant of GCaMP6f (~150ms), converted to frames 
    Dsmeared(Dsmeared>0) = 1;
    Dendtrueeventcount(i,:) = Dsmeared;
    
        dendtimebuffer = 0;
    
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
    [Dpeaks, Dloc] = findpeaks(smooth(floored_Dend(i,:),10), 'MinPeakDistance', 5);   %%% The "floored" variable is used to count events, and so should be used to find the corresponding amplitude
    Damp(i,1) = mean(Dpeaks);
    Dfreq(i,1) = length(peaks);
end


%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 2 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

if showFig == 1
    k = zeros(1,length(File.Time));
    k(1:end) = Dthresh(DendriteChoice,1);
%     m = zeros(1,length(File.Time)) * Dmed(DendriteChoice,1);

    figure('Position', [10, 50 ,Scrsz(3)/2,Scrsz(4)/2]); hold on;
    rawdend = subplot(2,2,1:2);
    plot(File.Time, dendritedatatouse(DendriteChoice,:), 'Color', [0.2 0.2 0.2]);
    hold on; 
    plot(File.Time, Ddriftbaseline(DendriteChoice,:), 'r', 'LineWidth', 2);
    legend({'Raw Data', 'Baseline'}, 'Location', 'SouthEastOutside')
    
    xlabel('Frames')
    ylabel(['Events for Dendrite ', num2str(DendriteChoice)])
    
    procdend = subplot(2,2,3:4);
    plot(File.Time, processed_Dendrite(DendriteChoice,:), 'Color', [0.2 0.2 0.2]); hold on;
    topspikes = Driders(DendriteChoice,:);
    plot(1:length(File.Time), topspikes, 'Color', dred, 'LineWidth', 2);
%     plot(File.Time(Dend_Locations{DendriteChoice}), Dend_Peaks{DendriteChoice}+0.05, 'kv', 'markerfacecolor', lgreen);
    plot(File.Time, Dboth(DendriteChoice,:)*Dthresh(DendriteChoice), 'Color', yellow, 'Linewidth', 2)

    plot(File.Time, k, '--', 'Color', lgreen, 'Linewidth', 2)
    plot(File.Time, Dglobal(DendriteChoice,:)*Dthresh(DendriteChoice,1), 'Color', orange, 'Linewidth', 2)
    plot(File.Time, Dendtrueeventcount(DendriteChoice,:)*Dthresh(DendriteChoice,1),'Color', lblue, 'LineWidth', 2);
    
    legend({'Smoothed Data', 'Activity above Thresh', 'Binary Activity', 'Threshold', 'Global Event', 'Counted Events'}, 'Location', 'SouthEastOutside')        
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

Dboth(Dboth>1) = 1;
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

if length(File.dF_over_F) ~= File.SpineDendriteGrouping{end}(end)
    File.SpineDendriteGrouping{end} = File.SpineDendriteGrouping{end}(1):length(File.dF_over_F);
    analyzed.SpineDendriteGrouping{end} = analyzed.SpineDendriteGrouping{end}(1):length(analyzed.dF_over_F);
end
% 

analyzed = DendriteSubtraction(analyzed, [], 'Initial');

if showFig
    axes(procplot)
    plot(analyzed.Floored_DendriteSubtracted(SpineNo, :), 'Color', [0.7 0.7 0.7], 'Linewidth', 1.5)
    legend({'Smoothed Data', 'Activity above Thresh', 'Binary Activity', 'Counted Events', 'Threshold', 'Baseline', 'Dend-subtracted'}, 'Location', 'SouthEastOutside')
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


cofires = sum(square);
cofires(cofires == 1) = 0; %%% values of '1' correspond to a single event, meaning it's not actually a 'cofire' event


%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

%%% Figure 4 %%%

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%

if showFig == 1
    figure('Position', [Scrsz(3)/2, Scrsz(4)/2.5,Scrsz(3)/2,Scrsz(4)/2]); 
else
end

causal = zeros(numberofSpines,size(all,2));
back = 1;   %%% Number of frames prior to a dendritic event that a spine must be active to be considered "causal"

synapticEvents = zeros(numberofSpines, length(square));
synapseOnlyFreq = zeros(numberofSpines,1);
withAPs = zeros(numberofSpines, length(square));
withAPsFreq = zeros(numberofSpines,1);

for i = 1:numberofSpines
    onDend = 1;
    for j = 1:DendNum
        if ~isempty(find(File.SpineDendriteGrouping{j} == i))
            onDend = j;
            %%%
            %%%
            %%%
            %%% This is the last decision variable on whether to use
            %%% dendrite-corrected or dendrite-removed data!!!
            %%%
            synapticEvents(i,:) = square(i,:)-Dglobal(onDend,:);
%             synapticEvents(i,:) = square_Ds(i,:);
            %%%
            %%%
            %%%
            %%%
            %%%
            synapticEvents(i,synapticEvents(i,:)<1) = 0;
            synapseOnlyFreq(i,1) = (nnz(diff(synapticEvents(i,:)>0.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
            %%%
            withAPs(i,:) = analyzed.SynapseOnlyBinarized_DendriteSubtracted(i,:)+logical(Dboth(onDend,:));   %%% Add binarized spine data to dendrite data to illustrate when dendrite and spines are co-firing
            %%%
            withAPsFreq(i,1) = (nnz(diff(withAPs(i,:)>1.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
            withAPs(i,(withAPs(i,:)==1)) = 0;
            withAPs(i,(withAPs(i,:)==2)) = 1;
%             dendOnly(i,:) = square_Dend(onDend,:)-square(i,:);
            APstart(i,:) = [0,diff(withAPs(i,:))]; %%% Find where the derivative of the AP-paired events is nonzero (i.e. where it is first increasing, making it the start of an AP)
            for k = 1:size(binarized,2)
                if showFig == 1
                    if synapticEvents(i,k) == 1 && withAPs(i,k) ~=1
                        line([k k],i-0.5:i+0.5,'color', [0.2 0.2 0.2]);
                    end
                    if withAPs(i,k) == 1
                        line([k k],i-0.5:i+0.5,'color', red);
                    end
    %                 if dendOnly(i,k) == 1
    %                     line([k k],[i:i+1],'color', 'r'); hold on;
    %                 end
                    if k > back %%% can't index at zero (see below)
                        if APstart(i,k) && withAPs(i,k) && synapticEvents(i,k-back) %%% If a spine event precedes a putative AP
                            causal(i,(find(diff(synapticEvents(i,1:k))==1, 1,'last'))+1:k) = 1;
                            line([k-back k-back], i:0.5:(i+0.5), 'color', lblue, 'LineWidth', 2); hold on;
                            line([k-1 k-1], i:0.5:(i+0.5), 'color', lblue, 'LineWidth', 2); hold on;
                        end
                    end
                else
                    if k > back %%% can't index at zero (see below)
                        if APstart(i,k) && withAPs(i,k) && synapticEvents(i,k-back) %%% If a spine event precedes a putative AP
                            causal(i,(find(diff(synapticEvents(i,1:k))==1, 1,'last'))+1:k) = 1;
                        end
                    end
                end
            end 
        else
        end
    end
end

% withAPs(withAPs == 1) = 0; 
% withAPs(withAPs ==2 ) = 1;

for i = 1:DendNum
    Dfrequency(i,1) = (nnz(diff(Dendtrueeventcount(i,:)>0.5)>0)/((length(analyzed.Time)/ImagingFrequency)/60))';
end

disp(['Dendritic Frequencies: ', num2str(Dfrequency(:)')])

analyzed.Dendritic_Frequency = Dfrequency;
analyzed.Dendritic_Amp = Damp;
analyzed.SynapseOnlyBinarized = synapticEvents;
analyzed.OverallSpineActivity = square;
analyzed.SynapseOnlyFreq = synapseOnlyFreq;
analyzed.SpikeTimedEvents = withAPsFreq;
analyzed.CausalBinarized = causal;
%%%%%%%%%%%%

if showFig == 1
    xlabel('Frames');
    ylabel('Spine number');
    xlim([0 size(binarized,2)+1]);
    ylim([0 numberofSpines+1]);
    title('Synapse only vs. AP-paired events');
else
end
%%%%%%%%%%%%%%%%

Spine_No = numberofSpines;
Time = size(binarized,2)/ImagingFrequency;
Time = Time/60;
cofire_index = sum(cofires)/(Spine_No*Time);

cofires(cofires ==0) = NaN;
coactive_percentage = 100*(max(cofires))/numberofSpines;
% spec = 'Approximately %2.0f percent of spines showed co-active firing\n';
% fprintf(spec, coactive_percentage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 5 : Spatial Analysis %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pixpermicron = 4.65;
if ~isempty(strfind(File.Filename, 'ZL'))
    File.ZoomValue = 8.5;
end
if isfield(File, 'ZoomValue')
    if File.ZoomValue ~= 0
        pixpermicron = (pixpermicron*File.ZoomValue)/12.1;
    end
end
SpineToSpineDistance = nan(numberofSpines,numberofSpines);
OverallCorrelation = nan(numberofSpines, numberofSpines);
SpineToSpineCorrelation = nan(numberofSpines,numberofSpines);
SpineToSpinePValue = nan(numberofSpines, numberofSpines);
SpwAPCorrelation = nan(numberofSpines, numberofSpines);
SpwAP_PValue = nan(numberofSpines, numberofSpines);
CausalCorrelation = nan(numberofSpines, numberofSpines);
CausalPValue = nan(numberofSpines,numberofSpines);


%%% Correlate spines on the same dendrite as a function of dendritic
%%% distance between them

if DendNum ~= length(File.DendritePolyPointNumber)
    error('The polyline ROIs are not binned correctly; this file needs to be re-analyzed!')
end
counter = 1;
for i = 1:File.NumberofDendrites
    Branch{i}(1,1) = 0;
%     zeropoint = [(File.PolyLinePos{counter}(1)+File.PolyLinePos{counter}(3)/2), (File.PolyLinePos{counter}(2)+File.PolyLinePos{counter}(4)/2)]; %%% zeropoint(x,y) = center in x,y coordinates of the beginning of a dendrite
    PolyX_center{i}(1,1) = File.PolyLinePos{counter}(1)+File.PolyLinePos{counter}(3)/2;
    PolyY_center{i}(1,1) = File.PolyLinePos{counter}(2)+File.PolyLinePos{counter}(4)/2;
    Pix_Dist{i}(1,1) = 0;
    Mic_Dist{i}(1,1) = 0;
    for j = 2:File.DendritePolyPointNumber(i)
        counter = counter+1;
        PolyX_center{i}(1,j) = File.PolyLinePos{counter}(1)+File.PolyLinePos{counter}(3)/2;
        PolyY_center{i}(1,j) = File.PolyLinePos{counter}(2)+File.PolyLinePos{counter}(4)/2;
        Pix_Dist{i}(1,j) = sqrt((PolyX_center{i}(1,j)-PolyX_center{i}(j-1)).^2 + (PolyY_center{i}(j)-PolyY_center{i}(j-1)).^2);
        Mic_Dist{i}(1,j) = Pix_Dist{i}(1,j)/pixpermicron;
    end
    counter = counter+1;
    for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
        spine_pos{j} = [File.ROIPosition{j+1}(1)+File.ROIPosition{j+1}(3)/2, File.ROIPosition{j+1}(2)+File.ROIPosition{j+1}(4)/2]; %%% Don't forget that position 1 in this cell is actually ROI0/background ROI!!!! 
        [distance, index] = min(sqrt(((PolyX_center{i}-spine_pos{j}(1)).^2)+(PolyY_center{i}-spine_pos{j}(2)).^2)); %%% Find the closest ROI along the dendrite (usually spaced evenly and regularly enough that it should be right at the base of the spine, more or less)
%         spine_address{j} = [PolyX_center{i}(1,index), PolyY_center{i}(1,index)]; %%% Set a spine's "address" as that point along the dendrite, found above
        spine_address{j}.Dendrite = i;
        spine_address{j}.Index = index;
    end
    if length(File.SpineDendriteGrouping{i})>1
        for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end-1)
            for k = (j+1):File.SpineDendriteGrouping{i}(end)
                [val ind] = sort([spine_address{j}.Index,spine_address{k}.Index]);
                lower = val(1);
                higher = val(2);
                SpineToSpineDistance(j,k) = abs(sum(Mic_Dist{spine_address{j}.Dendrite}(lower:higher))-Mic_Dist{spine_address{j}.Dendrite}(lower));  %%% Find the sum of linear distances from the current point to the nearby spine
            end
        end 
    else
    end
end

analyzed.DendriteLengthValues = Mic_Dist;


[r_all, p_all] = corrcoef(square');
r_all(isnan(r_all)) = 0;
OverallCorrelation = r_all;
OverallPvalue = p_all;

[r, p] = corrcoef(analyzed.SynapseOnlyBinarized');
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


nonnan = find(~isnan(SpineToSpineDistance)); %% Find the indices for  non-NaN values
Correlations = SpineToSpineCorrelation(nonnan);
pValues = SpineToSpinePValue(nonnan);
wAPCorrelations = SpwAPCorrelation(nonnan);
SpwAP_PValue = SpwAP_PValue(nonnan);
Distances = SpineToSpineDistance(nonnan);
CausalCorrelations = CausalCorrelation(nonnan);
CausalPValues = CausalPValue(nonnan);

analyzed.SpineToSpineDistance = Distances;
analyzed.OverallCorrelationsHeatMap = OverallCorrelation;
analyzed.OverallCorrelation = OverallCorrelation(nonnan);
analyzed.SpineToSpineCorrelation = Correlations;
analyzed.CorrelationHeatMap = SpineToSpineCorrelation;
analyzed.PValueHeatMap = SpineToSpinePValue;
analyzed.CausalHeatMap = CausalCorrelation;
analyzed.DistanceHeatMap = SpineToSpineDistance;
analyzed.CausalPValueHeatMap = CausalPValue;
analyzed.SpinewithAP_Correlation = wAPCorrelations;
analyzed.SpineToSpine_PValues = pValues;
analyzed.SpinewithAP_PValues = SpwAP_PValue;
analyzed.CausalCorrelations = CausalCorrelations;
analyzed.CausalPValues = CausalPValues;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Analysis of individual clusters %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Clustnum = 1;

%%% Find all values that are greater than the cluster threshold
[row, col] = find(SpineToSpineCorrelation>=ClusterThresh);
[Crow, Ccol] = find(CausalCorrelation>=ClusterThresh);
Dendind = [];
CDendind = [];
addresses = cell(1,DendNum);
Caddresses = cell(1,DendNum);

%%% Make full correlation matrix %%%
tempA = SpineToSpineCorrelation;
tempB = SpineToSpineCorrelation';
tempA(isnan(tempA) & ~isnan(tempB)) = tempB(isnan(tempA) & ~isnan(tempB));
fullmat = tempA;
tempC = SpineToSpineDistance;
tempD = SpineToSpineDistance';
tempC(isnan(tempC) & ~isnan(tempD)) = tempD(isnan(tempC) & ~isnan(tempD));
fullDist = tempC;

%%% 'Synapse only' clusters
for i = 1:length(row)
    for j = 1:DendNum
        if ~isempty(find(File.SpineDendriteGrouping{j} == row(i)))
            Dendind = [Dendind; j];
            addresses{j} = [addresses{j}; row(i), col(i)];
        end
    end
end
usedDend = unique(Dendind);

for i = 1:length(addresses)
    if ~isempty(addresses{i})
        if size(addresses{i},1)>1
            spines = unique(addresses{i});
            clust = spines(1);
            nonclust = [];
            for j = 2:length(spines)
                if sum(fullmat(clust, spines(j))>ClusterThresh)==length(clust)  %%% If all the indices in the 'clust' array yield correlation values > ClustThresh, then it should return all logical == 1, so the sum should be the same as the length of the 'clust' array
                    clust = [clust; spines(j)];
                else
                    nonclust = [nonclust; spines(j)];
                end
            end
            Clustered{Clustnum} = clust;
            Clustnum = Clustnum+1;
            while length(clust)<length(spines)
                for j = 1:length(clust)
                    spines = spines(spines~=clust(j));  %%% Replace 'spines' array with only the ones that haven't been used yet
                end
%                 if length(spines) == 1
%                     continue
%                 end
                clust = spines(1);
                options = unique(addresses{i});
                for j = 1:length(options)
                    if sum(fullmat(clust, options(j))>ClusterThresh)==length(clust)
                        clust = [clust; options(j)];
                    end
                end
                if length(clust)>1
                    Clustered{Clustnum} = clust;
                    Clustnum = Clustnum+1;
                end
            end
        else
            spines = unique(addresses{i});
            Clustered{Clustnum} = spines';
            Clustnum = Clustnum+1;
        end
    else
        Clustered{Clustnum} = [];
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Find the largest distance covered by the spines in a each cluster

for i = 1:length(Clustered)
    if length(Clustered{i})>1
        combinations = [];
        dist = [];
        combinations = nchoosek(Clustered{i},2); %%% Find all combinations of spines (two at a time) in a given cluster
        for j = 1:size(combinations, 1)
            dist(j) = fullDist(combinations(j,1), combinations(j,2));
        end
        ClustLength{i} = nanmean(dist);
    else
        ClustLength{i} = [];
    end
end

analyzed.Clustered_Spines = Clustered;
analyzed.Cluster_Length = ClustLength;

%%% Repeat the above for causal clusters
%%% Make full correlation matrix %%%
tempA = CausalCorrelation;
tempB = CausalCorrelation';
tempA(isnan(tempA) & ~isnan(tempB)) = tempB(isnan(tempA) & ~isnan(tempB));
fullmat = tempA;

%%% Causal clusters

Clustnum = 1;

for i = 1:length(Crow)
    for j = 1:DendNum
        if ~isempty(find(File.SpineDendriteGrouping{j} == Crow(i)))
            CDendind = [CDendind; j];
            Caddresses{j} = [Caddresses{j}; Crow(i), Ccol(i)];
        end
    end
end

CusedDend = unique(CDendind);


for i = 1:length(Caddresses)
    if ~isempty(Caddresses{i})
        if size(Caddresses{i},1)>1
            spines = unique(Caddresses{i});
            clust = spines(1);
            nonclust = [];
            for j = 2:length(spines)
                if sum(fullmat(clust, spines(j))>ClusterThresh)==length(clust)  %%% If all the indices in the 'clust' array yield correlation values > 0.5, then it should return all logical == 1, so the sum should be the same as the length of the 'clust' array
                    clust = [clust; spines(j)];
                else
                    nonclust = [nonclust; spines(j)];
                end
            end
            CausalClustered{Clustnum} = clust;
            Clustnum = Clustnum+1;
            while length(clust)<length(spines)
                for j = 1:length(clust)
                    spines = spines(spines~=clust(j));  %%% Replace 'spines' array with only the ones that haven't been used yet
                end
%                 if length(spines) == 1
%                     continue
%                 end
                clust = spines(1);
                options = unique(Caddresses{i});
                for j = 1:length(options)
                    if sum(fullmat(clust, options(j))>ClusterThresh)==length(clust)
                        clust = [clust; options(j)];
                    end
                end
                if length(clust)>1
                    CausalClustered{Clustnum} = clust;
                    Clustnum = Clustnum+1;
                end
            end
        else
            spines = unique(Caddresses{i});
            CausalClustered{Clustnum} = spines';
            Clustnum = Clustnum+1;
        end
    else
        CausalClustered{Clustnum} = [];
    end
end


for i = 1:length(CausalClustered)
    if length(CausalClustered{i})>1
        combinations = [];
        dist = [];
        combinations = nchoosek(CausalClustered{i},2); %%% Find all combinations of spines (two at a time) in a given cluster
        for j = 1:size(combinations, 1);
            dist(j) = fullDist(combinations(j,1), combinations(j,2));
        end
        CausalClustLength{i} = nanmean(dist);
    else
        CausalClustLength{i} = [];
    end
end

analyzed.CausalClustered_Spines = CausalClustered;
analyzed.CausalCluster_Length = CausalClustLength;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Spectral graph analysis of degree of clustering for each spine and
%%% dendrite

DendClustering = zeros(1,DendNum);
weightedCluster = cell(1,DendNum);
DistanceEigenVectors = cell(1,DendNum);
DistanceEigenValues = cell(1,DendNum);

for i = 1:DendNum
    firstspine = File.SpineDendriteGrouping{i}(1);
    lastspine = File.SpineDendriteGrouping{i}(end);
    if firstspine ~= lastspine
        A{i} = fullDist(firstspine:lastspine, firstspine:lastspine);
%         if max(max(A{i}))>0
%             A{i} = A{i}/max(max(A{i}));     %%% Normalize to dendrite length;
%         else
%         end
%         A{i}(A{i}<10) = 1;
%         A{i}(A{i}>10) = 0;

        A{i}(A{i}<1) = 1;
        A{i} = 1./exp(A{i}./SpectralLengthConstant);          %%% Adjacency matrix --> 1/e^x, where x = distance
        A{i}(isnan(A{i})) = 0;                                %%% Since the diagonal of the laplacian == the degree, set NaNs in A to be zero to maintain this identity;
        degs = sum(A{i},2);
        degs(degs==0) = eps;
        D{i} = sparse(1:size(A{i},1),1:size(A{i},2),degs);    %%% Degree matrix
        L{i} = D{i}-A{i};                                     %%% Laplacian matrix
        Dinv{i} = inv(D{i});                                  %%% Determine the inverse Degree matrix
        nL{i}= Dinv{i} * L{i};
        [eVecs eVals] = eig(nL{i});                           %%% Find the eigenvectors and eigenvalues for the Laplacian
        DistanceEigenVectors{i} = eVecs;
        DistanceEigenValues{i} = eVals;
        e = diag(eVals);
        DendClustering(1,i) = min(e(~ismember(e,min(e))));   %%% Finds the SECOND smallest eigenvalue (the Fiedler value or algebraic connectivity) which corresponds to the extent of clustering for the whole dendrit
        weightedCluster{i} = [];
    else
        A{i} = [];
        D{i} = [];
        L{i} = [];
        nL{i} = [];
        DendClustering(1,i) = NaN;
        weightedCluster{i} = [];
    end
end

analyzed.AdjacencyMatrix = A;
analyzed.DegreeMatrix = D;
analyzed.LaplacianMatrix = L;
analyzed.NormalizedLaplacian = nL;
analyzed.DistanceEigenVectors = DistanceEigenVectors;
analyzed.DistanceEigenValues = DistanceEigenValues; 
analyzed.DendriteClusterDegree = DendClustering;
analyzed.WeightedClustering = weightedCluster;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%%% Correlate distant spines on separate dendrites

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


analyzed.FarSpineToSpineDistance = FarDistances;
analyzed.FarSpineToSpineCorrelation = FarCorrelations;

%%%%
analyzed.Session = currentsession;
if ispc
    if spinetraceoption == 1
        cd('E:\ActivitySummary')
    else
        cd('C:\Users\Komiyama\Desktop\ActivitySummary')
    end
elseif isunix
    cd('/usr/local/lab/People/Nathan/Data/ActivitySummaryFromSuperComputer')
end
%%%%

savefile = [folder, '_' Date, '_Summary'];
polyfile = [folder, '_',Date, '_PolySummary'];
eval([savefile, '= analyzed;']);
eval([polyfile, '= poly;']);

% save(savefile, savefile, '-v7.3')
save(savefile, savefile);
save(polyfile, polyfile, '-v7.3');

if showFig == 1
    figure('Position', [Scrsz(3)/2, 50 ,Scrsz(3)/2,Scrsz(4)/2]); 
    subplot(1,3,1)
        plot(Distances, Correlations, 'ok')
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
    for i = 1:numberofSpines;
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

disp([folder, '_', Date, ' (session ', num2str(analyzed.Session),')',' analysis complete'])

% spatialfit = robustfit(SpineToSpineDistance, SpineToSpineCorrelation);
% fitcurve = spatialfit(2)*([0:0.1:max(SpineToSpineDistance)])+spatialfit(1);


function [choice] = accept(hObject, eventdata, handles)
setappdata(gcf, 'choice', 0);
uiresume

function choice = reject(hObject, eventdata, handles)
setappdata(gcf, 'choice', 1);
uiresume