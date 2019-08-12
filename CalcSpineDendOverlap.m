function PercentOverlap = CalcSpineDendOverlap(varargin)


if isempty(varargin)
    files = fastdir('E:\ActivitySummary', '_Summary');
    cd('E:\ActivitySummary');
    
    usefiles = inputdlg('Use how many files? (e.g. 20, half, all)', 'File number selection', 1, {'All'});
    
    if isempty(str2num(usefiles{1}))   %%% Check if the input is text
        switch usefiles{1}
            case 'All'
                usefiles = length(files);
            case 'Half'
                usefiles = round(length(files)/2);
        end
    else
        usefiles = str2num(usefiles{1});
    end
    choices = 1:length(files);
    randnum = choices(randi(length(choices),usefiles,1));
    
    
    filelist = files(randnum);
   

    for f = 1:length(filelist)
        load(filelist{f});
        eval(['File = ', filelist{f}(1:end-4), ';'])
        clear(filelist{f}(1:end-4));
        bound = cell(1,File.NumberofDendrites);
        split = cell(1,File.NumberofDendrites);

        for i = 1:File.NumberofDendrites
            bound{i} = find(diff([Inf; File.Dendrite_Binarized(i,:)'; Inf]) ~=0);   %%% Identify boundaries of dendritic activity
            split{i} = mat2cell(File.Dendrite_Binarized(i,:)', diff(bound{i}));     %%% Separate dendritic trace according to above boundaries
        end

        spinewithdendcounter = zeros(length(File.dF_over_F),1);
        allspineeventscounter = zeros(length(File.dF_over_F),1);
        Dend_events = zeros(File.NumberofDendrites,1);

        for i = 1:File.NumberofDendrites
            for j = 1:length(split{i})
                if sum(split{i}{j}) %%% If this epoch is nonzero, it's an event
                    Dend_events(i,1) = Dend_events(i,1) + 1;
                end
            end
        end

        for i = 1:length(File.SpineDendriteGrouping)
            for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
                spine_with_dend = mat2cell(File.SynapseOnlyBinarized_DendriteSubtracted(j,:)', diff(bound{i}));
                for k = 1:length(split{i})
                    if sum(split{i}{k}) %%% If the dendrite is active
                        if sum(spine_with_dend{k})  
                            spinewithdendcounter(j,1) = spinewithdendcounter(j,1)+1;
                        end
                    end
                end
                spinewithdendfraction{f}(j,1) = spinewithdendcounter(j)/Dend_events(i,1);
            end
        end

        for i = 1:length(File.dF_over_F)
            spine = mat2cell(File.SynapseOnlyBinarized_DendriteSubtracted(i,:)', diff(find(diff([Inf; File.SynapseOnlyBinarized_DendriteSubtracted(i,:)'; Inf]) ~=0)));
            for j = 1:length(spine)
                if sum(spine{j})
                    allspineeventscounter(i,1) = allspineeventscounter(i,1)+1;
                end
            end
            percentofspineeventsoverlappingdendriteevents{f}(i,1) = spinewithdendcounter(i,1)/allspineeventscounter(i,1);
        end
        for i = 1:length(File.dF_over_F)
            [pks locs] = findpeaks(smooth(File.Processed_dFoF(i,:).*File.SynapseOnlyBinarized(i,:),10), 'MinPeakHeight', File.SpineThreshold(i,1), 'MinPeakDistance', 20);
            spineAmpDendExc{i} = pks;
            msgid = [];
            [warnmsg, msgid] = lastwarn;
            if strcmpi(msgid, 'signal:findpeaks:largeMinPeakHeight')
                iter = 'limitreached';
            else
                iter = [];
            end
            [pks locs] = findpeaks(smooth(File.Processed_dFoF_DendriteSubtracted(i,:),10), 'MinPeakHeight', File.SpineThreshold(i,1), 'MinPeakDistance', 20);
            msgid = [];
            [warnmsg, msgid] = lastwarn;
            if strcmpi(msgid, 'signal:findpeaks:largeMinPeakHeight')
                iter = 'limitreached';
            else
                iter = [];
            end
            spineAmpDendSub{i} = pks;
        end
        SpineAmpDendExcluded{f} = cell2mat(spineAmpDendExc');
        SpineAmpDendSubtracted{f} = cell2mat(spineAmpDendSub');
    end
    
else
    filelist = varargin;

    for f = 1:length(filelist)
        File = filelist{f};
        bound = cell(1,File.NumberofDendrites);
        split = cell(1,File.NumberofDendrites);

        for i = 1:File.NumberofDendrites
            bound{i} = find(diff([Inf; File.Dendrite_Binarized(i,:)'; Inf]) ~=0);   %%% Identify boundaries of dendritic activity
            split{i} = mat2cell(File.Dendrite_Binarized(i,:)', diff(bound{i}));     %%% Separate dendritic trace according to above boundaries
        end

        spinewithdendcounter = zeros(length(File.dF_over_F),1);
        allspineeventscounter = zeros(length(File.dF_over_F),1);
        Dend_events = zeros(File.NumberofDendrites,1);

        for i = 1:File.NumberofDendrites
            for j = 1:length(split{i})
                if sum(split{i}{j}) %%% If this epoch is nonzero, it's an event
                    Dend_events(i,1) = Dend_events(i,1) + 1;
                end
            end
        end

        for i = 1:length(File.SpineDendriteGrouping)
            for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
                spine_with_dend = mat2cell(File.SynapseOnlyBinarized_DendriteSubtracted(j,:)', diff(bound{i}));
                for k = 1:length(split{i})
                    if sum(split{i}{k}) %%% If the dendrite is active
                        if sum(spine_with_dend{k})  
                            spinewithdendcounter(j,1) = spinewithdendcounter(j,1)+1;
                        end
                    end
                end
                spinewithdendfraction{f}(j,1) = spinewithdendcounter(j)/Dend_events(i,1);
            end
        end

        for i = 1:length(File.dF_over_F)
            spine = mat2cell(File.SynapseOnlyBinarized_DendriteSubtracted(i,:)', diff(find(diff([Inf; File.SynapseOnlyBinarized_DendriteSubtracted(i,:)'; Inf]) ~=0)));
            for j = 1:length(spine)
                if sum(spine{j})
                    allspineeventscounter(i,1) = allspineeventscounter(i,1)+1;
                end
            end
            percentofspineeventsoverlappingdendriteevents{f}(i,1) = spinewithdendcounter(i,1)/allspineeventscounter(i,1);
        end
        for i = 1:length(File.dF_over_F)
            [pks locs] = findpeaks(smooth(File.Processed_dFoF(i,:).*File.SynapseOnlyBinarized(i,:),10), 'MinPeakHeight', File.SpineThreshold(i,1), 'MinPeakDistance', 20);
            spineAmpDendExc{i} = pks;
            msgid = [];
            [warnmsg, msgid] = lastwarn;
            if strcmpi(msgid, 'signal:findpeaks:largeMinPeakHeight')
                iter = 'limitreached';
            else
                iter = [];
            end
            [pks locs] = findpeaks(smooth(File.Processed_dFoF_DendriteSubtracted(i,:),10), 'MinPeakHeight', File.SpineThreshold(i,1), 'MinPeakDistance', 20);
            msgid = [];
            [warnmsg, msgid] = lastwarn;
            if strcmpi(msgid, 'signal:findpeaks:largeMinPeakHeight')
                iter = 'limitreached';
            else
                iter = [];
            end
            spineAmpDendSub{i} = pks;
        end
        SpineAmpDendExcluded{f} = cell2mat(spineAmpDendExc');
        SpineAmpDendSubtracted{f} = cell2mat(spineAmpDendSub');
    end
end


PercentOverlap.PercentofDendEventswithSpineActivity = spinewithdendfraction;
FractionofspineeventswithAPs = percentofspineeventsoverlappingdendriteevents;
figure; hist(cell2mat(spinewithdendfraction'), 50); hold on;
plot(nanmedian(cell2mat(spinewithdendfraction'))*ones(1,length(0:nanmax(hist(cell2mat(spinewithdendfraction'), 50)))),0:nanmax(hist(cell2mat(spinewithdendfraction'),50)),'--r')
text(nanmedian(cell2mat(spinewithdendfraction')),nanmax(hist(cell2mat(spinewithdendfraction'), 50))+2, ['Median = ', num2str(nanmedian(cell2mat(spinewithdendfraction')))])
xlabel('Fraction Dendrite Events with Spine Activity')
ylabel('Count')
ylim([0 nanmax(hist(cell2mat(spinewithdendfraction'), 50))+3])
PercentOverlap.PercentofSpineEventsCoincidentwithDend = FractionofspineeventswithAPs;
figure; hist(cell2mat(FractionofspineeventswithAPs'), 50); hold on;
plot(nanmedian(cell2mat(FractionofspineeventswithAPs'))*ones(1,length(0:nanmax(hist(cell2mat(FractionofspineeventswithAPs'), 50)))),0:nanmax(hist(cell2mat(FractionofspineeventswithAPs'),50)), '--r')
text(nanmedian(cell2mat(FractionofspineeventswithAPs')),nanmax(hist(cell2mat(FractionofspineeventswithAPs'), 50))+2, ['Median = ', num2str(nanmedian(cell2mat(FractionofspineeventswithAPs')))])
xlabel('Fraction of spine events occurring with AP')
ylabel('Count')
ylim([0 nanmax(hist(cell2mat(FractionofspineeventswithAPs'), 50))+3])

PercentOverlap.SpineAmpDendSubtracted = SpineAmpDendSubtracted;
PercentOverlap.SpineAmpDendExcluded = SpineAmpDendExcluded;
figure; hist(cell2mat(SpineAmpDendExcluded'), 20000);
h = findobj(gca, 'Type', 'patch');
set(h, 'FaceColor', 'r', 'EdgeColor', 'r')
hold on; hist(cell2mat(SpineAmpDendSubtracted'), 20000);
xlabel('Amplitude of Spine Events')
xlim([-1 50])
ylabel('Count')
legend({['Dendrite Excluded (median = ', num2str(nanmedian(cell2mat(SpineAmpDendExcluded'))), ')'], ['Dendrite Subtracted (median = ', num2str(nanmedian(cell2mat(SpineAmpDendSubtracted'))), ')']})

uistack(h, 'top')

