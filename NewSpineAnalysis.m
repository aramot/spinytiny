function NewSpineAnalysis(varargin)

for animal = 1:length(varargin)
    experimentnames = varargin{animal}; 
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

    %%%%%%%%%%%% Load calcium imaging data for the animal

    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd('E:\ActivitySummary')
    end

    activitydata = fastdir(cd, [experimentnames, '.+_Summary']);

    for f = 1:length(activitydata)
        load(activitydata{f})
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%% Match the loaded data with the session numbers from the spine
    %%%%%%%%%%%% registry data
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
    %%%%%%%%%%%% Load Statistical classification data
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
    %%%%%%%%%%%% Load Correlation data
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%  Determine data type to use
    global gui_KomiyamaLabHub
    
    if get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'Value')
        AnalysisType = 'Exclude';
    elseif get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'Value')
        AnalysisType = 'Subtract';
    else
        AnalysisType = 'Exclude';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%
    %% New spine analysis section
    %%%%%%%%%%%%
    
    %%% Initiatilize variables to be used
    FractionofMovementRelatedSpinesMaintained = cell(1,NumFields);
    FractionofMovementRelatedSpinesEliminated = cell(1,NumFields);
    NumberofNewSpines = 0;
    NumberofElimSpines = 0;
    NumberofNewSpinesThatAreMR = 0;                     %%% Movement-related
    NumberofNewSpinesThatArePreSR = 0;                  %%% Pre-success-related
    NumberofNewSpinesThatAreSR = 0;                     %%% Successful-press-related
    NumberofNewSpinesThatAreRR = 0;                     %%% Reward-related
    NumberofElimSpinesThatWereMR = 0;
    NumberofMovementClusteredNewSpines = 0;             %%% New spines that form near movement-related spines
    NumberofMovementClusteredNewSpinesThatAreMR = 0;    %%% New spines that form near movement-related spines AND are themselves movement-related
    NewSpinesMaxCorr = cell(1,NumFields);
    DistanceToMaxCorrPartner = cell(1,NumFields);
    FractionofHCPsThatAreMR = cell(1,NumFields);
    ElimSpinesMaxCorr = cell(1,NumFields);
    TaskCorrelationofNearbyEarlyMRSs = cell(1,NumFields);
    TaskCorrelationofNearbyLateMRSs = cell(1,NumFields);
    TaskCorrelationofNearbyEarlyMRSsforElimSp = cell(1,NumFields);
    MovementReliabilityofNearbyEarlyMRSs = cell(1,NumFields);
    MovementReliabilityofNearbyLateMRSs = cell(1,NumFields);
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
    ClusteredNewSpineCorrwithDendrite = cell(1,NumFields);
    ClusteredNewSpineCorrwithMovement = cell(1,NumFields);
    ClusteredNewSpineCorrwithSuccess = cell(1,NumFields);
    ClusteredMoveSpineCorrwithDendrite = cell(1,NumFields);
    ClusteredMoveSpineCorrwithMovement = cell(1,NumFields);
    ClusteredMoveSpineCorrwithSuccess = cell(1,NumFields);
    CoActiveClusterCorrwithDendrite = cell(1,NumFields);
    CoActiveClusterCorrwithMovement = cell(1,NumFields);
    CoActiveClusterCorrwithSuccess = cell(1,NumFields);
    SuccessCentricDistanceMatchedCorrelation = cell(1,NumFields);
    SuccessCentricClusterCorrelation = cell(1,NumFields);
    CombinedClusterActivityCorrwithMovement = cell(1,NumFields);
    CombinedClusterActivityCorrwithSuccess = cell(1,NumFields);
    ClusterMovementReliability = cell(1,NumFields);
    ClusterSuccessReliability = cell(1,NumFields);
    SessionsbyField = cell(1,NumFields);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%
    for f = 1:NumFields
        %%%%%%%%%%%%% 
        %%% When chosing data to use (i.e. dend subtracted vs. excluded),
        %%% you must change everything that mentions STATCLASS,
        %%% CORRELATIONS, as well as raw activity
        SessionsbyField{f} = cell2mat(cellfun(@(x) x(:).Session, FieldData{f}.CalciumData, 'uni', false));
        latesession = FieldData{f}.CalciumData{end}.Session;
        %%%%%%%%%%%%%%%%
        eval(['levertrace = ', currentanimal, '_Aligned{',num2str(latesession),'}.Binarized_Lever;']);
        eval(['successtrace = ', currentanimal, '_Aligned{', num2str(latesession), '}.SuccessulPresses;']);
        %%%%%%%%%%%%%%%%
        boundM = find(diff([Inf; levertrace; Inf])~=0);
        allperiodsM = mat2cell(levertrace, diff(boundM));
        moveperiods = allperiodsM(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsM, 'uni', false)));
        boundS = find(diff([Inf; successtrace; Inf])~=0);
        allperiodsS = mat2cell(successtrace, diff(boundS));
        successperiods = allperiodsS(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsS, 'uni', false)));
        %%%%%%%%%%%%%
        Spine1_Address = 10;
        NumberofEarlySpines = FieldData{f}.CalciumData{1}.NumberofSpines;
        NumberofLateSpines = FieldData{f}.CalciumData{end}.NumberofSpines;
        switch AnalysisType
            case 'Exclude'
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
                FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(FieldData{f}.StatClass{end}.DendSub_MovementSpines))/sum(FieldData{1}.StatClass{1}.DendSub_MovementSpines);
                FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.DendSub_MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
                AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.DendSub_MovementSpines);
                AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.DendSub_MovementSpines);
                AllMovementSpines{f} = cell2mat(cellfun(@(x) x.DendSub_MovementSpines, FieldData{f}.StatClass, 'uni', false));
                AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
                AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
                AllLateSpineCorrelations = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
                AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
                behaviorcorrdataearly = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
                behaviorcorrdatalate = FieldData{f}.Correlations{end}.DendSubtractedSpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AllDendriteDistances{f} = FieldData{f}.CalciumData{end}.DistanceHeatMap;
        flipped = FieldData{f}.CalciumData{end}.DistanceHeatMap';
        AllDendriteDistances{f}(isnan(AllDendriteDistances{f})&~isnan(flipped)) = flipped(isnan(AllDendriteDistances{f})&~isnan(flipped));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        shuffnum = 1000;
        ShuffledEarlyMovementLabels = cell(1,shuffnum);
        ShuffledLateMovementLabels = cell(1,shuffnum);
        clusterdistance = 10;
        for shuff = 1:shuffnum
            ShuffledEarlyMovementLabels{shuff} = randi(NumberofEarlySpines,[length(AllMovementSpinesOnEarlySession),1]);
            ShuffledLateMovementLabels{shuff} = randi(NumberofLateSpines,[length(AllMovementSpinesOnLateSession),1]);
            if length(ShuffledEarlyMovementLabels{shuff})>length(AllMovementSpinesOnEarlySession)/2
                replimit = 1;
                while any(ismember(ShuffledEarlyMovementLabels{shuff}, AllMovementSpinesOnEarlySession))>length(AllMovementSpinesOnLateSession)/2 && replimit<1000
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
        if size(FieldChanges{f},2) >1
            NewSpines{f} = find(sum(FieldChanges{f},2)>0);
        else
            NewSpines{f} = find(FieldChanges{f}>0);
        end
        NumberofNewSpines = NumberofNewSpines+length(NewSpines{f});
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(NewSpines{f})    %%% If there are new spines, find out whether they are close to a nearby movement spine, have a highly correlated partner, etc.
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
            %% Compare new spines to EARLY session features
            if ~isempty(AllMovementSpinesOnEarlySession)
                for ns = 1:length(NewSpines{f})
                    switch AnalysisType
                        case 'Subtract'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                        case 'Exclude'
                            NewSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized(NewSpines{f}(ns),:);
                            eval(['NewSpineActivityAligned = ', currentanimal, '_Aligned{', num2str(latesession),'}.SynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:).*', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized(', num2str(NewSpines{f}(ns)), ',:);'])
                    end
                    NewSpinestoEarlyMovementSpines = NaN;
                    NewSpinesEarlyMovementSpinesLateCorr = NaN;
                    NewSpinesCorrwithCloseEarlyMRS = NaN;
                    NearbyMRSlist = [];
                    DistMatchedNonEarlyMRPartnersCorr = NaN;
                    NewSpinestoShuffledEarlyMovementSpines = NaN;
                    DendCorrNewSpineOnly = NaN;
                    DendCorrMoveSpineOnly = NaN;
                    DendCorrCoactiveCluster = NaN;
                    MoveSpineOnlywithMovement = NaN; MoveSpineOnlywithSuccess = NaN;
                    NewSpineOnlywithMovement = NaN; NewSpineOnlywithSuccess = NaN;
                    CoactiveClusterwithMovement = NaN; CoactiveClusterwithSuccess = NaN;
                    success_centric_cluster_correlation = NaN; SuccessCentricDistMatchedCorrelation = NaN;
                    combined_activity_move_corr = NaN;combined_activity_success_corr = NaN;
                    clustermovementreliability = NaN; clustersuccessreliability = NaN;
                    count = 1;
                    closecount = 1;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%% Vouch to use only MR dends
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines{f}(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
%                     if ~ismember(ParentDend, find(FieldData{f}.StatClass{end}.MovementDends))
%                         continue
%                     end           
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for ms = 1:length(AllMovementSpinesOnEarlySession)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%% Choose to filter for persistent movement
                        %%%% related spines!
                        if ~ismember(AllMovementSpinesOnEarlySession(ms), AllMovementSpinesOnLateSession)
                            continue
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        switch AnalysisType
                            case 'Subtract'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                            case 'Exclude'
                                eval(['MoveSpineActivityAligned = ', currentanimal, '_Aligned{',num2str(latesession),'}.SynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:).*', currentanimal, '_Aligned{',num2str(latesession),'}.DendSubSynapseOnlyBinarized(', num2str(AllMovementSpinesOnEarlySession(ms)), ',:);'])
                        end
                        bothactivity = logical(NewSpineActivityAligned+MoveSpineActivityAligned);
                        %%%
                        [val, ~] = sort([NewSpines{f}(ns), AllMovementSpinesOnEarlySession(ms)]);
                        NewSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        NewSpinesEarlyMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));   %%% Find the correlation of new spines with the movement spines from early sessions (they might not be movement-related at the late sessions, but are they highly correlated with the new spine?)                        
                        if NewSpinestoEarlyMovementSpines(1,count)<clusterdistance
                            NewSpinesCorrwithCloseEarlyMRS(1,closecount) = NewSpinesEarlyMovementSpinesLateCorr(1,count);
                            NearbyMRSlist = [NearbyMRSlist,AllMovementSpinesOnEarlySession(ms)];
                            %%% Compare Activity of Clustered (both new and
                            %%% MRS) Spines with Dendrite
                            MoveSpineActivity = FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(AllMovementSpinesOnEarlySession(ms),:);
                            CoActiveCluster =  logical(FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(NewSpines{f}(ns),:) & FieldData{f}.CalciumData{end}.SynapseOnlyBinarized_DendriteSubtracted(AllMovementSpinesOnEarlySession(ms), :));
                            DendAct = FieldData{f}.CalciumData{end}.Dendrite_Binarized(ParentDend,:);
                            temp = corrcoef([NewSpineActivity', DendAct']);
                            DendCorrNewSpineOnly(1,closecount) = temp(1,2);
                            temp = corrcoef([MoveSpineActivity', DendAct']);
                            DendCorrMoveSpineOnly(1,closecount) = temp(1,2);
                            temp = corrcoef([CoActiveCluster', DendAct']);
                            DendCorrCoactiveCluster(1,closecount) = temp(1,2);
                            %%% Compare coactive clusters with movement
                            %%%% Make sure to use activity traces
                            %%%% consistent with the rest of the data being
                            %%%% used!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            coactivetrace = MoveSpineActivityAligned.*NewSpineActivityAligned;
                            moveonly = corrcoef([levertrace, MoveSpineActivityAligned']);
                            newonly = corrcoef([levertrace, NewSpineActivityAligned']);
                            coactive = corrcoef([levertrace, coactivetrace']);
                            MoveSpineOnlywithMovement(1,closecount) = moveonly(1,2);
                            NewSpineOnlywithMovement(1,closecount) = newonly(1,2);
                            CoactiveClusterwithMovement(1,closecount) = coactive(1,2);
                            %%%
                            moveonly = corrcoef([successtrace, MoveSpineActivityAligned']);
                            newonly = corrcoef([successtrace, NewSpineActivityAligned']);
                            coactive = corrcoef([successtrace, coactivetrace']);
                            MoveSpineOnlywithSuccess(1,closecount) = moveonly(1,2);
                            NewSpineOnlywithSuccess(1,closecount) = newonly(1,2);
                            CoactiveClusterwithSuccess(1,closecount) = coactive(1,2);
                            %%%
                            success_centric_newspineactivity = NewSpineActivityAligned'.*successtrace;
                            success_centric_movespineactivity = MoveSpineActivityAligned'.*successtrace;
                            success_centric_correlations = corrcoef([success_centric_newspineactivity, success_centric_movespineactivity]);
                            success_centric_cluster_correlation(1,closecount) = success_centric_correlations(1,2);
                            %%%
                            combinedcorr = corrcoef([levertrace, bothactivity']);
                            combined_activity_move_corr(1,closecount) = combinedcorr(1,2);
                            combinedcorr = corrcoef([successtrace,bothactivity']);
                            combined_activity_success_corr(1,closecount) = combinedcorr(1,2);
                            bothspineactivity_Moveseparated = mat2cell(bothactivity', diff(boundM));
                            bothspineactivity_Succseparated = mat2cell(bothactivity', diff(boundS));
                            bothspineactivity_moveperiods = bothspineactivity_Moveseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsM, 'uni', false)));
                            numberofmovementswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), moveperiods, bothspineactivity_moveperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
                            clustermovementreliability(1,closecount) = numberofmovementswithclusteractivity/length(moveperiods);
                            bothspineactivity_successperiods = bothspineactivity_Succseparated(cell2mat(cellfun(@(x) ~isempty(find(x,1)), allperiodsS, 'uni', false)));
                            numberofsuccesseswithclusteractivity = length(find(logical(cell2mat(cellfun(@(x,y) sum((x+y)>1), successperiods, bothspineactivity_successperiods, 'uni', false)))));   %%% Find the number of movements during which there is also activity for this spine
                            clustersuccessreliability(1,closecount) = numberofsuccesseswithclusteractivity/length(successperiods);
                            closecount = closecount+1;
                        end
                        count = count+1;
                    end
                    DistanceMatchedNonMRPartners = find(AllDendriteDistances{f}(NewSpines{f}(ns),:)<clusterdistance);
                    DistanceMatchedNonMRPartners = setdiff(DistanceMatchedNonMRPartners, union(AllMovementSpinesOnLateSession, AllMovementSpinesOnEarlySession));
                    DistMatchedNonEarlyMRPartnersCorr(1,count) = nanmedian(AllLateSpineCorrelations(NewSpines{f}(ns), DistanceMatchedNonMRPartners));
                    switch AnalysisType
                        case 'Subtract'
                            eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.DendSubSynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                        case 'Exclude'
                            eval(['DistanceMatchedActivity = ', currentanimal, '_Aligned{', num2str(latesession), '}.SynapseOnlyBinarized([', num2str(DistanceMatchedNonMRPartners), '],:);'])
                    end
                    success_centric_distmatched_activity = DistanceMatchedActivity'.*(repmat(successtrace,1,length(DistanceMatchedNonMRPartners)));
                    success_centric_distmatched_correlation = corrcoef([NewSpineActivityAligned', success_centric_distmatched_activity]);
                    SuccessCentricDistMatchedCorrelation(1,ns) = nanmedian(success_centric_distmatched_correlation(1,2:end));
                    %%%
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([NewSpines{f}(ns),ShuffledEarlyMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        NewSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
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
                    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{f}(ns) = nanmean(DistMatchedNonEarlyMRPartnersCorr);
                    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{f}(ns) = nanmean(NewSpinestoShuffledEarlyMovementSpines);
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
                    SuccessCentricDistanceMatchedCorrelation{f}{ns} = SuccessCentricDistMatchedCorrelation;
                    %%%
                    CombinedClusterActivityCorrwithMovement{f}{ns} = combined_activity_move_corr;
                    CombinedClusterActivityCorrwithSuccess{f}{ns} = combined_activity_success_corr;
                    ClusterMovementReliability{f}{ns} = clustermovementreliability;
                    ClusterSuccessReliability{f}{ns} = clustersuccessreliability;
                end
            else
                NearbyMRSlist = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TaskCorrelationofNearbyEarlyMRSs{f} = behaviorcorrdataearly(:,NearbyMRSlist);
            MovementReliabilityofNearbyEarlyMRSs{f} = FieldData{f}.StatClass{1}.AllSpineReliability(NearbyMRSlist);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Compare new spines to LATE session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentNew)
                lateMRStouse = AllMovementSpinesOnLateSession;
%                 lateMRStouse = OtherMovementSpinesThatArentNew;
                for ns = 1:length(NewSpines{f})
                    NewSpinestoLateMovementSpines = [];
                    NewSpinesLateMovementSpinesLateCorr = [];
                    NewSpinesCorrwithCloseMRS = nan;
                    NearbyMRSlist = [];
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
                            NearbyMRSlist = [NearbyMRSlist,lateMRStouse(os)];
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
                NearbyMRSlist = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TaskCorrelationofNearbyLateMRSs{f} = behaviorcorrdatalate(:,NearbyMRSlist);
            MovementReliabilityofNearbyLateMRSs{f} = FieldData{f}.StatClass{end}.AllSpineReliability(NearbyMRSlist);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%
            [NewSpinesMaxCorr{f}, NewSpineMaxInd] = nanmax(AllLateSpineCorrelations(NewSpines{f},:),[],2); %%% Find the spine that has the highest correlation with each new spine
            allotherspines = setdiff(1:NumberofLateSpines,union(NewSpineMaxInd, NewSpines{f})); %%% For comparison, find the spine that has the maximum correlation value with every other spine ("every other" can exclude either just new spines or new spines AND their highly correlated partners)
            DistanceToMaxCorrPartner{f} = AllDendriteDistances{f}(NewSpineMaxInd);
            FractionofHCPsThatAreMR{f} = sum(ismember(NewSpineMaxInd,AllMovementSpinesOnLateSession))/length(NewSpineMaxInd);
            OtherSpinesMaxCorr{f} = max(AllLateSpineCorrelations(allotherspines,:),[],2);
            NewSpineMaxCorrPartnerEarlyMoveCorrelation{f} = behaviorcorrdataearly(:,NewSpineMaxInd);
            NewSpineMaxCorrPartnerLateMoveCorrelation{f} = behaviorcorrdatalate(:,NewSpineMaxInd);
            NewSpineMaxCorrPartnerEarlyMoveReliability{f} = FieldData{f}.StatClass{1}.AllSpineReliability(NewSpineMaxInd);
            NewSpineMaxCorrPartnerLateMoveReliability{f} = FieldData{f}.StatClass{end}.AllSpineReliability(NewSpineMaxInd);
            %%%%%%
            for ns = 1:length(NewSpines{f})
                NewSpinesBehaviorCorrelation{f}(ns,1:9) = behaviorcorrdatalate(:,ns);
            end
            NonNewSpinesBehaviorCorrelationEarly{f} = behaviorcorrdataearly(:,setdiff(1:NumberofEarlySpines,union(NewSpines{f}, AllMovementSpinesOnEarlySession)));
            NonNewSpinesBehaviorCorrelationLate{f} = behaviorcorrdatalate(:,setdiff(1:NumberofLateSpines,union(NewSpines{f}, AllMovementSpinesOnLateSession)));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(FieldChanges{f},2)>1
            ElimSpines = find(sum(FieldChanges{f},2)<0);
        else
            ElimSpines = find(FieldChanges{f}<0);
        end
        NumberofElimSpines = NumberofElimSpines+length(ElimSpines);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(ElimSpines)    %%% If there are new spines, find out whether they are close to a nearby movement spine
            ElimSpinesThatWereMR = ElimSpines(ismember(ElimSpines, find(FieldData{f}.StatClass{1}.DendSub_MovementSpines)));
            NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR+sum(FieldData{f}.StatClass{1}.DendSub_MovementSpines(ElimSpines));
            OtherMovementSpinesThatArentElim = setdiff(AllMovementSpinesOnLateSession,ElimSpines);
            %%% Compare eliminated spines to early session features
            if ~isempty(AllMovementSpinesOnEarlySession)
                for es = 1:length(ElimSpines)
                    ElimSpinestoEarlyMovementSpines = [];
                    ElimSpinestoShuffledEarlyMovementSpines = [];
                    ElimSpinesCorrwithCloseMRS = nan;
                    NearbyMRSlist = [];
                    count = 1;
                    closecount = 1;
                    for ms = 1:length(AllMovementSpinesOnEarlySession) 
                        [val, ~] = sort([ElimSpines(es), AllMovementSpinesOnEarlySession(ms)]);
                        ElimSpinestoEarlyMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        CorrElimSpinestoEarlyMovementSpines(1,count) = AllEarlySpineCorrelations(val(1), val(2));
                        if ElimSpinestoEarlyMovementSpines(1,count)<clusterdistance 
                            ElimSpinesCorrwithCloseMRS(1,closecount) = CorrElimSpinestoEarlyMovementSpines(1,count);
                            NearbyMRSlist = [NearbyMRSlist,AllMovementSpinesOnEarlySession(ms)];
                            closecount = closecount+1;
                        end
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines(es),ShuffledEarlyMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = AllDendriteDistances{f}(val(1),val(2));
                        end
                        ElimSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    [DistancesBetweenElimSpinesandEarlyMovementSpines{f}(es), ind] = nanmin(ElimSpinestoEarlyMovementSpines);
                    CorrelationsofElimSpinesandEarlyMovementSpines{f}(es) = CorrElimSpinestoEarlyMovementSpines(ind);
                    ElimSpinesCorrwithNearbyMRSs{f}(es) = max(ElimSpinesCorrwithCloseMRS);
                    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines{f}(es) = nanmean(ElimSpinestoShuffledEarlyMovementSpines);
                end
            else
                NearbyMRSlist = [];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            TaskCorrelationofNearbyEarlyMRSsforElimSp{f} = behaviorcorrdataearly(:,NearbyMRSlist);
            MovementReliabilityofNearbyEarlyMRSsforElimSp{f} = FieldData{f}.StatClass{end}.AllSpineReliability(NearbyMRSlist);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Compare eliminated spines to late session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentElim)
                for ns = 1:length(ElimSpines)
                    ElimSpinestoMovementSpines = [];
                    ElimSpinestoRandomSpines = [];
                    ElimSpinestoShuffledMovementSpines = [];
                    count = 1;
                    for os = 1:length(OtherMovementSpinesThatArentElim)
                        [val, ~] = sort([ElimSpines(ns),OtherMovementSpinesThatArentElim(os)]);
                        ElimSpinestoMovementSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == ElimSpines(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                        randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        while randomspinefromsamedend == ElimSpines(ns)
                            randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        end
                        [val, ~] = sort([ElimSpines(ns),randomspinefromsamedend]);
                        ElimSpinestoRandomSpines(1,count) = AllDendriteDistances{f}(val(1),val(2));
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledLateMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines(ns),ShuffledLateMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) =  AllDendriteDistances{f}(val(1),val(2));
                        end
                        ElimSpinestoShuffledMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    DistancesBetweenElimSpinesandMovementSpines{f}(ns) = nanmin(ElimSpinestoMovementSpines);
                    DistancesBetweenElimSpinesandRandomSpines{f}(ns) = ElimSpinestoRandomSpines(randi(length(ElimSpinestoRandomSpines)));
                    DistancesBetweenElimSpinesandShuffledMovementSpines{f}(ns) = nanmean(ElimSpinestoShuffledMovementSpines);
                end
            end
            %%%%%%
            currentcorrdata = FieldData{f}.Correlations{1}.DendSubtractedSpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1,Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
            currentcorrdata(1:1+size(currentcorrdata,1):end) = nan; %%% set identity values to nan
            [ElimSpinesMaxCorr{f}, ElimSpineMaxInd] = max(currentcorrdata(ElimSpines,:),[],2);
            allotherspines = setdiff(1:NumberofEarlySpines,union(ElimSpineMaxInd, ElimSpines));
            OtherSpinesMaxCorr{f} = max(currentcorrdata(allotherspines,:),[],2);
            ElimSpineMaxCorrPartnerEarlyMoveCorrelation{f} = behaviorcorrdataearly(:,ElimSpineMaxInd);
            ElimSpineMaxCorrPartnerEarlyMoveReliability{f} = FieldData{f}.StatClass{1}.AllSpineReliability(ElimSpineMaxInd);
            for es = 1:length(ElimSpines)
                ElimSpinesBehaviorCorrelation{f}(es,1:9) = behaviorcorrdataearly(:,es);
            end
            NonNewSpinesBehaviorCorrelationEarly{f} = behaviorcorrdataearly(:,setdiff(1:NumberofEarlySpines,ElimSpines));
            %%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    FractionofNewSpinesClustered = NumberofMovementClusteredNewSpinesThatAreMR/NumberofNewSpinesThatAreMR;

    %%%%%%%%%%%%
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

    for f = 1:NumFields
        for d = 1:length(DendriteDynamics{f})
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
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},ElimSpines))
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
    
    a.NewSpines = NewSpines;
    a.NumberofNewSpines = NumberofNewSpines;
    a.NumberofElimSpines = NumberofElimSpines;
    a.NumberofMovementClusteredNewSpines = NumberofMovementClusteredNewSpines;
    a.NumberofMovementClusteredNewSpinesThatAreMR = NumberofMovementClusteredNewSpinesThatAreMR;
    a.FractionofNewSpinesClustered = FractionofNewSpinesClustered;
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
    a.SuccessCentricClusterCorrelation = SuccessCentricClusterCorrelation;
    a.CombinedClusterActivityCorrwithMovement = CombinedClusterActivityCorrwithMovement;
    a.CombinedClusterActivityCorrwithSuccess = CombinedClusterActivityCorrwithSuccess;
    a.ClusterMovementReliability = ClusterMovementReliability;
    a.ClusterSuccessReliability = ClusterSuccessReliability;
    a.SuccessCentricDistanceMatchedCorrelation = SuccessCentricDistanceMatchedCorrelation;
    a.TaskCorrelationofNearbyEarlyMRSs = TaskCorrelationofNearbyEarlyMRSs;
    a.MovementReliabilityofNearbyEarlyMRSs = MovementReliabilityofNearbyEarlyMRSs;
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
    
    a.SessionsbyField = SessionsbyField;

    eval([experimentnames, '_SpineDynamicsSummary = a'])
    fname = [experimentnames, '_SpineDynamicsSummary'];
    save(fname, fname)

    disp(['Analysis of ', experimentnames, ' complete'])
    clearvars -except varargin
end