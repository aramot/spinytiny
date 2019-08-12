function SpineVolumeSummary(varargin)

h1 = waitbar(0, 'Initializing...');

%%% Variable Initiation
overalldendritecount = 1;
Spine1Address = 10;

for animal = 1:length(varargin)
    waitbar(animal/length(varargin), h1, ['Animal ', num2str(animal), '/', num2str(length(varargin))])
    experimentnames = varargin{animal}; 
    %%%%%%%%%%%% Load Spine Dynamics Registry for a given animal
    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        OutputDataFolder = 'C:\Users\Komiyama\Desktop\Output Data';
        cd([OutputDataFolder, filesep, experimentnames, ' New Spine Analysis'])
    end
    fieldsource = fastdir(cd, 'Field');
    [~, ind] = sort(cellfun(@(x) regexp(x, '[0-9]{1}', 'match'),fieldsource));
    for fieldcount = 1:length(fieldsource)
        sortedfield = ind(fieldcount);
        load(fieldsource{sortedfield})
        eval(['FieldData{animal}{', num2str(sortedfield), '} = SpineRegistry;']);
        fieldnumber = regexp(fieldsource{fieldcount}, '[0-9]{1}', 'match');
        FieldData{animal}{sortedfield}.FieldNumber = str2num(fieldnumber{1});  %%% Because of the naming system of the files, Field 2 can be loaded before Field 1 (e.g. if files are Named Imaging Field 2 vs. Nathan_Imaging Field 1). This is normally fine, as the dates are the primary determinant of the data loaded, but in some cases, actual field numbers are used.
        clear SpineRegistry
    end
    NumFields = length(FieldData{animal});
    FieldChanges = cell(1,NumFields);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    voldatadir = [OutputDataFolder, filesep, experimentnames, ' Spine Volume Data'];
    if ~isdir(voldatadir)
        continue
    end
    for fieldcount = 1:NumFields
        currentFieldNumber = FieldData{animal}{fieldcount}.FieldNumber;
        FieldChanges{fieldcount} = diff(FieldData{animal}{fieldcount}.Data,1,2);
        DynamicSpines = [];
        for s = 1:size(FieldChanges{fieldcount},2)
            DynamicSpines = [DynamicSpines; find(FieldChanges{fieldcount}(:,s))];
        end
        breakfield = 0;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%% Load Spine Volume data %%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        currentdates = sortrows(FieldData{animal}{fieldcount}.DatesAcquired);
        thisdir = dir(voldatadir);
        cd(voldatadir)
        found = 0;
        for file = 1:length(thisdir)
            likelydate = regexp(thisdir(file).name, '_[0-9]{4,6}_', 'match');
            if ~isempty(likelydate)
                datelabel = likelydate{1}(2:end-1);
                datesearch = cell2mat(cellfun(@(x) contains(x, datelabel), currentdates, 'uni', false));
                if any(datesearch)
                    session = find(datesearch);
                    load(thisdir(file).name)
                    dataname = thisdir(file).name(1:end-4);
                    eval(['FieldData{animal}{fieldcount}.SpineVolumeData(:,session) = ', dataname, '.DendriteNormalizedSpineIntensity;'])
                    clear(dataname)
                    found = found+1;
                end
            end
        end
        if found~=length(currentdates)
            breakfield = 1;
        end
        if breakfield
            continue
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% Load calcium imaging data for the animal %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
            activitydir = 'E:\ActivitySummary';
            cd(activitydir)
        end
        activitydata = fastdir(activitydir, [experimentnames, '.+_Summary']);
        for cdate = 1:length(currentdates)
            correspfile = activitydata{cellfun(@(x) contains(x,currentdates{cdate}), activitydata)};
            load(correspfile)
            eval(['currentactdata = ', correspfile(1:end-4), ';'])
            %%% Collect a subset of the data from the activity data file;
            %%% loading the whole thing is too expensive to memory
            FieldData{animal}{fieldcount}.CalciumData{cdate}.NumberofSpines = currentactdata.NumberofSpines; NumberofSpines = currentactdata.NumberofSpines;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.SpineDendriteGrouping = currentactdata.SpineDendriteGrouping;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.Session = currentactdata.Session;
            clear currentactdata)
            clear(correspfile(1:end-4))
        end
        FieldData{animal}{fieldcount}.CalciumData = FieldData{animal}{fieldcount}.CalciumData(~cellfun(@isempty, FieldData{animal}{fieldcount}.CalciumData));
        sessionstouse = find(~cellfun(@isempty, FieldData{animal}{fieldcount}.CalciumData));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% Load Statistical classification data %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        statdata = fastdir(OutputDataFolder, [experimentnames, '_StatClassified']);
        if ~isempty(statdata)
            load([OutputDataFolder,filesep, statdata{1}])
        else
            disp(['Cannot load stat data for animal ', experimentnames]);
        end
        eval(['statclass = ', experimentnames, '_StatClassified;'])
        clear(statdata{1}(1:end-4));
        
        for s = sessionstouse
            if ~isempty(FieldData{animal}{fieldcount}.CalciumData{s})
                FieldData{animal}{fieldcount}.StatClass{s} = statclass{FieldData{animal}{fieldcount}.CalciumData{s}.Session};
            else
                FieldData{animal}{fieldcount}.StatClass{s} = [];
            end
        end 
        clear('statclass')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% Load Behavioral Correlation Data %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        corrfiles = fastdir(OutputDataFolder, [experimentnames, '_Correlations']);
        if ~isempty(corrfiles)
            load([OutputDataFolder,filesep, corrfiles{1}])
        else
            disp(['Cannot load stat data for animal ', experimentnames]);
        end
        eval(['corrdata = ', experimentnames, '_Correlations;'])
        clear(corrfiles{1}(1:end-4));
        
        for s = sessionstouse
            if ~isempty(FieldData{animal}{fieldcount}.CalciumData{s})
                FieldData{animal}{fieldcount}.Correlations{s} = corrdata{FieldData{animal}{fieldcount}.CalciumData{s}.Session};
            else
                FieldData{animal}{fieldcount}.Correlations{s} = [];
            end
        end 
        clear('corrdata');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%% Load Spine Dynamics Summary Data %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Note: this data is handled in field numbers, not by date!
        
        dyndata = fastdir(OutputDataFolder, [experimentnames, '_SpineDynamicsSummary']);
        if ~isempty(dyndata)
            load([OutputDataFolder,filesep,dyndata{1}])
        else
            disp(['Cannot load spine dynamics data for animal ', experimentnames])
        end
        eval(['SpineDynamics = ', experimentnames, '_SpineDynamicsSummary;'])
        clear(dyndata{1}(1:end-4))
        
        NewSpines = SpineDynamics.NewSpines{fieldcount};
        ElimSpines = SpineDynamics.ElimSpines{fieldcount};
        
        ClusteredEarlyMovementSpines = SpineDynamics.ClusteredEarlyMoveSpines{fieldcount};
        ClusteredLateMovementSpines = SpineDynamics.ClusteredLateMoveSpines{fieldcount};
        ClusteredNewSpines = SpineDynamics.ClusteredNewSpines{fieldcount};
        AntiClusteredMovementSpines = SpineDynamics.AntiClusteredMoveSpines{fieldcount};
        AntiClusteredElimSpines = SpineDynamics.AnitClusteredElimSpines{fieldcount};
        
        %%% Find the change in spine volume
        DeltaSpineVolume{fieldcount} = FieldData{animal}{fieldcount}.SpineVolumeData(:,:)./FieldData{animal}{fieldcount}.SpineVolumeData(:,1);
        CueSpines = logical(sum(cell2mat(cellfun(@(x) x.DendSub_CueSpines, FieldData{animal}{fieldcount}.StatClass, 'uni', false)),2));
        MovementSpines = logical(sum(cell2mat(cellfun(@(x) x.MovementSpines, FieldData{animal}{fieldcount}.StatClass, 'uni', false)),2));
        DSMovementSpines = find(logical(sum(cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{animal}{fieldcount}.StatClass, 'uni', false)),2))); %%% Assumes movement-related spine identity at ANY POINT DURING TRAINING
        DSMovementSpines = setdiff(DSMovementSpines, DynamicSpines);    %%% Don't include any dynamic spines, the spine volume calculation of which doesn't make any sense
        CSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(CueSpines,:);
        MRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(MovementSpines,:);
        DS_MRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(DSMovementSpines,:);
        if ~isempty(ClusteredEarlyMovementSpines)
            cMRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(ClusteredEarlyMovementSpines,:);
        else
            cMRSDeltaVolume{animal}{fieldcount} = NaN;
        end
        if ~isempty(AntiClusteredMovementSpines)
            aMRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(AntiClusteredMovementSpines,:);
        else
            aMRSDeltaVolume{animal}{fieldcount} = NaN;
        end
        OtherSpines = setdiff(setdiff(1:NumberofSpines,DSMovementSpines), DynamicSpines);
        OtherSpinesDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(OtherSpines,:);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%% Plasticity score by dendrite %%%%%%%%%%%%%%%%%%%
        
        DGrouping = FieldData{animal}{fieldcount}.CalciumData{1}.SpineDendriteGrouping;
        NumberofDendrites = length(DGrouping);
        for d = 1:NumberofDendrites
            DendriteData(overalldendritecount,1:9) = FieldData{animal}{fieldcount}.Correlations{1}.OverallSpineCorrelations(1:9, Spine1Address+NumberofSpines+(d-1)); %%% Dendrite behavioral feature correlation FROM EARLY SESSIONS
            DendriteData(overalldendritecount,10:18) = FieldData{animal}{fieldcount}.Correlations{end}.OverallSpineCorrelations(1:9, Spine1Address+NumberofSpines+(d-1)); %%% Dendrite behavioral feature correlation FROM EARLY SESSIONS
            DendriteData(overalldendritecount,19) = sum(ismember(NewSpines, DGrouping{d}))/length(DGrouping{d}); %%% Number of spine additions (normalized by total spine number on dendrite)
            DendriteData(overalldendritecount,20) = sum(ismember(ElimSpines, DGrouping{d}))/length(DGrouping{d}); %%% Number of spine eliminations (normalized by total spine number on dendrite)
            DendriteData(overalldendritecount,21) = sum(nanmean(DeltaSpineVolume{fieldcount}(DGrouping{d},2:end),2)>=1)/length(DGrouping{d}); %%% Number of spines showing stable or increased volume (normalized by total spine number on dend)
            DendriteData(overalldendritecount,22) = sum(nanmean(DeltaSpineVolume{fieldcount}(DGrouping{d},2:end),2)<1)/length(DGrouping{d}); %%% Number of spines showing decreased volume (normalized by total spine number on dend)
            DendriteData(overalldendritecount,23) = sum(ismember(DSMovementSpines, DGrouping{d}))/length(DGrouping{d});  %%% Fraction of spines that are movement-related
            DendriteData(overalldendritecount,24) = sum(ismember(ClusteredEarlyMovementSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines from early sessions
            DendriteData(overalldendritecount,25) = sum(ismember(ClusteredLateMovementSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines from late sessions
            DendriteData(overalldendritecount,26) = sum(ismember(union(ClusteredEarlyMovementSpines,ClusteredLateMovementSpines), DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines at any session
            DendriteData(overalldendritecount,27) = sum(ismember(ClusteredNewSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered new spines
            DendriteData(overalldendritecount,28) = sum(ismember(AntiClusteredElimSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are anti-clustered eliminated spines
            overalldendritecount = overalldendritecount+1;
        end
        
    end
    disp(['Spine volume summary for ', varargin{animal}, ' complete'])
end
close(h1)

cd(OutputDataFolder)
save('DendriteSummaryData', 'DendriteData')

AllMat = []; CSMat = []; MRSMat = []; DS_MRSMat = [];DS_MRSMatMid = []; cMRSMat = [];cMRSMatMid = []; aMRSMat = []; aMRSMatMid = []; OtherMat = []; OtherMatMid = [];
for i = 1:length(FieldData)
    for j = 1:length(FieldData{i})
        if isfield(FieldData{i}{j}, 'SpineVolumeData')
            AllMat = [AllMat; FieldData{i}{j}.SpineVolumeData(:,end)];
            if ~isempty(CSDeltaVolume{i})
                if ~isempty(CSDeltaVolume{i}{j})
                    CSMat = [CSMat; CSDeltaVolume{i}{j}(:,end)];
                end
            end
            if ~isempty(MRSDeltaVolume{i})
                if ~isempty(MRSDeltaVolume{i}{j})
                    MRSMat = [MRSMat; MRSDeltaVolume{i}{j}(:,end)];
                end
            end
            if ~isempty(DS_MRSDeltaVolume{i})
                if ~isempty(DS_MRSDeltaVolume{i}{j})
                    if size(DS_MRSDeltaVolume{i}{j},2)>2
                        DS_MRSMatMid = [DS_MRSMatMid; DS_MRSDeltaVolume{i}{j}(:,2)];
                    end
                    DS_MRSMat = [DS_MRSMat; DS_MRSDeltaVolume{i}{j}(:,end)];
                end
            end
            if ~isempty(cMRSDeltaVolume{i})
                if ~isempty(cMRSDeltaVolume{i}{j})
                    if size(cMRSDeltaVolume{i}{j},2)>2
                        cMRSMatMid = [cMRSMatMid; cMRSDeltaVolume{i}{j}(:,2)];
                    end
                    cMRSMat = [cMRSMat; cMRSDeltaVolume{i}{j}(:,end)];
                end
            end
            if ~isempty(aMRSDeltaVolume{i})
                if ~isempty(aMRSDeltaVolume{i}{j})
                    if size(aMRSDeltaVolume{i}{j},2)>2
                        aMRSMatMid = [aMRSMatMid; aMRSDeltaVolume{i}{j}(:,2)];
                    end
                    aMRSMat = [aMRSMat; aMRSDeltaVolume{i}{j}(:,end)];
                end
            end
            if ~isempty(OtherSpinesDeltaVolume{i})
                if ~isempty(OtherSpinesDeltaVolume{i}{j})
                    if size(OtherSpinesDeltaVolume{i}{j},2)>2
                        OtherMatMid = [OtherMatMid; OtherSpinesDeltaVolume{i}{j}(:,2)];
                    end
                    OtherMat = [OtherMat; OtherSpinesDeltaVolume{i}{j}(:,end)];
                end
            end
        end
    end
end
OtherMat(OtherMat<=0) = NaN;    %OtherMat(isoutlier(OtherMat))= NaN;
OtherMatMid(OtherMatMid<=0)=NaN; %OtherMatMid(isoutlier(OtherMatMid)) = NaN;
CSMat(CSMat<=0) = NaN;
MRSMat(MRSMat<=0) = NaN;
% MRSMatMid(MRSMatMid<=0) = NaN;
DS_MRSMat(DS_MRSMat<=0) = NaN;  %MRSMat(isoutlier(MRSMat)) = NaN;
DS_MRSMatMid(DS_MRSMatMid<=0) = NaN; %MRSMatMid(isoutlier(MRSMatMid)) = NaN;
cMRSMat(cMRSMat<=0) = NaN;  %cMRSMat(isoutlier(cMRSMat)) = NaN;
cMRSMatMid(cMRSMatMid<=0) = NaN; %cMRSMatMid(isoutlier(cMRSMatMid)) = 0;
aMRSMat(aMRSMat<=0) = NaN;% aMRSMat(isoutlier(aMRSMat)) = NaN;
aMRSMatMid(aMRSMatMid<=0) = NaN; %aMRSMatMid(isoutlier(aMRSMatMid)) = NaN;

% figure; plot(linspace(0.75,1.25, length(DS_MRSMat)), DS_MRSMat', '.', 'Markersize', 14)
% hold on; plot(linspace(1.75, 2.25, length(OtherMat)), OtherMat', '.', 'Markersize', 14)
% plot(linspace(2.75,3.25,length(cMRSMat)), cMRSMat', '.', 'Markersize', 14)
% plot(linspace(3.75,4.25,length(aMRSMat)), aMRSMat', '.', 'Markersize', 14)
datamat = [{OtherMat}, {CSMat}, {MRSMat},{DS_MRSMat}, {cMRSMat}, {aMRSMat}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
ranksum(DS_MRSMat, OtherMat);
