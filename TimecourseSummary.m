function TimecourseSummary(varargin)

h1 = waitbar(0, 'Initializing...');

sensor = inputdlg('Enter Sensor', '', 1,{'GCaMP'});
if contains(sensor, 'GluSNFR')
    ImagingFrequency = 58.30;
elseif contains(sensor, 'GCaMP')
    ImagingFrequency = 30.49;
end

ns = length(varargin);
AllFreq = [];
Frequency = nan(ns,14);
Amp = nan(ns,14);
Dendritic_Freq = nan(ns,14);
Dendritic_Amp = nan(ns,14);
PercentTimeActive = nan(ns,14);
All_PercentTimeActive = [];
TotalActivity = nan(ns,14);
All_TotalActivity = [];

for i = 1:ns
    waitbar(i/ns,h1, ['Animal ', num2str(i), '/', num2str(ns)])
    files = fastdir('E:\ActivitySummary', varargin{i}, {'Poly', 'ZSeries'});
    for j = 1:length(files)
        load(files{j})
        eval(['Session = ', files{j}(1:end-4), '.Session;'])
        eval(['freq = ', files{j}(1:end-4), '.Frequency_DendriteSubtracted;'])
        AllFreq = [AllFreq; freq];
        Frequency(i,Session) = nanmedian(freq);
        eval(['floored_data = ', files{j}(1:end-4), '.Floored_DendriteSubtracted;'])
        Amp(i,Session) = nanmedian(floored_data(floored_data>0));
        eval(['dend_freq = ', files{j}(1:end-4), '.Dendritic_Frequency;'])
        Dendritic_Freq(i,Session) = nanmedian(dend_freq);
        eval(['dend_amp = ', files{j}(1:end-4), '.Dendritic_Amp;'])
        Dendritic_Amp(i,Session) = nanmedian(dend_amp);
        eval(['pta = (sum(', files{j}(1:end-4), '.SynapseOnlyBinarized,2)./ImagingFrequency)/(length(', files{j}(1:end-4), '.Fluorescence_Measurement{1})/(ImagingFrequency));'])
        PercentTimeActive(i,Session) = nanmedian(pta);
        All_PercentTimeActive = [All_PercentTimeActive; pta];
        eval(['TA = sum(', files{j}(1:end-4), '.SynapseOnlyBinarized.*', files{j}(1:end-4), '.Processed_dFoF,2)./ImagingFrequency;'])
        TotalActivity(i,Session) = nanmedian(TA);
        All_TotalActivity = [All_TotalActivity; TA];
        clear(files{j}(1:end-4));
    end
end

delete(h1)

%%%%%%%%%%%%%%%%%%%%%%
%%Color Information%%%
%%%%%%%%%%%%%%%%%%%%%%

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
    
scrsz = get(0, 'ScreenSize');
figure('Position', scrsz)
statchoice = 'nonparametric';

sub1 = 2;
sub2 = 2;
subcount = 1;

subplot(sub1,sub2,subcount); flex_plot(1:size(Frequency,2), Frequency, statchoice, 'k', 2);
title('Event Frequency')
xlabel('Session')
ylabel('Events/min')
subcount= subcount+1;

xlim([0 15])
subplot(sub1,sub2,subcount); flex_plot(1:size(Amp,2), Amp, statchoice, 'k', 2);
title('Event Amp')
xlim([0 15])
xlabel('Session')
ylabel('dF/F')
subcount = subcount+1;

subplot(sub1,sub2,subcount); flex_plot(1:size(Dendritic_Freq,2), Dendritic_Freq,statchoice, 'k', 2);
title('Dendritic Freq')
xlim([0 15])
xlabel('Session')
ylabel('Events/min')
subcount = subcount+1;

subplot(sub1,sub2,subcount); flex_plot(1:size(Dendritic_Amp,2), Dendritic_Amp, statchoice, 'k', 2);
title('Dendritic Amp')
xlim([0 15])
xlabel('Session')
ylabel('dF/F')


%==========================================================================
figure('Position', scrsz)
statchoice = 'nonparametric';

sub1 = 1;
sub2 = 2;
subcount = 1;


subplot(sub1,sub2,subcount); flex_plot(1:size(PercentTimeActive,2), PercentTimeActive, statchoice, 'k', 2);
title('Percent Time Active')
xlabel('Session')
ylabel('Events/min')
subcount= subcount+1;

xlim([0 15])
subplot(sub1,sub2,subcount); flex_plot(1:size(TotalActivity,2), TotalActivity, statchoice, 'k', 2);
title('Total Activity')
xlim([0 15])
xlabel('Session')
ylabel('dF/F')
subcount = subcount+1;
%==========================================================================
ActivityDataBasics.AnimalList = varargin;
ActivityDataBasics.Frequency = Frequency;
ActivityDataBasics.Amplitude = Amp;
ActivityDataBasics.DendriticFrequency = Dendritic_Freq;
ActivityDataBasics.DendriticAmplitude = Dendritic_Amp; 
date_string = datestr(datetime('today'));

Notes = inputdlg('Any notes for this analysis?', '', 1,{'Analyzed using...'});

ActivityDataBasics.Notes = Notes{1};

save([sensor{1}, ' ActivityDataBasics ', date_string], 'ActivityDataBasics')