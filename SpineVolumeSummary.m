function SpineVolumeSummary(varargin)

h1 = waitbar(0, 'Initializing...');

%%% Variable Initiation
overalldendritecount = 1;
Spine1Address = 10;

DendritesbyAnimal = cell(1,length(varargin));

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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% Load Behavioral Data %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    behdata = fastdir(OutputDataFolder, [experimentnames, '_SummarizedBehavior']);
    if ~isempty(behdata)
        load([OutputDataFolder,filesep, behdata{1}]);
    else
        disp(['Cannot load behavior data for animal ', experimentnames, '!']);
    end
    eval(['fullbehaviordata = ', experimentnames, '_SummarizedBehavior;'])
    clear(behdata{1}(1:end-4))

    BehaviorSummary{animal}.WithinSessionsCorr = diag(fullbehaviordata.MovementCorrelation);
        y = diag(fullbehaviordata.MovementCorrelation);
        x = [1:length(y)]';
        x = x(~isnan(y));
        y = y(~isnan(y));

        X = [ones(length(x),1),x];
        b = X\y;

        yCalc = X*b;
        LearningCurve = (yCalc(end)-yCalc(1))/length(x);
    BehaviorSummary{animal}.WithinSessionsSlope = LearningCurve;
    BehaviorSummary{animal}.AcrossSessionsCorr = diag(fullbehaviordata.MovementCorrelation,1);
        y = diag(fullbehaviordata.MovementCorrelation,1);
        x = [2:length(diag(fullbehaviordata.MovementCorrelation,1))+1]';
        x = x(~isnan(y));
        y = y(~isnan(y));

        X = [ones(length(x),1),x];
        b = X\y;

        yCalc = X*b;
        LearningCurve = (yCalc(end)-yCalc(1))/length(x);
    BehaviorSummary{animal}.AcrossSessionsSlope = LearningCurve;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    voldatadir = [OutputDataFolder, filesep, experimentnames, ' Spine Volume Data'];
    if ~isdir(voldatadir)
        continue
    end
    shiftedfieldcount = 1; %%% useful for data structures that don't match the {field}{new spine} organization
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
                    eval(['FieldData{animal}{fieldcount}.SpineVolumeData(:,session) = ', dataname, '.DendriteNormalizedIntegratedSpineIntensity;'])
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
            FieldData{animal}{fieldcount}.CalciumData{cdate}.Frequency = currentactdata.Frequency;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.MeanEventAmp = currentactdata.MeanEventAmp';
            FieldData{animal}{fieldcount}.CalciumData{cdate}.Session = currentactdata.Session;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.PolyROIPosition = currentactdata.PolyLinePos;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.ROIPosition = currentactdata.ROIPosition;
            FieldData{animal}{fieldcount}.CalciumData{cdate}.ZoomValue = currentactdata.ZoomValue;
            clear currentactdata)
            clear(correspfile(1:end-4))
        end
        FieldData{animal}{fieldcount}.CalciumData = FieldData{animal}{fieldcount}.CalciumData(~cellfun(@isempty, FieldData{animal}{fieldcount}.CalciumData));
        sessionstouse = find(~cellfun(@isempty, FieldData{animal}{fieldcount}.CalciumData));   %%% This is only getting an address to access the sessions, and doesn't correspond to the session numbers themselves!
        
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
        
        ClusteredEarlyMovementSpines = SpineDynamics.ClusteredEarlyMoveSpines{fieldcount}; %%% Note: this includes both early and mid-session cMRSs (as per NewSpineAnalysis.m)
        ClusteredLateMovementSpines = SpineDynamics.ClusteredLateMoveSpines{fieldcount};
        ClusteredNewSpines = SpineDynamics.ClusteredNewSpines{fieldcount};
        AntiClusteredMovementSpines = SpineDynamics.AntiClusteredMoveSpines{fieldcount};
        AntiClusteredElimSpines = SpineDynamics.AntiClusteredElimSpines{fieldcount};
        
        %%% Find the change in spine volume
        DeltaSpineVolume = [];
        DeltaSpineVolume{fieldcount} = FieldData{animal}{fieldcount}.SpineVolumeData(:,:)./FieldData{animal}{fieldcount}.SpineVolumeData(:,1);
        if any(DeltaSpineVolume{fieldcount}==Inf)
            k = 1;
        end
        DeltaSpineVolume{fieldcount}(DeltaSpineVolume{fieldcount}==Inf) = NaN;
        CueSpines = logical(sum(cell2mat(cellfun(@(x) x.OverallCueSpines, FieldData{animal}{fieldcount}.StatClass(1), 'uni', false)),2));
        %==================================================================
%         MovementSpines = find(logical(sum(cell2mat(cellfun(@(x) x.OverallMovementSpines, FieldData{animal}{fieldcount}.StatClass(1), 'uni', false)),2)));   %%% Make sure you pay attention to whether you're looking at just early MRSs or all of them
        MovementSpines = find(logical(sum(cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{animal}{fieldcount}.StatClass(1), 'uni', false)),2)));   %%% Make sure you pay attention to whether you're looking at just early MRSs or all of them
        %%% Movement Spine Filtering!!=====================================
        MovementSpines = setdiff(MovementSpines, DynamicSpines); 
        MovementSpines = setdiff(MovementSpines, ClusteredEarlyMovementSpines);
            %%% Filter for distance from the edge
            MovementSpinesClosetoEdge = [];
            if ischar(FieldData{animal}{fieldcount}.CalciumData{cdate}.ZoomValue)
                ZoomValue = str2num(FieldData{animal}{fieldcount}.CalciumData{cdate}.ZoomValue);
            else
                ZoomValue = FieldData{animal}{fieldcount}.CalciumData{cdate}.ZoomValue;
            end
            pixpermicron = 0.5*ZoomValue; %% 0.5 corresponds to the pixel/micron value at 512x512 at 1x zoom on BScope 1
            for ms = 1:length(MovementSpines)
                [~,closestPolyROI] = min(cellfun(@(x) sqrt((FieldData{animal}{fieldcount}.CalciumData{1}.ROIPosition{MovementSpines(ms)+1}(1)-x(1))^2+(FieldData{animal}{fieldcount}.CalciumData{1}.ROIPosition{MovementSpines(ms)+1}(2)-x(2))^2), FieldData{animal}{fieldcount}.CalciumData{1}.PolyROIPosition));
                closestPolyROIPosition = FieldData{animal}{fieldcount}.CalciumData{1}.PolyROIPosition{closestPolyROI};
                BranchEnd1 = FieldData{animal}{fieldcount}.CalciumData{1}.PolyROIPosition{1}; BranchEnd2 = FieldData{animal}{fieldcount}.CalciumData{1}.PolyROIPosition{end};
                if (sqrt((closestPolyROIPosition(1)-BranchEnd1(1))^2+(closestPolyROIPosition(2)-BranchEnd1(2))^2)/pixpermicron)<15 || (sqrt((closestPolyROIPosition(1)-BranchEnd2(1))^2+(closestPolyROIPosition(2)-BranchEnd2(2))^2)/pixpermicron)<15
                    MovementSpinesClosetoEdge = [MovementSpinesClosetoEdge, MovementSpines(ms)];
                end
            end
            FractionofSpinesExcludedonDistance{animal}{fieldcount} = length(MovementSpinesClosetoEdge)/length(MovementSpines);
            MovementSpines = setdiff(MovementSpines, MovementSpinesClosetoEdge);
        %==================================================================
        DSMovementSpines = find(logical(sum(cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{animal}{fieldcount}.StatClass, 'uni', false)),2))); %%% Assumes movement-related spine identity at ANY POINT DURING TRAINING
        DSMovementSpines = setdiff(DSMovementSpines, DynamicSpines);    %%% Don't include any dynamic spines, the spine volume calculation of which doesn't make any sense
        CSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(CueSpines,:);
        MRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(MovementSpines,:);
        DS_MRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(DSMovementSpines,:);
        if ~isempty(AntiClusteredMovementSpines)
            aMRSDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(AntiClusteredMovementSpines,:);
        else
            aMRSDeltaVolume{animal}{fieldcount} = NaN;
        end
        OtherSpines = setdiff(setdiff(1:NumberofSpines,MovementSpines), DynamicSpines);
        OtherSpinesDeltaVolume{animal}{fieldcount} = DeltaSpineVolume{fieldcount}(OtherSpines,:);
        if ~isempty(SpineDynamics.ClusteredMovementSpineVolume{fieldcount})
            cMRSvolume = SpineDynamics.ClusteredMovementSpineVolume{fieldcount};
            cMRSDeltaVolume{animal}{fieldcount} = cMRSvolume;
            for search = 1:length(cMRSvolume)
                if any(cMRSvolume{search}==Inf)
                    k = 1;
                end
                cMRSvolume{search}(cMRSvolume{search}==Inf) = nan;
            end
            ClusterCorrelation = SpineDynamics.AllClusterCorrelationsbyNewSpine{fieldcount};
            AllClusterCorrelation{animal}{fieldcount} = ClusterCorrelation;
            NoiseCorrelation = SpineDynamics.AllMoveCentricClusterCorrelationsbyNewSpine{fieldcount};
            SeedlingMovementSimilarity = SpineDynamics.SimilarityofClusteredMovementwithSeedlingMRSMovement{fieldcount};
            validNS = cellfun(@(x) any(~isnan(x)), ClusterCorrelation);
            MRSDeltaVolumebyMaxCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSvolume(validNS), ClusterCorrelation(validNS)));
            MRSDeltaVolumebyHighCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSvolume(validNS), ClusterCorrelation(validNS), 'uni', false)));
            MRSDeltaVolumebyLowCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y<0.05), cMRSvolume(validNS), ClusterCorrelation(validNS), 'uni', false)));
            MRSDeltaVolumebyMaxNoiseCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSvolume(validNS), NoiseCorrelation(validNS)));
            MRSDeltaVolumebyHighNoiseCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSvolume(validNS), NoiseCorrelation(validNS), 'uni', false)));
            MRSDeltaVolumebyLowNoiseCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y<0.05), cMRSvolume(validNS), NoiseCorrelation(validNS), 'uni', false)));
            MRSDeltaVolumebySeedlingMovementSimilarity{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.1), cMRSvolume(validNS), SeedlingMovementSimilarity(validNS), 'uni', false)));
            MaxDeltaVolume{animal}{fieldcount} = cellfun(@nanmax, cMRSvolume);
        else
            MRSDeltaVolumebyMaxCorr{animal}{fieldcount} = NaN;
        end

        %%% Delta Frequency 
        DeltaSpineFrequency{fieldcount} = FieldData{animal}{fieldcount}.CalciumData{end}.Frequency./FieldData{animal}{fieldcount}.CalciumData{1}.Frequency; 
        DeltaSpineFrequency{fieldcount}(DeltaSpineFrequency{fieldcount}==Inf) = nan;
        OtherSpinesDeltaFrequency{animal}{fieldcount} = DeltaSpineFrequency{fieldcount}(OtherSpines,:);
        MRSDeltaFrequency{animal}{fieldcount} = DeltaSpineFrequency{fieldcount}(MovementSpines,:);
        if ~isempty(SpineDynamics.ClusteredMovementSpineDeltaFrequency{fieldcount})
            cMRSfreq = SpineDynamics.ClusteredMovementSpineDeltaFrequency{fieldcount};
            cMRSDeltaFreqbyMaxCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSfreq(validNS), ClusterCorrelation(validNS)));
            cMRSDeltaFreqbyHighCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSfreq(validNS), ClusterCorrelation(validNS), 'uni', false)));
            cMRSDeltaFreqbyMaxNoiseCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSfreq(validNS), NoiseCorrelation(validNS)));
            cMRSDeltaFreqbyHighNoiseCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSfreq(validNS), NoiseCorrelation(validNS), 'uni', false)));
            MRSDeltaFreqbySeedlingMovementSimilarity{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.1), cMRSfreq(validNS), SeedlingMovementSimilarity(validNS), 'uni', false)));
            MaxDeltaFreq{animal}{fieldcount} = unique(cellfun(@nanmax, cMRSfreq));
        else
            MRSDeltaVolumebyMaxCorr{animal}{fieldcount} = NaN;
        end
        if ~isempty(AntiClusteredMovementSpines)
            aMRSDeltaFreq{animal}{fieldcount} = DeltaSpineFrequency{fieldcount}(AntiClusteredMovementSpines,:);
        else
            aMRSDeltaFreq{animal}{fieldcount} = NaN;
        end

        %%% Delta Amplitude
        DeltaSpineAmp{fieldcount} = FieldData{animal}{fieldcount}.CalciumData{end}.MeanEventAmp./FieldData{animal}{fieldcount}.CalciumData{1}.MeanEventAmp; 
        DeltaSpineAmp{fieldcount}(DeltaSpineAmp{fieldcount}==Inf) = nan;
        OtherSpinesDeltaAmp{animal}{fieldcount} = DeltaSpineAmp{fieldcount}(OtherSpines,:);
        MRSDeltaAmp{animal}{fieldcount} = DeltaSpineAmp{fieldcount}(MovementSpines,:);
        if ~isempty(SpineDynamics.ClusteredMovementSpineDeltaFrequency{fieldcount})
            cMRSamp = SpineDynamics.ClusteredMovementSpineDeltaAmplitude{fieldcount};
            cMRSDeltaAmpbyMaxCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSamp(validNS), ClusterCorrelation(validNS)));
            cMRSDeltaAmpbyHighCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSamp(validNS), ClusterCorrelation(validNS), 'uni', false)));
            cMRSDeltaAmpbyMaxNoiseCorr{animal}{fieldcount} = unique(cellfun(@(x,y) x(y==nanmax(y)), cMRSamp(validNS), NoiseCorrelation(validNS)));
            cMRSDeltaAmpbyHighNoiseCorr{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.05), cMRSamp(validNS), NoiseCorrelation(validNS), 'uni', false)));
            MRSDeltaAmpbySeedlingMovementSimilarity{animal}{fieldcount} = unique(cell2mat(cellfun(@(x,y) x(y>0.1), cMRSamp(validNS), SeedlingMovementSimilarity(validNS), 'uni', false)));
            MaxDeltaAmp{animal}{fieldcount} = unique(cellfun(@nanmax, cMRSamp));
        else
            MRSDeltaVolumebyMaxCorr{animal}{fieldcount} = NaN;
        end
        if ~isempty(AntiClusteredMovementSpines)
            aMRSDeltaAmp{animal}{fieldcount} = DeltaSpineAmp{fieldcount}(AntiClusteredMovementSpines,:);
        else
            aMRSDeltaAmp{animal}{fieldcount} = NaN;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%% Plasticity score by dendrite %%%%%%%%%%%%%%%%%%%
        
        DGrouping = FieldData{animal}{fieldcount}.CalciumData{1}.SpineDendriteGrouping;
        NumberofDendrites = length(DGrouping);
        for d = 1:NumberofDendrites
            DendriteData(overalldendritecount,1:9) = FieldData{animal}{fieldcount}.Correlations{1}.DendSubtractedSpineCorrelations(1:9, Spine1Address+NumberofSpines+(d-1)); %%% Dendrite behavioral feature correlation FROM EARLY SESSIONS
            DendriteData(overalldendritecount,10:18) = FieldData{animal}{fieldcount}.Correlations{end}.DendSubtractedSpineCorrelations(1:9, Spine1Address+NumberofSpines+(d-1)); %%% Dendrite behavioral feature correlation FROM LATE SESSIONS
            DendriteData(overalldendritecount,19) = sum(ismember(NewSpines, DGrouping{d}))/length(DGrouping{d}); %%% Number of spine additions (normalized by total spine number on dendrite)
            DendriteData(overalldendritecount,20) = sum(ismember(ElimSpines, DGrouping{d}))/length(DGrouping{d}); %%% Number of spine eliminations (normalized by total spine number on dendrite)
            DendriteData(overalldendritecount,21) = sum(nanmedian(DeltaSpineVolume{fieldcount}(DGrouping{d},2:end),2)>=1)/length(DGrouping{d}); %%% Number of spines showing stable or increased volume (normalized by total spine number on dend)
            DendriteData(overalldendritecount,22) = sum(nanmedian(DeltaSpineVolume{fieldcount}(DGrouping{d},2:end),2)<1)/length(DGrouping{d}); %%% Number of spines showing decreased volume (normalized by total spine number on dend)
            DendriteData(overalldendritecount,23) = sum(ismember(DSMovementSpines, DGrouping{d}))/length(DGrouping{d});  %%% Fraction of spines that are movement-related
            DendriteData(overalldendritecount,24) = sum(ismember(ClusteredEarlyMovementSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines from early sessions
            DendriteData(overalldendritecount,25) = sum(ismember(ClusteredLateMovementSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines from late sessions
            DendriteData(overalldendritecount,26) = sum(ismember(union(ClusteredEarlyMovementSpines,ClusteredLateMovementSpines), DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered movement-related spines at any session
            DendriteData(overalldendritecount,27) = sum(ismember(ClusteredNewSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are clustered new spines
            DendriteData(overalldendritecount,28) = sum(ismember(AntiClusteredElimSpines, DGrouping{d}))/length(DGrouping{d}); %%% Fraction of spines that are anti-clustered eliminated spines
            DendriteData(overalldendritecount,29) = animal;
            DendritesbyAnimal{animal} = [DendritesbyAnimal{animal}, overalldendritecount];
            overalldendritecount = overalldendritecount+1;
        end
        
    end
    disp(['Spine volume summary for ', varargin{animal}, ' complete'])
end
close(h1)

cd(OutputDataFolder)
save('DendriteSummaryData', 'DendriteData')

% AllMat = []; CSMat = []; MRSMat = [];MRSMatMid = []; DS_MRSMat = [];DS_MRSMatMid = []; cMRSMat = [];cMRSMatMid = []; aMRSMat = []; aMRSMatMid = []; OtherMat = []; OtherMatMid = [];
% for i = 1:length(FieldData)
%     for j = 1:length(FieldData{i})
%         if isfield(FieldData{i}{j}, 'SpineVolumeData')
%             AllMat = [AllMat; FieldData{i}{j}.SpineVolumeData(:,end)];
%             if ~isempty(CSDeltaVolume{i})
%                 if ~isempty(CSDeltaVolume{i}{j})
%                     CSMat = [CSMat; CSDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%             if ~isempty(MRSDeltaVolume{i})
%                 if ~isempty(MRSDeltaVolume{i}{j})
%                     if size(MRSDeltaVolume{i}{j},2)>2
%                         MRSMatMid = [MRSMatMid; MRSDeltaVolume{i}{j}(:,2)];
%                     end
%                     MRSMat = [MRSMat; MRSDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%             if ~isempty(DS_MRSDeltaVolume{i})
%                 if ~isempty(DS_MRSDeltaVolume{i}{j})
%                     if size(DS_MRSDeltaVolume{i}{j},2)>2
%                         DS_MRSMatMid = [DS_MRSMatMid; DS_MRSDeltaVolume{i}{j}(:,2)];
%                     end
%                     DS_MRSMat = [DS_MRSMat; DS_MRSDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%             if ~isempty(cMRSDeltaVolume{i})
%                 if ~isempty(cMRSDeltaVolume{i}{j})
%                     if size(cMRSDeltaVolume{i}{j},2)>2
%                         cMRSMatMid = [cMRSMatMid; cMRSDeltaVolume{i}{j}(:,2)];
%                     end
%                     cMRSMat = [cMRSMat; cMRSDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%             if ~isempty(aMRSDeltaVolume{i})
%                 if ~isempty(aMRSDeltaVolume{i}{j})
%                     if size(aMRSDeltaVolume{i}{j},2)>2
%                         aMRSMatMid = [aMRSMatMid; aMRSDeltaVolume{i}{j}(:,2)];
%                     end
%                     aMRSMat = [aMRSMat; aMRSDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%             if ~isempty(OtherSpinesDeltaVolume{i})
%                 if ~isempty(OtherSpinesDeltaVolume{i}{j})
%                     if size(OtherSpinesDeltaVolume{i}{j},2)>2
%                         OtherMatMid = [OtherMatMid; OtherSpinesDeltaVolume{i}{j}(:,2)];
%                     end
%                     OtherMat = [OtherMat; OtherSpinesDeltaVolume{i}{j}(:,end)];
%                 end
%             end
%         end
%     end
% end
% SelectedClusters = cell2mat(horzcat(MRSDeltaVolumebyMaxCorr{:}));
% SelectedClusters2 = cell2mat(horzcat(MRSDeltaVolumebyHighCorr{:}));
% SelectedClusters3 = cell2mat(horzcat(MRSDeltaVolumebyMaxNoiseCorr{:}));
% SelectedClusters4 = cell2mat(horzcat(MRSDeltaVolumebyHighNoiseCorr{:}));
% SelectedClusters5 = cell2mat(horzcat(MaxDeltaVolume{:}));
% 
% OtherMat(OtherMat<=0) = NaN;    %OtherMat(isoutlier(OtherMat))= NaN;
% OtherMatMid(OtherMatMid<=0)=NaN; %OtherMatMid(isoutlier(OtherMatMid)) = NaN;
% CSMat(CSMat<=0) = NaN;
% MRSMat(MRSMat<=0) = NaN;
% % MRSMatMid(MRSMatMid<=0) = NaN;
% DS_MRSMat(DS_MRSMat<=0) = NaN;  %MRSMat(isoutlier(MRSMat)) = NaN;
% DS_MRSMatMid(DS_MRSMatMid<=0) = NaN; %MRSMatMid(isoutlier(MRSMatMid)) = NaN;
% cMRSMat(cMRSMat<=0) = NaN;  %cMRSMat(isoutlier(cMRSMat)) = NaN;
% cMRSMatMid(cMRSMatMid<=0) = NaN; %cMRSMatMid(isoutlier(cMRSMatMid)) = 0;
% aMRSMat(aMRSMat<=0) = NaN;% aMRSMat(isoutlier(aMRSMat)) = NaN;
% aMRSMatMid(aMRSMatMid<=0) = NaN; %aMRSMatMid(isoutlier(aMRSMatMid)) = NaN;
% 
% % figure; plot(linspace(0.75,1.25, length(DS_MRSMat)), DS_MRSMat', '.', 'Markersize', 14)
% % hold on; plot(linspace(1.75, 2.25, length(OtherMat)), OtherMat', '.', 'Markersize', 14)
% % plot(linspace(2.75,3.25,length(cMRSMat)), cMRSMat', '.', 'Markersize', 14)
% % plot(linspace(3.75,4.25,length(aMRSMat)), aMRSMat', '.', 'Markersize', 14)
% datamat = [{OtherMat},{MRSMat}, {cMRSMat}, {SelectedClusters},{SelectedClusters2},{SelectedClusters3}, {SelectedClusters4}, {SelectedClusters5}, {aMRSMat}];
% figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
% bootstrpnum = 1000;
% alphaforbootstrap = 0.05;
% for i = 1:length(datamat)
%     Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
%     line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
% end
% set(gca, 'XTickLabel', {'All Other Spines','Movement Spines', 'Putative cMRS', 'cMRS with Max Corr', 'cMRS with High Corr', 'cMRS max Noise Corr', 'cMRS high Noise Corr', 'max \DeltaV', 'anti-Clustered MRS'})
% ylabel('\Delta Spine Volume (Late/Early)')
% xtickangle(gca, 45)

%==========================================================================
%% Delta Volume by animal
temp = OtherSpinesDeltaVolume(~cellfun(@isempty, OtherSpinesDeltaVolume));
OtherSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    OtherSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:,end), currentdata, 'uni', false)');
end
temp = MRSDeltaVolume(~cellfun(@isempty, MRSDeltaVolume));
for i = 1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    MRSbyAnimal{i} = cell2mat(cellfun(@(x) x(:,end), currentdata, 'uni', false)');
end
temp = MRSDeltaVolumebyHighCorr(~cellfun(@isempty, MRSDeltaVolumebyHighCorr));
for i = 1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    MRSDeltaVolumebyMaxCorrbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end
temp = MRSDeltaVolumebyHighNoiseCorr(~cellfun(@isempty, MRSDeltaVolumebyHighNoiseCorr));
for i = 1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    MRSDeltaVolumebyMaxNoiseCorrbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end
temp = aMRSDeltaVolume(~cellfun(@isempty, aMRSDeltaVolume));
for i = 1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    aMRSDeltaVolumebyAnimal{i} = cell2mat(cellfun(@(x) x(:,end), currentdata, 'uni', false)');
end
datamat = [{cellfun(@nanmedian, OtherSpinesbyAnimal)},{cellfun(@nanmedian, MRSbyAnimal)},{cellfun(@nanmedian, MRSDeltaVolumebyMaxCorrbyAnimal)}, {cellfun(@nanmedian, MRSDeltaVolumebyMaxNoiseCorrbyAnimal)}, {cellfun(@nanmedian, aMRSDeltaVolumebyAnimal)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@nanmedian, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','Movement Spines', 'cMRS by Corr', 'cMRS by Noise Corr', 'aMRS'})
ylabel('\Delta Spine Volume (Late/Early)')
xtickangle(gca, 45)

%==========================================================================
%% Delta Volume by field
temp = horzcat(OtherSpinesDeltaVolume{:});
OtherSpinesbyField = temp(~cellfun(@isempty, temp));
OtherSpinesbyField = cellfun(@(x) x(:,end), OtherSpinesbyField, 'uni', false);

temp = horzcat(MRSDeltaVolume{:});
MRSbyField = temp(~cellfun(@isempty, temp));
MRSbyField = cellfun(@(x) x(:,end), MRSbyField, 'uni', false);

temp = horzcat(cMRSDeltaVolume{:});
cMRSbyField = temp(~cellfun(@isempty, temp));
cMRSbyField = cellfun(@cell2mat, cMRSbyField, 'uni', false);

temp = horzcat(MRSDeltaVolumebySeedlingMovementSimilarity{:});
MRSDeltaVolumebyMaxCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(MRSDeltaVolumebyHighNoiseCorr{:});
MRSDeltaVolumebyMaxNoiseCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(aMRSDeltaVolume{:});
aMRSDeltaVolumebyField = temp(~cellfun(@isempty, temp));
aMRSDeltaVolumebyField = cellfun(@(x) x(:,end), aMRSDeltaVolumebyField, 'uni', false);

datamat = [{cellfun(@nanmedian, OtherSpinesbyField)},{cellfun(@nanmedian, MRSbyField)},{cellfun(@nanmedian, cMRSbyField)},{cellfun(@nanmedian, MRSDeltaVolumebyMaxCorrbyField)}, {cellfun(@nanmedian, MRSDeltaVolumebyMaxNoiseCorrbyField)}, {cellfun(@nanmedian, aMRSDeltaVolumebyField)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','r')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','Movement Spines', 'cMRS', 'cMRS by Corr', 'cMRS by Noise Corr', 'aMRS'})
ylabel('\Delta Spine Volume (Late/Early)')
xtickangle(gca, 45)

%==========================================================================
%% Delta Frequency by animal
temp = OtherSpinesDeltaFrequency(~cellfun(@isempty, OtherSpinesDeltaFrequency));
OtherSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    OtherSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = MRSDeltaFrequency(~cellfun(@isempty, MRSDeltaFrequency));
MRSsbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    MRSsbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = cMRSDeltaFreqbyHighCorr(~cellfun(@isempty, cMRSDeltaFreqbyHighCorr));
ClustSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    ClustSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = cMRSDeltaFreqbyHighNoiseCorr(~cellfun(@isempty, cMRSDeltaFreqbyHighNoiseCorr));
ClustSpinesNoiseCorrbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    ClustSpinesNoiseCorrbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = aMRSDeltaFreq(~cellfun(@isempty, aMRSDeltaFreq));
antiClustSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    antiClustSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

datamat = [{cellfun(@nanmedian, OtherSpinesbyAnimal)},{cellfun(@nanmedian, MRSsbyAnimal)},{cellfun(@nanmedian, ClustSpinesbyAnimal)},{cellfun(@nanmedian, ClustSpinesNoiseCorrbyAnimal)},{cellfun(@nanmedian, antiClustSpinesbyAnimal)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','All MRSs', 'cMRS by Corr', 'cMRS by Noise Corr', 'aMRS'})
ylabel('\Delta Frequency (Late/Early)')
xtickangle(gca, 45)

%==========================================================================
%% Delta Frequency by field
temp = horzcat(OtherSpinesDeltaFrequency{:});
OtherSpinesbyField = temp(~cellfun(@isempty, temp));
OtherSpinesbyField = cellfun(@(x) x(:,end), OtherSpinesbyField, 'uni', false);

temp = horzcat(MRSDeltaFrequency{:});
MRSbyField = temp(~cellfun(@isempty, temp));
MRSbyField = cellfun(@(x) x(:,end), MRSbyField, 'uni', false);

temp = horzcat(cMRSDeltaFreqbyHighCorr{:});
MRSDeltaVolumebyMaxCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(cMRSDeltaFreqbyHighNoiseCorr{:});
MRSDeltaVolumebyMaxNoiseCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(aMRSDeltaFreq{:});
aMRSDeltaVolumebyField = temp(~cellfun(@isempty, temp));
aMRSDeltaVolumebyField = cellfun(@(x) x(:,end), aMRSDeltaVolumebyField, 'uni', false);

datamat = [{cellfun(@nanmedian, OtherSpinesbyField)},{cellfun(@nanmedian, MRSbyField)},{cellfun(@nanmedian, MRSDeltaVolumebyMaxCorrbyField)}, {cellfun(@nanmedian, MRSDeltaVolumebyMaxNoiseCorrbyField)}, {cellfun(@nanmedian, aMRSDeltaVolumebyField)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','r')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','Movement Spines', 'cMRS with Max Corr', 'cMRS max Noise Corr', 'aMRS'})
ylabel('\Delta Frequency (Late/Early)')
xtickangle(gca, 45)

%==========================================================================
%% Delta Amplitude
temp = OtherSpinesDeltaAmp(~cellfun(@isempty, OtherSpinesDeltaAmp));
OtherSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    OtherSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = MRSDeltaAmp(~cellfun(@isempty, MRSDeltaAmp));
MRSsbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    MRSsbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = cMRSDeltaAmpbyHighCorr(~cellfun(@isempty, cMRSDeltaAmpbyHighCorr));
ClustSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    ClustSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = cMRSDeltaAmpbyHighNoiseCorr(~cellfun(@isempty, cMRSDeltaAmpbyHighNoiseCorr));
ClustSpinesNoiseCorrbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    ClustSpinesNoiseCorrbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

temp = aMRSDeltaAmp(~cellfun(@isempty, aMRSDeltaAmp));
antiClustSpinesbyAnimal = [];
for i =1:length(temp)
    currentdata = temp{i}(~cellfun(@isempty, temp{i}));
    antiClustSpinesbyAnimal{i} = cell2mat(cellfun(@(x) x(:), currentdata, 'uni', false)');
end

datamat = [{cellfun(@nanmedian, OtherSpinesbyAnimal)},{cellfun(@nanmedian, MRSsbyAnimal)},{cellfun(@nanmedian, ClustSpinesbyAnimal)},{cellfun(@nanmedian, ClustSpinesNoiseCorrbyAnimal)},{cellfun(@nanmedian, antiClustSpinesbyAnimal)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','All MRSs', 'cMRS', 'cMRS by Max Noise Corr', 'aMRS'})
ylabel('\Delta Amplitude (Late/Early)')
xtickangle(gca, 45)
%==========================================================================
%% Delta Amp by field
temp = horzcat(OtherSpinesDeltaAmp{:});
OtherSpinesbyField = temp(~cellfun(@isempty, temp));
OtherSpinesbyField = cellfun(@(x) x(:,end), OtherSpinesbyField, 'uni', false);

temp = horzcat(MRSDeltaAmp{:});
MRSbyField = temp(~cellfun(@isempty, temp));
MRSbyField = cellfun(@(x) x(:,end), MRSbyField, 'uni', false);

temp = horzcat(cMRSDeltaAmpbyHighCorr{:});
MRSDeltaVolumebyMaxCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(cMRSDeltaAmpbyHighNoiseCorr{:});
MRSDeltaVolumebyMaxNoiseCorrbyField = temp(~cellfun(@isempty, temp));

temp = horzcat(aMRSDeltaAmp{:});
aMRSDeltaVolumebyField = temp(~cellfun(@isempty, temp));
aMRSDeltaVolumebyField = cellfun(@(x) x(:,end), aMRSDeltaVolumebyField, 'uni', false);

datamat = [{cellfun(@nanmedian, OtherSpinesbyField)},{cellfun(@nanmedian, MRSbyField)},{cellfun(@nanmedian, MRSDeltaVolumebyMaxCorrbyField)}, {cellfun(@nanmedian, MRSDeltaVolumebyMaxNoiseCorrbyField)}, {cellfun(@nanmedian, aMRSDeltaVolumebyField)}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','r')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTickLabel', {'All Other Spines','Movement Spines', 'cMRS with Max Corr', 'cMRS max Noise Corr', 'aMRS'})
ylabel('\Delta Amp (Late/Early)')
xtickangle(gca, 45)

%==========================================================================

ranksum(DS_MRSMat, OtherMat);

datamat = [{OtherMatMid},{MRSMatMid},{DS_MRSMatMid}, {cMRSMatMid}, {aMRSMatMid}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor','k')
bootstrpnum = 1000;
alphaforbootstrap = 0.05;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
