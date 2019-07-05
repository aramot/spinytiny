function NewSpineAnalysis(varargin)

sensor = varargin(end);

for animal = 1:length(varargin)-1
    
    experimentnames = varargin{animal}; 
    FilterforMovementDends = 0;
    FilterforPersistentMRSs = 0;
    
    %%%%%%%%%%%% Load Spine Dynamics Registry for a given animal
    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd(['C:\Users\Komiyama\Desktop\Output Data', filesep, experimentnames, ' New Spine Analysis'])
    end
    fieldsource = fastdir(cd, 'Field');
    filecount = 1;
    for f = 1:length(fieldsource)
        load(fieldsource{f})
        fieldnumber = regexp(fieldsource{f}, '\d+.Spine');
        eval(['FieldData{', num2str(filecount), '} = SpineRegistry;']);
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
        cd('E:\ActivitySummary')
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
        clear(activitydata{f})
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
        cd('C:\Users\Komiyama\Desktop\Output Data')
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
    %%%%%%%%%%%%%%%%%%% Load Behavioral Summary Data %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd('C:\Users\Komiyama\Desktop\Output Data')
    end

    behdata = fastdir(cd, [experimentnames, '_SummarizedBehavior']);
    if ~isempty(behdata)
        load(behdata{1});
    else
        disp(['Cannot load behavior data for animal ', experimentnames, '!']);
    end

    eval(['fullbehaviordata = ', experimentnames, '_SummarizedBehavior;'])
    
    ModelMovement = nanmean(fullbehaviordata.MovementMat{end},1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% CHANGE THIS PART ACCORDING TO THE SENSOR BEING USED!!!!
    
    secondspostmovementstart = 3;
    
    if strcmpi(sensor, 'GCaMP')
    	ImagingFrequency = 30.49;
    elseif strcmpi(sensor, 'GluSNFR')
    	ImagingFrequency = 60;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    framesofinterest = round(ImagingFrequency*secondspostmovementstart)+1;
    [n, d] = rat(framesofinterest/length(ModelMovement));
%     xpad = [repmat(ModelMovement(1),1,500),ModelMovement, repmat(ModelMovement(end),1,500)];
    modmov_shifted = ModelMovement-nanmedian(ModelMovement);    %%% Centering the movement around zero prevents edge artifacts of resampling
    ModelMovement = resample(modmov_shifted,n,d)+nanmedian(ModelMovement);
%     ModelMovement = ModelMovement(16:end-16);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Load Correlation data  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    
    ConsiderOnlyMovementPeriods = 0; % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Determine data type to use %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    global gui_KomiyamaLabHub
    
    if get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'Value')
        AnalysisType = 'Exclude';
    elseif get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'Value')
        AnalysisType = 'Subtract';
    else
        AnalysisType = 'Exclude';
    end
    
    clear gui_KomiyamaLabHub
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% New spine analysis section
    %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initiatilize variables to be used
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NewSpines = cell(1,NumFields); NewSpinesbyDendrite = cell(1,NumFields);
    ElimSpines = cell(1,NumFields); ElimSpinesbyDendrite = cell(1,NumFields);
    MiddleSessionNewSpines = cell(1,NumFields);
    LateSessionNewSpines = cell(1,NumFields);
    persistentNewSpines = cell(1,NumFields);
    ClusteredNewSpines = cell(1,NumFields); ClusteredNewSpinesbyDendrite = cell(1,NumFields);
    ClusteredEarlyMoveSpines = cell(1,NumFields);
    ClusteredLateMoveSpines = cell(1,NumFields);
    AntiClusteredElimSpines = cell(1,NumFields); AntiClusteredElimSpinesbyDendrite = cell(1,NumFields);
    AntiClusteredEarlyMoveSpines = cell(1,NumFields);
    
    NumberofEarlyMovementRelatedSpines = 0;
    NumberofLateMovementRelatedSpines = 0;
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
    AllMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandEarlyMovementSpines = cell(1,NumFields);
    NewSpineAllSpinesDistance = cell(1,NumFields);
    NewSpineAllSpinesLateCorr = cell(1,NumFields);
    LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions = cell(1,NumFields);
    LateCorrfNewSpinesandNearestMovementSpinefromLateSessions = cell(1,NumFields);
    NewSpinesCorrwithNearbyEarlyMRSs = cell(1,NumFields);
    MovementSpineDistanceMatchedControlCorrelation = cell(1,NumFields);
    NewSpinesCorrwithNearbyLateMRSs = cell(1,NumFields);
    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs = cell(1,NumFields);
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
    CoActiveClusterCorrwithDendrite = cell(1,NumFields);
    CoActiveClusterCorrwithMovement = cell(1,NumFields);
    CoActiveClusterCorrwithSuccess = cell(1,NumFields);
    
    %%% Noise Correlation stuff
    SuccessCentricDistanceMatchedCorrelation = cell(1,NumFields);
    SuccessCentricDistanceMatchedCorrelationforMRS = cell(1,NumFields);
    SuccessCentricCorrelationofAllOtherSpines = cell(1,NumFields);
    SuccessCentricClusterCorrelation = cell(1,NumFields);
    SuccessCentricAntiClusterCorrelation = cell(1,NumFields);
    SuccessCentricDistanceMatchedtoAntiClustCorrelation = cell(1,NumFields);
    FailureCentricClusterCorrelation = cell(1,NumFields);
    CombinedClusterActivityCorrwithMovement = cell(1,NumFields);
    CombinedClusterActivityCorrwithSuccess = cell(1,NumFields);
    ClusterMovementReliability = cell(1,NumFields);
    ClusterSuccessReliability = cell(1,NumFields);
    ControlPairMovementReliability = cell(1,NumFields);
    ControlPairSuccessReliability = cell(1,NumFields);
    SessionsbyField = cell(1,NumFields);
    SpineDendriteGrouping = cell(1,NumFields);
    
    MovementCorrelationwithCoActiveClusters = cell(1,NumFields);
    CoActiveClusterMovementsCorrelationwithModelMovement = cell(1,NumFields);
    MovementCorrelationofAllOtherMovements = cell(1,NumFields);
    AllOtherMovementsCorrelationwithModelMovement = cell(1,NumFields);
    MovementCorrelationofFrequencyMatchedPairs = cell(1,NumFields);
    FrequencyMatchedPairMovementsCorrelationwithModelMovement = cell(1,NumFields);
    
    HCPClusteredNewSpineCorrwithMovement = cell(1,NumFields);
    HCPClusteredNewSpineCorrwithSuccess = cell(1,NumFields);
    HCPCorrwithMovement = cell(1,NumFields);
    HCPCorrwithSuccess = cell(1,NumFields);
    CoActiveHCPClusterCorrwithMovement = cell(1,NumFields);
    CoActiveHCPClusterCorrwithSuccess = cell(1,NumFields);
    MovementCorrelationwithCoActiveHCPClusters = cell(1,NumFields);
    MovementCorrelationofAllOtherNonHCPMovements = cell(1,NumFields);
    MovementCorrelationofHCPComparatorSpines = cell(1,NumFields);
    SuccessCentricHCPClusterCorrelation = cell(1,NumFields);
    
    MovementTracesOccurringwithClusterCoActivity = [];
    MovementTracesOccurringwithAntiClusterCoActivity = [];
    IsMovementRewardedEarly = cell(1,NumFields);
    IsMovementRewardedLate = cell(1,NumFields);
    IsCoActiveAntiClusterMovementRewarded = [];
    IsCoActiveMovementRewarded = [];
    ChanceRewardedLevel = cell(1,NumFields);
    ChanceRewardedLevelElimVersion = cell(1,NumFields);
    
    DendsWithBothDynamics = repmat({0},1,NumFields);
    DendsWithBothClustDynamics = repmat({0},1,NumFields);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%
    for f = 1:NumFields
        NumberofSpines = size(FieldChanges{f},1);
        %%%%%%%%%%%%% 
        %%% When chosing data to use (i.e. dend subtracted vs. excluded),
        %%% you must change everything that mentions STATCLASS,
        %%% CORRELATIONS, as well as raw activity
        SessionsbyField{f} = cell2mat(cellfun(@(x) x(:).Session, FieldData{f}.CalciumData, 'uni', false));
        earlysession = FieldData{f}.CalciumData{1}.Session;
        latesession = FieldData{f}.CalciumData{end}.Session;
        %%%%%%%%%%%%%%%%
        FocusOn = 'All';    %%% Change this value between "Rewarded" and "All" to consider different categories of movements;
        eval(['binarizedleverEarly = ', currentanimal, '_Aligned{',num2str(earlysession),'}.Binarized_Lever;']);
        eval(['successtraceEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SuccessfulPresses;']);
        eval(['levertraceEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.LeverMovement;']);
        eval(['rewardperiodsEarly = ', currentanimal, '_Aligned{', num2str(earlysession), '}.RewardDelivery;']);
        eval(['binarizedleverLate = ', currentanimal, '_Aligned{',num2str(latesession),'}.Binarized_Lever;']);
        eval(['successtraceLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.SuccessfulPresses;']);
        eval(['levertraceLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.LeverMovement;']);
        eval(['rewardperiodsLate = ', currentanimal, '_Aligned{', num2str(latesession), '}.RewardDelivery;']);
        failuretraceEarly = binarizedleverEarly-successtraceEarly;
        failuretraceLate = binarizedleverLate-successtraceLate;
        %%%%%%%%%%%%%%%%
        boundMEarly = find(diff([Inf; binarizedleverEarly; Inf])~=0);
        allperiodsMEarly = mat2cell(binarizedleverEarly, diff(boundMEarly));
        moveperiodsEarly = allperiodsMEarly(cell2mat(cellfun(@any, allperiodsMEarly, 'uni', false)));
        boundSEarly = find(diff([Inf; successtraceEarly; Inf])~=0);
        allperiodsSEarly = mat2cell(successtraceEarly, diff(boundSEarly));
        successperiodsEarly = allperiodsSEarly(cell2mat(cellfun(@any, allperiodsSEarly, 'uni', false)));
        success_allmove_separated_Early = mat2cell(successtraceEarly, diff(boundMEarly));
        success_allmove_separated_moveperiods_Early = success_allmove_separated_Early(cellfun(@any, allperiodsMEarly));
        IsMovementRewardedEarly{f} = cellfun(@any, success_allmove_separated_moveperiods_Early);
        %%%
        boundMLate = find(diff([Inf; binarizedleverLate; Inf])~=0);
        allperiodsMLate = mat2cell(binarizedleverLate, diff(boundMLate));
        moveperiodsLate = allperiodsMLate(cell2mat(cellfun(@any, allperiodsMLate, 'uni', false)));
        boundSLate = find(diff([Inf; successtraceLate; Inf])~=0);
        allperiodsSLate = mat2cell(successtraceLate, diff(boundSLate));
        successperiodsLate = allperiodsSLate(cell2mat(cellfun(@any, allperiodsSLate, 'uni', false)));
        success_allmove_separated_Late = mat2cell(successtraceLate, diff(boundMLate));
        success_allmove_separated_moveperiods_Late = success_allmove_separated_Late(cellfun(@any, allperiodsMLate));
        IsMovementRewardedLate{f} = cellfun(@any, success_allmove_separated_moveperiods_Late);
        %%%%%%%%%%%%%
        Spine1_Address = 10;
        NumberofEarlySpines = FieldData{f}.CalciumData{1}.NumberofSpines;
        NumberofLateSpines = FieldData{f}.CalciumData{end}.NumberofSpines;
        SpineDendriteGrouping{f} = FieldData{f}.CalciumData{1}.SpineDendriteGrouping;
        switch AnalysisType
            case 'Exclude'
                NumberofPersistentMovementRelatedSpines{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.StatClass{end}.MovementSpines));
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.StatClass{end}.MovementSpines))/sum(FieldData{1}.StatClass{1}.MovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.MovementSpines);
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.MovementSpines);
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.MovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations = FieldData{f}.Correlations{end}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
            case 'Subtract'
                NumberofPersistentMovementRelatedSpines{f} = sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.StatClass{end}.DendSub_MovementSpines));
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.StatClass{end}.DendSub_MovementSpines))/sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.DendSub_MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.DendSub_MovementSpines);
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.DendSub_MovementSpines);
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{f}.StatClass, 'uni', false));
                if ConsiderOnlyMovementPeriods
                    AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendriteSubtractedSpineDuringMovePeriods; %%% This matrix only considers spines and not behavioral features, so the whole matrix is taken (unlike the matrix for all periods, below)
                    AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendriteSubtractedSpineDuringMovePeriods;
                else
                    AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                    AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
                end
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
        end
        NumberofEarlyMovementRelatedSpines = NumberofEarlyMovementRelatedSpines+length(AllMovementSpinesOnEarlySession);
        NumberofLateMovementRelatedSpines = NumberofLateMovementRelatedSpines+length(AllMovementSpinesOnLateSession);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AllDendriteDistances{f} = FieldData{f}.CalciumData{end}.DistanceHeatMap;
        flipped = FieldData{f}.CalciumData{end}.DistanceHeatMap';
        AllDendriteDistances{f}(isnan(AllDendriteDistances{f})&~isnan(flipped)) = flipped(isnan(AllDendriteDistances{f})&~isnan(flipped));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shuffnum = 1000;
        ShuffledEarlyMovementLabels = cell(1,shuffnum);
        ShuffledLateMovementLabels = cell(1,shuffnum);
        clusterdistance = 13;
        for shuff = 1:shuffnum
            ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines,[length(AllMovementSpinesOnEarlySession),1]);
            ShuffledLateMovementLabels{shuff} = randi(NumberofLateSpines,[length(AllMovementSpinesOnLateSession),1]);
            if length(ShuffledEarlyMovementLabels{shuff})>length(AllMovementSpinesOnEarlySession)/2
                replimit = 1;
                while any(ismember(ShuffledEarlyMovementLabels{shuff}, AllMovementSpinesOnEarlySession))>length(AllMovementSpinesOnLateSession)/2 && replimit<1000  %%% Attempt to exclude actual movement related spines from being included
                    ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines, [length(AllMovementSpinesOnEarlySession),1]);
                    replimit = replimit+1;
                end
            else
                replimit = 1;
                while sum(ismember(ShuffledEarlyMovementLabels{shuff}, AllMovementSpinesOnEarlySession))>length(AllMovementSpinesOnEarlySession)/2 && replimit<1000
                    ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines, [length(AllMovementSpinesOnEarlySession),1]);
                    replimit = replimit+1;
                end
            end
            replimit = 1;
            while any(ismember(ShuffledLateMovementLabels{shuff}, AllMovementSpinesOnLateSession)) && replimit <1000
                ShuffledLateMovementLabels{shuff} = randi(NumberofLateSpines, [length(AllMovementSpinesOnLateSession),1]);
                replimit = replimit+1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%% Find and index any new spines from each field %%%%%%%%%
        if size(FieldChanges{f},2) >1   %%%If more than two sessions (three session data can reveal, e.g., transient new spines that don't persist; primary interest is in those that persist)
            NewSpines{f} = find(sum(FieldChanges{f},2)>0);
            MiddleSessionNewSpines{f}  = find(FieldChanges{f}(:,1)>0);
            LateSessionNewSpines{f} = find(FieldChanges{f}(:,2)>0);
            if ~isempty(MiddleSessionNewSpines{f})
                persistentNewSpines{f} = MiddleSessionNewSpines{f}(ismember(MiddleSessionNewSpines{f}, find(FieldData{f}.Data(:,3))));
            else
                persistentNewSpines{f} = [];
            end
            isThreeSessions = 1;
        else
            NewSpines{f} = find(FieldChanges{f}>0);
            MiddleSessionNewSpines{f} = [];
            LateSessionNewSpines{f} = NewSpines{f};
            isThreeSessions = 0;
        end
        newspineslogical = zeros(NumberofSpines,1); newspineslogical(NewSpines{f}) = 1;
        for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
            SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
            NewSpinesbyDendrite{f}{dnd} = newspineslogical(SpinesOnThisDend);
        end

        NumberofNewSpines = NumberofNewSpines+length(NewSpines{f});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        persistentclustercount = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Find and index spines that aren't new or movement related at
        %%% any point, then describe the activity of these spines
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AllOtherSpines = setdiff(1:NumberofLateSpines, union(NewSpines{f}, union(AllMovementSpinesOnEarlySession,AllMovementSpinesOnLateSession)));
        switch AnalysisType
            case 'Subtract'
                OtherSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(AllOtherSpines,:);
                eval(['OtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized([', num2str(AllOtherSpines), '],:);'])
            case 'Exclude'
                OtherSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(AllOtherSpines,:);
                eval(['OtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized([', num2str(AllOtherSpines), '],:);'])
        end
        for oth = 1:size(OtherSpineActivityAligned,1)
            if ~any(OtherSpineActivityAligned(oth,:)==0)
                OtherSpineActivityAligned(oth,:) = zeros(1,length(OtherSpineActivityAligned(oth,:)));
            end
        end
        success_centric_otherspine_activity = OtherSpineActivityAligned.*successtraceLate';
        success_centric_otherspine_correlation = corrcoef(success_centric_otherspine_activity');
        success_centric_otherspine_correlation(success_centric_otherspine_correlation==1)=nan;
        SuccessCentricCorrelationofAllOtherSpines{f} = nanmedian(success_centric_otherspine_correlation,2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %% Analyze dendrites that show new spines
        if ~isempty(NewSpines{f})    %%% If there are new spines, characterize each
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% First, characterize the classification of any new spines
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
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Compare new spines to EARLY SESSION movement related spines
            if ~isempty(AllMovementSpinesOnEarlySession)    %%% NOTE: THIS SECTION ONLY CONSIDERS NEW SPINES THAT ARE ON THE SAME DENDRITES AS AT LEAST ONE MOVEMENT-RELATED SPINE; DO NOT CONFUSE THIS FOR ALL NEW SPINES
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for ns = 1:length(NewSpines{f})             %%% FOR EACH NEW SPINE THAT IS ON A DENDRITE WITH AT LEAST ONE MOVEMENT RELATED SPINE
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%% Categorize New Spine based on when it was formed
                    if isThreeSessions %%% Only accurate when there is actually 3 sessions of data
                        if ismember(NewSpines{f}(ns), MiddleSessionNewSpines{f})
                            isMidorLate = 'Mid';
                        elseif ismember(NewSpines{f}(ns), LateSessionNewSpines{f})
                            isMidorLate = 'Late';
                        end
                    else
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch AnalysisType
                        case 'Subtract'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                        case 'Exclude'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Initialize temporary/counting variables for each
                    %%% new spine 
                    NewSpinestoEarlyMovementSpines = NaN;
                    NewSpinesEarlyMovementSpinesLateCorr = NaN;
                    NewSpinesCorrwithCloseEarlyMRS = NaN;
                    MovementSpineDistanceMatchedControlCorr = NaN;
                    DistMatchedNonEarlyMRPartnersCorr = NaN;
                    NewSpinestoShuffledEarlyMovementSpines = NaN;
                    DendCorrNewSpineOnly = NaN;
                    DendCorrMoveSpineOnly = NaN;
                    DendCorrCoactiveCluster = NaN;
                    MoveSpineOnlywithMovement = NaN; MoveSpineOnlywithSuccess = NaN;
                    NewSpineOnlywithMovement = NaN; NewSpineOnlywithSuccess = NaN;
                    CoactiveClusterwithMovement = NaN; CoactiveClusterwithSuccess = NaN;
                    success_centric_cluster_correlation = NaN; SuccessCentricDistMatchedCorrelation = NaN; SuccessCentricDistMatchedCorrelationforMRS = NaN; failure_centric_cluster_correlation = NaN;
                    combined_activity_move_corr = NaN;combined_activity_success_corr = NaN;
                    clustermovementreliability = NaN; clustersuccessreliability = NaN; controlpairmovereliability = NaN; controlpairsuccreliability = NaN;
                    CoActiveMovementCorr = NaN;CoActiveMovementCorrwithModelMovement = NaN;
                    OtherMovementCorr = NaN; Comp_CoActiveClusterMovementCorr = NaN;OtherCorrwithModelMovement = NaN; Comp_CoActiveMovementCorrwithModelMovement = NaN;
                    ChanceReward = NaN;
                    count = 1;
                    closecount = 1;
                    controlcount = 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Vouch to use only MR dends !!!!!
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines{f}(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
%                     if FilterforMovementDends
%                         if ~ismember(ParentDend, find(FieldData{f}.StatClass{end}.MovementDends))
%                             continue
%                         end
%                     else
%                     end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for ms = 1:length(AllMovementSpinesOnEarlySession)  %%% FOR ALL MOVEMENT RELATED SPINES THAT FIT THE ABOVE CRITERIA (i.e. THOSE THAT ARE ON A DENDRITE WITH NEW SPINES)
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%% Choose to filter for persistent movement
                        %%%% related spines!
%                         if FilterforPersistentMRSs
%                             if ~ismember(AllMovementSpinesOnEarlySession(ms), AllMovementSpinesOnLateSession)
%                                 continue
%                             end
%                         else
%                         end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        switch AnalysisType
                            case 'Subtract'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(ns), AllMovementSpinesOnEarlySession(ms)))), '],:);'])
                            case 'Exclude'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.SynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(ns), AllMovementSpinesOnEarlySession(ms)))), '],:);'])
                        end
                        MoveSpineActivityAligned(isnan(MoveSpineActivityAligned)) = 0;
                        AllOtherSpineActivityAligned(isnan(AllOtherSpineActivityAligned)) = 0;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        bothactivity = logical(NewSpineActivityAligned+MoveSpineActivityAligned);
                        [val, ~] = sort([NewSpines{f}(ns), AllMovementSpinesOnEarlySession(ms)]);
                        NewSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        NewSpinesEarlyMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));   %%% Find the correlation of new spines with the movement spines from early sessions (they might not be movement-related at the late sessions, but are they highly correlated with the new spine?)                        
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%% Clustering Section 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if NewSpinestoEarlyMovementSpines(1,count)<clusterdistance
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% First, count spines that meet criteria %%%%
                            ClusteredNewSpines{f} = [ClusteredNewSpines{f}, NewSpines{f}(ns)];
                            ClusteredEarlyMoveSpines{f} = [ClusteredEarlyMoveSpines{f},AllMovementSpinesOnEarlySession(ms)];
                            if ismember(AllMovementSpinesOnEarlySession(ms), AllMovementSpinesOnLateSession)
                                persistentclustercount = persistentclustercount+1;
                            end
                            NewSpinesCorrwithCloseEarlyMRS(1,closecount) = NewSpinesEarlyMovementSpinesLateCorr(1,count);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%% Find spines with similar frequencies for best comparisons
                            OtherSpFreq = [];
                            for spf = 1:size(AllOtherSpineActivityAligned,1)
                                OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineActivityAligned(spf,:))>0));
                            end
                            NewSpFreq = numel(find(diff(NewSpineActivityAligned)));
                                [~, CompSpFreqMatchedtoNS] = min(abs(OtherSpFreq-NewSpFreq));
                            CMRSFreq = numel(find(diff(MoveSpineActivityAligned)));   %%% Clustered MRS frequency
                                [~, CompSpFreqMatchedtoCMRS] = min(abs(OtherSpFreq(setdiff(1:length(OtherSpFreq), CompSpFreqMatchedtoNS))-CMRSFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Compare Activity of Clustered (both new and
                            %%% MRS) Spines with Dendrite
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            switch AnalysisType
                                case 'Subtract'
                                    MoveSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(AllMovementSpinesOnEarlySession(ms),:);
                                    MoveSpineActivity(isnan(MoveSpineActivity)) = 0;
                                    CoActiveCluster =  logical(NewSpineActivity & MoveSpineActivity);
                                case 'Exclude'
                                    MoveSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(AllMovementSpinesOnEarlySession(ms),:);
                                    MoveSpineActivity(isnan(MoveSpineActivity)) = 0;
                                    CoActiveCluster = logical(NewSpineActivity & MoveSpineActivity);
                            end
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
                            coactivetrace = MoveSpineActivityAligned.*NewSpineActivityAligned;
                            moveonly = corrcoef([binarizedleverLate, MoveSpineActivityAligned']);
                            newonly = corrcoef([binarizedleverLate, NewSpineActivityAligned']);
                            coactive = corrcoef([binarizedleverLate, coactivetrace']);
                            MoveSpineOnlywithMovement(1,closecount) = moveonly(1,2);
                            NewSpineOnlywithMovement(1,closecount) = newonly(1,2);
                            CoactiveClusterwithMovement(1,closecount) = coactive(1,2);
                            %%%
                            comp_coactivetrace = AllOtherSpineActivityAligned(CompSpFreqMatchedtoNS,:).*AllOtherSpineActivityAligned(CompSpFreqMatchedtoCMRS,:);
                            %%%
                            moveonly = corrcoef([successtraceLate, MoveSpineActivityAligned']);
                            newonly = corrcoef([successtraceLate, NewSpineActivityAligned']);
                            coactive = corrcoef([successtraceLate, coactivetrace']);
                            MoveSpineOnlywithSuccess(1,closecount) = moveonly(1,2);
                            NewSpineOnlywithSuccess(1,closecount) = newonly(1,2);
                            CoactiveClusterwithSuccess(1,closecount) = coactive(1,2);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% "NOISE CORRELATION "
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            success_centric_newspineactivity = NewSpineActivityAligned.*successtraceLate';
                            success_centric_movespineactivity = MoveSpineActivityAligned.*successtraceLate';
                            success_centric_correlations = corrcoef([success_centric_newspineactivity', success_centric_movespineactivity']);
                            success_centric_cluster_correlation(1,closecount) = success_centric_correlations(1,2);
                            if success_centric_cluster_correlation >0.1
                                disp(['Animal ', currentanimal, ', Field ', num2str(f), ' spines ', num2str(NewSpines{f}(ns)), ' & ', num2str(AllMovementSpinesOnEarlySession(ms)), ' have high noise correlation!'])
                            end
                            %%%
                            failure_centric_newspineactivity = NewSpineActivityAligned.*failuretraceLate';
                            failure_centric_movespineactivity = MoveSpineActivityAligned.*failuretraceLate';
                            failure_centric_correlations = corrcoef([failure_centric_newspineactivity', failure_centric_movespineactivity']);
                            failure_centric_cluster_correlation(1,closecount) = failure_centric_correlations(1,2);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% The goal of this section is to determine
                            %%% whether the combined activity of two
                            %%% clustered spines covers more
                            %%% movements/increases reliability of a single
                            %%% input type (note: NOT coactive periods, but
                            %%% their collective representation)
                            combinedcorr = corrcoef([successtraceLate, bothactivity']);
                            combined_activity_move_corr(1,closecount) = combinedcorr(1,2);
                            combinedcorr = corrcoef([successtraceLate,bothactivity']);
                            combined_activity_success_corr(1,closecount) = combinedcorr(1,2);
                            bothspineactivity_Moveseparated = mat2cell(bothactivity', diff(boundMLate));
                            bothspineactivity_Succseparated = mat2cell(bothactivity', diff(boundSLate));
                            bothspineactivity_moveperiods = bothspineactivity_Moveseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsMLate, 'uni', false)));
                            numberofmovementswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), moveperiodsLate, bothspineactivity_moveperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine pair
                            clustermovementreliability(1,closecount) = numberofmovementswithclusteractivity/length(moveperiodsLate);
                            bothspineactivity_successperiods = bothspineactivity_Succseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsSLate, 'uni', false)));
                            numberofsuccesseswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), successperiodsLate, bothspineactivity_successperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
                            clustersuccessreliability(1,closecount) = numberofsuccesseswithclusteractivity/length(successperiodsLate);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%% Movements with cluster co-activity %%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            switch FocusOn
                                case 'Rewarded'
                                    boundstouse = boundSLate;
                                    allperiodblocks = allperiodsSLate;
                                    targetperiods = successperiodsLate;
                                case 'All'
                                    boundstouse = boundMLate;
                                    allperiodblocks = allperiodsMLate;
                                    targetperiods = moveperiodsLate;
                            end
                            lever_separated = mat2cell(levertraceLate, diff(boundstouse));   %%% Even if you want successful presses, you want to start with the actual lever force trace (i.e. NOT the binarized trace) so as to characterize movement stereotypy
                            frames = 1:length(levertraceLate);
                            frames_separated = mat2cell(frames', diff(boundstouse));
                            coactive_separated = mat2cell(coactivetrace', diff(boundstouse));
                            coactive_trace_during_allperiods = coactive_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            lever_trace_during_allperiods = lever_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            frames_during_allperiods = frames_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            CoActiveDuringMovement_Addresses = find(cell2mat(cellfun(@(x,y) any(x)&any(y), targetperiods, coactive_trace_during_allperiods, 'uni', false)));
                            TargetMovementswithCoactivity = lever_trace_during_allperiods(CoActiveDuringMovement_Addresses);
                            framesofinterest = frames_during_allperiods(CoActiveDuringMovement_Addresses);
                            if ~isempty(framesofinterest)
                                MovementswithClusterCoActivity = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate, secondspostmovementstart, ImagingFrequency);
                                MovementTracesOccurringwithClusterCoActivity = [MovementTracesOccurringwithClusterCoActivity, MovementswithClusterCoActivity];
                                IsCoActiveMovementRewarded = [IsCoActiveMovementRewarded; cell2mat(cellfun(@(x) any(successtraceLate(x)), framesofinterest, 'uni', false))];
                                for shf = 1:100 %%% Find the chance level of cluster co-activity occurring during a rewarded movement
                                    SimRew = shake(IsMovementRewardedLate{f});
                                    chance(shf) = sum(SimRew(CoActiveDuringMovement_Addresses))/length(CoActiveDuringMovement_Addresses);
                                end
                                ChanceReward(closecount) = nanmean(chance);
                                if size(MovementswithClusterCoActivity,2)>1
                                    movementcorr = corrcoef([MovementswithClusterCoActivity, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    CoActiveMovementCorr(closecount) = nanmedian(thissessionmovementcorr(:));
                                    CoActiveMovementCorrwithModelMovement(closecount) = nanmedian(movementcorr(end,:));
                                else
                                    CoActiveMovementCorr(closecount) = NaN;
                                    CoActiveMovementCorrwithModelMovement(closecount) = NaN;
                                end
                            else
                                CoActiveMovementCorr(closecount) = NaN;
                                CoActiveMovementCorrwithModelMovement(closecount) = NaN;
                            end
                            framesofinterest = frames_during_allperiods(setdiff(1:length(frames_during_allperiods),CoActiveDuringMovement_Addresses));
                            if ~isempty(framesofinterest)
                                [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate, secondspostmovementstart, ImagingFrequency);
                                movementcorr = corrcoef([SuccessfulPresseswithoutCoactivity, ModelMovement']);
                                movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                                thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                OtherMovementCorr(closecount) = nanmedian(thissessionmovementcorr(:));
                                OtherCorrwithModelMovement(closecount) = nanmedian(movementcorr(end,:));
                            else
                                OtherMovementCorr(closecount) = NaN;
                                OtherCorrwithModelMovement(closecount) = NaN;
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the same features for freq-matched
                            %%% spine pairs
                            comp_coactive_separated = mat2cell(comp_coactivetrace', diff(boundstouse));    %%% Separate the coactive trace according to the bounds of the successful/rewarded lever press trace
                            comp_coactive_trace_during_success = comp_coactive_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocks, 'uni', false))); %%% First, find the cases when the lever is actually being pressed (where 'allperiodblocks' is nonzero), and extract the activity traces DURING THESE PERIODS
                            comp_CoActiveAddresses = logical(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), targetperiods, comp_coactive_trace_during_success, 'uni', false)));
                            framesofinterest = frames_during_allperiods(comp_CoActiveAddresses);
                            if ~isempty(framesofinterest)
                                MovementswithCompCoActivity = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate, secondspostmovementstart, ImagingFrequency);
                                if size(MovementswithCompCoActivity,2)>1
                                    movementcorr = corrcoef([MovementswithCompCoActivity, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    Comp_CoActiveClusterMovementCorr(closecount) = nanmedian(thissessionmovementcorr(:));
                                    Comp_CoActiveMovementCorrwithModelMovement(closecount) = nanmedian(movementcorr(end,:));
                                else
                                    Comp_CoActiveClusterMovementCorr(closecount) = NaN;
                                    Comp_CoActiveMovementCorrwithModelMovement(closecount) = NaN;
                                end
                            else
                                Comp_CoActiveClusterMovementCorr(closecount) = NaN;
                                Comp_CoActiveMovementCorrwithModelMovement(closecount) = NaN;
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            DistanceMatchedNonMRPartners = find(AllDendriteDistances{f}(NewSpines{f}(ns),:)<=clusterdistance);
                            DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(union(AllMovementSpinesOnLateSession, AllMovementSpinesOnEarlySession), NewSpines{f}));
                            DistMatchedNonEarlyMRPartnersCorr = nanmedian(AllLateSpineCorrelations(NewSpines{f}(ns), DistanceMatchedNonMRPartners));
                            switch AnalysisType
                                case 'Subtract'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                case 'Exclude'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                            end
                            success_centric_distmatched_activity = DistanceMatchedActivity'.*(repmat(successtraceLate,1,length(DistanceMatchedNonMRPartners)));
                            success_centric_distmatched_correlation = corrcoef([NewSpineActivityAligned', success_centric_distmatched_activity]);
                            SuccessCentricDistMatchedCorrelation(1,closecount) = nanmedian(success_centric_distmatched_correlation(1,2:end));
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the analogous features of the movement
                            %%% spine with another nearby spine (as a control
                            %%% for the clustered new spine)
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            DistanceMatchedNonNewPartners = find(AllDendriteDistances{f}(AllMovementSpinesOnEarlySession(ms), :)<=clusterdistance);
                            DistanceMatchedNonNewPartners = setdiff(DistanceMatchedNonNewPartners, NewSpines{f});
                            switch AnalysisType
                                case 'Subtract'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(DistanceMatchedNonNewPartners), '],:);'])
                                case 'Exclude'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(DistanceMatchedNonNewPartners), '],:);'])
                            end
                            DistanceMatchedActivity(isnan(DistanceMatchedActivity)) = 0;
                            controlgroupedactivity = logical(MoveSpineActivityAligned+DistanceMatchedActivity);
                            controlgroupedactivity_Moveseparated =  mat2cell(controlgroupedactivity', diff(boundMLate));
                            controlgroupedactivity_Succseparated =  mat2cell(controlgroupedactivity', diff(boundSLate));  
                            controlgroupedactivity_moveperiods = controlgroupedactivity_Moveseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsMLate, 'uni', false)));
                            controlgroupedactivity_succperiods = controlgroupedactivity_Succseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsSLate, 'uni', false)));
                            MovementSpineDistanceMatchedControlCorr(1,closecount) = nanmedian(AllLateSpineCorrelations(AllMovementSpinesOnEarlySession(ms),DistanceMatchedNonNewPartners));
                            success_centric_distmatched_activity = DistanceMatchedActivity.*successtraceLate';
                            success_centric_distmatched_correlation = corrcoef([MoveSpineActivityAligned', success_centric_distmatched_activity']); %% success_centric_distmatched_correlation(1:size(success_centric_distmatched_correlation,1)+1:numel(success_centric_distmatched_correlation)) = nan;
                            SuccessCentricDistMatchedCorrelationforMRS(1,closecount) = nanmedian(success_centric_distmatched_correlation(1,2:end));
                            for cs = 1:length(DistanceMatchedNonNewPartners)
                                controlpairmovereliability(1,controlcount) = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y(:,cs))>1), moveperiodsLate, controlgroupedactivity_moveperiods, 'uni', false)))))/length(moveperiodsLate);
                                controlpairsuccreliability(1,controlcount) = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y(:,cs))>1), successperiodsLate, controlgroupedactivity_succperiods, 'uni', false)))))/length(successperiodsLate);
                                controlcount = controlcount+1;
                            end
                            closecount = closecount+1;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        end
                        count = count+1;
                    end

                    %%%
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([NewSpines{f}(ns),ShuffledEarlyMovementLabels{shuff}(sh)]); %%% Sort for consistent indexing in the distance matrix
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        NewSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        shuffleddistances = [];
                        count = count+1;
                    end
                    if ~any(~isnan(NewSpinestoEarlyMovementSpines))
                        NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner+1;
                    end
                    [DistancesBetweenNewSpinesandEarlyMovementSpines{f}(ns), ind] = nanmin(NewSpinestoEarlyMovementSpines);
                    if DistancesBetweenNewSpinesandEarlyMovementSpines{f}(ns)<=clusterdistance
                        NumberofMovementClusteredNewSpines = NumberofMovementClusteredNewSpines+1;
                        if FieldData{f}.StatClass{end}.DendSub_MovementSpines(NewSpines{f}(ns))
                            NumberofMovementClusteredNewSpinesThatAreMR = NumberofMovementClusteredNewSpinesThatAreMR+1;
                        end
                    end
                    %%%
                    NewSpineAllSpinesDistance{f}(ns,:) = AllDendriteDistances{f}(ns,:);
                    NewSpineAllSpinesLateCorr{f}(ns,:) = AllLateSpineCorrelations(ns,:);
                    %%%
                    LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions{f}(ns) = NewSpinesEarlyMovementSpinesLateCorr(ind);
                    NewSpinesCorrwithNearbyEarlyMRSs{f}(ns) = nanmax(NewSpinesCorrwithCloseEarlyMRS);
                    MovementSpineDistanceMatchedControlCorrelation{f}{ns} = MovementSpineDistanceMatchedControlCorr;
                    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{f}(ns) = nanmean(DistMatchedNonEarlyMRPartnersCorr);
                    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{f}{ns} = NewSpinestoShuffledEarlyMovementSpines;
                    ClusteredNewSpineCorrwithDendrite{f}{ns} = DendCorrNewSpineOnly;
                    ClusteredNewSpineCorrwithMovement{f}{ns} = NewSpineOnlywithMovement;
                    ClusteredNewSpineCorrwithSuccess{f}{ns} = NewSpineOnlywithSuccess;
                    ClusteredMoveSpineCorrwithDendrite{f}{ns} = DendCorrMoveSpineOnly;
                    ClusteredMoveSpineCorrwithMovement{f}{ns} = MoveSpineOnlywithMovement;
                    ClusteredMoveSpineCorrwithSuccess{f}{ns} = MoveSpineOnlywithSuccess;
                    CoActiveClusterCorrwithDendrite{f}{ns} = DendCorrCoactiveCluster;
                    CoActiveClusterCorrwithMovement{f}{ns} = CoactiveClusterwithMovement;
                    CoActiveClusterCorrwithSuccess{f}{ns} = CoactiveClusterwithSuccess;
                    %%%
                    SuccessCentricClusterCorrelation{f}{ns} = success_centric_cluster_correlation;
                    FailureCentricClusterCorrelation{f}{ns} = failure_centric_cluster_correlation;
                    SuccessCentricDistanceMatchedCorrelation{f}{ns} = SuccessCentricDistMatchedCorrelation;
                    SuccessCentricDistanceMatchedCorrelationforMRS{f}{ns} = SuccessCentricDistMatchedCorrelationforMRS;
                    %%%
                    CombinedClusterActivityCorrwithMovement{f}{ns} = combined_activity_move_corr;
                    CombinedClusterActivityCorrwithSuccess{f}{ns} = combined_activity_success_corr;
                    ClusterMovementReliability{f}{ns} = clustermovementreliability;
                    ClusterSuccessReliability{f}{ns} = clustersuccessreliability;
                    ControlPairMovementReliability{f}{ns} = controlpairmovereliability;
                    ControlPairSuccessReliability{f}{ns} = controlpairsuccreliability;
                    MovementCorrelationwithCoActiveClusters{f}{ns} = CoActiveMovementCorr;
                    CoActiveClusterMovementsCorrelationwithModelMovement{f}{ns} = CoActiveMovementCorrwithModelMovement;
                    MovementCorrelationofAllOtherMovements{f}{ns} = OtherMovementCorr;
                    AllOtherMovementsCorrelationwithModelMovement{f}{ns} = OtherCorrwithModelMovement;
                    MovementCorrelationofFrequencyMatchedPairs{f}{ns} = Comp_CoActiveClusterMovementCorr;
                    FrequencyMatchedPairMovementsCorrelationwithModelMovement{f}{ns} = Comp_CoActiveMovementCorrwithModelMovement;
                    ChanceRewardedLevel{f}{ns} = ChanceReward;
                end
            else
                NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner+1;
                DistancesBetweenNewSpinesandEarlyMovementSpines{f} = nan(1,length(NewSpines{f}));
                LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions{f} = nan(1,length(NewSpines{f}));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            NumberofPersistentMovementSpinesClustered{f} = persistentclustercount;
            TaskCorrelationofNearbyEarlyMRSs{f} = behaviorcorrdataearly(:,ClusteredEarlyMoveSpines{f});
            NumberofClusteredMoveSpines{f} = length(unique(ClusteredNewSpines{f}));
            TaskCorrelationofClusteredNewSpines{f} = behaviorcorrdataearly(:,unique(ClusteredNewSpines{f}));
            MovementReliabilityofNearbyEarlyMRSs{f} = FieldData{f}.StatClass{1}.AllSpineReliability(ClusteredEarlyMoveSpines{f});
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Compare new spines to LATE session features
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
                        DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(AllMovementSpinesOnLateSession, AllMovementSpinesOnEarlySession));
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
                    LateCorrfNewSpinesandNearestMovementSpinefromLateSessions{f}(ns) = NewSpinesLateMovementSpinesLateCorr(ind);
                    NewSpinesCorrwithNearbyLateMRSs{f}(ns) = max(NewSpinesCorrwithCloseMRS);
                    NewSpinesCorrwithDistanceMatchedNonLateMRSs{f}(ns) = nanmean(DistMatchedNonLateMRPartnersCorr);
                    DistancesBetweenNewSpinesandRandomSpines{f}(ns) = NewSpinestoRandomSpines(randi(length(NewSpinestoRandomSpines)));
                    DistancesBetweenNewSpinesandShuffledMovementSpines{f}(ns) = nanmean(NewSpinestoShuffledMovementSpines);
                end
            else
                DistancesBetweenNewSpinesandLateMovementSpines{f} = nan(1,length(NewSpines{f}));
                LateCorrfNewSpinesandNearestMovementSpinefromLateSessions{f} = nan(1,length(NewSpines{f}));
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
            success_centric_HCPcluster_correlation = [];
            CoActiveHCPMovementCorr = []; OtherMovementCorr= []; Comp_CoActiveHCPMovementCorr = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%% End initialization for HCP section
            highcorrcount = 1;
            for hcp = 1:length(NewSpineMaxInd) %%% Note: every new spine should should have a corresponding max correlated partner, so you can use "hcp" as an index for new spines;
                if NewSpinesMaxCorr{f}(hcp) >= 0.2
                    switch AnalysisType
                        case 'Subtract'
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['HCPActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                        case 'Exclude'
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:).*', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(hcp)), ',:);'])
                            eval(['HCPActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:).*', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpineMaxInd(hcp)), ',:);'])
                            eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(NewSpines{f}(hcp), NewSpineMaxInd(hcp)))), '],:);'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%% Find spines with similar frequencies for best comparisons
                    OtherSpFreq = [];
                    for spf = 1:size(AllOtherSpineActivityAligned,1)
                        OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineActivityAligned(spf,:))>0));
                    end
                    NewSpFreq = numel(find(diff(NewSpineActivityAligned)));
                        [~, CompSpFreqMatchedtoNS] = min(abs(OtherSpFreq-NewSpFreq));
                    HCPFreq = numel(find(diff(HCPActivityAligned)));
                        [~, CompSpFreqMatchedtoHCP] = min(abs(OtherSpFreq(setdiff(1:length(OtherSpFreq), CompSpFreqMatchedtoNS))-HCPFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    coactivetrace = HCPActivityAligned.*NewSpineActivityAligned;
                    HCPonly = corrcoef([binarizedleverLate, HCPActivityAligned']);
                    newonly = corrcoef([binarizedleverLate, NewSpineActivityAligned']);
                    coactive = corrcoef([binarizedleverLate, coactivetrace']);
                    HCPOnlywithMovement(1,highcorrcount) = HCPonly(1,2);
                    NewSpineOnlywithMovement(1,highcorrcount) = newonly(1,2);
                    CoactiveHCPClusterwithMovement(1,highcorrcount) = coactive(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    comp_coactivetrace = AllOtherSpineActivityAligned(CompSpFreqMatchedtoNS,:).*AllOtherSpineActivityAligned(CompSpFreqMatchedtoHCP,:);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    HCPonly = corrcoef([successtraceLate, HCPActivityAligned']);
                    newonly = corrcoef([successtraceLate, NewSpineActivityAligned']);
                    coactive = corrcoef([successtraceLate, coactivetrace']);
                    HCPOnlywithSuccess(1,highcorrcount) = HCPonly(1,2);
                    NewSpineOnlywithSuccess(1,highcorrcount) = newonly(1,2);
                    CoactiveHCPClusterwithSuccess(1,highcorrcount) = coactive(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    success_centric_newspineactivity = NewSpineActivityAligned.*successtraceLate';
                    success_centric_HCPactivity = HCPActivityAligned.*successtraceLate';
                    success_centric_correlations = corrcoef([success_centric_newspineactivity', success_centric_HCPactivity']);
                    success_centric_HCPcluster_correlation(1,highcorrcount) = success_centric_correlations(1,2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch FocusOn
                        case 'Rewarded'
                            boundstouse = boundSLate;
                            allperiodblocks = allperiodsSLate;
                            targetperiods = successperiodsLate;
                        case 'All'
                            boundstouse = boundMLate;
                            allperiodblocks = allperiodsMLate;
                            targetperiods = moveperiodsLate;
                    end
                    lever_separated = mat2cell(levertraceLate, diff(boundstouse));
                    frames = 1:length(levertraceLate);
                    frames_separated = mat2cell(frames', diff(boundstouse));
                    coactive_separated = mat2cell(coactivetrace', diff(boundstouse));    %%% Separate the coactive trace according to the bounds of the successful/rewarded lever press trace
                    coactive_trace_during_allperiods = coactive_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocks, 'uni', false))); %%% First, find the cases when the lever is actually being pressed (where 'allperiodsS' is nonzero), and extract the activity traces DURING THESE PERIODS
                    lever_trace_during_success = lever_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocks, 'uni', false)));   %%% Extract the actual lever trace during these periods
                    frames_during_allperiods = frames_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocks, 'uni', false)));       %%% Extract the frames of interest during these periods
                    CoActiveDuringMovement_Addresses = find(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), targetperiods, coactive_trace_during_allperiods, 'uni', false)));
                    TargetMovementswithCoactivity = lever_trace_during_success(CoActiveDuringMovement_Addresses);
                    framesofinterest = frames_during_allperiods(CoActiveDuringMovement_Addresses);
                    if ~isempty(framesofinterest)
                        MovementswithClusterCoActivity = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate ,secondspostmovementstart, ImagingFrequency);
                        if size(MovementswithClusterCoActivity,2)>1
                            movementcorr = corrcoef(MovementswithClusterCoActivity);
                            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                            CoActiveHCPMovementCorr(highcorrcount) = nanmedian(movementcorr(:));
                        else
                            CoActiveHCPMovementCorr(highcorrcount) = NaN;
                        end
                    else
                        CoActiveHCPMovementCorr(highcorrcount) = NaN;
                    end
                    framesofinterest = frames_during_allperiods(setdiff(1:length(frames_during_allperiods),CoActiveDuringMovement_Addresses));
                    [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate,secondspostmovementstart, ImagingFrequency);
                    movementcorr = corrcoef(SuccessfulPresseswithoutCoactivity);
                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                    OtherMovementCorr(highcorrcount) = nanmedian(movementcorr(:));
                    %%%%%%%%%%%%%
                    comp_coactive_separated = mat2cell(comp_coactivetrace', diff(boundstouse));    %%% Separate the coactive trace according to the bounds of the successful/rewarded lever press trace
                    comp_coactive_trace_during_success = comp_coactive_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodblocks, 'uni', false))); %%% First, find the cases when the lever is actually being pressed (where 'allperiodsS' is nonzero), and extract the activity traces DURING THESE PERIODS
                    comp_CoActiveAddresses = find(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), targetperiods, comp_coactive_trace_during_success, 'uni', false)));
                    framesofinterest = frames_during_allperiods(comp_CoActiveAddresses);
                    if ~isempty(framesofinterest)
                        MovementswithCompCoActivity = ExtractMovementswithKnownBounds(levertraceLate, framesofinterest, rewardperiodsLate,secondspostmovementstart,ImagingFrequency);
                        if size(MovementswithCompCoActivity,2)>1
                            movementcorr = corrcoef(MovementswithCompCoActivity);
                            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                            Comp_CoActiveHCPMovementCorr(highcorrcount) = nanmedian(movementcorr(:));
                        else
                            Comp_CoActiveHCPMovementCorr(highcorrcount) = NaN;
                        end
                    else
                        Comp_CoActiveHCPMovementCorr(highcorrcount) = NaN;
                    end
                    highcorrcount = highcorrcount+1;
                end
            end
%             ClusteredNewSpineCorrwithDendrite{f} = DendCorrNewSpineOnly;
            HCPClusteredNewSpineCorrwithMovement{f} = NewSpineOnlywithMovement;
            HCPClusteredNewSpineCorrwithSuccess{f} = NewSpineOnlywithSuccess;
%             ClusteredMoveSpineCorrwithDendrite{f} = DendCorrHCPOnly;
            HCPCorrwithMovement{f} = HCPOnlywithMovement;
            HCPCorrwithSuccess{f} = HCPOnlywithSuccess;
%             CoActiveClusterCorrwithDendrite{f} = DendCorrCoactiveCluster;
            CoActiveHCPClusterCorrwithMovement{f} = CoactiveHCPClusterwithMovement;
            CoActiveHCPClusterCorrwithSuccess{f} = CoactiveHCPClusterwithSuccess;
            SuccessCentricHCPClusterCorrelation{f} = success_centric_HCPcluster_correlation;
            MovementCorrelationwithCoActiveHCPClusters{f} = CoActiveHCPMovementCorr;
            MovementCorrelationofAllOtherNonHCPMovements{f} = OtherMovementCorr;
            MovementCorrelationofHCPComparatorSpines{f} = Comp_CoActiveHCPMovementCorr;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for ns = 1:length(NewSpines{f})
                NewSpinesBehaviorCorrelation{f}(ns,1:9) = behaviorcorrdatalate(:,ns);
            end
            NonNewSpinesBehaviorCorrelationEarly{f} = behaviorcorrdataearly(:,setdiff(1:NumberofEarlySpines,union(NewSpines{f}, AllMovementSpinesOnEarlySession)));
            NonNewSpinesBehaviorCorrelationLate{f} = behaviorcorrdatalate(:,setdiff(1:NumberofLateSpines,union(NewSpines{f}, AllMovementSpinesOnLateSession)));
        end
        MovementReliabilityofOtherMoveSpines{f} = FieldData{f}.StatClass{1}.AllSpineReliability(setdiff(AllMovementSpinesOnEarlySession,ClusteredEarlyMoveSpines{f}));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(FieldChanges{f},2)>1    %%% Eliminated spines are different that new spines in that they are (probably) never 'transiently' eliminated (1->0->1); however, a new spine can be eliminated immediately (0->1->0, and so you cannot simply sum the difference columns to report change whether any elimination occurred
            for fc = 1:size(FieldChanges{f},2)
                ElimSpines{f} = [ElimSpines{f}; find(FieldChanges{f}(:,fc)<0)];
            end
        else
            ElimSpines{f} = find(FieldChanges{f}<0);
        end
        elimspineslogical = zeros(NumberofSpines,1); elimspineslogical(NewSpines{f}) = 1;
        for dnd = 1:length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping)
            SpinesOnThisDend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{dnd};
            ElimSpinesbyDendrite{f}{dnd} = elimspineslogical(SpinesOnThisDend);
        end
        NumberofElimSpines = NumberofElimSpines+length(ElimSpines);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(ElimSpines{f})    %%% If there are new spines, find out whether they are close to a nearby movement spine
            ElimSpinesThatWereMR = ElimSpines{f}(ismember(ElimSpines{f}, find(FieldData{f}.StatClass{1}.DendSub_MovementSpines)));
            NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR+sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(ElimSpines{f}));
            OtherMovementSpinesThatArentElim = setdiff(AllMovementSpinesOnLateSession,ElimSpines{f});
            %%% Compare eliminated spines to early session features
            if ~isempty(AllMovementSpinesOnEarlySession)
                for es = 1:length(ElimSpines{f})
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    switch AnalysisType
                        case 'Subtract'
                            ElimSpineActivity = FieldData{f}.CalciumData{1}.SynapseOnlyBinarized_DendriteSubtracted(ElimSpines{f}(es),:);
                            eval(['ElimSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.DendSubSynapseOnlyBinarized(', num2str(ElimSpines{f}(es)), ',:);'])
                        case 'Exclude'
                            ElimSpineActivity = FieldData{f}.CalciumData{1}.SynapseOnlyBinarized(ElimSpines{f}(es),:);
                            eval(['ElimSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession),'}.SynapseOnlyBinarized(', num2str(ElimSpines{f}(es)), ',:);'])
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ElimSpinestoEarlyMovementSpines = [];
                    ElimSpinestoShuffledEarlyMovementSpines = [];
                    ElimSpinesCorrwithCloseMRS = nan;
                    DistMatchedNonEarlyMRPartnersCorr = NaN;
                    success_centric_anticluster_correlation = NaN; SuccessCentricDistMatchedtoAntiClustCorrelation = NaN;
                    CoActiveAntiClustMovementCorr = NaN;CoActiveAntiClustMovementCorrwithModelMovement = NaN; 
                    OtherMovementCorrElimVersion = NaN; Comp_CoActiveAntiClusterMovementCorr = NaN;OtherCorrwithModelMovementElimVersion = NaN; Comp_CoActiveAntiClusterMovementCorrwithModelMovement = NaN;
                    ChanceReward = NaN;
                    count = 1;
                    closecount = 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for ms = 1:length(AllMovementSpinesOnEarlySession) 
                        switch AnalysisType
                            case 'Subtract'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.DendSubSynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), AllMovementSpinesOnEarlySession(ms)))), '],:);'])
                            case 'Exclude'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(earlysession),'}.SynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                                eval(['AllOtherSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SynapseOnlyBinarized([', num2str(setdiff(1:NumberofLateSpines, union(ElimSpines{f}(es), AllMovementSpinesOnEarlySession(ms)))), '],:);'])
                        end
                        MoveSpineActivityAligned(isnan(MoveSpineActivityAligned)) = 0;
                        AllOtherSpineActivityAligned(isnan(AllOtherSpineActivityAligned)) = 0;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [val, ~] = sort([ElimSpines{f}(es), AllMovementSpinesOnEarlySession(ms)]);
                        ElimSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        CorrElimSpinestoEarlyMovementSpines(1,count) = AllEarlySpineCorrelations(val(1), val(2));
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%% Anti-Clustering Section 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if ElimSpinestoEarlyMovementSpines(1,count)<clusterdistance 
                            ElimSpinesCorrwithCloseMRS(1,closecount) = CorrElimSpinestoEarlyMovementSpines(1,count);
                            AntiClusteredElimSpines{f} = [AntiClusteredElimSpines{f}, ElimSpines{f}(es)];
                            AntiClusteredEarlyMoveSpines{f} = [AntiClusteredEarlyMoveSpines{f},AllMovementSpinesOnEarlySession(ms)];
                            coactivetrace = MoveSpineActivityAligned.*ElimSpineActivityAligned;
                            %%% Find frequency-matched spines
                            OtherSpFreq = [];
                            for spf = 1:size(AllOtherSpineActivityAligned,1)
                                OtherSpFreq(1,spf) = numel(find(diff(AllOtherSpineActivityAligned(spf,:))>0));
                            end
                            ElimSpFreq = numel(find(diff(ElimSpineActivityAligned)));
                                [~, CompSpFreqMatchedtoES] = min(abs(OtherSpFreq-ElimSpFreq));
                            ACMRSFreq = numel(find(diff(MoveSpineActivityAligned)));   %%% Anti-Clustered MRS frequency
                                [~, CompSpFreqMatchedtoACMRS] = min(abs(OtherSpFreq(setdiff(1:length(OtherSpFreq), CompSpFreqMatchedtoES))-ACMRSFreq)); %%% The spine that was found to be freq-matched to the new spine is excluded to prevent the same spine being matched for both
                            comp_coactivetrace = AllOtherSpineActivityAligned(CompSpFreqMatchedtoES,:).*AllOtherSpineActivityAligned(CompSpFreqMatchedtoACMRS,:);
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% "NOISE CORRELATION "
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%
                            success_centric_elimspineactivity = ElimSpineActivityAligned.*successtraceEarly';
                            success_centric_movespineactivity = MoveSpineActivityAligned.*successtraceEarly';
                            anticlust_success_centric_correlations = corrcoef([success_centric_elimspineactivity', success_centric_movespineactivity']);
                            success_centric_anticluster_correlation(1,closecount) = anticlust_success_centric_correlations(1,2);
                            if success_centric_anticluster_correlation >0.1
                                disp(['Animal ', currentanimal, ', Field ', num2str(f), ' spines ', num2str(ElimSpines{f}(es)), ' & ', num2str(AllMovementSpinesOnEarlySession(ms)), ' have high noise correlation!'])
                            end
                            DistanceMatchedNonMRPartners = find(AllDendriteDistances{f}(ElimSpines{f}(es),:)<=clusterdistance);
                            DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(union(AllMovementSpinesOnLateSession, AllMovementSpinesOnEarlySession), ElimSpines{f}));
                            switch AnalysisType
                                case 'Subtract'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(earlysession), '}.DendSubSynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                                case 'Exclude'
                                    eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(earlysession), '}.SynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                            end
                            success_centric_distmatched_activity = DistanceMatchedActivity'.*(repmat(successtraceEarly,1,length(DistanceMatchedNonMRPartners)));
                            success_centric_distmatched_correlation = corrcoef([ElimSpineActivityAligned', success_centric_distmatched_activity]);
                            SuccessCentricDistMatchedtoAntiClustCorrelation(1,closecount) = nanmedian(success_centric_distmatched_correlation(1,2:end));
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            switch FocusOn
                                case 'Rewarded'
                                    boundstouse = boundSEarly;
                                    allperiodblocks = allperiodsSEarly;
                                    targetperiods = successperiodsEarly;
                                case 'All'
                                    boundstouse = boundMEarly;
                                    allperiodblocks = allperiodsMEarly;
                                    targetperiods = moveperiodsEarly;
                            end
                            lever_separated = mat2cell(levertraceEarly, diff(boundstouse));   %%% Even if you want successful presses, you want to start with the actual lever force trace (i.e. NOT the binarized trace) so as to characterize movement stereotypy
                            frames = 1:length(levertraceEarly);
                            frames_separated = mat2cell(frames', diff(boundstouse));
                            coactive_separated = mat2cell(coactivetrace', diff(boundstouse));
                            coactive_trace_during_allperiods = coactive_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            lever_trace_during_allperiods = lever_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            frames_during_allperiods = frames_separated(cell2mat(cellfun(@any, allperiodblocks, 'uni', false)));
                            CoActiveDuringMovement_Addresses = find(cell2mat(cellfun(@(x,y) any(x)&any(y), targetperiods, coactive_trace_during_allperiods, 'uni', false)));
                            TargetMovementswithCoactivity = lever_trace_during_allperiods(CoActiveDuringMovement_Addresses);
                            framesofinterest = frames_during_allperiods(CoActiveDuringMovement_Addresses);
                            if ~isempty(framesofinterest)
                                MovementswithAntiClusterCoActivity = ExtractMovementswithKnownBounds(levertraceEarly, framesofinterest, rewardperiodsEarly, secondspostmovementstart,ImagingFrequency);
                                MovementTracesOccurringwithAntiClusterCoActivity = [MovementTracesOccurringwithAntiClusterCoActivity, MovementswithAntiClusterCoActivity];
                                IsCoActiveAntiClusterMovementRewarded = [IsCoActiveAntiClusterMovementRewarded; cell2mat(cellfun(@(x) any(successtraceEarly(x)), framesofinterest, 'uni', false))];
                                for shf = 1:100 %%% Find the chance level of cluster co-activity occurring during a rewarded movement
                                    SimRew = shake(IsMovementRewardedEarly{f});
                                    chance(shf) = sum(SimRew(CoActiveDuringMovement_Addresses))/length(CoActiveDuringMovement_Addresses);
                                end
                                ChanceReward(closecount) = nanmean(chance);
                                if size(MovementswithAntiClusterCoActivity,2)>1
                                    movementcorr = corrcoef([MovementswithAntiClusterCoActivity, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    CoActiveAntiClustMovementCorr(closecount) = nanmedian(thissessionmovementcorr(:));
                                    CoActiveAntiClustMovementCorrwithModelMovement(closecount) = nanmedian(movementcorr(end,:));
                                else
                                    CoActiveAntiClustMovementCorr(closecount) = NaN;
                                    CoActiveAntiClustMovementCorrwithModelMovement(closecount) = NaN;
                                end
                            else
                                CoActiveAntiClustMovementCorr(closecount) = NaN;
                                CoActiveAntiClustMovementCorrwithModelMovement(closecount) = NaN;
                            end
                            framesofinterest = frames_during_allperiods(setdiff(1:length(frames_during_allperiods),CoActiveDuringMovement_Addresses));
                            [SuccessfulPresseswithoutCoactivity] = ExtractMovementswithKnownBounds(levertraceEarly, framesofinterest, rewardperiodsEarly,secondspostmovementstart,ImagingFrequency);
                            movementcorr = corrcoef([SuccessfulPresseswithoutCoactivity, ModelMovement']);
                            movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                            thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                            OtherMovementCorrElimVersion(closecount) = nanmedian(thissessionmovementcorr(:));
                            OtherCorrwithModelMovementElimVersion(closecount) = nanmedian(movementcorr(end,:));
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%% Find the same features for freq-matched
                            %%% spine pairs
                            comp_coactive_separated = mat2cell(comp_coactivetrace', diff(boundSEarly));    %%% Separate the coactive trace according to the bounds of the successful/rewarded lever press trace
                            comp_coactive_trace_during_success = comp_coactive_separated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsSEarly, 'uni', false))); %%% First, find the cases when the lever is actually being pressed (where 'allperiodsS' is nonzero), and extract the activity traces DURING THESE PERIODS
                            comp_CoActiveAddresses = logical(cell2mat(cellfun(@(x,y) ~isempty(find(x,1))&~isempty(find(y,1)), successperiodsEarly, comp_coactive_trace_during_success, 'uni', false)));
                            framesofinterest = frames_during_allperiods(comp_CoActiveAddresses);
                            if ~isempty(framesofinterest)
                                MovementswithCompCoActivity = ExtractMovementswithKnownBounds(levertraceEarly, framesofinterest, rewardperiodsEarly,secondspostmovementstart,ImagingFrequency);
                                if size(MovementswithCompCoActivity,2)>1
                                    movementcorr = corrcoef([MovementswithCompCoActivity, ModelMovement']);
                                    movementcorr(1:1+size(movementcorr,1):numel(movementcorr)) = nan;
                                    thissessionmovementcorr = movementcorr(1:end-1, 1:end-1);
                                    Comp_CoActiveAntiClusterMovementCorr(closecount) = nanmedian(thissessionmovementcorr(:));
                                    Comp_CoActiveAntiClusterMovementCorrwithModelMovement(closecount) = nanmedian(movementcorr(end,:));
                                else
                                    Comp_CoActiveAntiClusterMovementCorr(closecount) = NaN;
                                    Comp_CoActiveAntiClusterMovementCorrwithModelMovement(closecount) = NaN;
                                end
                            else
                                Comp_CoActiveAntiClusterMovementCorr(closecount) = NaN;
                                Comp_CoActiveAntiClusterMovementCorrwithModelMovement(closecount) = NaN;
                            end
                            %%%%%%%%%%%
                            closecount = closecount+1;
                        end
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines{f}(es),ShuffledEarlyMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        ElimSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    [DistancesBetweenElimSpinesandEarlyMovementSpines{f}(es), ind] = nanmin(ElimSpinestoEarlyMovementSpines);
                    CorrelationsofElimSpinesandEarlyMovementSpines{f}(es) = CorrElimSpinestoEarlyMovementSpines(ind);
                    ElimSpinesCorrwithNearbyMRSs{f}(es) = max(ElimSpinesCorrwithCloseMRS);
                    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines{f}(es) = nanmean(ElimSpinestoShuffledEarlyMovementSpines);
                    SuccessCentricAntiClusterCorrelation{f}{es} = success_centric_anticluster_correlation;
                    SuccessCentricDistanceMatchedtoAntiClustCorrelation{f}{es} = SuccessCentricDistMatchedtoAntiClustCorrelation;

                    MovementCorrelationwithCoActiveAntiClusters{f}{es} = CoActiveAntiClustMovementCorr;
                    CoActiveAntiClusterMovementsCorrelationwithModelMovement{f}{es} = CoActiveAntiClustMovementCorrwithModelMovement;
                    MovementCorrelationofAllOtherMovementsElimVersion{f}{es} = OtherMovementCorrElimVersion;
                    AllOtherMovementsCorrelationwithModelMovementElimVersion{f}{es} = OtherCorrwithModelMovementElimVersion;
                    MovementCorrelationofFrequencyMatchedPairsElimVersion{f}{es} = Comp_CoActiveAntiClusterMovementCorr;
                    FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion{f}{es} = Comp_CoActiveAntiClusterMovementCorrwithModelMovement;
                    ChanceRewardedLevelElimVersion{f}{es} = ChanceReward;
                end
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
        case 'Exclude'
            ClusteredMoveSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            ClusteredNewSpineFrequency = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(x), ClusteredNewSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithClusters = cellfun(@(x,y) y(:).CalciumData{end}.Frequency(setdiff(1:y(:).CalciumData{end}.NumberofSpines,x)), ClusteredEarlyMoveSpines(fields_with_clusters), FieldData(fields_with_clusters), 'uni', false);
            OtherSpineFrequencyOnDendswithoutClusters = cellfun(@(x) x(:).CalciumData{end}.Frequency,FieldData, 'uni', false);
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Set Final Structure and Save 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    a.SpineDynamics = FieldChanges;
    a.DendriteDynamics = DendriteDynamics;
    a.AllDendriteDistances = AllDendriteDistances;
    a.AllMovementSpines = AllMovementSpines;
    
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
    a.ElimSpines = ElimSpines; a.ElimSpinesbyDendrite = ElimSpinesbyDendrite; 
    a.NumberofNewSpines = NumberofNewSpines;
    a.MiddleSessionNewSpines = MiddleSessionNewSpines;
    a.LateSessionNewSpines = LateSessionNewSpines;
    a.PersistentNewSpines = persistentNewSpines;
    a.ClusteredNewSpines = cellfun(@unique, ClusteredNewSpines, 'uni', false); a.ClusteredNewSpinesbyDendrite = ClusteredNewSpinesbyDendrite;
    a.ClusteredEarlyMoveSpines = cellfun(@unique, ClusteredEarlyMoveSpines, 'uni', false);
    a.AntiClusteredMoveSpines = cellfun(@unique, AntiClusteredEarlyMoveSpines, 'uni', false);
    a.AnitClusteredElimSpines = cellfun(@unique, AntiClusteredElimSpines, 'uni', false); a.AntiClusteredElimSpinesbyDendrite = AntiClusteredElimSpinesbyDendrite;
    
    a.NumberofElimSpines = NumberofElimSpines;
    a.NewSpineswithNoMoveSpinePartner = NewSpineswithNoMoveSpinePartner;
    a.NumberofClusteredMoveSpines = NumberofClusteredMoveSpines;
    a.NumberofMovementClusteredNewSpines = NumberofMovementClusteredNewSpines;
    a.NumberofMovementClusteredNewSpinesThatAreMR = NumberofMovementClusteredNewSpinesThatAreMR;
    a.FractionofNewMovementSpinesThatAreClustered = FractionofNewMovementSpinesThatAreClustered;
    a.FractionofPersistentMovementRelatedSpinesClustered = FractionofPersistentMovementRelatedSpinesClustered;
    a.NumberofEarlyMovementRelatedSpines = NumberofEarlyMovementRelatedSpines;
    a.NumberofLateMovementRelatedSpines = NumberofLateMovementRelatedSpines;
    a.NumberofPersistentMovementRelatedSpines = NumberofPersistentMovementRelatedSpines;
    a.NumberofPersistentMovementSpinesClustered = NumberofPersistentMovementSpinesClustered;
    a.FractionofMovementRelatedSpinesMaintained = FractionofMovementRelatedSpinesMaintained;
    a.FractionofMovementRelatedSpinesEliminated = FractionofMovementRelatedSpinesEliminated;
    a.NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR;
    a.NumberofNewSpinesThatArePreSR = NumberofNewSpinesThatArePreSR;
    a.NumberofNewSpinesThatAreSR = NumberofNewSpinesThatAreSR;
    a.NumberofNewSpinesThatAreRR = NumberofNewSpinesThatAreRR;
    a.NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR;
    a.NewSpineAllSpinesDistance = NewSpineAllSpinesDistance;
    a.NewSpineAllSpinesLateCorr = NewSpineAllSpinesLateCorr;
    a.DistancesBetweenNewSpinesandEarlyMovementSpines = DistancesBetweenNewSpinesandEarlyMovementSpines;
    a.LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions = LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions;
    a.NewSpinesCorrwithDistanceMatchedNonEarlyMRSs = NewSpinesCorrwithDistanceMatchedNonEarlyMRSs;
    a.NewSpinesCorrwithDistanceMatchedNonLateMRSs= NewSpinesCorrwithDistanceMatchedNonLateMRSs;
    a.DistancesBetweenNewSpinesandMovementSpines = DistancesBetweenNewSpinesandLateMovementSpines;
    a.LateCorrfNewSpinesandNearestMovementSpinefromLateSessions = LateCorrfNewSpinesandNearestMovementSpinefromLateSessions;
    a.NewSpinesCorrwithNearbyEarlyMRSs = NewSpinesCorrwithNearbyEarlyMRSs;
    a.MovementSpineDistanceMatchedControlCorrelation = MovementSpineDistanceMatchedControlCorrelation;
    a.CombinedClusterActivityCorrwithMovement = CombinedClusterActivityCorrwithMovement;
    a.CombinedClusterActivityCorrwithSuccess = CombinedClusterActivityCorrwithSuccess;
    a.ClusterMovementReliability = ClusterMovementReliability;
    a.ClusterSuccessReliability = ClusterSuccessReliability;
    a.ControlPairMovementReliability = ControlPairMovementReliability;
    a.ControlPairSuccessReliability = ControlPairSuccessReliability;
    a.SuccessCentricClusterCorrelation = SuccessCentricClusterCorrelation;
    a.SuccessCentricDistanceMatchedCorrelation = SuccessCentricDistanceMatchedCorrelation;
    a.SuccessCentricDistanceMatchedCorrelationforMRS = SuccessCentricDistanceMatchedCorrelationforMRS;
    a.SuccessCentricCorrelationofAllOtherSpines = SuccessCentricCorrelationofAllOtherSpines;
    a.FailureCentricClusterCorrelation = FailureCentricClusterCorrelation;
    a.SuccessCentricAntiClusterCorrelation = SuccessCentricAntiClusterCorrelation;
    a.SuccessCentricDistanceMatchedtoAntiClustCorrelation = SuccessCentricDistanceMatchedtoAntiClustCorrelation;
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
                    a.ChanceRewardedLevelElimVersion = ChanceRewardedLevelElimVersion;

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
    a.SuccessCentricHCPClusterCorrelation = SuccessCentricHCPClusterCorrelation;
    a.MovementCorrelationwithCoActiveHCPClusters = MovementCorrelationwithCoActiveHCPClusters;
    a.MovementCorrelationofAllOtherNonHCPMovements = MovementCorrelationofAllOtherNonHCPMovements;
    a.MovementCorrelationofHCPComparatorSpines = MovementCorrelationofHCPComparatorSpines;

    
    a.SessionsbyField = SessionsbyField;
    a.SpineDendriteGrouping = SpineDendriteGrouping;
    
    a.IsMovementRewardedEarly = IsMovementRewardedEarly;
    a.IsMovementRewardedLate = IsMovementRewardedLate;
    a.ChanceRewardedLevel = ChanceRewardedLevel;
    a.MovementTracesOccurringwithClusterCoActivity = MovementTracesOccurringwithClusterCoActivity;
    a.MovementTracesOccurringwithAntiClusterCoActivity = MovementTracesOccurringwithAntiClusterCoActivity;
    a.IsCoActiveMovementRewarded = IsCoActiveMovementRewarded;
    a.IsCoActiveAntiClusterMovementRewarded = IsCoActiveAntiClusterMovementRewarded;
    a.MovementCorrelationwithCoActiveClusters = MovementCorrelationwithCoActiveClusters;
    a.CoActiveClusterMovementsCorrelationwithModelMovement = CoActiveClusterMovementsCorrelationwithModelMovement;
    a.MovementCorrelationofAllOtherMovements = MovementCorrelationofAllOtherMovements;
    a.AllOtherMovementsCorrelationwithModelMovement = AllOtherMovementsCorrelationwithModelMovement;
    a.MovementCorrelationofFrequencyMatchedPairs = MovementCorrelationofFrequencyMatchedPairs;
    a.FrequencyMatchedPairMovementsCorrelationwithModelMovement = FrequencyMatchedPairMovementsCorrelationwithModelMovement;
    
    a.ClusteredMoveSpineFrequency = ClusteredMoveSpineFrequency;
    a.ClusteredNewSpineFrequency = ClusteredNewSpineFrequency;
    a.OtherSpineFrequencyOnDendswithClusters = OtherSpineFrequencyOnDendswithClusters;
    a.OtherSpineFrequencyOnDendswithoutClusters = OtherSpineFrequencyOnDendswithoutClusters;
    
    a.DendsWithBothDynamics = DendsWithBothDynamics;
    a.DendsWithBothClustDynamics = DendsWithBothClustDynamics;

    eval([experimentnames, '_SpineDynamicsSummary = a'])
    fname = [experimentnames, '_SpineDynamicsSummary'];
    save(fname, fname)

    disp(['Analysis of ', experimentnames, ' complete'])
    clearvars -except varargin sensor
end