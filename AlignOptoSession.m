function AlignOptoSession(Filename)

animal = regexp(Filename, '[A-Z]{2,3}0\d+', 'match');
animal = animal{1};
date = regexp(Filename, '_\d+', 'match');
date = date{1}(2:end);

cd('E:\ActivitySummary')

act_file = fastdir(cd, [Filename, '_OptoSummary']);

load(act_file{1});

eval(['Fluor = ', act_file{1}(1:end-4), ';'])

cd('E:\Behavioral Data\All Summarized Behavior Files list')

beh_file = fastdir(cd, [animal, '_OPTO_', date, '_Behavior']);

load(beh_file{1});

eval(['Beh = ', beh_file{1}(1:end-4), ';'])

numSpines = Fluor.NumberofSpines;

NumOptoTrials = length(Beh.Behavior_Frames);


OptoStim = zeros(1,length(Fluor.Processed_dFoF));
for i = 1:NumOptoTrials
    start = Beh.Behavior_Frames{i}.states.iti2(1);
    stop = Beh.Behavior_Frames{i}.states.iti2(2);
    OptoStim(start:stop) = 1;
end

sf.OptoStim = OptoStim;

zscored_rawtrace = zscore(Fluor.Processed_dFoF(:,:),[],2);
zscored_dendsubtrace = zscore(Fluor.Processed_dFoF_DendriteSubtracted(:,:),[],2);

%%%%%%%%%%%%%%%%%%%%%%%
StimResponsiveROIs = [];
Suppressed_ROIs = [];
Excited_ROIs = [];
SlowResponsiveROIs = [];
%%%%%%%%%%%%%%%%%%%%%%%%
suppressed_count = 1;
excited_count = 1;

trialbytrial_raw = cell(1,numSpines);
trialbytrial_dendsub = cell(1,numSpines);
prestimwindow = 60;
poststimwindow = 30;
for s = 1:numSpines
    for ot = 1:NumOptoTrials
        start = Beh.Behavior_Frames{ot}.states.iti2(1)-prestimwindow;
        stop = Beh.Behavior_Frames{ot}.states.iti2(2)+poststimwindow;
        if mod(start,1)    %%% If the frame values for start and stop are not integers, skip this trial
            continue
        end
        stimduration =  Beh.Behavior_Frames{ot}.states.iti2(2)- Beh.Behavior_Frames{ot}.states.iti2(1);
        trialbytrial_raw{s}(ot,:) = zscored_rawtrace(s,start:stop);
        trialbytrial_dendsub{s}(ot,:) = zscored_dendsubtrace(s,start:stop);
    end
    pre_stim_activity = nanmean(trialbytrial_dendsub{s}(:,1:prestimwindow),1);
    stim_activity = nanmean(trialbytrial_dendsub{s}(:,prestimwindow+1:prestimwindow+stimduration));
    post_stim_activity = nanmean(trialbytrial_dendsub{s}(:,prestimwindow+stimduration+1:end));
    pfast = ranksum(pre_stim_activity, stim_activity); %%% Compare activity before and DURING opto stimulus
    if pfast<0.001 
        StimResponsiveROIs = [StimResponsiveROIs; s];
        if nanmean(pre_stim_activity)>nanmean(stim_activity)
            Suppressed_ROIs = [Suppressed_ROIs; s];
            Suppressed_ROI_traces{suppressed_count} = trialbytrial_dendsub{s};
            suppressed_count = suppressed_count+1;
        elseif nanmean(pre_stim_activity)<nanmean(stim_activity)
            Excited_ROIs = [Excited_ROIs; s];
            Excited_ROI_traces{excited_count} = trialbytrial_dendsub{s};
            excited_count = excited_count+1;
        end
    end
    pslow = ranksum(pre_stim_activity, post_stim_activity); %%% Compare activity before and AFTER opto stimulus
    if pslow<0.01 && pfast>0.05
        SlowResponsiveROIs = [SlowResponsiveROIs; s];
    end
end

sf.TotalNumberofROIs = numSpines;
sf.StimResponsiveROIs = StimResponsiveROIs;
sf.SlowResponsiveROIs = SlowResponsiveROIs;
sf.Suppressed_ROIs = Suppressed_ROIs;
sf.Suppressed_ROI_Traces = Suppressed_ROI_traces;
sf.Excited_ROIs = Excited_ROIs;
sf.Excited_ROI_Traces = Excited_ROI_traces;


savefilename = [Filename, '_OptoClassification'];
eval([savefilename, ' = sf;'])

cd('C:\Users\Komiyama\Desktop\Output Data')
save(savefilename, savefilename)


datasumfig = figure;
for s = 1:numSpines
    plot(trialbytrial_dendsub{s}'); hold on;
    plot(nanmean(trialbytrial_dendsub{s},1), 'k', 'linewidth', 2)
    if ismember(s,Excited_ROIs)
        patchcolor = 'g';
        titlemessage = 'Excited';
    elseif ismember(s,Suppressed_ROIs)
        patchcolor = 'b';
        titlemessage = 'Suppressed';
    else
        patchcolor = 'r';
        titlemessage = 'Unresp.';
    end
    patch_binary_periods(logical([zeros(1,60), ones(1,30),zeros(1,30)]), 'datamax', max(trialbytrial_dendsub{s}(:))+0.5, 'datamin', -2, 'patchcolor', patchcolor)
    title(['Spine No. ', num2str(s), ' (', titlemessage, ')'])
    pause
    cla
end

close(datasumfig)


