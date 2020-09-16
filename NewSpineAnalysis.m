function NewSpineAnalysis(varargin)

global gui_KomiyamaLabHub

sensor = varargin(end);

for animal = 1:length(varargin)-1
    
    experimentnames = varargin{animal}; 
    
    %================================
    %   Settings
    ConsiderOnlyMovementPeriods = 0;
    FilterforMovementDends = 0;
    FilterforPersistentMRSs = 0;
    use_dFoF_not_binarized = 0;
    lower_thresh_for_coact = 0;
    filterclusters = 0;
    useMaxMoveLengthcutoff = 1;
    discardJustaposedMovements = 0;
    cutoff_of_highcorr_cluster = 0.05;
    volumeincreasecutoff = 1.25;
    
    if strcmpi(sensor, 'GCaMP')
    	ImagingFrequency = 30.03;
        clusterdistance = 1500;
        mindFoFtoconsiderCoActive = 0.2;
    elseif strcmpi(sensor, 'GluSNFR')
    	ImagingFrequency = 58.30;
        clusterdistance = 1500;
        mindFoFtoconsiderCoActive = 0.2;
    end
       
    %=================================

    %%%%%%%%%%%% Load Spine Dynamics Registry for a given animal
    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd(['C:\Users\Komiyama\Desktop\Output Data', filesep, experimentnames, ' New Spine Analysis'])
    end
    fieldsource = fastdir(cd, 'Field');
    [~, ind] = sort(cellfun(@(x) regexp(x, '[0-9]{1}', 'match'),fieldsource));
    filecount = 1;
    FieldData = [];
    for f = 1:length(fieldsource)
        sortedfield = ind(f);
        load(fieldsource{sortedfield})
        fieldnumber = regexp(fieldsource{f}, '[0-9]{1}', 'match');
        eval(['FieldData{', num2str(sortedfield), '} = SpineRegistry;']);
        clear SpineRegistry
        filecount = filecount+1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NumFields = length(FieldData);
    FieldChanges = cell(1,NumFields);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for f = 1:NumFields
        FieldChanges{f} = diff(FieldData{f}.Data,1,2);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Load calcium imaging data for the animal %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd(gui_KomiyamaLabHub.DefaultActivityFolder)
    end
    activitydata = fastdir(cd, [experimentnames, '.+_Summary']);
    for f = 1:length(activitydata)
        load(activitydata{f})
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Match the loaded data with the session numbers from the spine
    %%%%%%%%%% registry data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    wrkspc = whos;
    for f = 1:NumFields
        FieldData{f}.DatesAcquired = sortrows(FieldData{f}.DatesAcquired);
        for j = 1:length(FieldData{f}.DatesAcquired)
            locate =(regexp(who, FieldData{f}.DatesAcquired{j}));
            if any(~cellfun(@isempty, locate))
                FieldData{f}.CalciumData{j} = eval(wrkspc(~cell2mat(cellfun(@isempty, locate, 'uni',false))).name);
            else
                FieldData{f}.CalciumData{j} = [];
            end
        end
        FieldData{f}.CalciumData = FieldData{f}.CalciumData(~cellfun(@isempty, FieldData{f}.CalciumData));
        sessionstouse{f} = find(~cellfun(@isempty, FieldData{f}.CalciumData));
    end

    for f = 1:length(activitydata)
        clear(activitydata{f}(1:end-4))
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Separate the spine dynamics arrays into dendrites
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    DendriteDynamics = cell(1,NumFields);
    for f = 1:NumFields
        DendriteDynamics{f} = cellfun(@(x) FieldChanges{f}(x),FieldData{f}.CalciumData{1}.SpineDendriteGrouping,'uni', false);  %%% Calculate the CHANGE in spines (-1 is a lost spine, +1 is a new spine) between sessions for each dendrite
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% Load Statistical classification data %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd(gui_KomiyamaLabHub.DefaultOutputFolder)
    end

    statdata = fastdir(cd, [experimentnames, '_StatClassified']);
    if ~isempty(statdata)
        load(statdata{1});
    else
        disp(['Cannot load stat data for animal ', experimentnames]);
    end

    eval(['statclass = ', experimentnames, '_StatClassified;'])

    for f = 1:NumFields
        for s = sessionstouse{f}
            if ~isempty(FieldData{f}.CalciumData{s})
                FieldData{f}.StatClass{s} = statclass{FieldData{f}.CalciumData{s}.Session};
            else
                FieldData{f}.DatesAcquired = FieldData{f}.DatesAcquired(1:s-1);
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% Load Spine Volume Data %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    voldatadir = [gui_KomiyamaLabHub.DefaultOutputFolder, filesep, experimentnames, ' Spine Volume Data'];
    
    for f = 1:NumFields
        currentdates = sortrows(FieldData{f}.DatesAcquired);
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
                    eval(['FieldData{f}.SpineVolumeData(:,session) = ', dataname, '.DendriteNormalizedIntegratedSpineIntensity;'])
                    clear(dataname)
                    found = found+1;
                end
            end
        end
        if found~=length(currentdates)
            breakfield = 1;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Load Behavioral Summary Data %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
%         cd(gui_KomiyamaLabHub.DefaultOutputFolder)
        cd('C:\Users\Komiyama\Desktop\Output Data\')
    end

    behdata = fastdir(cd, [experimentnames, '_SummarizedBehavior']);
    if ~isempty(behdata)
        load(behdata{1});
    else
        disp(['Cannot load behavior data for animal ', experimentnames, '!']);
    end

    eval(['fullbehaviordata = ', experimentnames, '_SummarizedBehavior;'])
    latestagesessions = fullbehaviordata.UsedSessions(fullbehaviordata.UsedSessions>=11);
    
    %%% set up how to determine which sessions to use to be considered as
    %%% the "model" or "expert" movement; this might be criteria based on
    %%% number of rewards, movement stereotypy (either within or across
    %%% sessions), etc.
    
    rewards = fullbehaviordata.rewards(fullbehaviordata.UsedSessions);
    latestagehighperformancesessions = ismember(latestagesessions,find(rewards>75));
    if any(latestagehighperformancesessions)
        latestagesessions = latestagesessions(latestagehighperformancesessions);
    else
        disp([experimentnames, ' showed low performance in late sessions; consider this when evaluating learning'])
        latestagesessions = fullbehaviordata.UsedSessions(11:14);
    end

    withinsessions_stereotypy = diag(fullbehaviordata.MovementCorrelation);
        withinsessions_stereotypy = withinsessions_stereotypy(fullbehaviordata.UsedSessions);
    acrosssessions_stereotypy = diag(fullbehaviordata.MovementCorrelation,1);
        acrosssessions_stereotypy = acrosssessions_stereotypy(fullbehaviordata.UsedSessions(2:end)-1);
        
%     [~, most_stereotyped_session] = max(withinsessions_stereotypy(8:end).*acrosssessions_stereotypy(7:end));
%     most_stereotyped_session = most_stereotyped_session+7;
%     
%     session_scoring = (rewards./100).*withinsessions_stereotypy'.*[1;acrosssessions_stereotypy]'.*(1./fullbehaviordata.ReactionTime(fullbehaviordata.UsedSessions)).*(1./fullbehaviordata.CuetoReward(fullbehaviordata.UsedSessions));
%     [~, highest_scoring_session] = max(session_scoring);
    
%     targetbehavioralsessions = highest_scoring_session;
%     targetbehavioralsessions = most_stereotyped_session;
    targetbehavioralsessions = latestagesessions;
    
    RawModelMovement = nanmean(cell2mat(cellfun(@nanmean, fullbehaviordata.MovementMat(targetbehavioralsessions), 'uni', false)'),1);
   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Model Movement alignment depends on what you used for the behavior
    %%% analysis/learning curve; currently, the time window is:
    %%% 0.5 second before movement start,
    %%% 2.5 seconds after movement start
    %%% These are the MAX values that you can use!
    
    targetsecondspremovement = 0.5;
    targetsecondspostmovementstart = 2.5;
    TimingValues.SecondsPreMovement = targetsecondspremovement; 
    TimingValues.SecondsPostMovement = targetsecondspostmovementstart;

    learningcurve_pre = targetsecondspremovement*1000;
    zeropoint = learningcurve_pre;
        
    targetwindow = round(ImagingFrequency*(targetsecondspremovement+targetsecondspostmovementstart))+1; %%% The time window for the model movement is set at 3 seconds, thus the resampling should be set to this window, irrespective of the time window considered for movements here. 
    ModelMovement = RawModelMovement(zeropoint-(targetsecondspremovement*1000)+1:zeropoint+(targetsecondspostmovementstart*1000));   %%% 400ms is the window that we move back from the initiation of a rewarded press; use a maximum of three total seconds of movement (i.e. 2.6s post movement start) unless you change the Model Movement calculation using NHanalySummarizeBehavior
    [n, d] = rat(targetwindow/length(ModelMovement));
    shiftvalue = nanmedian(ModelMovement(1:(targetsecondspremovement*1000))); %%% Centering the movement around zero reduces edge artifacts of resampling
    modmov_shifted = ModelMovement-shiftvalue;    
    ModelMovement = resample(modmov_shifted,n,d)+shiftvalue;

    targetlength = length(ModelMovement);
    TimingValues.TargetLength = targetlength;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Load Correlation data  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
    corrdata = fastdir(cd, [experimentnames, '_Correlations']);
    if ~isempty(corrdata)
        load(corrdata{1})
    else
        disp(['Cannot load correlation data for animal ', experimentnames])
    end

    eval(['correlations = ', experimentnames, '_Correlations;'])

    for f = 1:NumFields
        for s = sessionstouse{f}
            if ~isempty(FieldData{f}.CalciumData{s})
                FieldData{f}.Correlations{s} = correlations{FieldData{f}.CalciumData{s}.Session};
            else
                FieldData{f}.Correlations{s} = [];
            end
        end
    end
    currentanimal = varargin{animal};
    load([currentanimal, '_Aligned'])
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Determine data type to use %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    if get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'Value')
        AnalysisType = 'Exclude';
    elseif get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'Value')
        AnalysisType = 'Subtract';
    else
        AnalysisType = 'Ignore';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %======================================================================    
    %% New spine analysis section
    %======================================================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initiatilize variables to be used
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Numbers and Labels of Spine Types
    NewSpines = cell(1,NumFields); NewSpinesbyDendrite = cell(1,NumFields);
    ElimSpines = cell(1,NumFields); ElimSpinesbyDendrite = cell(1,NumFields);
    MiddleSessionNewSpines = cell(1,NumFields);
    LateSessionNewSpines = cell(1,NumFields);
    persistentNewSpines = cell(1,NumFields);
    transientNewSpines = cell(1,NumFields);
    ClusteredNewSpines = cell(1,NumFields); ClusteredNewSpinesbyDendrite = cell(1,NumFields);
    ClusteredEarlyMoveSpines = cell(1,NumFields);
    ClusteredLateMoveSpines = cell(1,NumFields);
    ClusteredMoveSpinesbyNewSpine = cell(1,NumFields);
    AntiClusteredElimSpines = cell(1,NumFields); AntiClusteredElimSpinesbyDendrite = cell(1,NumFields);
    AntiClusteredEarlyMoveSpines = cell(1,NumFields); 
    NumberofEarlyMovementRelatedSpines = 0;
    NumberofMidSessionMovementRelatedSpines = 0;
    NumberofLateMovementRelatedSpines = 0;
    NumberofEarlierSessionMovementRelatedSpines = 0; %%% This includes both early- and mid-session MRSs, which is useful for many metrics considering what spines were doing at any time prior to the final session
    NumberofPersistentMovementRelatedSpines = cell(1,NumFields);
    NumberofPersistentMovementSpinesClustered = cell(1,NumFields);
    FractionofMovementRelatedSpinesMaintained = cell(1,NumFields);
    FractionofMovementRelatedSpinesEliminated = cell(1,NumFields);
    NumberofNewSpines = 0;
    NumberofElimSpines = 0;
    NumberofNewSpinesThatAreMR = 0;                     %%% Movement-related
    NumberofNewSpinesThatArePreSR = 0;                  %%% Pre-success-related
    NumberofNewSpinesThatAreSR = 0;                     %%% Successful-press-related
    NumberofNewSpinesThatAreRR = 0;                     %%% Reward-related
    NumberofElimSpinesThatWereMR = 0;
    NewSpineswithNoMoveSpinePartner = 0;
    NumberofClusteredMoveSpines = cell(1,NumFields);
    NumberofMovementClusteredNewSpines = 0;             %%% New spines that form near movement-related spines
    NumberofMovementClusteredNewSpinesThatAreMR = 0;    %%% New spines that form near movement-related spines AND are themselves movement-related
    persistentclustercount = 0;
    
    %%% Correlation stuff
    AllSpineCorrelationsonLateSession = cell(1,NumFields);
    AllSpineNoiseCorrelationsonLateSession = cell(1,NumFields);
    NewSpinesMaxCorr = cell(1,NumFields);
    DistanceToMaxCorrPartner = cell(1,NumFields);
    FractionofHCPsThatAreMR = cell(1,NumFields);
    ElimSpinesMaxCorr = cell(1,NumFields);
    TaskCorrelationofClusteredNewSpines = cell(1,NumFields);
    TaskCorrelationofNearbyEarlyMRSs = cell(1,NumFields);
    TaskCorrelationofNearbyLateMRSs = cell(1,NumFields);
    TaskCorrelationofNearbyEarlyMRSsforElimSp = cell(1,NumFields);
    MovementReliabilityofNearbyEarlyMRSs = cell(1,NumFields);
    MovementReliabilityofNearbyLateMRSs = cell(1,NumFields);
    MovementReliabilityofOtherMoveSpines = cell(1,NumFields);
    
    MovementReliabilityofNearbyEarlyMRSsforElimSp = cell(1,NumFields);
    NewSpineMaxCorrPartnerEarlyMoveCorrelation = cell(1,NumFields);
    NewSpineMaxCorrPartnerEarlyMoveReliability = cell(1,NumFields);
    NewSpineMaxCorrPartnerLateMoveCorrelation = cell(1,NumFields);
    NewSpineMaxCorrPartnerLateMoveReliability = cell(1,NumFields);
    ElimSpineMaxCorrPartnerEarlyMoveCorrelation = cell(1,NumFields);
    ElimSpineMaxCorrPartnerEarlyMoveReliability = cell(1,NumFields);
    OtherSpinesMaxCorr = cell(1,NumFields);
    NewSpinesBehaviorCorrelation = cell(1,NumFields);
    ElimSpinesBehaviorCorrelation = cell(1,NumFields);
    NonNewSpinesBehaviorCorrelationEarly = cell(1,NumFields);
    NonNewSpinesBehaviorCorrelationLate = cell(1,NumFields);
    AllDendriteDistances = cell(1,NumFields);
    
    AllCueSpines = cell(1,NumFields);
    AllMovementDuringCueSpines = cell(1,NumFields);
    AllMovementSpines = cell(1,NumFields);
    AllMovementRanks = cell(1,NumFields);
    AllRewMovementSpines = cell(1,NumFields);
    AllRewardSpines = cell(1,NumFields);
    
    AllSpineFrequency = cell(1,NumFields);
    AllSpineVolumeData = cell(1,NumFields);
    AllDeltaSpineVolume = cell(1,NumFields);
    ClusteredMovementSpineVolume = cell(1,NumFields);
    SimClusterCorr = cell(1,NumFields);
    ClusteredMovementSpineDeltaFrequency = cell(1,NumFields);
    ClusteredMovementSpineDeltaAmplitude = cell(1,NumFields);
    DistancesBetweenNewSpinesandNearestEarlyMovementSpines = cell(1,NumFields);
    NewSpineAllSpinesDistance = cell(1,NumFields);
    AllTransientNewSpinesDistance = cell(1,NumFields);
    NewSpineAllSpinesMidCorr = cell(1,NumFields);
    NewSpineAllSpinesLateCorr = cell(1,NumFields);
    NewSpineAllSpinesLateRawCorr = cell(1,NumFields);
    NewSpineAllSpinesLateNoiseCorr = cell(1,NumFields);
    AllSpinesEarlyCoActiveRates = cell(1,NumFields);
    AllSpinesEarlyCoActiveRatesGeoNormalized = cell(1,NumFields);
    AllSpinesLateCoActiveRates = cell(1,NumFields);
    AllSpinesLateCoActiveRatesGeoNormalized = cell(1,NumFields);
    AllInterSpineDistancesList = cell(1,NumFields);
    NewSpineAllCoActiveRates = cell(1,NumFields);
    NewSpineAllCoActiveRatesNormalized = cell(1,NumFields);
    NewSpineAllCoActiveRatesGeoNormalized = cell(1,NumFields);
    AllTransientNewSpinesMidCorr = cell(1,NumFields);
    TransientSpineCoActiveRate = cell(1,NumFields);
    TransientSpineCoActiveRateNormalized = cell(1,NumFields);
    TransientSpineCoActiveRateGeoNormalized = cell(1,NumFields);
    TransientNewSpinesFrequency = cell(1,NumFields);
    NewSpineMidFrequency = cell(1,NumFields);
    NewSpineMidCoActiveRate = cell(1,NumFields);
    NewSpineMidCoActiveRateNormalized = cell(1,NumFields);
    NewSpineMidCoActiveRateGeoNormalized = cell(1,NumFields);
    NewSpineAllDistancestoEarlyMovementSpines = cell(1,NumFields);
    LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions = cell(1,NumFields);
    LateCorrofNewSpinesandNearestMovementSpinefromLateSessions = cell(1,NumFields);
    AllClusterCorrelationsbyNewSpine = cell(1,NumFields);
    HighCorrClusters = cell(1,NumFields);
    VolIncreaseClusters = cell(1,NumFields);
    DistancetoHighCorrMovementSpines = cell(1,NumFields);
    DistancetoEnlargedSpines = cell(1,NumFields);
    AllMoveCentricClusterCorrelationsbyNewSpine = cell(1,NumFields);
    NewSpinesCorrwithNearbyEarlyMRSs = cell(1,NumFields);
    FractionofNewSpinesMeetingClusterCriteria = cell(1,NumFields);
    MovementSpineDistanceMatchedControlCorrelation = cell(1,NumFields);
    NewSpinesCorrwithNearbyLateMRSs = cell(1,NumFields);
    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs = cell(1,NumFields);
    FrequencyMatchedControlCorrelation = cell(1,NumFields);
    NewSpinesCorrwithDistanceMatchedNonLateMRSs = cell(1,NumFields);
    DistancesBetweenNewSpinesandLateMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandRandomSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandShuffledMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandEarlyMovementSpines = cell(1,NumFields);
    CorrelationsofElimSpinesandEarlyMovementSpines = cell(1,NumFields);
    ElimSpinesCorrwithNearbyMRSs = cell(1,NumFields);
    DistancesBetweenElimSpinesandMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandRandomSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandShuffledMovementSpines = cell(1,NumFields);
    MovementCorrelationwithCoActiveAntiClusters = cell(1,NumFields);
    CoActiveAntiClusterMovementsCorrelationwithModelMovement = cell(1,NumFields);
    MovementCorrelationofAllOtherMovementsElimVersion = cell(1,NumFields);
    AllOtherMovementsCorrelationwithModelMovementElimVersion = cell(1,NumFields);
    MovementCorrelationofFrequencyMatchedPairsElimVersion = cell(1,NumFields);
    FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion = cell(1,NumFields);
    ClusteredNewSpineCorrwithDendrite = cell(1,NumFields);
    ClusteredNewSpineCorrwithMovement = cell(1,NumFields);
    ClusteredNewSpineCorrwithSuccess = cell(1,NumFields);
    ClusteredMoveSpineCorrwithDendrite = cell(1,NumFields);
    ClusteredMoveSpineCorrwithMovement = cell(1,NumFields);
    ClusteredMoveSpineCorrwithSuccess = cell(1,NumFields);
    ClusterCoActiveTraces = cell(1,NumFields);
    CoActiveClusterCorrwithDendrite = cell(1,NumFields);
    CoActiveClusterCorrwithMovement = cell(1,NumFields);
    CoActiveClusterCorrwithSuccess = cell(1,NumFields);
    
    %%% Noise Correlation stuff
    MoveCentricFrequencyMatchedCorrelation = cell(1,NumFields);
    MoveCentricDistanceMatchedCorrelation = cell(1,NumFields);
    MoveCentricDistanceMatchedCorrelationforMRS = cell(1,NumFields);
    MoveCentricCorrelationofAllOtherSpines = cell(1,NumFields);
    MoveCentricClusterCorrelation = cell(1,NumFields);
    MoveCentricAntiClusterCorrelation = cell(1,NumFields);
    MoveCentricDistanceMatchedtoAntiClustCorrelation = cell(1,NumFields);
    FailureCentricClusterCorrelation = cell(1,NumFields);
    CombinedClusterActivityCorrwithMovement = cell(1,NumFields);
    CombinedClusterActivityCorrwithSuccess = cell(1,NumFields);
    ClusterMovementReliability = cell(1,NumFields);
    ClusterSuccessReliability = cell(1,NumFields);
    ControlPairMovementReliability = cell(1,NumFields);
    ControlPairSuccessReliability = cell(1,NumFields);
    SessionsbyField = cell(1,NumFields);
    SpineDendriteGrouping = cell(1,NumFields);
    
    %%% Movement stereotypy stuff
    MovementsEncodedbySeedlingMRS = cell(1,NumFields);
    MovementswithClusteredCoActivity = cell(1,NumFields);
    MovementswithClusteredCoActivitybyCluster = cell(1,NumFields);
    CorrelationofMovementswithCoActiveClusterActivity = cell(1,NumFields);
    CorrelationofMovementswithCoActiveClusterActivitybyCluster = cell(1,NumFields);
    CoActiveClusterMovementsCorrelationwithModelMovement = cell(1,NumFields);
    CoActiveClusterMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    SimilarityofClusteredMovementwithSeedlingMRSMovement = cell(1,NumFields);
    StereotypyDiagnostics = cell(1,NumFields);
    
    MovementswithFMControlCoActivity = cell(1,NumFields);
    MovementswithFMControlCoActivitybyCluster = cell(1,NumFields);
    FMControlMovementsCorrelationwithModelMovement = cell(1,NumFields);
    FMControlMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    CorrelationofMovementswithCoActiveFMControlActivity = cell(1,NumFields);
    CorrelationofMovementswithCoActiveFMControlActivitybyCluster = cell(1,NumFields);
    
    MovementswithMRSDMCoActivity = cell(1,NumFields);
    MovementswithMRSDMCoActivitybyCluster = cell(1,NumFields);
    MRSDMControlMovementsCorrelationwithModelMovement = cell(1,NumFields);
    MRSDMControlMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    CorrelationofMovementswithCoActiveMRSDMControlActivity = cell(1,NumFields);
    CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster = cell(1,NumFields);
    
    MovementswithAllOtherSpineCoActivity = cell(1,NumFields);
    CorrelationofMovementswithAllOtherSpineCoActivity = cell(1,NumFields);
    AllOtherSpineCoActivityMovementsCorrelationwithModelMovement  = cell(1,NumFields);
    
    MovementswithNSDMCoActivitybyCluster = cell(1,NumFields);
    NSDMControlMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster = cell(1,NumFields);
    MovementswithMRSOnlyActivity = cell(1,NumFields);
    MovementswithMRSOnlyActivitybyCluster = cell(1,NumFields);
    CorrelationofMovementswithMRSOnlyActivity = cell(1,NumFields);
    CorrelationofMovementswithMRSOnlyActivitybyCluster = cell(1,NumFields);
    MovementswithNSOnlyActivity = cell(1,NumFields);
    MovementswithNSOnlyActivitybyCluster = cell(1,NumFields);
    CorrelationofMovementswithNSOnlyActivity = cell(1,NumFields);
    CorrelationofMovementswithNSOnlyActivitybyCluster = cell(1,NumFields);
    MRSOnlyMovementsCorrelationwithModelMovement = cell(1,NumFields);
    MRSOnlyMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    NSOnlyMovementsCorrelationwithModelMovement = cell(1,NumFields);
    NSOnlyMovementsCorrelationwithModelMovementbyCluster = cell(1,NumFields);
    WithoutGroupMovements = cell(1,NumFields);
    MovementCorrelationofAllOtherMovements = cell(1,NumFields);
    AllOtherMovementsCorrelationwithModelMovement = cell(1,NumFields);
    
    ClustActivityStartRelativetoMovement = cell(1,NumFields);
    ClustActivityStartNormalizedtoMovementLength = cell(1,NumFields);
    StandardDeviationofClustActivityOnset = cell(1,NumFields);
    StandardDeviationofNormClustActivityOnset = cell(1,NumFields);
    LeverPositionatClustActivityOnset = cell(1,NumFields);
    LeverVelocityatClustActivityOnset = cell(1,NumFields);
    LeverVelocityatRandomLagsfromOnset = cell(1,NumFields);
    MeanSpeedofActMovementPeriods = cell(1,NumFields);
    MeanSpeedofOtherMovementPeriods = cell(1,NumFields); 
    LeverSlopeTraces = cell(1,NumFields);
    ShuffledClustActivityStart = cell(1,NumFields);
    ShuffledActivityStartNormalizedtoMovementLength = cell(1,NumFields);
    StandardDeviationofShuffledActivityOnset = cell(1,NumFields);
    StandardDeviationofNormShuffledActivityOnset = cell(1,NumFields);
    LeverPositionatShuffledActivityOnset = cell(1,NumFields);
    LeverVelocityatShuffledActivityOnset = cell(1,NumFields);
    ClustActivityStartHypothesisTest= cell(1,NumFields);
    FMActivityStartRelativetoMovement = cell(1,NumFields);
    MRSDMActivityStartRelativetoMovement = cell(1,NumFields);
    NSDMActivityStartRelativetoMovement = cell(1,NumFields);
    NSonlyActivityStartRelativetoMovement = cell(1,NumFields);
    StandardDeviationofNSOnlyActivityOnset = cell(1,NumFields);
    LeverPositionatNSOnlyActivityOnset = cell(1,NumFields);
    LeverVelocityatNSOnlyActivityOnset = cell(1,NumFields);
    LeverVelocityatShuffledNSActivityOnset = cell(1,NumFields);
    LeverPositionatMRSOnlyActivityOnset = cell(1,NumFields);
    LeverVelocityatMRSOnlyActivityOnset = cell(1,NumFields);
    LeverVelocityatShuffledMRSActivityOnset = cell(1,NumFields);
    
    HCPClusteredNewSpineCorrwithMovement = cell(1,NumFields);
    HCPClusteredNewSpineCorrwithSuccess = cell(1,NumFields);
    HCPCorrwithMovement = cell(1,NumFields);
    HCPCorrwithSuccess = cell(1,NumFields);
    CoActiveHCPClusterCorrwithMovement = cell(1,NumFields);
    CoActiveHCPClusterCorrwithSuccess = cell(1,NumFields);
    MovementCorrelationwithCoActiveHCPClusters = cell(1,NumFields);
    MovementCorrelationofAllOtherNonHCPMovements = cell(1,NumFields);
    MovementCorrelationofHCPComparatorSpines = cell(1,NumFields);
    MoveCentricHCPClusterCorrelation = cell(1,NumFields);
    
    % Movement-relatedness stuff
    IsMovementRewardedEarly = cell(1,NumFields);
    IsMovementRewardedLate = cell(1,NumFields);
    IsCoActiveAntiClusterMovementRewarded = cell(1,NumFields);
    DotProductofCoActivePeriodsDuringMovement = cell(1,NumFields);
    AllCoActivityDotProductsforDistanceMeasurement = cell(1,NumFields);
    DotProductofFMCoActivePeriodsDuringMovement = cell(1,NumFields);
    DotProductofNSDMCoActivePeriodsDuringMovement = cell(1,NumFields);
    DotProductofNSOnlyActivePeriodsDuringMovement = cell(1,NumFields);
    DotProductofMRSDMCoActivePeriodsDuringMovement = cell(1,NumFields);
    DotProductofMRSOnlyPeriodsDuringMovement = cell(1,NumFields);
    DotProductofCoActivePeriodsDuringCRMovement = cell(1,NumFields);
    DotProductofCoActivePeriodsDuringStillness = cell(1,NumFields);
    DotProductofFMCoActivePeriodsDuringCRMovement = cell(1,NumFields);
    ChanceLevelofCoactivityMovementOverlap = cell(1,NumFields);
    AllCoActivityChanceLevelDotProductsforDistanceMeasurement = cell(1,NumFields);
    ChanceLevelofFMCoActivitywithmovement = cell(1,NumFields);
    ChanceLevelofNSDMCoActivitywithMovement = cell(1,NumFields);
    ChanceLevelofNSOnlyActivitywithMovement = cell(1,NumFields);
    ChanceLevelofMRSDMCoActivitywithMovement = cell(1,NumFields);
    ChanceLevelofMRSOnlyPeriodsDuringMovement = cell(1,NumFields);
	ChanceLevelofCoActivityCRMovementOverlap = cell(1,NumFields);
    ChanceLevelofFMCoActivityCRMovementOverlap = cell(1,NumFields);
        
    IsCoActiveMovementRewarded = cell(1,NumFields);
    MoveOnlyAddresses = cell(1,NumFields);
    IsMoveOnlyRewarded = cell(1,NumFields);
    NewOnlyAddresses = cell(1,NumFields);
    MRSDM_CoActiveAddresses = cell(1,NumFields);
    NSDM_CoActiveAddresses = cell(1,NumFields);
    MoveOnlyChanceRewardedLevel = cell(1,NumFields);
    IsNewOnlyRewarded = cell(1,NumFields);
    NewOnlyChanceRewardedLevel = cell(1,NumFields);
    comp_CoActiveAddresses = cell(1,NumFields);
    IsCompCoActiveMovementRewarded = cell(1,NumFields);
    FMChanceRewardedLevel = cell(1,NumFields);
    IsMRSDMCoActiveMovementRewarded = cell(1,NumFields);
    MRSDMChanceRewardedLevel = cell(1,NumFields);
    IsNSDMCoActiveMovementRewarded = cell(1,NumFields);
    NSDMChanceRewardedLevel = cell(1,NumFields);
    ChanceRewardedLevel = cell(1,NumFields);
    ChanceRewardedLevelElimVersion = cell(1,NumFields);
    
    MedianMovementCorrelationbyNewSpine = cell(1,NumFields);
    
    NumberofMovementswithClusterCoActivitybyCluster = cell(1,NumFields);
    FractionofMovementswithClusterCoActivitybyCluster = cell(1,NumFields);

    DendsWithBothDynamics = repmat({0},1,NumFields);
    DendsWithBothClustDynamics = repmat({0},1,NumFields);
    
    %%% Event rate descriptions, etc
    NSonlyEventRate = cell(1,NumFields);
    NSonlyIntegratedActivity = cell(1,NumFields);
    FractionofNSActivityDuringMovements = cell(1,NumFields);
    FractionofMRSActivityDuringMovements = cell(1,NumFields);
        
    ClustCoActiveRate = cell(1,NumFields);
    ClustIntegratedCoactivity = cell(1,NumFields);
    FractionofClustActivityDuringMovements = cell(1,NumFields);
    FractionofClustActivityDuringCRMovements = cell(1,NumFields);
    FMcompCoActiveRate = cell(1,NumFields);
    MRSDMcompCoActiveRate = cell(1,NumFields);
    NSDMcompCoActiveRate = cell(1,NumFields);
    NumberofMovementswithAnyClusterCoActivity = [];
    FractionofMovementswithAnyClusterCoActivity = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %======================================================================
    
    CoActivityDifferenceOptimizationCurve = {}; optimcount = 1;
    
    %% ====================================================================
    for f = 1:NumFields
        NumberofSpines = size(FieldChanges{f},1);
        usedthiMRSforMRSOnlyPeriods = [];
        usedforCMRSFreqComp = [];
        countedpersistentMRSs = [];
        %%%%%%%%%%%%% 
        %%% When choosing data to use (i.e. dend subtracted vs. excluded),
        %%% you must change everything that mentions STATCLASS,
        %%% CORRELATIONS, as well as raw activity
        SessionsbyField{f} = cell2mat(cellfun(@(x) x(:).Session, FieldData{f}.CalciumData, 'uni', false));
        if size(FieldChanges{f},2) >1   %%%If more than two sessions (three session data can reveal, e.g., transient new spines that don't persist; primary interest is in those that persist)
            isThreeSessions = 1;
        else
            isThreeSessions = 0;
        end
        earlysession = FieldData{f}.CalciumData{1}.Session;
        if isThreeSessions
            midsession = FieldData{f}.CalciumData{2}.Session;
        else
            midsession = [];
        end
        latesession = FieldData{f}.CalciumData{end}.Session;
        %%%%%%%%%%%%%%%%
        %==================================================================
        FocusOnWhichMovements = 'All';    %%% Change this value between "All", "CuedRewarded", and "Rewarded" to consider different categories of movements;
        %==================================================================
        eval(['cuetraceEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.Cue;']);
        eval(['binarizedleverEarly = ', currentanimal, '_Aligned{',num2str(earlysession),'}.Binarized_Lever;']);
        eval(['successtraceEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SuccessfulPresses;']);
        eval(['levertraceEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.LeverMovement;']);
        eval(['rewardperiodsEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.RewardDelivery;']);
        eval(['cuetraceLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.Cue;']);
        eval(['binarizedleverLate = ', currentanimal, '_Aligned{',num2str(latesession),'}.Binarized_Lever;']);
        eval(['successtraceLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.SuccessfulPresses;']);
        eval(['levertraceLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.LeverMovement;']);
        eval(['rewardperiodsLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.RewardDelivery;']);
        
        failuretraceEarly = binarizedleverEarly-successtraceEarly;
        failuretraceLate = binarizedleverLate-successtraceLate;
        
        trialstructEarly = cuetraceEarly+rewardperiodsEarly'; trialstructEarly(trialstructEarly>1) = 1;
        trialstructLate = cuetraceLate+rewardperiodsLate'; trialstructLate(trialstructLate>1) = 1;
        
        %%%%%%%%%%%%%%%%
        %%% Attempt to separate individual presses, not just by the more
        %%% general "lever active" periods
%         
%         [~,locs] = findpeaks(levertraceEarly, 'MinPeakProminence', 0.1);  %%% Finds PULLS/RELEASES, not pushes, so as to separate when the lever is retracted to start a new movement
%         binarizedleverEarly(locs) = 0;
%         
%         [~,locs] = findpeaks(levertraceLate, 'MinPeakProminence', 0.1);   %%% Finds PULLS/RELEASES, not pushes, so as to separate when the lever is retracted to start a new movement
%         binarizedleverLate(locs) = 0;
        
        %==================================================================
        boundMEarly = find(diff([Inf; binarizedleverEarly; Inf])~=0);
        allperiodsMEarly = mat2cell(binarizedleverEarly, diff(boundMEarly));
        moveperiodsEarly = allperiodsMEarly(cell2mat(cellfun(@any, allperiodsMEarly, 'uni', false)));
        boundSEarly = find(diff([Inf; successtraceEarly; Inf])~=0);
        allperiodsSEarly = mat2cell(successtraceEarly, diff(boundSEarly));
        successperiodsEarly = allperiodsSEarly(cell2mat(cellfun(@any, allperiodsSEarly, 'uni', false)));
        rewstartEarly = diff([0;rewardperiodsEarly]); rewstartEarly(rewstartEarly<0)= 0; %%% Using this instead of the binarized success trace gives more accuracy in terms of which discrete movements were rewarded!
        success_allmove_separated_Early = mat2cell(rewstartEarly, diff(boundMEarly));
        success_allmove_separated_moveperiods_Early = success_allmove_separated_Early(cellfun(@any, allperiodsMEarly));
        IsMovementRewardedEarly{f} = cellfun(@any, success_allmove_separated_moveperiods_Early);
        %%%
        %%% If not filtering out trials when the animal is moving at the
        %%% beginning, you need to separate movements based on when the
        %%% cue starts (otherwise you can have variable movement lengths
        %%% that go out long before the putative associated activity even
        %%% starts); do this by subtracting the cue signal from the
        %%% movement trace
%         cuestart = diff([Inf, cuetraceLate])>0;
%         binarizedleverLate = binarizedleverLate & ~(cuestart');
        boundMLate = find(diff([Inf; binarizedleverLate; Inf])~=0);
        allperiodsMLate = mat2cell(binarizedleverLate, diff(boundMLate));
        moveperiodsLate = allperiodsMLate(cell2mat(cellfun(@any, allperiodsMLate, 'uni', false)));
        boundSLate = find(diff([Inf; successtraceLate; Inf])~=0);
        allperiodsSLate = mat2cell(successtraceLate, diff(boundSLate));
        successperiodsLate = allperiodsSLate(cell2mat(cellfun(@any, allperiodsSLate, 'uni', false)));
        rewstartLate = diff([0;rewardperiodsLate]); rewstartLate(rewstartLate<0)= 0;
        rew_move_separated_Late = mat2cell(rewstartLate, diff(boundMLate));
        rew_during_moveperiods_Late = rew_move_separated_Late(cellfun(@any, allperiodsMLate));
        IsMovementRewardedLate{f} = cellfun(@any, rew_during_moveperiods_Late);
        %%%
        PreCueTolerance = 10/1000;
        PreCueTolerance = round(ImagingFrequency*PreCueTolerance);
        
        [CRBoundsEarly, CMovementsEarly, CRMovementsTraceEarly] = FindCuedRewardedMovements(PreCueTolerance, cuetraceEarly, binarizedleverEarly, rewardperiodsEarly);
        CuedRewardedMovementTracesEarly{f} = CRMovementsTraceEarly;
        [CRBoundsLate, CMovementsLate, CRMovementsTraceLate] = FindCuedRewardedMovements(PreCueTolerance, cuetraceLate, binarizedleverLate, rewardperiodsLate);
        CuedRewardedMovementTracesLate{f} = CRMovementsTraceLate;
        %==================================================================
        
        switch FocusOnWhichMovements
            case 'Rewarded'
                boundstouseEarly = boundSEarly;
                boundstouseLate = boundSLate;
                allperiodblocksEarly = allperiodsSEarly;
                allperiodblocksLate = allperiodsSLate;
                targetperiodsEarly = successperiodsEarly;
                targetperiodsLate = successperiodsLate;
            case 'All'
                boundstouseEarly = boundMEarly;
                boundstouseLate = boundMLate;
                allperiodblocksEarly = allperiodsMEarly;
                allperiodblocksLate = allperiodsMLate;
                targetperiodsEarly = moveperiodsEarly;
                targetperiodsLate = moveperiodsLate;
            case 'CuedRewarded'
                boundstouseEarly = CRBoundsEarly.BoundsofCRMovements;
                allperiodblocksEarly = CRBoundsEarly.AllPeriodsSeparatedbyCRMovements;
                targetperiodsEarly = CRBoundsEarly.PeriodswithCRMovements;
                
                boundstouseLate = CRBoundsLate.BoundsofCRMovements;
                allperiodblocksLate = CRBoundsLate.AllPeriodsSeparatedbyCRMovements;
                CRTrace_SeparatedbyAllMovementBounds = mat2cell(CRMovementsTraceLate,diff(boundMLate));
                targetperiodsLate = CRBoundsLate.PeriodswithCRMovements;
        end
        %==================================================================
        %%% Note: if looking at all movements, you might want to exclude
        %%% those that are longer than, say, your typical selected movement
        %%% length (e.g. 3sec) to avoid ambiguity about how activity
        %%% relates to a particular movement (longer movements = harder to
        %%% interpret how activity contributed). 
        %%% Also consider removing movements that are too close together
        %%% (if, e.g., movements are short and close together, then the
        %%% second movement can be considered as part of the first, and is
        %%% this considered twice). 
        movemax = ImagingFrequency*targetsecondspostmovementstart;  %%% IF you want the stereotypy of movements that SHOW CERTAIN ACTIVITY, then it makes the most sense to not allow the movements to be any longer than what is considered for stereotypy (e.g. if you consider a 4s movement, and the activity is at t = 3.7s, then only considering the stereotypy for 3 seconds wouldn't be considering what is relevant to the activity itself!)
        min_separation = ImagingFrequency*targetsecondspostmovementstart;
        %%%
        lever_separatedEarly = mat2cell(levertraceEarly, diff(boundstouseEarly));   %%% Even if you want successful presses, you want to start with the actual lever force trace (i.e. NOT the binarized trace) so as to characterize movement stereotypy
        framesEarly = 1:length(levertraceEarly);
        frames_separatedEarly = mat2cell(framesEarly', diff(boundstouseEarly));    %%% All frames, separated into cells by the boundaries defined above (e.g. all movements or only successul movements)
        lever_trace_during_targetperiodsEarly = lever_separatedEarly(cell2mat(cellfun(@any, allperiodblocksEarly, 'uni', false))); %%% Separate the lever trace accordingly
        frames_during_targetperiodsEarly = frames_separatedEarly(cell2mat(cellfun(@any, allperiodblocksEarly, 'uni', false))); %%% Extract the actual frames corresponding to the target periods
%         if useMaxMoveLengthcutoff
%             SufficientlyShortMovements = cellfun(@(x) length(x)<movemax, frames_during_targetperiodsEarly);
%         else
%             SufficientlyShortMovements = ones(length(frames_during_targetperiodsEarly),1);
%         end
        if discardJustaposedMovements
            exclude = []; 
            for t = 1:length(frames_during_targetperiodsEarly)-1
                if (frames_during_targetperiodsEarly{t+1}(1)-frames_during_targetperiodsEarly{t}(1))<min_separation
                    exclude = [exclude, t];
                end
            end
            SufficientlySeparatedMovements = ones(length(frames_during_targetperiodsEarly),1);
            SufficientlySeparatedMovements(exclude) = 0;
        else
            SufficientlySeparatedMovements = ones(length(frames_during_targetperiodsEarly),1);
        end
        
        TargetBlocksMeetingCriteriaEarly = logical(SufficientlySeparatedMovements);
        frames_during_targetperiodsEarly = frames_during_targetperiodsEarly(TargetBlocksMeetingCriteriaEarly);
        %%%

        lever_separatedLate = mat2cell(levertraceLate, diff(boundstouseLate));   %%% Even if you want successful presses, you want to start with the actual lever force trace (i.e. NOT the binarized trace) so as to characterize movement stereotypy
        frames = 1:length(levertraceLate);
        frames_separated = mat2cell(frames', diff(boundstouseLate));    %%% All frames, separated into cells by the boundaries defined above (e.g. all movements or only successul movements)
        lever_trace_during_targetperiods = lever_separatedLate(cell2mat(cellfun(@any, allperiodblocksLate, 'uni', false))); %%% Separate the lever trace accordingly
        frames_during_targetperiods = frames_separated(cell2mat(cellfun(@any, allperiodblocksLate, 'uni', false))); %%% Extract the actual frames corresponding to the target periods
%         if useMaxMoveLengthcutoff
%             SufficientlyShortMovements = cellfun(@(x) length(x)<movemax, frames_during_targetperiods);
%         else
%             SufficientlyShortMovements = ones(length(frames_during_targetperiods),1);
%         end
        if discardJustaposedMovements
            exclude = []; 
            for t = 1:length(frames_during_targetperiods)-1
                if (frames_during_targetperiods{t+1}(1)-frames_during_targetperiods{t}(1))<min_separation
                    exclude = [exclude, t];
                end
            end
            SufficientlySeparatedMovements = ones(length(frames_during_targetperiods),1);
            SufficientlySeparatedMovements(exclude) = 0;
        else
            SufficientlySeparatedMovements = ones(length(frames_during_targetperiods),1);
        end
        
        TargetBlocksMeetingCriteriaLate = logical(SufficientlySeparatedMovements);
        frames_during_targetperiods = frames_during_targetperiods(TargetBlocksMeetingCriteriaLate);
        
        disp([num2str(ceil(sum(TargetBlocksMeetingCriteriaLate)/length(lever_trace_during_targetperiods)*100)), '% of movements left after filtering'])
        %==================================================================
        MovementBlocks.binarizedleverEarly = binarizedleverEarly;
        MovementBlocks.binarizedleverLate = binarizedleverLate;
        MovementBlocks.boundstouseEarly = boundstouseEarly;
        MovementBlocks.boundstouse = boundstouseLate;
        MovementBlocks.allperiodblocksEarly = allperiodblocksEarly;
        MovementBlocks.allperiodblocks = allperiodblocksLate;
        MovementBlocks.lever_trace_during_targetperiodsEarly = lever_trace_during_targetperiodsEarly;
        MovementBlocks.lever_trace_during_targetperiods = lever_trace_during_targetperiods;
        MovementBlocks.frames_during_targetperiodsEarly = frames_during_targetperiodsEarly;
        MovementBlocks.frames_during_targetperiods = frames_during_targetperiods;
        MovementBlocks.targetperiodsEarly = targetperiodsEarly;
        MovementBlocks.targetperiods = targetperiodsLate;
        MovementBlocks.targetblocksmeetingcriteriaEarly = TargetBlocksMeetingCriteriaEarly;
        MovementBlocks.targetblocksmeetingcriteriaLate = TargetBlocksMeetingCriteriaLate;
        MovementBlocks.levertraceEarly = levertraceEarly;
        MovementBlocks.levertraceLate = levertraceLate;
        MovementBlocks.successtraceEarly = successtraceEarly;
        MovementBlocks.successtraceLate = successtraceLate;
        MovementBlocks.rewardperiodsEarly = rewardperiodsEarly;
        MovementBlocks.rewardperiodsLate = rewardperiodsLate;
        MovementBlocks.AllMovementBoundsEarly = boundMEarly;
        MovementBlocks.AllMovementBoundsLate = boundMLate;
        MovementBlocks.AllMovementPeriodsEarly = allperiodsMEarly;
        MovementBlocks.AllMovementPeriodsLate = allperiodsMLate;
        
        shuffledmovetraces = [];
        shuffledCRmovetraces = [];
        for shf = 1:1000
            SimMov = shake(allperiodsMLate);
            shuffledmovetraces(:,shf) = vertcat(SimMov{:});
            SimCRMov = shake(CRBoundsLate.AllPeriodsSeparatedbyCRMovements);
            shuffledCRmovetraces(:,shf) = vertcat(SimCRMov{:});
        end

        %%%%%%%%%%%%%
        Spine1_Address = 10;
        NumberofEarlySpines = FieldData{f}.CalciumData{1}.NumberofSpines;
        NumberofLateSpines = FieldData{f}.CalciumData{end}.NumberofSpines;
        SpineDendriteGrouping{f} = FieldData{f}.CalciumData{1}.SpineDendriteGrouping;
        %%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%% Find and index any new spines from each field %%%%%%%%%
        if isThreeSessions  %%%If more than two sessions (three session data can reveal, e.g., transient new spines that last to the final session; ***primary interest is in those that persist***)
            NewSpines{f} = find(sum(FieldChanges{f},2)>0);
            MiddleSessionNewSpines{f}  = find(~FieldData{f}.Data(:,1) & FieldData{f}.Data(:,2));
            LateSessionNewSpines{f} = find(~FieldData{f}.Data(:,1) & ~FieldData{f}.Data(:,2) & FieldData{f}.Data(:,3));
            if ~isempty(MiddleSessionNewSpines{f})
                persistentNewSpines{f} = find(~FieldData{f}.Data(:,1) & FieldData{f}.Data(:,2) & FieldData{f}.Data(:,3));
                transientNewSpines{f} = find(~FieldData{f}.Data(:,1) & FieldData{f}.Data(:,2) & ~FieldData{f}.Data(:,3));
            else
                persistentNewSpines{f} = [];
                transientNewSpines{f} = [];
            end
        else
            NewSpines{f} = find(FieldChanges{f}>0);
            MiddleSessionNewSpines{f} = [];
            LateSessionNewSpines{f} = NewSpines{f};
            transientNewSpines{f} = [];
        end
        newspineslogical = zeros(NumberofSpines,1); newspineslogical(NewSpines{f}) = 1;
        for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
            SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
            NewSpinesbyDendrite{f}{dnd} = newspineslogical(SpinesOnThisDend);
        end
        NumberofNewSpines = NumberofNewSpines+length(NewSpines{f});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(FieldChanges{f},2)>1    %%% Eliminated spines are different that new spines in that they are (probably) never 'transiently' eliminated (1->0->1); however, a new spine can be eliminated immediately (0->1->0, and so you cannot simply sum the difference columns to report change whether any elimination occurred
            for fc = 1:size(FieldChanges{f},2)
                ElimSpines{f} = [ElimSpines{f}; find(FieldChanges{f}(:,fc)<0)];
            end
        else
            ElimSpines{f} = find(FieldChanges{f}<0);
        end
        elimspineslogical = zeros(NumberofSpines,1); elimspineslogical(ElimSpines{f}) = 1;
        for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
            SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
            ElimSpinesbyDendrite{f}{dnd} = elimspineslogical(SpinesOnThisDend);
        end
        NumberofElimSpines = NumberofElimSpines+length(ElimSpines{f});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch AnalysisType
            case 'Exclude'
                NumberofPersistentMovementRelatedSpines{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.StatClass{end}.MovementSpines));
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.StatClass{end}.MovementSpines))/sum(FieldData{1}.StatClass{1}.MovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.MovementSpines);
                if isThreeSessions
                    AllMovementSpinesOnMidSession = find(FieldData{f}.StatClass{2}.MovementSpines);
                    %%% Consider both spines that remain MRS from
                    %%% early->late and from mid-> late
                    NumberofPersistentMovementRelatedSpines{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(AllMovementSpinesOnEarlySession) & FieldData{f}.StatClass{end}.OverallMovementSpines(AllMovementSpinesOnEarlySession))+sum(FieldData{f}.StatClass{2}.OverallMovementSpines(AllMovementSpinesOnMidSession) & FieldData{f}.StatClass{end}.OverallMovementSpines(AllMovementSpinesOnMidSession));
                else
                    AllMovementSpinesOnMidSession = [];
                    NumberofPersistentMovementRelatedSpines{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(AllMovementSpinesOnEarlySession) & FieldData{f}.StatClass{end}.OverallMovementSpines(AllMovementSpinesOnEarlySession));
                end
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.MovementSpines);
                AllCueSpines{f} = cell2mat(cellfun(@(x) x.CueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementDuringCueSpines{f} = cell2mat(cellfun(@(x) x.MovementDuringCueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.MovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementRanks{f} = cell2mat(cellfun(@(x) x.MovementRank, FieldData{f}.StatClass, 'uni', false));
                AllRewMovementSpines{f} = cell2mat(cellfun(@(x) x.MovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllRewardSpines{f} = cell2mat(cellfun(@(x) x.RewardSpines, FieldData{f}.StatClass, 'uni', false));
                AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations = FieldData{f}.Correlations{end}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
            case 'Subtract'
                eval(['AllEarlySpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSpineActivity;'])
                eval(['AllLateSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSpineActivity;'])
                eval(['AllEarlySpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSynapseOnlyBinarized;'])
                eval(['AllLateSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized;'])
                %%% The following will add amplitude to binarized traces
                AllEarlySpineBinarizedAligned = PreserveActivityAmplitude(AllEarlySpineActivityAligned, AllEarlySpineBinarizedAligned);
                AllLateSpineBinarizedAligned = PreserveActivityAmplitude(AllLateSpineActivityAligned,AllLateSpineBinarizedAligned);
                %%%
                AllEarlyMoveCentricSpineBinarizedAligned = AllEarlySpineBinarizedAligned.*repmat(binarizedleverEarly',size(AllEarlySpineActivityAligned,1),1);
                AllLateMoveCentricSpineBinarizedAligned = AllLateSpineBinarizedAligned.*repmat(binarizedleverLate',size(AllLateSpineBinarizedAligned,1),1);
                %%%
                if use_dFoF_not_binarized
                    AllEarlySpineCorrelations = corrcoef(AllEarlySpineActivityAligned');
                    AllLateSpineCorrelations = corrcoef(AllLateSpineActivityAligned');
                else
                    AllEarlySpineCorrelations = corrcoef(AllEarlySpineBinarizedAligned');
                    AllEarlySpineNoiseCorrelations = corrcoef(AllEarlyMoveCentricSpineBinarizedAligned');
                    AllLateSpineRawTraceCorrelations = corrcoef(AllLateSpineActivityAligned');
                    AllLateSpineCorrelations = corrcoef(AllLateSpineBinarizedAligned');
                    AllLateSpineNoiseCorrelations = corrcoef(AllLateMoveCentricSpineBinarizedAligned');
                end
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.DendSub_MovementSpines);
                AllMovementRanksOnEarlySession = FieldData{f}.StatClass{1}.DendSub_MovementRank;
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.DendSub_MovementSpines);
                if isThreeSessions
                    eval(['AllMidSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(midsession), '}.DendSubSpineActivity;'])
                    eval(['AllMidSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(midsession), '}.DendSubSynapseOnlyBinarized;'])
                    %%% The following will add amplitude to binary traces
                    AllMidSpineBinarizedAligned = PreserveActivityAmplitude(AllMidSpineActivityAligned, AllMidSpineBinarizedAligned);
                    %%%
                    AllMovementSpinesOnMidSession = find(FieldData{f}.StatClass{2}.DendSub_MovementSpines);
                    EarlierSessionMovementSpines = union(AllMovementSpinesOnEarlySession, AllMovementSpinesOnMidSession);
                    if use_dFoF_not_binarized
                        AllMidSpineCorrelations = corrcoef(AllMidSpineActivityAligned');
                    else
                        AllMidSpineCorrelations = corrcoef(AllMidSpineBinarizedAligned');
                    end    
                else
                    AllMidSpineCorrelations = nan(NumberofSpines,NumberofSpines);
                    EarlierSessionMovementSpines = AllMovementSpinesOnEarlySession;
                    AllMovementSpinesOnMidSession = [];
                end
                NumberofPersistentMovementRelatedSpines{f} = sum(ismember(EarlierSessionMovementSpines, AllMovementSpinesOnLateSession));
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.StatClass{end}.DendSub_MovementSpines))/sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.DendSub_MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllCueSpines{f} = cell2mat(cellfun(@(x) x.DendSub_CueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementDuringCueSpines{f} = cell2mat(cellfun(@(x) x.DendSub_MovementDuringCueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementRanks{f} = cell2mat(cellfun(@(x) x.DendSub_MovementRank, FieldData{f}.StatClass, 'uni', false));
                AllRewMovementSpines{f} = cell2mat(cellfun(@(x) x.DendSub_SuccessSpines, FieldData{f}.StatClass, 'uni', false));
                AllRewardSpines{f} = cell2mat(cellfun(@(x) x.DendSub_RewardSpines, FieldData{f}.StatClass, 'uni', false));
%                 if ConsiderOnlyMovementPeriods
%                     AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendriteSubtractedSpineDuringMovePeriods; %%% This matrix only considers spines and not behavioral features, so the whole matrix is taken (unlike the matrix for all periods, below)
%                     AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendriteSubtractedSpineDuringMovePeriods;
%                 else
%                     AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
%                     AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
%                 end
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                AllLateSpineRawTraceCorrelations(1:1+size(AllLateSpineRawTraceCorrelations,1):numel(AllLateSpineRawTraceCorrelations)) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
            case 'Ignore'
                eval(['AllEarlySpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.ProcessedSpineActivity;'])
                eval(['AllLateSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity;'])
                eval(['AllEarlySpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.BinarizedOverallSpineData;'])
                eval(['AllLateSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.BinarizedOverallSpineData;'])
                %%% The following will add amplitude to binarized traces
                AllEarlySpineBinarizedAligned = PreserveActivityAmplitude(AllEarlySpineActivityAligned, AllEarlySpineBinarizedAligned);
                AllLateSpineBinarizedAligned = PreserveActivityAmplitude(AllLateSpineActivityAligned,AllLateSpineBinarizedAligned);
                %%% Zero all values outside of movements for noise corr.
                AllEarlyMoveCentricSpineBinarizedAligned = AllEarlySpineBinarizedAligned.*repmat(binarizedleverEarly',size(AllEarlySpineActivityAligned,1),1);
                AllLateMoveCentricSpineBinarizedAligned = AllLateSpineBinarizedAligned.*repmat(binarizedleverLate',size(AllLateSpineBinarizedAligned,1),1);
                %%%
                if use_dFoF_not_binarized
                    AllEarlySpineCorrelations = corrcoef(AllEarlySpineActivityAligned');
                    AllLateSpineCorrelations = corrcoef(AllLateSpineActivityAligned');
                else
                    AllEarlySpineCorrelations = corrcoef(AllEarlySpineBinarizedAligned');
                    AllEarlySpineNoiseCorrelations = corrcoef(AllEarlyMoveCentricSpineBinarizedAligned');
                    AllLateSpineRawTraceCorrelations = corrcoef(AllLateSpineActivityAligned');
                    AllLateSpineCorrelations = corrcoef(AllLateSpineBinarizedAligned');
                    AllLateSpineNoiseCorrelations = corrcoef(AllLateMoveCentricSpineBinarizedAligned');
                end
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.OverallMovementSpines);
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.OverallMovementSpines);
                if isThreeSessions
                    eval(['AllMidSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(midsession), '}.ProcessedSpineActivity;'])
                    eval(['AllMidSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(midsession), '}.BinarizedOverallSpineData;'])
                    %%% The following will add amplitude to binary traces
                    AllMidSpineBinarizedAligned = PreserveActivityAmplitude(AllMidSpineActivityAligned, AllMidSpineBinarizedAligned);
                    %%%
                    AllMovementSpinesOnMidSession = find(FieldData{f}.StatClass{2}.OverallMovementSpines);
                    EarlierSessionMovementSpines = union(AllMovementSpinesOnEarlySession, AllMovementSpinesOnMidSession);
                    if use_dFoF_not_binarized
                        AllMidSpineCorrelations = corrcoef(AllMidSpineActivityAligned'); AllMidSpineCorrelations(1:1+size(AllMidSpineCorrelations):end) = nan;
                    else
                        AllMidSpineCorrelations = corrcoef(AllMidSpineBinarizedAligned'); AllMidSpineCorrelations(1:1+size(AllMidSpineCorrelations):end) = nan;
                    end 
                else
                    AllMidSpineCorrelations = nan(NumberofSpines,NumberofSpines);
                    AllMovementSpinesOnMidSession = [];
                    EarlierSessionMovementSpines = AllMovementSpinesOnEarlySession;
                end
                NumberofPersistentMovementRelatedSpines{f} = sum(ismember(EarlierSessionMovementSpines, AllMovementSpinesOnLateSession));
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.OverallMovementSpines(FieldData{f}.StatClass{end}.OverallMovementSpines))/sum(FieldData{f}.StatClass{1}.OverallMovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.OverallMovementSpines)<0))/sum(FieldData{f}.StatClass{1}.OverallMovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllCueSpines{f} = cell2mat(cellfun(@(x) x.OverallCueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementDuringCueSpines{f} = cell2mat(cellfun(@(x) x.OverallMovementDuringCueSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.OverallMovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllMovementRanks{f} = cell2mat(cellfun(@(x) x.OverallMovementRank, FieldData{f}.StatClass, 'uni', false));
                AllRewMovementSpines{f} = cell2mat(cellfun(@(x) x.OverallSuccessSpines, FieldData{f}.StatClass, 'uni', false));
                AllRewardSpines{f} = cell2mat(cellfun(@(x) x.OverallRewardSpines, FieldData{f}.StatClass, 'uni', false));
%                 if ConsiderOnlyMovementPeriods
%                     AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendriteSubtractedSpineDuringMovePeriods; %%% This matrix only considers spines and not behavioral features, so the whole matrix is taken (unlike the matrix for all periods, below)
%                     AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendriteSubtractedSpineDuringMovePeriods;
%                 else
%                     AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.OverallSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
%                     AllLateSpineCorrelations = FieldData{f}.Correlations{end}.OverallSpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
%                 end
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                AllLateSpineRawTraceCorrelations(1:1+size(AllLateSpineRawTraceCorrelations,1):numel(AllLateSpineRawTraceCorrelations)) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.OverallSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.OverallSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
        end
        AllSpineCorrelationsonLateSession{f} = AllLateSpineCorrelations;
        AllSpineNoiseCorrelationsonLateSession{f} = AllLateSpineNoiseCorrelations;
        if strcmpi(sensor, 'GCaMP')
            MovementSpinestoCompare = AllMovementSpinesOnLateSession;
        elseif strcmpi(sensor, 'GluSNFR') %%% This is a temporary effort to see if adding more MRSs to the GCaMP data yield similar results to GluSNFR
            MovementSpinestoCompare = AllMovementSpinesOnLateSession;
        end
        NumberofEarlyMovementRelatedSpines = NumberofEarlyMovementRelatedSpines+length(AllMovementSpinesOnEarlySession);
        NumberofMidSessionMovementRelatedSpines = NumberofMidSessionMovementRelatedSpines+length(AllMovementSpinesOnMidSession);
        NumberofLateMovementRelatedSpines = NumberofLateMovementRelatedSpines+length(AllMovementSpinesOnLateSession);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AllDendriteDistances{f} = FieldData{f}.CalciumData{end}.DistanceHeatMap;
        flipped = FieldData{f}.CalciumData{end}.DistanceHeatMap';
        AllDendriteDistances{f}(isnan(AllDendriteDistances{f})&~isnan(flipped)) = flipped(isnan(AllDendriteDistances{f})&~isnan(flipped));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shuffnum = 1000;
        ShuffledEarlyMovementLabels = cell(1,shuffnum);
        ShuffledLateMovementLabels = cell(1,shuffnum);
        for shuff = 1:shuffnum
            ShuffledEarlyMovementLabels{shuff} = randi(NumberofSpines,[length(MovementSpinestoCompare),1]);
            ShuffledLateMovementLabels{shuff} = randi(NumberofSpines,[length(AllMovementSpinesOnLateSession),1]);
            if length(ShuffledEarlyMovementLabels{shuff})>length(MovementSpinestoCompare)/2
                replimit = 1;
                while any(ismember(ShuffledEarlyMovementLabels{shuff}, MovementSpinestoCompare))>length(AllMovementSpinesOnLateSession)/2 && replimit<1000  %%% Attempt to exclude actual movement related spines from being included
                    ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines, [length(MovementSpinestoCompare),1]);
                    replimit = replimit+1;
                end
            else
                replimit = 1;
                while sum(ismember(ShuffledEarlyMovementLabels{shuff}, MovementSpinestoCompare))>length(MovementSpinestoCompare)/2 && replimit<1000
                    ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines, [length(MovementSpinestoCompare),1]);
                    replimit = replimit+1;
                end
            end
            replimit = 1;
            while any(ismember(ShuffledLateMovementLabels{shuff}, AllMovementSpinesOnLateSession)) && replimit <1000
                ShuffledLateMovementLabels{shuff} = randi(NumberofLateSpines, [length(AllMovementSpinesOnLateSession),1]);
                replimit = replimit+1;
            end
        end
        NumberofEarlierSessionMovementRelatedSpines = NumberofEarlierSessionMovementRelatedSpines+length(EarlierSessionMovementSpines);
        
        %==================================================================
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% Relevant to movement stereotypy %%%%%%%%%%%%%%%%%%%

%         useSDorPRCT = 'SD';
        useSDorPRCT = 'PRCT';

        if lower_thresh_for_coact
            switch useSDorPRCT
                case 'PRCT'
                    chosen_prct = 95;
                case 'SD'
                    chosen_prct = 2.5;
            end
        else
            chosen_prct = 100;
        end
        switch useSDorPRCT
            case 'PRCT'
                prctvals = [75:5:90, 91:98, 99:0.1:100];
            case 'SD'
                prctvals = [1.5,1.75,2,2.25,2.5,2.75,3,100];
        end
        if ~ismember(chosen_prct, prctvals)
            prctvals = sort([prctvals, chosen_prct]);
        end
        chosen_address = find(prctvals == chosen_prct);
        coactivethresh = nan(1,length(prctvals));
        if strcmpi(sensor, 'GCaMP')
            staticthresh = [0 0.0015 0.0077 0.0237 0.0290 0.0342 0.0436 0.0544 0.0670 0.0844 0.1320 0.2268 0.5085 0.5610 0.6351 0.7036 0.8095 0.8937 0.9672 1.1667 1.6447 2.1094]; %%% Calculated from the median prctile across all animals
        elseif strcmpi(sensor, 'GluSNFR')
            staticthresh = [0.0007, 0.0020, 0.0040, 0.0075, 0.0084, 0.0096, 0.0110, 0.0125, 0.0146, 0.0172, 0.0209, 0.0262, 0.0365, 0.0381, 0.0398, 0.0422, 0.0446, 0.0473, 0.0510, 0.0564, 0.0638, 0.0767]; %%% Calculated from the median prctile across all animals
        end
        %==================================================================
        %%% Find and index spines that aren't new or movement related at
        %%% any point, then describe the activity of these spines
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isThreeSessions
            AllOtherSpines = setdiff(1:NumberofLateSpines, union(NewSpines{f}, union(union(AllMovementSpinesOnEarlySession, AllMovementSpinesOnMidSession), AllMovementSpinesOnLateSession)));
        else    
            AllOtherSpines = setdiff(1:NumberofLateSpines, union(NewSpines{f}, union(AllMovementSpinesOnEarlySession,AllMovementSpinesOnLateSession)));
        end
        switch FocusOnWhichMovements
            case 'Rewarded'
                target_movements_trace = successtraceLate;
            case 'All'
                target_movements_trace = binarizedleverLate;
            case 'CuedRewarded'
                target_movements_trace = CRMovementsTraceLate;
        end
        switch AnalysisType
            case 'Subtract'
                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSpineActivity([', num2str(AllOtherSpines), '],:);'])
                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(AllOtherSpines), '],:);'])
            case 'Exclude'
                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(AllOtherSpines), '],:);'])
                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(AllOtherSpines), '],:);'])
                AllOtherSpineActivityAligned = AllOtherSpineActivityAligned.*AllOtherSpineBinarizedAligned;
            case 'Ignore'
                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(AllOtherSpines), '],:);'])
                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.BinarizedOverallSpineData([', num2str(AllOtherSpines), '],:);'])
        end
        %%% The following preserves event amp. from binary traces
        AllOtherSpineBinarizedAligned = PreserveActivityAmplitude(AllOtherSpineActivityAligned, AllOtherSpineBinarizedAligned);
        %%%
        if use_dFoF_not_binarized
            move_centric_otherspine_activity = AllOtherSpineActivityAligned(:,cell2mat(frames_during_targetperiods));   %%% Concatenate all periods of interest together
        else
            move_centric_otherspine_activity = AllOtherSpineBinarizedAligned(:,cell2mat(frames_during_targetperiods));   %%% Concatenate all periods of interest together
        end
        move_centric_otherspine_correlation = corrcoef(move_centric_otherspine_activity');
        move_centric_otherspine_correlation(1:size(move_centric_otherspine_correlation,1)+1:numel(move_centric_otherspine_correlation)) = nan;
        MoveCentricCorrelationofAllOtherSpines{f} = nanmedian(move_centric_otherspine_correlation,2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AllSpineVolumeData{f} = FieldData{f}.SpineVolumeData;
        %==================================================================
        for sp = 1:NumberofSpines
            spact = logical(AllEarlySpineBinarizedAligned(sp,:));
            AllSpineFrequency{f}(sp) = numel(find(diff(spact)>0))/(length(spact)/(ImagingFrequency*60));
        end
        %==================================================================
        %%% CoActivity Section

        % First, find the coactivity rates of all spine combos in the late
        % session
        spinecombos = nchoosek(1:NumberofSpines,2);
        AllSpinesEarlyCoActiveRates{f} = nan(1, length(spinecombos));
        AllSpinesEarlyCoActiveRatesGeoNormalized{f} = nan(1, length(spinecombos));
        for sc = 1:length(spinecombos)
            %%% Early
            sp1act = logical(AllEarlySpineBinarizedAligned(spinecombos(sc,1),:));
            sp1freq = numel(find(diff(sp1act)>0))/(length(sp1act)/(ImagingFrequency*60));
            sp2act = logical(AllEarlySpineBinarizedAligned(spinecombos(sc,2),:));
            sp2freq = numel(find(diff(sp2act)>0))/(length(sp2act)/(ImagingFrequency*60));
            coA = sp1act & sp2act;
            coAfreq = numel(find(diff(coA)>0))/(length(coA)/(ImagingFrequency*60));
            AllSpinesEarlyCoActiveRates{f}(sc) = coAfreq;
            AllSpinesEarlyCoActiveRatesGeoNormalized{f}(sc) = coAfreq./sqrt(sp1freq*sp2freq);
            %%% Late 
            sp1act = logical(AllLateSpineBinarizedAligned(spinecombos(sc,1),:));
            sp1freq = numel(find(diff(sp1act)>0))/(length(sp1act)/(ImagingFrequency*60));
            sp2act = logical(AllLateSpineBinarizedAligned(spinecombos(sc,2),:));
            sp2freq = numel(find(diff(sp2act)>0))/(length(sp2act)/(ImagingFrequency*60));
            coA = sp1act & sp2act;
            coAfreq = numel(find(diff(coA)>0))/(length(coA)/(ImagingFrequency*60));
            AllSpinesLateCoActiveRates{f}(sc) = coAfreq;
            AllSpinesLateCoActiveRatesGeoNormalized{f}(sc) = coAfreq./sqrt(sp1freq*sp2freq);
            AllInterSpineDistancesList{f}(sc) = AllDendriteDistances{f}(spinecombos(sc,1),spinecombos(sc,2));
        end
            
            
        % Next, find the coactivity rates of new spines with other spines,
        % also on the late sessions
        ns_count = 1;
        for ns = 1:length(NewSpines{f})
            NewSpineAllCoActiveRates{f}{ns} = nan(1, NumberofSpines);
            NewSpineAllCoActiveRatesNormalized{f}{ns} = nan(1, NumberofSpines);
            NewSpineAllCoActiveRatesGeoNormalized{f}{ns} = nan(1,NumberofSpines);
            ns_act = logical(AllLateSpineBinarizedAligned(NewSpines{f}(ns),:));
            NewSpineLateFrequency{f}(ns_count) = numel(find(diff(ns_act)>0))/(length(ns_act)/(ImagingFrequency*60));
            for allspines = setdiff(1:NumberofSpines, NewSpines{f})
                compspineact = logical(AllLateSpineBinarizedAligned(allspines,:));
                compspinefreq = numel(find(diff(compspineact)>0))/(length(compspineact)/(ImagingFrequency*60));
                coactivetrace = ns_act+compspineact; coactivetrace(coactivetrace<2) = 0;
                NewSpineAllCoActiveRates{f}{ns}(allspines) = numel(find(diff(coactivetrace)>0))/(length(coactivetrace)/(ImagingFrequency*60));
                NewSpineAllCoActiveRatesNormalized{f}{ns}(allspines) = NewSpineAllCoActiveRates{f}{ns}(allspines)./NewSpineLateFrequency{f}(ns_count);
                NewSpineAllCoActiveRatesGeoNormalized{f}{ns}(allspines) = NewSpineAllCoActiveRates{f}{ns}(allspines)./sqrt(NewSpineLateFrequency{f}(ns_count)*compspinefreq);
            end
            ns_count = ns_count+1;
        end
        
        % Next, find the coactivity rates of transient new spines found in
        % the middle session, as well as the comparable values for
        % sustained new spines
        if isThreeSessions
            AllTransientNewSpinesDistance{f}(1:length(transientNewSpines{f}),:) = AllDendriteDistances{f}(transientNewSpines{f},:);
            AllTransientNewSpinesMidCorr{f}(1:length(transientNewSpines{f}),:) = AllMidSpineCorrelations(transientNewSpines{f},:);
            for ts = 1:length(transientNewSpines{f})
                TransientSpineCoActiveRate{f}{ts} = nan(1,NumberofSpines);
                TransientSpineCoActiveRateNormalized{f}{ts} = nan(1,NumberofSpines);
                TransientSpineCoActiveRateGeoNormalized{f}{ts} = nan(1,NumberofSpines);
                ts_act = logical(AllMidSpineBinarizedAligned(transientNewSpines{f}(ts),:));
                TransientNewSpinesFrequency{f}(ts) = numel(find(diff(ts_act)>0))/(length(ts_act)/(ImagingFrequency*60));
                for allspines = setdiff(1:NumberofSpines, transientNewSpines{f})
                    compspineact = logical(AllMidSpineBinarizedAligned(allspines,:));
                    compspinefreq = numel(find(diff(compspineact)>0))/(length(compspineact)/(ImagingFrequency*60));
                    coactivetrace = ts_act & compspineact; 
                    TransientSpineCoActiveRate{f}{ts}(allspines) = numel(find(diff(coactivetrace)>0))/(length(coactivetrace)/(ImagingFrequency*60));
                    TransientSpineCoActiveRateNormalized{f}{ts}(allspines) = TransientSpineCoActiveRate{f}{ts}(allspines)./TransientNewSpinesFrequency{f}(ts);
                    TransientSpineCoActiveRateGeoNormalized{f}{ts}(allspines) = TransientSpineCoActiveRate{f}{ts}(allspines)./sqrt(TransientNewSpinesFrequency{f}(ts)*compspinefreq);
                end
            end
            ns_count = 1;
            for ns = 1:length(NewSpines{f})
                if ismember(NewSpines{f}(ns), MiddleSessionNewSpines{f})
                    NewSpineMidCoActiveRate{f}{ns} = nan(1, NumberofSpines);
                    NewSpineMidCoActiveRateNormalized{f}{ns} = nan(1, NumberofSpines);
                    NewSpineMidCoActiveRateGeoNormalized{f}{ns} = nan(1, NumberofSpines);
                    ns_act = logical(AllMidSpineBinarizedAligned(NewSpines{f}(ns),:));
                    NewSpineMidFrequency{f}(ns_count) = numel(find(diff(ns_act)>0))/(length(ns_act)/(ImagingFrequency*60));
                    for allspines = setdiff(1:NumberofSpines, union(NewSpines{f}, transientNewSpines{f}))
                        compspineact = logical(AllMidSpineBinarizedAligned(allspines,:));
                        compspinefreq = numel(find(diff(compspineact)>0))/(length(compspineact)/(ImagingFrequency*60));
                        coactivetrace = ns_act & compspineact; 
                        NewSpineMidCoActiveRate{f}{ns}(allspines) = numel(find(diff(coactivetrace)>0))/(length(coactivetrace)/(ImagingFrequency*60));
                        NewSpineMidCoActiveRateNormalized{f}{ns}(allspines) = NewSpineMidCoActiveRate{f}{ns}(allspines)./NewSpineMidFrequency{f}(ns_count);
                        NewSpineMidCoActiveRateGeoNormalized{f}{ns}(allspines) = NewSpineMidCoActiveRate{f}{ns}(allspines)./sqrt(NewSpineMidFrequency{f}(ns_count)*compspinefreq);
                    end
                    ns_count = ns_count+1;
                else
                end
            end
        end
        %==================================================================
        %% Analyze dendrites that show new spines
        if ~isempty(NewSpines{f})   %%% If there are new spines, characterize each
            CoActiveDuringMovement_Addresses = repmat({cell(1,length(NewSpines{f}))}, 1, length([75:5:90,90:98, 99:0.1:99.9])); %comp_CoActiveAddresses{f} = cell(1,length(NewSpines{f})); MoveOnlyAddresses{f} = cell(1,length(NewSpines{f})); NewOnlyAddresses{f} = cell(1,length(NewSpines{f})); MRSDM_CoActiveAddresses{f} = cell(1,length(NewSpines{f})); NSDM_CoActiveAddresses{f} = cell(1,length(NewSpines{f}));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% First, set the classification of any new spines
            switch AnalysisType
                case 'Subtract'
                    NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR+sum(FieldData{f}.StatClass{end}.DendSub_MovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatArePreSR = NumberofNewSpinesThatArePreSR+sum(FieldData{f}.StatClass{end}.PreSuccessSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreSR = NumberofNewSpinesThatAreSR+sum(FieldData{f}.StatClass{end}.DendSub_MovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreRR = NumberofNewSpinesThatAreRR+sum(FieldData{f}.StatClass{end}.RewardSpines(NewSpines{f}));
                    OtherMovementSpinesThatArentNew = setdiff(AllMovementSpinesOnLateSession,NewSpines{f});
                case 'Exclude'
                    NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR+sum(FieldData{f}.StatClass{end}.MovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatArePreSR = NumberofNewSpinesThatArePreSR+sum(FieldData{f}.StatClass{end}.PreSuccessSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreSR = NumberofNewSpinesThatAreSR+sum(FieldData{f}.StatClass{end}.MovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreRR = NumberofNewSpinesThatAreRR+sum(FieldData{f}.StatClass{end}.RewardSpines(NewSpines{f}));
                    OtherMovementSpinesThatArentNew = setdiff(AllMovementSpinesOnLateSession,NewSpines{f});
                case 'Ignore'
                    NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR+sum(FieldData{f}.StatClass{end}.OverallMovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatArePreSR = NumberofNewSpinesThatArePreSR+sum(FieldData{f}.StatClass{end}.OverallPreSuccessSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreSR = NumberofNewSpinesThatAreSR+sum(FieldData{f}.StatClass{end}.OverallMovementSpines(NewSpines{f}));
                    NumberofNewSpinesThatAreRR = NumberofNewSpinesThatAreRR+sum(FieldData{f}.StatClass{end}.OverallRewardSpines(NewSpines{f}));
                    OtherMovementSpinesThatArentNew = setdiff(AllMovementSpinesOnLateSession,NewSpines{f});
            end
            
            
            for emrs = 1:length(AllMovementSpinesOnEarlySession)
                [val, ~] = sort([NewSpines{f}(ns), AllMovementSpinesOnEarlySession(emrs)]);
                dist = AllDendriteDistances{f}(val(1),val(2));
                if dist <= clusterdistance
                    ClusteredEarlyMoveSpines{f} = [ClusteredEarlyMoveSpines{f},AllMovementSpinesOnEarlySession(emrs)];
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% ============================================================
            %%% Compare new spines to EARLY SESSION movement related spines

            %==============================================================
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(MovementSpinestoCompare)                           %%% NOTE: THIS SECTION ONLY CONSIDERS NEW SPINES THAT ARE ON THE SAME DENDRITES AS AT LEAST ONE MOVEMENT-RELATED SPINE; DO NOT CONFUSE THIS FOR ALL NEW SPINES !!!!
                %==========================================================
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for ns = 1:length(NewSpines{f})                             %%% FOR EACH NEW SPINE THAT IS ON A DENDRITE WITH AT LEAST ONE MOVEMENT RELATED SPINE
                    MovementswithClusteredCoActivitybyCluster{f}{ns}{1} = []; CorrelationofMovementswithCoActiveClusterActivitybyCluster{f}{ns}{1} = []; CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{f}{ns}{1} = []; CorrelationofMovementswithNSOnlyActivitybyCluster{f}{ns}{1} = []; %%% This ensures that the data type of new spines that DON'T have clusters stays consistent
                    ChanceRewardedLevel{f}{ns} = []; IsCoActiveMovementRewarded{f}{ns} = []; NumberofMovementswithClusterCoActivitybyCluster{f}{ns} = []; FractionofMovementswithClusterCoActivitybyCluster{f}{ns} = [];
                    MovementCorrelationwithMRSonlyActivitybyCluster{f}{ns}{1} = [];
                    MovementsEncodedbySeedlingMRS{f}{ns}{1} = [];
                    CorrelationofMovementswithCoActiveFMControlActivitybyCluster{f}{ns}{1} = [];
                    CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{f}{ns}{1} = [];
                    ClustCoActiveRate{f}{ns}{1} = []; ClustIntegratedCoactivity{f}{ns}{1} = []; FMcompCoActiveRate{f}{ns}{1} = []; MRSDMcompCoActiveRate{f}{ns}{1} = []; FractionofClustActivityDuringMovements{f}{ns}{1}= []; FractionofClustActivityDuringCRMovements{f}{ns}{1} = []; 
                    ClustActivityStartRelativetoMovement{f}{ns}{1} = [];ClustActivityStartNormalizedtoMovementLength{f}{ns}{1} = []; StandardDeviationofClustActivityOnset{f}{ns}{1} = []; StandardDeviationofNormClustActivityOnset{f}{ns}{1} = []; LeverPositionatClustActivityOnset{f}{ns}{1} = []; LeverVelocityatClustActivityOnset{f}{ns}{1} = []; LeverVelocityatRandomLagsfromOnset{f}{ns}{1} = []; MeanSpeedofActMovementPeriods{f}{ns}{1} = []; MeanSpeedofOtherMovementPeriods{f}{ns}{1} = []; LeverSlopeTraces{f}{ns}{1} = []; ShuffledClustActivityStart{f}{ns}{1} = []; ShuffledActivityStartNormalizedtoMovementLength{f}{ns}{1} = [];StandardDeviationofShuffledActivityOnset{f}{ns}{1} = [];StandardDeviationofNormShuffledActivityOnset{f}{ns}{1} = [];LeverPositionatShuffledActivityOnset{f}{ns}{1} = []; LeverVelocityatShuffledActivityOnset{f}{ns}{1} = []; ClustActivityStartHypothesisTest{f}{ns}{1} = []; FMActivityStartRelativetoMovement{f}{ns}{1} = []; MRSDMActivityStartRelativetoMovement{f}{ns}{1} = [];
                    MRSsClusteredwiththisNS = [];
                    binarycoactivetrace = [];
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%% Categorize New Spine based on when it was formed
                    if isThreeSessions %%% Only accurate when there is actually 3 sessions of data
                        if ismember(NewSpines{f}(ns), MiddleSessionNewSpines{f})
                            isNSMidorLate = 'Mid';
                        elseif ismember(NewSpines{f}(ns), LateSessionNewSpines{f})
                            isNSMidorLate = 'Late';
                        end
                    else
                        isNSMidorLate = 'Late';
                    end
                    
                    %%% Find all spine volume changes according to when the
                    %%% new spine formed (hypothesis: spines that showed
                    %%% LTP/enlarge compared to the session before NS
                    %%% formation give rise to NS formation 
                    
                    if isThreeSessions
                        switch isNSMidorLate
                            case 'Mid'
                                AllDeltaSpineVolume{f}{ns} = FieldData{f}.SpineVolumeData(:,2)/FieldData{f}.SpineVolumeData(:,1);
                            case 'Late'
                                AllDeltaSpineVolume{f}{ns} = FieldData{f}.SpineVolumeData(:,3)/FieldData{f}.SpineVolumeData(:,2);
                        end
                    else
                        AllDeltaSpineVolume{f}{ns} = FieldData{f}.SpineVolumeData(:,2)/FieldData{f}.SpineVolumeData(:,1);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch AnalysisType
                        case 'Subtract'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSpineActivity(', num2str(NewSpines{f}(ns)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                        case 'Exclude'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpines{f}(ns)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                            NewSpineActivityAligned = NewSpineActivityAligned.*NewSpineBinarizedAligned;
                        case 'Ignore'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.OverallSpineActivity(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpines{f}(ns)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.BinarizedOverallSpineData(', num2str(NewSpines{f}(ns)), ',:);'])
                    end
                    %%%
                    NewSpineBinarizedAligned = PreserveActivityAmplitude(NewSpineActivityAligned, NewSpineBinarizedAligned);
                    %%%
                    NewSpineActivityAligned(isnan(NewSpineActivityAligned)) = 0;
                    NewSpineBinarizedAligned(isnan(NewSpineBinarizedAligned)) = 0;
                    
                    NZNSAct = NewSpineActivityAligned;
                    NZNSAct(NZNSAct<=0) = 0;
                    NSactbounds = find(diff([Inf,NewSpineBinarizedAligned,Inf]));
                    NSdivbyNS = mat2cell(NewSpineBinarizedAligned', diff(NSactbounds));

                    
                    AllChosenMRSPairActivity = zeros(1,length(NewSpineBinarizedAligned));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Initialize temporary/counting variables for each
                    %%% new spine 
                    NewSpinestoEarlyMovementSpines = NaN;
                    NewSpinesEarlyMovementSpinesLateCorr = NaN;
                    NewSpinesCorrwithCloseEarlyMRS = NaN;
                    cMRS_SpineVolume = nan; cMRS_DeltaFrequency = nan; cMRS_DeltaAmplitude = nan;
                    DistanceMatchedtoMRSControlCorr = NaN;
                    DistMatchedtoNSPartnersCorr = NaN;
                    FreqMatchedControlCorr = NaN;
                    NewSpinestoShuffledEarlyMovementSpines = NaN;
                    DendCorrNewSpineOnly = NaN;
                    DendCorrMoveSpineOnly = NaN;
                    DendCorrCoactiveCluster = NaN;
                    clustcoAtraces = zeros(1,length(cuetraceLate));
                    MoveSpineOnlywithMovement = NaN; MoveSpineOnlywithSuccess = NaN;
                    NewSpineOnlywithMovement = NaN; NewSpineOnlywithSuccess = NaN;
                    CoactiveClusterwithMovement = NaN; CoactiveClusterwithSuccess = NaN;
                    move_centric_cluster_correlation = NaN; MoveCentricFreqMatchedCorrelation = NaN; MoveCentricDistMatchedCorrelation = NaN; MoveCentricDistMatchedCorrelationforMRS = NaN; failure_centric_cluster_correlation = NaN;
                    combined_activity_move_corr = NaN;combined_activity_success_corr = NaN;
                    clustermovementreliability = NaN; clustersuccessreliability = NaN; controlpairmovereliability = NaN; controlpairsuccreliability = NaN;
                    MRSOnlyMovementCorr = NaN; DotProdofNSOnlyActivePeriodswithMovement = NaN; 
                    DotProdofCoActivePeriodswithMovement = NaN; DotProdofFreqCompCoActivePeriodswithMovement = NaN; DotProdofNSDMCoActivePeriodswithMovement = NaN; DotProdofMRSDMCoActivePeriodswithMovement = NaN; DotProdofMRSOnlyCoActivePeriodswithMovement = NaN;
                    DotProdofCoActivePeriodswithCRMovement = NaN; DotProductofCompCoActivePeriodswithCRMovement = NaN; ChanceCompCoActiveCRMovementOverlap = NaN;
                    DotProdofCoActivePeriodswithoutMovement = NaN;
                    Chosen_Addresses = NaN;
                    ChanceCoActiveCRMovementOverlap = NaN; ChanceCoActiveMovementOverlap= NaN;ChanceFreqMatchedCoActivitywithMovement = NaN; ChanceNSDMCoActivitywithMovement = NaN;ChanceMRSDMCoActivitywithMovement = NaN;ChanceMRSOnlyoActivitywithMovement = NaN;
                    count = 1;
                    closecount = 1;
                    controlcount = 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Vouch to use only MR dends !!!!!
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines{f}(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                    if FilterforMovementDends
                        if ~ismember(ParentDend, find(FieldData{f}.StatClass{end}.MovementDends))
                            continue
                        end
                    else
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for ms = 1:length(MovementSpinestoCompare)  %%% FOR ALL MOVEMENT RELATED SPINES THAT FIT THE ABOVE CRITERIA (i.e. THOSE THAT ARE ON A DENDRITE WITH NEW SPINES)
                        if ismember(MovementSpinestoCompare(ms), ElimSpines{f})
                            continue
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%% Choose to filter for persistent movement
                        %%%% related spines!
                        if FilterforPersistentMRSs
                            if ~ismember(AllMovementSpinesOnEarlySession(ms), AllMovementSpinesOnLateSession)
                                continue
                            end
                        else
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        switch AnalysisType
                            case 'Subtract'
                                eval(['MoveSpineEarlyActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineEarlyBinarizedAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.DendSubSynapseOnlyBinarized(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                            case 'Exclude'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.ProcessedSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.SynapseOnlyBinarized(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                MoveSpineActivityAligned = MoveSpineActivityAligned.*MoveSpineBinarizedAligned; %% Convert to a floored signal to at least preserve amplitude
                            case 'Ignore'
                                eval(['MoveSpineEarlyActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.BinarizedOverallSpineData(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineEarlyBinarizedAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.BinarizedOverallSpineData(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.ProcessedSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.BinarizedOverallSpineData(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                        end
                        %%%
                        MoveSpineEarlyBinarizedAligned = PreserveActivityAmplitude(MoveSpineEarlyActivityAligned, MoveSpineEarlyBinarizedAligned);
                        MoveSpineBinarizedAligned = PreserveActivityAmplitude(MoveSpineActivityAligned, MoveSpineBinarizedAligned);
                        %%%
                        MoveSpineBinarizedAligned(isnan(MoveSpineBinarizedAligned)) = 0;
                        MoveSpineActivityAligned(isnan(MoveSpineActivityAligned)) = 0;
                        
                        NZMRSAct = MoveSpineActivityAligned; 
                        NZMRSAct(NZMRSAct<0)= 0;
                        AllOtherSpineBinarizedAligned(isnan(AllOtherSpineBinarizedAligned)) = 0;
                        AllOtherSpineActivityAligned(isnan(AllOtherSpineActivityAligned)) = 0;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%% Find exclusive versions of each activity bouts
                        %%% (i.e. specifically NOT co-activity)
                        
                        MoveSpineBinarizedAligned(MoveSpineBinarizedAligned~=0) = 1;
                        MoveSpineActivity_Boundaries = find(diff([Inf,MoveSpineBinarizedAligned,Inf])~=0);
                        MoveSpineActivity_Separated = mat2cell(MoveSpineBinarizedAligned', diff(MoveSpineActivity_Boundaries));
                        AllNSActivity_Separated_byMRSAct = mat2cell(NewSpineBinarizedAligned', diff(MoveSpineActivity_Boundaries));
                        MoveSpineActivity_Separated(cellfun(@(x,y) any(x)&any(y), MoveSpineActivity_Separated,AllNSActivity_Separated_byMRSAct)) = cellfun(@(x) zeros(length(x),1), MoveSpineActivity_Separated(cellfun(@(x,y) any(x)&any(y), MoveSpineActivity_Separated,AllNSActivity_Separated_byMRSAct)), 'uni', false);
                        %======================================================
                        MoveSpineActivityWithoutNewSpineActivity = cell2mat(MoveSpineActivity_Separated)';
                        %%%
                        MoveSpineActivityWithoutNewSpineActivity = PreserveActivityAmplitude(MoveSpineActivityAligned, MoveSpineActivityWithoutNewSpineActivity);
                        
                        %%% Fraction of MRS only activity occurring during
                        %%% movements
                        movements_separated_byMRSAct = mat2cell(binarizedleverLate, diff(MoveSpineActivity_Boundaries));
                        MRS_with_movement = cellfun(@(x,y) any(x)&any(y), MoveSpineActivity_Separated, movements_separated_byMRSAct);
                        Total_MRS_ActBouts = cellfun(@any, MoveSpineActivity_Separated);
                        %                     NS_with_movement = NS_activity_to_use+binarizedleverLate';
                        %                     NS_with_movement(NS_with_movement~=2) = 0; NS_with_movement(NS_with_movement~=0) = 1;
                        FractionofMRSActivityDuringMovements{f}{ns}(ms) = sum(MRS_with_movement)/sum(Total_MRS_ActBouts);

                                                
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        bothactivity = logical(NewSpineBinarizedAligned+MoveSpineBinarizedAligned);
                        [val, ~] = sort([NewSpines{f}(ns), MovementSpinestoCompare(ms)]);
                        NewSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        NewSpinesEarlyMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));   %%% Find the correlation of new spines with the movement spines from early sessions (they might not be movement-related at the late sessions, but are they highly correlated with the new spine?)                        
                         
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%% Movements encoded by seedling MRSs (those
                        %%% that give rise to clusters)
                        OtherVariables.TimingValues = TimingValues;
                        OtherVariables.ImagingFrequency = ImagingFrequency;
                        OtherVariables.IsMovementRewarded = IsMovementRewardedEarly{f};
                        OtherVariables.ModelMovement = ModelMovement;
                        OtherVariables.LearningPhase = 'Early';
                        OtherVariables.Focus = FocusOnWhichMovements;
                        OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                        OtherVariables.IsCluster = 0;
                        OtherVariables.DoShuffling = 0;
                        
                        [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(MoveSpineEarlyBinarizedAligned, MovementBlocks, OtherVariables);
                        framesofinterest = frames_during_targetperiodsEarly(MovementInfo.ActivityDuringMovement_Addresses);
                        if ~isempty(framesofinterest)
                            [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverEarly,framesofinterest ,[], rewardperiodsEarly, TimingValues, ImagingFrequency);
                        else
                            ExtractedTraces = [];
                        end
                        MovementsEncodedbySeedlingMRS{f}{ns}{ms} = ExtractedTraces;
                        % =======================================================================================================================================================================================================
                        %==================================================
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%% Clustering Section 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %==================================================
                        % =======================================================================================================================================================================================================
                        if NewSpinestoEarlyMovementSpines(1,count) <= clusterdistance
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% First, count spines that meet criteria %%%%
                            
                            ClusteredNewSpines{f} = [ClusteredNewSpines{f}, NewSpines{f}(ns)];
                            MRSsClusteredwiththisNS = [MRSsClusteredwiththisNS, MovementSpinestoCompare(ms)];
                            if ismember(MovementSpinestoCompare(ms), AllMovementSpinesOnLateSession) && ismember(MovementSpinestoCompare(ms), EarlierSessionMovementSpines)&& ~ismember(MovementSpinestoCompare(ms),countedpersistentMRSs)
                                countedpersistentMRSs = [countedpersistentMRSs; MovementSpinestoCompare(ms)];
                                persistentclustercount = persistentclustercount+1;
                            end
                            NewSpinesCorrwithCloseEarlyMRS(1,closecount) = NewSpinesEarlyMovementSpinesLateCorr(1,count);
                            IsHighlyCorrelatedCluster = NewSpinesCorrwithCloseEarlyMRS(1,closecount)>=cutoff_of_highcorr_cluster;
                            if IsHighlyCorrelatedCluster
                                if use_dFoF_not_binarized
                                    AllChosenMRSPairActivity = [AllChosenMRSPairActivity; MoveSpineActivityAligned>mindFoFtoconsiderCoActive];
                                else
                                    AllChosenMRSPairActivity = [AllChosenMRSPairActivity; MoveSpineBinarizedAligned];
                                end
                            else
%                                 AllHighCorrClusterMRSActivity = [AllHighCorrClusterMRSActivity; zeros(1,length(MoveSpineBinarizedAligned))];
                                AllChosenMRSPairActivity = [AllChosenMRSPairActivity; MoveSpineBinarizedAligned]; %%% Note: currently not filtering for high correlation, so this should just use ANY MRS activity;
                            end
                            
                            
                            %==============================================
                            %%% Find Plasticity Features for the Clustered
                            %%% Movement-Related Spine

                            if isThreeSessions
                                switch isNSMidorLate
                                    case 'Mid'
                                        if ~ismember(MovementSpinestoCompare(ms), MiddleSessionNewSpines{f}) %%% If the MRS is also a NS, spine volume calculations don't make sense
                                            cMRS_SpineVolume(closecount) = FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),2)/FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),1);
                                            cMRS_PreFreq = FieldData{f}.CalciumData{1}.Frequency(MovementSpinestoCompare(ms));
                                            cMRS_PostFreq = FieldData{f}.CalciumData{2}.Frequency(MovementSpinestoCompare(ms));
                                            cMRS_DeltaFrequency(closecount) = cMRS_PostFreq./cMRS_PreFreq;
                                            cMRS_PreAmp = FieldData{f}.CalciumData{1}.MeanEventAmp(MovementSpinestoCompare(ms));
                                            cMRS_PostAmp = FieldData{f}.CalciumData{end}.MeanEventAmp(MovementSpinestoCompare(ms));
                                            cMRS_DeltaAmplitude(closecount) = cMRS_PostAmp./cMRS_PreAmp;
                                        else
                                            cMRS_SpineVolume(closecount) = nan;
                                            cMRS_DeltaFrequency(closecount) = nan;
                                            cMRS_DeltaAmplitude(closecount) = nan;
                                        end
                                    case 'Late'
                                        if ~ismember(MovementSpinestoCompare(ms), LateSessionNewSpines{f}) %%% If the MRS is also a NS, spine volume calculations don't make sense
                                            if FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),2)==0   %%% In some cases, the middle session version of the spine might be obscured, e.g., not allowing volume calcuation... so use first session instead
                                                comp_sesh = 1;
                                            else
                                                comp_sesh = 2;
                                            end
                                            cMRS_SpineVolume(closecount) = FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),3)/FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),comp_sesh);
                                            cMRS_PreFreq = FieldData{f}.CalciumData{2}.Frequency(MovementSpinestoCompare(ms));
                                            cMRS_PostFreq = FieldData{f}.CalciumData{3}.Frequency(MovementSpinestoCompare(ms));
                                            cMRS_DeltaFrequency(closecount) = cMRS_PostFreq./cMRS_PreFreq;
                                            cMRS_PreAmp = FieldData{f}.CalciumData{2}.MeanEventAmp(MovementSpinestoCompare(ms));
                                            cMRS_PostAmp = FieldData{f}.CalciumData{end}.MeanEventAmp(MovementSpinestoCompare(ms));
                                            cMRS_DeltaAmplitude(closecount) = cMRS_PostAmp./cMRS_PreAmp;
                                        else
                                            cMRS_SpineVolume(closecount) = nan;
                                            cMRS_DeltaFrequency(closecount) = nan;
                                            cMRS_DeltaAmplitude(closecount) = nan;
                                        end
                                end
                            else
                                if ~ismember(MovementSpinestoCompare(ms), LateSessionNewSpines{f}) %%% If the MRS is also a NS, spine volume calculations don't make sense
                                    cMRS_SpineVolume(closecount) = FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),2)/FieldData{f}.SpineVolumeData(MovementSpinestoCompare(ms),1);
                                    cMRS_PreFreq = FieldData{f}.CalciumData{1}.Frequency(MovementSpinestoCompare(ms));
                                    cMRS_PostFreq = FieldData{f}.CalciumData{end}.Frequency(MovementSpinestoCompare(ms));
                                    cMRS_DeltaFrequency(closecount) = cMRS_PostFreq./cMRS_PreFreq;
                                    cMRS_PreAmp = FieldData{f}.CalciumData{1}.MeanEventAmp(MovementSpinestoCompare(ms));
                                    cMRS_PostAmp = FieldData{f}.CalciumData{end}.MeanEventAmp(MovementSpinestoCompare(ms));
                                    cMRS_DeltaAmplitude(closecount) = cMRS_PostAmp./cMRS_PreAmp;
                                else
                                    cMRS_SpineVolume(closecount) = nan;
                                    cMRS_DeltaFrequency(closecount) = nan;
                                    cMRS_DeltaAmplitude(closecount) = nan;
                                end
                            end

                            if ismember(MovementSpinestoCompare(ms), ElimSpines{f}) 
                                cMRS_SpineVolume(closecount) = NaN;
                                cMRS_DeltaFrequency(closecount) = nan;
                                cMRS_DeltaAmplitude(closecount) = nan;
                            end
                            
                            %==============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Compare Activity of Clustered (both new and
                            %%% MRS) Spines with Dendrite
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            
                            switch AnalysisType
                                case 'Subtract'
                                    MoveSpineActivity = FieldData{f}.CalciumData{end}.Processed_dFoF_DendriteSubtracted(MovementSpinestoCompare(ms),:);
                                case 'Exclude'
                                    MoveSpineActivity = FieldData{f}.CalciumData{end}.Processed_dFoF(MovementSpinestoCompare(ms),:).*FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(MovementSpinestoCompare(ms),:);
                                case 'Ignore'
                                    MoveSpineActivity = FieldData{f}.CalciumData{end}.Processed_dFoF(MovementSpinestoCompare(ms),:);
                            end
                            MoveSpineActivity(isnan(MoveSpineActivity)) = 0;
                            CoActiveCluster = (NewSpineActivity + MoveSpineActivity);

                            DendAct = FieldData{f}.CalciumData{end}.Dendrite_Binarized(ParentDend,:);
                            temp = corrcoef([NewSpineActivity', DendAct']);
                            DendCorrNewSpineOnly(1,closecount) = temp(1,2);
                            temp = corrcoef([MoveSpineActivity', DendAct']);
                            DendCorrMoveSpineOnly(1,closecount) = temp(1,2);
                            temp = corrcoef([CoActiveCluster', DendAct']);
                            DendCorrCoactiveCluster(1,closecount) = temp(1,2);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Compare coactive clusters with movement
                            %%%% Make sure to use activity traces
                            %%%% consistent with the rest of the data being
                            %%%% used!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            analogcoactivetrace = NZNSAct.*NZMRSAct;
                            binarycoactivetrace = double(logical(MoveSpineBinarizedAligned.*NewSpineBinarizedAligned));
%                             if use_dFoF_not_binarized
%                                 %%%% Leave the following commented out
%                                 %%%% unless you want to optimize the
%                                 %%%% threshold and window parameters for
%                                 %%%% finding high corr periods
% %                                 wcount = 1;
% %                                 CoA_diff = [];
% %                                 windowcycle = 2:20;
% %                                 threshcycle = 0.25:0.1:0.75;
% %                                 for w = windowcycle
% %                                     tcount = 1;
% %                                     for t = threshcycle
% %                                         highcorrwindows = FindHighCorrRegions(MoveSpineActivityAligned, NewSpineActivityAligned, ImagingFrequency,w, t);
% %                                         CoA = coactivetrace | highcorrwindows';
% %                                         move_activity = CoA*binarizedleverLate;
% %                                         shuff_activity = nanmedian(CoA*shuffledmovetraces);
% %                                         CoA_diff(wcount, tcount) = move_activity-shuff_activity;
% %                                         tcount = tcount+1;
% %                                     end
% %                                     wcount = wcount+1;
% %                                 end
% %                                 CoActivityDifferenceOptimizationCurve{optimcount} = CoA_diff;
% %                                 optimcount = optimcount+1;
% %                                 [~, Idx] = max(CoA_diff(:));
% %                                 [Zmaxcol, Zmaxrow] = ind2sub(size(CoA_diff), Idx);
% %                                 window = windowcycle(Zmaxcol); corr_thresh = threshcycle(Zmaxrow);
%                                 %%%
%                                 window = 6; corr_thresh = 0.25; %%% Values taken from the median values used to optimize the difference between movement activity and shuffled activity
%                                 highcorrwindows = FindHighCorrRegions(MoveSpineActivityAligned, NewSpineActivityAligned, ImagingFrequency,window, corr_thresh);
%                                 binarycoactivetrace = binarycoactivetrace | highcorrwindows';
%                             end
                            clustcoAtraces(closecount,:) = binarycoactivetrace;
                            moveonly = corrcoef([binarizedleverLate, MoveSpineActivityWithoutNewSpineActivity']);
                            coactive = corrcoef([binarizedleverLate, binarycoactivetrace']);
                            MoveSpineOnlywithMovement(1,closecount) = moveonly(1,2);
                            CoactiveClusterwithMovement(1,closecount) = coactive(1,2);
                            %%%
                            %%%
                            moveonly = corrcoef([successtraceLate, MoveSpineActivityAligned']);
                            coactive = corrcoef([successtraceLate, binarycoactivetrace']);
                            MoveSpineOnlywithSuccess(1,closecount) = moveonly(1,2);
                            CoactiveClusterwithSuccess(1,closecount) = coactive(1,2);
                            
                            %% ============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        %%%"NOISE CORRELATION"%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            switch FocusOnWhichMovements
                                case 'Rewarded'
                                    target_movements_trace = successtraceLate;
                                case 'All'
                                    target_movements_trace = binarizedleverLate;
                                case 'CuedRewarded'
                                    target_movements_trace = CRMovementsTraceLate;
                            end
                            if use_dFoF_not_binarized
                                move_centric_newspineactivity = NewSpineActivityAligned(:,cell2mat(frames_during_targetperiods));
                                move_centric_movespineactivity = MoveSpineActivityAligned(:,cell2mat(frames_during_targetperiods));
                            else
                                move_centric_newspineactivity = NewSpineBinarizedAligned.*binarizedleverLate';
                                move_centric_movespineactivity = MoveSpineBinarizedAligned.*binarizedleverLate';
                            end
                            move_centric_correlations = corrcoef([move_centric_newspineactivity', move_centric_movespineactivity']);
                            move_centric_cluster_correlation(1,closecount) = move_centric_correlations(1,2);
                            
                            if move_centric_cluster_correlation(1,closecount) > cutoff_of_highcorr_cluster
                                disp(['Animal ', currentanimal, ', Field ', num2str(f), ' clustered spines ', num2str(NewSpines{f}(ns)), ' & ', num2str(MovementSpinestoCompare(ms)), ' have high noise correlation!'])
                            end
                            %%%
                            failure_centric_newspineactivity = NewSpineActivityAligned.*failuretraceLate';
                            failure_centric_movespineactivity = MoveSpineActivityAligned.*failuretraceLate';
                            failure_centric_correlations = corrcoef([failure_centric_newspineactivity', failure_centric_movespineactivity']);
                            failure_centric_cluster_correlation(1,closecount) = failure_centric_correlations(1,2);
                            
                            %==============================================
                            %==============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the analogous features of the movement
                            %%% spine with another nearby spine (as a control
                            %%% for the clustered new spine)
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            
                            DistanceMatchedPartners = find(AllDendriteDistances{f}(MovementSpinestoCompare(ms), :)<=clusterdistance);
                            DistanceMatchedNonNewPartners = setdiff(DistanceMatchedPartners, union(MovementSpinestoCompare, NewSpines{f}));
                            comparisonspinestouse = DistanceMatchedNonNewPartners;
                            switch AnalysisType
                                case 'Subtract'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(comparisonspinestouse), '],:);'])
                                case 'Exclude'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(comparisonspinestouse), '],:);'])
                                    DistanceMatchedActivity = DistanceMatchedActivity.*DistanceMatchedBinarized;
                                case 'Ignore'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.BinarizedOverallSpineData([', num2str(comparisonspinestouse), '],:);'])
                            end
                            %%% Preserve amp. from binary traces
                            DistanceMatchedBinarized = PreserveActivityAmplitude(DistanceMatchedActivity, DistanceMatchedBinarized);
                            %%%
                            DistanceMatchedActivity(isnan(DistanceMatchedActivity)) = 0;
                            DistanceMatchedBinarized(isnan(DistanceMatchedBinarized)) = 0;
                            
                            NZDMdata = DistanceMatchedActivity; NZDMdata(NZDMdata<0) =0;
                            analogMRSDistMatchedcoactivity = repmat(NZMRSAct,length(comparisonspinestouse),1).*NZDMdata;
                            binaryMRSDistMatchedcoactivity = repmat(MoveSpineBinarizedAligned,length(comparisonspinestouse),1).*DistanceMatchedBinarized;
                            if use_dFoF_not_binarized
                                move_centric_distmatched_activity = DistanceMatchedActivity(:,cell2mat(frames_during_targetperiods));
                            else
                                move_centric_distmatched_activity = DistanceMatchedBinarized.*binarizedleverLate';
                            end
                            controlgroupedactivity = logical(MoveSpineBinarizedAligned+DistanceMatchedBinarized);
                            controlgroupedactivity_Moveseparated =  mat2cell(controlgroupedactivity', diff(boundMLate));
                            controlgroupedactivity_Succseparated =  mat2cell(controlgroupedactivity', diff(boundSLate));  
                            controlgroupedactivity_moveperiods = controlgroupedactivity_Moveseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsMLate, 'uni', false)));
                            controlgroupedactivity_succperiods = controlgroupedactivity_Succseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsSLate, 'uni', false)));
                            
                            if ~isempty(comparisonspinestouse)
                                for shf = 1:100
                                    pseudo_partners = comparisonspinestouse(randi(length(comparisonspinestouse),1,2));
                                    corr_samples(shf) = nanmax(AllLateSpineCorrelations(NewSpines{f}(ns), pseudo_partners));
                                end
                                DistanceMatchedtoMRSControlCorr(1,closecount) = nanmedian(corr_samples);
                            else
                                DistanceMatchedtoMRSControlCorr(1,closecount) = NaN;
                            end
                            DistanceMatchedActivity(isnan(DistanceMatchedActivity)) = 0;
                            
                            if isempty(move_centric_movespineactivity) || isempty(move_centric_distmatched_activity)
                                move_centric_distmatched_correlation = NaN;
                            else
                                move_centric_distmatched_correlation = corrcoef([move_centric_movespineactivity', move_centric_distmatched_activity']); 
                            end
                            MoveCentricDistMatchedCorrelationforMRS(1,closecount) = nanmedian(move_centric_distmatched_correlation(1,2:end));

                            %==============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the analogous features for
                            %%% frequency-matched spine pairs
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            
                            OtherSpFreq = [];
                            for spf = 1:size(AllOtherSpineActivityAligned,1)
                                OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineBinarizedAligned(spf,:))>0))/(length(AllOtherSpineBinarizedAligned)/(ImagingFrequency*60));
                            end
                            NewSpFreq = numel(find(diff(NewSpineBinarizedAligned))>0)/(length(NewSpineBinarizedAligned)/(ImagingFrequency*60));
                                [~, CompSpFreqMatchedtoNS] = nanmin(abs(OtherSpFreq-NewSpFreq));
                                OtherSpFreq(CompSpFreqMatchedtoNS) = NaN;
                            CMRSFreq = numel(find(diff(MoveSpineBinarizedAligned))>0)/(length(MoveSpineBinarizedAligned)/(ImagingFrequency*60));   %%% Clustered MRS frequency
                                [~, CompSpFreqMatchedtoCMRS] = nanmin(abs(OtherSpFreq-CMRSFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                            NZotherspinedata = AllOtherSpineActivityAligned;
                            NZotherspinedata(NZotherspinedata<0) = 0;
                            analogcomp_coactivetrace =  NZotherspinedata(CompSpFreqMatchedtoNS,:).*NZotherspinedata(CompSpFreqMatchedtoCMRS,:);
                            binarycomp_coactivetrace = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoNS,:).*AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoCMRS,:);
                            
                            if ~isempty(AllOtherSpines)
                                FreqMatchedControlCorr(1,closecount) = nanmax(AllLateSpineCorrelations(AllOtherSpines(CompSpFreqMatchedtoNS),AllOtherSpines(CompSpFreqMatchedtoCMRS))); %%% Remember that the "other spine" labels are found wrt the list of other spines, not their numbers according to the whole population
                            else
                                FreqMatchedControlCorr(1,closecount) = NaN;
                            end
                            
                            if use_dFoF_not_binarized
%                                 highcorrwindows = FindHighCorrRegions(AllOtherSpineActivityAligned(CompSpFreqMatchedtoNS,:), AllOtherSpineActivityAligned(CompSpFreqMatchedtoCMRS,:), ImagingFrequency,window, corr_thresh);
%                                 binarycomp_coactivetrace = binarycomp_coactivetrace | highcorrwindows';
                                move_centric_NSfreqmatched_activity = AllOtherSpineActivityAligned(CompSpFreqMatchedtoNS,cell2mat(frames_during_targetperiods));
                                move_centric_MRSfreqmatched_activity = AllOtherSpineActivityAligned(CompSpFreqMatchedtoCMRS,cell2mat(frames_during_targetperiods));
                            else
                                move_centric_NSfreqmatched_activity = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoNS,:).*binarizedleverLate';
                                move_centric_MRSfreqmatched_activity = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoCMRS,:).*binarizedleverLate';
                            end
                            %if ~ismember(CompSpFreqMatchedtoCMRS, usedforCMRSFreqComp)
                            if ~isempty(AllOtherSpines)
                                move_centric_freqmatched_correlation = corrcoef([move_centric_NSfreqmatched_activity', move_centric_MRSfreqmatched_activity']);
                                MoveCentricFreqMatchedCorrelation(1,closecount) = nanmedian(move_centric_freqmatched_correlation(1,2));
                                usedforCMRSFreqComp = [usedforCMRSFreqComp, CompSpFreqMatchedtoCMRS];
                            else
                                MoveCentricFreqMatchedCorrelation(1,closecount) = NaN;
                            end
                            
                            %else
                            %    MoveCentricFreqMatchedCorrelation(1,closecount) = NaN;
                            %end
                            
                            %% ============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                  %%% Shared Movement Reliability %%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            
                            combinedcorr = corrcoef([binarizedleverLate, bothactivity']);
                            combined_activity_move_corr(1,closecount) = combinedcorr(1,2);
                            combinedcorr = corrcoef([successtraceLate,bothactivity']);
                            combined_activity_success_corr(1,closecount) = combinedcorr(1,2);
                            bothspineactivity_Moveseparated = mat2cell(bothactivity', diff(boundMLate));
                            bothspineactivity_Succseparated = mat2cell(bothactivity', diff(boundstouseLate));
                            bothspineactivity_moveperiods = bothspineactivity_Moveseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsMLate, 'uni', false)));
                            numberofmovementswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), moveperiodsLate, bothspineactivity_moveperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine pair
                            clustermovementreliability(1,closecount) = numberofmovementswithclusteractivity/length(moveperiodsLate);
                            bothspineactivity_successperiods = bothspineactivity_Succseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocksLate, 'uni', false)));
                            numberofsuccesseswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), targetperiodsLate, bothspineactivity_successperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
                            clustersuccessreliability(1,closecount) = numberofsuccesseswithclusteractivity/length(targetperiodsLate);
                            
                            for cs = 1:length(DistanceMatchedNonNewPartners)
                                controlpairmovereliability(1,controlcount) = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y(:,cs))>1), moveperiodsLate, controlgroupedactivity_moveperiods, 'uni', false)))))/length(moveperiodsLate);
                                controlpairsuccreliability(1,controlcount) = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y(:,cs))>1), successperiodsLate, controlgroupedactivity_succperiods, 'uni', false)))))/length(successperiodsLate);
                                controlcount = controlcount+1;
                            end
                            %%
                            %==============================================
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                      %%% MOVEMENT STEREOTYPY %%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================
                            OtherVariables.TimingValues = TimingValues;
                            OtherVariables.ImagingFrequency = ImagingFrequency;
                            OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                            OtherVariables.ModelMovement = ModelMovement;
                            OtherVariables.LearningPhase = 'Late';
                            OtherVariables.Focus = FocusOnWhichMovements;
                            OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                            OtherVariables.IsCluster = 1;
                            OtherVariables.DoShuffling = 0;
                            
                            %==============================================

                            modelcorrvalues = [];
                            movcorrvalues = [];
                            compcorrvalues = [];
                            prct_count = 1;
                            if ~lower_thresh_for_coact
                                savethisone = 100;
                            else
                                savethisone = chosen_prct;
                            end
                            for p = prctvals
                                if p == 100
                                    chosenbinarycoactivetrace = binarycoactivetrace;
                                else
                                    switch useSDorPRCT
                                        case 'PRCT'
                                            coactivethresh(prct_count) = prctile(analogcoactivetrace, p);
                                        case 'SD'
                                            coactivethresh(prct_count) = p*std(analogcoactivetrace);
                                    end
%                                     threshtouse = min(coactivethresh(prct_count), staticthresh(prct_count));
                                    if use_dFoF_not_binarized
                                        threshtouse = coactivethresh(prct_count);
    %                                     contingA = analogcoactivetrace>coactivethresh(prct_count);
                                        contingA = analogcoactivetrace>threshtouse;
                                        contingB = NewSpineActivityAligned>mindFoFtoconsiderCoActive;
                                        contingC = MoveSpineActivityAligned>mindFoFtoconsiderCoActive;
                                        chosenbinarycoactivetrace = (contingA & contingB & contingC) | binarycoactivetrace;
                                    else
                                        chosenbinarycoactivetrace = binarycoactivetrace;
                                    end
                                end
%                                 newbinarycoactivetrace = (analogcoactivetrace>staticthresh) | binarycoactivetrace;
                                if p == savethisone
                                    OtherVariables.DoShuffling = 1;
                                else
                                    OtherVariables.DoShuffling = 0;
                                end
                                [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(chosenbinarycoactivetrace, MovementBlocks, OtherVariables);
                                framesofinterest = frames_during_targetperiods(MovementInfo.ActivityDuringMovement_Addresses);
                                if ~isempty(framesofinterest)
                                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,chosenbinarycoactivetrace, rewardperiodsLate, TimingValues, ImagingFrequency);
                                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    CoAMC = thissessionmovementcorr(:); 
                                    CoAMCwMM = movementcorr(end,:);
                                else
                                    ExtractedTraces = [];
                                    CoAMC = [];
                                    CoAMCwMM = [];
                                end
                                CoActiveDuringMovement_Addresses{prct_count}{ns}{closecount} = MovementInfo.ActivityDuringMovement_Addresses;
                                if p == savethisone
                                    thiscluster_moveaddresses = MovementInfo.ActivityDuringMovement_Addresses;
                                    Chosen_Addresses = MovementInfo.ActivityDuringMovement_Addresses;
                                    Chosen_ExcludedFraction = MovementInfo.FractionMovementswithActivityAfterWindow;
                                    if ~isempty(Chosen_Addresses)
                                        disp([num2str(Chosen_ExcludedFraction*100), '% of movements had activity outside target window'])
                                    end
                                    Chosen_ChanceLevel = MovementInfo.ChanceReward;
                                    Chosen_Reward_Outcome = MovementInfo.IsSpecifiedMovementRewarded;
                                    ChosenExtractedTraces = ExtractedTraces;
                                    CoActiveMovementCorr = CoAMC;
                                    CoActiveMovementCorrwithModelMovement = CoAMCwMM;
                                    %======================================
                                    ClustCoActiveRate{f}{ns}{closecount} = numel(find(diff(chosenbinarycoactivetrace)>0))/(length(chosenbinarycoactivetrace)/(ImagingFrequency*60));
                                    ClustIntegratedCoactivity{f}{ns}{closecount} = sum(chosenbinarycoactivetrace)/length(chosenbinarycoactivetrace);
                                    %======================================
                                    ClustActBoundaries = find(diff([~chosenbinarycoactivetrace(1),chosenbinarycoactivetrace,~chosenbinarycoactivetrace(end)])~=0);
                                    ClustAct_Separated = mat2cell(chosenbinarycoactivetrace', diff(ClustActBoundaries));
                                    movements_separated_byCoAct = mat2cell(binarizedleverLate, diff(ClustActBoundaries));
                                    CR_movements_separated_byCoAct = mat2cell(CRMovementsTraceLate, diff(ClustActBoundaries));
%                                     Clust_with_Movement = chosenbinarycoactivetrace+binarizedleverLate'; Clust_with_Movement(Clust_with_Movement~=2) = 0; Clust_with_Movement(Clust_with_Movement~=0) = 1;
                                    Clust_with_Movement = cellfun(@(x,y) any(x) & any(y), ClustAct_Separated,movements_separated_byCoAct);
                                    Clust_with_CRMovement = cellfun(@(x,y) any(x) & any(y), ClustAct_Separated, CR_movements_separated_byCoAct);
                                    Total_ClustAct_Bouts = cellfun(@any, ClustAct_Separated);
                                    FractionofClustActivityDuringMovements{f}{ns}{closecount} = sum(Clust_with_Movement)/sum(Total_ClustAct_Bouts);
                                    FractionofClustActivityDuringCRMovements{f}{ns}{closecount} = sum(Clust_with_CRMovement)/sum(Total_ClustAct_Bouts);
                                    NumMovs = length(MovementInfo.ActivityDuringMovement_Addresses);
                                    %======================================
                                    ClustActivityStartRelativetoMovement{f}{ns}{closecount} = nanmedian(MovementInfo.ActivityStartRelativetoMovement);
                                    ClustActivityStartNormalizedtoMovementLength{f}{ns}{closecount} = nanmedian(MovementInfo.ActivityStartNormalized);
                                    StandardDeviationofClustActivityOnset{f}{ns}{closecount} = nanstd(MovementInfo.ActivityStartRelativetoMovement);
                                    StandardDeviationofNormClustActivityOnset{f}{ns}{closecount} = nanstd(MovementInfo.ActivityStartNormalized);
                                    LeverPositionatClustActivityOnset{f}{ns}{closecount} = MovementInfo.LeverPositionatActivityOnset;
                                    LeverVelocityatClustActivityOnset{f}{ns}{closecount} = MovementInfo.LeverVelocityatActivityOnset;
                                    LeverVelocityatRandomLagsfromOnset{f}{ns}{closecount} = MovementInfo.LeverVelocityatRandomLags; 
                                    MeanSpeedofActMovementPeriods{f}{ns}{closecount} = MovementInfo.MeanSpeedofActMovementPeriods;
                                    MeanSpeedofOtherMovementPeriods{f}{ns}{closecount} = MovementInfo.MeanSpeedofOtherMovementPeriods;
                                    LeverSlopeTraces{f}{ns}{closecount} = MovementInfo.LeverSlopeTraces;
                                    ShuffledClustActivityStart{f}{ns}{closecount} = nanmedian(MovementInfo.ShuffledActivityStartTime);
                                    ShuffledActivityStartNormalizedtoMovementLength{f}{ns}{closecount} = nanmedian(MovementInfo.ShuffledActivityStartNormalized);
                                    StandardDeviationofShuffledActivityOnset{f}{ns}{closecount} = nanstd(MovementInfo.ShuffledActivityStartTime);
                                    StandardDeviationofNormShuffledActivityOnset{f}{ns}{closecount} = nanstd(MovementInfo.ShuffledActivityStartNormalized);
                                    LeverPositionatShuffledActivityOnset{f}{ns}{closecount} = MovementInfo.ShuffledLeverPositionatActivityOnset;
                                    LeverVelocityatShuffledActivityOnset{f}{ns}{closecount} = MovementInfo.ShuffledLeverVelocityatActivityOnset;
                                    ClustActivityStartHypothesisTest{f}{ns}{closecount} = MovementInfo.ActivityStartHypothesisTest;
                                end
                                modelnumberofmovementsused(prct_count) = length(MovementInfo.ActivityDuringMovement_Addresses);
                                modelfractionofmovementsused(prct_count) = length(MovementInfo.ActivityDuringMovement_Addresses)./length(frames_during_targetperiods);
                                modelcorrvalues(prct_count) = nanmedian(CoAMCwMM);
                                movcorrvalues(prct_count) = nanmedian(CoAMC);
                                modelcorrvalues(prct_count) = nanmedian(CoAMCwMM);
                                movcorrvalues(prct_count) = nanmedian(CoAMC);
                                framesofinterest = frames_during_targetperiods(setdiff(1:length(frames_during_targetperiods),MovementInfo.ActivityDuringMovement_Addresses));
                                if ~isempty(framesofinterest)
                                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate,framesofinterest ,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                                else
                                    ExtractedTraces = [];
                                end
                                temp = corrcoef(ExtractedTraces);
                                temp(1:size(temp,1)+1:end) = nan;
                                compcorrvalues(prct_count) = nanmedian(temp(:));
                                prct_count = prct_count+1;
                            end

                            StereotypyDiagnostics{f}{ns}{closecount}.ModelCorrValues = modelcorrvalues;
                            StereotypyDiagnostics{f}{ns}{closecount}.MoveCorrValues = movcorrvalues;
                            StereotypyDiagnostics{f}{ns}{closecount}.OtherCorrValues = compcorrvalues;
                            StereotypyDiagnostics{f}{ns}{closecount}.NumberofMovements = modelnumberofmovementsused;
                            StereotypyDiagnostics{f}{ns}{closecount}.FractionofMovements = modelfractionofmovementsused;
                            StereotypyDiagnostics{f}{ns}{closecount}.PercentileThreshold = coactivethresh;

                            MovementswithClusteredCoActivitybyCluster{f}{ns}{closecount} = ChosenExtractedTraces;
                            CorrelationofMovementswithCoActiveClusterActivitybyCluster{f}{ns}{closecount} = CoActiveMovementCorr;
                            CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{f}{ns}{closecount} = CoActiveMovementCorrwithModelMovement;
                            if ~isempty(ChosenExtractedTraces) && ~isempty(MovementsEncodedbySeedlingMRS{f}{ns}{ms})
%                                 similaritytoseedmovement = corrcoef([nanmean(MovementsEncodedbySeedlingMRS{f}{ns}{ms},2), nanmean(ChosenExtractedTraces,2)]);
%                                 SimilarityofClusteredMovementwithSeedlingMRSMovement{f}{ns}(closecount) = similaritytoseedmovement(1,2);
                                similaritytoseedmovement = corrcoef([MovementsEncodedbySeedlingMRS{f}{ns}{ms}, ChosenExtractedTraces]);similaritytoseedmovement(1:size(similaritytoseedmovement,1)+1:numel(similaritytoseedmovement)) = nan;
                                similaritytoseedmovement = similaritytoseedmovement(size(MovementsEncodedbySeedlingMRS{f}{ns}{ms},2)+1:size(similaritytoseedmovement,1),:);
                                SimilarityofClusteredMovementwithSeedlingMRSMovement{f}{ns}(closecount) = nanmean(similaritytoseedmovement(:));
                            else
                                SimilarityofClusteredMovementwithSeedlingMRSMovement{f}{ns}(closecount) = NaN;
                            end
                            
                            ChanceRewardedLevel{f}{ns}(1,closecount) = Chosen_ChanceLevel;
                            IsCoActiveMovementRewarded{f}{ns}{closecount} = Chosen_Reward_Outcome;
                            %==============================================
                            NumberofMovementswithClusterCoActivitybyCluster{f}{ns}(1,closecount) = NumMovs;
                            FractionofMovementswithClusterCoActivitybyCluster{f}{ns}(1,closecount) = NumMovs./length(frames_during_targetperiods);
                            %==============================================
                            %%% Repeat using MRS activity alone
                            if ~ismember(MovementSpinestoCompare(ms),usedthiMRSforMRSOnlyPeriods)
                                
                                usedthiMRSforMRSOnlyPeriods = MovementSpinestoCompare(ms);
                                OtherVariables.TimingValues = TimingValues;
                                OtherVariables.ImagingFrequency = ImagingFrequency;
                                OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                                OtherVariables.ModelMovement = ModelMovement;
                                OtherVariables.LearningPhase = 'Late';
                                OtherVariables.Focus = FocusOnWhichMovements;
                                OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                                OtherVariables.IsCluster = 0;
                                OtherVariables.DoShuffling = 0;
                                
                                [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(MoveSpineActivityWithoutNewSpineActivity, MovementBlocks,OtherVariables);
                                framesofinterest = frames_during_targetperiods(MovementInfo.ActivityDuringMovement_Addresses);
                                LeverPositionatMRSOnlyActivityOnset{f}{ns}{closecount} = MovementInfo.LeverPositionatActivityOnset;
                                LeverVelocityatMRSOnlyActivityOnset{f}{ns}{closecount} = MovementInfo.LeverVelocityatActivityOnset;
                                LeverVelocityatShuffledMRSActivityOnset{f}{ns}{closecount} = MovementInfo.ShuffledLeverVelocityatActivityOnset;
                                %==============================================

                                framesofinterest = frames_during_targetperiods(setdiff(MovementInfo.ActivityDuringMovement_Addresses, thiscluster_moveaddresses));
                                if ~isempty(framesofinterest)
                                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,MoveSpineActivityWithoutNewSpineActivity, rewardperiodsLate, TimingValues, ImagingFrequency);
                                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    MRSOnlyMovementCorr = thissessionmovementcorr(:); %%% Finding the correlation at this point assumes that movements co-occurring with ANY cluster co-activation should be differently correlated... if this is true to the extreme, then you might also correlate movements with such activity across sessions/fields, which would suggest that clusters in general represent the modified circuit
                                    MRSOnlyCorrwithModelMovement = movementcorr(end,:);
                                else
                                    ExtractedTraces = [];
                                    MRSOnlyMovementCorr = [];
                                    MRSOnlyCorrwithModelMovement = [];
                                end
                                
                                MovementswithMRSOnlyActivitybyCluster{f}{ns}{closecount} = ExtractedTraces;
                                CorrelationofMovementswithMRSOnlyActivitybyCluster{f}{ns}{closecount} = MRSOnlyMovementCorr;
                                MRSOnlyMovementsCorrelationwithModelMovementbyCluster{f}{ns}{closecount} = MRSOnlyCorrwithModelMovement;

                                
                                MoveOnlyAddresses{f} = [MoveOnlyAddresses{f}; MovementInfo.ActivityDuringMovement_Addresses];
                                IsMoveOnlyRewarded{f} = [IsMoveOnlyRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];
                                MoveOnlyChanceRewardedLevel{f} = [MoveOnlyChanceRewardedLevel{f}; MovementInfo.ChanceReward];
                            else
                            end
                            
                            %==============================================
                            %%% Mov. Stereotypy of FREQUENCY-MATCHED ctrls
                            
                            OtherVariables.TimingValues = TimingValues;
                            OtherVariables.ImagingFrequency = ImagingFrequency;
                            OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                            OtherVariables.ModelMovement = ModelMovement;
                            OtherVariables.LearningPhase = 'Late';
                            OtherVariables.Focus = FocusOnWhichMovements;
                            OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                            OtherVariables.IsCluster = 0;
                            OtherVariables.DoShuffling = 0;

                            coactivethresh = [];

                            if lower_thresh_for_coact
                                switch useSDorPRCT
                                    case 'PRCT'
                                        coactivethresh = prctile(analogcomp_coactivetrace, chosen_prct,2);
                                    case 'SD'
                                        for cs = 1:size(analogcomp_coactivetrace,1)
                                            coactivethresh(1,cs) = chosen_prct*std(analogcomp_coactivetrace(cs,:));
                                        end
                                end
                                if use_dFoF_not_binarized
                                    threshtouse = coactivethresh;
                                    contingA = (analogcomp_coactivetrace>threshtouse);
    %                                 contingA = analogcomp_coactivetrace>staticthresh(chosen_address);
                                    contingB = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoNS,:)>mindFoFtoconsiderCoActive;
                                    contingC = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoCMRS,:)>mindFoFtoconsiderCoActive;
                                    binarycomp_coactivetrace = (contingA & contingB & contingC) | binarycomp_coactivetrace;
                                else
                                end
                                FMcompCoActiveRate{f}{ns}{closecount} = length(find(diff(binarycomp_coactivetrace)>0))/(length(binarycomp_coactivetrace)/(ImagingFrequency*60));
                            end
                            
                            if ~isempty(binarycomp_coactivetrace)
                                [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binarycomp_coactivetrace, MovementBlocks,OtherVariables);
                                framesofinterest = frames_during_targetperiods(setdiff(MovementInfo.ActivityDuringMovement_Addresses,thiscluster_moveaddresses));
                                if ~isempty(framesofinterest)
                                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,binarycomp_coactivetrace, rewardperiodsLate, TimingValues, ImagingFrequency);
                                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    CompMovementCorr = thissessionmovementcorr(:); 
                                    CompCorrwithModelMovement = movementcorr(end,:);
                                else
                                    ExtractedTraces = [];
                                    CompMovementCorr = [];
                                    CompCorrwithModelMovement = [];
                                end
                                FMActivityStartRelativetoMovement{f}{ns}{closecount} = nanmedian(MovementInfo.ActivityStartRelativetoMovement);
                                MovementswithFMControlCoActivitybyCluster{f}{ns}{closecount} = ExtractedTraces;
                                CorrelationofMovementswithCoActiveFMControlActivitybyCluster{f}{ns}{closecount} = CompMovementCorr;
                                FMControlMovementsCorrelationwithModelMovementbyCluster{f}{ns}{closecount} = CompCorrwithModelMovement;
                                comp_CoActiveAddresses{f} = [comp_CoActiveAddresses{f};MovementInfo.ActivityDuringMovement_Addresses];
                                IsCompCoActiveMovementRewarded{f} = [IsCompCoActiveMovementRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];
                                FMChanceRewardedLevel{f} = [FMChanceRewardedLevel{f}; MovementInfo.ChanceReward];
                            else
                                FMActivityStartRelativetoMovement{f}{ns}{closecount} = NaN;
                                MovementswithFMControlCoActivitybyCluster{f}{ns}{closecount} = NaN;
                                CorrelationofMovementswithCoActiveFMControlActivitybyCluster{f}{ns}{closecount} = NaN;
                                FMControlMovementsCorrelationwithModelMovementbyCluster{f}{ns}{closecount} = NaN;
                            end


                            
                            %==============================================
                            %%% Mov. Stereotypy of distance-matched ctrls
                            
                            if lower_thresh_for_coact
                                coactivethresh = [];
                                switch useSDorPRCT
                                    case 'PRCT'
                                        coactivethresh = prctile(analogMRSDistMatchedcoactivity, chosen_prct,2);
                                    case 'SD'
                                        for cs = 1:size(analogMRSDistMatchedcoactivity,1)
                                            coactivethresh(cs,1) = chosen_prct*std(analogMRSDistMatchedcoactivity(cs,:));
                                        end
                                        end
%                                 contingA = analogMRSDistMatchedcoactivity>coactivethresh;
%                                 threshtouse = min(coactivethresh, staticthresh(chosen_address));
                                if use_dFoF_not_binarized
                                    threshtouse = coactivethresh;
                                    if isempty(analogMRSDistMatchedcoactivity)
                                        contingA = zeros(1,length(MoveSpineActivityAligned));
                                    else
                                        contingA = analogMRSDistMatchedcoactivity>threshtouse;
                                    end
                                    contingB = MoveSpineActivityAligned>mindFoFtoconsiderCoActive;
                                    contingC = DistanceMatchedActivity>mindFoFtoconsiderCoActive;
                                    binaryMRSDistMatchedcoactivity = (contingA & contingB & contingC) | binaryMRSDistMatchedcoactivity;
                                else
                                end
                                if ~isempty(binaryMRSDistMatchedcoactivity)
                                    for compspine = 1:size(binaryMRSDistMatchedcoactivity,1)
                                        MRSDMcompCoActiveRate{f}{ns}{closecount}(1,compspine) = length(find(diff(binaryMRSDistMatchedcoactivity(compspine,:))>0))/(length(binaryMRSDistMatchedcoactivity)/(ImagingFrequency*60));
                                    end
                                else
                                    MRSDMcompCoActiveRate{f}{ns}{closecount} = NaN;
                                end
%                                 binaryMRSDistMatchedcoactivity = (analogMRSDistMatchedcoactivity>staticthresh) | binaryMRSDistMatchedcoactivity;
                            end
                            
                            ExtractedTraces = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                            MRSDMMovementCorr = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                            MRSDMCorrwithModelMovement = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                            for cmp = 1:size(binaryMRSDistMatchedcoactivity,1)
                                [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binaryMRSDistMatchedcoactivity(cmp,:), MovementBlocks,OtherVariables);
                                MovementInfo.ActivityDuringMovement_Addresses = setdiff(MovementInfo.ActivityDuringMovement_Addresses, MRSDM_CoActiveAddresses{f});
                                MRSDM_CoActiveAddresses{f} = [MRSDM_CoActiveAddresses{f};MovementInfo.ActivityDuringMovement_Addresses];
                                framesofinterest = frames_during_targetperiods(setdiff(MovementInfo.ActivityDuringMovement_Addresses,thiscluster_moveaddresses));
                                if ~isempty(framesofinterest)
                                    [ExtractedTraces{cmp}] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,binaryMRSDistMatchedcoactivity(cmp,:), rewardperiodsLate, TimingValues, ImagingFrequency);
                                    movementcorr = corrcoef([ExtractedTraces{cmp}, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    MRSDMMovementCorr{cmp} = thissessionmovementcorr(:); 
                                    MRSDMCorrwithModelMovement{cmp} = movementcorr(end,:);
                                else
                                    ExtractedTraces{cmp} = [];
                                    MRSDMMovementCorr{cmp} = [];
                                    MRSDMCorrwithModelMovement{cmp} = [];
                                end
                            end
                            MRSDMActivityStartRelativetoMovement{f}{ns}{closecount} = nanmedian(MovementInfo.ActivityStartRelativetoMovement);
                            MovementswithMRSDMCoActivitybyCluster{f}{ns}{closecount} = cell2mat(ExtractedTraces);
                            CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{f}{ns}{closecount} = cell2mat(MRSDMMovementCorr');
                            MRSDMControlMovementsCorrelationwithModelMovementbyCluster{f}{ns}{closecount} = cell2mat(MRSDMCorrwithModelMovement);

                            
                            IsMRSDMCoActiveMovementRewarded{f} = [IsMRSDMCoActiveMovementRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];
                            MRSDMChanceRewardedLevel{f} = [MRSDMChanceRewardedLevel{f}; MovementInfo.ChanceReward];
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %% ============================================
                            %%% Dot products of co-activity and movement;
                            %%% this should show whether co-activity is
                            %%% more likely to occur with movements than
                            %%% chance
                            
                            
                            if use_dFoF_not_binarized
                                CoATrace = analogcoactivetrace.*chosenbinarycoactivetrace;
                                CompTrace = analogcomp_coactivetrace.*binarycomp_coactivetrace;
                                MRSDMTrace = analogMRSDistMatchedcoactivity.*binaryMRSDistMatchedcoactivity;
                            else
%                                 CoATrace = (NewSpineActivityAligned.*NewSpineBinarizedAligned).*(MoveSpineActivityAligned.*MoveSpineBinarizedAligned);
                                CoATrace = chosenbinarycoactivetrace;
                                CompTrace = binarycomp_coactivetrace;
                                MRSDMTrace = binaryMRSDistMatchedcoactivity;
                                MRSonlyTrace = MoveSpineActivityWithoutNewSpineActivity;
                            end
                            
                            MRSDM_vectormag =[];
                            for nt = 1:size(MRSDMTrace,1)
                                MRSDM_vectormag(nt,1) = norm(MRSDMTrace(nt,:));
                            end
                            %%% Note: comparable values for the NS will be
                            %%% found below;
                            
                            
                            if any(CoATrace)
                                movement_activity = CoATrace*binarizedleverLate;
                                    shuffled_activity  = CoATrace*shuffledmovetraces;
                                freqcomp_activity = CompTrace*binarizedleverLate;
                                    freqcompshuffled_activity = CompTrace*shuffledmovetraces;
                                MRSDM_activity = MRSDMTrace *binarizedleverLate;
                                    MRSDMshuffled_activity = MRSDMTrace*shuffledmovetraces;
                                MRSonly_activity = MRSonlyTrace*binarizedleverLate;
                                    MRSonlyshuffled_activity = MRSonlyTrace*shuffledmovetraces;

                                DotProdofCoActivePeriodswithMovement(closecount) = movement_activity/(norm(CoATrace)*norm(binarizedleverLate));
                                    ChanceCoActiveMovementOverlap(closecount) = nanmedian(shuffled_activity./(norm(CoATrace)*norm(binarizedleverLate)));
                                if ~isempty(freqcomp_activity)
                                    DotProdofFreqCompCoActivePeriodswithMovement(closecount) = nanmedian(freqcomp_activity)./(norm(CompTrace)*norm(binarizedleverLate));
                                    ChanceFreqMatchedCoActivitywithMovement(closecount) = nanmedian(freqcompshuffled_activity)./(norm(CompTrace)*norm(binarizedleverLate));
                                else
                                    DotProdofFreqCompCoActivePeriodswithMovement(closecount) = nan;
                                    ChanceFreqMatchedCoActivitywithMovement(closecount) = nan;
                                end
                                DotProdofMRSDMCoActivePeriodswithMovement(closecount) = nanmedian(MRSDM_activity./(MRSDM_vectormag.*norm(binarizedleverLate)));
                                    ChanceMRSDMCoActivitywithMovement(closecount) = nanmedian(nanmedian(MRSDMshuffled_activity,2)./(MRSDM_vectormag.*norm(binarizedleverLate)));
                                DotProdofMRSOnlyCoActivePeriodswithMovement(closecount) = nanmedian(MRSonly_activity./(norm(MRSonlyTrace)*norm(binarizedleverLate)));
                                    ChanceMRSOnlyoActivitywithMovement(closecount) = nanmedian(nanmedian(MRSonlyshuffled_activity,2)./(norm(MRSonlyTrace)*norm(binarizedleverLate)));

                                CRmovement_activity = CoATrace*CuedRewardedMovementTracesLate{f};
                                    CRshuffled_activity = CoATrace*shuffledCRmovetraces;
                                CRcomp_movement_activity = CompTrace*CuedRewardedMovementTracesLate{f};
                                    CRcomp_shuffled_activity = CompTrace*shuffledCRmovetraces;

                                DotProdofCoActivePeriodswithCRMovement(closecount) = CRmovement_activity;
                                ChanceCoActiveCRMovementOverlap(closecount) = nanmedian(CRshuffled_activity);
                                if ~isempty(CRcomp_movement_activity)
                                    DotProductofCompCoActivePeriodswithCRMovement(closecount) = CRcomp_movement_activity;
                                    ChanceCompCoActiveCRMovementOverlap(closecount) = nanmedian(CRcomp_shuffled_activity);
                                else
                                    DotProductofCompCoActivePeriodswithCRMovement(closecount) = nan;
                                    ChanceCompCoActiveCRMovementOverlap(closecount) = nan;
                                end
                            else                             
                                DotProdofCoActivePeriodswithMovement(closecount) = 0;
                                    ChanceCoActiveMovementOverlap(closecount) = 0;
                                DotProdofFreqCompCoActivePeriodswithMovement(closecount) = 0;
                                    ChanceFreqMatchedCoActivitywithMovement(closecount) = 0;
                                DotProdofMRSDMCoActivePeriodswithMovement(closecount) = 0;
                                    ChanceMRSDMCoActivitywithMovement(closecount) = 0;
                                DotProdofMRSOnlyCoActivePeriodswithMovement(closecount) = 0;
                                    ChanceMRSOnlyoActivitywithMovement(closecount) = 0;

                                    
                                CRmovement_activity = CoATrace*CuedRewardedMovementTracesLate{f};
                                    CRshuffled_activity = CoATrace*shuffledCRmovetraces;
                                CRcomp_movement_activity = CompTrace*CuedRewardedMovementTracesLate{f};
                                    CRcomp_shuffled_activity = CompTrace*shuffledCRmovetraces;
                                DotProdofCoActivePeriodswithCRMovement(closecount) = CRmovement_activity;
                                ChanceCoActiveCRMovementOverlap(closecount) = nanmedian(CRshuffled_activity);
                                DotProductofCompCoActivePeriodswithCRMovement(closecount) = 0;
                                ChanceCompCoActiveCRMovementOverlap(closecount) = 0;
                            end
                            
                            %==============================================
                            closecount = closecount+1;
                            %==============================================
                        end
                        %==================================================
                        count = count+1;
                        %==================================================
                    end
                    %======================================================
                    %======================================================
                    %%% DONE CYCLING THROUGH MRSs FOR CURRENT NEW SPINE
                    %======================================================
                   
                    %======================================================
                    %% Handle All Data for the current New Spine
                    %======================================================
                    
                    if use_dFoF_not_binarized
                        NS_activity_to_use = double(NewSpineActivityAligned>mindFoFtoconsiderCoActive);
                    else
                        NS_activity_to_use = NewSpineBinarizedAligned;
                    end
                    
                    %%% Find all periods of new spine activity and exclude
                    %%% all events that contain ANY MRS activity
                    AllChosenMRSPairActivity = sum(AllChosenMRSPairActivity,1);
                    AllChosenMRSPairActivity(AllChosenMRSPairActivity~=0) = 1;
                    NewSpineActivity_Boundaries = find(diff([Inf,NS_activity_to_use,Inf])~=0);
                    NewSpineActivity_Separated = mat2cell(NS_activity_to_use', diff(NewSpineActivity_Boundaries));
                    AllMRSActivity_Separated_byNSAct = mat2cell(AllChosenMRSPairActivity', diff(NewSpineActivity_Boundaries));
                    NewSpineActivity_Separated(cellfun(@(x,y) any(x)&any(y), NewSpineActivity_Separated,AllMRSActivity_Separated_byNSAct)) = cellfun(@(x) zeros(length(x),1), NewSpineActivity_Separated(cellfun(@(x,y) any(x)&any(y), NewSpineActivity_Separated,AllMRSActivity_Separated_byNSAct)), 'uni', false);
                    %======================================================
                    NewSpineActivityWithoutMoveSpineActivity = cell2mat(NewSpineActivity_Separated)';
                    %%%
                    NewSpineActivityWithoutMoveSpineActivity = PreserveActivityAmplitude(NewSpineActivityAligned, NewSpineActivityWithoutMoveSpineActivity);
                    %%%
                    NSonlyEventRate{f}(1,ns) = numel(find(diff(NewSpineActivityWithoutMoveSpineActivity)>0))/(length(NewSpineActivityWithoutMoveSpineActivity)/(ImagingFrequency*60));
                    NSonlyIntegratedActivity{f}(1,ns) = sum(NewSpineActivityWithoutMoveSpineActivity)/length(NewSpineActivityWithoutMoveSpineActivity);
                    %======================================================
                    movements_separated_byNSAct = mat2cell(binarizedleverLate, diff(NewSpineActivity_Boundaries));
                    NS_with_movement = cellfun(@(x,y) any(x)&any(y), NewSpineActivity_Separated, movements_separated_byNSAct);
                    Total_NS_ActBouts = cellfun(@any, NewSpineActivity_Separated);
%                     NS_with_movement = NS_activity_to_use+binarizedleverLate';
%                     NS_with_movement(NS_with_movement~=2) = 0; NS_with_movement(NS_with_movement~=0) = 1;
                    FractionofNSActivityDuringMovements{f}(1,ns) = sum(NS_with_movement)/sum(Total_NS_ActBouts);
                    %======================================================
                    newonly = corrcoef([binarizedleverLate, NewSpineActivityWithoutMoveSpineActivity']);
                    NewSpineOnlywithMovement(1,closecount) = newonly(1,2);
                    newonly = corrcoef([successtraceLate, NewSpineActivityWithoutMoveSpineActivity']);
                    NewSpineOnlywithSuccess(1,closecount) = newonly(1,2);

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Find the analogous features of the NEW
                    %%% spine with another nearby spine: 
                    %%% New-Spine Distance Matched (NSDM) controls!
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %==============================================
                    ClusteredMoveSpinesbyNewSpine{f}{ns} = MRSsClusteredwiththisNS;
                    spinestochoose = length(MRSsClusteredwiththisNS);
                    if spinestochoose>0 %%% the following comparisons only make sense if there was at least one clustered spine pair (e.g. an MRS clustered with an NS); otherwise, skip this section
                        DistanceMatchedPartners = find(AllDendriteDistances{f}(NewSpines{f}(ns),:)<=clusterdistance);
                        DistanceMatchedNonMRPartners = setdiff(DistanceMatchedPartners, union(MovementSpinestoCompare, NewSpines{f}));
%                         DistanceMatchedNonMRPartners = setdiff(DistanceMatchedPartners, MRSsClusteredwiththisNS);
                        comparisonspinestouse = DistanceMatchedNonMRPartners;
                        if ~isempty(comparisonspinestouse)
                            for shf = 1:100
                                pseudo_partners = comparisonspinestouse(randi(length(comparisonspinestouse),1,spinestochoose));
                                corr_samples(shf) = nanmax(AllLateSpineCorrelations(NewSpines{f}(ns), pseudo_partners));
                            end
                            DistMatchedtoNSPartnersCorr = nanmedian(corr_samples);
                        else
                            DistMatchedtoNSPartnersCorr = NaN;
                        end
                        switch AnalysisType
                            case 'Subtract'
                                eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(comparisonspinestouse), '],:);'])
                            case 'Exclude'
                                eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(comparisonspinestouse), '],:);'])
                                DistanceMatchedActivity = DistanceMatchedActivity.*DistanceMatchedBinarized;
                            case 'Ignore'
                                eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(comparisonspinestouse), '],:);'])
                                eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(latesession), '}.BinarizedOverallSpineData([', num2str(comparisonspinestouse), '],:);'])
                        end
                        %%%
                        DistanceMatchedBinarized = PreserveActivityAmplitude(DistanceMatchedActivity, DistanceMatchedBinarized);
                        %%%
                        DistanceMatchedBinarized(isnan(DistanceMatchedBinarized)) = 0;
                        DistanceMatchedActivity(isnan(DistanceMatchedActivity)) = 0;

                        NZDMdata = DistanceMatchedActivity; NZDMdata(NZDMdata<0) =0;
                        analogNSDistMatchedcoactivity = repmat(NZNSAct,length(comparisonspinestouse),1).*NZDMdata;
                        binaryNSDistMatchedcoactivity = repmat(NewSpineBinarizedAligned,length(comparisonspinestouse),1).*DistanceMatchedBinarized;
                        for compspine = 1:size(binaryNSDistMatchedcoactivity,1)
                            NSDMcompCoActiveRate{f}{ns} = length(find(diff(binaryNSDistMatchedcoactivity(compspine,:))>0))/(length(binaryNSDistMatchedcoactivity)/(ImagingFrequency*60));
                        end
                        if use_dFoF_not_binarized
                            move_centric_distmatched_activity = DistanceMatchedActivity(:,cell2mat(frames_during_targetperiods));
                        else
                            move_centric_distmatched_activity = DistanceMatchedBinarized.*binarizedleverLate';
                        end
                        move_centric_distmatched_correlation = corrcoef([move_centric_newspineactivity', move_centric_distmatched_activity']);
                        MoveCentricDistMatchedCorrelation = nanmedian(move_centric_distmatched_correlation(1,2:end));

                        %==============================================
                        %%% Mov. Stereotypy of dist-matched (to NS) ctrls
                        
                        OtherVariables.TimingValues = TimingValues;
                        OtherVariables.ImagingFrequency = ImagingFrequency;
                        OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                        OtherVariables.ModelMovement = ModelMovement;
                        OtherVariables.LearningPhase = 'Late';
                        OtherVariables.Focus = FocusOnWhichMovements;
                        OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;

                        if lower_thresh_for_coact
                            switch useSDorPRCT
                                case 'PRCT'
                                    coactivethresh = prctile(analogNSDistMatchedcoactivity, chosen_prct,2);
                                case 'SD'
                                    coactivethresh = chosen_prct*std(analogNSDistMatchedcoactivity,[],2);
                            end
%                             contingA = analogNSDistMatchedcoactivity>coactivethresh;
%                             threshtouse = min(coactivethresh, staticthresh(chosen_address));
                            if use_dFoF_not_binarized
                                threshtouse = coactivethresh;
                                contingA = analogNSDistMatchedcoactivity>threshtouse; 
                                contingB = NewSpineActivityAligned>mindFoFtoconsiderCoActive;
                                contingC = DistanceMatchedActivity>mindFoFtoconsiderCoActive;
                                binaryNSDistMatchedcoactivity = (contingA & contingB & contingC) | binaryNSDistMatchedcoactivity;
                            else
                            end
                        end
                        
                        ExtractedTraces = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                        NSDMMovementCorr = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                        NSDMCorrwithModelMovement = cell(1,size(binaryMRSDistMatchedcoactivity,1));
                        for cmp = 1:size(binaryNSDistMatchedcoactivity,1)
                            [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binaryNSDistMatchedcoactivity(cmp,:), MovementBlocks,OtherVariables);
                            framesofinterest = frames_during_targetperiods(setdiff(MovementInfo.ActivityDuringMovement_Addresses,cell2mat(CoActiveDuringMovement_Addresses{find(prctvals==chosen_prct)}{ns}')));
                            if ~isempty(framesofinterest)
                                [ExtractedTraces{cmp}] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,binaryNSDistMatchedcoactivity(cmp,:), rewardperiodsLate, TimingValues, ImagingFrequency);
                                movementcorr = corrcoef([ExtractedTraces{cmp}, ModelMovement']);
                                movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                                thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                NSDMMovementCorr{cmp} = thissessionmovementcorr(:); 
                                NSDMCorrwithModelMovement{cmp} = movementcorr(end,:);
                            else
                                ExtractedTraces{cmp} = [];
                                NSDMMovementCorr{cmp} = [];
                                NSDMCorrwithModelMovement{cmp} = [];
                            end
                        end
                        NSDMActivityStartRelativetoMovement{f}{ns} = nanmedian(MovementInfo.ActivityStartRelativetoMovement);
                        MovementswithNSDMCoActivitybyCluster{f}{ns} = cell2mat(ExtractedTraces);
                        CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster{f}{ns} = cell2mat(NSDMMovementCorr');
                        NSDMControlMovementsCorrelationwithModelMovementbyCluster{f}{ns} = cell2mat(NSDMCorrwithModelMovement);


                        NSDM_CoActiveAddresses{f} = [NSDM_CoActiveAddresses{f}; MovementInfo.ActivityDuringMovement_Addresses];
                        IsNSDMCoActiveMovementRewarded{f} = [IsNSDMCoActiveMovementRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];
                        NSDMChanceRewardedLevel{f} = [NSDMChanceRewardedLevel{f}; MovementInfo.ChanceReward];
                    else
                        binaryNSDistMatchedcoactivity = zeros(1,length(NewSpineActivityAligned));
                        
                    end
                    %==================================================
                    %%% Movement ster. of NS ACTIVITY ALONE
                    OtherVariables.TimingValues = TimingValues;
                    OtherVariables.ImagingFrequency = ImagingFrequency;
                    OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                    OtherVariables.ModelMovement = ModelMovement;
                    OtherVariables.LearningPhase = 'Late';
                    OtherVariables.Focus = FocusOnWhichMovements;
                    OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                    OtherVariables.IsCluster = 0;
                    OtherVariables.DoShuffling = 0;

                    [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(NewSpineActivityWithoutMoveSpineActivity,MovementBlocks,OtherVariables);
                    %==============================================

                    framesofinterest = frames_during_targetperiods(setdiff(MovementInfo.ActivityDuringMovement_Addresses, Chosen_Addresses));
                    if ~isempty(framesofinterest)
                        [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,NewSpineActivityWithoutMoveSpineActivity, rewardperiodsLate, TimingValues, ImagingFrequency);
                        movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                        movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                        thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                        NSOnlyMovementCorr = thissessionmovementcorr(:); %%% Finding the correlation at this point assumes that movements co-occurring with ANY cluster co-activation should be differently correlated... if this is true to the extreme, then you might also correlate movements with such activity across sessions/fields, which would suggest that clusters in general represent the modified circuit
                        NSOnlyCorrwithModelMovement = movementcorr(end,:);
                    else
                        ExtractedTraces = [];
                        NSOnlyMovementCorr = [];
                        NSOnlyCorrwithModelMovement = [];
                    end

                    NSonlyActivityStartRelativetoMovement{f}{ns} = nanmedian(MovementInfo.ActivityStartRelativetoMovement);
                    StandardDeviationofNSOnlyActivityOnset{f}{ns} = nanstd(MovementInfo.ActivityStartRelativetoMovement);
                    LeverPositionatNSOnlyActivityOnset{f}{ns} = MovementInfo.LeverPositionatActivityOnset;
                    LeverVelocityatNSOnlyActivityOnset{f}{ns} = MovementInfo.LeverVelocityatActivityOnset;
                    LeverVelocityatShuffledNSActivityOnset{f}{ns} = MovementInfo.ShuffledLeverVelocityatActivityOnset;
                    MovementswithNSOnlyActivitybyCluster{f}{ns} = ExtractedTraces;
                    CorrelationofMovementswithNSOnlyActivitybyCluster{f}{ns} = NSOnlyMovementCorr;
                    NSOnlyMovementsCorrelationwithModelMovementbyCluster{f}{ns} = NSOnlyCorrwithModelMovement;

                    NewOnlyAddresses{f} = [NewOnlyAddresses{f};MovementInfo.ActivityDuringMovement_Addresses];
                    IsNewOnlyRewarded{f} = [IsNewOnlyRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];
                    NewOnlyChanceRewardedLevel{f} = [NewOnlyChanceRewardedLevel{f}; MovementInfo.ChanceReward];
                    %==============================================

                    %%% Analogous DOT PRODUCT calc. for each New Spine

                    if use_dFoF_not_binarized
                        NSDMTrace = analogNSDistMatchedcoactivity;
                        NSDM_activity = NSDMTrace*binarizedleverLate;
                        NSDMshuffled_activity = NSDMTrace*shuffledmovetraces;
                        NSonlyTrace = NewSpineActivityWithoutMoveSpineActivity.*NewSpineActivityAligned;
                        NSonly_movement_activity = NSonlyTrace*binarizedleverLate;
                        NSonly_shuffled_activity = NSonlyTrace*shuffledmovetraces;
                    else
                        NSDMTrace = binaryNSDistMatchedcoactivity;
                        NSDM_activity = NSDMTrace*binarizedleverLate;
                        NSDMshuffled_activity = NSDMTrace*shuffledmovetraces;
                        NSonlyTrace = NewSpineActivityWithoutMoveSpineActivity;
                        NSonly_movement_activity = NSonlyTrace*binarizedleverLate;
                        NSonly_shuffled_activity = NSonlyTrace*shuffledmovetraces;
                    end
                    NSDM_vectormag = [];
                    for nt = 1:size(NSDMTrace,1)
                        NSDM_vectormag(nt,1) = norm(NSDMTrace(nt,:));
                    end
                    DotProdofNSDMCoActivePeriodswithMovement = nanmedian(NSDM_activity./(NSDM_vectormag.*norm(binarizedleverLate)));
                    ChanceNSDMCoActivitywithMovement = nanmedian(nanmedian(NSDMshuffled_activity,2)./(NSDM_vectormag.*norm(binarizedleverLate)));

                    DotProdofNSOnlyActivePeriodswithMovement = NSonly_movement_activity/(norm(NSonlyTrace)*norm(binarizedleverLate));
                    ChanceNSOnlyActivitywithMovement = nanmedian(NSonly_shuffled_activity./(norm(NSonlyTrace)*norm(binarizedleverLate)));

                    %==============================================
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([NewSpines{f}(ns),ShuffledEarlyMovementLabels{shuff}(sh)]); %%% Sort for consistent indexing in the distance matrix
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        if ~isempty(shuffleddistances)
                            NewSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        else
                            NewSpinestoShuffledEarlyMovementSpines(1,count) = nan;
                        end
                        shuffleddistances = [];
                        count = count+1;
                    end
                    if ~any(~isnan(NewSpinestoEarlyMovementSpines))
                        NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner+1;
                    end
                    [DistancesBetweenNewSpinesandNearestEarlyMovementSpines{f}(ns), ind] = nanmin(NewSpinestoEarlyMovementSpines);
                    if DistancesBetweenNewSpinesandNearestEarlyMovementSpines{f}(ns)<=clusterdistance
                        NumberofMovementClusteredNewSpines = NumberofMovementClusteredNewSpines+1;
                        if FieldData{f}.StatClass{end}.DendSub_MovementSpines(NewSpines{f}(ns))
                            NumberofMovementClusteredNewSpinesThatAreMR = NumberofMovementClusteredNewSpinesThatAreMR+1;
                        end
                    end
                    %======================================================
                    %======================================================
                    %======================================================
                    %%% Store all of the features found above
                    %======================================================
                    %======================================================
                    %======================================================
                    %%%
                    NewSpineAllSpinesDistance{f}(ns,:) = AllDendriteDistances{f}(NewSpines{f}(ns),:);
                    NewSpineAllSpinesMidCorr{f}(ns,:) = AllMidSpineCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateCorr{f}(ns,:) = AllLateSpineCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateRawCorr{f}(ns,:) = AllLateSpineRawTraceCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateNoiseCorr{f}(ns,:) = AllLateSpineNoiseCorrelations(NewSpines{f}(ns),:);

                    %%%
%                     NewSpinestoEarlyMovementSpines = NewSpinestoEarlyMovementSpines(NewSpinestoEarlyMovementSpines <= clusterdistance);
                    NewSpineAllDistancestoEarlyMovementSpines{f}{ns} = NewSpinestoEarlyMovementSpines;
                    %%%
                    ClusteredMovementSpineVolume{f}{ns} = cMRS_SpineVolume;
                    [~,MRSwithLargestVolumeChange{f}{ns}] = max(cMRS_SpineVolume);
                    VolIncreaseClusters{f}{ns} = find(cMRS_SpineVolume > volumeincreasecutoff);
                    DistancetoEnlargedSpines{f}{ns} = NewSpinestoEarlyMovementSpines; DistancetoEnlargedSpines{f}{ns}(~(cMRS_SpineVolume > volumeincreasecutoff)) = nan;
                    if any(~isnan(DistancetoEnlargedSpines{f}{ns}))
                        [~, ClosestEnlargedMRS{f}{ns}] = nanmin(DistancetoEnlargedSpines{f}{ns});
                    else
                        ClosestEnlargedMRS{f}{ns} = [];
                    end
                    for sim = 1:100
                        SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend};
                        SimNewSpine = randi([SpinesOnThisDend(1), SpinesOnThisDend(end)]);
                        SimNewSpineDistances = AllDendriteDistances{f}(SimNewSpine,:);
                        AllSpineVolumeChanges = FieldData{f}.SpineVolumeData(SpinesOnThisDend,end)./FieldData{f}.SpineVolumeData(SpinesOnThisDend,1);
                        SimNewSpineDistances(~(AllSpineVolumeChanges > volumeincreasecutoff)) = nan;
                        [~, SimClosestEnlargedSpine] = nanmin(SimNewSpineDistances);
                        SimClusterCorr{f}{ns}(sim) = AllLateSpineCorrelations(SimNewSpine, SimClosestEnlargedSpine);
                    end
                    %%%
                    ClusteredMovementSpineDeltaFrequency{f}{ns} = cMRS_DeltaFrequency;
                    %%%
                    ClusteredMovementSpineDeltaAmplitude{f}{ns} = cMRS_DeltaAmplitude;
                    %%%
                    LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions{f}(ns) = NewSpinesEarlyMovementSpinesLateCorr(ind);
                    AllClusterCorrelationsbyNewSpine{f}{ns} = NewSpinesCorrwithCloseEarlyMRS;
                    [HighCorrClusters{f}{ns},ind] = find(NewSpinesCorrwithCloseEarlyMRS > cutoff_of_highcorr_cluster);
                    DistancetoHighCorrMovementSpines{f}{ns} = NewSpinestoEarlyMovementSpines(ind);
                    [~, ClustwithHighestCorrelation{f}{ns}] =  nanmax(NewSpinesCorrwithCloseEarlyMRS);
                    %%% 
                    MovementSpineDistanceMatchedControlCorrelation{f}{ns} = nanmax(DistanceMatchedtoMRSControlCorr);
                    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{f}(ns) = nanmax(DistMatchedtoNSPartnersCorr);
                    FrequencyMatchedControlCorrelation{f}(ns) = nanmax(FreqMatchedControlCorr);
                    
                    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{f}{ns} = NewSpinestoShuffledEarlyMovementSpines;
                    ClusteredNewSpineCorrwithDendrite{f}{ns} = DendCorrNewSpineOnly;
                    ClusteredNewSpineCorrwithMovement{f}{ns} = NewSpineOnlywithMovement;
                    ClusteredNewSpineCorrwithSuccess{f}{ns} = NewSpineOnlywithSuccess;
                    ClusteredMoveSpineCorrwithDendrite{f}{ns} = DendCorrMoveSpineOnly;
                    ClusteredMoveSpineCorrwithMovement{f}{ns} = MoveSpineOnlywithMovement;
                    ClusteredMoveSpineCorrwithSuccess{f}{ns} = MoveSpineOnlywithSuccess;
                    ClusterCoActiveTraces{f}{ns} = clustcoAtraces;
                    CoActiveClusterCorrwithDendrite{f}{ns} = DendCorrCoactiveCluster;
                    CoActiveClusterCorrwithMovement{f}{ns} = CoactiveClusterwithMovement;
                    CoActiveClusterCorrwithSuccess{f}{ns} = CoactiveClusterwithSuccess;
                    %%%
                    [~, ClustwithHighestNoiseCorrelation{f}{ns}] = nanmax(move_centric_cluster_correlation);
                    HighNoiseCorrClusters{f}{ns} = find(move_centric_cluster_correlation>cutoff_of_highcorr_cluster);
                    AllMoveCentricClusterCorrelationsbyNewSpine{f}{ns} = move_centric_cluster_correlation;
                    FailureCentricClusterCorrelation{f}{ns} = failure_centric_cluster_correlation(ClustwithHighestCorrelation{f}{ns});
                    MoveCentricFrequencyMatchedCorrelation{f}{ns} = MoveCentricFreqMatchedCorrelation(ClustwithHighestCorrelation{f}{ns});
                    MoveCentricDistanceMatchedCorrelation{f}{ns} = MoveCentricDistMatchedCorrelation;
                    MoveCentricDistanceMatchedCorrelationforMRS{f}{ns} = MoveCentricDistMatchedCorrelationforMRS(ClustwithHighestCorrelation{f}{ns});
                    %%%
                    CombinedClusterActivityCorrwithMovement{f}{ns} = combined_activity_move_corr;
                    CombinedClusterActivityCorrwithSuccess{f}{ns} = combined_activity_success_corr;
                    ClusterMovementReliability{f}{ns} = clustermovementreliability;
                    ClusterSuccessReliability{f}{ns} = clustersuccessreliability;
                    ControlPairMovementReliability{f}{ns} = controlpairmovereliability;
                    ControlPairSuccessReliability{f}{ns} = controlpairsuccreliability;
                    
                    if sum(~isnan(NewSpinestoEarlyMovementSpines)) ~= sum(~isnan(DotProdofCoActivePeriodswithMovement))
                        k = 1;
                    end
                                        
                    DotProductofCoActivePeriodsDuringMovement{f}{ns} = DotProdofCoActivePeriodswithMovement;
                    AllCoActivityDotProductsforDistanceMeasurement{f}{ns} = DotProdofCoActivePeriodswithMovement; %%% Create a duplicate that isn't filtered (below) to preserve looking at distance values;
                    DotProductofFMCoActivePeriodsDuringMovement{f}{ns} = DotProdofFreqCompCoActivePeriodswithMovement;
                    DotProductofNSDMCoActivePeriodsDuringMovement{f}{ns} = DotProdofNSDMCoActivePeriodswithMovement;
                    DotProductofNSOnlyActivePeriodsDuringMovement{f}{ns} = DotProdofNSOnlyActivePeriodswithMovement;
                    DotProductofMRSDMCoActivePeriodsDuringMovement{f}{ns} = DotProdofMRSDMCoActivePeriodswithMovement;
                    DotProductofMRSOnlyPeriodsDuringMovement{f}{ns} = DotProdofMRSOnlyCoActivePeriodswithMovement;

                    DotProductofCoActivePeriodsDuringCRMovement{f}{ns} = DotProdofCoActivePeriodswithCRMovement;
%                     DotProductofCoActivePeriodsDuringStillness{f}{ns} = DotProdofCoActivePeriodswithoutMovement;
                    DotProductofFMCoActivePeriodsDuringCRMovement{f}{ns} = DotProductofCompCoActivePeriodswithCRMovement;
                    
                    ChanceLevelofCoactivityMovementOverlap{f}{ns} = ChanceCoActiveMovementOverlap;
                    AllCoActivityChanceLevelDotProductsforDistanceMeasurement{f}{ns} = ChanceCoActiveMovementOverlap;
                    ChanceLevelofFMCoActivitywithmovement{f}{ns} = ChanceFreqMatchedCoActivitywithMovement;
                    ChanceLevelofNSDMCoActivitywithMovement{f}{ns} = ChanceNSDMCoActivitywithMovement;
                    ChanceLevelofNSOnlyActivitywithMovement{f}{ns} = ChanceNSOnlyActivitywithMovement;
                    ChanceLevelofMRSDMCoActivitywithMovement{f}{ns} = ChanceMRSDMCoActivitywithMovement;
                    ChanceLevelofMRSOnlyPeriodsDuringMovement{f}{ns} = ChanceMRSOnlyoActivitywithMovement;
                    ChanceLevelofCoActivityCRMovementOverlap{f}{ns} = ChanceCoActiveCRMovementOverlap;
                    ChanceLevelofFMCoActivityCRMovementOverlap{f}{ns} = ChanceCompCoActiveCRMovementOverlap;
                    
                    MedianMovementCorrelationbyNewSpine{f}{ns} = cellfun(@nanmedian, CorrelationofMovementswithCoActiveClusterActivitybyCluster{f}{ns});
                end

                %==========================================================
                %%% END OF CYCLING THROUGH NEW SPINES
                %==========================================================
                
                %% ======================================================
                % If you want to use a representative cluster (i.e.
                % the MRS-NS pair that has the highest correlation),
                % indicate this here:
                if filterclusters
%                     FilteredClusts = ClustwithHighestCorrelation{f};
                    FilteredClusts = ClosestEnlargedMRS{f};
                    FractionofNewSpinesMeetingClusterCriteria{f} = sum(cellfun(@any, FilteredClusts))/length(NewSpines{f});
                    NewSpinesCorrwithNearbyEarlyMRSs{f} = cellfun(@(x,y) x(y), AllClusterCorrelationsbyNewSpine{f}, FilteredClusts, 'uni', false); %% This is a special case; you want to show whether clusters are more likely to have a highly correlated partner, so finding the maximum makes more sense than setting a lower limit
                    MoveCentricClusterCorrelation{f} = cellfun(@(x,y) x(y), AllMoveCentricClusterCorrelationsbyNewSpine{f}, FilteredClusts, 'uni', false);
                    MovementswithClusteredCoActivitybyCluster{f} = cellfun(@(x,y) x(y), MovementswithClusteredCoActivitybyCluster{f}, FilteredClusts,'uni', false);
                    CorrelationofMovementswithCoActiveClusterActivitybyCluster{f} = cellfun(@(x,y) x(y), CorrelationofMovementswithCoActiveClusterActivitybyCluster{f}, FilteredClusts,'uni', false);
                    CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{f} = cellfun(@(x,y) x(y), CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{f}, FilteredClusts, 'uni', false);
                    DotProductofCoActivePeriodsDuringMovement{f} = cellfun(@(x,y) x(y), DotProductofCoActivePeriodsDuringMovement{f}, FilteredClusts, 'uni', false);
                    DotProductofFMCoActivePeriodsDuringMovement{f} = cellfun(@(x,y) x(y), DotProductofFMCoActivePeriodsDuringMovement{f}, FilteredClusts, 'uni', false);
                    DotProductofNSDMCoActivePeriodsDuringMovement{f} = DotProductofNSDMCoActivePeriodsDuringMovement{f}; %%% The NSDM activity should be handled differently, since it's on a new-spine basis and not putative cluster basis, like MRSs
                    DotProductofMRSDMCoActivePeriodsDuringMovement{f} = cellfun(@(x,y) x(y), DotProductofMRSDMCoActivePeriodsDuringMovement{f}, FilteredClusts, 'uni', false);
                    DotProductofCoActivePeriodsDuringCRMovement{f} = cellfun(@(x,y) x(y), DotProductofCoActivePeriodsDuringCRMovement{f}, FilteredClusts, 'uni', false);
%                     DotProductofCoActivePeriodsDuringStillness{f} = cellfun(@(x,y) x(y), DotProductofCoActivePeriodsDuringStillness{f}, FilteredClusts, 'uni', false);
                    DotProductofFMCoActivePeriodsDuringCRMovement{f} = cellfun(@(x,y) x(y), DotProductofFMCoActivePeriodsDuringCRMovement{f}, FilteredClusts, 'uni', false);
                    
                    IsCoActiveMovementRewarded{f} = cellfun(@(x,y) x(y), IsCoActiveMovementRewarded{f}, FilteredClusts, 'uni', false);
                    ChanceRewardedLevel{f} = cellfun(@(x,y) x(y), ChanceRewardedLevel{f}, FilteredClusts, 'uni', false);
                    NumberofMovementswithClusterCoActivitybyCluster{f} = cellfun(@(x,y) x(y), NumberofMovementswithClusterCoActivitybyCluster{f}, FilteredClusts, 'uni', false);
                    FractionofMovementswithClusterCoActivitybyCluster{f} = cellfun(@(x,y) x(y), FractionofMovementswithClusterCoActivitybyCluster{f}, FilteredClusts, 'uni', false);
                    ChanceLevelofCoactivityMovementOverlap{f} = cellfun(@(x,y) x(y), ChanceLevelofCoactivityMovementOverlap{f}, FilteredClusts, 'uni', false);
                    ChanceLevelofFMCoActivitywithmovement{f} = cellfun(@(x,y) x(y), ChanceLevelofFMCoActivitywithmovement{f}, FilteredClusts, 'uni', false);
                    ChanceLevelofNSDMCoActivitywithMovement{f} = ChanceLevelofNSDMCoActivitywithMovement{f};
                    ChanceLevelofMRSDMCoActivitywithMovement{f} = cellfun(@(x,y) x(y), ChanceLevelofMRSDMCoActivitywithMovement{f}, FilteredClusts, 'uni', false);
                    ChanceLevelofCoActivityCRMovementOverlap{f} =cellfun(@(x,y) x(y), ChanceLevelofCoActivityCRMovementOverlap{f}, FilteredClusts, 'uni', false);
                    ChanceLevelofFMCoActivityCRMovementOverlap{f} = cellfun(@(x,y) x(y), ChanceLevelofFMCoActivityCRMovementOverlap{f}, FilteredClusts, 'uni', false);
                    ClustCoActiveRate{f} = cellfun(@(x,y) x(y), ClustCoActiveRate{f}, FilteredClusts, 'uni', false);
                    ClustIntegratedCoactivity{f} = cellfun(@(x,y) x(y), ClustIntegratedCoactivity{f}, FilteredClusts, 'uni', false);
                    FractionofClustActivityDuringMovements{f} = cellfun(@(x,y) x(y), FractionofClustActivityDuringMovements{f}, FilteredClusts, 'uni', false);
                    FMcompCoActiveRate{f} = cellfun(@(x,y) x(y), FMcompCoActiveRate{f}, FilteredClusts, 'uni', false);
                    MRSDMcompCoActiveRate{f} = cellfun(@(x,y) x(y), MRSDMcompCoActiveRate{f}, FilteredClusts, 'uni', false);
                    ClustActivityStartRelativetoMovement{f} = cellfun(@(x,y) x(y), ClustActivityStartRelativetoMovement{f}, FilteredClusts, 'uni', false);
                    ClustActivityStartNormalizedtoMovementLength{f} = cellfun(@(x,y) x(y), ClustActivityStartNormalizedtoMovementLength{f}, FilteredClusts, 'uni', false);
                    StandardDeviationofClustActivityOnset{f} = cellfun(@(x,y) x(y), StandardDeviationofClustActivityOnset{f}, FilteredClusts, 'uni', false);
                    StandardDeviationofNormClustActivityOnset{f} = cellfun(@(x,y) x(y), StandardDeviationofNormClustActivityOnset{f}, FilteredClusts, 'uni', false);
                    LeverPositionatClustActivityOnset{f} = cellfun(@(x,y) x(y), LeverPositionatClustActivityOnset{f}, FilteredClusts, 'uni', false);
                    LeverVelocityatClustActivityOnset{f} = cellfun(@(x,y) x(y), LeverVelocityatClustActivityOnset{f}, FilteredClusts, 'uni', false);
                    ShuffledClustActivityStart{f} = cellfun(@(x,y) x(y), ShuffledClustActivityStart{f}, FilteredClusts, 'uni', false);
                    ShuffledActivityStartNormalizedtoMovementLength{f} = cellfun(@(x,y) x(y), ShuffledActivityStartNormalizedtoMovementLength{f}, FilteredClusts, 'uni', false);
                    StandardDeviationofShuffledActivityOnset{f} = cellfun(@(x,y) x(y), StandardDeviationofShuffledActivityOnset{f}, FilteredClusts, 'uni', false);
                    StandardDeviationofNormShuffledActivityOnset{f} = cellfun(@(x,y) x(y), StandardDeviationofNormShuffledActivityOnset{f}, FilteredClusts, 'uni', false);
                    LeverPositionatShuffledActivityOnset{f} = cellfun(@(x,y) x(y), LeverPositionatShuffledActivityOnset{f}, FilteredClusts, 'uni', false);
                    LeverVelocityatShuffledActivityOnset{f} = cellfun(@(x,y) x(y), LeverVelocityatShuffledActivityOnset{f}, FilteredClusts, 'uni', false);
                    ClustActivityStartHypothesisTest{f} = cellfun(@(x,y) x(y), ClustActivityStartHypothesisTest{f}, FilteredClusts, 'uni', false);
                    FMActivityStartRelativetoMovement{f} = cellfun(@(x,y) x(y), FMActivityStartRelativetoMovement{f}, FilteredClusts, 'uni', false);
                    MRSDMActivityStartRelativetoMovement{f} = cellfun(@(x,y) x(y), MRSDMActivityStartRelativetoMovement{f}, FilteredClusts, 'uni', false);
                else
                    NewSpinesCorrwithNearbyEarlyMRSs{f} = cellfun(@nanmax, AllClusterCorrelationsbyNewSpine{f}, 'uni', false);
                    MoveCentricClusterCorrelation{f} = cellfun(@nanmax, AllMoveCentricClusterCorrelationsbyNewSpine{f}, 'uni', false);
                end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%% Now that you've cycle through all possible clusters,
                %%% consider the movements both with ANY observed cluster
                %%% co-activity and without any such observed activity
                %%% (all clusters should be considered at once!)
                
                prct_count = 1;
                for p = prctvals
                    if filterclusters
                        if any(cellfun(@isempty, CoActiveDuringMovement_Addresses{prct_count}))
                            FilteredClusts = ClustwithHighestCorrelation{f};
                            FilteredClusts = FilteredClusts(~cellfun(@isempty, CoActiveDuringMovement_Addresses{prct_count}));
                            CoActiveDuringMovement_Addresses{prct_count} = CoActiveDuringMovement_Addresses{prct_count}(~cellfun(@isempty, CoActiveDuringMovement_Addresses{prct_count}));
                        end    
                        ClustSelect = cellfun(@(x,y) x(y), CoActiveDuringMovement_Addresses{prct_count}, FilteredClusts,'uni', false);
                        ChosenClusterAddresses{prct_count} = unique(cell2mat(horzcat(ClustSelect{:})'));
                    else
                        ChosenClusterAddresses{prct_count} = unique(cell2mat(horzcat(CoActiveDuringMovement_Addresses{prct_count}{:})')); %%% If you want to use all cluster co-activity as representative 
                    end
                    %======================================================
                    NumMovs(1,prct_count) = length(ChosenClusterAddresses{prct_count});
                    AllClusterCoActivePeriods = ChosenClusterAddresses{prct_count}; AllClusterCoActivePeriods = AllClusterCoActivePeriods(~isnan(AllClusterCoActivePeriods));
                    framesofinterest = frames_during_targetperiods(AllClusterCoActivePeriods);
                    if ~isempty(framesofinterest)
                        [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                        movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                        movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                        thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                        CoAMC = thissessionmovementcorr(:); %%% Finding the correlation at this point assumes that movements co-occurring with ANY cluster co-activation should be differently correlated... if this is true to the extreme, then you might also correlate movements with such activity across sessions/fields, which would suggest that clusters in general represent the modified circuit
                        CoAMdC = movementcorr(end,:);
                    else
                        ExtractedTraces = [];
                        CoAMC = [];
                        CoAMdC = [];
                    end
                    if p == chosen_prct
                        ChosenExtractedTraces = ExtractedTraces;
                        CoActiveMovementCorr = CoAMC;
                        CoActiveMovementCorrwithModelMovement = CoAMdC;
                        UsedAddresses = ChosenClusterAddresses{prct_count};
                    end
                    modelcorrvalues(prct_count) = nanmedian(CoAMdC);
                    movcorrvalues(prct_count) = nanmedian(CoAMC);
                    prct_count = prct_count+1;
                end
                
                StereotypyDiagnostics{f}{ns}{1}.CombinedModelCorrValues = modelcorrvalues;
                StereotypyDiagnostics{f}{ns}{1}.CombinedMoveCorrValues = movcorrvalues;

                NumberofMovementswithAnyClusterCoActivity(f,:) = NumMovs;
                FractionofMovementswithAnyClusterCoActivity(f,:) = NumMovs./length(frames_during_targetperiods);

                MovementswithClusteredCoActivity{f} = [MovementswithClusteredCoActivity{f}, ChosenExtractedTraces];
                CorrelationofMovementswithCoActiveClusterActivity{f} = CoActiveMovementCorr;
                CoActiveClusterMovementsCorrelationwithModelMovement{f} = CoActiveMovementCorrwithModelMovement;
                %==========================================================
                %==========================================================
                %%% Perform the same with frequency-matched control spines
                %==========================================================
                movements_to_exclude = ChosenClusterAddresses{logical(prctvals==chosen_prct)};  %%% Decide carefully! Can exclude just cluster co-activity, or any movements that contain any activity from either spine
                AllCompCoActivePeriods = unique(comp_CoActiveAddresses{f}); AllCompCoActivePeriods = AllCompCoActivePeriods(~isnan(AllCompCoActivePeriods));
                AllCompCoActivePeriods = setdiff(AllCompCoActivePeriods,movements_to_exclude);
                framesofinterest = frames_during_targetperiods(AllCompCoActivePeriods);
                if ~isempty(framesofinterest)
                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    CompMovementCorr = thissessionmovementcorr(:); 
                    CompCorrwithModelMovement = movementcorr(end,:);
                else
                    ExtractedTraces = [];
                    CompMovementCorr = [];
                    CompCorrwithModelMovement = [];
                end
                MovementswithFMControlCoActivity{f} = ExtractedTraces;
                CorrelationofMovementswithCoActiveFMControlActivity{f} = CompMovementCorr;
                FMControlMovementsCorrelationwithModelMovement{f} = CompCorrwithModelMovement;
                %==========================================================
                
                AllMRSDMPeriods = unique(MRSDM_CoActiveAddresses{f}); AllMRSDMPeriods = AllMRSDMPeriods(~isnan(AllMRSDMPeriods));
                framesofinterest = frames_during_targetperiods(AllMRSDMPeriods);
                if ~isempty(framesofinterest)
                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    MRSDMMovementCorr = thissessionmovementcorr(:);
                    MRSDMCorrwithModelMovement = movementcorr(end,:);
                else
                    ExtractedTraces = [];
                    MRSDMMovementCorr = [];
                    MRSDMCorrwithModelMovement = [];
                end
                MovementswithMRSDMCoActivity{f} = ExtractedTraces;
                CorrelationofMovementswithCoActiveMRSDMControlActivity{f} = MRSDMMovementCorr;
                MRSDMControlMovementsCorrelationwithModelMovement{f} = MRSDMCorrwithModelMovement;
                
                %==========================================================
                %%% Every other spine combination
                if length(AllOtherSpines)>1
                    spine_combos = nchoosek(1:length(AllOtherSpines),2);
                else
                    spine_combos = [];
                    AllOtherSpinePairsMoveCorr = [];
                    AllOtherSpinePairsCorrwithModelMovement = [];
                end
                for os = 1:size(spine_combos,1)
                    binaryOtherSpinescoactivity = AllOtherSpineBinarizedAligned(spine_combos(os,1),:)& AllOtherSpineBinarizedAligned(spine_combos(os,2),:);
                    sp1Act = AllOtherSpineActivityAligned(spine_combos(os,1),:); sp1Act(sp1Act<0) = 0;
                    sp2Act = AllOtherSpineActivityAligned(spine_combos(os,2),:); sp2Act(sp2Act<0) = 0;
                    analogOtherCoATrace = sp1Act.*sp2Act;
                    if lower_thresh_for_coact
                        coactivethresh = [];
                        switch useSDorPRCT
                            case 'PRCT'
                                coactivethresh = prctile(analogOtherCoATrace, chosen_prct,2);
                            case 'SD'
                                for cs = 1:size(analogOtherCoATrace,1)
                                    coactivethresh(cs,1) = chosen_prct*std(analogOtherCoATrace(cs,:));
                                end
                        end
%                         contingA = analogOtherCoATrace>coactivethresh;
%                         threshtouse = min(coactivethresh, staticthresh(chosen_address));
                        if use_dFoF_not_binarized
                            threshtouse = coactivethresh;
                            contingA = analogOtherCoATrace>threshtouse;
                            contingB = sp1Act>mindFoFtoconsiderCoActive;
                            contingC = sp2Act>mindFoFtoconsiderCoActive;
                            binaryOtherSpinescoactivity = (contingA & contingB & contingC) | binaryOtherSpinescoactivity;
                        else
                        end
                    end
                    OtherVariables.IsCluster = 0;
                    OtherVariables.DoShuffling = 0;
                    [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binaryOtherSpinescoactivity, MovementBlocks,OtherVariables);
                    framesofinterest = frames_during_targetperiods(MovementInfo.ActivityDuringMovement_Addresses);
                    if ~isempty(framesofinterest)
                        [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,binaryOtherSpinescoactivity, rewardperiodsLate, TimingValues, ImagingFrequency);
                        movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                        movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                        thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                        AllOtherSpinePairsMoveCorr(1,os) = nanmedian(thissessionmovementcorr(:)); 
                        AllOtherSpinePairsCorrwithModelMovement(1,os) = nanmedian(movementcorr(end,:));
                    else
                        AllOtherSpinePairsMoveCorr(1,os) = NaN;
                        AllOtherSpinePairsCorrwithModelMovement(1,os) = NaN;
                    end
                end
                MovementswithAllOtherSpineCoActivity{f} = ExtractedTraces;
                CorrelationofMovementswithAllOtherSpineCoActivity{f} = AllOtherSpinePairsMoveCorr;
                AllOtherSpineCoActivityMovementsCorrelationwithModelMovement{f} = AllOtherSpinePairsCorrwithModelMovement;

                %==========================================================
                
                AllMoveOnlyPeriods = unique(MoveOnlyAddresses{f}); AllMoveOnlyPeriods = AllMoveOnlyPeriods(~isnan(AllMoveOnlyPeriods));
                framesofinterest = frames_during_targetperiods(AllMoveOnlyPeriods);
                if ~isempty(framesofinterest)
                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    MRSOnlyMovementCorr = thissessionmovementcorr(:);
                    MRSOnlyCorrwithModelMovement = movementcorr(end,:);
                else
                    ExtractedTraces = [];
                    MRSOnlyMovementCorr = [];
                    MRSOnlyCorrwithModelMovement = [];
                end
                MovementswithMRSOnlyActivity{f} = ExtractedTraces;
                CorrelationofMovementswithMRSOnlyActivity{f} = MRSOnlyMovementCorr;
                MRSOnlyMovementsCorrelationwithModelMovement{f} = MRSOnlyCorrwithModelMovement;
                
                %==========================================================
                AllNewOnlyPeriods = unique(NewOnlyAddresses{f}); AllNewOnlyPeriods = AllNewOnlyPeriods(~isnan(AllNewOnlyPeriods));
                framesofinterest = frames_during_targetperiods(AllNewOnlyPeriods);
                if ~isempty(framesofinterest)
                    [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                    movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    NSOnlyMovementCorr = thissessionmovementcorr(:);
                    NSOnlyCorrwithModelMovement = movementcorr(end,:);
                else
                    ExtractedTraces = [];
                    NSOnlyMovementCorr = [];
                    NSOnlyCorrwithModelMovement = [];
                end
                MovementswithNSOnlyActivity{f} = ExtractedTraces;
                CorrelationofMovementswithNSOnlyActivity{f} = NSOnlyMovementCorr;
                NSOnlyMovementsCorrelationwithModelMovement{f} = NSOnlyCorrwithModelMovement;
                %==========================================================
                %%% Perform the same WITHOUT cluster (or other) co-activity
                prct_count = 1;
                for p = prctvals
                    movements_to_exclude = ChosenClusterAddresses{prct_count};  %%% Decide carefully! Can exclude just cluster co-activity, or any movements that contain any activity from either spine, e.g.
                    framesofinterest = frames_during_targetperiods(setdiff(1:length(frames_during_targetperiods),movements_to_exclude));
                    if ~isempty(framesofinterest)
                        [ExtractedTraces] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate, TimingValues, ImagingFrequency);
                        movementcorr = corrcoef([ExtractedTraces, ModelMovement']);
                        movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;   %%% Ignore the diagonal
                        thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                        OMC = thissessionmovementcorr(:);
                        OMdMC = movementcorr(end,:);
                    else
                        ExtractedTraces = [];
                        OMC = [];
                        OMdMC = [];
                    end
                    if p == chosen_prct
                        Chosen_ExtractedTraces = ExtractedTraces;
                        OtherMovementCorr = OMC;
                        OtherCorrwithModelMovement = OMdMC;
                    end
                    modelcorrvalues(prct_count) = nanmedian(OMdMC);
                    movcorrvalues(prct_count) = nanmedian(OMC);
                    prct_count = prct_count+1;
                end
                
                StereotypyDiagnostics{f}{ns}{1}.CombinedOtherModelCorrValues = modelcorrvalues;
                StereotypyDiagnostics{f}{ns}{1}.CombinedOtherMoveCorrValues = movcorrvalues;

                WithoutGroupMovements{f} = Chosen_ExtractedTraces;
                MovementCorrelationofAllOtherMovements{f} = OtherMovementCorr;
                AllOtherMovementsCorrelationwithModelMovement{f} = OtherCorrwithModelMovement;
                %==========================================================
            else
%                 framesofinterest = frames_during_targetperiods;
%                 ExtractedTraces = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest, [], rewardperiodsLate, TimingValues, ImagingFrequency);
%                 movementcorr = corrcoef([ExtractedTraces,ModelMovement']);
%                 movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
%                 thissessionmovementcorr = movementcorr(1:end-1,1:end-1);
%                 WithoutGroupMovements{f} = ExtractedTraces;
%                 MovementCorrelationofAllOtherMovements{f} = thissessionmovementcorr(:);
%                 AllOtherMovementsCorrelationwithModelMovement{f} = movementcorr(end,:);
%                 ==========================================================
%                 NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner+1;
%                 DistancesBetweenNewSpinesandNearestEarlyMovementSpines{f} = nan(1,length(NewSpines{f}));
%                 LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions{f} = nan(1,length(NewSpines{f}));
                for ns = 1:length(NewSpines{f})
                    NewSpineAllSpinesDistance{f}(ns,:) = AllDendriteDistances{f}(NewSpines{f}(ns),:);
                    NewSpineAllSpinesMidCorr{f}(ns,:) = AllMidSpineCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateCorr{f}(ns,:) = AllLateSpineCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateRawCorr{f}(ns,:) = AllLateSpineRawTraceCorrelations(NewSpines{f}(ns),:);
                    NewSpineAllSpinesLateNoiseCorr{f}(ns,:) = AllLateSpineNoiseCorrelations(NewSpines{f}(ns),:);
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            NumberofPersistentMovementSpinesClustered{f} = persistentclustercount;
            TaskCorrelationofNearbyEarlyMRSs{f} = behaviorcorrdataearly(:,ClusteredEarlyMoveSpines{f});
            NumberofClusteredMoveSpines{f} = length(unique(ClusteredEarlyMoveSpines{f}));
            TaskCorrelationofClusteredNewSpines{f} = behaviorcorrdataearly(:,unique(ClusteredNewSpines{f}));
            MovementReliabilityofNearbyEarlyMRSs{f} = FieldData{f}.StatClass{1}.AllSpineReliability(ClusteredEarlyMoveSpines{f});
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %==============================================================
            %% ============================================================
            
            %%%%% Compare new spines to LATE session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentNew)
                lateMRStouse = AllMovementSpinesOnLateSession;
%                 lateMRStouse = OtherMovementSpinesThatArentNew;
                for ns = 1:length(NewSpines{f})
                    NewSpinestoLateMovementSpines = [];
                    NewSpinesLateMovementSpinesLateCorr = [];
                    NewSpinesCorrwithCloseMRS = nan;
                    NewSpinestoRandomSpines = [];
                    DistMatchedNonLateMRPartnersCorr = [];
                    NewSpinestoShuffledMovementSpines = [];
                    count = 1;
                    closecount = 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines{f}(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
%                     if ~ismember(ParentDend, find(FieldData{f}.StatClass{end}.MovementDends))
%                         continue
%                     end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for os = 1:length(lateMRStouse)  %%% Compare new spines to other *extant* (not new) movement-related spines on the same dendrite
                        [val, ~] = sort([NewSpines{f}(ns),lateMRStouse(os)]);
                        NewSpinestoLateMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        NewSpinesLateMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));
                        
                        if NewSpinestoLateMovementSpines(1,count)<clusterdistance
                            NewSpinesCorrwithCloseMRS(1,closecount) = NewSpinesLateMovementSpinesLateCorr(1,count);
                            ClusteredLateMoveSpines{f} = [ClusteredLateMoveSpines{f},lateMRStouse(os)];
                            closecount = closecount+1;
                        end
                        ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines{f}(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                        randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        while randomspinefromsamedend == NewSpines{f}(ns)
                            randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        end
                        [val, ~] = sort([NewSpines{f}(ns),randomspinefromsamedend]);
                        NewSpinestoRandomSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        DistanceMatchedNonMRPartners = find(AllDendriteDistances{f}(val(1),:)<clusterdistance);
                        DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(AllMovementSpinesOnLateSession, MovementSpinestoCompare));
                        DistMatchedNonLateMRPartnersCorr(1,count) = nanmean(AllLateSpineCorrelations(val(1), DistanceMatchedNonMRPartners));
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledLateMovementLabels{shuff})
                            [val, ~] = sort([NewSpines{f}(ns),ShuffledLateMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        NewSpinestoShuffledMovementSpines(1,count) = nanmin(shuffleddistances);
                        shuffleddistances = [];
                        count = count+1;
                    end
                    [DistancesBetweenNewSpinesandLateMovementSpines{f}(ns),ind] = nanmin(NewSpinestoLateMovementSpines);
                    LateCorrofNewSpinesandNearestMovementSpinefromLateSessions{f}(ns) = NewSpinesLateMovementSpinesLateCorr(ind);
                    NewSpinesCorrwithNearbyLateMRSs{f}(ns) = max(NewSpinesCorrwithCloseMRS);
                    NewSpinesCorrwithDistanceMatchedNonLateMRSs{f}(ns) = nanmean(DistMatchedNonLateMRPartnersCorr);
                    DistancesBetweenNewSpinesandRandomSpines{f}(ns) = NewSpinestoRandomSpines(randi(length(NewSpinestoRandomSpines)));
                    DistancesBetweenNewSpinesandShuffledMovementSpines{f}(ns) = nanmean(NewSpinestoShuffledMovementSpines);
                end
            else
                DistancesBetweenNewSpinesandLateMovementSpines{f} = nan(1,length(NewSpines{f}));
                LateCorrofNewSpinesandNearestMovementSpinefromLateSessions{f} = nan(1,length(NewSpines{f}));
            end %%% End "late" variable section
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TaskCorrelationofNearbyLateMRSs{f} = behaviorcorrdatalate(:,ClusteredLateMoveSpines{f});
            MovementReliabilityofNearbyLateMRSs{f} = FieldData{f}.StatClass{end}.AllSpineReliability(ClusteredLateMoveSpines{f});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%% Highly Correlated Partner Section %%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            dendcorrectionmat = AllDendriteDistances{f}; 
            dendcorrectionmat(~isnan(dendcorrectionmat)) = 1;
            CorrelationsByDendrite = AllLateSpineCorrelations.*dendcorrectionmat;
            [NewSpinesMaxCorr{f}, NewSpineMaxInd] = nanmax(CorrelationsByDendrite(NewSpines{f},:),[],2); %%% Find the spine that has the highest correlation with each new spine
            allotherspines = setdiff(1:NumberofLateSpines,union(NewSpineMaxInd, NewSpines{f})); %%% For comparison, find the spine that has the maximum correlation value with every other spine ("every other" can exclude either just new spines or new spines AND their highly correlated partners)
            DistanceToMaxCorrPartner{f} = AllDendriteDistances{f}(NewSpineMaxInd);
            FractionofHCPsThatAreMR{f} = sum(ismember(NewSpineMaxInd,AllMovementSpinesOnLateSession))/length(NewSpineMaxInd);
            OtherSpinesMaxCorr{f} = max(CorrelationsByDendrite(allotherspines,:),[],2);
            NewSpineMaxCorrPartnerEarlyMoveCorrelation{f} = behaviorcorrdataearly(:,NewSpineMaxInd);
            NewSpineMaxCorrPartnerLateMoveCorrelation{f} = behaviorcorrdatalate(:,NewSpineMaxInd);
            NewSpineMaxCorrPartnerEarlyMoveReliability{f} = FieldData{f}.StatClass{1}.AllSpineReliability(NewSpineMaxInd);
            NewSpineMaxCorrPartnerLateMoveReliability{f} = FieldData{f}.StatClass{end}.AllSpineReliability(NewSpineMaxInd);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%% Find features of highly correlated pairs %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            HCPOnlywithMovement = []; NewSpineOnlywithMovement = []; CoactiveHCPClusterwithMovement = [];
            HCPOnlywithSuccess = []; NewSpineOnlywithSuccess = []; CoactiveHCPClusterwithSuccess = [];
            move_centric_HCPcluster_correlation = [];
            CoActiveHCPMovementCorr = [];CoActiveHCPMovementCorrwithModelMovement= []; OtherMovementCorr= []; Comp_CoActiveHCPMovementCorr = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%% End initialization for HCP section
            highcorrcount = 1;
            HCPCoActiveDuringMovement_Addresses = {};
            HCPCompCoActiveDuringMovement_Addresses = {};
            for hcp = 1:length(NewSpineMaxInd) %%% Note: every new spine should should have a corresponding max correlated partner, so you can use "hcp" as an index for new spines;
                if strcmpi(sensor, 'GCaMP')
                    HighCorrThresh = 0.25;
                elseif strcmpi(sensor, 'GluSNFR')
                    HighCorrThresh = 0.1;
                end
                if NewSpinesMaxCorr{f}(hcp) >= HighCorrThresh
                    switch AnalysisType
                        case 'Subtract'
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSpineActivity(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['HCPActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSpineActivity(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['HCPBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                            eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                        case 'Exclude'
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpines{f}(hcp)), ',:).*', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:).*', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:);'])
                            NewSpineActivityAligned = NewSpineActivityAligned.*NewSpineBinarizedAligned;
                            eval(['HCPActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpineMaxInd(hcp)), ',:).*', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['HCPBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:).*', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            HCPActivityAligned = HCPActivityAligned.*HCPBinarizedAligned;
                            eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                            eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                            AllOtherSpineActivityAligned = AllOtherSpineActivityAligned.*AllOtherSpineBinarizedAligned;
                        case 'Ignore'
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['NewSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.BinarizedOverallSpineData(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['HCPActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.ProcessedSpineActivity(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['HCPBinarizedAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.BinarizedOverallSpineData(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.ProcessedSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                            eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.BinarizedOverallSpineData([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%% Find spines with similar frequencies for best comparisons
                    OtherSpFreq = [];
                    for spf = 1:size(AllOtherSpineActivityAligned,1)
                        OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineBinarizedAligned(spf,:))>0))/(length(AllOtherSpineBinarizedAligned)/(ImagingFrequency*60));
                    end
                    NewSpFreq = numel(find(diff(NewSpineBinarizedAligned)))/(length(NewSpineBinarizedAligned)/(ImagingFrequency*60));
                        [~, CompSpFreqMatchedtoNS] = nanmin(abs(OtherSpFreq-NewSpFreq));
                        OtherSpFreq(CompSpFreqMatchedtoNS) = NaN;
                    HCPFreq = numel(find(diff(HCPBinarizedAligned)))/(length(HCPBinarizedAligned)/(ImagingFrequency*60));
                        [~, CompSpFreqMatchedtoHCP] = nanmin(abs(OtherSpFreq-HCPFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    binarycoactivetrace = HCPBinarizedAligned.*NewSpineBinarizedAligned;
                    HCPonly = corrcoef([binarizedleverLate, HCPActivityAligned']);
                    newonly = corrcoef([binarizedleverLate, NewSpineActivityAligned']);
                    coactive = corrcoef([binarizedleverLate, binarycoactivetrace']);
                    HCPOnlywithMovement(1,highcorrcount) = HCPonly(1,2);
                    NewSpineOnlywithMovement(1,highcorrcount) = newonly(1,2);
                    CoactiveHCPClusterwithMovement(1,highcorrcount) = coactive(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    binarycomp_coactivetrace = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoNS,:).*AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoHCP,:);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    HCPonly = corrcoef([successtraceLate, HCPActivityAligned']);
                    newonly = corrcoef([successtraceLate, NewSpineActivityAligned']);
                    coactive = corrcoef([successtraceLate, binarycoactivetrace']);
                    HCPOnlywithSuccess(1,highcorrcount) = HCPonly(1,2);
                    NewSpineOnlywithSuccess(1,highcorrcount) = newonly(1,2);
                    CoactiveHCPClusterwithSuccess(1,highcorrcount) = coactive(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    move_centric_newspineactivity = NewSpineActivityAligned.*successtraceLate';
                    move_centric_HCPactivity = HCPActivityAligned.*successtraceLate';
                    move_centric_correlations = corrcoef([move_centric_newspineactivity', move_centric_HCPactivity']);
                    move_centric_HCPcluster_correlation(1,highcorrcount) = move_centric_correlations(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %======================================================
                    
                    OtherVariables.TimingValues = TimingValues;
                    OtherVariables.ImagingFrequency = ImagingFrequency;
                    OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                    OtherVariables.ModelMovement = ModelMovement;
                    OtherVariables.LearningPhase = 'Late';
                    OtherVariables.Focus = FocusOnWhichMovements;
                    OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                    OtherVariables.IsCluster = 0;
                    OtherVariables.DoShuffling = 0;

                    [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binarycoactivetrace, MovementBlocks,OtherVariables);
                    
                    HCPCoActiveDuringMovement_Addresses{highcorrcount} = MovementInfo.ActivityDuringMovement_Addresses;

                    %%%%%%%%%%%%%
                    
                    OtherVariables.TimingValues = TimingValues;
                    OtherVariables.ImagingFrequency = ImagingFrequency;
                    OtherVariables.IsMovementRewarded = IsMovementRewardedLate{f};
                    OtherVariables.ModelMovement = ModelMovement;
                    OtherVariables.LearningPhase = 'Late';
                    OtherVariables.Focus = FocusOnWhichMovements;
                    OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                    OtherVariables.DoShuffling = 0;

                    [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binarycomp_coactivetrace, MovementBlocks,OtherVariables);
                    
                    HCPCompCoActiveDuringMovement_Addresses{highcorrcount} = MovementInfo.ActivityDuringMovement_Addresses;
                    %======================================================

                    highcorrcount = highcorrcount+1;
                end
            end
            %==============================================================
            framesofinterest = frames_during_targetperiods(unique(cell2mat(HCPCoActiveDuringMovement_Addresses')));
            if ~isempty(framesofinterest)
                [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate,TimingValues, ImagingFrequency);
            else
                SuccessfulPresseswithoutCoactivity = [];
            end
            movementcorr = corrcoef(SuccessfulPresseswithoutCoactivity);
            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
            MovementCorrelationwithCoActiveHCPClusters{f} = nanmedian(movementcorr(:));
            %==============================================================
            framesofinterest = frames_during_targetperiods(setdiff(1:length(frames_during_targetperiods),unique(cell2mat(HCPCoActiveDuringMovement_Addresses'))));
            if ~isempty(framesofinterest)
                [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate,TimingValues, ImagingFrequency);
            else
                SuccessfulPresseswithoutCoactivity = [];
            end
            movementcorr = corrcoef(SuccessfulPresseswithoutCoactivity);
            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
            MovementCorrelationofAllOtherNonHCPMovements{f} = nanmedian(movementcorr(:));
            %==============================================================
            framesofinterest = frames_during_targetperiods(unique(cell2mat(HCPCompCoActiveDuringMovement_Addresses')));
            if ~isempty(framesofinterest)
                [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest,[], rewardperiodsLate,TimingValues, ImagingFrequency);
            else
                SuccessfulPresseswithoutCoactivity = [];
            end
            movementcorr = corrcoef(SuccessfulPresseswithoutCoactivity);
            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
            MovementCorrelationofHCPComparatorSpines{f} = nanmedian(movementcorr(:));
            %==============================================================
%             ClusteredNewSpineCorrwithDendrite{f} = DendCorrNewSpineOnly;
            HCPClusteredNewSpineCorrwithMovement{f} = NewSpineOnlywithMovement;
            HCPClusteredNewSpineCorrwithSuccess{f} = NewSpineOnlywithSuccess;
%             ClusteredMoveSpineCorrwithDendrite{f} = DendCorrHCPOnly;
            HCPCorrwithMovement{f} = HCPOnlywithMovement;
            HCPCorrwithSuccess{f} = HCPOnlywithSuccess;
%             CoActiveClusterCorrwithDendrite{f} = DendCorrCoactiveCluster;
            CoActiveHCPClusterCorrwithMovement{f} = CoactiveHCPClusterwithMovement;
            CoActiveHCPClusterCorrwithSuccess{f} = CoactiveHCPClusterwithSuccess;
            MoveCentricHCPClusterCorrelation{f} = move_centric_HCPcluster_correlation;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for ns = 1:length(NewSpines{f})
                NewSpinesBehaviorCorrelation{f}(ns,1:9) = behaviorcorrdatalate(:,ns);
            end
            NonNewSpinesBehaviorCorrelationEarly{f} = behaviorcorrdataearly(:,setdiff(1:NumberofEarlySpines,union(NewSpines{f}, AllMovementSpinesOnEarlySession)));
            NonNewSpinesBehaviorCorrelationLate{f} = behaviorcorrdatalate(:,setdiff(1:NumberofLateSpines,union(NewSpines{f}, AllMovementSpinesOnLateSession)));
        else
            %==============================================================
            
            %%% For including movements where there are no observed new
            %%% spines (What's fair?) ** As of 10/11/2019, this only hurts
            %%% the comparison!
%             framesofinterest = frames_during_targetperiods;
%             ExtractedTraces = ExtractMovementswithKnownBounds(levertraceLate, binarizedleverLate, framesofinterest, [], rewardperiodsLate, TimingValues, ImagingFrequency);
%             movementcorr = corrcoef([ExtractedTraces,ModelMovement']);
%             movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
%             thissessionmovementcorr = movementcorr(1:end-1,1:end-1);
%             WithoutGroupMovements{f} = ExtractedTraces;
%             MovementCorrelationofAllOtherMovements{f} = thissessionmovementcorr(:);
%             AllOtherMovementsCorrelationwithModelMovement{f} = movementcorr(end,:);
            
            %==============================================================
        end
        MovementReliabilityofOtherMoveSpines{f} = FieldData{f}.StatClass{1}.AllSpineReliability(setdiff(AllMovementSpinesOnEarlySession,ClusteredEarlyMoveSpines{f}));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(ElimSpines{f})    %%% If there are new spines, find out whether they are close to a nearby movement spine
            ElimSpinesThatWereMR = ElimSpines{f}(ismember(ElimSpines{f}, find(FieldData{f}.StatClass{1}.DendSub_MovementSpines)));
            NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR+sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(ElimSpines{f}));
            OtherMovementSpinesThatArentElim = setdiff(AllMovementSpinesOnLateSession,ElimSpines{f});
            %%% Compare eliminated spines to early session features
            if isThreeSessions
                MovementSpinestoCompare = AllMovementSpinesOnLateSession;
            else
                MovementSpinestoCompare = AllMovementSpinesOnLateSession;
            end
            if ~isempty(MovementSpinestoCompare)
                for es = 1:length(ElimSpines{f})
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch AnalysisType
                        case 'Subtract'
                            ElimSpineActivity = FieldData{f}.CalciumData{1}.SynapseOnlyBinarized_DendriteSubtracted(ElimSpines{f}(es),:);
                            eval(['ElimSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.DendSubSpineActivity(', num2str(ElimSpines{f}(es)), ',:);'])
                            eval(['ElimSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.DendSubSynapseOnlyBinarized(', num2str(ElimSpines{f}(es)), ',:);'])
                        case 'Exclude'
                            ElimSpineActivity = FieldData{f}.CalciumData{1}.SynapseOnlyBinarized(ElimSpines{f}(es),:);
                            eval(['ElimSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.ProcessedSpineActivity(', num2str(ElimSpines{f}(es)), ',:);'])
                            eval(['ElimSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.SynapseOnlyBinarized(', num2str(ElimSpines{f}(es)), ',:);'])
                            ElimSpineActivityAligned = ElimSpineActivityAligned.*ElimSpineBinarizedAligned;
                        case 'Ignore'
                            ElimSpineActivity = FieldData{f}.CalciumData{1}.OverallSpineActivity(ElimSpines{f}(es),:);
                            eval(['ElimSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.ProcessedSpineActivity(', num2str(ElimSpines{f}(es)), ',:);'])
                            eval(['ElimSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.BinarizedOverallSpineData(', num2str(ElimSpines{f}(es)), ',:);'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ElimSpinestoEarlyMovementSpines = [];
                    ElimSpinestoShuffledEarlyMovementSpines = [];
                    ElimSpinesCorrwithCloseMRS = nan;
                    DistMatchedtoNSPartnersCorr = NaN;
                    move_centric_anticluster_correlation = NaN; MoveCentricDistMatchedtoAntiClustCorrelation = NaN;
                    CoActiveAntiClustMovementCorr = NaN;CoActiveAntiClustMovementCorrwithModelMovement = NaN; 
                    OtherMovementCorrElimVersion = NaN; Comp_CoActiveAntiClusterMovementCorr = NaN;OtherCorrwithModelMovementElimVersion = NaN; Comp_CoActiveAntiClusterMovementCorrwithModelMovement = NaN;
                    count = 1;
                    closecount = 1;
                    AntiCoActiveDuringMovement_Addresses = {}; AC_comp_CoActiveAddresses = {};
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for ms = 1:length(MovementSpinestoCompare) 
                        switch AnalysisType
                            case 'Subtract'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.DendSubSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.DendSubSynapseOnlyBinarized(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                            case 'Exclude'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.ProcessedSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.SynapseOnlyBinarized(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                MoveSpineActivityAligned = MoveSpineActivityAligned.*MoveSpineBinarizedAligned;
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.ProcessedSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                                AllOtherSpineActivityAligned = AllOtherSpineActivityAligned.*AllOtherSpineBinarizedAligned;
                            case 'Ignore'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.ProcessedSpineActivity(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['MoveSpineBinarizedAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.BinarizedOverallSpineData(', num2str(MovementSpinestoCompare(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.ProcessedSpineActivity([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                                eval(['AllOtherSpineBinarizedAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.BinarizedOverallSpineData([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), MovementSpinestoCompare(ms)))), '],:);'])
                        end
                        MoveSpineActivityAligned(isnan(MoveSpineActivityAligned)) = 0;
                        AllOtherSpineActivityAligned(isnan(AllOtherSpineActivityAligned)) = 0;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [val, ~] = sort([ElimSpines{f}(es), MovementSpinestoCompare(ms)]);
                        ElimSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        CorrElimSpinestoEarlyMovementSpines(1,count) = AllEarlySpineCorrelations(val(1), val(2));
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%% Anti-Clustering Section 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        if ElimSpinestoEarlyMovementSpines(1,count)<clusterdistance 
                            ElimSpinesCorrwithCloseMRS(1,closecount) = CorrElimSpinestoEarlyMovementSpines(1,count);
                            AntiClusteredElimSpines{f} = [AntiClusteredElimSpines{f}, ElimSpines{f}(es)];
                            AntiClusteredEarlyMoveSpines{f} = [AntiClusteredEarlyMoveSpines{f},MovementSpinestoCompare(ms)];
                            binarycoactivetrace = MoveSpineBinarizedAligned.*ElimSpineBinarizedAligned;
                            %%% Find frequency-matched spines
                            OtherSpFreq = [];
                            for spf = 1:size(AllOtherSpineActivityAligned,1)
                                OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineBinarizedAligned(spf,:))>0))/(length(AllOtherSpineBinarizedAligned)/(ImagingFrequency*60));
                            end
                            ElimSpFreq = numel(find(diff(ElimSpineBinarizedAligned)))/(length(ElimSpineBinarizedAligned)/(ImagingFrequency*60));
                                [~, CompSpFreqMatchedtoES] = nanmin(abs(OtherSpFreq-ElimSpFreq));
                                OtherSpFreq(CompSpFreqMatchedtoES) = NaN;
                            ACMRSFreq = numel(find(diff(MoveSpineBinarizedAligned)))/(length(MoveSpineBinarizedAligned)/(ImagingFrequency*60));   %%% Anti-Clustered MRS frequency
                                [~, CompSpFreqMatchedtoACMRS] = nanmin(abs(OtherSpFreq-ACMRSFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                            binarycomp_coactivetrace = AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoES,:).*AllOtherSpineBinarizedAligned(CompSpFreqMatchedtoACMRS,:);
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% "NOISE CORRELATION "
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            switch FocusOnWhichMovements
                                case 'Rewarded'
                                    target_movements_trace = successtraceEarly;
                                case 'All'
                                    target_movements_trace = binarizedleverEarly;
                                case 'CuedRewarded'
                                    target_movements_trace = CRMovementsTraceEarly;
                            end
                            move_centric_elimspineactivity = ElimSpineActivityAligned(:,cell2mat(frames_during_targetperiodsEarly));
                            move_centric_movespineactivity = MoveSpineActivityAligned(:,cell2mat(frames_during_targetperiodsEarly));
                            anticlust_move_centric_correlations = corrcoef([move_centric_elimspineactivity', move_centric_movespineactivity']);
                            move_centric_anticluster_correlation(1,closecount) = anticlust_move_centric_correlations(1,2);
                            if move_centric_anticluster_correlation(1,closecount) >0.1
                                disp(['Animal ', currentanimal, ', Field ', num2str(f), ' anticlustered spines ', num2str(ElimSpines{f}(es)), ' & ', num2str(MovementSpinestoCompare(ms)), ' have high noise correlation!'])
                            end
                            DistanceMatchedNonMRPartners = find(AllDendriteDistances{f}(ElimSpines{f}(es),:)<=clusterdistance);
                            DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(MovementSpinestoCompare, ElimSpines{f}));
                            switch AnalysisType
                                case 'Subtract'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSpineActivity([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                case 'Exclude'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(earlysession), '}.ProcessedSpineActivity([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                case 'Ignore'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(earlysession), '}.ProcessedSpineActivity([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                    eval(['DistanceMatchedBinarized = ', currentanimal, '_Aligned{', num2str(earlysession), '}.BinarizedOverallSpineData([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                            end
                            move_centric_distmatched_activity = DistanceMatchedActivity(:,cell2mat(frames_during_targetperiodsEarly))';
                            move_centric_distmatched_correlation = corrcoef([move_centric_elimspineactivity', move_centric_distmatched_activity]);
                            MoveCentricDistMatchedtoAntiClustCorrelation(1,closecount) = nanmedian(move_centric_distmatched_correlation(1,2:end));
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %==============================================

                            OtherVariables.TimingValues = TimingValues;
                            OtherVariables.ImagingFrequency = ImagingFrequency;
                            OtherVariables.IsMovementRewarded = IsMovementRewardedEarly{f};
                            OtherVariables.ModelMovement = ModelMovement;
                            OtherVariables.LearningPhase = 'Early';
                            OtherVariables.Focus = FocusOnWhichMovements;
                            OtherVariables.UseMaxMoveLengthCutoff = useMaxMoveLengthcutoff;
                            OtherVariables.IsCluster = 0;
                            OtherVariables.DoShuffling = 0;

                            [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binarycoactivetrace, MovementBlocks,OtherVariables);
                            
                            AntiCoActiveDuringMovement_Addresses{closecount} = MovementInfo.ActivityDuringMovement_Addresses;
                            ChanceRewardedLevelElimVersion{f} = [ChanceRewardedLevelElimVersion{f}; MovementInfo.ChanceReward];
                            IsCoActiveAntiClusterMovementRewarded{f} = [IsCoActiveAntiClusterMovementRewarded{f}; MovementInfo.IsSpecifiedMovementRewarded];

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the same features for freq-matched
                            %%% spine pairs
                            
                            OtherVariables.TimingValues = TimingValues;
                            OtherVariables.ImagingFrequency = ImagingFrequency;
                            OtherVariables.IsMovementRewarded = IsMovementRewardedEarly{f};
                            OtherVariables.ModelMovement = ModelMovement;
                            OtherVariables.LearningPhase = 'Early';
                            OtherVariables.Focus = FocusOnWhichMovements;
                            OtherVariables.DoShuffling = 0;

                            [MovementInfo] = CharacterizeMovementsDuringSpecifiedActivity(binarycomp_coactivetrace, MovementBlocks,OtherVariables);
                            
                            AC_comp_CoActiveAddresses{closecount} = MovementInfo.ActivityDuringMovement_Addresses;
                            %==============================================
                            %%%%%%%%%%%
                            closecount = closecount+1;
                        end
                        count = count+1;
                    end
                    count = 1;
                    if ~isempty(MovementSpinestoCompare)
                        for shuff = 1:shuffnum
                            shuffleddistances = nan(1,shuffnum);
                            for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                                [val, ~] = sort([ElimSpines{f}(es),ShuffledEarlyMovementLabels{shuff}(sh)]);
                                shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                            end
                            if ~isempty(shuffleddistances)
                                ElimSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                            else
                                ElimSpinestoShuffledEarlyMovementSpines(1,count) = nan;
                            end
                            count = count+1;
                        end
                    else
                        ElimSpinestoShuffledEarlyMovementSpines(1,count) = nan;
                    end
                    [DistancesBetweenElimSpinesandEarlyMovementSpines{f}(es), ind] = nanmin(ElimSpinestoEarlyMovementSpines);
                    CorrelationsofElimSpinesandEarlyMovementSpines{f}(es) = CorrElimSpinestoEarlyMovementSpines(ind);
                    ElimSpinesCorrwithNearbyMRSs{f}(es) = max(ElimSpinesCorrwithCloseMRS);
                    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines{f}(es) = nanmean(ElimSpinestoShuffledEarlyMovementSpines);
                    MoveCentricAntiClusterCorrelation{f}{es} = move_centric_anticluster_correlation;
                    MoveCentricDistanceMatchedtoAntiClustCorrelation{f}{es} = MoveCentricDistMatchedtoAntiClustCorrelation;
                end
                %==========================================================
                %%% now that you've cycled through all possible
                %%% anti-clusters, find the features of movements that have
                %%% observed anti-cluster activity and compare to those
                %%% movements that don't show (observed) anti-cluster
                %%% co-activity
                %%% 
                framesofinterest = frames_during_targetperiodsEarly(unique(cell2mat(AntiCoActiveDuringMovement_Addresses')));
                if ~isempty(framesofinterest)
                    [SuccessfulPresseswithCoActivity] = ExtractMovementswithKnownBounds(levertraceEarly, binarizedleverEarly, framesofinterest, [],rewardperiodsEarly,TimingValues,ImagingFrequency);
                    movementcorr = corrcoef([SuccessfulPresseswithCoActivity, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    CoActiveAntiClustMovementCorr = thissessionmovementcorr(:);
                    CoActiveAntiClustMovementCorrwithModelMovement = nanmedian(movementcorr(end,:));
                else
                    CoActiveAntiClustMovementCorr = NaN;
                    CoActiveAntiClustMovementCorrwithModelMovement = NaN;
                end
                MovementCorrelationwithCoActiveAntiClusters{f} = CoActiveAntiClustMovementCorr;
                CoActiveAntiClusterMovementsCorrelationwithModelMovement{f} = CoActiveAntiClustMovementCorrwithModelMovement;
                
                %==========================================================
                framesofinterest = frames_during_targetperiodsEarly(setdiff(1:length(frames_during_targetperiodsEarly),unique(cell2mat(AntiCoActiveDuringMovement_Addresses'))));
                if ~isempty(framesofinterest)
                    [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceEarly, binarizedleverEarly, framesofinterest, [],rewardperiodsEarly,TimingValues,ImagingFrequency);
                    movementcorr = corrcoef([SuccessfulPresseswithoutCoactivity, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    OtherMovementCorrElimVersion = thissessionmovementcorr(:);
                    OtherCorrwithModelMovementElimVersion = nanmedian(movementcorr(end,:));
                else
                    OtherMovementCorrElimVersion = NaN;
                    OtherCorrwithModelMovementElimVersion = NaN;
                end
                MovementCorrelationofAllOtherMovementsElimVersion{f} = OtherMovementCorrElimVersion;
                AllOtherMovementsCorrelationwithModelMovementElimVersion{f} = OtherCorrwithModelMovementElimVersion;
                
                framesofinterest = frames_during_targetperiodsEarly(setdiff(1:length(frames_during_targetperiodsEarly),unique(cell2mat(AC_comp_CoActiveAddresses'))));
                if ~isempty(framesofinterest)
                    [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceEarly, binarizedleverEarly, framesofinterest, [],rewardperiodsEarly,TimingValues,ImagingFrequency);
                    movementcorr = corrcoef([SuccessfulPresseswithoutCoactivity, ModelMovement']);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                    Comp_CoActiveAntiClusterMovementCorr = thissessionmovementcorr(:);
                    Comp_CoActiveAntiClusterMovementCorrwithModelMovement = nanmedian(movementcorr(end,:));
                else
                    Comp_CoActiveAntiClusterMovementCorr = NaN;
                    Comp_CoActiveAntiClusterMovementCorrwithModelMovement = NaN;
                end
                MovementCorrelationofFrequencyMatchedPairsElimVersion{f} = Comp_CoActiveAntiClusterMovementCorr;
                FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion{f} = Comp_CoActiveAntiClusterMovementCorrwithModelMovement;

            else
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TaskCorrelationofNearbyEarlyMRSsforElimSp{f} = behaviorcorrdataearly(:,AntiClusteredEarlyMoveSpines{f});
            MovementReliabilityofNearbyEarlyMRSsforElimSp{f} = FieldData{f}.StatClass{end}.AllSpineReliability(AntiClusteredEarlyMoveSpines{f});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Compare eliminated spines to late session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentElim)
                for es = 1:length(ElimSpines{f})
                    ElimSpinestoMovementSpines = [];
                    ElimSpinestoRandomSpines = [];
                    ElimSpinestoShuffledMovementSpines = [];
                    count = 1;
                    for os = 1:length(OtherMovementSpinesThatArentElim)
                        [val, ~] = sort([ElimSpines{f}(es),OtherMovementSpinesThatArentElim(os)]);
                        ElimSpinestoMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == ElimSpines{f}(es),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                        randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        while randomspinefromsamedend == ElimSpines{f}(es)
                            randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        end
                        [val, ~] = sort([ElimSpines{f}(es),randomspinefromsamedend]);
                        ElimSpinestoRandomSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledLateMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines{f}(es),ShuffledLateMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) =  AllDendriteDistances{f}(val(1),val(2));
                        end
                        ElimSpinestoShuffledMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    DistancesBetweenElimSpinesandMovementSpines{f}(es) = nanmin(ElimSpinestoMovementSpines);
                    DistancesBetweenElimSpinesandRandomSpines{f}(es) = ElimSpinestoRandomSpines(randi(length(ElimSpinestoRandomSpines)));
                    DistancesBetweenElimSpinesandShuffledMovementSpines{f}(es) = nanmean(ElimSpinestoShuffledMovementSpines);
                end
            end
            %%%%%%
            switch AnalysisType
                case 'Subtract'
                    if ConsiderOnlyMovementPeriods
                        currentcorrdata = FieldData{f}.Correlations{1}.DendriteSubtractedSpineDuringMovePeriods;
                    else
                        currentcorrdata = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1,Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                    end
                case 'Exclude'
                    if ConsiderOnlyMovementPeriods
                        currentcorrdata = FieldData{f}.Correlations{1}.SpineDuringMovePeriods;
                    else
                        currentcorrdata = FieldData{f}.Correlations{1}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1,Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                    end
                case 'Ignore'
                    if ConsiderOnlyMovementPeriods
                        currentcorrdata = FieldData{f}.Correlations{1}.SpineDuringMovePeriods;
                    else
                        currentcorrdata = FieldData{f}.Correlations{1}.OverallSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1,Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                    end
            end
            currentcorrdata(1:1+size(currentcorrdata,1):end) = nan; %%% set identity values to nan
            [ElimSpinesMaxCorr{f}, ElimSpineMaxInd] = max(currentcorrdata(ElimSpines{f},:),[],2);
            allotherspines = setdiff(1:NumberofEarlySpines,union(ElimSpineMaxInd, ElimSpines{f}));
%             OtherSpinesMaxCorr{f} = max(currentcorrdata(allotherspines,:),[],2);
            ElimSpineMaxCorrPartnerEarlyMoveCorrelation{f} = behaviorcorrdataearly(:,ElimSpineMaxInd);
            ElimSpineMaxCorrPartnerEarlyMoveReliability{f} = FieldData{f}.StatClass{1}.AllSpineReliability(ElimSpineMaxInd);
            for es = 1:length(ElimSpines{f})
                ElimSpinesBehaviorCorrelation{f}(es,1:9) = behaviorcorrdataearly(:,es);
            end
            NonNewSpinesBehaviorCorrelationEarly{f} = behaviorcorrdataearly(:,setdiff(1:NumberofEarlySpines,ElimSpines{f}));
            %%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%% Determine whether both types of spine dynamics happen on
        %%%%%%%% the same or different dendrites
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(NewSpines{f}) && ~isempty(ElimSpines{f})
            for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
               SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
               if any(ismember(NewSpines{f}, SpinesOnThisDend)) && any(ismember(ElimSpines{f}, SpinesOnThisDend))
                    DendsWithBothDynamics{f} = DendsWithBothDynamics{f}+1;
               end
               if any(ismember(ClusteredNewSpines{f}, SpinesOnThisDend)) && any(ismember(AntiClusteredElimSpines{f}, SpinesOnThisDend))
                    DendsWithBothClustDynamics{f} = DendsWithBothClustDynamics{f}+1;
               end
            end           
        end
        clusterednewspineslogical = zeros(NumberofSpines,1); clusterednewspineslogical(ClusteredNewSpines{f}) = 1;
        anticlusteredelimspineslogical = zeros(NumberofSpines,1); anticlusteredelimspineslogical(AntiClusteredElimSpines{f}) = 1;
        for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
            SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
            ClusteredNewSpinesbyDendrite{f}{dnd} = clusterednewspineslogical(SpinesOnThisDend);
            AntiClusteredElimSpinesbyDendrite{f}{dnd} = anticlusteredelimspineslogical(SpinesOnThisDend);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FractionofNewMovementSpinesThatAreClustered = NumberofMovementClusteredNewSpinesThatAreMR/NumberofNewSpinesThatAreMR;
    FractionofPersistentMovementRelatedSpinesClustered = cellfun(@(x,y) x/y, NumberofPersistentMovementSpinesClustered,NumberofPersistentMovementRelatedSpines, 'uni', false);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Dendrites Section

    for f = 1:NumFields
        IsDendriteUsed{f} = sum([FieldData{f}.StatClass{1}.MovementDends, FieldData{f}.StatClass{end}.MovementDends],2);
        DendriteFunctionChange{f} = diff([FieldData{f}.StatClass{1}.MovementDends, FieldData{f}.StatClass{end}.MovementDends],1,2);
    end

    NumberofImagedDendrites = sum(cell2mat(cellfun(@length, DendriteDynamics, 'uni', false)));
    NumberofDendritesThatBecomeMR = 0;
    NumberofDendritesThatBecomeMRandHaveMRSpines = 0;
    NumberofDendritesThatBecomeMRandGainMRSpines = 0;
    NumberofDendritesThatBecomeMRandHaveNewSpines = 0;
    NumberofDendritesThatBecomeMRandHaveElimSpines = 0;
    NumberofDendritesThatLoseMR = 0;
    NumberofDendritesThatLoseMRandHaveMRSpines = 0;
    NumberofDendritesThatLoseMRandLoseMRSpines = 0;
    NumberofDendritesThatLoseMRandHaveNewSpines = 0;
    NumberofDendritesThatLoseMRandHaveElimSpines = 0;
    NumberofDynamicDendrites = 0;
    NumberofAdditionDendrites = 0;
    NumberofEliminationDendrites = 0;
    NumberofAdditionandEliminationDendrites = 0;
    NumberofStaticDendrites = 0;
    NumberofDynamicDendritesUsedForMovement = 0;
    NumberofAdditionDendritesUsedForMovement = 0;
    NumberofEliminationDendritesUsedForMovement = 0;
    NumberofAdditionandEliminationDendritesUsedForMovement = 0;
    NumberofStaticDendritesUsedForMovement = 0;
    NumberofMovementSpinesOnAdditionDendrites = [];
    NumberofMovementSpinesOnEliminationDendrites = [];
    NumberofMovementSpinesOnStaticDendrites = [];
    fields_with_clusters = ~cellfun(@isempty, ClusteredEarlyMoveSpines);
    ListofDendswithClusters = zeros(NumberofImagedDendrites,1);
    ListofDendsThatAreEarlyMoveRelated = cell2mat(cellfun(@(x) x(:).StatClass{1}.MovementDends, FieldData, 'uni', false)');
    ListofDendsThatAreLateMoveRelated = cell2mat(cellfun(@(x) x(:).StatClass{end}.MovementDends, FieldData, 'uni', false)');

    for f = 1:NumFields
        DendritesInThisField = length(DendriteDynamics{f});
        if ~isempty(ClusteredEarlyMoveSpines{f})
            DendswithClusts = cellfun(@any, cellfun(@(x) ismember(ClusteredEarlyMoveSpines{f},x), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'uni', false));
        else
            DendswithClusts = zeros(1,DendritesInThisField);
        end
        for d = 1:DendritesInThisField
            ListofDendswithClusters(d) = DendswithClusts(d);
            if DendriteFunctionChange{f}(d) >0
                NumberofDendritesThatBecomeMR = NumberofDendritesThatBecomeMR+1;
                if sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}))
                    NumberofDendritesThatBecomeMRandHaveMRSpines = NumberofDendritesThatBecomeMRandHaveMRSpines+1;
                end
                if ~isempty(find((diff([FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}),FieldData{f}.StatClass{end}.DendSub_MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d})],1,2))>0,1))
                    NumberofDendritesThatBecomeMRandGainMRSpines = NumberofDendritesThatBecomeMRandGainMRSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},NewSpines{f}))
                    NumberofDendritesThatBecomeMRandHaveNewSpines = NumberofDendritesThatBecomeMRandHaveNewSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},ElimSpines{f}))
                    NumberofDendritesThatBecomeMRandHaveElimSpines = NumberofDendritesThatBecomeMRandHaveElimSpines+1;
                end
            end
            if DendriteFunctionChange{f}(d)<0
                NumberofDendritesThatLoseMR = NumberofDendritesThatLoseMR+1;
                if sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}))
                    NumberofDendritesThatLoseMRandHaveMRSpines = NumberofDendritesThatLoseMRandHaveMRSpines+1;
                end
                if ~isempty(find((diff([FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}),FieldData{f}.StatClass{end}.DendSub_MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d})],1,2))<0,1))
                    NumberofDendritesThatLoseMRandLoseMRSpines = NumberofDendritesThatLoseMRandLoseMRSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},find(DendriteDynamics{f}{d}>0,1)))
                    NumberofDendritesThatLoseMRandHaveNewSpines = NumberofDendritesThatLoseMRandHaveNewSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},find(DendriteDynamics{f}{d}<0,1)))
                    NumberofDendritesThatLoseMRandHaveElimSpines = NumberofDendritesThatLoseMRandHaveElimSpines+1;
                end
            end
            if sum(abs(DendriteDynamics{f}{d}))
                NumberofDynamicDendrites = NumberofDynamicDendrites+1;
                if ~isempty(find(DendriteDynamics{f}{d}>0,1))
                    NumberofAdditionDendrites = NumberofAdditionDendrites+1;
                    if IsDendriteUsed{f}(d)
                        NumberofAdditionDendritesUsedForMovement = NumberofAdditionDendritesUsedForMovement+1;
                    end
                    NumberofMovementSpinesOnAdditionDendrites = [NumberofMovementSpinesOnAdditionDendrites;sum(FieldData{f}.StatClass{end}.DendSub_MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
                end
                if ~isempty(find(DendriteDynamics{f}{d}<0,1))
                    NumberofEliminationDendrites = NumberofEliminationDendrites + 1;
                    if IsDendriteUsed{f}(d)
                        NumberofEliminationDendritesUsedForMovement = NumberofEliminationDendritesUsedForMovement+1;
                    end
                    NumberofMovementSpinesOnEliminationDendrites = [NumberofMovementSpinesOnEliminationDendrites;sum(FieldData{f}.StatClass{end}.DendSub_MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
                end
                if ~isempty(find(DendriteDynamics{f}{d}>0,1)) && ~isempty(find(DendriteDynamics{f}{d}<0,1))
                    NumberofAdditionandEliminationDendrites = NumberofAdditionandEliminationDendrites + 1;
                    if IsDendriteUsed{f}(d)
                        NumberofAdditionandEliminationDendritesUsedForMovement = NumberofAdditionandEliminationDendritesUsedForMovement+1;
                    end
                end
                if IsDendriteUsed{f}(d)
                    NumberofDynamicDendritesUsedForMovement = NumberofDynamicDendritesUsedForMovement+1;
                end
            elseif ~sum(abs(DendriteDynamics{f}{d}))
                NumberofStaticDendrites = NumberofStaticDendrites+1;
                if IsDendriteUsed{f}(d)
                    NumberofStaticDendritesUsedForMovement = NumberofStaticDendritesUsedForMovement+1;
                end
                NumberofMovementSpinesOnStaticDendrites = [NumberofMovementSpinesOnStaticDendrites;sum(FieldData{f}.StatClass{end}.DendSub_MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
            end
        end
    end
    
    switch AnalysisType
        case 'Subtract'
            ClusteredMoveSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency_DendriteSubtracted(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency_DendriteSubtracted(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency_DendriteSubtracted(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency_DendriteSubtracted,FieldData, 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency_DendriteSubtracted(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x))-y(:).CalciumData{1}.Frequency_DendriteSubtracted(setdiff(1:y(:).CalciumData{1}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency_DendriteSubtracted-x(:).CalciumData{1}.Frequency_DendriteSubtracted,FieldData, 'uni', false); 
           
            ClusteredMoveSpineAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredMoveSpineDeltaAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x)-y(:).CalciumData{1}.MeanEventAmp(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineAmplitudeOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineAmplitudeOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.MeanEventAmp,FieldData, 'uni', false);
            OtherSpineDeltaAmplitudeOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x))-y(:).CalciumData{1}.MeanEventAmp(setdiff(1:y(:).CalciumData{1}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineDeltaAmplitudeOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.MeanEventAmp-x(:).CalciumData{1}.MeanEventAmp,FieldData, 'uni', false);            
        case 'Exclude'
            ClusteredMoveSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency,FieldData, 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x))-y(:).CalciumData{1}.Frequency(setdiff(1:y(:).CalciumData{1}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency-x(:).CalciumData{1}.Frequency,FieldData, 'uni', false);
        case 'Ignore'
            ClusteredMoveSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency,FieldData, 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x))-y(:).CalciumData{1}.Frequency(setdiff(1:y(:).CalciumData{1}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineDeltaFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency-x(:).CalciumData{1}.Frequency,FieldData, 'uni', false);
            
            ClusteredMoveSpineAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredMoveSpineDeltaAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x)-y(:).CalciumData{1}.MeanEventAmp(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineAmplitude = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineAmplitudeOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineAmplitudeOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.MeanEventAmp,FieldData, 'uni', false);
            OtherSpineDeltaAmplitudeOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.MeanEventAmp(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x))-y(:).CalciumData{1}.MeanEventAmp(setdiff(1:y(:).CalciumData{1}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineDeltaAmplitudeOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.MeanEventAmp-x(:).CalciumData{1}.MeanEventAmp,FieldData, 'uni', false);            

    end
    NumberofDendritesThatAreEverMovementRelated = sum(cell2mat(cellfun(@sum, IsDendriteUsed, 'uni', false)));
    FractionofDendritesThatAreEverMovementRelated = NumberofDendritesThatAreEverMovementRelated/NumberofImagedDendrites; 
    FractionofDendritesThatAreDynamic = NumberofDynamicDendrites/NumberofImagedDendrites;
    FractionofDendriteswithAddition = NumberofAdditionDendrites/NumberofImagedDendrites;
    FractionofDendriteswithElimination = NumberofEliminationDendrites/NumberofImagedDendrites;
    FractionofDynamicDendritesUsedForMovement = NumberofDynamicDendritesUsedForMovement/NumberofDynamicDendrites;
    FractionofAdditionDendritesUsedForMovement = NumberofAdditionDendritesUsedForMovement/NumberofAdditionDendrites;
    FractionofEliminationDendritesUsedForMovement = NumberofEliminationDendritesUsedForMovement/NumberofEliminationDendrites;
    FractionofStaticDendritesUsedForMovement = NumberofStaticDendritesUsedForMovement/NumberofStaticDendrites;

    %======================================================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Set Final Structure and Save 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    a.Sensor = sensor; 

    a.SpineDynamics = FieldChanges;
    a.DendriteDynamics = DendriteDynamics;
    a.AllDendriteDistances = AllDendriteDistances;
    a.AllCueSpines = AllCueSpines; 
    a.AllMovementDuringCueSpines = AllMovementDuringCueSpines;
    a.AllMovementSpines = AllMovementSpines;
    a.AllMovementRanks = AllMovementRanks; 
    a.AllRewMovementSpines = AllRewMovementSpines;
    a.AllRewardSpines = AllRewardSpines;
    a.AllSpineCorrelationsonLateSession = AllSpineCorrelationsonLateSession;
    a.AllSpineNoiseCorrelationsonLateSession = AllSpineNoiseCorrelationsonLateSession;
    
    a.FractionofDendritesThatAreDynamic = FractionofDendritesThatAreDynamic;
    a.FractionofDendriteswithAddition = FractionofDendriteswithAddition;
    a.FractionofDendriteswithElimination = FractionofDendriteswithElimination; 
    a.NumberofDendritesThatAreEverMovementRelated = NumberofDendritesThatAreEverMovementRelated;
    a.FractionofDendritesThatAreEverMovementRelated = FractionofDendritesThatAreEverMovementRelated;
    a.NumberofImagedDendrites = NumberofImagedDendrites;
    a.NumberofDynamicDendrites = NumberofDynamicDendrites;
    a.NumberofDendritesThatBecomeMR = NumberofDendritesThatBecomeMR;
    a.NumberofDendritesThatBecomeMRandHaveMRSpines = NumberofDendritesThatBecomeMRandHaveMRSpines;
    a.NumberofDendritesThatBecomeMRandGainMRSpines = NumberofDendritesThatBecomeMRandGainMRSpines;
    a.NumberofDendritesThatBecomeMRandHaveNewSpines = NumberofDendritesThatBecomeMRandHaveNewSpines;
    a.NumberofDendritesThatBecomeMRandHaveElimSpines = NumberofDendritesThatBecomeMRandHaveElimSpines;
    a.NumberofDendritesThatLoseMR = NumberofDendritesThatLoseMR ;
    a.NumberofDendritesThatLoseMRandHaveMRSpines = NumberofDendritesThatLoseMRandHaveMRSpines;
    a.NumberofDendritesThatLoseMRandLoseMRSpines = NumberofDendritesThatLoseMRandLoseMRSpines;
    a.NumberofDendritesThatLoseMRandHaveNewSpines = NumberofDendritesThatLoseMRandHaveNewSpines;
    a.NumberofDendritesThatLoseMRandHaveElimSpines = NumberofDendritesThatLoseMRandHaveElimSpines;
    a.NumberofAdditionDendrites = NumberofAdditionDendrites;
    a.NumberofMovementSpinesOnAdditionDendrites = NumberofMovementSpinesOnAdditionDendrites;
    a.NumberofEliminationDendrites = NumberofEliminationDendrites;
    a.NumberofMovementSpinesOnEliminationDendrites = NumberofMovementSpinesOnEliminationDendrites;
    a.NumberofAdditionandEliminationDendrites = NumberofAdditionandEliminationDendrites;
    a.NumberofStaticDendrites = NumberofStaticDendrites;
    a.NumberofMovementSpinesOnStaticDendrites = NumberofMovementSpinesOnStaticDendrites;
    a.IsDendriteEverMovementRelated = IsDendriteUsed;
    a.NumberofDynamicDendritesUsedForMovement = NumberofDynamicDendritesUsedForMovement;
    a.NumberofAdditionDendritesUsedForMovement = NumberofAdditionDendritesUsedForMovement;
    a.NumberofEliminationDendritesUsedForMovement = NumberofEliminationDendritesUsedForMovement;
    a.NumberofAdditionandEliminationDendritesUsedForMovement = NumberofAdditionandEliminationDendritesUsedForMovement;
    a.NumberofStaticDendritesUsedForMovement = NumberofStaticDendritesUsedForMovement;
    a.FractionofDynamicDendritesUsedForMovement = FractionofDynamicDendritesUsedForMovement;
    a.FractionofAdditionDendritesUsedForMovement = FractionofAdditionDendritesUsedForMovement;
    a.FractionofEliminationDendritesUsedForMovement = FractionofEliminationDendritesUsedForMovement;
    a.FractionofStaticDendritesUsedForMovement = FractionofStaticDendritesUsedForMovement;
    a.ListofDendsThatAreEarlyMoveRelated = ListofDendsThatAreEarlyMoveRelated;
    a.ListofDendsThatAreLateMoveRelated = ListofDendsThatAreLateMoveRelated;
    a.ListofDendswithClusters = ListofDendswithClusters;
    
    a.NewSpines = NewSpines; a.NewSpinesbyDendrite = NewSpinesbyDendrite;
    a.NumberofNewSpines = NumberofNewSpines;
    a.MiddleSessionNewSpines = MiddleSessionNewSpines;
    a.LateSessionNewSpines = LateSessionNewSpines;
    a.PersistentNewSpines = persistentNewSpines;
    a.TransientNewSpines = transientNewSpines;
    a.ClusteredNewSpines = cellfun(@unique, ClusteredNewSpines, 'uni', false); a.ClusteredNewSpinesbyDendrite = ClusteredNewSpinesbyDendrite;
    a.ClusteredEarlyMoveSpines = cellfun(@unique, ClusteredEarlyMoveSpines, 'uni', false);
    a.ClusteredLateMoveSpines = cellfun(@unique, ClusteredLateMoveSpines, 'uni', false);
    a.ClusteredMoveSpinesbyNewSpine = ClusteredMoveSpinesbyNewSpine;
    a.ElimSpines = ElimSpines; a.ElimSpinesbyDendrite = ElimSpinesbyDendrite; 
    a.NumberofElimSpines = NumberofElimSpines;
    a.AntiClusteredMoveSpines = cellfun(@unique, AntiClusteredEarlyMoveSpines, 'uni', false);
    a.AntiClusteredElimSpines = cellfun(@unique, AntiClusteredElimSpines, 'uni', false); a.AntiClusteredElimSpinesbyDendrite = AntiClusteredElimSpinesbyDendrite;
    
    a.NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner;
    a.NumberofClusteredMoveSpines = NumberofClusteredMoveSpines;
    a.NumberofMovementClusteredNewSpines = NumberofMovementClusteredNewSpines;
    a.NumberofMovementClusteredNewSpinesThatAreMR = NumberofMovementClusteredNewSpinesThatAreMR;
    a.FractionofNewMovementSpinesThatAreClustered = FractionofNewMovementSpinesThatAreClustered;
    a.FractionofPersistentMovementRelatedSpinesClustered = FractionofPersistentMovementRelatedSpinesClustered;
    a.NumberofEarlyMovementRelatedSpines = NumberofEarlyMovementRelatedSpines;
    a.NumberofMidSessionMovementRelatedSpines = NumberofMidSessionMovementRelatedSpines;
    a.NumberofLateMovementRelatedSpines = NumberofLateMovementRelatedSpines;
    a.NumberofEarlierSessionMovementRelatedSpines = NumberofEarlierSessionMovementRelatedSpines;
    a.NumberofPersistentMovementRelatedSpines = NumberofPersistentMovementRelatedSpines;
    a.NumberofPersistentMovementSpinesClustered = NumberofPersistentMovementSpinesClustered;
    a.FractionofMovementRelatedSpinesMaintained = FractionofMovementRelatedSpinesMaintained;
    a.FractionofMovementRelatedSpinesEliminated = FractionofMovementRelatedSpinesEliminated;
    a.NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR;
    a.NumberofNewSpinesThatArePreSR = NumberofNewSpinesThatArePreSR;
    a.NumberofNewSpinesThatAreSR = NumberofNewSpinesThatAreSR;
    a.NumberofNewSpinesThatAreRR = NumberofNewSpinesThatAreRR;
    a.NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR;
    
    a.AllInterSpineDistancesList = AllInterSpineDistancesList;
    a.NewSpineAllSpinesDistance = NewSpineAllSpinesDistance;
    a.AllTransientNewSpinesDistance = AllTransientNewSpinesDistance;
    a.NewSpineAllSpinesMidCorr = NewSpineAllSpinesMidCorr;
    a.NewSpineAllSpinesLateCorr = NewSpineAllSpinesLateCorr;
    a.NewSpineAllSpinesLateRawCorr = NewSpineAllSpinesLateRawCorr;
    a.NewSpineAllSpinesLateNoiseCorr = NewSpineAllSpinesLateNoiseCorr;
    a.AllSpinesEarlyCoActiveRates = AllSpinesEarlyCoActiveRates;
    a.AllSpinesEarlyCoActiveRatesGeoNormalized = AllSpinesEarlyCoActiveRatesGeoNormalized;
    a.AllSpinesLateCoActiveRates = AllSpinesLateCoActiveRates;
    a.AllSpinesLateCoActiveRatesGeoNormalized = AllSpinesLateCoActiveRatesGeoNormalized;
    a.NewSpineAllCoActiveRates = NewSpineAllCoActiveRates;
    a.NewSpineAllCoActiveRatesNormalized = NewSpineAllCoActiveRatesNormalized;
    a.NewSpineAllCoActiveRatesGeoNormalized = NewSpineAllCoActiveRatesGeoNormalized;
    a.AllTransientNewSpinesMidCorr = AllTransientNewSpinesMidCorr;
    a.TransientSpineCoActiveRate = TransientSpineCoActiveRate;
    a.TransientSpineCoActiveRateNormalized = TransientSpineCoActiveRateNormalized;
    a.TransientSpineCoActiveRateGeoNormalized = TransientSpineCoActiveRateGeoNormalized;
    a.TransientNewSpinesFrequency = TransientNewSpinesFrequency;
    a.NewSpineMidCoActiveRate = NewSpineMidCoActiveRate;
    a.NewSpineMidCoActiveRateNormalized = NewSpineMidCoActiveRateNormalized;
    a.NewSpineMidCoActiveRateGeoNormalized = NewSpineMidCoActiveRateGeoNormalized;
    a.NewSpineMidFrequency = NewSpineMidFrequency;
    a.NewSpineAllDistancestoEarlyMovementSpines = NewSpineAllDistancestoEarlyMovementSpines;
    a.DistancesBetweenNewSpinesandNearestEarlyMovementSpines = DistancesBetweenNewSpinesandNearestEarlyMovementSpines;
    a.LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions = LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions;
    a.NewSpinesCorrwithDistanceMatchedNonEarlyMRSs = NewSpinesCorrwithDistanceMatchedNonEarlyMRSs;
    a.FrequencyMatchedControlCorrelation = FrequencyMatchedControlCorrelation;
    a.NewSpinesCorrwithDistanceMatchedNonLateMRSs= NewSpinesCorrwithDistanceMatchedNonLateMRSs;
    a.DistancesBetweenNewSpinesandMovementSpines = DistancesBetweenNewSpinesandLateMovementSpines;
    a.LateCorrofNewSpinesandNearestMovementSpinefromLateSessions = LateCorrofNewSpinesandNearestMovementSpinefromLateSessions;
    a.NewSpinesCorrwithNearbyEarlyMRSs = NewSpinesCorrwithNearbyEarlyMRSs;
    a.FractionofNewSpinesMeetingClusterCriteria = FractionofNewSpinesMeetingClusterCriteria;
    a.AllClusterCorrelationsbyNewSpine = AllClusterCorrelationsbyNewSpine;
    a.DistancetoHighCorrMovementSpines = DistancetoHighCorrMovementSpines;
    a.DistancetoEnlargedSpines = DistancetoEnlargedSpines;
    a.AllMoveCentricClusterCorrelationsbyNewSpine = AllMoveCentricClusterCorrelationsbyNewSpine;
    
    a.AllSpineVolumeData = AllSpineVolumeData;
    a.AllSpineFrequency = AllSpineFrequency;
    a.AllDeltaSpineVolume = AllDeltaSpineVolume;
    a.ClusteredMovementSpineVolume = ClusteredMovementSpineVolume;
    a.SimClusterCorr = SimClusterCorr;
    a.ClusteredMovementSpineDeltaFrequency = ClusteredMovementSpineDeltaFrequency;
    a.ClusteredMovementSpineDeltaAmplitude = ClusteredMovementSpineDeltaAmplitude;
    a.MovementSpineDistanceMatchedControlCorrelation = MovementSpineDistanceMatchedControlCorrelation;
    a.CombinedClusterActivityCorrwithMovement = CombinedClusterActivityCorrwithMovement;
    a.CombinedClusterActivityCorrwithSuccess = CombinedClusterActivityCorrwithSuccess;
    a.ClusterMovementReliability = ClusterMovementReliability;
    a.ClusterSuccessReliability = ClusterSuccessReliability;
    a.ControlPairMovementReliability = ControlPairMovementReliability;
    a.ControlPairSuccessReliability = ControlPairSuccessReliability;
    a.MoveCentricClusterCorrelation = MoveCentricClusterCorrelation;
    a.MoveCentricFrequencyMatchedCorrelation = MoveCentricFrequencyMatchedCorrelation;
    a.MoveCentricDistanceMatchedCorrelation = MoveCentricDistanceMatchedCorrelation;
    a.MoveCentricDistanceMatchedCorrelationforMRS = MoveCentricDistanceMatchedCorrelationforMRS;
    a.MoveCentricCorrelationofAllOtherSpines = MoveCentricCorrelationofAllOtherSpines;
    a.FailureCentricClusterCorrelation = FailureCentricClusterCorrelation;
    a.MoveCentricAntiClusterCorrelation = MoveCentricAntiClusterCorrelation;
    a.MoveCentricDistanceMatchedtoAntiClustCorrelation = MoveCentricDistanceMatchedtoAntiClustCorrelation;
    a.TaskCorrelationofClusteredNewSpines = TaskCorrelationofClusteredNewSpines;
    a.TaskCorrelationofNearbyEarlyMRSs = TaskCorrelationofNearbyEarlyMRSs;
    a.MovementReliabilityofNearbyEarlyMRSs = MovementReliabilityofNearbyEarlyMRSs;
    a.MovementReliabilityofOtherMoveSpines = MovementReliabilityofOtherMoveSpines;
    a.NewSpinesCorrwithNearbyLateMRSs = NewSpinesCorrwithNearbyLateMRSs;
    a.TaskCorrelationofNearbyLateMRSs = TaskCorrelationofNearbyLateMRSs;
    a.MovementReliabilityofNearbyLateMRSs = MovementReliabilityofNearbyLateMRSs;
    a.TaskCorrelationofNearbyEarlyMRSsforElimSp = TaskCorrelationofNearbyEarlyMRSsforElimSp;
    a.MovementReliabilityofNearbyEarlyMRSsforElimSp = MovementReliabilityofNearbyEarlyMRSsforElimSp;
    a.DistancesBetweenElimSpinesandEarlyMovementSpines = DistancesBetweenElimSpinesandEarlyMovementSpines;
    a.CorrelationsofElimSpinesandEarlyMovementSpines = CorrelationsofElimSpinesandEarlyMovementSpines;
    a.ElimSpinesCorrwithNearbyMRSs = ElimSpinesCorrwithNearbyMRSs;
    a.DistancesBetweenElimSpinesandMovementSpines = DistancesBetweenElimSpinesandMovementSpines;
    a.DistancesBetweenNewSpinesandRandomSpines = DistancesBetweenNewSpinesandRandomSpines;
    a.DistancesBetweenElimSpinesandRandomSpines = DistancesBetweenElimSpinesandRandomSpines;
    a.DistancesBetweenNewSpinesandShuffledEarlyMovementSpines = DistancesBetweenNewSpinesandShuffledEarlyMovementSpines;
    a.DistancesBetweenNewSpinesandShuffledMovementSpines = DistancesBetweenNewSpinesandShuffledMovementSpines;
    a.DistancesBetweenElimSpinesandShuffledEarlyMovementSpines = DistancesBetweenElimSpinesandShuffledEarlyMovementSpines;
    a.DistancesBetweenElimSpinesandShuffledMovementSpines = DistancesBetweenElimSpinesandShuffledMovementSpines;
    
    a.MovementCorrelationwithCoActiveAntiClusters = MovementCorrelationwithCoActiveAntiClusters;
    a.CoActiveAntiClusterMovementsCorrelationwithModelMovement = CoActiveAntiClusterMovementsCorrelationwithModelMovement;
    a.MovementCorrelationofAllOtherMovementsElimVersion = MovementCorrelationofAllOtherMovementsElimVersion;
    a.AllOtherMovementsCorrelationwithModelMovementElimVersion = AllOtherMovementsCorrelationwithModelMovementElimVersion;
    a.MovementCorrelationofFrequencyMatchedPairsElimVersion = MovementCorrelationofFrequencyMatchedPairsElimVersion;
    a.FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion = FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion;

    a.NewSpinesMaxCorrelation = NewSpinesMaxCorr;
    a.DistanceToMaxCorrPartner = DistanceToMaxCorrPartner;
    a.FractionofHCPsThatAreMR = FractionofHCPsThatAreMR;
    a.NewSpineMaxCorrPartnerEarlyMoveCorrelation = NewSpineMaxCorrPartnerEarlyMoveCorrelation;
    a.NewSpineMaxCorrPartnerLateMoveCorrelation = NewSpineMaxCorrPartnerLateMoveCorrelation;
    a.NewSpineMaxCorrPartnerEarlyMoveReliability = NewSpineMaxCorrPartnerEarlyMoveReliability;
    a.NewSpineMaxCorrPartnerLateMoveReliability = NewSpineMaxCorrPartnerLateMoveReliability;
    a.ElimSpineMaxCorrPartnerEarlyMoveReliability = ElimSpineMaxCorrPartnerEarlyMoveReliability;
    a.ElimSpineMaxCorrPartnerEarlyMoveCorrelation = ElimSpineMaxCorrPartnerEarlyMoveCorrelation;
    a.NewSpinesBehaviorCorrelation = NewSpinesBehaviorCorrelation;
    a.ElimSpinesBehaviorCorrelation = ElimSpinesBehaviorCorrelation;
    a.NonNewSpinesBehaviorCorrelationEarly = NonNewSpinesBehaviorCorrelationEarly;
    a.NonNewSpinesBehaviorCorrelationLate = NonNewSpinesBehaviorCorrelationLate;
    a.ElimSpinesMaxCorrelation = ElimSpinesMaxCorr;
    a.OtherSpinesMaxCorrelation = OtherSpinesMaxCorr;
    
    a.CuedRewardedMovementTracesEarly = CuedRewardedMovementTracesEarly;
    a.CuedRewardedMovementTracesLate = CuedRewardedMovementTracesLate;
    a.ClusterCoActiveTraces = ClusterCoActiveTraces;
    a.ClusteredNewSpineCorrwithDendrite = ClusteredNewSpineCorrwithDendrite;
    a.ClusteredNewSpineCorrwithMovement = ClusteredNewSpineCorrwithMovement;
    a.ClusteredNewSpineCorrwithSuccess = ClusteredNewSpineCorrwithSuccess;
    a.ClusteredMoveSpineCorrwithDendrite = ClusteredMoveSpineCorrwithDendrite;
    a.ClusteredMoveSpineCorrwithMovement = ClusteredMoveSpineCorrwithMovement;
    a.ClusteredMoveSpineCorrwithSuccess = ClusteredMoveSpineCorrwithSuccess;
    a.CoActiveClusterCorrwithDendrite = CoActiveClusterCorrwithDendrite;
    a.CoActiveClusterCorrwithMovement = CoActiveClusterCorrwithMovement;
    a.CoActiveClusterCorrwithSuccess = CoActiveClusterCorrwithSuccess;
    
    a.HCPClusteredNewSpineCorrwithMovement = HCPClusteredNewSpineCorrwithMovement;
    a.HCPClusteredNewSpineCorrwithSuccess = HCPClusteredNewSpineCorrwithSuccess;
    a.HCPCorrwithMovement = HCPCorrwithMovement;
    a.HCPCorrwithSuccess = HCPCorrwithSuccess;
    a.CoActiveHCPClusterCorrwithMovement = CoActiveHCPClusterCorrwithMovement;
    a.CoActiveHCPClusterCorrwithSuccess = CoActiveHCPClusterCorrwithSuccess;
    a.MoveCentricHCPClusterCorrelation = MoveCentricHCPClusterCorrelation;
    a.MovementCorrelationwithCoActiveHCPClusters = MovementCorrelationwithCoActiveHCPClusters;
    a.MovementCorrelationofAllOtherNonHCPMovements = MovementCorrelationofAllOtherNonHCPMovements;
    a.MovementCorrelationofHCPComparatorSpines = MovementCorrelationofHCPComparatorSpines;

    a.SessionsbyField = SessionsbyField;
    a.SpineDendriteGrouping = SpineDendriteGrouping;
    
    a.IsMovementRewardedEarly = IsMovementRewardedEarly;
    a.IsMovementRewardedLate = IsMovementRewardedLate;
    a.IsCoActiveMovementRewarded = IsCoActiveMovementRewarded;
    a.IsMoveOnlyRewarded = IsMoveOnlyRewarded;
    a.MoveOnlyChanceRewardedLevel = MoveOnlyChanceRewardedLevel;
    a.IsNewOnlyRewarded = IsNewOnlyRewarded;
    a.NewOnlyChanceRewardedLevel = NewOnlyChanceRewardedLevel;
    a.IsCompCoActiveMovementRewarded = IsCompCoActiveMovementRewarded;
    a.FMChanceRewardedLevel = FMChanceRewardedLevel;
    a.IsMRSDMCoActiveMovementRewarded = IsMRSDMCoActiveMovementRewarded;
    a.MRSDMChanceRewardedLevel = MRSDMChanceRewardedLevel;
    a.IsNSDMCoActiveMovementRewarded = IsNSDMCoActiveMovementRewarded;
    a.NSDMChanceRewardedLevel = NSDMChanceRewardedLevel;
    a.ChanceRewardedLevel = ChanceRewardedLevel;
    a.ChanceRewardedLevelElimVersion = ChanceRewardedLevelElimVersion;
    
    a.DotProductofCoActivePeriodsDuringMovement = DotProductofCoActivePeriodsDuringMovement;
    a.AllCoActivityDotProductsforDistanceMeasurement = AllCoActivityDotProductsforDistanceMeasurement;
    a.DotProductofFMCoActivePeriodsDuringMovement = DotProductofFMCoActivePeriodsDuringMovement;  
    a.DotProductofNSDMCoActivePeriodsDuringMovement = DotProductofNSDMCoActivePeriodsDuringMovement;
    a.DotProductofNSOnlyActivePeriodsDuringMovement = DotProductofNSOnlyActivePeriodsDuringMovement;
    a.DotProductofMRSDMCoActivePeriodsDuringMovement = DotProductofMRSDMCoActivePeriodsDuringMovement;
    a.DotProductofMRSOnlyPeriodsDuringMovement = DotProductofMRSOnlyPeriodsDuringMovement;
    a.MedianMovementCorrelationbyNewSpine = MedianMovementCorrelationbyNewSpine;

    a.DotProductofCoActivePeriodsDuringCRMovement = DotProductofCoActivePeriodsDuringCRMovement;
    a.DotProductofCoActivePeriodsDuringStillness = DotProductofCoActivePeriodsDuringStillness;
    a.DotProductofFMCoActivePeriodsDuringCRMovement = DotProductofFMCoActivePeriodsDuringCRMovement;
    
    a.ChanceLevelofCoactivityMovementOverlap = ChanceLevelofCoactivityMovementOverlap;
    a.AllCoActivityChanceLevelDotProductsforDistanceMeasurement = AllCoActivityChanceLevelDotProductsforDistanceMeasurement;
    a.ChanceLevelofFMCoActivitywithmovement = ChanceLevelofFMCoActivitywithmovement;
    a.ChanceLevelofNSDMCoActivitywithMovement = ChanceLevelofNSDMCoActivitywithMovement;
    a.ChanceLevelofNSOnlyActivitywithMovement = ChanceLevelofNSOnlyActivitywithMovement;
    a.ChanceLevelofMRSDMCoActivitywithMovement = ChanceLevelofMRSDMCoActivitywithMovement;
    a.ChanceLevelofMRSOnlyPeriodsDuringMovement = ChanceLevelofMRSOnlyPeriodsDuringMovement;
    a.ChanceLevelofCoActivityCRMovementOverlap = ChanceLevelofCoActivityCRMovementOverlap;
    a.ChanceLevelofFMCoActivityCRMovementOverlap = ChanceLevelofFMCoActivityCRMovementOverlap;

    a.ModelMovement = ModelMovement;
    a.IsCoActiveAntiClusterMovementRewarded = IsCoActiveAntiClusterMovementRewarded;
    a.MovementsEncodedbySeedlingMRS = MovementsEncodedbySeedlingMRS;
    a.MovementswithClusteredCoActivity = MovementswithClusteredCoActivity;
    a.MovementswithClusteredCoActivitybyCluster = MovementswithClusteredCoActivitybyCluster;
    a.CorrelationofMovementswithCoActiveClusterActivity = CorrelationofMovementswithCoActiveClusterActivity;
    a.CorrelationofMovementswithCoActiveClusterActivitybyCluster = CorrelationofMovementswithCoActiveClusterActivitybyCluster;
    a.CoActiveClusterMovementsCorrelationwithModelMovement = CoActiveClusterMovementsCorrelationwithModelMovement;
    a.CoActiveClusterMovementsCorrelationwithModelMovementbyCluster = CoActiveClusterMovementsCorrelationwithModelMovementbyCluster;
    a.SimilarityofClusteredMovementwithSeedlingMRSMovement = SimilarityofClusteredMovementwithSeedlingMRSMovement;
    a.StereotypyDiagnostics = StereotypyDiagnostics;
    
    a.NSonlyEventRate = NSonlyEventRate;
    a.NSonlyIntegratedActivity = NSonlyIntegratedActivity;
    a.FractionofNSActivityDuringMovements = FractionofNSActivityDuringMovements;
    a.FractionofMRSActivityDuringMovements = FractionofMRSActivityDuringMovements;
    a.ClustCoActiveRate = ClustCoActiveRate;
    a.ClustIntegratedCoactivity = ClustIntegratedCoactivity;
    a.FractionofClustActivityDuringMovements = FractionofClustActivityDuringMovements;
    a.FractionofClustActivityDuringCRMovements = FractionofClustActivityDuringCRMovements; 
    a.FMcompCoActiveRate = FMcompCoActiveRate;
    a.MRSDMcompCoActiveRate = MRSDMcompCoActiveRate;
    a.NSDMcompCoActiveRate = NSDMcompCoActiveRate;
    
    a.ClustActivityStartRelativetoMovement = ClustActivityStartRelativetoMovement;
    a.ClustActivityStartNormalizedtoMovementLength = ClustActivityStartNormalizedtoMovementLength;
    a.StandardDeviationofClustActivityOnset = StandardDeviationofClustActivityOnset;
    a.StandardDeviationofNormClustActivityOnset = StandardDeviationofNormClustActivityOnset;
    a.LeverPositionatClustActivityOnset = LeverPositionatClustActivityOnset;
    a.LeverVelocityatClustActivityOnset = LeverVelocityatClustActivityOnset;
    a.LeverVelocityatRandomLagsfromOnset = LeverVelocityatRandomLagsfromOnset;
    a.MeanSpeedofActMovementPeriods = MeanSpeedofActMovementPeriods;
    a.MeanSpeedofOtherMovementPeriods = MeanSpeedofOtherMovementPeriods;
    a.LeverSlopeTraces = LeverSlopeTraces;
    a.ShuffledClustActivityStart = ShuffledClustActivityStart;
    a.ShuffledActivityStartNormalizedtoMovementLength = ShuffledActivityStartNormalizedtoMovementLength;
    a.StandardDeviationofShuffledActivityOnset = StandardDeviationofShuffledActivityOnset;
    a.StandardDeviationofNormShuffledActivityOnset = StandardDeviationofNormShuffledActivityOnset;
    a.LeverPositionatShuffledActivityOnset = LeverPositionatShuffledActivityOnset;
    a.LeverVelocityatShuffledActivityOnset = LeverVelocityatShuffledActivityOnset;
    a.ClustActivityStartHypothesisTest = ClustActivityStartHypothesisTest;
    a.FMActivityStartRelativetoMovement = FMActivityStartRelativetoMovement;
    a.MRSDMActivityStartRelativetoMovement = MRSDMActivityStartRelativetoMovement;
    a.NSDMActivityStartRelativetoMovement = NSDMActivityStartRelativetoMovement;
    a.NSonlyActivityStartRelativetoMovement = NSonlyActivityStartRelativetoMovement;
    a.StandardDeviationofNSOnlyActivityOnset = StandardDeviationofNSOnlyActivityOnset;
    a.LeverPositionatNSOnlyActivityOnset = LeverPositionatNSOnlyActivityOnset;
    a.LeverVelocityatNSOnlyActivityOnset = LeverVelocityatNSOnlyActivityOnset;
    a.LeverVelocityatShuffledNSActivityOnset = LeverVelocityatShuffledNSActivityOnset;
    a.LeverPositionatMRSOnlyActivityOnset = LeverPositionatMRSOnlyActivityOnset;
    a.LeverVelocityatMRSOnlyActivityOnset = LeverVelocityatMRSOnlyActivityOnset; 
    a.LeverVelocityatShuffledMRSActivityOnset = LeverVelocityatShuffledMRSActivityOnset;
    
    a.NumberofMovementswithClusterCoActivitybyCluster = NumberofMovementswithClusterCoActivitybyCluster;
    a.FractionofMovementswithClusterCoActivitybyCluster = FractionofMovementswithClusterCoActivitybyCluster;
    a.NumberofMovementswithAnyClusterCoActivity = NumberofMovementswithAnyClusterCoActivity;
    a.FractionofMovementswithAnyClusterCoActivity = FractionofMovementswithAnyClusterCoActivity;
    
    a.MovementswithMRSOnlyActivity = MovementswithMRSOnlyActivity;
    a.MovementCorrelationwithMRSonlyActivity = CorrelationofMovementswithMRSOnlyActivity;
    a.MovementswithMRSOnlyActivitybyCluster = MovementswithMRSOnlyActivitybyCluster;
    a.MovementCorrelationwithMRSonlyActivitybyCluster = CorrelationofMovementswithMRSOnlyActivitybyCluster;
    a.MovementswithNSOnlyActivity = MovementswithNSOnlyActivity;
    a.MovementCorrelationwithNSonlyActivity = CorrelationofMovementswithNSOnlyActivity;
    a.MovementswithNSOnlyActivitybyCluster = MovementswithNSOnlyActivitybyCluster;
    a.MovementCorrelationwithNSonlyActivitybyCluster = CorrelationofMovementswithNSOnlyActivitybyCluster;
    a.WithoutGroupMovements = WithoutGroupMovements;
    a.MovementCorrelationofAllOtherMovements = MovementCorrelationofAllOtherMovements;
    a.MovementswithFMControlCoActivity = MovementswithFMControlCoActivity;
    a.CorrelationofMovementswithCoActiveFMControlActivity = CorrelationofMovementswithCoActiveFMControlActivity;
    a.MovementswithFMControlCoActivitybyCluster = MovementswithFMControlCoActivitybyCluster;
    a.CorrelationofMovementswithCoActiveFMControlActivitybyCluster = CorrelationofMovementswithCoActiveFMControlActivitybyCluster;
    a.CorrelationofMovementswithCoActiveMRSDMControlActivity = CorrelationofMovementswithCoActiveMRSDMControlActivity;
    a.CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster = CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster;
    a.MovementswithMRSDMCoActivity = MovementswithMRSDMCoActivity;
    a.MovementswithMRSDMCoActivitybyCluster = MovementswithMRSDMCoActivitybyCluster;
    a.MRSDMControlMovementsCorrelationwithModelMovementbyCluster = MRSDMControlMovementsCorrelationwithModelMovementbyCluster;
    a.MRSDMControlMovementsCorrelationwithModelMovement = MRSDMControlMovementsCorrelationwithModelMovement;
    a.MovementswithAllOtherSpineCoActivity = MovementswithAllOtherSpineCoActivity;
    a.CorrelationofMovementswithAllOtherSpineCoActivity = CorrelationofMovementswithAllOtherSpineCoActivity;
    a.AllOtherSpineCoActivityMovementsCorrelationwithModelMovement = AllOtherSpineCoActivityMovementsCorrelationwithModelMovement;
    a.CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster = CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster;
    a.MovementswithNSDMCoActivitybyCluster = MovementswithNSDMCoActivitybyCluster;
    a.NSDMControlMovementsCorrelationwithModelMovementbyCluster = NSDMControlMovementsCorrelationwithModelMovementbyCluster;
    
    a.MRSActivityOnlyMovementsCorrelationwithModelMovement = MRSOnlyMovementsCorrelationwithModelMovement;
    a.NSActivityOnlyMovementsCorrelationwithModelMovement = NSOnlyMovementsCorrelationwithModelMovement;
    a.MRSActivityOnlyMovementsCorrelationwithModelMovementbyCluster = MRSOnlyMovementsCorrelationwithModelMovementbyCluster;
    a.NSActivityOnlyMovementsCorrelationwithModelMovementbyCluster = NSOnlyMovementsCorrelationwithModelMovementbyCluster;
    a.AllOtherMovementsCorrelationwithModelMovement = AllOtherMovementsCorrelationwithModelMovement;
    a.FMControlMovementsCorrelationwithModelMovement = FMControlMovementsCorrelationwithModelMovement;
    a.FMControlMovementsCorrelationwithModelMovementbyCluster = FMControlMovementsCorrelationwithModelMovementbyCluster;

    
    a.ClusteredMoveSpineFrequency = ClusteredMoveSpineFrequency;
    a.ClusteredNewSpineFrequency = ClusteredNewSpineFrequency;
    a.OtherSpineFrequencyOnDendswithClusters = OtherSpineFrequencyOnDendswithClusters;
    a.OtherSpineFrequencyOnDendswithoutClusters = OtherSpineFrequencyOnDendswithoutClusters;
    a.OtherSpineDeltaFrequencyOnDendswithClusters = OtherSpineDeltaFrequencyOnDendswithClusters;
    a.OtherSpineDeltaFrequencyOnDendswithoutClusters = OtherSpineDeltaFrequencyOnDendswithoutClusters;
    
    a.ClusteredMoveSpineAmplitude = ClusteredMoveSpineAmplitude;
    a.ClusteredNewSpineAmplitude = ClusteredNewSpineAmplitude;
    a.OtherSpineAmplitudeOnDendswithClusters = OtherSpineAmplitudeOnDendswithClusters;
    a.OtherSpineAmplitudeOnDendswithoutClusters = OtherSpineAmplitudeOnDendswithoutClusters;
    a.ClusteredMoveSpineDeltaAmplitude = ClusteredMoveSpineDeltaAmplitude;
    a.OtherSpineDeltaAmplitudeOnDendswithClusters = OtherSpineDeltaAmplitudeOnDendswithClusters;
    a.OtherSpineDeltaAmplitudeOnDendswithoutClusters = OtherSpineDeltaAmplitudeOnDendswithoutClusters;
    
    a.DendsWithBothDynamics = DendsWithBothDynamics;
    a.DendsWithBothClustDynamics = DendsWithBothClustDynamics;
    a.CoActivityDifferenceOptimizationCurve = CoActivityDifferenceOptimizationCurve;

    eval([experimentnames, '_SpineDynamicsSummary = a;'])
    fname = [experimentnames, '_SpineDynamicsSummary'];
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
    save(fname, fname)
    
    
    disp(['Analysis of ', experimentnames, ' complete'])
    clearvars -except varargin sensor gui_KomiyamaLabHub
end