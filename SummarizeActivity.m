function a = SummarizeActivity(varargin)

Frequency = nan(1,14);
Amp = nan(1,14);
SynapseOnlyFreq = nan(1,14);
SpikeTimedEvents = nan(1,14);
Dendritic_Freq = nan(1,14);
Dendritic_Amp = nan(1,14);

for i = 1:length(varargin)
    session = varargin{i}.Session;
    Frequency(1,session) = mean(varargin{i}.Frequency);
    Amp(1,session) = mean(varargin{i}.MeanEventAmp);
    SynapseOnlyFreq(1,session) = mean(varargin{i}.SynapseOnlyFreq);
    SpikeTimedEvents(1,session) = mean(varargin{i}.SpikeTimedEvents);
    varargin{i}.Dendritic_Frequency = varargin{i}.Dendritic_Frequency(varargin{i}.Dendritic_Frequency~=0);
    Dendritic_Freq(1,session) = mean(varargin{i}.Dendritic_Frequency);
    varargin{i}.Dendritic_Amp = varargin{i}.Dendritic_Amp(varargin{i}.Dendritic_Amp~=0);
    Dendritic_Amp(1,session) = mean(varargin{i}.Dendritic_Amp);
end


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


subplot(2,3,1); plot(1:14,Frequency,'-ok', 'Linewidth', 2)
title('Event Frequency')
subplot(2,3,2); plot(1:14,Amp,'-ok', 'Linewidth', 2)
title('Event Amp')
subplot(2,3,3); plot(1:14, SynapseOnlyFreq,'-ok', 'Linewidth', 2)
title('Synapse Only Freq')
subplot(2,3,4); plot(1:14, SpikeTimedEvents,'-ok', 'Linewidth', 2)
title('Spike Timed Freq')
subplot(2,3,5); plot(1:14, Dendritic_Freq,'-ok', 'Linewidth', 2)
title('Dendritic Freq')
subplot(2,3,6); plot(1:14, Dendritic_Amp,'-ok', 'Linewidth', 2)
title('Dendritic Amp')


a.Frequency = Frequency;
a.Amplitude = Amp;
a.SynapseOnlyFreq = SynapseOnlyFreq;
a.SpikeTimedEvents = SpikeTimedEvents;
a.Dendritic_Frequency = Dendritic_Freq;
a.Dendritic_Amp = Dendritic_Amp;

mouse = regexp(varargin{1}.Filename, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
mouse = mouse{1};


cd('C:\Users\Komiyama\Desktop\Output Data')
savefile = [mouse, '_Timecourse_Summary'];
eval([savefile, '= a']);
save(savefile, savefile)

