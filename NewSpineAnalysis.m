function NewSpineAnalysis(varargin)

experimentnames = varargin;

if length(experimentnames) == 1
    experimentnames = varargin{1}; 
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

    NumFields = length(FieldData);

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

    %%%%%%%%%%%% Match the loaded data with the session numbers from the spine
    %%%%%%%%%%%% registry data

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
    end

    for f = 1:length(activitydata)
        clear(activitydata{f})
    end

    %%%%%%%%%%%% Separate the spine dynamics arrays into dendrites

    for f = 1:NumFields
        DendriteDynamics{f} = cellfun(@(x) FieldChanges{f}(x),FieldData{f}.CalciumData{1}.SpineDendriteGrouping,'uni', false);  %%% Calculate the CHANGE in spines (-1 is a lost spine, +1 is a new spine) between sessions for each dendrite
    end

    %%%%%%%%%%%% Load Statistical classification data

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
        for s = 1:length(FieldData{f}.DatesAcquired)
            if ~isempty(FieldData{f}.CalciumData{s})
                FieldData{f}.StatClass{s} = statclass{FieldData{f}.CalciumData{s}.Session};
            else
                FieldData{f}.DatesAcquired = FieldData{f}.DatesAcquired(1:s-1);
            end
        end
    end
    
    
    %%%%%%%%%%%% Load Correlation data
    
    corrdata = fastdir(cd, [experimentnames, '_Correlations']);
    if ~isempty(corrdata)
        load(corrdata{1})
    else
        disp(['Cannot load correlation data for animal ', experimentnames])
    end
    
    eval(['correlations = ', experimentnames, '_Correlations;'])
    
    for f = 1:NumFields
        for s = 1:length(FieldData{f}.DatesAcquired)
            if ~isempty(FieldData{f}.CalciumData{s})
                FieldData{f}.Correlations{s} = correlations{FieldData{f}.CalciumData{s}.Session};
            else
                FieldData{f}.Correlations{s} = [];
            end
        end
    end

    %%%%%%%%%%%%
    %% New spine analysis section
    
    %%% Initiatilize variables to be used
    FractionofMovementRelatedSpinesMaintained = cell(1,NumFields);
    FractionofMovementRelatedSpinesEliminated = cell(1,NumFields);
    NumberofNewSpinesThatAreMR = 0;
    NumberofElimSpinesThatWereMR = 0;
    NumberofNewSpines = 0;
    NumberofElimSpines = 0;
    NewSpinesMaxCorr = cell(1,NumFields);
    ElimSpinesMaxCorr = cell(1,NumFields);
    OtherSpinesMaxCorr = cell(1,NumFields);
    NewSpinesBehaviorCorrelation = cell(1,NumFields);
    ElimSpinesBehaviorCorrelation = cell(1,NumFields);
    OtherSpinesBehaviorCorrelation = cell(1,NumFields);
    AllDendriteDistances = cell(1,NumFields);
    AllMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandEarlyMovementSpines = cell(1,NumFields);
    LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions = cell(1,NumFields);
    LateCorrfNewSpinesandNearestMovementSpinefromLateSessions = cell(1,NumFields);
    DistancesBetweenNewSpinesandLateMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandRandomSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines = cell(1,NumFields);
    DistancesBetweenNewSpinesandShuffledMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandEarlyMovementSpines = cell(1,NumFields);
    CorrelationsofElimSpinesandEarlyMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandRandomSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines = cell(1,NumFields);
    DistancesBetweenElimSpinesandShuffledMovementSpines = cell(1,NumFields);
    
    for f = 1:NumFields
        FractionofMovementRelatedSpinesMaintained{f} = sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.StatClass{end}.MovementSpines))/sum(FieldData{1}.StatClass{1}.MovementSpines);
        FractionofMovementRelatedSpinesEliminated{f} = length(find(FieldChanges{f}(FieldData{f}.StatClass{1}.MovementSpines)<0))/sum(FieldData{f}.StatClass{1}.MovementSpines); %%% How many movement spines from early sessions are eliminated by later sessions? 
        AllMovementSpinesOnEarlySession = find(FieldData{f}.StatClass{1}.MovementSpines);
        AllMovementSpinesOnLateSession = find(FieldData{f}.StatClass{end}.MovementSpines);
        AllMovementSpines{f} = cell2mat(cellfun(@(x) x.MovementSpines, FieldData{f}.StatClass, 'uni', false));
        NumberofEarlySpines = FieldData{f}.CalciumData{1}.NumberofSpines;
        NumberofLateSpines = FieldData{f}.CalciumData{end}.NumberofSpines;
        Spine1_Address = 10;
        AllEarlySpineCorrelations = FieldData{f}.Correlations{1}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1, Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
        AllEarlySpineCorrelations(1:1+size(AllEarlySpineCorrelations,1):end) = nan;   %%% set identity values to nan;
        AllLateSpineCorrelations = FieldData{f}.Correlations{end}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofLateSpines-1, Spine1_Address:Spine1_Address+NumberofLateSpines-1);
        AllLateSpineCorrelations(1:1+size(AllLateSpineCorrelations,1):end) = nan;
        AllDendriteDistances{f} = FieldData{f}.CalciumData{end}.DistanceHeatMap;
        shuffnum = 1000;
        ShuffledEarlyMovementLabels = cell(1,shuffnum);
        ShuffledLateMovementLabels = cell(1,shuffnum);
        behaviorcorrdataearly = FieldData{f}.Correlations{1}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1); 
        behaviorcorrdatalate = FieldData{f}.Correlations{end}.SpineCorrelations(1:Spine1_Address-1,Spine1_Address:Spine1_Address+NumberofLateSpines-1);
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
        if size(FieldChanges{f},2) >1
            NewSpines = find(sum(FieldChanges{f},2));
        else
            NewSpines = find(FieldChanges{f}>0);
        end
        NumberofNewSpines = NumberofNewSpines+length(NewSpines);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(NewSpines)    %%% If there are new spines, find out whether they are close to a nearby movement spine, have a highly correlated partner, etc.
            NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR+sum(FieldData{f}.StatClass{end}.MovementSpines(NewSpines));
            OtherMovementSpinesThatArentNew = setdiff(AllMovementSpinesOnLateSession,NewSpines);
            %%% Compare new spines to EARLY session features
            if ~isempty(AllMovementSpinesOnEarlySession)
                NewSpinestoEarlyMovementSpines = [];
                NewSpinestoShuffledEarlyMovementSpines = [];
                for ns = 1:length(NewSpines)
                    count = 1;
                    for ms = 1:length(AllMovementSpinesOnEarlySession)
                        [val, ~] = sort([NewSpines(ns), AllMovementSpinesOnEarlySession(ms)]);
                        NewSpinestoEarlyMovementSpines(1,count) = FieldData{f}.CalciumData{1}.DistanceHeatMap(val(1),val(2));
                        NewSpinesEarlyMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));   %%% Find the correlation of new spines with the movement spines from early sessions (they might not be movement-related at the late sessions, but are they highly correlated with the new spine?)
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([NewSpines(ns),ShuffledEarlyMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = FieldData{f}.CalciumData{1}.DistanceHeatMap(val(1),val(2));
                        end
                        NewSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    [DistancesBetweenNewSpinesandEarlyMovementSpines{f}(ns), ind] = nanmin(NewSpinestoEarlyMovementSpines);
                    LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions{f}(ns) = NewSpinesEarlyMovementSpinesLateCorr(ind);
                    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{f}(ns) = nanmean(NewSpinestoShuffledEarlyMovementSpines);
                end
            end
            %%% Compare new spines to LATE session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentNew)
                for ns = 1:length(NewSpines)
                    NewSpinestoLateMovementSpines = [];
                    NewSpinestoRandomSpines = [];
                    NewSpinestoShuffledMovementSpines = [];
                    count = 1;
                    for os = 1:length(OtherMovementSpinesThatArentNew)
                        [val, ~] = sort([NewSpines(ns),OtherMovementSpinesThatArentNew(os)]);
                        NewSpinestoLateMovementSpines(1,count) = FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
                        NewSpinesLateMovementSpinesLateCorr(1,count) = AllLateSpineCorrelations(val(1), val(2));
                        ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == NewSpines(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                        randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        while randomspinefromsamedend == NewSpines(ns)
                            randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        end
                        [val, ~] = sort([NewSpines(ns),randomspinefromsamedend]);
                        NewSpinestoRandomSpines(1,count) = FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledLateMovementLabels{shuff})
                            [val, ~] = sort([NewSpines(ns),ShuffledLateMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
                        end
                        NewSpinestoShuffledMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    [DistancesBetweenNewSpinesandLateMovementSpines{f}(ns),ind] = nanmin(NewSpinestoLateMovementSpines);
                    LateCorrfNewSpinesandNearestMovementSpinefromLateSessions{f}(ns) = NewSpinesLateMovementSpinesLateCorr(ind);
                    DistancesBetweenNewSpinesandRandomSpines{f}(ns) = NewSpinestoRandomSpines(randi(length(NewSpinestoRandomSpines)));
                    DistancesBetweenNewSpinesandShuffledMovementSpines{f}(ns) = nanmean(NewSpinestoShuffledMovementSpines);
                end
            end
            %%%%%%
            [NewSpinesMaxCorr{f}, NewSpineMaxInd] = max(AllLateSpineCorrelations(NewSpines,:),[],2); %%% Find the spine that has the highest correlation with each new spine
            allotherspines = setdiff(1:NumberofLateSpines,union(NewSpineMaxInd, NewSpines)); %%% For comparison, find the spine that has the maximum correlation value with every other spine ("every other" can exclude either just new spines or new spines AND their highly correlated partners)
            OtherSpinesMaxCorr{f} = max(AllLateSpineCorrelations(allotherspines,:),[],2);
            %%%%%%
            for ns = 1:length(NewSpines)
                NewSpinesBehaviorCorrelation{f}(ns,1:9) = behaviorcorrdatalate(:,ns);
            end
            OtherSpinesBehaviorCorrelation{f} = behaviorcorrdatalate(:,setdiff(1:NumberofLateSpines,NewSpines));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if size(FieldChanges{f},2)>1
            ElimSpines = find(sum(FieldChanges{f},2));
        else
            ElimSpines = find(FieldChanges{f}<0);
        end
        NumberofElimSpines = NumberofElimSpines+length(ElimSpines);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(ElimSpines)    %%% If there are new spines, find out whether they are close to a nearby movement spine
            ElimSpinesThatWereMR = ElimSpines(ismember(ElimSpines, find(FieldData{f}.StatClass{1}.MovementSpines)));
            NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR+sum(FieldData{f}.StatClass{1}.MovementSpines(ElimSpines));
            OtherMovementSpinesThatArentElim = setdiff(AllMovementSpinesOnLateSession,ElimSpines);
            %%% Compare new spines to early session features
            if ~isempty(AllMovementSpinesOnEarlySession)
                ElimSpinestoEarlyMovementSpines = [];
                ElimSpinestoShuffledEarlyMovementSpines = [];
                for ns = 1:length(ElimSpines)
                    count = 1;
                    for ms = 1:length(AllMovementSpinesOnEarlySession)
                        [val, ~] = sort([ElimSpines(ns), AllMovementSpinesOnEarlySession(ms)]);
                        ElimSpinestoEarlyMovementSpines(1,count) = FieldData{f}.CalciumData{1}.DistanceHeatMap(val(1),val(2));
                        CorrElimSpinestoEarlyMovementSpines(1,count) = AllEarlySpineCorrelations(val(1), val(2));
                        if ElimSpinestoEarlyMovementSpines(1,count)<20 || CorrElimSpinestoEarlyMovementSpines(1,count)>0.2
                            k =1;
                        end
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledEarlyMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines(ns),ShuffledEarlyMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) = FieldData{f}.CalciumData{1}.DistanceHeatMap(val(1),val(2));
                        end
                        ElimSpinestoShuffledEarlyMovementSpines(1,count) = nanmin(shuffleddistances);
                        count = count+1;
                    end
                    [DistancesBetweenElimSpinesandEarlyMovementSpines{f}(ns), ind] = nanmin(ElimSpinestoEarlyMovementSpines);
                    CorrelationsofElimSpinesandEarlyMovementSpines{f}(ns) = CorrElimSpinestoEarlyMovementSpines(ind);
                    DistancesBetweenElimSpinesandShuffledEarlyMovementSpines{f}(ns) = nanmean(ElimSpinestoShuffledEarlyMovementSpines);
                end
            end
            %%% Compare new spines to late session features
            if ~isempty(AllMovementSpinesOnLateSession) && ~isempty(OtherMovementSpinesThatArentElim)
                for ns = 1:length(ElimSpines)
                    ElimSpinestoMovementSpines = [];
                    ElimSpinestoRandomSpines = [];
                    ElimSpinestoShuffledMovementSpines = [];
                    count = 1;
                    for os = 1:length(OtherMovementSpinesThatArentElim)
                        [val, ~] = sort([ElimSpines(ns),OtherMovementSpinesThatArentElim(os)]);
                        ElimSpinestoMovementSpines(1,count) = FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
                        ParentDend =  find(~cell2mat(cellfun(@(x) isempty(find(x == ElimSpines(ns),1)), FieldData{f}.CalciumData{1}.SpineDendriteGrouping, 'Uni', false)));
                        randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        while randomspinefromsamedend == ElimSpines(ns)
                            randomspinefromsamedend = FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend}(randi(length(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{ParentDend})));
                        end
                        [val, ~] = sort([ElimSpines(ns),randomspinefromsamedend]);
                        ElimSpinestoRandomSpines(1,count) = FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
                        count = count+1;
                    end
                    count = 1;
                    for shuff = 1:shuffnum
                        for sh = 1:length(ShuffledLateMovementLabels{shuff})
                            [val, ~] = sort([ElimSpines(ns),ShuffledLateMovementLabels{shuff}(sh)]);
                            shuffleddistances(1,sh) =  FieldData{f}.CalciumData{end}.DistanceHeatMap(val(1),val(2));
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
            Spine1_Address = 10;
            currentcorrdata = FieldData{f}.Correlations{1}.SpineCorrelations(Spine1_Address:Spine1_Address+NumberofEarlySpines-1,Spine1_Address:Spine1_Address+NumberofEarlySpines-1);
            currentcorrdata(1:1+size(currentcorrdata,1):end) = nan; %%% set identity values to nan
            [ElimSpinesMaxCorr{f}, ElimSpineMaxInd] = max(currentcorrdata(ElimSpines,:),[],2);
            allotherspines = setdiff(1:NumberofEarlySpines,union(ElimSpineMaxInd, ElimSpines));
            OtherSpinesMaxCorr{f} = max(currentcorrdata(allotherspines,:),[],2);
            for es = 1:length(ElimSpines)
                ElimSpinesBehaviorCorrelation{f}(es,1:9) = behaviorcorrdataearly(:,es);
            end
            %%%%%%
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

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
                if sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}))
                    NumberofDendritesThatBecomeMRandHaveMRSpines = NumberofDendritesThatBecomeMRandHaveMRSpines+1;
                end
                if ~isempty(find((diff([FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}),FieldData{f}.StatClass{end}.MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d})],1,2))>0,1))
                    NumberofDendritesThatBecomeMRandGainMRSpines = NumberofDendritesThatBecomeMRandGainMRSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},NewSpines))
                    NumberofDendritesThatBecomeMRandHaveNewSpines = NumberofDendritesThatBecomeMRandHaveNewSpines+1;
                end
                if sum(ismember(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d},ElimSpines))
                    NumberofDendritesThatBecomeMRandHaveElimSpines = NumberofDendritesThatBecomeMRandHaveElimSpines+1;
                end
            end
            if DendriteFunctionChange{f}(d)<0
                NumberofDendritesThatLoseMR = NumberofDendritesThatLoseMR+1;
                if sum(FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}))
                    NumberofDendritesThatLoseMRandHaveMRSpines = NumberofDendritesThatLoseMRandHaveMRSpines+1;
                end
                if ~isempty(find((diff([FieldData{f}.StatClass{1}.MovementSpines(FieldData{f}.CalciumData{1}.SpineDendriteGrouping{d}),FieldData{f}.StatClass{end}.MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d})],1,2))<0,1))
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
                    NumberofMovementSpinesOnAdditionDendrites = [NumberofMovementSpinesOnAdditionDendrites;sum(FieldData{f}.StatClass{end}.MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
                end
                if ~isempty(find(DendriteDynamics{f}{d}<0,1))
                    NumberofEliminationDendrites = NumberofEliminationDendrites + 1;
                    if IsDendriteUsed{f}(d)
                        NumberofEliminationDendritesUsedForMovement = NumberofEliminationDendritesUsedForMovement+1;
                    end
                    NumberofMovementSpinesOnEliminationDendrites = [NumberofMovementSpinesOnEliminationDendrites;sum(FieldData{f}.StatClass{end}.MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
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
                NumberofMovementSpinesOnStaticDendrites = [NumberofMovementSpinesOnStaticDendrites;sum(FieldData{f}.StatClass{end}.MovementSpines(FieldData{f}.CalciumData{end}.SpineDendriteGrouping{d}))];
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
    
    a.NumberofNewSpines = NumberofNewSpines;
    a.NumberofElimSpines = NumberofElimSpines;
    a.FractionofMovementRelatedSpinesMaintained = FractionofMovementRelatedSpinesMaintained;
    a.FractionofMovementRelatedSpinesEliminated = FractionofMovementRelatedSpinesEliminated;
    a.NumberofNewSpinesThatAreMR = NumberofNewSpinesThatAreMR;
    a.NumberofElimSpinesThatWereMR = NumberofElimSpinesThatWereMR;
    a.DistancesBetweenNewSpinesandEarlyMovementSpines = DistancesBetweenNewSpinesandEarlyMovementSpines;
    a.LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions = LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions;
    a.DistancesBetweenNewSpinesandMovementSpines = DistancesBetweenNewSpinesandLateMovementSpines;
    a.LateCorrfNewSpinesandNearestMovementSpinefromLateSessions = LateCorrfNewSpinesandNearestMovementSpinefromLateSessions;
    a.DistancesBetweenElimSpinesandEarlyMovementSpines = DistancesBetweenElimSpinesandEarlyMovementSpines;
    a.CorrelationsofElimSpinesandEarlyMovementSpines = CorrelationsofElimSpinesandEarlyMovementSpines;
    a.DistancesBetweenElimSpinesandMovementSpines = DistancesBetweenElimSpinesandMovementSpines;
    a.DistancesBetweenNewSpinesandRandomSpines = DistancesBetweenNewSpinesandRandomSpines;
    a.DistancesBetweenElimSpinesandRandomSpines = DistancesBetweenElimSpinesandRandomSpines;
    a.DistancesBetweenNewSpinesandShuffledEarlyMovementSpines = DistancesBetweenNewSpinesandShuffledEarlyMovementSpines;
    a.DistancesBetweenNewSpinesandShuffledMovementSpines = DistancesBetweenNewSpinesandShuffledMovementSpines;
    a.DistancesBetweenElimSpinesandShuffledEarlyMovementSpines = DistancesBetweenElimSpinesandShuffledEarlyMovementSpines;
    a.DistancesBetweenElimSpinesandShuffledMovementSpines = DistancesBetweenElimSpinesandShuffledMovementSpines;
    a.NewSpinesMaxCorrelation = NewSpinesMaxCorr;
    a.NewSpinesBehaviorCorrelation = NewSpinesBehaviorCorrelation;
    a.ElimSpinesBehaviorCorrelation = ElimSpinesBehaviorCorrelation;
    a.OtherSpinesBehaviorCorrelation = OtherSpinesBehaviorCorrelation;
    a.ElimSpinesMaxCorrelation = ElimSpinesMaxCorr;
    a.OtherSpinesMaxCorrelation = OtherSpinesMaxCorr;    

    eval([experimentnames, '_SpineDynamicsSummary = a'])
    fname = [experimentnames, '_SpineDynamicsSummary'];
    save(fname, fname)
    
    disp(['Analysis of ', experimentnames, ' complete'])
else
    if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
        cd('C:\Users\Komiyama\Desktop\Output Data')
    end
    
    for i = 1:length(experimentnames)
        targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
        load(targetfile)
        eval(['currentdata = ',targetfile])
        NumFields = length(currentdata.SpineDynamics);
        SpineDynamics{i} = currentdata.SpineDynamics;
        DendriteDynamics{i} =  currentdata.DendriteDynamics;
        AllDendriteDistances{i} = currentdata.AllDendriteDistances;
        AllMovementSpines{i} = currentdata.AllMovementSpines;
        FractionofDendritesThatAreDynamic(1,i) = currentdata.FractionofDendritesThatAreDynamic;
        FractionofDendriteswithAddition(1,i) = currentdata.FractionofDendriteswithAddition;
        FractionofDendriteswithElimination(1,i) = currentdata.FractionofDendriteswithElimination;
        FractionofDendritesThatAreEverMovementRelated(1,i) = currentdata.FractionofDendritesThatAreEverMovementRelated;
        NumberofImagedDendrites(1,i) = currentdata.NumberofImagedDendrites;
        NumberofDynamicDendrites(1,i) = currentdata.NumberofDynamicDendrites;
        NumberofAdditionDendrites(1,i) = currentdata.NumberofAdditionDendrites;
        NumberofEliminationDendrites(1,i) = currentdata.NumberofEliminationDendrites;
        NumberofAdditionandEliminationDendrites(1,i) = currentdata.NumberofAdditionandEliminationDendrites;
        NumberofStaticDendrites(1,i) = currentdata.NumberofStaticDendrites;
        NumberofMovementSpinesOnAdditionDendrites{i} = currentdata.NumberofMovementSpinesOnAdditionDendrites;
        NumberofMovementSpinesOnEliminationDendrites{i} = currentdata.NumberofMovementSpinesOnEliminationDendrites;
        NumberofMovementSpinesOnStaticDendrites{i} = currentdata.NumberofMovementSpinesOnStaticDendrites;
        NumberofDendritesThatAreEverMovementRelated(1,i) = currentdata.NumberofDendritesThatAreEverMovementRelated;
        NumberofDynamicDendritesUsedForMovement(1,i) = currentdata.NumberofDynamicDendritesUsedForMovement;
        NumberofAdditionDendritesUsedForMovement(1,i) = currentdata.NumberofAdditionDendritesUsedForMovement;
        NumberofEliminationDendritesUsedForMovement(1,i) = currentdata.NumberofEliminationDendritesUsedForMovement;
        NumberofAdditionandEliminationDendritesUsedForMovement(1,i) = currentdata.NumberofAdditionandEliminationDendritesUsedForMovement;
        NumberofStaticDendritesUsedForMovement(1,i) = currentdata.NumberofStaticDendritesUsedForMovement;
        FractionofDynamicDendritesUsedForMovement(1,i) = currentdata.FractionofDynamicDendritesUsedForMovement;
        FractionofAdditionDendritesUsedForMovement(1,i) = currentdata.FractionofAdditionDendritesUsedForMovement;
        FractionofEliminationDendritesUsedForMovement(1,i) = currentdata.FractionofEliminationDendritesUsedForMovement;
        FractionofStaticDendritesUsedForMovement(1,i) = currentdata.FractionofStaticDendritesUsedForMovement;
        FractionofMovementRelatedSpinesMaintained{i} = cell2mat(currentdata.FractionofMovementRelatedSpinesMaintained);
        FractionofMovementRelatedSpinesEliminated{i} = cell2mat(currentdata.FractionofMovementRelatedSpinesEliminated);
        NumberofNewSpines(1,i) = currentdata.NumberofNewSpines;
        NumberofElimSpines(1,i) = currentdata.NumberofElimSpines;
        NumberofNewSpinesThatAreMR(1,i) = currentdata.NumberofNewSpinesThatAreMR;
        NumberofElimSpinesThatWereMR(1,i) = currentdata.NumberofElimSpinesThatWereMR;
        DistancesBetweenNewSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandEarlyMovementSpines);
        LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions{i} = cell2mat(currentdata.LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions);
        DistancesBetweenNewSpinesandLateMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandMovementSpines);
        LateCorrfNewSpinesandNearestMovementSpinefromLateSessions{i} = cell2mat(currentdata.LateCorrfNewSpinesandNearestMovementSpinefromLateSessions);
        DistancesBetweenElimSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandEarlyMovementSpines);
        CorrelationsofElimSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.CorrelationsofElimSpinesandEarlyMovementSpines);
        DistancesBetweenElimSpinesandMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandMovementSpines);
        DistancesBetweenNewSpinesandRandomSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandRandomSpines);
        DistancesBetweenElimSpinesandRandomSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandRandomSpines);
        DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandShuffledEarlyMovementSpines);
        DistancesBetweenNewSpinesandShuffledMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandShuffledMovementSpines);
        DistancesBetweenElimSpinesandShuffledEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandShuffledEarlyMovementSpines);
        DistancesBetweenElimSpinesandShuffledMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandShuffledMovementSpines);
        NumberofDendritesThatBecomeMR(1,i) = currentdata.NumberofDendritesThatBecomeMR;
        NumberofDendritesThatBecomeMRandHaveMRSpines(1,i) = currentdata.NumberofDendritesThatBecomeMRandHaveMRSpines;
        NumberofDendritesThatBecomeMRandGainMRSpines(1,i) = currentdata.NumberofDendritesThatBecomeMRandGainMRSpines;
        NumberofDendritesThatBecomeMRandHaveNewSpines(1,i) = currentdata.NumberofDendritesThatBecomeMRandHaveNewSpines;
        NumberofDendritesThatBecomeMRandHaveElimSpines(1,i) = currentdata.NumberofDendritesThatBecomeMRandHaveElimSpines;
        NumberofDendritesThatLoseMR(1,i) = currentdata.NumberofDendritesThatLoseMR;
        NumberofDendritesThatLoseMRandHaveMRSpines(1,i) = currentdata.NumberofDendritesThatLoseMRandHaveMRSpines;
        NumberofDendritesThatLoseMRandLoseMRSpines(1,i) = currentdata.NumberofDendritesThatLoseMRandLoseMRSpines;
        NumberofDendritesThatLoseMRandHaveNewSpines(1,i) = currentdata.NumberofDendritesThatLoseMRandHaveNewSpines;
        NumberofDendritesThatLoseMRandHaveElimSpines(1,i) = currentdata.NumberofDendritesThatLoseMRandHaveElimSpines;
        
        NewSpinesMaxCorr{i} = cell2mat(currentdata.NewSpinesMaxCorrelation');
        ElimSpinesMaxCorr{i} = cell2mat(currentdata.ElimSpinesMaxCorrelation');
        OtherSpinesMaxCorr{i} = cell2mat(currentdata.OtherSpinesMaxCorrelation');
        
        NewSpinesBehaviorCorrelation{i} = cell2mat(currentdata.NewSpinesBehaviorCorrelation');
        OtherSpinesBehaviorCorrelation{i} = cell2mat(currentdata.OtherSpinesBehaviorCorrelation)';
        clear currentdata
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%% Color Information %%
    %%%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];       brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];        lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];      orange = [0.95 0.40 0.13];
    lgreen = [0.45 0.8 0.35];       green = [0.00 0.43 0.23];
    lblue = [0.30 0.65 0.94];       blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55];     purple = [0.57 0.15 0.56];
    pink = [0.9 0.6 0.6];           lpurple  = [0.7 0.15 1];
    red = [0.85 0.11 0.14];         black = [0.1 0.1 0.15];
    dred = [0.6 0 0];               dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 

    %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 1: Prevalence of Spine Dynamics
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure; 
%     allmat = [nanmean(FractionofDendritesThatAreDynamic); nanmean(FractionofDendriteswithAddition); nanmean(FractionofDendriteswithElimination)];
%     allerror = [nanstd(FractionofDendritesThatAreDynamic)/sqrt(length(FractionofDendritesThatAreDynamic)); nanstd(FractionofDendriteswithAddition)/sqrt(length(FractionofDendriteswithAddition)); nanstd(FractionofDendriteswithElimination)/sqrt(length(FractionofDendriteswithElimination))];
    allmat = [NumberofAdditionDendrites/NumberofImagedDendrites; NumberofEliminationDendrites/NumberofImagedDendrites; NumberofAdditionandEliminationDendrites/NumberofImagedDendrites];
    bar(allmat, 'FaceColor', lgreen)
%     r_errorbar(1:3, allmat, allerror, 'k')
    ylabel({'Fraction of Dendrites'; 'with Dynamic Spines'}, 'Fontsize', 12)
    set(gca, 'XTick', 1:3, 'XTickLabel',{'A', 'E', 'A&E'})
    title('Prevalence of Spine Dynamics on Imaged Dendrites')
    ylim([0 1])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 2: Spine Dynamics and Movement Relatedness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\
   
    figure;
%     allmat = [nanmean(FractionofDendritesThatAreEverMovementRelated), nanmean(FractionofDynamicDendritesUsedForMovement),nanmean(FractionofAdditionDendritesUsedForMovement),nanmean(FractionofEliminationDendritesUsedForMovement),nanmean(FractionofStaticDendritesUsedForMovement)];
%     allerror = [nanstd(FractionofDendritesThatAreEverMovementRelated)/sqrt(length(FractionofDendritesThatAreEverMovementRelated)); nanstd(FractionofDynamicDendritesUsedForMovement)/sqrt(length(FractionofDynamicDendritesUsedForMovement)); nanstd(FractionofAdditionDendritesUsedForMovement)/sqrt(length(FractionofAdditionDendritesUsedForMovement));nanstd(FractionofEliminationDendritesUsedForMovement)/sqrt(length(FractionofEliminationDendritesUsedForMovement));nanstd(FractionofStaticDendritesUsedForMovement)/sqrt(length(FractionofStaticDendritesUsedForMovement))];
    allmat = [nansum(NumberofDendritesThatAreEverMovementRelated)/nansum(NumberofImagedDendrites), nansum(NumberofAdditionDendritesUsedForMovement)/nansum(NumberofAdditionDendrites), nansum(NumberofEliminationDendritesUsedForMovement)/nansum(NumberofEliminationDendrites),nansum(NumberofAdditionandEliminationDendritesUsedForMovement)/nansum(NumberofAdditionandEliminationDendrites), nansum(NumberofStaticDendritesUsedForMovement)/nansum(NumberofStaticDendrites)];
    bar(allmat, 'FaceColor', blue)
%     r_errorbar(1:5, allmat, allerror, 'k')
    ylabel({'Fraction of Dendrites'; 'That Are Movement Related'}, 'Fontsize', 12)
    set(gca, 'XTick', 1:5, 'XTickLabel',{'All Dends','A','E','A&E','Static'})
    title('Likelihood of Movement Relatedness')
    text(1,nansum(NumberofDendritesThatAreEverMovementRelated)/nansum(NumberofImagedDendrites)+0.05, [num2str(nansum(NumberofDendritesThatAreEverMovementRelated)), '/', num2str(nansum(NumberofImagedDendrites))])
%     text(2,nansum(NumberofDynamicDendritesUsedForMovement)/nansum(NumberofDynamicDendrites) + 0.05, [num2str(nansum(NumberofDynamicDendritesUsedForMovement)), '/', num2str(nansum(NumberofDynamicDendrites))])
    text(2,nansum(NumberofAdditionDendritesUsedForMovement)/nansum(NumberofAdditionDendrites) + 0.05, [num2str(nansum(NumberofAdditionDendritesUsedForMovement)), '/', num2str(nansum(NumberofAdditionDendrites))])
    text(3,nansum(NumberofEliminationDendritesUsedForMovement)/nansum(NumberofEliminationDendrites) + 0.05, [num2str(nansum(NumberofEliminationDendritesUsedForMovement)), '/', num2str(nansum(NumberofEliminationDendrites))])
    text(4,nansum(NumberofAdditionandEliminationDendritesUsedForMovement)/nansum(NumberofAdditionandEliminationDendrites) + 0.05, [num2str(nansum(NumberofAdditionandEliminationDendritesUsedForMovement)), '/', num2str(nansum(NumberofAdditionandEliminationDendrites))])
    text(5,nansum(NumberofStaticDendritesUsedForMovement)/nansum(NumberofStaticDendrites) + 0.05, [num2str(nansum(NumberofStaticDendritesUsedForMovement)), '/', num2str(nansum(NumberofStaticDendrites))])
    ylim([0 1])
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 3: Predictive Features of Becoming movement related
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure; subplot(1,2,1)
    FractionofDendsThatBecomeMR = nansum(NumberofDendritesThatBecomeMR)/nansum(NumberofImagedDendrites);
    FractionofDendritesThatBecomeMRandHaveMRSpines = nansum(NumberofDendritesThatBecomeMRandHaveMRSpines)/nansum(NumberofDendritesThatBecomeMR);
    FractionofDendritesThatBecomeMRandGainMRSpines = nansum(NumberofDendritesThatBecomeMRandGainMRSpines)/nansum(NumberofDendritesThatBecomeMR);
    FractionofDendritesThatBecomeMRandHaveNewSpines = nansum(NumberofDendritesThatBecomeMRandHaveNewSpines)/nansum(NumberofDendritesThatBecomeMR);
    FractionofDendritesThatBecomeMRandHaveElimSpines = nansum(NumberofDendritesThatBecomeMRandHaveElimSpines)/nansum(NumberofDendritesThatBecomeMR);
    
    allmat = [FractionofDendsThatBecomeMR,FractionofDendritesThatBecomeMRandHaveMRSpines,FractionofDendritesThatBecomeMRandGainMRSpines,FractionofDendritesThatBecomeMRandHaveNewSpines,FractionofDendritesThatBecomeMRandHaveElimSpines];
    bar(allmat, 'FaceColor', orange)
    ylabel('Fraction of Dendrites', 'Fontsize', 12)
    set(gca, 'XTick', 1:5, 'XTickLabel', {'All Dends', 'Old MRS', 'New MRS', 'A', 'E'})
    ylim([0 1])
    title('Predictive Features of Becoming MR')
    
    text(1,FractionofDendsThatBecomeMR+0.05, [num2str(sum(NumberofDendritesThatBecomeMR)), '/', num2str(nansum(NumberofImagedDendrites))])
    text(2,FractionofDendritesThatBecomeMRandHaveMRSpines+0.05, [num2str(nansum(NumberofDendritesThatBecomeMRandHaveMRSpines)), '/', num2str(nansum(NumberofDendritesThatBecomeMR))])
    text(3,FractionofDendritesThatBecomeMRandGainMRSpines+0.05, [num2str(nansum(NumberofDendritesThatBecomeMRandGainMRSpines)), '/', num2str(nansum(NumberofDendritesThatBecomeMR))])
    text(4,FractionofDendritesThatBecomeMRandHaveNewSpines+0.05, [num2str(nansum(NumberofDendritesThatBecomeMRandHaveNewSpines)), '/', num2str(nansum(NumberofDendritesThatBecomeMR))])
    text(5,FractionofDendritesThatBecomeMRandHaveElimSpines+0.05, [num2str(nansum(NumberofDendritesThatBecomeMRandHaveElimSpines)), '/', num2str(nansum(NumberofDendritesThatBecomeMR))])
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 4: Predictive Features of Losing Movement Relatedness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(1,2,2)
    FractionofDendsThatLoseMR = nansum(NumberofDendritesThatLoseMR)/nansum(NumberofImagedDendrites);
    FractionofDendritesThatLoseMRandHaveMRSpines = nansum(NumberofDendritesThatLoseMRandHaveMRSpines)/nansum(NumberofDendritesThatLoseMR);
    FractionofDendritesThatLoseMRandLoseMRSpines = nansum(NumberofDendritesThatLoseMRandLoseMRSpines)/nansum(NumberofDendritesThatLoseMR);
    FractionofDendritesThatLoseMRandHaveNewSpines = nansum(NumberofDendritesThatLoseMRandHaveNewSpines)/nansum(NumberofDendritesThatLoseMR);
    FractionofDendritesThatLoseMRandHaveElimSpines = nansum(NumberofDendritesThatLoseMRandHaveElimSpines)/nansum(NumberofDendritesThatLoseMR);
    
    allmat = [FractionofDendsThatLoseMR,FractionofDendritesThatLoseMRandHaveMRSpines,FractionofDendritesThatLoseMRandLoseMRSpines,FractionofDendritesThatLoseMRandHaveNewSpines,FractionofDendritesThatLoseMRandHaveElimSpines];
    bar(allmat, 'FaceColor', lblue)
    ylabel('Fraction of Dendrites', 'Fontsize', 12)
    set(gca, 'XTick', 1:5, 'XTickLabel', {'All Dends', 'Old MRS', 'New MRS', 'A', 'E'})
    ylim([0 1])
    title('Predictive Features of Losing MR')
    
    text(1,FractionofDendsThatLoseMR+0.05, [num2str(sum(NumberofDendritesThatLoseMR)), '/', num2str(nansum(NumberofImagedDendrites))])
    text(2,FractionofDendritesThatLoseMRandHaveMRSpines+0.05, [num2str(nansum(NumberofDendritesThatLoseMRandHaveMRSpines)), '/', num2str(nansum(NumberofDendritesThatLoseMR))])
    text(3,FractionofDendritesThatLoseMRandLoseMRSpines+0.05, [num2str(nansum(NumberofDendritesThatLoseMRandLoseMRSpines)), '/', num2str(nansum(NumberofDendritesThatLoseMR))])
    text(4,FractionofDendritesThatLoseMRandHaveNewSpines+0.05, [num2str(nansum(NumberofDendritesThatLoseMRandHaveNewSpines)), '/', num2str(nansum(NumberofDendritesThatLoseMR))])
    text(5,FractionofDendritesThatLoseMRandHaveElimSpines+0.05, [num2str(nansum(NumberofDendritesThatLoseMRandHaveElimSpines)), '/', num2str(nansum(NumberofDendritesThatLoseMR))])

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 5: Characterization of New Spines
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure; 
    
    allmat = [sum(NumberofNewSpinesThatAreMR)/sum(NumberofNewSpines), sum(NumberofElimSpinesThatWereMR)/sum(NumberofElimSpines)];
    bar(allmat, 'FaceColor', red);
    
    text(1,sum(NumberofNewSpinesThatAreMR)/sum(NumberofNewSpines)+0.05, [num2str(sum(NumberofNewSpinesThatAreMR)), '/', num2str(sum(NumberofNewSpines))])
    text(2,sum(NumberofElimSpinesThatWereMR)/sum(NumberofElimSpines)+0.05, [num2str(sum(NumberofElimSpinesThatWereMR)), '/', num2str(sum(NumberofElimSpines))])
    ylim([0 1])   
    xlim([0 3])
    set(gca, 'XTick', [1 2])
    set(gca, 'XTickLabel', {'New Spines', 'Elim Spines'})
    ylabel('Fractin of Spines that Become MR')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 6: Distance Between Dynamic Spines and MR spines
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    newspinesrandspines = cell2mat(DistancesBetweenNewSpinesandRandomSpines);
    newspinesshuffledearlyspines = cell2mat(DistancesBetweenNewSpinesandShuffledEarlyMovementSpines);
    newspinesearlymovspines = cell2mat(DistancesBetweenNewSpinesandEarlyMovementSpines);
    newspinesshuffledlatespines = cell2mat(DistancesBetweenNewSpinesandShuffledMovementSpines);
    newspineslatemovspines = cell2mat(DistancesBetweenNewSpinesandLateMovementSpines);
    elimspinesrandspines = cell2mat(DistancesBetweenElimSpinesandRandomSpines);
    elimspinesshuffledearlyspines = cell2mat(DistancesBetweenElimSpinesandShuffledEarlyMovementSpines);
    elimspinesearlymovspines = cell2mat(DistancesBetweenElimSpinesandEarlyMovementSpines);
    elimspinesshuffledspines = cell2mat(DistancesBetweenElimSpinesandShuffledMovementSpines);
    elimspineslatemovspines = cell2mat(DistancesBetweenElimSpinesandMovementSpines);
    
    shuffnum = 1000;
    alphaforbootstrap = 0.05;
    SimNewSpinetoEarlyMovementSpineDistance = nan(1,shuffnum);
    SimNewSpinetoLateMovementSpineDistance = nan(1,shuffnum);
    
    for i = 1:shuffnum
        mockearlynewspinedistribution = nan(1,sum(NumberofNewSpines));
        mocklatenewspinedistribution = nan(1,sum(NumberofNewSpines));
        mockearlyelimspinedistribution = nan(1,sum(NumberofElimSpines));
        mocklateelimspinedistribution = nan(1,sum(NumberofElimSpines));
        for j = 1:sum(NumberofNewSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randSpine = randi([1,length(AllDendriteDistances{randAnimal}{randField})]);
            simNewSpine = randSpine;
%         simNewSpineDistances = AllDendriteDistances{randAnimal}{randField}(simNewSpine,:);
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(:,1); %%% 1 index corresponds to early session
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(:,end);%%% 'end' index corresponds to final session
            while ~any(~isnan(AllDendriteDistances{randAnimal}{randField}(simNewSpine, EarlyMovementSpines))) || ~any(~isnan(AllDendriteDistances{randAnimal}{randField}(simNewSpine, LateMovementSpines)))
                randAnimal = randi([1,length(AllDendriteDistances)],1);
                randField = randi([1,length(AllDendriteDistances{randAnimal})]);
                randSpine = randi([1,length(AllDendriteDistances{randAnimal}{randField})]);
                simNewSpine = randSpine;
            %         simNewSpineDistances = AllDendriteDistances{randAnimal}{randField}(simNewSpine,:);
                EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(:,1);
                LateMovementSpines = AllMovementSpines{randAnimal}{randField}(:,end);
            end
            mockearlynewspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simNewSpine, EarlyMovementSpines));
            mocklatenewspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simNewSpine, LateMovementSpines));
            mockearlyelimspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simNewSpine, EarlyMovementSpines));
            mocklateelimspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simNewSpine, LateMovementSpines));
        end
        SimNewSpinetoEarlyMovementSpineDistance(i) = nanmedian(mockearlynewspinedistribution);
            if SimNewSpinetoEarlyMovementSpineDistance(i) > nanmedian(newspinesearlymovspines)
                NewSpineEarlyMoveSpinesNullDistTest(i) = 1;
            else
                NewSpineEarlyMoveSpinesNullDistTest(i) = 0;
            end
        SimNewSpinetoLateMovementSpineDistance(i) = nanmedian(mocklatenewspinedistribution);
            if SimNewSpinetoLateMovementSpineDistance(i) > nanmedian(newspineslatemovspines)
                NewSpineLateMoveSpinesNullDistTest(i) = 1;
            else
                NewSpineLateMoveSpinesNullDistTest(i) = 0;
            end
        %%% Repeat for eliminated spines
        for j = 1:sum(NumberofElimSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randSpine = randi([1,length(AllDendriteDistances{randAnimal}{randField})]);
            simElimSpine = randSpine;
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(:,1); %%% 1 index corresponds to early session
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(:,end);%%% 'end' index corresponds to final session
            while ~any(~isnan(AllDendriteDistances{randAnimal}{randField}(simElimSpine, EarlyMovementSpines))) || ~any(~isnan(AllDendriteDistances{randAnimal}{randField}(simElimSpine, LateMovementSpines)))
                randAnimal = randi([1,length(AllDendriteDistances)],1);
                randField = randi([1,length(AllDendriteDistances{randAnimal})]);
                randSpine = randi([1,length(AllDendriteDistances{randAnimal}{randField})]);
                simElimSpine = randSpine;
                EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(:,1);
                LateMovementSpines = AllMovementSpines{randAnimal}{randField}(:,end);
            end
            mockearlynewspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simElimSpine, EarlyMovementSpines));
            mocklatenewspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simElimSpine, LateMovementSpines));
            mockearlyelimspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simElimSpine, EarlyMovementSpines));
            mocklateelimspinedistribution(j) = nanmin(AllDendriteDistances{randAnimal}{randField}(simElimSpine, LateMovementSpines));
        end
        
        SimElimSpinetoEarlyMovementSpineDistance(i) = nanmedian(mockearlyelimspinedistribution);
            if SimElimSpinetoEarlyMovementSpineDistance(i) > nanmedian(elimspinesearlymovspines)
                ElimSpineEarlyMoveSpinesNullDistTest(i) = 1;
            else
                ElimSpineEarlyMoveSpinesNullDistTest(i) = 0;
            end
        SimElimSpinetoLateMovementSpineDistance(i) = nanmedian(mocklateelimspinedistribution);
            if SimElimSpinetoLateMovementSpineDistance(i) > nanmedian(elimspineslatemovspines)
                ElimSpineLateMoveSpinesNullDistTest(i) = 1;
            else
                ElimSpineLateMoveSpinesNullDistTest(i) = 0;
            end
    end
    
    
%     datamat = [{newspinesrandspines},{newspinesshuffledearlyspines},{SimNewSpinetoEarlyMovementSpineDistance},{newspinesearlymovspines},{newspinesshuffledlatespines},{SimNewSpinetoLateMovementSpineDistance},{newspineslatemovspines},{elimspinesrandspines}, {elimspinesshuffledearlyspines},{elimspinesearlymovspines},{elimspinesshuffledspines},{elimspineslatemovspines}];
    datamat = [{SimNewSpinetoEarlyMovementSpineDistance},{newspinesearlymovspines}, {SimNewSpinetoLateMovementSpineDistance}, {newspineslatemovspines}, {SimElimSpinetoEarlyMovementSpineDistance},{elimspinesearlymovspines}, {SimElimSpinetoLateMovementSpineDistance}, {elimspineslatemovspines}];
    figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred')
%     r_errorbar(1:6, [nanmedian(randspines),nanmedian(shuffledearlyspines),nanmedian(earlyspines),nanmedian(shuffledspines),nanmedian(newspines),nanmedian(elimspines)], [nanstd(randspines)/sum(~isnan(randspines)),nanstd(shuffledearlyspines)/sum(~isnan(shuffledearlyspines)),nanstd(earlyspines)/sum(~isnan(earlyspines)),nanstd(shuffledspines)/sum(~isnan(shuffledspines)), nanstd(newspines)/sum(~isnan(newspines)), nanstd(elimspines)/sum(~isnan(elimspines))], 'k')
    bootstrpnum = shuffnum;
    for i = 1:length(datamat)
        Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
        line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
    end
    set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'Shuff New Spine-Early MRS','New Spine-Early MRS','Shuff New Spine-MRS', 'New Spine-MRS','Shuff. Elim Sp - Early MRS', 'Elim Sp - Early MRS','Shuff Elim Sp - MRS', 'Elim Spine - MRS'})
    ylabel('Median Distance')
    xtickangle(gca, 45)

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 7: Number of Movement Spines on Dynamic vs. Static Dendrites
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    MoveSpinesonAdditionDendrites = cell2mat(NumberofMovementSpinesOnAdditionDendrites');
    MoveSpinesonEliminationDendrites = cell2mat(NumberofMovementSpinesOnEliminationDendrites');
    MoveSpinesonStaticDendrites = cell2mat(NumberofMovementSpinesOnStaticDendrites');
    
    allmat = [{MoveSpinesonAdditionDendrites}, {MoveSpinesonEliminationDendrites}, {MoveSpinesonStaticDendrites}];
    figure; bar(1:length(allmat), cell2mat(cellfun(@nanmedian, allmat, 'uni', false)), 'FaceColor', lgreen)
    
    for i = 1:length(allmat)
        Y = bootci(bootstrpnum, {@median, allmat{i}(~isnan(allmat{i}))}, 'alpha', alphaforbootstrap);
        line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
    end
    set(gca, 'XTick', 1:length(allmat), 'XTickLabel',{'Add. Dends', 'Elim. Dends', 'Static Dends'})
    ylabel('Median # of Move Spines')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 8: Dynamic Spines Max Correlation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure; subplot(1,2,1);hold on;
    histogram(cell2mat(NewSpinesMaxCorr'),25); title('New Spines Max Corr. Dist.'); xlim([0 1])
    plot(nanmedian(cell2mat(NewSpinesMaxCorr'))*ones(1,11),0:(max(hist(cell2mat(NewSpinesMaxCorr')))/10):max(hist(cell2mat(NewSpinesMaxCorr'))), '--r')
    text(nanmedian(cell2mat(NewSpinesMaxCorr')), max(hist(cell2mat(NewSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(NewSpinesMaxCorr')))])
    histogram(cell2mat(ElimSpinesMaxCorr'),25)
    subplot(1,2,2); hold on
    histogram(cell2mat(OtherSpinesMaxCorr'),25); title('All Other Spines Max Corr. Dist.'); xlim([0 1])
    plot(nanmedian(cell2mat(OtherSpinesMaxCorr'))*ones(1,11),0:(max(hist(cell2mat(OtherSpinesMaxCorr')))/10):max(hist(cell2mat(OtherSpinesMaxCorr'))), '--r')
    text(nanmedian(cell2mat(OtherSpinesMaxCorr')), max(hist(cell2mat(OtherSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(OtherSpinesMaxCorr')))])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 9: New Spines Behavior Corr
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure; newspplot = subplot(1,2,1); hold on; title('New Spines'' Correlation with Task')
    tempnewspmat = cell2mat(NewSpinesBehaviorCorrelation');
%     tempnewspmat(tempnewspmat>=0) = nan;
    bar(nanmedian(tempnewspmat,1))
    for i = 1:9
        Y = bootci(bootstrpnum, {@median, tempnewspmat(~isnan(tempnewspmat(:,i)),i)}, 'alpha', 0.05);
        line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
    end
    set(gca, 'XTick', [1:9])
    set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
    xtickangle(gca, 45)
    ylabel('Correlation')
    
    otherspplot = subplot(1,2,2); hold on; title('All Other Spines'' Correlation with Task')
    tempotherspmat = cell2mat(OtherSpinesBehaviorCorrelation');
%     tempotherspmat(tempotherspmat>=0) = nan;
    bar(nanmedian(tempotherspmat,1))
    linkaxes([newspplot,otherspplot],'y')
    for i = 1:9
        Y = bootci(bootstrpnum, {@median, tempotherspmat(~isnan(tempotherspmat(:,i)),i)}, 'alpha', 0.05);
        line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
    end
    set(gca, 'XTick', [1:9])
    set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
    xtickangle(gca, 45)
    ylabel('Correlation')
end
end