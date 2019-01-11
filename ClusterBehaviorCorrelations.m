function ClusterBehaviorCorrelations(varargin)

%%% Input argument list:
%%% If running this on a single animal, inputs are the following:
%%% 1: All Correlation matrices from NHanalyAlignBehavior
%%% 2: All statistically classified structures from NHanalyAlignBehavior
%%% Otherwise, if running with multiple animals, the inputs are the
%%% analyzed files generated from THIS program from each animal

global gui_KomiyamaLabHub

dendsubtract = get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'value');
dendexclude = get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'value');

if isempty(strfind(inputname(1), 'SpineCorrelationTimecourse'))
    %%% Define the inputs
    
    Correlations = varargin{1};
    StatClass = varargin{2};
    firstdatainput = 3;
    
    if length(Correlations)<14
        Correlations{14} = [];
    end
    
    %%%
%     MovementSpineDataToUse = StatClass.MovementSpines;
%     MovementSpineDataToUse = LiberalSpines;
%     CausalMovementDataToUse = StatClass.CausalMovementSpines;
%     CausalMovementDataToUse = CausalLiberalSpines;
    %%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Set addresses for different correlations sets
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Cue_address = 1;
    Movement_address = 3; %%% row 2 is binarized movement, row 3 has a larger window
    Presuccess_address = 4; 
    Success_address = 6;  %%% row 5 is binarized rewarded movements, row 6 has a larger window
    MovementDuringCue_address = 7;
    Reward_address = 8;
    Punishment_address = 9;
    Spine1_address = 9;   %%% Actually +1, but easier to add other spine addresses to zero...
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%
    %%% Contingencies %%%
    %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    usespineclassification = 0;
    usecorrminimum = 0;
    usecuecorrminimum = 0;
    corrminimum = 0;
    cuecorrminimum = 0;
    correlatecuewithall = 1;
    useonlyspinesfromstatreldends = 0;         %%% Use only spines on MOVEMENT-RELATED dendrites (applies to spine analysis, not that of dendrites)
        useSTATdends = 0;                      %%% Provides a different contingency option for using only movement-related dendrites for just the "dendritic" portions of the analysis (i.e. not for spines)
    mindendsize = 10;                           %%% Minimum number of spines on a dendrite to be considered for analysis (probably some sensitivity to length of dendrite)
    laplaciantouse = 'Normalized';             %%% Choose 'Normalized' or 'Original'
    
    
    Choices.UseStatisticalClassification = usespineclassification;
    Choices.UseCorrMinimum = usecorrminimum;
    Choices.CorrMinimum = corrminimum;
    Choices.CueCorrMinimum = cuecorrminimum; 
    Choices.CorrelateCueWithAll = correlatecuewithall;
    Choices.UseOnlySpinesFromStatRelDends = useonlyspinesfromstatreldends;
    Choices.UseStatDends = useSTATdends;
    Choices.MinDendSize = mindendsize;
    Choices.LaplacianToUse = laplaciantouse;
    Choices.Spine1_Address = Spine1_address;
    Choices.MovementAddress = Movement_address;
    
    %%% Spine data being used: 
    
    %%% Options:
    %%% OverallSpineCorrelations
    %%% SpineCorrelations
    %%% DendSubtractedSpineCorrelations
    %%% CausalCorrelations

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Display above filters in the command window
    
    if usespineclassification
        disp('Clusters ARE being classified by function');
    else
        disp('Clusters are NOT being filtered by statistical relationship with movement');
    end
    %disp('Clusters are being filtered by dominance with cue/movement');
    
    if usecorrminimum
        disp(['Using only correlations above ', num2str(corrminimum), ' for analysis']);
    else
        disp('Not using a minimum correlation')
    end
    
    animal = regexp(varargin{firstdatainput}.Filename, ['[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}0+\d+'], 'match');
    
    disp(['File ', animal{1}, ' analyzed'])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% Initialize variables %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    CorrelationofClusters = cell(1,14);
    
    clustcorrwithcue = nan(1,14);
        nonclustcorrwithcue = nan(1,14);
    cueclustcorrwithcue = nan(1,14);
        cuenonclustcorrwithcue = nan(1,14);
    
    allspinescorrwithmov = nan(1,14);
    movspinescorrwithmov = nan(1,14);
    clustcorrwithmov = nan(1,14);
        nonclustcorrwithmov = nan(1,14);
    movclustcorrwithmov = nan(1,14);
        movnonclustcorrwithmov = nan(1,14);
        
    clustcorrwithMDC = nan(1,14);
        nonclustcorrwithMDC = nan(1,14);
    MDCclustcorrwithMDC = nan(1,14);
        MDCnonclustcorrwithMDC = nan(1,14);
        
    clustcorrwithsuc = nan(1,14);
        nonclustcorrwithsuc = nan(1,14);
    succlustcorrwithsuc = nan(1,14);
        sucnonclustcorrwithsuc = nan(1,14);
        
    clustcorrwithrew = nan(1,14);
        nonclustcorrwithrew = nan(1,14);
    rewclustcorrwithrew = nan(1,14);
        rewnonclustcorrwithrew = nan(1,14);
        
    Caus_clustcorrwithcue = nan(1,14);
        Caus_nonclustcorrwithcue = nan(1,14);
    Caus_cueclustcorrwithcue = nan(1,14);
        Caus_cuenonclustcorrwithcue = nan(1,14);
        
    Caus_clustcorrwithMDC = nan(1,14);
        Caus_nonclustcorrwithMDC = nan(1,14);
    Caus_MDCclustcorrwithMDC = nan(1,14);
        Caus_MDCnonclustcorrwithMDC = nan(1,14);

        
    Caus_clustcorrwithmov = nan(1,14);
        Caus_nonclustcorrwithmov = nan(1,14);
    Caus_movclustcorrwithmov = nan(1,14);
        Caus_movnonclustcorrwithmov = nan(1,14);
        
    Caus_clustcorrwithsuc = nan(1,14);
        Caus_nonclustcorrwithsuc = nan(1,14);
    Caus_succlustcorrwithsuc = nan(1,14);
        Caus_sucnonclustcorrwithsuc = nan(1,14);
        
    Caus_clustcorrwithrew = nan(1,14);
        Caus_nonclustcorrwithrew = nan(1,14);
    Caus_rewclustcorrwithrew = nan(1,14);
        Caus_rewnonclustcorrwithrew = nan(1,14);
        
    FractionofCueSpinesThatAreClustered = nan(1,14);
    FractionofCueSpinesThatAreNonClustered = nan(1,14);
    FractionofMovementSpinesThatAreClustered = nan(1,14);
    FractionofMovementSpinesThatAreNonClustered = nan(1,14);
    FractionofPreSuccessSpinesThatAreClustered = nan(1,14);
    FractionofSuccessSpinesThatAreClustered = nan(1,14);
    FractionofSuccessSpinesThatAreNonClustered = nan(1,14);
    FractionofMovementDuringCueSpinesThatAreClustered = nan(1,14);
    FractionofRewardSpinesThatAreClustered = nan(1,14);
    FractionofRewardSpinesThatAreNonClustered = nan(1,14);
    
    ClusteredSpines = cell(1,14);
    HSCs = cell(1,14);
    HighlyCorrelatedMovementRelatedSpines = cell(1,14);
    
    allspine_freq = nan(1,14);
    movspine_freq = nan(1,14);
    cluster_freq = nan(1,14);
    nonclustered_freq = nan(1,14);
    cue_cluster_freq = nan(1,14);
    mov_cluster_freq = nan(1,14);
    movduringcue_cluster_freq = nan(1,14);
    presuc_cluster_freq = nan(1,14);
    suc_cluster_freq = nan(1,14);
    rew_cluster_freq = nan(1,14);
    Caus_cluster_freq = nan(1,14);
    Caus_nonclustered_freq = nan(1,14);
    Caus_cue_cluster_freq = nan(1,14);
    Caus_mov_cluster_freq = nan(1,14);
    Caus_movduringcue_cluster_freq = nan(1,14);
    Caus_presuc_cluster_freq = nan(1,14);
    Caus_suc_cluster_freq = nan(1,14);
    Caus_rew_cluster_freq = nan(1,14);
    
    AllDendFreq = nan(1,14);
    MoveDendFreq = nan(1,14);
    NonMoveDendFreq = nan(1,14);
    ClustDendFreq = nan(1,14);
    NoClustDendFreq = nan(1,14);
    CueClustDendFreq = nan(1,14);
    MovClustDendFreq = nan(1,14);
    MovDuringCueClustDendFreq = nan(1,14);
    PreSucClustDendFreq = nan(1,14);
    SucClustDendFreq = nan(1,14);
    RewClustDendFreq = nan(1,14);
    NoMovClustDendFreq = nan(1,14);
    DendNumClust = cell(1,14);
    
    
    ClustAmp = nan(1,14);
    NonClusteredAmp = nan(1,14);
    Caus_ClustAmp = nan(1,14);
    Caus_NonClusteredAmp = nan(1,14);
    CueAmp = nan(1,14);
    Caus_CueAmp = nan(1,14);
    MovAmp = nan(1,14);
    Caus_MovAmp = nan(1,14);
    MovDuringCueAmp = nan(1,14);
    Caus_MovDuringCueAmp = nan(1,14);
    PreSucAmp = nan(1,14);
    Caus_PreSucAmp = nan(1,14);
    SucAmp = nan(1,14);
    Caus_SucAmp = nan(1,14);
    RewAmp = nan(1,14);
    Caus_RewAmp = nan(1,14);
    
    NumCueRelSpines = nan(1,14);
    NumMovRelSpines = nan(1,14);
    LengthofDendrites = cell(1,14);
    FractionofMovRelSpinesPerDendrite = arrayfun(@(x) x(:), nan(1,14), 'uni', false);
    MovRelSpinesPer10Microns = arrayfun(@(x) x(:), nan(1,14), 'uni', false);
    FractionofSucRelSpinesPerDendrite = arrayfun(@(x) x(:), nan(1,14), 'uni', false);
    SucRelSpinesPer10Microns = arrayfun(@(x) x(:), nan(1,14), 'uni', false);    
    NumCueORMovRelSpines = nan(1,14);
    NumPreSucRelSpines = nan(1,14);
    NumSucRelSpines = nan(1,14);
    NumMovDuringCueRelSpines = nan(1,14);
    NumRewRelSpines = nan(1,14);
    NumCausalCueSpines = nan(1,14);
    NumCausalMovSpines = nan(1,14);
    NumCausalSucSpines = nan(1,14);
    NumCausalRewSpines = nan(1,14);
    
    NumHSCs = nan(1,14);
    NumClustSpines = nan(1,14);
    NumClustCueSpines = nan(1,14);
    NumClustMovSpines = nan(1,14);
    NumClustMixSpines = nan(1,14);
    NumClustPreSucSpines = nan(1,14);
    NumClustSucSpines = nan(1,14);
    NumClustMovDuringCueSpines = nan(1,14);
    NumClustRewSpines = nan(1,14);
    
    NumFarClustSpines = nan(1,14);
    NumFarClustCueSpines = nan(1,14);
    NumFarClustMovSpines = nan(1,14);
    NumFarClustMixSpines = nan(1,14);
    NumFarClustPreSucSpines = nan(1,14);
    NumFarClustSucSpines = nan(1,14);
    NumFarClustMovDuringCueSpines = nan(1,14);
    NumFarClustRewSpines = nan(1,14);

    NumCausClustSpines = nan(1,14);
    NumCausClustCueSpines = nan(1,14);
    NumCausClustMovSpines = nan(1,14);
    NumCausClustMixSpines = nan(1,14);
    NumCausClustPreSucSpines = nan(1,14);
    NumCausClustSucSpines = nan(1,14);
    NumCausClustMovDuringCueSpines = nan(1,14);
    NumCausClustRewSpines = nan(1,14);
    

    MeanCueClustLength = nan(1,14);
    MaxCueClustLength = nan(1,14);
    AllMovClustLengths = cell(1,14);
    MeanMovClustLength = nan(1,14);
    MaxMovClustLength = nan(1,14);
    MeanMixClustLength = nan(1,14);
    MaxMixClustLength = nan(1,14);
    MeanPreSucClustLength = nan(1,14);
    MaxPreSucClustLength = nan(1,14);
    MeanSucClustLength = nan(1,14);
    MaxSucClustLength = nan(1,14);
    MeanMovDuringCueClustLength = nan(1,14);
    MaxMovDuringCueClustLength = nan(1,14);
    MeanRewClustLength = nan(1,14);
    MaxRewClustLength = nan(1,14);
    MeanAllClustLength = nan(1,14);
    MaxAllClustLength = nan(1,14);
    
    MeanFarCueClustLength = nan(1,14);
    MeanFarMovClustLength = nan(1,14);
    MeanFarMixClustLength = nan(1,14);
    MeanFarPreSucClustLength = nan(1,14);
    MeanFarSucClustLength = nan(1,14);
    MeanFarMovDuringCueClustLength = nan(1,14);
    MeanFarRewClustLength = nan(1,14);
    MeanAllFarClustLength = nan(1,14);

    MeanCausalCueClustLength = nan(1,14);
    MaxCausalCueClustLength = nan(1,14);
    MeanCausalMovClustLength = nan(1,14);
    MaxCausalMovClustLength = nan(1,14);
    MeanCausalSucClustLength = nan(1,14);
    MaxCausalSucClustLength = nan(1,14);
    MeanCausalRewClustLength = nan(1,14);
    MaxCausalRewClustLength = nan(1,14);
    MeanAllCausalClustLength = nan(1,14);
    MaxAllCausalClustLength = nan(1,14);
    
    MovSpinetoNearestMovSpine = cell(1,14);
    NextClosest = cell(1,14);
    ThirdClosest = cell(1,14);
    FourthClosest = cell(1,14);
    CorrwithNearestMovSpine = cell(1,14);
    CorrwithFarthestMovSpine = cell(1,14);
    AllCorrwithNearbyMetaClusters = cell(1,14);
    AllCorrwithDistantMetaClusters = cell(1,14);
    MovSpinetoNearestFuncClustMovSpine = cell(1,14);
    CorrofNearestMetaCluster = cell(1,14);
    CorrofNextMetaCluster = cell(1,14);
    CorrofThirdMetaCluster = cell(1,14);
    CorrofFourthMetaCluster = cell(1,14);
    RandomMovementPairCorr = cell(1,14);
    MovSpinetoNextFuncClustMovSpine = cell(1,14);
    MovSpinetoThirdFuncClustMovSpine = cell(1,14);
    MovSpinetoFourthFuncClustMovSpine = cell(1,14);
    FuncClustMovSpinetoNearestFuncClustMovSpine = cell(1,14);
    NearestHighCorrMovSpine = cell(1,14);
    NextClosestFuncClustMovSpine = cell(1,14);
    NextClosestHighCorrMovSpine = cell(1,14);
    ThirdClosestFuncClustMovSpine = cell(1,14);
    ThirdClosestHighCorrMovSpine = cell(1,14);
    FourthClosestFuncClustMovSpine = cell(1,14);
    FourthClosestHighCorrMovSpine = cell(1,14);
    
    DistanceBetweenAllSpines = cell(1,14);
        CorrelationBetweenAllSpines = cell(1,14);
        CorrelationBetweenAllSpinesMovePeriods = cell(1,14);
        CorrelationBetweenAllSpinesStillPeriods = cell(1,14);
        MeanCorrelationBetweenAllSpines = cell(1,14);
        AdjacencyValuesforAllSpines = cell(1,14);
        SharedPairwiseCorrelationValuesforAllSpines = cell(1,14);
        SharedPairwiseReliabilityValuesforAllSpines = cell(1,14);
    DistanceBetweenCueSpines = cell(1,14);
    MeanDistanceBetweenCueSpines = nan(1,14);
    DistanceBetweenMovementSpines = cell(1,14);
    MeanDistanceBetweenMovementSpines = nan(1,14);
        CorrelationBetweenMovementSpines = cell(1,14);
        CorrelationBetweenMovementSpinesMovePeriods = cell(1,14);
        CorrelationBetweenMovementSpinesStillPeriods = cell(1,14);
        MeanCorrelationBetweenMovementSpines = cell(1,14);
    DistanceBetweenPreSuccessSpines = cell(1,14);
    MeanDistanceBetweenPreSuccessSpines = nan(1,14);
        CorrelationBetweenPreSuccessSpines = cell(1,14);
    DistanceBetweenSuccessSpines = cell(1,14);
    MeanDistanceBetweenSuccessSpines = nan(1,14);
        CorrelationBetweenSuccessSpines = cell(1,14);
        CorrelationBetweenSuccessSpinesMovePeriods = cell(1,14);
        CorrelationBetweenSuccessSpinesStillPeriods = cell(1,14);
        MeanCorrelationBetweenSuccessSpines = cell(1,14);    
    DistanceBetweenMovementDuringCueSpines = cell(1,14);
    MeanDistanceBetweenMovementDuringCueSpines = nan(1,14);
    DistanceBetweenRewardSpines = cell(1,14);
    MeanDistanceBetweenRewardSpines = nan(1,14);
    CorrelationBetweenAlloDendriticSpines = cell(1,14);
    DistanceBetweenFarSpines = cell(1,14);
    CorrelationBetweenAllodendriticMovementSpines = cell(1,14);
    DistanceBetweenFarMovementSpines = cell(1,14);
    DistanceBetweenBranchMoveSpines = cell(1,14);
    DistanceBetweenAllBranchSpines = cell(1,14);
    CorrelationBetweenAllBranchSpines = cell(1,14);
    CorrelationBetweenBranchMoveSpines = cell(1,14);
    DistanceBetweenBranchSuccessSpines = cell(1,14);
    CorrelationBetweenBranchSuccessSpines = cell(1,14);
    
    ClusteredSpines_CorrwithDend = nan(1,14);
    FilteredClusteredSpines_CorrwithDend = nan(1,14);
    NonClusteredSpines_CorrwithDend = nan(1,14);
    CausalClusteredSpines_CorrwithDend = nan(1,14);
    FilteredCausalClusteredSpines_CorrwithDend = nan(1,14);
    NonCausalClusteredSpines_CorrwithDend = nan(1,14);
    CueRelClusteredSpines_CorrwithDend = nan(1,14);
    MovRelClusteredSpines_CorrwithDend = nan(1,14);
    PreSucRelClusteredSpines_CorrwithDend = nan(1,14);
    SucRelClusteredSpines_CorrwithDend = nan(1,14);
    MovDuringCueRelClusteredSpines_CorrwithDend = nan(1,14);
    RewRelClusteredSpines_CorrwithDend = nan(1,14);
    CueRelCausalClusteredSpines_CorrwithDend = nan(1,14);
    MovRelCausalClusteredSpines_CorrwithDend = nan(1,14);
    SucRelCausalClusteredSpines_CorrwithDend = nan(1,14);
    RewRelCausalClusteredSpines_CorrwithDend = nan(1,14);

    SpatioTemporalAdjacencyMatrix = cell(1,14);
    Spatial_Deg = cell(1,14);
    Temporal_Deg = cell(1,14);
    Spatiotemporal_Deg = cell(1,14);
    Dend_SpatTemp_Deg = cell(1,14);
    Spatiotemporal_Laplacian = cell(1,14);
    Spatiotemporal_Overlap = cell(1,14);
    MovementCorrelationsforAllSpinesonDend = cell(1,14);
    SpatialDegree_vs_Movement = cell(1,14);
    TemporalDegree_vs_Movement = cell(1,14);
    SpatiotemporalDegree_vs_Movement = cell(1,14);
    InterspineMovementCorrelation = cell(1,14);
    InterspineMovementReliability = cell(1,14);
    DendClust_Deg = cell(1,14);
    MeanSpatialDegreeofCueSpines = nan(1,14);
    MeanTemporalDegreeofCueSpines = nan(1,14);
    MeanSpatioTemporalDegreeofCueSpines = nan(1,14);
    MeanSpatialDegreeofMovementSpines = nan(1,14);
    MeanTemporalDegreeofMovementSpines = nan(1,14);
    MeanSpatioTemporalDegreeofMovementSpines = nan(1,14);
    MeanSpatialDegreeofMDCSpines = nan(1,14);
    MeanTemporalDegreeofMDCSpines = nan(1,14);
    MeanSpatioTemporalDegreeofMDCSpines = nan(1,14);
    MeanSpatialDegreeofPreSuccessSpines = nan(1,14);
    MeanTemporalDegreeofPreSuccessSpines = nan(1,14);
    MeanSpatioTemporalDegreeofPreSuccessSpines = nan(1,14);
    MeanSpatialDegreeofSuccessSpines = nan(1,14);
    MeanTemporalDegreeofSuccessSpines = nan(1,14);
    MeanSpatioTemporalDegreeofSuccessSpines = nan(1,14);
    MeanSpatialDegreeofRewardSpines = nan(1,14);
    MeanTemporalDegreeofRewardSpines = nan(1,14);
    MeanSpatioTemporalDegreeofRewardSpines = nan(1,14);
    
    NumberofImagedSpines = nan(1,14);
    NumClusters = nan(1,14);
    NumCausalClusters = nan(1,14);
    MeanNumberofSpinesinEachCluster = nan(1,14);
    MeanNumberofSpinesinEachCausalCluster = nan(1,14);
    NumMovClusters = nan(1,14);
    NumberofSpinesinEachMovCluster = cell(1,14);
    
    FractionofClusterThatsMR = nan(1,14);
    FractionofCausalClusterThatsMR = nan(1,14);
    SpinesonCueDend = cell(1,14);
    SpinesonMovementDend = cell(1,14);
    SpinesonPreSuccessDend = cell(1,14);
    SpinesonSuccessDend = cell(1,14);
    SpinesonMovementDuringCueDend = cell(1,14);
    SpinesonRewardDend = cell(1,14);
    PercentCueRelDends = nan(1,14);
    PercentMovRelDends = nan(1,14);
    PercentPreSucRelDends = nan(1,14);
    PercentSucRelDends = nan(1,14);
    PercentMovDuringCueRelDends = nan(1,14);
    PercentRewRelDends = nan(1,14);
    Temporal_Laplacian = cell(1,14);
    Spatial_Deg = cell(1,14);
        Dend_Spat_Deg = cell(1,14);
        Dend_Temp_Deg = cell(1,14);
        Spatial_FirstEigenvector = cell(1,14);
    Temporal_Deg = cell(1,14);
        end_Temp_Deg = cell(1,14);
        Temporal_FirstEigenvector = cell(1,14);
    SpatioTemporalFiedler = cell(1,14);
    SpatioTemporalPartition = cell(1,14);
    SpatioTemporal_FirstEigenvector = cell(1,14);
    AllSpineReliability = cell(1,14);
    MovementSpineReliability = cell(1,14);
    
    for i = 1:length(StatClass)
        if ~isempty(StatClass{i})
            StatClass{i}.CueORMovementSpines = logical(StatClass{i}.MovementSpines+StatClass{i}.CueSpines);
            StatClass{i}.DendSub_CueORMovementSpines = logical(StatClass{i}.DendSub_MovementSpines+StatClass{i}.DendSub_CueSpines);
        else
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%
    
    for i = firstdatainput:length(varargin) 
        
        session = varargin{i}.Session;
        SpineToSpineDistance = varargin{i}.DistanceHeatMap;
            tempC = SpineToSpineDistance;
            tempD = SpineToSpineDistance';
            tempC(isnan(tempC) & ~isnan(tempD)) = tempD(isnan(tempC) & ~isnan(tempD));
            DistanceMap = tempC;
        NumClusters(1,session) = 0;
        NumCausalClusters(1,session) = 0;
        
        if varargin{i}.NumberofSpines ~= length(varargin{i}.dF_over_F)
            varargin{i}.NumberofSpines = length(varargin{i}.dF_over_F);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        denominator = varargin{i}.NumberofSpines;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        NumberofImagedSpines(1,session) = varargin{i}.NumberofSpines;

        if NumberofImagedSpines(1,session) ~= length(varargin{i}.dF_over_F);
            NumberofImagedSpines(1,session) = length(varargin{i}.dF_over_F);
        end

        for d = 1:varargin{i}.NumberofDendrites;
            LengthofDendrites{session}(1,d) = sum(varargin{i}.DendriteLengthValues{d});
        end
        
        if ~isempty(Correlations{session})
           
            if isfield(varargin{i}, 'SpineDendriteGrouping')
                for d = 1:varargin{i}.NumberofDendrites
                    firstspine = varargin{i}.SpineDendriteGrouping{d}(1);
                    lastspine = varargin{i}.SpineDendriteGrouping{d}(end);
                    if d == varargin{i}.NumberofDendrites
                        if lastspine ~= varargin{i}.NumberofSpines
                            lastspine = varargin{i}.NumberofSpines;
                        end
                    end
                    SpinesonCueDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.CueDends(d);
                    SpinesonMovementDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.MovementDends(d);
                    SpinesonPreSuccessDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.PreSuccessDends(d);
                    SpinesonSuccessDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.SuccessDends(d);
                    SpinesonMovementDuringCueDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.MovementDuringCueDends(d);
                    SpinesonRewardDend{session}(firstspine:lastspine) = ones(length(firstspine:lastspine),1)*StatClass{session}.RewardDends(d);
                end
            else
                if varargin{i}.NumberofDendrites ==1
                    varargin{i}.SpineDendriteGrouping = {1:varargin{i}.NumberofSpines};
                    SpinesonCueDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.CueDends;
                    SpinesonMovementDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.MovementDends;
                    SpinesonPreSuccessDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.PreSuccessDends;
                    SpinesonSuccessDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.SuccessDends;
                    SpinesonMovementDuringCueDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.MovementDuringCueDends;
                    SpinesonRewardDend{session} = ones(varargin{i}.NumberofSpines,1).*StatClass{session}.RewardDends;
                    disp(['File ', varargin{i}.Filename, ' did not have spine-dendrite grouping information, but can be correctly filled in']);
                else
                    disp(['File ', varargin{i}.Filename, ' does NOT have necessary spine-dendrite grouping info!']);
                end
            end
            
            PercentCueRelDends(1,session) = sum(StatClass{session}.CueDends)/varargin{i}.NumberofDendrites;
            PercentMovRelDends(1,session) = sum(StatClass{session}.MovementDends)/varargin{i}.NumberofDendrites;
            PercentPreSucRelDends(1,session) = sum(StatClass{session}.PreSuccessDends)/varargin{i}.NumberofDendrites;
            PercentSucRelDends(1,session) = sum(StatClass{session}.SuccessDends)/varargin{i}.NumberofDendrites;
            PercentMovDuringCueRelDends(1,session) = sum(StatClass{session}.MovementDuringCueDends)/varargin{i}.NumberofDendrites;
            PercentRewRelDends(1,session) = sum(StatClass{session}.RewardDends)/varargin{i}.NumberofDendrites;
            
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%% Data choice (how to handle bAPs) %%%%%%%%%%%%%%%%
            %%%%%%%%%%%% Selection of Movement Spine Types %%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       
            if dendexclude
                SessionCorrData = Correlations{session}.SpineCorrelations;
                SessionMovCorrData = Correlations{session}.SpineDuringMovePeriods;
                SessionStillCorrData = Correlations{session}.SpineDuringStillPeriods;
                CueSpines = StatClass{session}.CueSpines;
                MovementSpines = StatClass{session}.MovementSpines;
                MovementDuringCueSpines = StatClass{session}.MovementDuringCueSpines;
                PreSuccessSpines = StatClass{session}.PreSuccessSpines;
                SuccessSpines = StatClass{session}.SuccessSpines;
                RewardSpines = StatClass{session}.RewardSpines;
                CueORMovementSpines = StatClass{session}.CueORMovementSpines;
            elseif dendsubtract
                SessionCorrData = Correlations{session}.DendSubtractedSpineCorrelations;
                SessionMovCorrData = Correlations{session}.SpineDuringMovePeriods;
                SessionStillCorrData = Correlations{session}.SpineDuringStillPeriods;
                CueSpines = StatClass{session}.DendSub_CueSpines;
                MovementSpines = StatClass{session}.DendSub_MovementSpines; %%%%%%%%%%%%%%%%%%%% ****************************************************************** Important choice!!
                MovementDuringCueSpines = StatClass{session}.DendSub_MovementDuringCueSpines;
                PreSuccessSpines = StatClass{session}.DendSub_PreSuccessSpines;
                SuccessSpines = StatClass{session}.DendSub_SuccessSpines;
                RewardSpines = StatClass{session}.DendSub_RewardSpines;
                CueORMovementSpines = StatClass{session}.DendSub_CueORMovementSpines;
            else
                SessionCorrData = Correlations{session}.OverallSpineCorrelations;
                SessionMovCorrData = Correlations{session}.SpineDuringMovePeriods;
                SessionStillCorrData = Correlations{session}.SpineDuringStillPeriods;
                CueSpines = StatClass{session}.CueSpines;
                MovementSpines = StatClass{session}.MovementSpines;
                MovementDuringCueSpines = StatClass{session}.MovementDuringCueSpines;
                PreSuccessSpines = StatClass{session}.PreSuccessSpines;
                SuccessSpines = StatClass{session}.SuccessSpines;
                RewardSpines = StatClass{session}.RewardSpines;
                CueORMovementSpines = StatClass{session}.CueORMovementSpines;
            end
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%% Spectral analysis of clustering %%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [SpectralData] = SpectralClustering(varargin{i}, SessionCorrData, StatClass, Choices);

            SpatioTemporalAdjacencyMatrix{session} = blkdiag(SpectralData.SpatioTemporalAdjacencyMatrix{:});
            Spatial_Deg{session} = SpectralData.Spatial_Deg;
            Temporal_Deg{session} = SpectralData.Temporal_Deg;
            Spatiotemporal_Deg{session} = SpectralData.Spatiotemporal_Deg;
            Spatiotemporal_Overlap{session} = SpectralData.Spatiotemporal_Overlap;
            
            SpatioTemporalFiedler{session} = SpectralData.SpatioTemporalFiedler;
            
            Temporal_Laplacian{session} = SpectralData.Temporal_Laplacian;

            MeanSpatialDegreeofCueSpines(1,session) = SpectralData.MeanSpatialDegreeofCueSpines;
            MeanTemporalDegreeofCueSpines(1,session) = SpectralData.MeanTemporalDegreeofCueSpines;
            MeanSpatioTemporalDegreeofCueSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofCueSpines;
            MeanSpatialDegreeofMovementSpines(1,session) = SpectralData.MeanSpatialDegreeofMovementSpines;
            MeanTemporalDegreeofMovementSpines(1,session) = SpectralData.MeanTemporalDegreeofMovementSpines;
            MeanSpatioTemporalDegreeofMovementSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofMovementSpines;
            MeanSpatialDegreeofMDCSpines(1,session) = SpectralData.MeanSpatialDegreeofMovementDuringCueSpines;
            MeanTemporalDegreeofMDCSpines(1,session) = SpectralData.MeanTemporalDegreeofMovementDuringCueSpines;
            MeanSpatioTemporalDegreeofMDCSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofMovementDuringCueSpines;
            MeanSpatialDegreeofPreSuccessSpines(1,session) = SpectralData.MeanSpatialDegreeofPreSuccessSpines;
            MeanTemporalDegreeofPreSuccessSpines(1,session) = SpectralData.MeanTemporalDegreeofPreSuccessSpines;
            MeanSpatioTemporalDegreeofPreSuccessSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofPreSuccessSpines;
            MeanSpatialDegreeofSuccessSpines(1,session) = SpectralData.MeanSpatialDegreeofSuccessSpines;
            MeanTemporalDegreeofSuccessSpines(1,session) = SpectralData.MeanTemporalDegreeofSuccessSpines;
            MeanSpatioTemporalDegreeofSuccessSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofSuccessSpines;
            MeanSpatialDegreeofRewardSpines(1,session) = SpectralData.MeanSpatialDegreeofRewardSpines;
            MeanTemporalDegreeofRewardSpines(1,session) = SpectralData.MeanTemporalDegreeofRewardSpines;
            MeanSpatioTemporalDegreeofRewardSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofRewardSpines;
            
            Dend_Spat_Deg{session} = SpectralData.Dend_Spat_Deg;
            Dend_Temp_Deg{session} = SpectralData.Dend_Temp_Deg;
            Dend_SpatTemp_Deg{session} = SpectralData.Dend_SpatTemp_Deg;      
            
            SpatialDegree_vs_Movement{session} = SpectralData.SpatialDegree_vs_Movement;
            TemporalDegree_vs_Movement{session} = SpectralData.TemporalDegree_vs_Movement;
            SpatiotemporalDegree_vs_Movement{session} = SpectralData.SpatiotemporalDegree_vs_Movement;
            
            InterspineMovementCorrelation{session} = blkdiag(SpectralData.MeanInterspineMovementCorrelation{:});
            InterspineMovementReliability{session} = blkdiag(SpectralData.MeanInterspineMovementReliability{:});
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%
            
            if useonlyspinesfromstatreldends
                dendcheckC = reshape(SpinesonCueDend{session},1,length(SpinesonCueDend{session}));
                dendcheckM = reshape(SpinesonMovementDend{session},1,length(SpinesonMovementDend{session}));
                dendcheckPS = reshape(SpinesonPreSuccessDend{session},1,length(SpinesonPreSuccessDend{session}));
                dendcheckS = reshape(SpinesonSuccessDend{session},1,length(SpinesonSuccessDend{session}));
                dendcheckMDC = reshape(SpinesonMovementDuringCueDend{session},1,length(SpinesonMovementDuringCueDend{session}));
                dendcheckR = reshape(SpinesonRewardDend{session},1,length(SpinesonRewardDend{session}));
                dendcheck = nansum([dendcheckC; dendcheckM; dendcheckPS; dendcheckS; dendcheckMDC; dendcheckR]);
                dendcheck(dendcheck~=0) = 1;
%                 dendcheck(dendcheck==0)= nan;
%                 dendcheckC(dendcheckC==0) = nan;
%                 dendcheckM(dendcheckM==0) = nan;
%                 dendcheckPS(dendcheckPS==0) = nan;
%                 dendcheckS(dendcheckS==0) = nan;
%                 dendcheckMDC(dendcheckMDC==0) = nan;
%                 dendcheckR(dendcheckR==0) = nan;
            else
                dendcheck = ones(1,length(varargin{i}.deltaF)); %%% Set this variable to one to allow use of ALL spines on ALL (non just feature-related) dendrites
                dendcheckC = ones(1,length(varargin{i}.deltaF));
                dendcheckM = ones(1,length(varargin{i}.deltaF));
                dendcheckPS = ones(1,length(varargin{i}.deltaF));
                dendcheckS = ones(1,length(varargin{i}.deltaF));
                dendcheckMDC = ones(1,length(varargin{i}.deltaF));
                dendcheckR = ones(1,length(varargin{i}.deltaF));
            end
            
                CueSpines = CueSpines.*dendcheckC';
                MovementSpines = MovementSpines.*dendcheckM';
                MovementDuringCueSpines = MovementDuringCueSpines.*dendcheckMDC';
                PreSuccessSpines = PreSuccessSpines.*dendcheckPS';
                SuccessSpines = SuccessSpines.*dendcheckS';
                RewardSpines = RewardSpines.*dendcheckR';
                CueORMovementSpines = CueORMovementSpines.*dendcheck';

            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%% Set up correlation matrices %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
                corrmat = SessionCorrData(Spine1_address+1:Spine1_address+length(varargin{i}.dF_over_F),Spine1_address+1:Spine1_address+length(varargin{i}.dF_over_F));
                movcorrmat = SessionMovCorrData;
                stillcorrmat = SessionStillCorrData;
                causalmat = Correlations{session}.CausalCorrelations(Spine1_address+1:Spine1_address+length(varargin{i}.dF_over_F),Spine1_address+1:Spine1_address+length(varargin{i}.dF_over_F));
                
                samedendcorrection = DistanceMap; samedendcorrection(~isnan(samedendcorrection)) = 1;
                separatedendcorrection = DistanceMap; separatedendcorrection(~isnan(separatedendcorrection))=0; separatedendcorrection(isnan(separatedendcorrection)) = 1; 
                    separatedendcorrection(separatedendcorrection==0) = nan; separatedendcorrection = separatedendcorrection.*~eye(size(separatedendcorrection));
                    separatedendcorrection = triu(separatedendcorrection); %%% The distance matrix of spines on different dendrites was converted to a list earlier in analysis, so just taking the upper half makes it easier to find these values
                    separatedendcorrection(separatedendcorrection==0) = nan;
                samedendcorrmat = corrmat.*samedendcorrection; %%% Make all values on the same dendrites == 1, while all others are 0;
                tempcorrmat = movcorrmat; tempcorrmat(isnan(tempcorrmat)) = 0 ; tempcorrmat = tempcorrmat.*separatedendcorrection;
                separatedendcorrmat = tempcorrmat.*separatedendcorrection; %%% Make vall values on SEPARATE dendrites ==1, while all on the same ==0;
                    separatedendcorrlist = separatedendcorrmat(logical(~isnan(separatedendcorrmat)));
                samedendmovcorrmat = movcorrmat.*samedendcorrection;
                samedendstillcorrmat = stillcorrmat.*samedendcorrection;

            
                %%% set up correction for dendrites that are likely on the
                %%% same cell
                alldends = 1:varargin{i}.NumberofDendrites;
                if length(alldends)>1
                    dendcombs = nchoosek(alldends,2)+Spine1_address+length(varargin{i}.dF_over_F);
                    cellcount = 1;
                    samecell = {[]};
                    for d = 1:size(dendcombs,1)
                        dendcorrmat(1,d) = SessionCorrData(dendcombs(d,1), dendcombs(d,2));
    %                     dendcorrmat(1,d) = fakemat(dendcombs(d,1),dendcombs(d,2));
                        if dendcorrmat(1,d) > 0.75
                            if ~isempty(samecell{1})
                                if ~logical(sum(ismember(samecell{cellcount}, dendcombs(d,:))))
                                    cellcount = cellcount+1;
                                    samecell{cellcount} = [];
                                end
                            end
                            samecell{cellcount} = [samecell{cellcount}, dendcombs(d,1), dendcombs(d,2)];
                        end
                    end

                    samecell = cellfun(@(x) unique(x)-(Spine1_address+length(varargin{i}.dF_over_F)), samecell, 'uni', false);
                else
                    samecell = {[]};
                end


                DiffDendSameCell = [];
                spinesonthiscell = [];
                for sc = 1:length(samecell)
                    if ~isempty(samecell{sc})
                        spinesonthiscell{sc} = cell2mat(cellfun(@(x) cell2mat(varargin{i}.SpineDendriteGrouping(x)), samecell, 'uni', false));
                        samecellcorrectionmat = zeros(size(corrmat,1), size(corrmat,2));
                        samecellcorrectionmat(spinesonthiscell{sc}, spinesonthiscell{sc}) = 1;
                        diffDsameC = corrmat.*samecellcorrectionmat.*separatedendcorrection;
                        diffDsameC(diffDsameC==0) = nan;
                        DiffDendSameCell(:,:,sc) = diffDsameC;
                    end
                end
            
            if ~isempty(DiffDendSameCell)
                AllDiffDendSameCellCorr = logical(nansum(DiffDendSameCell,3)).*separatedendcorrmat;
                AllDiffDendSameCellCorr(AllDiffDendSameCellCorr == 0 ) = nan;
                DiffDendSameCellCorrList = AllDiffDendSameCellCorr(logical(~isnan(AllDiffDendSameCellCorr)));
            else
                AllDiffDendSameCellCorr = [];
                DiffDendSameCellCorrList = [];
            end
            
            %%
            
            MovementSpineReliability{session} = StatClass{session}.MovementSpineReliability;
            AllSpineReliability{session} = StatClass{session}.AllSpineReliability;
            
                
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%% Binary Classification of Clusters %%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
   
            [HSCs{1,session}, ClusteredSpines{1,session}, CorrelationofClusts, FarClusteredSpines, CausalClusteredSpines] = binaryclusterclass(varargin{i}, corrmat, causalmat);
                
            CorrelationofClusters{session} = CorrelationofClusts;
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Find indices for movement- and cue-related clusters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            [HSCInfo]...
                = findclusterind(HSCs{1,session}, StatClass{session}, Spine1_address);
            
            hsc_ind = HSCInfo.cluster_ind(~isnan(dendcheck(HSCInfo.cluster_ind-Spine1_address)));
            
            %%%% Correlation indices for synapse-only events
            
               [ClusterInfo]...
                = findclusterind(ClusteredSpines{1,session}, StatClass{session}, Spine1_address);
            
            NumSpinesinCluster = ClusterInfo.NumSpinesinCluster;
            cluster_ind = ClusterInfo.cluster_ind(~isnan(dendcheck(ClusterInfo.cluster_ind-Spine1_address)));
            cue_cluster_ind = ClusterInfo.cue_cluster_ind(~isnan(dendcheckC(ClusterInfo.cue_cluster_ind-Spine1_address)));
            mov_cluster_ind = ClusterInfo.mov_cluster_ind(~isnan(dendcheckM(ClusterInfo.mov_cluster_ind-Spine1_address)));
            mix_cluster_ind = ClusterInfo.mix_cluster_ind(~isnan(dendcheck(ClusterInfo.mix_cluster_ind-Spine1_address)));
            presuc_cluster_ind = ClusterInfo.presuc_cluster_ind(~isnan(dendcheckPS(ClusterInfo.presuc_cluster_ind-Spine1_address)));
            suc_cluster_ind = ClusterInfo.suc_cluster_ind(~isnan(dendcheckS(ClusterInfo.suc_cluster_ind-Spine1_address)));
            movduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind(~isnan(dendcheckMDC(ClusterInfo.movduringcue_cluster_ind-Spine1_address)));
            rew_cluster_ind = ClusterInfo.rew_cluster_ind(~isnan(dendcheckR(ClusterInfo.rew_cluster_ind-Spine1_address)));
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Repeat the above for "clusters" on separate dends.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%% Correlation indices for synapse-only events
            
               [ClusterInfo]...
                = findclusterind(FarClusteredSpines, StatClass{session}, Spine1_address);
            
            NumSpinesinFarCluster = ClusterInfo.NumSpinesinCluster;
            Farcluster_ind = ClusterInfo.cluster_ind(~isnan(dendcheck(ClusterInfo.cluster_ind-Spine1_address)));
            Farcue_cluster_ind = ClusterInfo.cue_cluster_ind(~isnan(dendcheckC(ClusterInfo.cue_cluster_ind-Spine1_address)));
            Farmov_cluster_ind = ClusterInfo.mov_cluster_ind(~isnan(dendcheckM(ClusterInfo.mov_cluster_ind-Spine1_address)));
            Farmix_cluster_ind = ClusterInfo.mix_cluster_ind(~isnan(dendcheck(ClusterInfo.mix_cluster_ind-Spine1_address)));
            Farpresuc_cluster_ind = ClusterInfo.presuc_cluster_ind(~isnan(dendcheckPS(ClusterInfo.presuc_cluster_ind-Spine1_address)));
            Farsuc_cluster_ind = ClusterInfo.suc_cluster_ind(~isnan(dendcheckS(ClusterInfo.suc_cluster_ind-Spine1_address)));
            Farmovduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind(~isnan(dendcheckMDC(ClusterInfo.movduringcue_cluster_ind-Spine1_address)));
            Farrew_cluster_ind = ClusterInfo.rew_cluster_ind(~isnan(dendcheckR(ClusterInfo.rew_cluster_ind-Spine1_address)));
            
            %%   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            %%%% Repeat the above for causal correlations
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%% Uncomment the following section to separate cue- and
            %%%% movement-correlated clusters
            
               [ClusterInfo]...
                = findclusterind(CausalClusteredSpines, StatClass{session}, Spine1_address);
            
            NumSpinesinCausalCluster = ClusterInfo.NumSpinesinCluster;
            Caus_cluster_ind = ClusterInfo.cluster_ind(~isnan(dendcheck(ClusterInfo.cluster_ind-Spine1_address)));
            Caus_cue_cluster_ind = ClusterInfo.cue_cluster_ind(~isnan(dendcheckC(ClusterInfo.cue_cluster_ind-Spine1_address)));
            Caus_mov_cluster_ind = ClusterInfo.mov_cluster_ind(~isnan(dendcheckM(ClusterInfo.mov_cluster_ind-Spine1_address)));
            Caus_mix_cluster_ind = ClusterInfo.mix_cluster_ind(~isnan(dendcheck(ClusterInfo.mix_cluster_ind-Spine1_address)));
            Caus_presuc_cluster_ind = ClusterInfo.presuc_cluster_ind(~isnan(dendcheckPS(ClusterInfo.presuc_cluster_ind-Spine1_address)));
            Caus_suc_cluster_ind = ClusterInfo.suc_cluster_ind(~isnan(dendcheckS(ClusterInfo.suc_cluster_ind-Spine1_address)));
            Caus_movduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind(~isnan(dendcheckMDC(ClusterInfo.movduringcue_cluster_ind-Spine1_address)));
            Caus_rew_cluster_ind = ClusterInfo.rew_cluster_ind(~isnan(dendcheckR(ClusterInfo.rew_cluster_ind-Spine1_address)));

                     
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%% End index-finding section %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Main variables
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            ClusteredSpines{1,session} = ClusteredSpines{1,session}(~cellfun(@isempty,ClusteredSpines{1,session}));
            CausalClusteredSpines = CausalClusteredSpines(~cellfun(@isempty,CausalClusteredSpines));

            NumClusters(1,session) = length(ClusteredSpines{1,session})/denominator;
            NumCausalClusters(1,session) = length(CausalClusteredSpines);
           
            NumSpinesinCluster(NumSpinesinCluster==0) = NaN;
            MeanNumberofSpinesinEachCluster(1,session) = nanmean(NumSpinesinCluster);
            NumSpinesinCausalCluster(NumSpinesinCausalCluster==0) = NaN;
            MeanNumberofSpinesinEachCausalCluster(1,session) = nanmean(NumSpinesinCausalCluster);
            ClusterswithMovRelSpines = ClusteredSpines{1,session}(cellfun(@(x) x(:), cellfun(@(x) sum(x)>1, cellfun(@(x) ismember(x,mov_cluster_ind-Spine1_address), ClusteredSpines{1,session}, 'UniformOutput', false), 'Uniformoutput', false)));
                        
            if ~isempty(ClusteredSpines{1,session}) && ~isempty(mov_cluster_ind)
                NumberofSpinesinEachMovCluster{1,session} = cell2mat(cellfun(@length, cellfun(@(x,y) x(y), ClusterswithMovRelSpines, cellfun(@(x) ismember(x,mov_cluster_ind-Spine1_address), ClusterswithMovRelSpines, 'Uni', false), 'Uni', false), 'Uni', false));
                NumMovClusters(1,session) = sum(cell2mat(cellfun(@(x) sum(x)>1, cellfun(@(x) ismember(x,mov_cluster_ind-Spine1_address), ClusteredSpines{1,session}, 'UniformOutput', false), 'Uniformoutput', false)))/denominator;  %%% Check if each reported cluster is movement-related
            else
                NumberofSpinesinEachMovCluster{1,session} = NaN;
                NumMovClusters(1,session) = 0;
            end            
            
            FractionofCueSpinesThatAreClustered(1,session) = length(cue_cluster_ind)/length(find(CueSpines));
            FractionofCueSpinesThatAreNonClustered(1,session) = length((setdiff(find(CueSpines),cue_cluster_ind-Spine1_address)))/length(find(CueSpines));
            FractionofMovementSpinesThatAreClustered(1,session) = length(mov_cluster_ind)/length(find(MovementSpines));
            FractionofMovementSpinesThatAreNonClustered(1,session) = length((setdiff(find(MovementSpines),mov_cluster_ind-Spine1_address)))/length(find(MovementSpines));
            FractionofPreSuccessSpinesThatAreClustered(1,session) = length(presuc_cluster_ind)/length(find(PreSuccessSpines));
            FractionofSuccessSpinesThatAreClustered(1,session) = length(suc_cluster_ind)/length(find(SuccessSpines));
            FractionofSuccessSpinesThatAreNonClustered(1,session) = length((setdiff(find(SuccessSpines),suc_cluster_ind-Spine1_address)))/length(find(SuccessSpines));
            FractionofMovementDuringCueSpinesThatAreClustered(1,session) = length(movduringcue_cluster_ind)/length(find(MovementDuringCueSpines));
            FractionofRewardSpinesThatAreClustered(1,session) = length(rew_cluster_ind)/length(find(RewardSpines));
            FractionofRewardSpinesThatAreNonClustered(1,session) = length((setdiff(find(RewardSpines),rew_cluster_ind-Spine1_address)))/length(find(RewardSpines));
            
            HighlyCorrelatedMovementRelatedSpines{1,session} = mov_cluster_ind-Spine1_address;
            
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Find number of spines in each category
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            
            
            NumCueRelSpines(1,session) = sum(CueSpines)/denominator;
            NumMovRelSpines(1,session) = sum(MovementSpines)/denominator;
                for d = 1:length(varargin{i}.SpineDendriteGrouping)
                    FractionofMovRelSpinesPerDendrite{session}(1,d) = sum(MovementSpines(varargin{i}.SpineDendriteGrouping{d}))/length(varargin{i}.SpineDendriteGrouping{d});
                    MovRelSpinesPer10Microns{session}(1,d) = sum(MovementSpines(varargin{i}.SpineDendriteGrouping{d}))/(sum(varargin{i}.DendriteLengthValues{d})/10);
                    FractionofSucRelSpinesPerDendrite{session}(1,d) = sum(SuccessSpines(varargin{i}.SpineDendriteGrouping{d}))/length(varargin{i}.SpineDendriteGrouping{d});
                    SucRelSpinesPer10Microns{session}(1,d) = sum(SuccessSpines(varargin{i}.SpineDendriteGrouping{d}))/(sum(varargin{i}.DendriteLengthValues{d})/10);
                end
            NumCueORMovRelSpines(1,session) = sum(CueORMovementSpines)/denominator;
            NumPreSucRelSpines(1,session) = sum(PreSuccessSpines)/denominator;
            NumSucRelSpines(1,session) = sum(SuccessSpines)/denominator;
            NumMovDuringCueRelSpines(1,session) = sum(MovementDuringCueSpines)/denominator;
            NumRewRelSpines(1,session) = sum(RewardSpines)/denominator;
            NumCausalMovSpines(1,session) = sum(StatClass{session}.CausalMovementSpines)/denominator;
            
            NumHSCs(1,session) = length(hsc_ind.*dendcheck(hsc_ind-Spine1_address)')/denominator;
            NumClustSpines(1,session) = length(cluster_ind.*dendcheck(cluster_ind-Spine1_address)')/denominator;
            NumClustCueSpines(1,session) = length(cue_cluster_ind.*dendcheckC(cue_cluster_ind-Spine1_address)')/denominator;
            NumClustMovSpines(1,session) = length(mov_cluster_ind.*dendcheckM(mov_cluster_ind-Spine1_address)')/denominator;
            NumClustMixSpines(1,session) = length(mix_cluster_ind.*dendcheck(mix_cluster_ind-Spine1_address)')/denominator;
            NumClustPreSucSpines(1,session) = length(presuc_cluster_ind.*dendcheckPS(presuc_cluster_ind-Spine1_address)')/denominator;
            NumClustSucSpines(1,session) = length(suc_cluster_ind.*dendcheckS(suc_cluster_ind-Spine1_address)')/denominator;
            NumClustMovDuringCueSpines(1,session) = length(movduringcue_cluster_ind.*dendcheckMDC(movduringcue_cluster_ind-Spine1_address)')/denominator;
            NumClustRewSpines(1,session) = length(rew_cluster_ind.*dendcheckR(rew_cluster_ind-Spine1_address)')/denominator;
            
            NumFarClustSpines(1,session) = length(Farcluster_ind.*dendcheck(Farcluster_ind-Spine1_address)')/denominator;
            NumFarClustCueSpines(1,session) = length(Farcue_cluster_ind.*dendcheckC(Farcue_cluster_ind-Spine1_address)')/denominator;
            NumFarClustMovSpines(1,session) = length(Farmov_cluster_ind.*dendcheckM(Farmov_cluster_ind-Spine1_address)')/denominator;
            NumFarClustMixSpines(1,session) = length(Farmix_cluster_ind.*dendcheck(Farmix_cluster_ind-Spine1_address)')/denominator;
            NumFarClustPreSucSpines(1,session) = length(Farpresuc_cluster_ind.*dendcheckPS(Farpresuc_cluster_ind-Spine1_address)')/denominator;
            NumFarClustSucSpines(1,session) = length(Farsuc_cluster_ind.*dendcheck(Farsuc_cluster_ind-Spine1_address)')/denominator;
            NumFarClustMovDuringCueSpines(1,session) = length(Farmovduringcue_cluster_ind.*dendcheckMDC(Farmovduringcue_cluster_ind-Spine1_address)')/denominator;
            NumFarClustRewSpines(1,session) = length(Farrew_cluster_ind.*dendcheckR(Farrew_cluster_ind-Spine1_address)')/denominator;

            NumCausClustSpines(1,session) = length(Caus_cluster_ind)/denominator;
            NumCausClustCueSpines(1,session) = length(Caus_cue_cluster_ind)/denominator;
            NumCausClustMovSpines(1,session) = length(Caus_mov_cluster_ind)/denominator;
            NumCausClustMixSpines(1,session) = length(Caus_mix_cluster_ind)/denominator;
            NumCausClustPreSucSpines(1,session) = length(Caus_presuc_cluster_ind)/denominator;
            NumCausClustSucSpines(1,session) = length(Caus_suc_cluster_ind)/denominator;
            NumCausClustMovDuringCueSpines(1,session) = length(Caus_movduringcue_cluster_ind)/denominator;
            NumCausClustRewSpines(1,session) = length(Caus_rew_cluster_ind)/denominator;
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Distances between clustered spines
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            val = 1;
            AllClusterDistances = cell(1,length(ClusteredSpines{1,session}));
            CueClusterDistances = [];
            MovClusterDistances = [];
            MixClusterDistances = [];
            PreSucClusterDistances = [];
            SucClusterDistances = [];
            MovDuringCueClusterDistances = [];
            RewClusterDistances = [];
            
            %%% regular clusters
            
            for CS = 1:length(ClusteredSpines{1,session})
                    
                    spinecombos = nchoosek(ClusteredSpines{1,session}{CS}, 2); %%% Find all possible combinations of spines in a cluster
                    all_clust_distances = zeros(1,size(spinecombos,1));
                    cue_clust_distances = [];
                    mov_clust_distances = [];
                    mix_clust_distances = [];
                    presuc_clust_distances = [];
                    suc_clust_distances = [];
                    movduringcue_clust_distances = [];
                    rew_clust_distances = [];
                    
                    for n = 1:size(spinecombos,1)
                        all_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        if sum(CueSpines(spinecombos(n,1:2))) == 2;
                            cue_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            cue_clust_distances(1,n) = nan;
                        end
                        if sum(MovementSpines(spinecombos(n,1:2))) == 2;
                            mov_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            mov_clust_distances(1,n) = nan;
                        end
                        if sum([sum(CueSpines(spinecombos(n,1:2))), sum(MovementSpines(spinecombos(n,1:2)))]) >= 2
                            mix_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            mix_clust_distances(1,n) = nan;
                        end
                        if sum(PreSuccessSpines(spinecombos(n,1:2))) == 2
                            presuc_clust_distances(1,n) = DistanceMap(spinecombos(n,1),spinecombos(n,2));
                        else
                            presuc_clust_distances(1,n) = nan;
                        end
                        if sum(SuccessSpines(spinecombos(n,1:2))) == 2;
                            suc_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            suc_clust_distances(1,n) = nan;
                        end
                        if sum(MovementDuringCueSpines(spinecombos(n,1:2))) == 2;
                            movduringcue_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            movduringcue_clust_distances(1,n) = nan;
                        end
                        if sum(RewardSpines(spinecombos(n,1:2))) == 2;
                            rew_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            rew_clust_distances(1,n) = nan;
                        end
                    end
                AllClusterDistances{val} = all_clust_distances;
                CueClusterDistances{val} = cue_clust_distances;
                MovClusterDistances{val} = mov_clust_distances;
                MixClusterDistances{val} = mix_clust_distances;
                PreSucClusterDistances{val} = presuc_clust_distances;
                SucClusterDistances{val} = suc_clust_distances;
                MovDuringCueClusterDistances{val} = movduringcue_clust_distances;
                RewClusterDistances{val} = rew_clust_distances;
                val = val+1;
            end
            
            
            MeanCueClustLength(1,session) = nanmean(cell2mat(CueClusterDistances));
            if ~isempty(cell2mat(CueClusterDistances))
                MaxCueClustLength(1,session) = nanmax(cell2mat(CueClusterDistances));
            else
                MaxCueClustLength(1,session) = NaN;
            end
            AllMovClustLengths{session} = cell2mat(MovClusterDistances);
            MeanMovClustLength(1,session) = nanmean(cell2mat(MovClusterDistances));
            if ~isempty(cell2mat(MovClusterDistances))
                MaxMovClustLength(1,session) = nanmax(cell2mat(MovClusterDistances));
            else
                MaxMovClustLength(1,session) = NaN;
            end
            MeanMixClustLength(1,session) = nanmean(cell2mat(MixClusterDistances));
            if ~isempty(cell2mat(MixClusterDistances))
                MaxMixClustLength(1,session) = nanmean(cell2mat(MixClusterDistances));
            else
                MaxMixClustLength(1,session) = NaN;
            end
            MeanPreSucClustLength(1,session) = nanmean(cell2mat(PreSucClusterDistances));
            if ~isempty(cell2mat(PreSucClusterDistances))
                MaxPreSucClustLength(1,session) = nanmax(cell2mat(PreSucClusterDistances));
            else
                MaxPreSucClustLength(1,session) = NaN;
            end
            MeanSucClustLength(1,session) = nanmean(cell2mat(SucClusterDistances));
            if ~isempty(cell2mat(SucClusterDistances))
                MaxSucClustLength(1,session) = nanmax(cell2mat(SucClusterDistances));
            else
                MaxSucClustLength(1,session) = NaN;
            end
            MeanMovDuringCueClustLength(1,session) = nanmean(cell2mat(MovDuringCueClusterDistances));
            if ~isempty(cell2mat(MovDuringCueClusterDistances))
                MaxMovDuringCueClustLength(1,session) = nanmax(cell2mat(MovDuringCueClusterDistances));
            else
                MaxMovDuringCueClustLength(1,session) = NaN;
            end
            MeanRewClustLength(1,session) = nanmean(cell2mat(RewClusterDistances));
            if ~isempty(cell2mat(RewClusterDistances))
                MaxRewClustLength(1,session) = nanmax(cell2mat(RewClusterDistances));
            else
                MaxRewClustLength(1,session) = NaN;
            end
            MeanAllClustLength(1,session) = nanmean(cell2mat(AllClusterDistances));
            if ~isempty(cell2mat(AllClusterDistances))
                MaxAllClustLength(1,session) = nanmax(cell2mat(AllClusterDistances));
            else
                MaxAllClustLength(1,session) = NaN;
            end
            
            %%% Far clusters
            
            val = 1;
            AllFarClusterDistances = [];
            FarCueClusterDistances = [];
            FarMovClusterDistances = [];
            FarMixClusterDistances = [];
            FarPreSucClusterDistances = [];
            FarSucClusterDistances = [];
            FarMovDuringCueClusterDistances = [];
            FarRewClusterDistances = [];
            
            pixpermicron = 4.65;
            if isfield(varargin{i}, 'ZoomValue')
                if varargin{i}.ZoomValue ~= 0
                    pixpermicron = (pixpermicron*varargin{i}.ZoomValue)/12.1;
                end
            end
            
            FarDistanceMap = DistanceMap;
            FarDistanceMap(logical(eye(length(DistanceMap),length(DistanceMap)))) = 0;
            [r,c] = find(isnan(triu(FarDistanceMap)));
            
            if length(varargin{i}.PolyLinePos{1})>2
                method = 'old';    
            elseif length(varargin{i}.PolyLinePos{1}) == 2
                method = 'new';
            else
                error('Could not determine method used to draw ROIs')
            end
            
            for m = 1:length(r)
                switch method
                    case 'old'
                        spine_pos1 = [varargin{i}.ROIPosition{r(m)+1}(1)+varargin{i}.ROIPosition{r(m)+1}(3)/2, varargin{i}.ROIPosition{r(m)+1}(2)+varargin{i}.ROIPosition{r(m)+1}(4)/2];
                        spine_pos2 = [varargin{i}.ROIPosition{c(m)+1}(1)+varargin{i}.ROIPosition{c(m)+1}(3)/2, varargin{i}.ROIPosition{c(m)+1}(2)+varargin{i}.ROIPosition{c(m)+1}(4)/2];
                        FarDistanceMap(r(m),c(m)) = (sqrt((spine_pos1(1)-spine_pos2(1)).^2 +(spine_pos1(2)-spine_pos2(2)).^2))/pixpermicron;
                    case 'new'
                        spine_pos1 = [varargin{i}.ROIPosition{r(m)}(1)+varargin{i}.ROIPosition{r(m)}(3)/2, varargin{i}.ROIPosition{r(m)}(2)+varargin{i}.ROIPosition{r(m)}(4)/2];
                        spine_pos2 = [varargin{i}.ROIPosition{c(m)}(1)+varargin{i}.ROIPosition{c(m)}(3)/2, varargin{i}.ROIPosition{c(m)}(2)+varargin{i}.ROIPosition{c(m)}(4)/2];
                        FarDistanceMap(r(m),c(m)) = (sqrt((spine_pos1(1)-spine_pos2(1)).^2 +(spine_pos1(2)-spine_pos2(2)).^2))/pixpermicron;
                end
            end
            
            for CS = 1:length(FarClusteredSpines)
                if ~isempty(FarClusteredSpines{CS})
                    
                    spinecombos = nchoosek(FarClusteredSpines{CS}, 2); %%% Find all possible combinations of spines in a cluster
                    all_far_clust_distances = zeros(1,size(spinecombos,1));
                    far_cue_clust_distances = [];
                    far_mov_clust_distances = [];
                    far_mix_clust_distances = [];
                    far_presuc_clust_distances = [];
                    far_suc_clust_distances = [];
                    far_movduringcue_clust_distances = [];
                    far_rew_clust_distances = [];
                    
                    for n = 1:size(spinecombos,1)
                        all_far_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        if sum(CueSpines(spinecombos(n,1:2))) == 2;
                            far_cue_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_cue_clust_distances(1,n) = nan;
                        end
                        if sum(MovementSpines(spinecombos(n,1:2))) == 2;
                            far_mov_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_mov_clust_distances(1,n) = nan;
                        end
                        if sum([sum(CueSpines(spinecombos(n,1:2))), sum(MovementSpines(spinecombos(n,1:2)))]) >= 2
                            far_mix_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_mix_clust_distances(1,n) = nan;
                        end
                        if sum(PreSuccessSpines(spinecombos(n,1:2))) == 2
                            far_presuc_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1),spinecombos(n,2));
                        else
                            far_presuc_clust_distances(1,n) = nan;
                        end
                        if sum(SuccessSpines(spinecombos(n,1:2))) == 2;
                            far_suc_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_suc_clust_distances(1,n) = nan;
                        end
                        if sum(MovementDuringCueSpines(spinecombos(n,1:2))) == 2;
                            far_movduringcue_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_movduringcue_clust_distances(1,n) = nan;
                        end
                        if sum(RewardSpines(spinecombos(n,1:2))) == 2;
                            far_rew_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        else
                            far_rew_clust_distances(1,n) = nan;
                        end
                    end
                else
                    far_cue_clust_distances = nan;
                    far_mov_clust_distances = nan;
                    far_mix_clust_distances = nan;
                    far_presuc_clust_distances = nan;
                    far_suc_clust_distances = nan;
                    far_movduringcue_clust_distances = nan;
                    far_rew_clust_distances = nan;
                    all_far_clust_distances = nan;
                end
                AllFarClusterDistances{val} = all_far_clust_distances;
                FarCueClusterDistances{val} = far_cue_clust_distances;
                FarMovClusterDistances{val} = far_mov_clust_distances;
                FarMixClusterDistances{val} = far_mix_clust_distances;
                FarPreSucClusterDistances{val} = far_presuc_clust_distances;
                FarSucClusterDistances{val} = far_suc_clust_distances;
                FarMovDuringCueClusterDistances{val} = far_movduringcue_clust_distances;
                FarRewClusterDistances{val} = far_rew_clust_distances;
                val = val+1;
            end

            MeanFarCueClustLength(1,session) = nanmean(cell2mat(FarCueClusterDistances));
            MeanFarMovClustLength(1,session) = nanmean(cell2mat(FarMovClusterDistances));
            MeanFarMixClustLength(1,session) = nanmean(cell2mat(FarMixClusterDistances));
            MeanFarPreSucClustLength(1,session) = nanmean(cell2mat(FarPreSucClusterDistances));
            MeanFarSucClustLength(1,session) = nanmean(cell2mat(FarSucClusterDistances));
            MeanFarMovDuringCueClustLength(1,session) = nanmean(cell2mat(FarMovDuringCueClusterDistances));
            MeanFarRewClustLength(1,session) = nanmean(cell2mat(FarRewClusterDistances));
            MeanAllFarClustLength(1,session) = nanmean(cell2mat(AllFarClusterDistances));
            
            
            %%% causal clusters
            
            val = 1;
            AllCausClusterDistances = [];
            CausCueClusterDistances = [];
            CausMovClusterDistances = [];
            CausMixClusterDistances = [];
            CausPreSucClusterDistances = [];
            CausSucClusterDistances = [];
            CausMovDuringCueClusterDistances = [];
            CausRewClustDistances = [];
            

            for CS = 1:length(CausalClusteredSpines) 
                spinecombos = nchoosek(CausalClusteredSpines{CS}, 2); %%% Find all possible combinations of spines in a cluster
                all_clust_distances = zeros(1,size(spinecombos,1));
                cue_clust_distances = [];
                mov_clust_distances = [];
                suc_clust_distances = [];
                rew_clust_distances = [];

                for n = 1:size(spinecombos,1)
                    all_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                    if sum(MovementSpines(spinecombos(n,1:2))) == 2;
                        mov_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                    else
                        mov_clust_distances(1,n) = nan;
                    end
                end
                AllCausClusterDistances{val} = nanmean(all_clust_distances);
                CausCueClusterDistances{val} = nanmean(cue_clust_distances);
                CausMovClusterDistances{val} = nanmean(mov_clust_distances);
                CausSucClusterDistances{val} = nanmean(suc_clust_distances);
                CausRewClustDistances{val} = nanmean(rew_clust_distances); 
                val=val+1;
            end

            
            MeanCausalCueClustLength(1,session) = nanmean(cell2mat(CausCueClusterDistances));
            if ~isempty(cell2mat(CausCueClusterDistances))
                MaxCausalCueClustLength(1,session) = nanmax(cell2mat(CausCueClusterDistances));
            else
                MaxCausalCueClustLength(1,session) = NaN;
            end
            MeanCausalMovClustLength(1,session) = nanmean(cell2mat(CausMovClusterDistances));
            if ~isempty(cell2mat(CausMovClusterDistances))
                MaxCausalMovClustLength(1,session) = nanmax(cell2mat(CausMovClusterDistances));
            else
                MaxCausalMovClustLength(1,session) = NaN;
            end
            MeanCausalSucClustLength(1,session) = nanmean(cell2mat(CausSucClusterDistances));
            if ~isempty(cell2mat(CausSucClusterDistances))
                MaxCausalSucClustLength(1,session) = nanmax(cell2mat(CausSucClusterDistances));
            else
                MaxCausalSucClustLength(1,session) = NaN;
            end
            MeanCausalRewClustLength(1,session) = nanmean(cell2mat(CausRewClustDistances));
            if ~isempty(cell2mat(CausRewClustDistances))
                MaxCausalRewClustLength(1,session) = nanmax(cell2mat(CausRewClustDistances));
            else
                MaxCausalRewClustLength(1,session) = NaN;
            end
            MeanAllCausalClustLength(1,session) = nanmean(cell2mat(AllCausClusterDistances));
            if ~isempty(cell2mat(AllCausClusterDistances))
                MaxAllCausalClustLength(1,session) = nanmax(cell2mat(AllCausClusterDistances));
            else
                MaxAllCausalClustLength(1,session) = NaN;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Distance between functionally relevant spines
            
            allspine_combos = nchoosek(1:length(varargin{i}.dF_over_F),2);
            
            if length(find(CueSpines)) > 1
                cuespine_combos = nchoosek(find(CueSpines),2);
            else
                cuespine_combos = [];
            end
            
            if length(find(MovementSpines)) > 1
                movspine_combos = nchoosek(find(MovementSpines),2);
            else
                movspine_combos = [];
            end
            
            if length(find(PreSuccessSpines)) > 1
                presucspine_combos = nchoosek(find(PreSuccessSpines),2);
            else
                presucspine_combos = [];
            end
            
            if length(find(SuccessSpines)) > 1
                sucspine_combos = nchoosek(find(SuccessSpines),2);
            else
                sucspine_combos = [];
            end
            
            if length(find(MovementDuringCueSpines)) > 1
                movduringcuespine_combos = nchoosek(find(MovementDuringCueSpines),2);
            else
                movduringcuespine_combos = [];
            end
            
            if length(find(RewardSpines)) > 1
                rewspine_combos = nchoosek(find(RewardSpines),2);
            else
                rewspine_combos = [];
            end
            
            dist_between_all_spines = nan(1,size(allspine_combos,1));
                corr_between_all_spines = nan(1,size(allspine_combos,1));
                corr_between_all_spines_movperiods = nan(1,size(allspine_combos,1));
                corr_between_all_spines_stillperiods = nan(1,size(allspine_combos,1));
                adjacency_value_all_spines = nan(1,size(allspine_combos,1));
                shared_correlation_value_all_spines = nan(1,size(allspine_combos,1));
                shared_reliability_value_all_spines = nan(1,size(allspine_combos,1));
            dist_between_cue_spines = nan(1,size(cuespine_combos,1));
            dist_between_mov_spines = nan(1,size(movspine_combos,1));
                corr_between_mov_spines = nan(1,size(movspine_combos,1));
                corr_between_mov_spines_movperiods = nan(1,size(movspine_combos,1));
                corr_between_mov_spines_stillperiods = nan(1,size(movspine_combos,1));
            dist_between_presuc_spines = nan(1,size(presucspine_combos,1));
                corr_between_presuc_spines = nan(1,size(presucspine_combos,1));
            dist_between_suc_spines = nan(1,size(sucspine_combos,1));
                corr_between_suc_spines = nan(1,size(sucspine_combos,1));
                corr_between_suc_spines_movperiods = nan(1,size(sucspine_combos,1));
                corr_between_suc_spines_stillperiods = nan(1,size(sucspine_combos,1));
            dist_between_movduringcue_spines = nan(1,size(movduringcuespine_combos,1));
            dist_between_rew_spines = nan(1,size(rewspine_combos,1));
            dist_between_far_mov_spines = nan(1,size(movspine_combos,1));
                corr_between_far_mov_spines = nan(1,size(movspine_combos,1));
            dist_between_far_suc_spines = nan(1,size(sucspine_combos,1));
                corr_between_far_suc_spines = nan(1,size(sucspine_combos,1));
            dist_between_branch_mov_spines = nan(1,size(movspine_combos,1));
                corr_between_branch_mov_spines = nan(1,size(movspine_combos,1));
            dist_between_branch_suc_spines = nan(1,size(sucspine_combos,1));
                corr_between_branch_suc_spines = nan(1,size(sucspine_combos,1));
            
            tempcorrmat = separatedendcorrmat';
            separatedendcorrmat(isnan(separatedendcorrmat) & ~isnan(tempcorrmat)) = tempcorrmat(isnan(separatedendcorrmat) & ~isnan(tempcorrmat));
          
            if ~isempty(samecell{1}) && length(AllDiffDendSameCellCorr)>1
                tempcorrmat = AllDiffDendSameCellCorr';
                AllDiffDendSameCellCorr(isnan(AllDiffDendSameCellCorr) & ~isnan(tempcorrmat)) = tempcorrmat(isnan(AllDiffDendSameCellCorr) & ~isnan(tempcorrmat));
                samecellcheck = 1;
            else
                samecellcheck = 0;
            end
            
            for n = 1:size(allspine_combos,1)
                dist_between_all_spines(1,n) = DistanceMap(allspine_combos(n,1), allspine_combos(n,2));
                corr_between_all_spines(1,n) = samedendcorrmat(allspine_combos(n,1), allspine_combos(n,2));
                corr_between_all_spines_movperiods(1,n) = samedendmovcorrmat(allspine_combos(n,1), allspine_combos(n,2));
                corr_between_all_spines_stillperiods(1,n) = samedendstillcorrmat(allspine_combos(n,1), allspine_combos(n,2));
                adjacency_value_all_spines(1,n) = SpatioTemporalAdjacencyMatrix{session}(allspine_combos(n,1), allspine_combos(n,2));
                shared_correlation_value_all_spines(1,n) = InterspineMovementCorrelation{session}(allspine_combos(n,1), allspine_combos(n,2));
                shared_reliability_value_all_spines(1,n) = InterspineMovementReliability{session}(allspine_combos(n,1), allspine_combos(n,2));
            end
            
            for n = 1:size(cuespine_combos,1)
                dist_between_cue_spines(1,n) = DistanceMap(cuespine_combos(n,1), cuespine_combos(n,2));
            end
            
            for n = 1:size(movspine_combos,1)
                dist_between_mov_spines(1,n) = DistanceMap(movspine_combos(n,1), movspine_combos(n,2));
                corr_between_mov_spines(1,n) = samedendcorrmat(movspine_combos(n,1), movspine_combos(n,2));
                corr_between_mov_spines_movperiods(1,n) = samedendmovcorrmat(movspine_combos(n,1), movspine_combos(n,2));
                corr_between_mov_spines_stillperiods(1,n) = samedendstillcorrmat(movspine_combos(n,1), movspine_combos(n,2));
                counter = 1;
                %%% All separate dendrites
                if ~isnan(separatedendcorrmat(movspine_combos(n,1), movspine_combos(n,2)))
                    numpos = find(separatedendcorrlist==separatedendcorrmat(movspine_combos(n,1), movspine_combos(n,2)));
                    if length(numpos)>1
                        separatedendcorrlist(numpos(1)) = NaN;  %%% Set the value in the correlation list to NaN so that it is not found again
                        numpos = numpos(1);
                    else
                        dist_between_far_mov_spines(1,n) = varargin{i}.FarSpineToSpineDistance(numpos);
                        corr_between_far_mov_spines(1,n) = separatedendcorrmat(movspine_combos(n,1), movspine_combos(n,2));
                    end
                else
                    dist_between_far_mov_spines(1,n) = nan;
                    corr_between_far_mov_spines(1,n) = nan;
                end
                %%% Separate dendrites of (presumed) same cell
                if samecellcheck
                    if ~isnan(AllDiffDendSameCellCorr(movspine_combos(n,1), movspine_combos(n,2)))
                        numpos = find(DiffDendSameCellCorrList==AllDiffDendSameCellCorr(movspine_combos(n,1), movspine_combos(n,2)));
                        if length(numpos)>1
                            DiffDendSameCellCorrList(numpos(1)) = NaN;  %%% Set the value in the correlation list to NaN so that it is not found again
                            numpos = numpos(1);
                        else
                            dist_between_branch_mov_spines(1,n) = varargin{i}.FarSpineToSpineDistance(numpos);
                            corr_between_branch_mov_spines(1,n) = separatedendcorrmat(movspine_combos(n,1), movspine_combos(n,2));
                        end
                    else
                        dist_between_branch_mov_spines(1,n) = nan;
                        corr_between_branch_mov_spines(1,n) = nan;
                    end
                else
                    dist_between_branch_mov_spines(1,n) = nan;
                    corr_between_branch_mov_spines(1,n) = nan;
                end
            end
            for n = 1:size(presucspine_combos,1)
                dist_between_presuc_spines(1,n) = DistanceMap(presucspine_combos(n,1), presucspine_combos(n,2));
                corr_between_presuc_spines(1,n) = samedendcorrmat(presucspine_combos(n,1), presucspine_combos(n,2));
            end
            for n = 1:size(sucspine_combos,1)
                dist_between_suc_spines(1,n) = DistanceMap(sucspine_combos(n,1), sucspine_combos(n,2));
                corr_between_suc_spines(1,n) = samedendcorrmat(sucspine_combos(n,1), sucspine_combos(n,2));
                corr_between_suc_spines_movperiods(1,n) = samedendmovcorrmat(sucspine_combos(n,1), sucspine_combos(n,2));
                corr_between_suc_spines_stillperiods(1,n) = samedendstillcorrmat(sucspine_combos(n,1), sucspine_combos(n,2));
                counter = 1;
                if ~isnan(separatedendcorrmat(sucspine_combos(n,1), sucspine_combos(n,2)))
                    numpos = find(separatedendcorrlist==separatedendcorrmat(sucspine_combos(n,1), sucspine_combos(n,2)));
                    if length(numpos)>1
                        separatedendcorrlist(numpos(1)) = NaN;  %%% Set the value in the correlation list to NaN so that it is not found again
                        numpos = numpos(1);
                    else
                        dist_between_far_suc_spines(1,n) = varargin{i}.FarSpineToSpineDistance(numpos);
                        corr_between_far_suc_spines(1,n) = separatedendcorrmat(sucspine_combos(n,1), sucspine_combos(n,2));
                    end
                else
                    dist_between_far_suc_spines(1,n) = nan;
                    corr_between_far_suc_spines(1,n) = nan;
                end
                if samecellcheck
                    if ~isnan(AllDiffDendSameCellCorr(sucspine_combos(n,1), sucspine_combos(n,2)))
                        numpos = find(DiffDendSameCellCorrList==AllDiffDendSameCellCorr(sucspine_combos(n,1), sucspine_combos(n,2)));
                        if length(numpos)>1
                            DiffDendSameCellCorrList(numpos(1)) = NaN;  %%% Set the value in the correlation list to NaN so that it is not found again
                            numpos = numpos(1);
                        else
                            dist_between_branch_suc_spines(1,n) = varargin{i}.FarSpineToSpineDistance(numpos);
                            corr_between_branch_suc_spines(1,n) = separatedendcorrmat(sucspine_combos(n,1), sucspine_combos(n,2));
                        end
                    else
                        dist_between_branch_suc_spines(1,n) = nan;
                        corr_between_branch_suc_spines(1,n) = nan;
                    end
                else
                    dist_between_branch_suc_spines(1,n) = nan;
                    corr_between_branch_suc_spines(1,n) = nan;
                end
            end
            for n = 1:size(movduringcuespine_combos,1)
                dist_between_movduringcue_spines = DistanceMap(movduringcuespine_combos(n,1), movduringcuespine_combos(n,2));
            end
            for n = 1:size(rewspine_combos,1)
                dist_between_rew_spines(1,n) = DistanceMap(rewspine_combos(n,1), rewspine_combos(n,2));
            end
            
            corr_between_all_spines = corr_between_all_spines(~isnan(dist_between_all_spines));
            corr_between_all_spines_movperiods = corr_between_all_spines_movperiods(~isnan(dist_between_all_spines));
            corr_between_all_spines_stillperiods = corr_between_all_spines_stillperiods(~isnan(dist_between_all_spines));
            adjacency_value_all_spines = adjacency_value_all_spines(~isnan(dist_between_all_spines));
            shared_correlation_value_all_spines = shared_correlation_value_all_spines(~isnan(dist_between_all_spines));
            shared_reliability_value_all_spines = shared_reliability_value_all_spines(~isnan(dist_between_all_spines));
                CorrelationBetweenAllSpines{session} = corr_between_all_spines;
                CorrelationBetweenAllSpinesMovePeriods{session} = corr_between_all_spines_movperiods;
                CorrelationBetweenAllSpinesStillPeriods{session} = corr_between_all_spines_stillperiods;
                MeanCorrelationBetweenAllSpines{session} = nanmean(corr_between_all_spines);
                AdjacencyValuesforAllSpines{session} = adjacency_value_all_spines;
                SharedPairwiseCorrelationValuesforAllSpines{session} = shared_correlation_value_all_spines;
                SharedPairwiseReliabilityValuesforAllSpines{session} = shared_reliability_value_all_spines;
            dist_between_all_spines = dist_between_all_spines(~isnan(dist_between_all_spines));
                DistanceBetweenAllSpines{session} = dist_between_all_spines;
            dist_between_cue_spines = dist_between_cue_spines(~isnan(dist_between_cue_spines));
                DistanceBetweenCueSpines{session} = dist_between_cue_spines;
                MeanDistanceBetweenCueSpines(1,session) = nanmean(dist_between_cue_spines);
            corr_between_mov_spines = corr_between_mov_spines(~isnan(dist_between_mov_spines)); %%% Needs to be calculated prior to updating (dist_between_mov_spines)!!
            corr_between_mov_spines_movperiods = corr_between_mov_spines_movperiods(~isnan(dist_between_mov_spines));
            corr_between_mov_spines_stillperiods = corr_between_mov_spines_stillperiods(~isnan(dist_between_mov_spines));
                CorrelationBetweenMovementSpines{session} = corr_between_mov_spines;
                CorrelationBetweenMovementSpinesMovePeriods{session} = corr_between_mov_spines_movperiods;
                CorrelationBetweenMovementSpinesStillPeriods{session} = corr_between_mov_spines_stillperiods;
                MeanCorrelationBetweenMovementSpines{1,session} = nanmean(corr_between_mov_spines);
            dist_between_mov_spines = dist_between_mov_spines(~isnan(dist_between_mov_spines));
                DistanceBetweenMovementSpines{session} = dist_between_mov_spines;
                MeanDistanceBetweenMovementSpines(1,session) = nanmean(dist_between_mov_spines);
            dist_between_presuc_spines = dist_between_presuc_spines(~isnan(dist_between_presuc_spines));
                DistanceBetweenPreSuccessSpines{session} = dist_between_presuc_spines;
                MeanDistanceBetweenPreSuccessSpines(1,session) = nanmean(dist_between_presuc_spines);
            corr_between_presuc_spines = corr_between_presuc_spines(~isnan(dist_between_presuc_spines)); %%% Needs to be calculated prior to updating (dist_between_mov_spines)!!
                CorrelationBetweenPreSuccessSpines{session} = corr_between_presuc_spines;
                MeanCorrelationBetweenPreSuccessSpines{1,session} = nanmean(corr_between_presuc_spines);

            corr_between_suc_spines = corr_between_suc_spines(~isnan(dist_between_suc_spines)); %%% Needs to be calculated prior to updating 'dist_between_suc_spines'!!
            corr_between_suc_spines_movperiods = corr_between_suc_spines_movperiods(~isnan(dist_between_suc_spines));
            corr_between_suc_spines_stillperiods = corr_between_suc_spines_stillperiods(~isnan(dist_between_suc_spines));
                CorrelationBetweenSuccessSpines{session} = corr_between_suc_spines;
                CorrelationBetweenSuccessSpinesMovePeriods{session} = corr_between_suc_spines_movperiods;
                CorrelationBetweenSuccessSpinesStillPeriods{session} = corr_between_suc_spines_stillperiods;
                MeanCorrelationBetweenSuccessSpines{1,session} = nanmean(corr_between_suc_spines);
            dist_between_suc_spines = dist_between_suc_spines(~isnan(dist_between_suc_spines));
                DistanceBetweenSuccessSpines{session} = dist_between_suc_spines;
                MeanDistanceBetweenSuccessSpines(1,session) = nanmean(dist_between_suc_spines);
            dist_between_movduringcue_spines = dist_between_movduringcue_spines(~isnan(dist_between_movduringcue_spines));
                DistanceBetweenMovementDuringCueSpines{session} = dist_between_movduringcue_spines;
                MeanDistanceBetweenMovementDuringCueSpines(1,session) = nanmean(dist_between_movduringcue_spines);
            dist_between_rew_spines = dist_between_rew_spines(~isnan(dist_between_rew_spines));
                DistanceBetweenRewardSpines{session} = dist_between_rew_spines;
                MeanDistanceBetweenRewardSpines(1,session) = nanmean(dist_between_rew_spines);
            
            corr_between_far_mov_spines = corr_between_far_mov_spines(~isnan(dist_between_far_mov_spines));
                CorrelationBetweenAllodendriticMovementSpines{session} = corr_between_far_mov_spines;
            dist_between_far_mov_spines = dist_between_far_mov_spines(~isnan(dist_between_far_mov_spines));
                DistanceBetweenFarMovementSpines{session} = dist_between_far_mov_spines;
            CorrelationBetweenAlloDendriticSpines{session} = separatedendcorrlist;
            
            if isempty(separatedendcorrlist) && ~isempty(varargin{i}.FarSpineToSpineDistance)
                if sum(varargin{i}.FarSpineToSpineDistance)
                    DistanceBetweenFarSpines{session} = [];
                else
                end
            else
                DistanceBetweenFarSpines{session} = varargin{i}.FarSpineToSpineDistance;
            end
            
            %%% Same cell, different branches
            CorrelationBetweenAllBranchSpines{session} = DiffDendSameCellCorrList;

            if ~isempty(DiffDendSameCellCorrList)
                DistanceBetweenAllBranchSpines{session} = DistanceBetweenFarSpines{session}(ismember(separatedendcorrlist, DiffDendSameCellCorrList));
            end
                        
            corr_between_branch_mov_spines = corr_between_branch_mov_spines(~isnan(dist_between_branch_mov_spines));
                CorrelationBetweenBranchMoveSpines{session} = corr_between_branch_mov_spines;
            dist_between_branch_mov_spines = dist_between_branch_mov_spines(~isnan(dist_between_branch_mov_spines));
                DistanceBetweenBranchMoveSpines{session} = dist_between_branch_mov_spines;
            corr_between_branch_suc_spines = corr_between_branch_suc_spines(~isnan(dist_between_branch_suc_spines));
                CorrelationBetweenBranchSuccessSpines{session} = corr_between_branch_suc_spines;
            dist_between_branch_suc_spines = dist_between_branch_suc_spines(~isnan(dist_between_branch_suc_spines));
                DistanceBetweenBranchSuccessSpines{session} = dist_between_branch_suc_spines;
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%  Distributions of Movement-related spines
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            
            if sum(MovementSpines)>1
                spinelist = find(MovementSpines);
                for s = 1:length(spinelist)
                    currentspine = spinelist(s);                    %%% Select current spine on the list
                    otherspines = setdiff(spinelist, currentspine); %%% Make a list of all other spines in the list
                    movspinedistlist = sort(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false)));   %%% Make a sorted list of all distances to other movement-related spines
                    MovSpinetoNearestMovSpine{session}(1,s) = movspinedistlist(1);   %%% Find the smallest distance from the current spine to other spines on the same dendrite
                    if length(movspinedistlist) >1
                        NextClosest{session}(1,s) = movspinedistlist(2);
                    else
                        NextClosest{session}(1,s) = NaN;
                    end
                    if length(movspinedistlist) >2
                        ThirdClosest{session}(1,s) = movspinedistlist(3);
                    else
                        ThirdClosest{session}(1,s) = NaN;
                    end
                    if length(movspinedistlist) > 3
                        FourthClosest{session}(1,s) = movspinedistlist(4);
                    end
                  
                    minloc = find(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false)) == movspinedistlist(1));  %%% Find the index of the closest movement-related spine in the 'otherspines' list                   
                    if ~isempty(movspinedistlist(find(~isnan(movspinedistlist),1, 'last')))
                    	maxloc = find(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false)) == movspinedistlist(find(~isnan(movspinedistlist),1, 'last')));
                    else
                        maxloc = [];
                    end
                    if ~isempty(minloc)
                        CorrwithNearestMovSpine{session}(1,s) = mean(samedendcorrmat(currentspine, otherspines(minloc)));   %%% Find the correlation with the nearest movement-related spine (note, sometimes there are multiple at the same distance, so use the mean correlation)
                        if length(movspinedistlist) > 1
                            CorrwithFarthestMovSpine{session}(1,s) = mean(samedendcorrmat(currentspine, otherspines(maxloc)));
                        else
                            CorrwithFarthestMovSpine{session}(1,s) = nan;
                        end
                        
                        %%% Distances from movement spines to nearby
                        %%% functionally clustered spines (meta-clustering)
                        
                        otherfuncclustmovspines = mov_cluster_ind-Spine1_address;
                        roundedcorrmat = round(samedendcorrmat.*100)/100;
                        
                        if ~isempty(otherfuncclustmovspines)
                            [distancestoFCSs, FCdistInd] = sort(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherfuncclustmovspines, 'uni', false)));
                            assoccorr = cell2mat(arrayfun(@(x) roundedcorrmat(currentspine, x), otherfuncclustmovspines, 'uni', false));
                            assoccorr = assoccorr(FCdistInd);
                            
                            AllCorrwithNearbyMetaClusters{session}= [AllCorrwithNearbyMetaClusters{session}; assoccorr(logical((assoccorr<0.5).*(distancestoFCSs<10)))];
                            AllCorrwithDistantMetaClusters{session} = [AllCorrwithDistantMetaClusters{session}; assoccorr(logical((assoccorr<0.5).*(distancestoFCSs>15)))];
                            
                            if assoccorr(1)<0.5
                                MovSpinetoNearestFuncClustMovSpine{session}(1,s) = distancestoFCSs(1);  %%% Distances from any given movement spine (irrespective of its functional properties) to a functionally clustered movement spine)
                                CorrofNearestMetaCluster{session}(1,s) = assoccorr(1);
                            else
                                MovSpinetoNearestFuncClustMovSpine{session}(1,s) = NaN;
                                CorrofNearestMetaCluster{session}(1,s) = NaN;
                            end
                            if length(distancestoFCSs)>1
                                if assoccorr(2)<0.5
                                    MovSpinetoNextFuncClustMovSpine{session}(1,s) = distancestoFCSs(2);
                                    CorrofNextMetaCluster{session}(1,s) = assoccorr(2);
                                else
                                    MovSpinetoNextFuncClustMovSpine{session}(1,s) = NaN;
                                    CorrofNextMetaCluster{session}(1,s) = NaN;
                                end
                            end
                            if length(distancestoFCSs)>2
                                if assoccorr(3)<0.5
                                    MovSpinetoThirdFuncClustMovSpine{session}(1,s) = distancestoFCSs(3);
                                    CorrofThirdMetaCluster{session}(1,s) = assoccorr(3);
                                else
                                    MovSpinetoThirdFuncClustMovSpine{session}(1,s) = NaN;
                                    CorrofThirdMetaCluster{session}(1,s) = NaN;
                                end
                            end
                            if length(distancestoFCSs)>3
                                if assoccorr(4)<0.5
                                    MovSpinetoFourthFuncClustMovSpine{session}(1,s) = distancestoFCSs(4);
                                    CorrofFourthMetaCluster{session}(1,s) = assoccorr(4);
                                else
                                    MovSpinetoFourthFuncClustMovSpine{session}(1,s) = NaN;
                                    CorrofFourthMetaCluster{session}(1,s) = NaN;
                                end
                            end
                        else
                            distancestoFCSs = [];
                        end
                        if ismember(currentspine, otherfuncclustmovspines)  %%% if both spines are functionally clustered movement spines
                            FuncClustMovSpinetoNearestFuncClustMovSpine{session}(1,s) = distancestoFCSs(1); %%% Distances between functionally clustered movement related spines (i.e. both are functionally clustered and movement-related)
                            otherhighcorrspines = otherfuncclustmovspines(cell2mat(arrayfun(@(x) roundedcorrmat(currentspine, x), otherfuncclustmovspines, 'uni', false))>=0.5);
                            [distancestoHCSs, HCdistInd] = sort(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherhighcorrspines, 'uni', false)));
                            if ~isempty(otherhighcorrspines)
                                NearestHighCorrMovSpine{session}(1,s) = distancestoHCSs(1);
                            end
                            if length(distancestoFCSs)>1
                                NextClosestFuncClustMovSpine{session}(1,s) = distancestoFCSs(2);
                            end
                            if length(distancestoHCSs)>1
                                NextClosestHighCorrMovSpine{session}(1,s) = distancestoHCSs(2);
                            end
                            if length(distancestoFCSs)>2
                                ThirdClosestFuncClustMovSpine{session}(1,s) = distancestoFCSs(3);
                            end
                            if length(distancestoHCSs)>2
                                ThirdClosestHighCorrMovSpine{session}(1,s) = distancestoHCSs(3);
                            end
                            if length(distancestoFCSs)>3
                                FourthClosestFuncClustMovSpine{session}(1,s) = distancestoFCSs(4);
                            end
                            if length(distancestoHCSs)>3
                                FourthClosestHighCorrMovSpine{session}(1,s) = distancestoHCSs(4);
                            end
                        end
                    end
                end
                s = 1;
                ticker = 1;
                while s<sum(MovementSpines)/4
                    randchoice1 = spinelist(randi(length(spinelist)));
                    randchoice2 = spinelist(randi(length(spinelist)));
                    while randchoice1 == randchoice2
                        randchoice2 = spinelist(randi(length(spinelist)));
                    end
                    roundedcorrmat = round(corrmat.*100)/100;
                    if roundedcorrmat(randchoice1,randchoice2)<0.5
                        RandomMovementPairCorr{session}(1,s) = roundedcorrmat(randchoice1, randchoice2);
                        s = s+1;
                    else
                    end
                    ticker = ticker+1;      %%% If none of the correlation values meet the criteria, then you can get stuck in an infinite loop... only perform enough loops to cover at most all the possible combination of spines...
                    if ticker>= size(nchoosek(spinelist,2),1);
                        s = sum(MovementSpines)/4;
                    end
                end
            end
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Correlation of Clusters with Different Features %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            allcorrs = [];
            invcheckmat = ones(varargin{i}.NumberofSpines,1);
            
            allspines = Spine1_address+(1:length(varargin{i}.deltaF));
            nonclustered = allspines(~ismember(allspines,cluster_ind));
            causal_nonclustered = allspines(~ismember(allspines,Caus_cluster_ind));
                     
            
            allclusterscorrwithcue = SessionCorrData(Cue_address, cluster_ind);
            nonclusteredcorrwithcue = SessionCorrData(Cue_address, nonclustered);
                cueclusterscorrwithcue = SessionCorrData(Cue_address, cue_cluster_ind);
                cuenonclusteredcorrwithcue = SessionCorrData(Cue_address, setdiff(find(CueSpines),cue_cluster_ind-Spine1_address)+Spine1_address).*dendcheckC(setdiff(find(CueSpines),cue_cluster_ind-Spine1_address));
            allclusterscorrwithmov = SessionCorrData(Movement_address, cluster_ind);
            nonclusteredcorrwithmov = SessionCorrData(Movement_address, nonclustered);
                movclusterscorrwithmov = SessionCorrData(Movement_address, mov_cluster_ind);
                movnonclusteredcorrwithmov = SessionCorrData(Movement_address, setdiff(find(MovementSpines),mov_cluster_ind-Spine1_address)+Spine1_address).*dendcheckM(setdiff(find(MovementSpines),mov_cluster_ind-Spine1_address));
            
            allclusterscorrwithMDC = SessionCorrData(MovementDuringCue_address, cluster_ind);
            nonclusteredcorrwithMDC = SessionCorrData(MovementDuringCue_address, nonclustered);
                MDCclusterscorrwithMDC = SessionCorrData(MovementDuringCue_address, movduringcue_cluster_ind);
                MDCnonclusteredcorrwithMDC = SessionCorrData(MovementDuringCue_address, setdiff(find(MovementDuringCueSpines),movduringcue_cluster_ind-Spine1_address)+Spine1_address).*dendcheckMDC(setdiff(find(MovementDuringCueSpines), movduringcue_cluster_ind-Spine1_address));
                
            allclusterscorrwithsuc = SessionCorrData(Success_address, cluster_ind);
            nonclusteredcorrwithsuc = SessionCorrData(Success_address, nonclustered);
                succlusterscorrwithsuc = SessionCorrData(Success_address, suc_cluster_ind);
                sucnonclusteredcorrwithsuc = SessionCorrData(Success_address, setdiff(find(SuccessSpines),suc_cluster_ind-Spine1_address)+Spine1_address).*dendcheckS(setdiff(find(SuccessSpines),suc_cluster_ind-Spine1_address));
            allclusterscorrwithrew = SessionCorrData(Reward_address, cluster_ind);
            nonclusteredcorrwithrew = SessionCorrData(Reward_address, nonclustered);
                rewclusterscorrwithrew = SessionCorrData(Reward_address, rew_cluster_ind);
                rewnonclusteredcorrwithrew = SessionCorrData(Reward_address, setdiff(find(RewardSpines),rew_cluster_ind-Spine1_address)+Spine1_address).*dendcheckR(setdiff(find(RewardSpines),rew_cluster_ind-Spine1_address));
            
                
                
                
            if usecorrminimum
                allclusterscorrwithcue = allclusterscorrwithcue(find(allclusterscorrwithcue>corrminimum));
                nonclusteredcorrwithcue = nonclusteredcorrwithcue(find(nonclusteredcorrwithcue>corrminimum));
                    cueclusterscorrwithcue = cueclusterscorrwithcue(find(cueclusterscorrwithcue>corrminimum));
                    cuenonclusteredcorrwithcue = cuenonclusteredcorrwithcue(find(cuenonclusteredcorrwithcue>corrminimum));
                allclusterscorrwithmov = allclusterscorrwithmov(find(allclusterscorrwithmov>corrminimum));
                nonclusteredcorrwithmov = nonclusteredcorrwithmov(find(nonclusteredcorrwithmov>corrminimum));
                    movclusterscorrwithmov = movclusterscorrwithmov(find(movclusterscorrwithmov>corrminimum));
                    movnonclusteredcorrwithmov = movnonclusteredcorrwithmov(find(movnonclusteredcorrwithmov>corrminimum));
                allclusterscorrwithMDC = allclusterscorrwithMDC(find(allclusterscorrwithMDC>corrminimum));
                nonclusteredcorrwithMDC = nonclusteredcorrwithMDC(find(nonclusteredcorrwithMDC>corrminimum));
                    MDCclusterscorrwithMDC = MDCclusterscorrwithMDC(find(MDCclusterscorrwithMDC>corrminimum));
                    MDCnonclusteredcorrwithMDC = MDCnonclusteredcorrwithMDC(find(MDCnonclusteredcorrwithMDC>corrminimum));
                allclusterscorrwithsuc = allclusterscorrwithsuc(find(allclusterscorrwithsuc>corrminimum));
                nonclusteredcorrwithsuc = nonclusteredcorrwithsuc(find(nonclusteredcorrwithsuc>corrminimum));
                    succlusterscorrwithsuc = succlusterscorrwithsuc(find(succlusterscorrwithsuc>corrminimum));
                    sucnonclusteredcorrwithsuc = sucnonclusteredcorrwithsuc(find(sucnonclusteredcorrwithsuc));
                allclusterscorrwithrew = allclusterscorrwithrew(find(allclusterscorrwithrew>corrminimum));
                nonclusteredcorrwithrew = nonclusteredcorrwithrew(find(nonclusteredcorrwithrew>corrminimum));
                    rewclusterscorrwithrew = rewclusterscorrwithrew(find(rewclusterscorrwithrew>corrminimum));
                    rewnonclusteredcorrwithrew = rewnonclusteredcorrwithrew(find(rewnonclusteredcorrwithrew));
            end

            clustcorrwithcue(1,session) = nanmean(allclusterscorrwithcue);
            nonclustcorrwithcue(1,session) = nanmean(nonclusteredcorrwithcue);
                cueclustcorrwithcue(1,session) = nanmean(cueclusterscorrwithcue);
                cuenonclustcorrwithcue(1,session) = nanmean(cuenonclusteredcorrwithcue);
                
            allspinescorrwithmov(1,session) = nanmean(SessionCorrData(Movement_address,:));
            if sum(MovementSpines)>0
                movspinescorrwithmov(1,session) = nanmean(SessionCorrData(Movement_address,logical(MovementSpines)));
            else
                movspinescorrwithmov(1,session) = nan;
            end
            clustcorrwithmov(1,session) = nanmean(allclusterscorrwithmov);
            nonclustcorrwithmov(1,session) = nanmean(nonclusteredcorrwithmov);
                movclustcorrwithmov(1,session) = nanmean(movclusterscorrwithmov);
                movnonclustcorrwithmov(1,session) = nanmean(movnonclusteredcorrwithmov);
                
            clustcorrwithMDC(1,session) = nanmean(allclusterscorrwithMDC);
            nonclustcorrwithMDC(1,session) = nanmean(nonclusteredcorrwithMDC);
                MDCclustcorrwithMDC(1,session) = nanmean(MDCclusterscorrwithMDC);
                MDCnonclustcorrwithMDC(1,session) = nanmean(MDCnonclusteredcorrwithMDC);
            
            clustcorrwithsuc(1,session) = nanmean(allclusterscorrwithsuc);
            nonclustcorrwithsuc(1,session) = nanmean(nonclusteredcorrwithsuc);
                succlustcorrwithsuc(1,session) = nanmean(succlusterscorrwithsuc);
                sucnonclustcorrwithsuc(1,session) = nanmean(sucnonclusteredcorrwithsuc);
            clustcorrwithrew(1,session) = nanmean(allclusterscorrwithrew);
            nonclustcorrwithrew(1,session) = nanmean(nonclusteredcorrwithrew);
                rewclustcorrwithrew(1,session) = nanmean(rewclusterscorrwithrew);
                rewnonclustcorrwithrew(1,session) = nanmean(rewnonclusteredcorrwithrew);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Repeat for Causal Clusters %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
             
            if ~isempty(Caus_cluster_ind)
                Caus_allclusterscorrwithcue = Correlations{session}.CausalCorrelations(Cue_address, Caus_cluster_ind).*dendcheck(Caus_cluster_ind-Spine1_address);
                Caus_nonclusteredcorrwithcue = Correlations{session}.CausalCorrelations(Cue_address, causal_nonclustered).*dendcheck(causal_nonclustered-Spine1_address);
                    Caus_cueclusterscorrwithcue = Correlations{session}.CausalCorrelations(Cue_address, Caus_cue_cluster_ind).*dendcheckC(Caus_cue_cluster_ind-Spine1_address);
                    Caus_cuenonclusteredcorrwithcue = Correlations{session}.CausalCorrelations(Cue_address, setdiff(find(CueSpines),Caus_cue_cluster_ind-Spine1_address)+Spine1_address).*dendcheckC(setdiff(find(CueSpines),Caus_cue_cluster_ind-Spine1_address));
                
                Caus_allclusterscorrwithmov = Correlations{session}.CausalCorrelations(Movement_address, Caus_cluster_ind).*dendcheck(Caus_cluster_ind-Spine1_address);
                Caus_nonclusteredcorrwithmov = Correlations{session}.CausalCorrelations(Movement_address, causal_nonclustered).*dendcheck(causal_nonclustered-Spine1_address);
                    Caus_movclusterscorrwithmov = Correlations{session}.CausalCorrelations(Movement_address, Caus_mov_cluster_ind).*dendcheckM(Caus_mov_cluster_ind-Spine1_address);
                    Caus_movnonclusteredcorrwithmov = Correlations{session}.CausalCorrelations(Movement_address, setdiff(find(MovementSpines),Caus_mov_cluster_ind-Spine1_address)+Spine1_address).*dendcheckM(setdiff(find(MovementSpines),Caus_mov_cluster_ind-Spine1_address));
                
                Caus_allclusterscorrwithMDC = Correlations{session}.CausalCorrelations(MovementDuringCue_address, cluster_ind);
                Caus_nonclusteredcorrwithMDC = Correlations{session}.CausalCorrelations(MovementDuringCue_address, nonclustered).*dendcheck(nonclustered-Spine1_address);
                    Caus_MDCclusterscorrwithMDC = Correlations{session}.CausalCorrelations(MovementDuringCue_address, movduringcue_cluster_ind);
                    Caus_MDCnonclusteredcorrwithMDC = Correlations{session}.CausalCorrelations(MovementDuringCue_address, setdiff(find(MovementDuringCueSpines),movduringcue_cluster_ind-Spine1_address)+Spine1_address).*dendcheckMDC(setdiff(find(MovementDuringCueSpines), movduringcue_cluster_ind-Spine1_address));

                 
                Caus_allclusterscorrwithsuc = Correlations{session}.CausalCorrelations(Success_address, Caus_cluster_ind).*dendcheck(Caus_cluster_ind-Spine1_address);
                Caus_nonclusteredcorrwithsuc = Correlations{session}.CausalCorrelations(Success_address, causal_nonclustered).*dendcheck(causal_nonclustered-Spine1_address);
                    Caus_succlusterscorrwithsuc = Correlations{session}.CausalCorrelations(Success_address, Caus_suc_cluster_ind).*dendcheckS(Caus_suc_cluster_ind-Spine1_address);
                    Caus_sucnonclusteredcorrwithsuc = Correlations{session}.CausalCorrelations(Success_address, setdiff(find(SuccessSpines),Caus_suc_cluster_ind-Spine1_address)+Spine1_address).*dendcheckS(setdiff(find(SuccessSpines),Caus_suc_cluster_ind-Spine1_address));
                Caus_allclusterscorrwithrew = Correlations{session}.CausalCorrelations(Reward_address, Caus_cluster_ind).*dendcheck(Caus_cluster_ind-Spine1_address);
                Caus_nonclusteredcorrwithrew = Correlations{session}.CausalCorrelations(Reward_address, causal_nonclustered).*dendcheck(causal_nonclustered-Spine1_address);
                    Caus_rewclusterscorrwithrew = Correlations{session}.CausalCorrelations(Reward_address, Caus_rew_cluster_ind).*dendcheckR(Caus_rew_cluster_ind-Spine1_address);
                    Caus_rewnonclusteredcorrwithrew = Correlations{session}.CausalCorrelations(Reward_address, setdiff(find(RewardSpines),Caus_rew_cluster_ind-Spine1_address)+Spine1_address).*dendcheckR(setdiff(find(RewardSpines),Caus_rew_cluster_ind-Spine1_address));
            else
                Caus_allclusterscorrwithcue = [];
                Caus_nonclusteredcorrwithcue = [];
                    Caus_cueclusterscorrwithcue = [];
                    Caus_cuenonclusteredcorrwithcue = [];
                Caus_allclusterscorrwithmov = [];
                Caus_nonclusteredcorrwithmov = [];
                    Caus_movclusterscorrwithmov = [];
                    Caus_movnonclusteredcorrwithmov =[];
                Caus_allclusterscorrwithMDC = [];
                Caus_nonclusteredcorrwithMDC = [];
                    Caus_MDCclusterscorrwithMDC = [];
                    Caus_MDCnonclusteredcorrwithMDC = [];
                Caus_allclusterscorrwithsuc = [];
                Caus_nonclusteredcorrwithsuc = [];
                    Caus_succlusterscorrwithsuc = [];
                    Caus_sucnonclusteredcorrwithsuc = [];
                Caus_allclusterscorrwithrew = [];
                Caus_nonclusteredcorrwithrew = [];
                    Caus_rewclusterscorrwithrew = [];
                    Caus_rewnonclusteredcorrwithrew = [];
            end
                
            
            if usecorrminimum
                Caus_allclusterscorrwithcue = Caus_allclusterscorrwithcue(find(Caus_allclusterscorrwithcue>corrminimum));
                Caus_nonclusteredcorrwithcue = Caus_nonclusteredcorrwithcue(find(Caus_nonclusteredcorrwithcue>corrminimum));
                    Caus_cueclusterscorrwithcue = Caus_cueclusterscorrwithcue(find(Caus_cueclusterscorrwithcue>corrminimum));
                    Caus_cuenonclusteredcorrwithcue = Caus_cuenonclusteredcorrwithcue(find(Caus_cuenonclusteredcorrwithcue>corrminimum));
                Caus_allclusterscorrwithmov = Caus_allclusterscorrwithmov(find(Caus_allclusterscorrwithmov>corrminimum));
                Caus_nonclusteredcorrwithmov = Caus_nonclusteredcorrwithmov(find(Caus_nonclusteredcorrwithmov>corrminimum));
                    Caus_movclusterscorrwithmov = Caus_movclusterscorrwithmov(find(Caus_movclusterscorrwithmov>corrminimum));
                    Caus_movnonclusteredcorrwithmov = Caus_movnonclusteredcorrwithmov(find(Caus_movnonclusteredcorrwithmov));
                    
                Caus_allclusterscorrwithMDC = Caus_allclusterscorrwithMDC(find(Caus_allclusterscorrwithMDC>corrminimum));
                Caus_nonclusteredcorrwithMDC = Caus_nonclusteredcorrwithMDC(find(Caus_nonclusteredcorrwithMDC>corrminimum));
                    Caus_MDCclusterscorrwithMDC = Caus_MDCclusterscorrwithMDC(find(Caus_MDCclusterscorrwithMDC>corrminimum));
                    Caus_MDCnonclusteredcorrwithMDC = Caus_MDCnonclusteredcorrwithMDC(find(Caus_MDCnonclusteredcorrwithMDC>corrminimum));
                    
                Caus_allclusterscorrwithsuc = Caus_allclusterscorrwithsuc(find(Caus_allclusterscorrwithsuc>corrminimum));
                Caus_nonclusteredcorrwithsuc = Caus_nonclusteredcorrwithsuc(find(Caus_nonclusteredcorrwithsuc>corrminimum));
                    Caus_succlusterscorrwithsuc = Caus_succlusterscorrwithsuc(find(Caus_succlusterscorrwithsuc>corrminimum));
                    Caus_sucnonclusteredcorrwithsuc = Caus_sucnonclusteredcorrwithsuc(find(Caus_sucnonclusteredcorrwithsuc>corrminimum));
                Caus_allclusterscorrwithrew = Caus_allclusterscorrwithrew(find(Caus_allclusterscorrwithrew>corrminimum));
                Caus_nonclusteredcorrwithrew = Caus_nonclusteredcorrwithrew(find(Caus_nonclusteredcorrwithrew>corrminimum));
                    Caus_rewclusterscorrwithrew = Caus_rewclusterscorrwithrew(find(Caus_rewclusterscorrwithrew>corrminimum));
                    Caus_rewnonclusteredcorrwithrew = Caus_rewnonclusteredcorrwithrew(find(Caus_rewnonclusteredcorrwithrew>corrminimum));
            end

            Caus_clustcorrwithcue(1,session) = nanmean(Caus_allclusterscorrwithcue);
            Caus_nonclustcorrwithcue(1,session) = nanmean(Caus_nonclusteredcorrwithcue);
                Caus_cueclustcorrwithcue(1,session) = nanmean(Caus_cueclusterscorrwithcue);
                Caus_cuenonclustcorrwithcue(1,session) = nanmean(Caus_cuenonclusteredcorrwithcue);
            Caus_clustcorrwithmov(1,session) = nanmean(Caus_allclusterscorrwithmov);
            Caus_nonclustcorrwithmov(1,session) = nanmean(Caus_nonclusteredcorrwithmov);
                Caus_movclustcorrwithmov(1,session) = nanmean(Caus_movclusterscorrwithmov);
                Caus_movnonclustcorrwithmov(1,session) = nanmean(Caus_movnonclusteredcorrwithmov);
            Caus_clustcorrwithMDC(1,session) = nanmean(Caus_allclusterscorrwithMDC);
            Caus_nonclustcorrwithMDC(1,session) = nanmean(Caus_nonclusteredcorrwithMDC);
                Caus_MDCclustcorrwithMDC(1,session) = nanmean(Caus_MDCclusterscorrwithMDC);
                Caus_MDCnonclustcorrwithMDC(1,session) = nanmean(Caus_MDCnonclusteredcorrwithMDC);
            Caus_clustcorrwithsuc(1,session) = nanmean(Caus_allclusterscorrwithsuc);
            Caus_nonclustcorrwithsuc(1,session) = nanmean(Caus_nonclusteredcorrwithsuc);
                Caus_succlustcorrwithsuc(1,session) = nanmean(Caus_succlusterscorrwithsuc);
                Caus_sucnonclustcorrwithsuc(1,session) = nanmean(Caus_sucnonclusteredcorrwithsuc);
            Caus_clustcorrwithrew(1,session) = nanmean(Caus_allclusterscorrwithrew);
            Caus_nonclustcorrwithrew(1,session) = nanmean(Caus_nonclusteredcorrwithrew);
                Caus_rewclustcorrwithrew(1,session) = nanmean(Caus_rewclusterscorrwithrew);
                Caus_rewnonclustcorrwithrew(1,session) = nanmean(Caus_rewnonclusteredcorrwithrew);
                
                
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Plasticity Features
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%% Frequency
            
            allspine_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq);
            
            movspine_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(logical(MovementSpines)));

            cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(cluster_ind-Spine1_address));
            
            nonclustered_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(nonclustered-Spine1_address));
            
            cue_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(cue_cluster_ind-Spine1_address));
            
            mov_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(mov_cluster_ind-Spine1_address));
            
            movduringcue_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(movduringcue_cluster_ind-Spine1_address));
            
            presuc_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(presuc_cluster_ind-Spine1_address));
            
            suc_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(suc_cluster_ind-Spine1_address));
            
            rew_cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(rew_cluster_ind-Spine1_address));
            
            Caus_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_cluster_ind-Spine1_address));
            
            Caus_nonclustered_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(causal_nonclustered-Spine1_address));
            
            Caus_cue_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_cue_cluster_ind-Spine1_address));
            
            Caus_mov_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_mov_cluster_ind-Spine1_address));
            
            Caus_movduringcue_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_movduringcue_cluster_ind-Spine1_address));
            
            Caus_presuc_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_presuc_cluster_ind-Spine1_address));
            
            Caus_suc_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_suc_cluster_ind-Spine1_address));
            
            Caus_rew_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_rew_cluster_ind-Spine1_address));
            
            
            %%% Amplitude
            AmpList = cellfun(@(x) nanmedian(x(x<100)), varargin{i}.AllSpineAmpData, 'Uni', false);
            clusterAmp = nanmedian(cat(1,AmpList{cluster_ind-Spine1_address}));
            nonclusteredAmp = nanmedian(cat(1,AmpList{nonclustered-Spine1_address}));
            cueAmp = nanmedian(cat(1,AmpList{cue_cluster_ind-Spine1_address}));
            movAmp = nanmedian(cat(1,AmpList{mov_cluster_ind-Spine1_address}));
            movduringcueAmp = nanmedian(cat(1,AmpList{movduringcue_cluster_ind-Spine1_address}));
            presucAmp = nanmedian(cat(1,AmpList{presuc_cluster_ind-Spine1_address}));
            sucAmp = nanmedian(cat(1,AmpList{suc_cluster_ind-Spine1_address}));
            rewAmp = nanmedian(cat(1,AmpList{rew_cluster_ind-Spine1_address}));
            Caus_clusterAmp = nanmedian(cat(1,AmpList{Caus_cluster_ind-Spine1_address}));
            Caus_nonclusteredAmp = nanmedian(cat(1,AmpList{causal_nonclustered-Spine1_address}));
            Caus_cueAmp = nanmedian(cat(1,AmpList{Caus_cue_cluster_ind-Spine1_address}));
            Caus_movAmp = nanmedian(cat(1,AmpList{Caus_mov_cluster_ind-Spine1_address}));
            Caus_movduringcueAmp = nanmedian(cat(1,AmpList{Caus_movduringcue_cluster_ind-Spine1_address}));
            Caus_presucAmp = nanmedian(cat(1,AmpList{Caus_presuc_cluster_ind-Spine1_address}));
            Caus_sucAmp = nanmedian(cat(1,AmpList{Caus_suc_cluster_ind-Spine1_address}));
            Caus_rewAmp = nanmedian(cat(1,AmpList{Caus_rew_cluster_ind-Spine1_address}));

                ClustAmp(1,session) = nanmean(clusterAmp);
                    NonClusteredAmp(1,session) = nanmean(nonclusteredAmp);
                Caus_ClustAmp(1,session) = nanmean(Caus_clusterAmp);
                    Caus_NonClusteredAmp(1,session) = nanmean(Caus_nonclusteredAmp);
                CueAmp(1,session) = nanmean(cueAmp);
                Caus_CueAmp(1,session) = nanmean(Caus_cueAmp);
                MovAmp(1,session) = nanmean(movAmp);
                Caus_MovAmp(1,session) = nanmean(Caus_movAmp);
                MovDuringCueAmp(1,session) = nanmean(movduringcueAmp);
                Caus_MovDuringCueAmp(1,session) = nanmean(Caus_movduringcueAmp);
                PreSucAmp(1,session) = nanmean(presucAmp);
                Caus_PreSucAmp(1,session) = nanmean(Caus_presucAmp);
                SucAmp(1,session) = nanmean(sucAmp);
                Caus_SucAmp(1,session) = nanmean(Caus_sucAmp);
                RewAmp(1,session) = nanmean(rewAmp);
                Caus_RewAmp(1,session) = nanmean(Caus_rewAmp);
                
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%%%%%%%%%%%%%
                                %%% Dendrites %%%
                                %%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%
            %%% Find which dendrites contain clusters
            %%%%%
            
            DendNum = varargin{i}.NumberofDendrites;
            
            DendswithClusts = [];
            DendswithCausClusts = [];
            DendsnoClusts = [];
            DendswithCueClusts = [];
            DendswithMovClusts = [];
            DendswithMovDuringCueClusts = [];
            DendswithPreSucClusts = [];
            DendswithSucClusts = [];
            DendswithRewClusts = [];
            DendswithCausmovClusts = [];
            DendsnomovClusts = [];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Count the number of clusters on each dendrite
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isfield(varargin{i}, 'SpineDendriteGrouping')
                ClustersoneachDend = cell(length(varargin{i}.SpineDendriteGrouping),1);
                CausalClustersoneachDend = cell(length(varargin{i}.SpineDendriteGrouping),1);
                dcounter = cell(length(varargin{i}.SpineDendriteGrouping),1);
                Cdcounter = cell(length(varargin{i}.SpineDendriteGrouping),1);
                for k = 1:varargin{i}.NumberofDendrites
                    dcounter{k} = 0;
                    Cdcounter{k} = 0;
                end
                for k = 1:length(ClusteredSpines{1,session})
                    if ~isempty(ClusteredSpines{1,session}{k})
                        for m = 1:length(varargin{i}.SpineDendriteGrouping)
                            if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == ClusteredSpines{1,session}{k}(1)))
                                ClustersoneachDend{m}{dcounter{m}+1} = ClusteredSpines{1,session}{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                                dcounter{m} = dcounter{m}+1;
                            end
                        end
                    end
                end
                for k = 1:length(CausalClusteredSpines)
                    if ~isempty(CausalClusteredSpines{k})
                        for m = 1:length(varargin{i}.SpineDendriteGrouping)
                            if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == CausalClusteredSpines{k}(1)))
                                CausalClustersoneachDend{m}{dcounter{m}+1} = CausalClusteredSpines{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                                Cdcounter{m} = Cdcounter{m}+1;
                            end
                        end
                    end
                end
            else
                ClustersoneachDend = {[]};
                CausalClustersoneachDend = {[]};
            end
            

            %%% Find the correlation of clustered vs. non-clustered spines
            %%% with dendritic activity (using pre-subtracted
            %%% spine/dendrite activity correlation heatmaps
             [r_dendsubtracted, ~] = corrcoef([varargin{i}.SynapseOnlyBinarized_DendriteSubtracted', varargin{i}.Dendrite_Binarized']);
            
            corrmattouse = r_dendsubtracted;
            causcorrmattouse = r_dendsubtracted;

            %%% initialize variables
            
            Clusters_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            CausalClusters_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            Nonclustered_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            Noncausal_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            FiltClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            FiltCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            
            CueClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            MovClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            PreSucClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            SucClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            MovDuringCueClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            RewClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            
            CueCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            MovCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            SucCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            RewCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);

            
            for k = 1:varargin{i}.NumberofDendrites
                if useSTATdends
                    usethisdend = StatClass{session}.MovementDends(k); %%% Finds the boolean corresponding to whether this dendrite is movement related or not
                else
                    usethisdend = 1;
                end
                if usethisdend
                    clusteredspinesonthisdend = [];
                    causalclusteredspinesonthisdend = [];
                    if ~isempty(ClustersoneachDend{k})
                        for l = 1:length(ClustersoneachDend{k})
                            clusteredspinesonthisdend = [clusteredspinesonthisdend; ClustersoneachDend{k}{l}];
                        end
                    end
                    if ~isempty(CausalClustersoneachDend{k})
                        for l = 1:length(CausalClustersoneachDend{k})
                            causalclusteredspinesonthisdend = [causalclusteredspinesonthisdend; CausalClustersoneachDend{k}{l}];
                        end
                    end
                    otherspinesonthisdend = varargin{i}.SpineDendriteGrouping{k}; %%% Labels spines by actual count/ROI num
                        nonclusteredcausalspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, causalclusteredspinesonthisdend));
                    otherspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, clusteredspinesonthisdend));
                    Clusters_CorrwithDend(1,k) = nanmean(corrmattouse(clusteredspinesonthisdend, length(varargin{i}.deltaF)+k));
                        CausalClusters_CorrwithDend(1,k) = nanmean(causcorrmattouse(causalclusteredspinesonthisdend, length(varargin{i}.deltaF)+k));
                    Nonclustered_CorrwithDend(1,k) = nanmean(corrmattouse(otherspinesonthisdend, length(varargin{i}.deltaF)+k));
                        Noncausal_CorrwithDend(1,k) = nanmean(causcorrmattouse(nonclusteredcausalspinesonthisdend, length(varargin{i}.deltaF)+k));
                    
                    Filtered_Clusts = clusteredspinesonthisdend(ismember(clusteredspinesonthisdend, cluster_ind-Spine1_address)); %%% Correct for addressing scheme           %%% Apply all the filtering criteria established in the first section of this function
                        Filtered_CausalClusts = causalclusteredspinesonthisdend(ismember(causalclusteredspinesonthisdend, cluster_ind-Spine1_address));
                    FiltClusts_CorrwithDend(1,k) = nanmean(corrmattouse(Filtered_Clusts, length(varargin{i}.deltaF)+k));
                        FiltCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Filtered_CausalClusts, length(varargin{i}.deltaF)+k));
                    CueClusts_CorrwithDend(1,k) = nanmean(corrmattouse(cue_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        CueCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_cue_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                    MovClusts_CorrwithDend(1,k) = nanmean(corrmattouse(mov_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        MovCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_mov_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                    PreSucClusts_CorrwithDend(1,k) = nanmean(corrmattouse(presuc_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        PreSucCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_presuc_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                    SucClusts_CorrwithDend(1,k) = nanmean(corrmattouse(suc_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        SucCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_suc_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                    MovDuringCueClusts_CorrwithDend(1,k) = nanmean(corrmattouse(movduringcue_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        MovDuringCueCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(movduringcue_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                    RewClusts_CorrwithDend(1,k) = nanmean(corrmattouse(rew_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                        RewCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_rew_cluster_ind-Spine1_address, length(varargin{i}.deltaF)+k));
                else
                    continue
                end
            end
            
            ClusteredSpines_CorrwithDend(1,session) = nanmean(Clusters_CorrwithDend);
            FilteredClusteredSpines_CorrwithDend(1,session) = nanmean(FiltClusts_CorrwithDend);
            NonClusteredSpines_CorrwithDend(1,session) = nanmean(Nonclustered_CorrwithDend);
            
            CausalClusteredSpines_CorrwithDend(1,session) = nanmean(CausalClusters_CorrwithDend);
            FilteredCausalClusteredSpines_CorrwithDend(1,session) = nanmean(FiltCausClusts_CorrwithDend);
            NonCausalClusteredSpines_CorrwithDend(1,session) = nanmean(Noncausal_CorrwithDend);

            CueRelClusteredSpines_CorrwithDend(1,session) = nanmean(CueClusts_CorrwithDend);
            MovRelClusteredSpines_CorrwithDend(1,session) = nanmean(MovClusts_CorrwithDend);
            PreSucRelClusteredSpines_CorrwithDend(1,session) = nanmean(PreSucClusts_CorrwithDend);
            SucRelClusteredSpines_CorrwithDend(1,session) = nanmean(SucClusts_CorrwithDend);
            MovDuringCueRelClusteredSpines_CorrwithDend(1,session) = nanmean(MovDuringCueClusts_CorrwithDend);
            RewRelClusteredSpines_CorrwithDend(1,session) = nanmean(RewClusts_CorrwithDend);
            
            CueRelCausalClusteredSpines_CorrwithDend(1,session) = nanmean(CueCausClusts_CorrwithDend);
            MovRelCausalClusteredSpines_CorrwithDend(1,session) = nanmean(MovCausClusts_CorrwithDend);
            SucRelCausalClusteredSpines_CorrwithDend(1,session) = nanmean(SucCausClusts_CorrwithDend);
            RewRelCausalClusteredSpines_CorrwithDend(1,session) = nanmean(RewCausClusts_CorrwithDend);

            if ~isempty(cluster_ind)
                for k = 1:numel(cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == cluster_ind(k)-Spine1_address))
                            DendswithClusts = [DendswithClusts; m];
                        end
                    end
                end
            else
            end
            
            if ~isempty(Caus_cluster_ind)
                for k = 1:numel(Caus_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == Caus_cluster_ind(k)-Spine1_address))
                            DendswithCausClusts = [DendswithCausClusts; m];
                        end
                    end
                end
            else
            end
            
            %%% Count the number of cue-related clustered spines on each
            %%% dendrite
            if ~isempty(cue_cluster_ind)
                for k = 1:numel(cue_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == cue_cluster_ind(k)-Spine1_address))
                            DendswithCueClusts = [DendswithCueClusts; m];
                        end
                    end
                end
            else
            end
            %%% Count the number of mov-related clustered spines on each
            %%% dendrite
            if ~isempty(mov_cluster_ind)
                for k = 1:numel(mov_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == mov_cluster_ind(k)-Spine1_address))
                            DendswithMovClusts = [DendswithMovClusts; m];
                        end
                    end
                end
            else
            end
            if ~isempty(movduringcue_cluster_ind)
                for k = 1:numel(movduringcue_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == movduringcue_cluster_ind(k)-Spine1_address))
                            DendswithMovDuringCueClusts = [DendswithMovDuringCueClusts; m];
                        end
                    end
                end
            else
            end
            if ~isempty(presuc_cluster_ind)
                for k = 1:numel(presuc_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == presuc_cluster_ind(k)-Spine1_address))
                            DendswithPreSucClusts = [DendswithPreSucClusts; m];
                        end
                    end
                end
            else
            end
            if ~isempty(suc_cluster_ind)
                for k = 1:numel(suc_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == suc_cluster_ind(k)-Spine1_address))
                            DendswithSucClusts = [DendswithSucClusts; m];
                        end
                    end
                end
            else
            end
            if ~isempty(rew_cluster_ind)
                for k = 1:numel(rew_cluster_ind)
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == rew_cluster_ind(k)-Spine1_address))
                            DendswithRewClusts = [DendswithRewClusts; m];
                        end
                    end
                end
            else
            end
            if ~isempty(Caus_mov_cluster_ind)
                for k = 1:numel(Caus_mov_cluster_ind)
                    Caus_movAmp(1,k) = nanmean(varargin{i}.AllSpineAmpData{Caus_mov_cluster_ind(k)-Spine1_address});
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == Caus_mov_cluster_ind(k)-Spine1_address))
                            DendswithCausmovClusts = [DendswithCausmovClusts; m];
                        end
                    end
                end
            else
            end

                               
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Build an array of information for each dendrite and
            %%% associated clustering information:
            %%% Col 1;       Col 2:       Col 3;       Col 4;       
            %%% Dend #       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            DendritesArray = [1:varargin{i}.NumberofDendrites]';                                      %%% All dendrites from the current experiment
            allindex = ismember(DendritesArray, DendswithClusts);
            cueindex = ismember(DendritesArray, DendswithCueClusts);
            movindex = ismember(DendritesArray, DendswithMovClusts);                                %%% Logical array of which dendrites contain clusters
            movduringcueindex = ismember(DendritesArray, DendswithMovDuringCueClusts);
            presucindex = ismember(DendritesArray, DendswithPreSucClusts);
            sucindex = ismember(DendritesArray, DendswithSucClusts);
            rewindex = ismember(DendritesArray, DendswithRewClusts);
            
            DendsnoClusts = DendritesArray(allindex ==  0);
            DendsnocueClusts = DendritesArray(cueindex == 0);
            DendsnomovClusts = DendritesArray(movindex == 0);
            DendsnomovduringcueClusts = DendritesArray(movduringcueindex == 0);
            DendsnopresucClusts = DendritesArray(presucindex == 0);
            DendsnosucClusts = DendritesArray(sucindex == 0);
            DendsnorewClusts = DendritesArray(rewindex == 0);
            
            DendNumClust{session} = DendritesArray;                                                 %%% Will be a 4-column array; column 1 is the dendrites index
            for n = 1:length(DendNumClust{session})
                DendNumClust{session}(n,2) = sum(DendswithClusts == DendNumClust{session}(n,1));    %%% Column 2: Counts number of clustered spines on a given dendrite
                DendNumClust{session}(n,3) = sum(DendswithMovClusts == DendNumClust{session}(n,1)); %%% Column 3: Counts number of movement-related clustered spines on a given dendrite 
                DendNumClust{session}(n,4) = length(ClustersoneachDend{n});                         %%% Column 4: Number of separate clusters on each dendrite
                DendNumClust{session}(n,5) = varargin{i}.Dendritic_Frequency(n);                    %%% Column 5: Frequency of dendrite
            end
            
            
                DendswithClusts = unique(DendswithClusts);
                DendsnoClusts = unique(DendsnoClusts);
                DendswithCueClusts = unique(DendswithCueClusts);
                DendswithMovClusts = unique(DendswithMovClusts);
                DendswithMovDuringCueClusts = unique(DendswithMovDuringCueClusts);
                DendswithPreSucClusts = unique(DendswithPreSucClusts);
                DendswithSucClusts = unique(DendswithSucClusts);
                DendswithRewClusts = unique(DendswithRewClusts);
                DendsnomovClusts = unique(DendsnomovClusts);
               
                
                if useSTATdends
                    DendswithClusts = DendswithClusts.*StatClass{session}.MovementDends(DendswithClusts);
                        DendswithClusts = DendswithClusts(logical(DendswithClusts));
                    DendsnoClusts = DendsnoClusts.*StatClass{session}.MovementDends(DendsnoClusts);
                        DendsnoClusts = DendsnoClusts(logical(DendsnoClusts));
                    DendswithCueClusts = DendswithCueClusts.*StatClass{session}.CueDends(DendswithCueClusts);
                        DendswithCueClusts = DendswithCueClusts(logical(DendswithCueClusts));
                    DendswithMovClusts = DendswithMovClusts.*StatClass{session}.MovementDends(DendswithMovClusts);
                        DendswithMovClusts = DendswithMovClusts(logical(DendswithMovClusts));
                    DendswithMovDuringCueClusts = DendswithMovDuringCueClusts.*StatClass{session}.MovementDuringCueDends(DendswithMovDuringCueClusts);
                        DendswithMovDuringCueClusts = DendswithMovDuringCueClusts(logical(DendswithMovDuringCueClusts));
                    DendswithPreSucClusts = DendswithPreSucClusts.*StatClass{session}.PreSuccessDends(DendswithPreSucClusts);
                        DendswithPreSucClusts = DendswithPreSucClusts(logical(DendswithPreSucClusts));
                    DendswithSucClusts = DendswithSucClusts.*StatClass{session}.SuccessDends(DendswithSucClusts);
                        DendswithSucClusts = DendswithSucClusts(logical(DendswithSucClusts));
                    DendswithRewClusts = DendswithRewClusts.*StatClass{session}.RewardDends(DendswithRewClusts);
                        DendswithRewClusts = DendswithRewClusts(logical(DendswithRewClusts));
                    DendsnomovClusts = DendsnomovClusts.*StatClass{session}.MovementDends(DendsnomovClusts);
                        DendsnomovClusts = DendsnomovClusts(logical(DendsnomovClusts));
                    
                    ClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithClusts));
                    NoClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendsnoClusts));
                    CueClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithCueClusts));
                    MovClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithMovClusts));
                    MovDuringCueClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithMovDuringCueClusts));
                    PreSuccessClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithPreSucClusts));
                    SuccessClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithSucClusts));
                    RewardClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithRewClusts));
                    NoMovClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendsnomovClusts));
                    counter = 1;
                    
                    for j = 1:DendNum
                        firstspine = varargin{i}.SpineDendriteGrouping{j}(1);
                        lastspine = varargin{i}.SpineDendriteGrouping{j}(end);

                        if length(varargin{i}.SpineDendriteGrouping{j})>mindendsize
                            if strcmpi(laplaciantouse, 'Normalized')
                                L = varargin{i}.NormalizedLaplacian{j};
                            elseif strcmpi(laplaciantouse, 'Original')
                                L = varargin{i}.LaplacianMatrix{j};
                            end
                            eigenvalues = eig(L);
                            Fiedlerval = min(eigenvalues(~ismember(eigenvalues,min(eigenvalues)))); %%% Finds the second smallest eigenvalue (the Fiedler value, or measure or algebraic connectivity)
                            
                            temporalvalues = eig(Temporal_Laplacian{session}{j});
                            temporalvalues(temporalvalues==min(temporalvalues)) = nan;
                            [TemporalFiedlerval, ~] = min(temporalvalues);
                            
                            if StatClass{session}.MovementDends(j)
                                DendClust_Deg{session}(counter,1) = real(Fiedlerval);
                                DendClust_Deg{session}(counter,2) = real(TemporalFiedlerval);
                                DendClust_Deg{session}(counter,3) = real(SpatioTemporalFiedler{session}(j));
                                DendClust_Deg{session}(counter,4) = varargin{i}.Dendritic_Frequency(j);
                                DendClust_Deg{session}(counter,5) = SessionCorrData(Movement_address, Spine1_address+length(varargin{i}.deltaF)+j);
                                DendClust_Deg{session}(counter,6) = length(varargin{i}.SpineDendriteGrouping{j});
                                counter = counter+1;
                            end
                        else
                            DendClust_Deg{session}(counter,1) = nan;
                            DendClust_Deg{session}(counter,2) = nan;
                            DendClust_Deg{session}(counter,3) = nan;
                            DendClust_Deg{session}(counter,4) = nan;
                            DendClust_Deg{session}(counter,5) = nan;
                            DendClust_Deg{session}(counter,6) = nan;
                            counter = counter+1;                        
                        end
                    end
                else
                    AllDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency);
                    MoveDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(StatClass{session}.MovementDends));
                    NonMoveDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(~StatClass{session}.MovementDends));
                    ClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithClusts));
                    NoClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendsnoClusts));
                    CueClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithCueClusts));
                    MovClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithMovClusts));
                    MovDuringCueClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithMovDuringCueClusts));
                    PreSucClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithPreSucClusts));
                    SucClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithSucClusts));
                    RewClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithRewClusts));
                    NoMovClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendsnomovClusts));
                    counter = 1;
                    
                    for j = 1:DendNum
                        firstspine = varargin{i}.SpineDendriteGrouping{j}(1);
                        lastspine = varargin{i}.SpineDendriteGrouping{j}(end);

                        if length(varargin{i}.SpineDendriteGrouping{j})>mindendsize
                            if strcmpi(laplaciantouse, 'Normalized')
                                L = varargin{i}.NormalizedLaplacian{j};
                            elseif strcmpi(laplaciantouse, 'Original')
                                L = varargin{i}.LaplacianMatrix{j};
                            end
                            eigenvalues = eig(L);
                            Fiedlerval = min(eigenvalues(~ismember(eigenvalues,min(eigenvalues)))); %%% Finds the second smallest eigenvalue (the Fiedler value, or measure or algebraic connectivity)
                            
                            temporalvalues = eig(Temporal_Laplacian{session}{j});
                            temporalvalues(temporalvalues==min(temporalvalues)) = nan;
                            [TemporalFiedlerval, ~] = min(temporalvalues);
                            DendClust_Deg{session}(counter,1) = real(Fiedlerval);
                            DendClust_Deg{session}(counter,2) = real(TemporalFiedlerval);
                            DendClust_Deg{session}(counter,3) = real(SpatioTemporalFiedler{session}(j));
                            DendClust_Deg{session}(counter,4) = varargin{i}.Dendritic_Frequency(j);
                            DendClust_Deg{session}(counter,5) = SessionCorrData(Movement_address, Spine1_address+length(varargin{i}.deltaF)+j);
                            DendClust_Deg{session}(counter,6) = length(varargin{i}.SpineDendriteGrouping{j});
                            counter = counter+1;
                        else
                            DendClust_Deg{session}(counter,1) = nan;
                            DendClust_Deg{session}(counter,2) = nan;
                            DendClust_Deg{session}(counter,3) = nan;
                            DendClust_Deg{session}(counter,4) = nan;
                            DendClust_Deg{session}(counter,5) = nan;
                            DendClust_Deg{session}(counter,6) = nan;
                            counter = counter+1;
                        end
                    end
                end
%             FractionofCluster = cellfun(@(x,y) sum(x(y))/length(y), repmat(MovementSpineDataToUse(session),[1 length(ClusteredSpines)]),ClusteredSpines,'Uni', false);
%             FractionofCausalCluster = cellfun(@(x,y) sum(x(y))/length(y), repmat(MovementSpineDataToUse(session),[1 length(CausalClusteredSpines)]),CausalClusteredSpines,'Uni', false);
%             FractionofClusterThatsMR(1,session) = nanmean(cat(2,FractionofCluster{:}));
%             FractionofCausalClusterThatsMR(1,session) = nanmean(cat(2,FractionofCausalCluster{:})); 


        else                %%% When there is no behavioral data for this session...
            
            
            if isfield(varargin{i}, 'SpineDendriteGrouping')
                for d = 1:varargin{i}.NumberofDendrites
                    firstspine = varargin{i}.SpineDendriteGrouping{d}(1);
                    lastspine = varargin{i}.SpineDendriteGrouping{d}(end);
                end
            else
                if varargin{i}.NumberofDendrites == 1
                    varargin{i}.SpineDendriteGrouping = {1:length(varargin{i}.deltaF)};
                    disp(['File ', varargin{i}.Filename, ' did not have spine-dendrite grouping information, but can be correctly filled in']);
                else
                    disp(['File ', varargin{i}.Filename, ' does NOT have necessary spine-dendrite grouping info!']);
                end
            end

            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%% Spectral analysis of dendrites %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% When no behavioral data is available, simply use
            %%% correlations of calcium traces alone
            
            if dendexclude
                [rsp, ~] = corrcoef(varargin{i}.SynapseOnlyBinarized');
            elseif dendsubtract
                [rsp, ~] = corrcoef(varargin{i}.SynapseOnlyBinarized_DendriteSubtracted');
            else
                [rsp, ~] = corrcoef(varargin{i}.OverallSpineActivity');
            end
            
            corrmat = nan(varargin{i}.NumberofSpines+Spine1_address, varargin{i}.NumberofSpines+Spine1_address);
            
            corrmat(Spine1_address+1:Spine1_address+size(rsp,1),Spine1_address+1:Spine1_address+size(rsp,2)) = rsp;
            
            [SpectralData] = SpectralClustering(varargin{i}, corrmat, StatClass, Choices);
            

            Spatial_Deg{session} = SpectralData.Spatial_Deg;
            Temporal_Deg{session} = SpectralData.Temporal_Deg;
            Spatiotemporal_Deg{session} = SpectralData.Spatiotemporal_Deg;
            Spatiotemporal_Overlap{session} = SpectralData.Spatiotemporal_Overlap;
            
            SpatioTemporalFiedler{session} = SpectralData.SpatioTemporalFiedler;
            
            Temporal_Laplacian{session} = SpectralData.Temporal_Laplacian;

            MeanSpatialDegreeofCueSpines(1,session) = SpectralData.MeanSpatialDegreeofCueSpines;
            MeanTemporalDegreeofCueSpines(1,session) = SpectralData.MeanTemporalDegreeofCueSpines;
            MeanSpatioTemporalDegreeofCueSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofCueSpines;
            MeanSpatialDegreeofMovementSpines(1,session) = SpectralData.MeanSpatialDegreeofMovementSpines;
            MeanTemporalDegreeofMovementSpines(1,session) = SpectralData.MeanTemporalDegreeofMovementSpines;
            MeanSpatioTemporalDegreeofMovementSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofMovementSpines;
            MeanSpatialDegreeofMDCSpines(1,session) = SpectralData.MeanSpatialDegreeofMovementDuringCueSpines;
            MeanTemporalDegreeofMDCSpines(1,session) = SpectralData.MeanTemporalDegreeofMovementDuringCueSpines;
            MeanSpatioTemporalDegreeofMDCSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofMovementDuringCueSpines;
            MeanSpatialDegreeofPreSuccessSpines(1,session) = SpectralData.MeanSpatialDegreeofPreSuccessSpines;
            MeanTemporalDegreeofPreSuccessSpines(1,session) = SpectralData.MeanTemporalDegreeofPreSuccessSpines;
            MeanSpatioTemporalDegreeofPreSuccessSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofPreSuccessSpines;
            MeanSpatialDegreeofSuccessSpines(1,session) = SpectralData.MeanSpatialDegreeofSuccessSpines;
            MeanTemporalDegreeofSuccessSpines(1,session) = SpectralData.MeanTemporalDegreeofSuccessSpines;
            MeanSpatioTemporalDegreeofSuccessSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofSuccessSpines;
            MeanSpatialDegreeofRewardSpines(1,session) = SpectralData.MeanSpatialDegreeofRewardSpines;
            MeanTemporalDegreeofRewardSpines(1,session) = SpectralData.MeanTemporalDegreeofRewardSpines;
            MeanSpatioTemporalDegreeofRewardSpines(1,session) = SpectralData.MeanSpatioTemporalDegreeofRewardSpines;
            
            Dend_Spat_Deg{session} = SpectralData.Dend_Spat_Deg;
            Dend_Temp_Deg{session} = SpectralData.Dend_Temp_Deg;
            Dend_SpatTemp_Deg{session} = SpectralData.Dend_SpatTemp_Deg;      
            
            SpatialDegree_vs_Movement{session} = SpectralData.SpatialDegree_vs_Movement;
            TemporalDegree_vs_Movement{session} = SpectralData.TemporalDegree_vs_Movement;
            SpatiotemporalDegree_vs_Movement{session} = SpectralData.SpatiotemporalDegree_vs_Movement;

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%% Binary Classification of Clusters %%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Make full correlation matrix %%%
            
            if dendexclude
                corrmat = corrcoef([varargin{i}.SynapseOnlyBinarized]');
            elseif dendsubtract
                corrmat = corrcoef([varargin{i}.SynapseOnlyBinarized_DendriteSubtracted]');
            end
%             corrmat = corrcoef([varargin{i}.OverallSpineActivity]');
            
            %%% Causal clusters

            Clustnum = 1;
            tempA = varargin{i}.CausalHeatMap;
            tempB = varargin{i}.CausalHeatMap';
            tempA(isnan(tempA) & ~isnan(tempB)) = tempB(isnan(tempA) & ~isnan(tempB));
            causalmat = tempA;
            
            [HSCs{1,session}, ClusteredSpines{1,session}, CorrelationofClusts, FarClusteredSpines, CausalClusteredSpines] = binaryclusterclass(varargin{i},corrmat, causalmat);
            
            CorrelationofClusters{session} = CorrelationofClusts;
            
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Find indices for clusters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Find indices for movement- and cue-related clusters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%% Correlation indices for synapse-only events
            
            StatClass{session}.MovementSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.CueSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.CueORMovementSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.PreSuccessSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.SuccessSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.MovementDuringCueSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.RewardSpines = zeros(length(varargin{i}.deltaF),1);
            
            StatClass{session}.DendSub_MovementSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.DendSub_CueSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.DendSub_PreSuccessSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.DendSub_SuccessSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.DendSub_MovementDuringCueSpines = zeros(length(varargin{i}.deltaF),1);
            StatClass{session}.DendSub_RewardSpines = zeros(length(varargin{i}.deltaF),1);
            
            [HSCInfo] =  findclusterind(HSCs{1,session}, StatClass{session}, Spine1_address);
            
            hsc_ind = HSCInfo.cluster_ind;
            
               [ClusterInfo]...
                = findclusterind(ClusteredSpines{1,session}, StatClass{session}, Spine1_address);
            
            NumSpinesinCluster = ClusterInfo.NumSpinesinCluster;
            cluster_ind = ClusterInfo.cluster_ind;
            cue_cluster_ind = ClusterInfo.cue_cluster_ind;
            mov_cluster_ind = ClusterInfo.mov_cluster_ind;
            mix_cluster_ind = ClusterInfo.mix_cluster_ind;
            presuc_cluster_ind = ClusterInfo.suc_cluster_ind;
            suc_cluster_ind = ClusterInfo.presuc_cluster_ind;
            movduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind;
            rew_cluster_ind = ClusterInfo.rew_cluster_ind;
            
            %%   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            %%%% Find indices for clusters on separate dendrites
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            [ClusterInfo]...
                = findclusterind(FarClusteredSpines, StatClass{session}, Spine1_address);
            
            NumSpinesinFarCluster = ClusterInfo.NumSpinesinCluster;
            Farcluster_ind = ClusterInfo.cluster_ind;
            Farcue_cluster_ind = ClusterInfo.cue_cluster_ind;
            Farmov_cluster_ind = ClusterInfo.mov_cluster_ind;
            Farmix_cluster_ind = ClusterInfo.mix_cluster_ind;
            Farpresuc_cluster_ind = ClusterInfo.suc_cluster_ind;
            Farsuc_cluster_ind = ClusterInfo.presuc_cluster_ind;
            Farmovduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind;
            Farrew_cluster_ind = ClusterInfo.rew_cluster_ind;
            
            %%   
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            %%%% Find indices for causal clusters
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%% Uncomment the following section to separate cue- and
            %%%% movement-correlated clusters
            
            StatClass{i}.CausalMovementSpines = zeros(length(varargin{i}.deltaF),1);
            
            [ClusterInfo]...
                = findclusterind(CausalClusteredSpines, StatClass{session}, Spine1_address);
            
            NumSpinesinCausalCluster = ClusterInfo.NumSpinesinCluster;
            Caus_cluster_ind = ClusterInfo.cluster_ind;
            Caus_cue_cluster_ind = ClusterInfo.cue_cluster_ind;
            Caus_mov_cluster_ind = ClusterInfo.mov_cluster_ind;
            Caus_mix_cluster_ind = ClusterInfo.mix_cluster_ind;
            Caus_presuc_cluster_ind = ClusterInfo.suc_cluster_ind;
            Caus_suc_cluster_ind = ClusterInfo.presuc_cluster_ind;
            Caus_movduringcue_cluster_ind = ClusterInfo.movduringcue_cluster_ind;
            Caus_rew_cluster_ind = ClusterInfo.rew_cluster_ind;


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%% End index-finding section %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            

            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%% Main variables
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            
            ClusteredSpines{1,session} = ClusteredSpines{1,session}(~cellfun(@isempty,ClusteredSpines{1,session}));
            CausalClusteredSpines = CausalClusteredSpines(~cellfun(@isempty,CausalClusteredSpines));

            NumClusters(1,session) = length(ClusteredSpines{1,session});
            NumCausalClusters(1,session) = length(CausalClusteredSpines);
           
            NumSpinesinCluster(NumSpinesinCluster==0) = NaN;
            MeanNumberofSpinesinEachCluster(1,session) = nanmean(NumSpinesinCluster);
            NumSpinesinCausalCluster(NumSpinesinCausalCluster==0) = NaN;
            MeanNumberofSpinesinEachCausalCluster(1,session) = nanmean(NumSpinesinCausalCluster);
            
            NumberofSpinesinEachMovCluster{1,session} = NaN;
            NumMovClusters(1,session) = NaN;

            
            HighlyCorrelatedMovementRelatedSpines{1,session} = [];
            
            %%% Find number of clustered spines in each category
            
            %%%%%%%%%%%%%%%%%%%            
            %%% All Clustered spines
            %%%%%%%%%%%%%%%%%%%
            
            NumCueRelSpines(1,session) = nan;
            NumMovRelSpines(1,session) = nan;
            FractionofMovRelSpinesPerDendrite{session} = nan;
            MovRelSpinesPer10Microns{session} = nan;
            FractionofSucRelSpinesPerDendrite{session} = nan;
            SucRelSpinesPer10Microns{session} = nan;
            NumCueORMovRelSpines(1,session) = nan;
            NumPreSucRelSpines(1,session) = nan;
            NumSucRelSpines(1,session) = nan;
            NumMovDuringCueRelSpines(1,session) = nan;
            NumRewRelSpines(1,session) = nan;
            NumCausalMovSpines(1,session) = nan;
            
            NumHSCs(1,session) = length(hsc_ind)/denominator;
            NumClustSpines(1,session) = length(cluster_ind)/denominator;
            NumClustCueSpines(1,session) = nan;
            NumClustMovSpines(1,session) = nan;
            NumClustMixSpines(1,session) = nan;
            NumClustPreSucSpines(1,session) = nan;
            NumClustSucSpines(1,session) = nan;
            NumClustMovDuringCueSpines(1,session) = nan;
            NumClustRewSpines(1,session) = nan;
            
            NumFarClustSpines(1,session) = length(Farcluster_ind)/denominator;
            NumFarClustCueSpines(1,session) = nan;
            NumFarClustMovSpines(1,session) = nan;
            NumFarClustMixSpines(1,session) = nan;
            NumFarClustPreSucSpines(1,session) = nan;
            NumFarClustSucSpines(1,session) = nan;
            NumFarClustMovDuringCueSpines(1,session) = nan;
            NumFarClustRewSpines(1,session) = nan;

            NumCausClustSpines(1,session) = length(Caus_cluster_ind)/denominator;
            NumCausClustCueSpines(1,session) = nan;
            NumCausClustMovSpines(1,session) = nan;
            NumCausClustMixSpines(1,session) = nan;
            NumCausClustPreSucSpines(1,session) = nan;
            NumCausClustSucSpines(1,session) = nan;
            NumCausClustMovDuringCueSpines(1,session) = nan;
            NumCausClustRewSpines(1,session) = nan;
            
            
            %%% Distance between spines (standard clusters)
            if ~isempty(ClusteredSpines{1,session})
                allclustlength = nan(1,length(ClusteredSpines{1,session}));
            else
                allclustlength = nan;
            end
            for CS = 1:length(ClusteredSpines{1,session})
                spinecombos = nchoosek(ClusteredSpines{1,session}{CS}, 2); %%% Find all possible combinations of spines in a cluster
                all_clust_distances = zeros(1,size(spinecombos,1));

                for n = 1:size(spinecombos,1)
                    all_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                end
                allclustlength(1,CS) = nanmean(all_clust_distances);
            end

            MeanAllClustLength(1,session) = nanmean(allclustlength);
            MaxAllClustLength(1,session) = nanmax(allclustlength);
            
            %%% Distance between spines ("far" clusters/separate dendrites)
            
            pixpermicron = 4.65;
            if isfield(varargin{i}, 'ZoomValue')
                if varargin{i}.ZoomValue ~= 0
                    pixpermicron = (pixpermicron*varargin{i}.ZoomValue)/12.1;
                end
            end
            
            FarDistanceMap = DistanceMap;
            FarDistanceMap(logical(eye(length(DistanceMap),length(DistanceMap)))) = 0;
            [r,c] = find(isnan(triu(FarDistanceMap)));
            
            for m = 1:length(r)
                spine_pos1 = [varargin{i}.ROIPosition{r(m)+1}(1)+varargin{i}.ROIPosition{r(m)+1}(3)/2, varargin{i}.ROIPosition{r(m)+1}(2)+varargin{i}.ROIPosition{r(m)+1}(4)/2];
                spine_pos2 = [varargin{i}.ROIPosition{c(m)+1}(1)+varargin{i}.ROIPosition{c(m)+1}(3)/2, varargin{i}.ROIPosition{c(m)+1}(2)+varargin{i}.ROIPosition{c(m)+1}(4)/2];
                FarDistanceMap(r(m),c(m)) = (sqrt((spine_pos1(1)-spine_pos2(1)).^2 +(spine_pos1(2)-spine_pos2(2)).^2))/pixpermicron;
            end

            if ~isempty(FarClusteredSpines)
                for CS = 1:length(FarClusteredSpines)
                    if ~isempty(FarClusteredSpines{CS})

                        spinecombos = nchoosek(FarClusteredSpines{CS}, 2); %%% Find all possible combinations of spines in a cluster
                        all_clust_distances = zeros(1,size(spinecombos,1));

                        for n = 1:size(spinecombos,1)
                            all_clust_distances(1,n) = FarDistanceMap(spinecombos(n,1), spinecombos(n,2));
                        end
                        Faralllength = nanmean(all_clust_distances);
                    else
                        Faralllength = nan;
                    end
                end
            else
                Faralllength = [];
            end
            
            MeanAllFarClustLength(1,session) = nanmean(Faralllength);
            
            
            %%% Distance between spines (causal clusters)
            if ~isempty(CausalClusteredSpines)
                for CS = 1:length(CausalClusteredSpines)
                    if ~isempty(CausalClusteredSpines{CS})

                        spinecombos = nchoosek(CausalClusteredSpines{CS}, 2); %%% Find all possible combinations of spines in a cluster
                        all_clust_distances = zeros(1,size(spinecombos,1));

                        for n = 1:size(spinecombos,1)
                            all_clust_distances(1,n) = DistanceMap(spinecombos(n,1), spinecombos(n,2));
                        end
                        Causalllength = nanmean(all_clust_distances);
                    else
                        Causalllength = nan;
                    end
                end
            else
                Causalllength = [];
            end
            
            MeanAllCausalClustLength(1,session) = nanmean(Causalllength);
            if ~isempty(CausalClusteredSpines)
                MaxAllCausalClustLength(1,session) = nanmax(Causalllength);
            end

            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Plasticity Features
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            allspines = Spine1_address+(1:length(varargin{i}.deltaF));
            nonclustered = allspines(~ismember(allspines,cluster_ind));
            causal_nonclustered = allspines(~ismember(allspines,Caus_cluster_ind));
            
            %%% Frequency
            
            allspine_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq);
            
            movspine_freq(1,session) = NaN;
            
            cluster_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(cluster_ind-Spine1_address));
            
            nonclustered_freq(1,session) = nanmedian(varargin{i}.SynapseOnlyFreq(nonclustered-Spine1_address));
                         
            Caus_cluster_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(Caus_cluster_ind-Spine1_address));
            
            Caus_nonclustered_freq(1,session) = nanmedian(varargin{i}.SpikeTimedEvents(causal_nonclustered-Spine1_address));
                        
            
            %%% Amplitude
            AmpList = cellfun(@(x) nanmean(x(x<100)), varargin{i}.AllSpineAmpData, 'Uni', false);
            clusterAmp = nanmean(cat(1,AmpList{cluster_ind-Spine1_address}));
            nonclusteredAmp = nanmean(cat(1,AmpList{nonclustered-Spine1_address}));
            Caus_clusterAmp = nanmean(cat(1,AmpList{Caus_cluster_ind-Spine1_address}));
            Caus_nonclusteredAmp = nanmean(cat(1,AmpList{causal_nonclustered-Spine1_address}));

                ClustAmp(1,session) = nanmean(clusterAmp);
                    NonClusteredAmp(1,session) = nanmean(nonclusteredAmp);
                Caus_ClustAmp(1,session) = nanmean(Caus_clusterAmp);
                    Caus_NonClusteredAmp(1,session) = nanmean(Caus_nonclusteredAmp);
            
            %%
            %%%%%%%%%%%%%%%%%
            %%% Dendrites %%%
            %%%%%%%%%%%%%%%%%
            
            DendNum = varargin{i}.NumberofDendrites; 
            
            %%%%%
            %%% Find which dendrites contain clusters
            %%%%%
            
            DendswithClusts = [];
            DendswithCausClusts = [];
            DendsnoClusts = [];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Count the number of clusters on each dendrite
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if isfield(varargin{i}, 'SpineDendriteGrouping')
                ClustersoneachDend = cell(length(varargin{i}.SpineDendriteGrouping),1);
                CausalClustersoneachDend = cell(length(varargin{i}.SpineDendriteGrouping),1);
                dcounter = cell(length(varargin{i}.SpineDendriteGrouping),1);
                Cdcounter = cell(length(varargin{i}.SpineDendriteGrouping),1);
                for k = 1:varargin{i}.NumberofDendrites
                    dcounter{k} = 0;
                    Cdcounter{k} = 0;
                end
                for k = 1:length(ClusteredSpines{1,session})
                    if ~isempty(ClusteredSpines{1,session}{k})
                        for m = 1:length(varargin{i}.SpineDendriteGrouping)
                            if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == ClusteredSpines{1,session}{k}(1)))
                                ClustersoneachDend{m}{dcounter{m}+1} = ClusteredSpines{1,session}{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                                dcounter{m} = dcounter{m}+1;
                            end
                        end
                    end
                end
                for k = 1:length(CausalClusteredSpines)
                    if ~isempty(CausalClusteredSpines{k})
                        for m = 1:length(varargin{i}.SpineDendriteGrouping)
                            if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == CausalClusteredSpines{k}(1)))
                                CausalClustersoneachDend{m}{dcounter{m}+1} = CausalClusteredSpines{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                                Cdcounter{m} = Cdcounter{m}+1;
                            end
                        end
                    end
                end
            else
                ClustersoneachDend = {[]};
                CausalClustersoneachDend = {[]};
            end
            

            %%% Find the correlation of clustered vs. non-clustered spines
            %%% with dendritic activity (using pre-subtracted
            %%% spine/dendrite activity correlation heatmaps
            
            spinedatatouse = varargin{i}.SynapseOnlyBinarized_DendriteSubtracted;
            
             [r_dendsubtracted, ~] = corrcoef([spinedatatouse', varargin{i}.Dendrite_Binarized']);
            
            corrmattouse = r_dendsubtracted;
            causcorrmattouse = r_dendsubtracted;

            %%% initialize variables
            Clusters_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            CausalClusters_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            Nonclustered_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            Noncausal_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            FiltClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            FiltCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            MovClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites);
            MovCausClusts_CorrwithDend = nan(1,varargin{i}.NumberofDendrites); 
            
            for k = 1:varargin{i}.NumberofDendrites
                    clusteredspinesonthisdend = [];
                    causalclusteredspinesonthisdend = [];
                    if ~isempty(ClustersoneachDend{k})
                        for l = 1:length(ClustersoneachDend{k})
                            clusteredspinesonthisdend = [clusteredspinesonthisdend; ClustersoneachDend{k}{l}];
                        end
                    end
                    if ~isempty(CausalClustersoneachDend{k})
                        for l = 1:length(CausalClustersoneachDend{k})
                            causalclusteredspinesonthisdend = [causalclusteredspinesonthisdend; CausalClustersoneachDend{k}{l}];
                        end
                    end
                    otherspinesonthisdend = varargin{i}.SpineDendriteGrouping{k}; %%% Labels spines by actual count/ROI num
                        nonclusteredcausalspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, causalclusteredspinesonthisdend));
                    otherspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, clusteredspinesonthisdend));
                    Clusters_CorrwithDend(1,k) = nanmean(corrmattouse(clusteredspinesonthisdend, length(varargin{i}.deltaF)+k));
                        CausalClusters_CorrwithDend(1,k) = nanmean(causcorrmattouse(causalclusteredspinesonthisdend, length(varargin{i}.deltaF)+k));
                    Nonclustered_CorrwithDend(1,k) = nanmean(corrmattouse(otherspinesonthisdend, length(varargin{i}.deltaF)+k));
                        Noncausal_CorrwithDend(1,k) = nanmean(causcorrmattouse(nonclusteredcausalspinesonthisdend, length(varargin{i}.deltaF)+k));
                    
                    Filtered_Clusts = clusteredspinesonthisdend(ismember(clusteredspinesonthisdend, cluster_ind-Spine1_address)); %%% Correct for addressing scheme           %%% Apply all the filtering criteria established in the first section of this function
                        Filtered_CausalClusts = causalclusteredspinesonthisdend(ismember(causalclusteredspinesonthisdend, cluster_ind-Spine1_address));
                    FiltClusts_CorrwithDend(1,k) = nanmean(corrmattouse(Filtered_Clusts, length(varargin{i}.deltaF)+k));
                        FiltCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Filtered_CausalClusts, length(varargin{i}.deltaF)+k));
            end
            
            ClusteredSpines_CorrwithDend(1,session) = nanmean(Clusters_CorrwithDend);
            FilteredClusteredSpines_CorrwithDend(1,session) = nanmean(FiltClusts_CorrwithDend);
            NonClusteredSpines_CorrwithDend(1,session) = nanmean(Nonclustered_CorrwithDend);
            
            CausalClusteredSpines_CorrwithDend(1,session) = nanmean(CausalClusters_CorrwithDend);
            FilteredCausalClusteredSpines_CorrwithDend(1,session) = nanmean(FiltCausClusts_CorrwithDend);
            NonCausalClusteredSpines_CorrwithDend(1,session) = nanmean(Noncausal_CorrwithDend);
            
            %%% Find amplitude for each cluster, and associate with its
            %%% parent dendrite
            
            if ~isempty(cluster_ind)
                for k = 1:numel(cluster_ind)
                    clusterAmp(1,k) = nanmean(varargin{i}.AllSpineAmpData{cluster_ind(k)-Spine1_address});
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == cluster_ind(k)-Spine1_address))
                            DendswithClusts = [DendswithClusts; m];
                        end
                    end
                end
            else
                clusterAmp = nan;
            end
            
            if ~isempty(Caus_cluster_ind)
                for k = 1:numel(Caus_cluster_ind)
                    Caus_clusterAmp(1,k) = nanmean(varargin{i}.AllSpineAmpData{Caus_cluster_ind(k)-Spine1_address});
                    for m = 1:length(varargin{i}.SpineDendriteGrouping)
                        if ~isempty(find(varargin{i}.SpineDendriteGrouping{m} == Caus_cluster_ind(k)-Spine1_address))
                            DendswithCausClusts = [DendswithCausClusts; m];
                        end
                    end
                end
            else
                Caus_clusterAmp = nan;
            end
            
            %%% Count the number of mov-related clustered spines on each
            %%% dendrite
            
                               
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Build an array of information for each dendrite and
            %%% its associated clustering information:
            %%% Col 1;       Col 2:       Col 3;       Col 4;       
            %%% Dend #       
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            DendritesArray = [1:varargin{i}.NumberofDendrites]';                                    %%% All dendrites from the current experiment
            allindex = ismember(DendritesArray, DendswithClusts);
            DendsnoClusts = DendritesArray(allindex ==  0);
            
            DendNumClust{session} = DendritesArray;                                                 %%% Will be a 4-column array; column 1 is the dendrites index
            for n = 1:length(DendNumClust{session})
                DendNumClust{session}(n,2) = sum(DendswithClusts == DendNumClust{session}(n,1));    %%% Column 2: Counts number of clustered spines on a given dendrite
                DendNumClust{session}(n,3) = nan;                                                   %%% Column 3: Counts number of movement-related clustered spines on a given dendrite 
                DendNumClust{session}(n,4) = length(ClustersoneachDend{n});                         %%% Column 4: Number of separate clusters on each dendrite
                DendNumClust{session}(n,5) = varargin{i}.Dendritic_Frequency(n);                    %%% Column 5: Frequency of dendrite
            end
            
            
                DendswithClusts = unique(DendswithClusts);
                DendsnoClusts = unique(DendsnoClusts);               
                
                AllDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency);
                MoveDendFreq(1,session) = nan;
                NonMoveDendFreq(1,session) = nan;
                ClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendswithClusts));
                NoClustDendFreq(1,session) = nanmean(varargin{i}.Dendritic_Frequency(DendsnoClusts));
                CueClustDendFreq(1,session) = nan;
                MovClustDendFreq(1,session) = nan;
                SucClustDendFreq(1,session) = nan;
                RewClustDendFreq(1,session) = nan;
                NoMovClustDendFreq(1,session) = nan;
                counter = 1;

                for j = 1:DendNum
                    firstspine = varargin{i}.SpineDendriteGrouping{j}(1);
                    lastspine = varargin{i}.SpineDendriteGrouping{j}(end);

                    if length(varargin{i}.SpineDendriteGrouping{j})>mindendsize
                        if strcmpi(laplaciantouse, 'Normalized')
                            L = varargin{i}.NormalizedLaplacian{j};
                        elseif strcmpi(laplaciantouse, 'Original')
                            L = varargin{i}.LaplacianMatrix{j};
                        end
                        eigenvalues = eig(L);
                        Fiedlerval = min(eigenvalues(~ismember(eigenvalues,min(eigenvalues)))); %%% Finds the second smallest eigenvalue (the Fiedler value, or measure of algebraic connectivity)

                        temporalvalues = eig(Temporal_Laplacian{session}{j});
                        temporalvalues(temporalvalues==min(temporalvalues)) = nan;
                        [TemporalFiedlerval, ~] = min(temporalvalues);
                        DendClust_Deg{session}(counter,1) = real(Fiedlerval);
                        DendClust_Deg{session}(counter,2) = real(TemporalFiedlerval);
                        DendClust_Deg{session}(counter,3) = real(SpatioTemporalFiedler{session}(j));
                        DendClust_Deg{session}(counter,4) = varargin{i}.Dendritic_Frequency(j);
                        DendClust_Deg{session}(counter,5) = nan;
                        DendClust_Deg{session}(counter,6) = length(varargin{i}.SpineDendriteGrouping{j});
                        counter = counter+1;
                    else
                        DendClust_Deg{session}(counter,1) = nan;
                        DendClust_Deg{session}(counter,2) = nan;
                        DendClust_Deg{session}(counter,3) = nan;
                        DendClust_Deg{session}(counter,4) = nan;
                        DendClust_Deg{session}(counter,5) = nan;
                        DendClust_Deg{session}(counter,6) = nan;
                        counter = counter+1;
                    end
                end
        end
    end
    

    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% Plots %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %%% Color Information %%
    %%%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.45 0.8 0.35];  green = [0.00 0.43 0.23];
    lblue = [0.30 0.65 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    pink = [0.9 0.6 0.6];       lpurple  = [0.7 0.15 1];
    red = [0.85 0.11 0.14];     black = [0.1 0.1 0.15];
    dred = [0.6 0 0];          dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 

    %%%%%%%%%%%%%%%%%%%%%%%


    scrsz = get(0, 'ScreenSize');
    
    %%%%%%%%%%%%%%%%
    %%% Figure 1 %%%
    %%% Correlation of Clustered vs. Non-clustered spines with behavioral
    %%% features %%%
    %%%%%%%%%%%%%%%%
    %%
    figure('Position', scrsz);
    subplot(2,5,1);
    plot(clustcorrwithcue, '-o','Color', black, 'MarkerFaceColor', 'k', 'Linewidth', 2); hold on; % plot(cueanticorr, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'LineWidth', 2); 
    plot(nonclustcorrwithcue, '-o', 'MarkerFaceColor', dred,'Color', dred, 'Linewidth', 2);
    plot(cueclustcorrwithcue, '-o', 'MarkerFaceColor', blue,'Color', blue, 'Linewidth', 2);
    plot(cuenonclustcorrwithcue, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Correlation with cue');
    legend({'All Clustered', 'Nonclustered', 'Clust Mov-rel', 'NClust mov-rel'}, 'Location', 'NW')
    
    %%%%%%%%%%%%%%%
    %%
    
    subplot(2,5,2)
    plot(clustcorrwithMDC, '-o', 'Color', black, 'MarkerFaceColor', 'k', 'Linewidth', 2); hold on;
    plot(nonclustcorrwithMDC, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2);
    plot(MDCclustcorrwithMDC, '-o', 'Color', blue, 'MarkerFaceColor', blue, 'Linewidth', 2)
    plot(MDCnonclustcorrwithMDC, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'Linewidth', 2)
    title('Correlation with MDC');
    legend({'All Clustered', 'Nonclustered', 'Clust Mov-rel', 'NClust mov-rel'}, 'Location', 'NW')

    %%%%%%%%%%%%%%%
    %%
   
    
    subplot(2,5,3);
    plot(clustcorrwithmov, '-o','Color', black, 'MarkerFaceColor', 'k', 'Linewidth', 2); hold on; % plot(clustanticorr, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'LineWidth', 2);
    plot(nonclustcorrwithmov, '-o', 'MarkerFaceColor',dred, 'Color', dred, 'Linewidth', 2)
    plot(movclustcorrwithmov, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2)
    plot(movnonclustcorrwithmov, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2)
    title('Correlation with movement')
    legend({'All Clustered', 'Nonclustered', 'Clust Mov-rel', 'NClust mov-rel'}, 'Location', 'NW')
    
    
    %%
   
    
    subplot(2,5,4);
    plot(clustcorrwithsuc, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(nonclustcorrwithsuc, '-o','Color', dred, 'MarkerFaceColor',dred, 'Linewidth', 2)
    plot(succlustcorrwithsuc, '-o','Color', blue, 'MarkerFaceColor',blue, 'Linewidth', 2)
    plot(sucnonclustcorrwithsuc, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'Linewidth', 2)
    title('Correlation with rewarded presses');
    legend({'All Clustered', 'Nonclustered', 'Clust Mov-rel', 'NClust mov-rel'}, 'Location', 'NW')
    
    %%
    
    subplot(2,5,5)
    plot(clustcorrwithrew, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(nonclustcorrwithrew, '-o','Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2);
    plot(rewclustcorrwithrew, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2);
    plot(rewnonclustcorrwithrew, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Correlation with reward');
    legend({'All Clustered', 'Nonclustered', 'Clust Mov-rel', 'NClust mov-rel'}, 'Location', 'NW')
    
    %%
    
    subplot(2,5,6)
    plot(Caus_clustcorrwithcue, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;% plot(causalclustanticorr, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'LineWidth', 2);
    plot(Caus_nonclustcorrwithcue, '-o', 'MarkerFaceColor',dred, 'Color', dred, 'Linewidth', 2)
    plot(Caus_cueclustcorrwithcue, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2)
    plot(Caus_cuenonclustcorrwithcue, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Causal Correlation with Cue');
    
    
    %%
    
    subplot(2,5,7)
    plot(Caus_clustcorrwithMDC,  '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(Caus_nonclustcorrwithMDC, '-o', 'MarkerFaceColor', dred, 'Color', dred, 'Linewidth', 2)
    plot(Caus_MDCclustcorrwithMDC, '-o', 'MarkerFaceColor', blue, 'Color', blue, 'Linewidth', 2);
    plot(Caus_MDCnonclustcorrwithMDC, '-o', 'MarkerFaceColor', gray, 'Color', gray', 'Linewidth', 2);
    
    %%
    
    subplot(2,5,8)
    plot(Caus_clustcorrwithmov, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(Caus_nonclustcorrwithmov, '-o', 'MarkerFaceColor',dred, 'Color', dred, 'Linewidth', 2)
    plot(Caus_movclustcorrwithmov, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2);
    plot(Caus_movnonclustcorrwithmov, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Causal Correlation with Mov');
    
    %%
    
    subplot(2,5,9)
    plot(Caus_clustcorrwithsuc, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(Caus_nonclustcorrwithsuc, '-o', 'MarkerFaceColor',dred, 'Color', dred, 'Linewidth', 2)
    plot(Caus_succlustcorrwithsuc, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2);
    plot(Caus_sucnonclustcorrwithsuc, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Causal Correlation with Rewarded Presses');
    
    %%
    
    subplot(2,5,10)
    plot(Caus_clustcorrwithrew, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
    plot(Caus_nonclustcorrwithrew, '-o', 'MarkerFaceColor',dred, 'Color', dred, 'Linewidth', 2)
    plot(Caus_rewclustcorrwithrew, '-o', 'MarkerFaceColor',blue, 'Color', blue, 'Linewidth', 2);
    plot(Caus_rewnonclustcorrwithrew, '-o', 'MarkerFaceColor', gray, 'Color', gray, 'Linewidth', 2);
    title('Causal Correlation with Reward');
    
    %%
    %%%%%%%%%%%%
    %%% Figure 2
    %%% Plasticity features
    %%%%%%%%%%%%
    
    figure('Position', scrsz); subplot(2,3,1); 
    plot(cluster_freq, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2)
    hold on; plot(Caus_cluster_freq, '-o', 'Color', dred,'MarkerFaceColor', dred, 'Linewidth', 2);
    hold on; plot(nonclustered_freq, '-o', 'Color', lpurple, 'MarkerFaceColor', lpurple, 'Linewidth', 2);
    plot(Caus_nonclustered_freq, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2);
    legend({'Clustered Spines', 'Causal Clusters', 'NonClustered', 'C nonclustered'})
    ylabel('Frequency of Clustered Spines')
    xlabel('Session')
    
    subplot(2,3,2); 
    plot(ClustAmp, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on; plot(MovAmp, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2); 
    plot(Caus_ClustAmp, '--o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); 
    plot(NonClusteredAmp, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2);
    plot(Caus_NonClusteredAmp, '--o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2);
    legend({'All', 'Mvmnt Rel.', 'Caus', 'Caus mov'})
    ylabel('Amp. of Clustered Spines');
    xlabel('Session')
    
    subplot(2,3,3); 
    plot(AllDendFreq, '-o', 'Color', gray, 'MarkerFaceColor', gray); hold on
    plot(MoveDendFreq, '-o', 'Color', black, 'MarkerFaceColor', black)
    plot(NonMoveDendFreq, '-o', 'Color', red, 'MarkerFaceColor', red)
%     plot(ClustDendFreq, '-o','Color', gray, 'MarkerFaceColor', gray, 'Linewidth', 2); hold on; 
%     plot(NoClustDendFreq, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2)
%     plot(CueClustDendFreq, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2);
%     plot(MovClustDendFreq, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); % plot(NoMovClustDendFreq, '-o', 'Color', lpurple, 'MarkerFaceColor', lpurple, 'Linewidth', 2); 
%     plot(SucClustDendFreq, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2);
%     plot(RewClustDendFreq, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2);
%     legend({'Dends w/ Clusts', 'Dends no Clusts', 'Dends w/ CueClusts', 'Dends w/ MovClusts', 'Dends w/ SucClusts', 'Dends w/ RewClusts'})
    legend({'All Dends', 'Move Dends', 'Non mov dends'})
    ylabel('Dendrite Frequency')
    xlabel('Session')
    
    subplot(2,3,4)
    for s = 1:length(DendNumClust)
        if ~isempty(DendNumClust{s})
            for p = 1:size(DendNumClust{s},1)
                plot(DendNumClust{s}(p,2), DendNumClust{s}(p,5), 'o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
            end
        end
    end
    xlabel('# of Clustered Spines')
    ylabel('Dendritic Freq.')
    
    subplot(2,3,5)
    for s = 1:length(DendNumClust)
        if ~isempty(DendNumClust{s})
            for p = 1:size(DendNumClust{s},1)
                plot(DendNumClust{s}(p,3), DendNumClust{s}(p,5), 'o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
            end
        end
    end
    xlabel('# of Mov-related Clustered Spines')
    ylabel('Dendritic Freq.')
    
    subplot(2,3,6)
    for s = 1:length(DendNumClust)
        if ~isempty(DendNumClust{s})
            for p = 1:size(DendNumClust{s},1)
                plot(DendNumClust{s}(p,4), DendNumClust{s}(p,5), 'o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); hold on;
            end
        end
    end
    xlabel('# of Clusters on Dend')
    ylabel('Dendritic Freq.')
    
    %%
    %%%%%%%%%%%%%
    %%% Figure 3
    %%% Number of spine types
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure('Position', scrsz)
   
    sub1 = 3;
    sub2 = 3;
    
        subplot(sub1,sub2,1)
    plot(NumCueRelSpines, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen,'Linewidth', 2); hold on;
    plot(NumMovRelSpines, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2);
    plot(cell2mat(cellfun(@nanmean, FractionofMovRelSpinesPerDendrite, 'uni', false)), '--o', 'Color', black, 'MarkerFaceColor', gray, 'Linewidth', 2);
    plot(NumCueORMovRelSpines, '--o', 'Color', red, 'MarkerFaceColor', red, 'Linewidth', 2); 
    plot(NumPreSucRelSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2);
    plot(NumSucRelSpines, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2);
    plot(cell2mat(cellfun(@nanmean, FractionofSucRelSpinesPerDendrite, 'uni', false)), '--o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2);
    plot(NumMovDuringCueRelSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2);
    plot(NumRewRelSpines, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2);
    plot(NumCausalMovSpines, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2)
    legend({'Cue Rel', 'Mov Rel (/field)', 'Mov Rel (/dend)', 'MovORCue Rel', 'PreSuc Rel', 'Suc Rel (/field)','Suc Rel (/dend)', 'MovDuringCue','Rew Rel','Caus Mov Rel'}, 'Location', 'NorthEast');
    xlabel('Session','Fontsize',14);
    ylabel('Fraction of spines','Fontsize',14);
    title('Classes of Spines', 'Fontsize',14);
            pos = get(gca,'Position');
            axes('Position', [pos(1)+0.2*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)]);
            plot(cell2mat(cellfun(@nanmean, MovRelSpinesPer10Microns, 'uni', false)), '--^', 'Color', lgray, 'MarkerFaceColor', lgray, 'Linewidth', 2); hold on;
            plot(cell2mat(cellfun(@nanmean, SucRelSpinesPer10Microns, 'uni', false)), '--^', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2);

        subplot(sub1,sub2,2)
    plot(NumHSCs, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(NumClustSpines, '-o','Color', black, 'MarkerFaceColor', black, 'Linewidth', 2); 
    plot(NumCausClustSpines, '-o', 'Color', dred, 'MarkerFaceColor', dred, 'Linewidth', 2);
    plot(NumFarClustSpines, '-o', 'Color', gray, 'MarkerFaceColor', gray, 'Linewidth', 2);
    legend({'HSCs','Clustered Spines', 'Caus Clustered Spines', 'Far Clustered Spines'}, 'Location', 'NorthEast');
    xlabel('Session','Fontsize',14);
    ylabel('Fraction of spines','Fontsize',14);
    title('Number of clustered spines', 'Fontsize', 14);
    
        subplot(sub1,sub2,3)
    plot(MeanNumberofSpinesinEachCluster, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple); hold on
    plot(MeanNumberofSpinesinEachCausalCluster, '-o', 'Color', gray, 'Linewidth', 2, 'MarkerFaceColor', gray)
    plot(NumClusters, '-ok', 'Linewidth', 2, 'MarkerFaceColor', 'k')
    plot(NumCausalClusters, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue)
    xlabel('Session', 'Fontsize', 14);
    ylabel('Raw Number', 'Fontsize', 14);
    legend({'Number of spines in each cluster', 'Num sp in each caus clust', 'Number of Clusters', 'Num Caus Clust'})
    title('Quantification of clusters', 'Fontsize', 14)
    
        subplot(sub1,sub2,4)
    plot(PercentCueRelDends, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(PercentMovRelDends, '-o', 'Color', black, 'MarkerFaceColor', black,'Linewidth', 2)
    plot(PercentPreSucRelDends, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2);
    plot(PercentSucRelDends, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(PercentMovDuringCueRelDends, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(PercentRewRelDends, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2)
    xlabel('Session', 'Fontsize', 14)
    ylabel('Fraction of Dendrites', 'Fontsize', 14)
    legend({'Cue rel dends', 'Mov rel dends', 'Suc rel dends', 'Rew rel dends'})
    title([{'Fraction of dendrites that'}, {'are (function)-related'}], 'Fontsize', 14)
    
        subplot(sub1,sub2,5)
    plot(NumClustCueSpines, '-o','Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
        plot(NumCausClustCueSpines, '--o','Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(NumClustMovSpines, '-o','Color', black, 'MarkerFaceColor', black, 'LineWidth', 2)
        plot(NumCausClustMovSpines, '--o','Color', black, 'MarkerFaceColor', black, 'LineWidth', 2)
    plot(NumClustMixSpines, '-o','Color', red, 'MarkerFaceColor', red, 'Linewidth', 2);
        plot(NumCausClustMixSpines, '--o','Color', red, 'MarkerFaceColor', red, 'LineWidth', 2)
    plot(NumClustPreSucSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2)
        plot(NumCausClustPreSucSpines, '--o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2)
    plot(NumClustSucSpines, '-o','Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
        plot(NumCausClustSucSpines, '--o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(NumClustMovDuringCueSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
        plot(NumCausClustMovDuringCueSpines, '--o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(NumClustRewSpines, '-o','Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2)
        plot(NumCausClustRewSpines, '--o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2)
    xlabel('Session', 'Fontsize', 14)
    ylabel('Fraction of Spines', 'Fontsize',14)
    title('Classes of Clustered Spines', 'Fontsize', 14)
    legend({'Cue Clust', 'Mov Clust', 'Mix Clust','PreSuc Clust', 'Suc Clust', 'MovDuringCue Clust', 'Rew Clust'})
    
    
            subplot(sub1, sub2, 6)
    plot(cell2mat(cellfun(@nanmean, NumberofSpinesinEachMovCluster, 'Uni', false)), '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple); hold on
    plot(NumMovClusters, '-ok', 'Linewidth', 2, 'MarkerFaceColor', 'k')
    xlabel('Session', 'Fontsize', 14);
    ylabel('Raw Number', 'Fontsize', 14);
    legend({'Number of spines in each mov cluster', 'Number of Clusters'})
    title('Quantification of movement clusters', 'Fontsize', 14)
    
            subplot(sub1,sub2,7)
    plot(NumFarClustCueSpines, '-o','Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(NumFarClustMovSpines, '-o','Color', black, 'MarkerFaceColor', black, 'LineWidth', 2)
    plot(NumFarClustMixSpines, '-o','Color', red, 'MarkerFaceColor', red, 'Linewidth', 2);
    plot(NumFarClustPreSucSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2)
    plot(NumFarClustSucSpines, '-o','Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(NumFarClustMovDuringCueSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(NumFarClustRewSpines, '-o','Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2)
    xlabel('Session', 'Fontsize', 14)
    ylabel('Fraction of Spines', 'Fontsize',14)
    title('Classes of Far-Clustered Spines', 'Fontsize', 14)
    legend({'Cue Clust', 'Mov Clust', 'Mix Clust','PreSuc Clust', 'Suc Clust', 'MovDuringCue Clust', 'Rew Clust'})
    
        subplot(sub1,sub2,8)
    FractionofCueSpinesThatAreClustered(FractionofCueSpinesThatAreClustered == Inf) = NaN;
    FractionofMovementSpinesThatAreClustered(FractionofMovementSpinesThatAreClustered == Inf) = NaN;
    FractionofPreSuccessSpinesThatAreClustered(FractionofPreSuccessSpinesThatAreClustered == Inf) = NaN;
    FractionofSuccessSpinesThatAreClustered(FractionofSuccessSpinesThatAreClustered == Inf) = NaN;
    FractionofMovementDuringCueSpinesThatAreClustered(FractionofMovementDuringCueSpinesThatAreClustered == Inf) = NaN;
    FractionofRewardSpinesThatAreClustered(FractionofRewardSpinesThatAreClustered == Inf) = NaN;
    
    plot(FractionofCueSpinesThatAreClustered, 'Color', lgreen, 'Linewidth', 2); hold on;
    plot(FractionofMovementSpinesThatAreClustered, 'Color', black, 'Linewidth', 2); 
    plot(FractionofPreSuccessSpinesThatAreClustered, 'Color', bgreen, 'Linewidth', 2);
    plot(FractionofSuccessSpinesThatAreClustered, 'Color', lblue, 'Linewidth', 2);
    plot(FractionofMovementDuringCueSpinesThatAreClustered, 'Color', green, 'Linewidth', 2);
    plot(FractionofRewardSpinesThatAreClustered, 'Color', purple, 'Linewidth', 2);
    xlabel('Session', 'Fontsize', 14)
    ylabel('Fraction of Spines', 'Fontsize',14)
    title([{'Fraction of (function) spines'},{'that are clustered'}], 'Fontsize', 14)
    legend({'Cue Clust', 'Mov Clust', 'PreSuc Clust', 'Suc Clust', 'MovDuringCue Clust', 'Rew Clust'})
    
    subplot(sub1,sub2, 9); hold on;
    plot(cell2mat(cellfun(@nanmean, AllSpineReliability, 'uni', false)), 'ok', 'MarkerFaceColor', 'k')
    plot(cell2mat(cellfun(@nanmean, MovementSpineReliability, 'uni', false)), 'ok', 'MarkerFaceColor', 'g')
    

    
    %%
    %%%%%%%%%%%%
    %%% Figure 4:
    %%%
    %%% Correlation of spine types with dendrites
    %%%%%%%%%%%%%
    
    figure('Position', scrsz);hold on;
    
    subplot(2,2,1)
    plot(cell2mat(cellfun(@nanmean, CorrelationofClusters, 'Uni', false)), 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2)
    
    xlabel('Session', 'Fontsize', 14)
    ylabel('Correlation of Clustered Spines', 'Fontsize', 14)
    title('Mean Correlation of Clustered Spines', 'Fontsize', 14)
    
    subplot(2,2,2)
    plot(ClusteredSpines_CorrwithDend, '-ok', 'LineWidth', 3, 'MarkerFaceColor', 'k'); hold on
    plot(FilteredClusteredSpines_CorrwithDend, '--o', 'Color', black, 'LineWidth', 2, 'MarkerFaceColor', orange);
    plot(CausalClusteredSpines_CorrwithDend, '-o', 'Color', red, 'Linewidth', 2, 'MarkerFaceColor', red);
    plot(FilteredCausalClusteredSpines_CorrwithDend, '--o', 'Color', red, 'Linewidth', 2, 'MarkerFaceColor', red);
    plot(NonClusteredSpines_CorrwithDend, '-o','Color', gray, 'LineWidth', 2, 'LineWidth', 2, 'MarkerFaceColor', gray)

    legend({'All Clustered', 'Filtered Clustered', 'Causal Clustered','Filtered Causal Clustered', 'Non-Clustered'})
    xlabel('Session')
    ylabel('Correlation with Dendrite', 'Fontsize', 14)
    title('Correlation of Different Spine Types with Dendritic Activity', 'Fontsize', 14)
    
    subplot(2,2,3)
    plot(CueRelClusteredSpines_CorrwithDend, '-o', 'Color', lgreen, 'Linewidth', 2, 'MarkerFaceColor', lgreen); hold on;
    plot(MovRelClusteredSpines_CorrwithDend, '-o', 'Color', black, 'LineWidth', 2, 'MarkerFaceColor', black);
    plot(PreSucRelClusteredSpines_CorrwithDend, '-o', 'Color', bgreen, 'Linewidth', 2, 'MarkerFaceColor', bgreen);
    plot(SucRelClusteredSpines_CorrwithDend, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue)
    plot(MovDuringCueRelClusteredSpines_CorrwithDend, '-o', 'Color', green, 'Linewidth', 2, 'MarkerFaceColor', green);
    plot(RewRelClusteredSpines_CorrwithDend, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple)
    legend({'Cue-rel Clusters', 'Mov-rel clusters', 'PreSuc','Suc-rel clusters', 'MovDuringCue', 'Rew-rel clusters'})
    xlabel('Session')
    ylabel('Correlation with Dendrite')
    title('Correlation of Different Spine Types with Dendritic Activity', 'Fontsize', 14)

    %%
    %%% Figure 5;
    %%%
    %%% Spectral analysis of clusters
    
    figure('Position', scrsz)
    MeanSpatialDegree = nan(1,14);
    MeanTemporalDegree = nan(1,14);
    MeanSpatioTemporalDegree = nan(1,14);
    DendriteClusteringDegree = nan(1,14);
    TemporalClusteringDegree = nan(1,14);
    SpatioTemporalClusteringDegree = nan(1,14);
    
    for i = 1:14
        MeanSpatialDegree(1,i) = nanmean(Dend_Spat_Deg{i});
        MeanTemporalDegree(1,i) = nanmean(Dend_Temp_Deg{i});
        MeanSpatioTemporalDegree(1,i) = nanmean(Dend_SpatTemp_Deg{i});
        if ~isempty(DendClust_Deg{i})
            DendriteClusteringDegree(1,i) = nanmean(DendClust_Deg{i}(:,1));
            TemporalClusteringDegree(1,i) = nanmean(DendClust_Deg{i}(:,2));
            SpatioTemporalClusteringDegree(1,i) = nanmean(DendClust_Deg{i}(:,3));
        else
            DendriteClusteringDegree(1,i) = nan;
            TemporalClusteringDegree(1,i) = nan;
            SpatioTemporalClusteringDegree(1,i) = nan;
        end
        MeanSpatialDegree_vs_Movement(1,i) = nanmean(SpatialDegree_vs_Movement{i});
        MeanTemporalDegree_vs_Movement(1,i) = nanmean(TemporalDegree_vs_Movement{i});
        MeanSpatioTemporalDegree_vs_Movement(1,i) = nanmean(SpatiotemporalDegree_vs_Movement{i});
        MeanSpatioTemporalOverlap(1,i) = nanmean(Spatiotemporal_Overlap{i});
    end
    subplot(2,4,1)
    plot(1:14, MeanSpatialDegree, '-ok', 'MarkerFaceColor', 'k'); hold on;
    plot(1:14, MeanTemporalDegree, '-or', 'MarkerFaceColor', 'r');
    plot(1:14, MeanSpatioTemporalDegree, '-og', 'MarkerFaceColor', 'g');
    legend({'Spatial', 'Temporal', 'Spatiotemporal'});
    xlabel('Session', 'Fontsize', 12)
    ylabel('Mean Degree', 'Fontsize', 12)
    title('Mean Graphical Degree of Dendrites', 'Fontsize', 14)
    
    subplot(2,4,2)
    plot(1:14,DendriteClusteringDegree,'-ok', 'MarkerFaceColor', 'k'); hold on;
    plot(1:14,TemporalClusteringDegree,'-or', 'MarkerFaceColor', 'r');
    plot(1:14,SpatioTemporalClusteringDegree, '-og', 'MarkerFaceColor', 'g');
    legend({'Spatial', 'Temporal'});
    
    ylabel('Mean algebraic connectivity of dendrites', 'Fontsize', 12)
    xlabel('Session', 'Fontsize', 12)
    title('Dendritic Fiedler Values', 'Fontsize', 14)
    
    subplot(2,4,3)
    plot(1:14, MeanSpatialDegree_vs_Movement, '-ok', 'MarkerFaceColor', 'k'); hold on;
    plot(1:14, MeanTemporalDegree_vs_Movement, '-or', 'MarkerFaceColor', 'r'); 
    plot(1:14, MeanSpatioTemporalDegree_vs_Movement, '-og', 'MarkerFaceColor', 'g');
    legend({'Spatial v Movment', 'Temporal v Movement', 'ST v Movement'})
    
    ylabel('Correlation of Degree and Movement Correlation')
    xlabel('Session')
    title('Correlation of Degree Measurements with Movement Correlation Profile')
    
    subplot(2,4,4)
    plot(1:14, MeanSpatioTemporalOverlap, '-ok', 'MarkerFaceColor', 'k');
    ylabel('Correlation')
    xlabel('Session')
    title('Correlation between Spatial and Temporal Profiles')
    
    subplot(2,4,5)
    plot(1:14, MeanSpatialDegreeofCueSpines, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(1:14, MeanSpatialDegreeofMovementSpines, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2)
    plot(1:14, MeanSpatialDegreeofMDCSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(1:14, MeanSpatialDegreeofPreSuccessSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen , 'Linewidth', 2)
    plot(1:14, MeanSpatialDegreeofSuccessSpines, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(1:14, MeanSpatialDegreeofRewardSpines, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2);
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14);
    title('Mean Spatial Degree of Spine Types')
    
    subplot(2,4,6)
    plot(1:14, MeanTemporalDegreeofCueSpines, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(1:14, MeanTemporalDegreeofMovementSpines, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2)
    plot(1:14, MeanTemporalDegreeofMDCSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(1:14, MeanTemporalDegreeofPreSuccessSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2)
    plot(1:14, MeanTemporalDegreeofSuccessSpines, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(1:14, MeanTemporalDegreeofRewardSpines, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2);
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14);
    title('Mean Temporal Degree')
    
    subplot(2,4,7)
    plot(1:14, MeanSpatioTemporalDegreeofCueSpines, '-o', 'Color', lgreen, 'MarkerFaceColor', lgreen, 'Linewidth', 2); hold on;
    plot(1:14, MeanSpatioTemporalDegreeofMovementSpines, '-o', 'Color', black, 'MarkerFaceColor', black, 'Linewidth', 2)
    plot(1:14, MeanSpatioTemporalDegreeofMDCSpines, '-o', 'Color', green, 'MarkerFaceColor', green, 'Linewidth', 2)
    plot(1:14, MeanSpatioTemporalDegreeofPreSuccessSpines, '-o', 'Color', bgreen, 'MarkerFaceColor', bgreen, 'Linewidth', 2)
    plot(1:14, MeanSpatioTemporalDegreeofSuccessSpines, '-o', 'Color', lblue, 'MarkerFaceColor', lblue, 'Linewidth', 2)
    plot(1:14, MeanSpatioTemporalDegreeofRewardSpines, '-o', 'Color', purple, 'MarkerFaceColor', purple, 'Linewidth', 2);
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14);
    title('Mean SpatioTemporal Degree');
    
    %%
    %%%%%%%%%%%%
    %%% Figure 6
    %%%
    %%% Length of Clusters
    %%%%%%%%%%%%%
    
    figure('Position', scrsz)
    subplot(1,4,1)
        plot(MeanCueClustLength, '-o', 'Color', lgreen, 'LineWidth', 2, 'MarkerFaceColor', lgreen); hold on;
        plot(MeanMovClustLength, '-o', 'Color', black, 'LineWidth', 2, 'MarkerFaceColor', black);
        plot(MeanMixClustLength, '-o', 'Color', red, 'Linewidth', 2, 'MarkerFaceColor', red)
        plot(MeanPreSucClustLength, '-o', 'Color', bgreen', 'Linewidth', 2, 'MarkerFaceColor', bgreen);
        plot(MeanSucClustLength, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue);
        plot(MeanMovDuringCueClustLength, '-o', 'Color', green, 'Linewidth', 2, 'MarkerFaceColor', green);
        plot(MeanRewClustLength, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple);
        plot(MeanAllClustLength, '-o', 'Color', gray, 'Linewidth', 2, 'MarkerFaceColor', gray);
        ylabel('Mean Distance b/w Spines in Clusters', 'Fontsize', 14);
        xlabel('Session','Fontsize', 14)
        xlim([0 15])
        legend({'Cue clust', 'Mov Clust', 'Mix Clust', 'Suc. Clust', 'Rew Clust', 'All Clust'}, 'Location', 'Northwest')
        title('Mean Cluster Length')
            pos = get(gca,'Position');
            axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)]);
            hist(cell2mat(AllMovClustLengths));
            
        
    subplot(1,4,2)
        plot(MaxCueClustLength, '-o', 'Color', lgreen, 'LineWidth', 2, 'MarkerFaceColor', lgreen); hold on;
        plot(MaxMovClustLength, '-o', 'Color', black, 'Linewidth', 2, 'MarkerFaceColor', black);
        plot(MaxMixClustLength, '-o', 'Color', red, 'Linewidth', 2, 'MarkerFaceColor', red)
        plot(MaxSucClustLength, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue);
        plot(MaxRewClustLength, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple);
        plot(MaxAllClustLength, '-o', 'Color', gray, 'Linewidth', 2, 'MarkerFaceColor', gray);
        ylabel('Max Distance b/w Spines in Clusters', 'Fontsize', 14);
        xlabel('Session', 'Fontsize', 14)
        xlim([0 15])
        legend({'Cue clust', 'Mov Clust', 'Mix Clust', 'Suc. Clust', 'Rew Clust', 'All Clust'})
        title('Max Cluster Length')
        
    subplot(1,4,3)
        plot(MeanDistanceBetweenCueSpines, '-o', 'Color', lgreen, 'Linewidth', 2, 'MarkerFaceColor', lgreen); hold on;
        plot(MeanDistanceBetweenMovementSpines, '-o', 'Color', black, 'Linewidth', 2, 'MarkerFaceColor', black)
        plot(MeanDistanceBetweenPreSuccessSpines, '-o', 'Color', bgreen, 'Linewidth', 2, 'MarkerFaceColor', bgreen)
        plot(MeanDistanceBetweenSuccessSpines, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue)
        plot(MeanDistanceBetweenMovementDuringCueSpines, '-o', 'Color', green, 'Linewidth', 2, 'MarkerFaceColor', green)
        plot(MeanDistanceBetweenRewardSpines, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple)
        ylabel('Distance (um)', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        xlim([0 15])
        title('Distance between (function) spines')
        
    subplot(1,4,4)
        plot(MeanFarCueClustLength, '-o', 'Color', lgreen, 'LineWidth', 2, 'MarkerFaceColor', lgreen); hold on;
        plot(MeanFarMovClustLength, '-o', 'Color', black, 'LineWidth', 2, 'MarkerFaceColor', black);
        plot(MeanFarMixClustLength, '-o', 'Color', red, 'Linewidth', 2, 'MarkerFaceColor', red)
        plot(MeanFarPreSucClustLength, '-o', 'Color', bgreen', 'Linewidth', 2, 'MarkerFaceColor', bgreen);
        plot(MeanFarSucClustLength, '-o', 'Color', lblue, 'Linewidth', 2, 'MarkerFaceColor', lblue);
        plot(MeanFarMovDuringCueClustLength, '-o', 'Color', green, 'Linewidth', 2, 'MarkerFaceColor', green);
        plot(MeanFarRewClustLength, '-o', 'Color', purple, 'Linewidth', 2, 'MarkerFaceColor', purple);
        plot(MeanAllFarClustLength, '-o', 'Color', gray, 'Linewidth', 2, 'MarkerFaceColor', gray);
        ylabel('Mean Distance b/w Spines in Clusters', 'Fontsize', 14);
        xlabel('Session','Fontsize', 14)
        xlim([0 15])
        legend({'Cue clust', 'Mov Clust', 'Mix Clust', 'Suc. Clust', 'Rew Clust', 'All Clust'})
        title('Mean Inter-dendrite cluster Length')
        
        
        
        %%% Figure 7
    figure('Position', scrsz); 
    
    earlysessions = 1:3;
    latesessions  = 10:12; 
    
    ConDendDistanceUmbrellaDataChoice = DistanceBetweenAllSpines; 
    ConDendCorrelationUmbrellaDataChoice = CorrelationBetweenAllSpines; 
    
    ConDendDistanceStatDataChoice = DistanceBetweenMovementSpines;
    ConDendCorrelationStatDataChoice = CorrelationBetweenMovementSpines;
    
%     AlloDendDistanceUmbrellaDataChoice = AllDistancesBetweenSameCellDiffBranchSpines; 
%     AlloDendCorrelationUmbrellaDataChoice = CorrelationBetweenSameCellDiffBranchSpines; 
    
    AlloDendDistanceUmbrellaDataChoice = DistanceBetweenFarSpines; 
    AlloDendCorrelationUmbrellaDataChoice = CorrelationBetweenAlloDendriticSpines; 
    
    AlloDendDistanceStatDataChoice = DistanceBetweenFarMovementSpines; 
    AlloDendCorrelationStatDataChoice = CorrelationBetweenAllodendriticMovementSpines; 


        subplot(2,4,1)
        plot(cell2mat(ConDendDistanceStatDataChoice(earlysessions))', cell2mat(ConDendCorrelationStatDataChoice(earlysessions))', 'ok', 'MarkerFaceColor', 'k')
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',14)
        subplot(2,4,2)
        plot(cell2mat(AlloDendDistanceStatDataChoice(earlysessions))', cell2mat(AlloDendCorrelationStatDataChoice(earlysessions))', 'o', 'MarkerFaceColor', gray)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',14)
        subplot(2,4,3)
        plot(cell2mat(ConDendDistanceStatDataChoice(latesessions))', cell2mat(ConDendCorrelationStatDataChoice(latesessions))', 'ok', 'MarkerFaceColor', 'k')
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',14)
        subplot(2,4,4)
        plot(cell2mat(AlloDendDistanceStatDataChoice(latesessions))', cell2mat(AlloDendCorrelationStatDataChoice(latesessions))', 'o', 'MarkerFaceColor', gray)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',14)
        subplot(2,4,5)
        plot(cell2mat(ConDendDistanceUmbrellaDataChoice(earlysessions))', cell2mat(ConDendCorrelationUmbrellaDataChoice(earlysessions))', 'o', 'MarkerEdgeColor', dred, 'MarkerFaceColor', dred)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',14)
        subplot(2,4,6)
        plot(cell2mat(AlloDendDistanceUmbrellaDataChoice(earlysessions)'), cell2mat(AlloDendCorrelationUmbrellaDataChoice(earlysessions)'), 'o', 'MarkerFaceColor', gray)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',14)
        subplot(2,4,7)
        plot(cell2mat(ConDendDistanceUmbrellaDataChoice(latesessions))', cell2mat(ConDendCorrelationUmbrellaDataChoice(latesessions))', 'o', 'MarkerEdgeColor', dred, 'MarkerFaceColor', dred)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',14)
        subplot(2,4,8)
        plot(cell2mat(AlloDendDistanceUmbrellaDataChoice(latesessions)'), cell2mat(AlloDendCorrelationUmbrellaDataChoice(latesessions)'), 'o', 'MarkerFaceColor', gray)
            xlim([0 100])
            ylim([-0.05 1])
            xlabel('Distance (\mum)', 'FontSize', 14)
            ylabel('Correlation', 'FontSize', 14)
        title(['Sessions ' num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',14)
        
    a.HighlyCorrelatedSpines = HSCs;    
    a.ClusteredSpines = ClusteredSpines;    
    a.ClustCorrwithCue = clustcorrwithcue;
    a.NonClusteredCorrwithCue = nonclustcorrwithcue;
    a.ClustCorrwithMovementDuringCue = clustcorrwithMDC;
    a.NonClusteredCorrwithMovementDuringCue = nonclustcorrwithMDC;
    a.AllSpinesCorrwithMovement = allspinescorrwithmov;
    a.MovementSpinesCorrwithMovement = movspinescorrwithmov;
    a.ClustCorrwithMovement = clustcorrwithmov;
    a.NonClusteredCorrwithMovement = nonclustcorrwithmov;
    a.ClustCorrwithSuccess = clustcorrwithsuc;
    a.NonClusteredCorrwithSuccess = nonclustcorrwithsuc;
    a.ClustCorrwithReward = clustcorrwithrew;
    a.NonClusteredCorrwithReward = nonclustcorrwithrew;
    a.CorrelationofClusters = CorrelationofClusters;
       
    a.CausalClustCorrwithCue = Caus_clustcorrwithcue;
    a.CausalNonClusteredCorrwithCue = Caus_nonclustcorrwithcue;
    a.CausalClustCorrwithMovementDuringCue = Caus_clustcorrwithMDC;
    a.CausalNonClusteredCorrwithMovementDuringCue = Caus_nonclustcorrwithMDC;
    a.CausalClustCorrwithMovement = Caus_clustcorrwithmov;
    a.CausalNonClusteredCorrwithMovement = Caus_nonclustcorrwithmov;
    a.CausalClustCorrwithSuccess = Caus_clustcorrwithsuc;
    a.CausalNonClusteredCorrwithSuccess = Caus_nonclustcorrwithsuc;
    a.CausalClustCorrwithReward = Caus_clustcorrwithrew;
    a.CausalNonClusteredCorrwithReward = Caus_nonclustcorrwithrew;
    
    a.CueClustersCorrwithCue = cueclustcorrwithcue;
    a.CueNonClustCorrwithCue = cuenonclustcorrwithcue;
    a.MovementDuringCueClustersCorrwithMovementDuringCue = MDCclustcorrwithMDC;
    a.MovementDuringCueNonClustCorrwithMovementDuringCue = MDCnonclustcorrwithMDC;
    a.MovementClustersCorrwithMovement = movclustcorrwithmov;
    a.MovementNonClustCorrwithMovement = movnonclustcorrwithmov;
    a.SuccessClustersCorrwithSuccess = succlustcorrwithsuc;
    a.SuccessNonClustCorrwithSuccess = sucnonclustcorrwithsuc;
    a.RewardClustersCorrwithReward = rewclustcorrwithrew;
    a.RewardNonClustCorrwithReward = rewnonclustcorrwithrew;
    
    a.CausalCueClustersCorrwithCue = Caus_cueclustcorrwithcue;
    a.CausalCueNonClustCorrwithCue = Caus_cuenonclustcorrwithcue;
    a.CausalMovementDuringCueClustersCorrwithMovementDuringCue = Caus_MDCclustcorrwithMDC;
    a.CausalMovementDuringCueNonClustCorrwithMovementDuringCue = Caus_MDCnonclustcorrwithMDC;
    a.CausalMovementClustersCorrwithMovement = Caus_movclustcorrwithmov;
    a.CausalMovementNonClustCorrwithMovement = Caus_movnonclustcorrwithmov;
    a.CausalSuccessClustersCorrwithSuccess = Caus_succlustcorrwithsuc;
    a.CausalSuccessNonClustCorrwithSuccess = Caus_sucnonclustcorrwithsuc;
    a.CausalRewardClustersCorrwithReward = Caus_rewclustcorrwithrew;
    a.CausalRewardNonClustCorrwithReward = Caus_rewnonclustcorrwithrew;
    
    a.FractionofCueSpinesThatAreClustered = FractionofCueSpinesThatAreClustered;
    a.FractionofCueSpinesThatAreNonClustered = FractionofCueSpinesThatAreNonClustered;
    a.FractionofMovementSpinesThatAreClustered = FractionofMovementSpinesThatAreClustered;
    a.FractionofMovementSpinesThatAreNonClustered = FractionofMovementSpinesThatAreNonClustered;
    a.FractionofPreSuccessSpinesThatAreClustered = FractionofPreSuccessSpinesThatAreClustered; 
    a.FractionofSuccessSpinesThatAreClustered = FractionofSuccessSpinesThatAreClustered;
    a.FractionofSuccessSpinesThatAreNonClustered = FractionofSuccessSpinesThatAreNonClustered;
    a.FractionofMovementDuringCueSpinesThatAreClustered = FractionofMovementDuringCueSpinesThatAreClustered;
    a.FractionofRewardSpinesThatAreClustered = FractionofRewardSpinesThatAreClustered;
    a.FractionofRewardSpinesThatAreNonClustered = FractionofRewardSpinesThatAreNonClustered;
    
    a.AllSpineFrequency = allspine_freq;
    a.MovementSpineFrequency = movspine_freq;
    a.ClusterFrequency = cluster_freq;
    a.NonClusteredFrequency = nonclustered_freq;
    a.CueClusterFrequency = cue_cluster_freq;
    a.MovementClusterFrequency = mov_cluster_freq;
    a.MovementDuringCueClusterFrequency = movduringcue_cluster_freq;
    a.PreSuccessClusterFrequency = presuc_cluster_freq;
    a.SuccessClusterFrequency = suc_cluster_freq;
    a.RewardClusterFrequency = rew_cluster_freq;
    a.CausalClusterFrequency = Caus_cluster_freq;
    a.NonClusteredCausalFrequency = Caus_nonclustered_freq;
    a.CausalCueClusterFrequency = Caus_cue_cluster_freq;
    a.CausalMovementClusterFrequency = Caus_mov_cluster_freq;
    a.CausalMovementDuringCueClusterFrequency = Caus_movduringcue_cluster_freq;
    a.CausalPreSuccessClusterFrequency = Caus_presuc_cluster_freq;
    a.CausalSuccessClusterFrequency = Caus_suc_cluster_freq;
    a.CausalRewardClusterFrequency = Caus_rew_cluster_freq;
    
%     a.DendriteswithMovementClusters = DendswithMovClusts;
%     a.DendriteswithoutMovementClusters = DendsnomovClusts;
    a.AllDendritesFrequency = AllDendFreq;
    a.MovementDendritesFrequency = MoveDendFreq;
    a.NonMovementDendritesFrequency = NonMoveDendFreq;
    a.DendriteswithClustersFrequency = ClustDendFreq;
    a.DendriteswithoutClustersFrequency = NoClustDendFreq;
    a.DendriteswithCueClustersFrequency = CueClustDendFreq;
    a.DendriteswithMovClustersFrequency = MovClustDendFreq;
    a.DendriteswithMovDuringCueClustersFrequency = MovDuringCueClustDendFreq;
    a.DendriteswithPreSucClustersFrequency = PreSucClustDendFreq;
    a.DendriteswithSucClustersFrequency = SucClustDendFreq;
    a.DendriteswithRewClustersFrequency = RewClustDendFreq;
    a.DendriteswithoutMovClustersFrequency = NoMovClustDendFreq;
    a.DendriticClusterNumberInfo = DendNumClust;
    
    a.ClusteredSpineAmp = ClustAmp;
    a.NonClusteredSpineAmp = NonClusteredAmp;
    a.ClusteredCueSpineAmp = CueAmp;
    a.ClusteredMovSpineAmp = MovAmp;
    a.ClusteredMovDuringCueSpineAmp = MovDuringCueAmp;
    a.ClusteredPreSuccessSpineAmp = PreSucAmp;
    a.ClusteredSuccessSpineAmp = SucAmp;
    a.ClusteredRewardSpineAmp = RewAmp;
    a.CausalClusteredSpineAmp = Caus_ClustAmp;
    a.CausalNonClusteredSpineAmp = Caus_NonClusteredAmp;
    a.CausalClusteredCueSpineAmp = Caus_CueAmp;
    a.CausalClusteredMovSpineAmp = Caus_MovAmp;
    a.CausalClusteredMovDuringCueSpineAmp = Caus_MovDuringCueAmp;
    a.CausalClusteredPreSuccessSpineAmp = Caus_PreSucAmp;
    a.CausalClusteredSuccessSpineAmp = Caus_SucAmp;
    a.CausalClusteredRewardSpineAmp = Caus_RewAmp;
    
    a.HighlyCorrelatedMovementRelatedSpines  = HighlyCorrelatedMovementRelatedSpines;
    
    a.NumberofImagedSpines = NumberofImagedSpines;
    a.NumberofCueSpines = NumCueRelSpines;
    a.NumberofMovementRelatedSpines = NumMovRelSpines;
    a.FractionofMovementRelatedSpinesPerDendrite = FractionofMovRelSpinesPerDendrite;
    a.LengthofDendrites = LengthofDendrites;
    a.MovementRelatedSpinesPer10Microns = MovRelSpinesPer10Microns;
    a.FractionofSuccessRelatedSpinesPerDendrite = FractionofSucRelSpinesPerDendrite;
    a.SuccessRelatedSpinesPer10Microns = SucRelSpinesPer10Microns;
    a.NumberofCueORMovementRelatedSpines = NumCueORMovRelSpines;
    a.NumberofPreSuccessSpines = NumPreSucRelSpines;
    a.NumberofSuccessSpines = NumSucRelSpines;
    a.NumberofMovementDuringCueSpines = NumMovDuringCueRelSpines;
    a.NumberofRewardSpines = NumRewRelSpines;
    a.NumberofCausalCueSpines = NumCausalCueSpines;
    a.NumberofCausalMvmntSpines = NumCausalMovSpines;
    a.NumberofCausalSuccessSpines = NumCausalSucSpines;
    a.NumberofCausalRewardSpines = NumCausalRewSpines;
    
    a.NumberofHighlyCorrelatedSpines = NumHSCs;
    a.NumberofClusteredSpines = NumClustSpines;
    a.NumberofClusteredCueSpines = NumClustCueSpines;
    a.NumberofClusteredMovementSpines = NumClustMovSpines;
    a.NumberofClusteredMixedFunctionSpines = NumClustMixSpines;
    a.NumberofClusteredPreSuccessSpines = NumClustPreSucSpines;
    a.NumberofClusteredSuccessSpines = NumClustSucSpines;
    a.NumberofClusteredMovementDuringCueSpines = NumClustMovDuringCueSpines;
    a.NumberofClusteredRewardSpines = NumClustRewSpines;
    
    a.NumberofFarClusteredSpines = NumFarClustSpines;
    a.NumberofFarClusteredCueSpines = NumFarClustCueSpines;
    a.NumberofFarClusteredMovementSpines = NumFarClustMovSpines;
    a.NumberofFarClusteredMixedFunctionSpines = NumFarClustMixSpines;
    a.NumberofFarClusteredPreSuccessSpines = NumFarClustPreSucSpines;
    a.NumberofFarClusteredSuccessSpines = NumFarClustSucSpines;
    a.NumberofFarClusteredMovementDuringCueSpines = NumFarClustMovDuringCueSpines;
    a.NumberofFarClusteredRewardSpines = NumFarClustRewSpines;
    
    a.NumberofCausalClusteredSpines = NumCausClustSpines;
    a.NumberofCausalClusteredCueSpines = NumCausClustCueSpines;
    a.NumberofCausalClusteredMovementDuringCueSpines = NumCausClustMovDuringCueSpines;
    a.NumberofCausalClusteredMovementSpines = NumCausClustMovSpines;
    a.NumberofCausalClusteredPreSuccessSpines = NumCausClustPreSucSpines;
    a.NumberofCausalClusteredSuccessSpines = NumCausClustSucSpines;
    a.NumberofCausalClusteredRewardSpines = NumCausClustRewSpines;
    
    a.MeanCueClustLength = MeanCueClustLength;
    a.MaxCueClustLength = MaxCueClustLength;
    a.MeanMovClustLength = MeanMovClustLength;
    a.AllMovClustLengths = AllMovClustLengths;
    a.MaxMovClustLength = MaxMovClustLength;
    a.MeanMixClustLength = MeanMixClustLength;
    a.MaxMixClustLength = MaxMixClustLength;
    a.MeanPreSucClustLength = MeanPreSucClustLength;
    a.MaxPreSucClustLength = MaxPreSucClustLength;
    a.MeanSucClustLength = MeanSucClustLength;
    a.MaxSucClustLength = MaxSucClustLength;
    a.MeanMovDuringCueClustLength = MeanMovDuringCueClustLength;
    a.MaxMovDuringCueClustLength = MaxMovDuringCueClustLength;
    a.MeanRewClustLength = MeanRewClustLength;
    a.MaxRewClustLength = MaxRewClustLength;
    a.MeanAllClustLength = MeanAllClustLength;
    a.MaxAllClustLength = MaxAllClustLength;
    
    a.MeanFarCueClustLength = MeanFarCueClustLength;
    a.MeanFarMovClustLength = MeanFarMovClustLength;
    a.MeanFarMixClustLength = MeanFarMixClustLength;
    a.MeanFarPreSucClustLength = MeanFarPreSucClustLength;
    a.MeanFarSucClustLength = MeanFarSucClustLength;
    a.MeanFarMovDuringCueClustLength = MeanFarMovDuringCueClustLength;
    a.MeanFarRewClustLength = MeanFarRewClustLength;
    a.MeanAllFarClustLength = MeanAllFarClustLength;
    
    a.MeanCausalCueClustLength = MeanCausalCueClustLength;
    a.MaxCausalCueClustLength = MaxCausalCueClustLength;
    a.MeanCausalMovClustLength = MeanCausalMovClustLength;
    a.MaxCausalMovClustLength = MaxCausalMovClustLength;
    a.MeanCausalSucClustLength = MeanCausalSucClustLength;
    a.MaxCausalSucClustLength = MaxCausalSucClustLength;
    a.MeanCausalRewClustLength = MeanCausalRewClustLength;
    a.MaxCausalRewClustLength = MaxCausalRewClustLength;
    a.MeanCausalAllClustLength = MeanAllCausalClustLength;
    a.MaxCausalAllClustLength = MaxAllCausalClustLength;
    
    a.NearestMovementRelatedSpine = MovSpinetoNearestMovSpine;
    a.NextClosestMovementRelatedSpine = NextClosest;
    a.ThirdClosestMovementRelatedSpine = ThirdClosest;
    a.FourthClosestMovementRelatedSpine = FourthClosest;
    a.CorrelationwithNearestMovementRelatedSpine = CorrwithNearestMovSpine; 
    a.CorrelationwithFarthestMovementRelatedSpine = CorrwithFarthestMovSpine;
    
    a.MoveSpinetoNearestFunctionallyClusteredMoveSpine = MovSpinetoNearestFuncClustMovSpine;
    a.MoveSpinetoNextFunctionallyClusteredMoveSpine = MovSpinetoNextFuncClustMovSpine;
    a.MoveSpinetoThirdFunctionallyClusteredMoveSpine = MovSpinetoThirdFuncClustMovSpine;
    a.MoveSpinetoFourthFunctionallyClusteredMoveSpine = MovSpinetoFourthFuncClustMovSpine;
    
    a.AllCorrelationswithNearbyMetaClusters = AllCorrwithNearbyMetaClusters;
    a.AllCorrelationswithDistantMetaClusters = AllCorrwithDistantMetaClusters;
    a.CorrelationofNearestMetaCluster = CorrofNearestMetaCluster;
    a.CorrelationofNextMetaCluster = CorrofNextMetaCluster;
    a.CorrelationofThirdMetaCluster = CorrofThirdMetaCluster;
    a.CorrelationofFourthMetaCluster = CorrofFourthMetaCluster;
    a.RandomMovementPairCorrelation = RandomMovementPairCorr;
    
    a.NearestFunctionallyClusteredMovementRelatedSpine = FuncClustMovSpinetoNearestFuncClustMovSpine;
    a.NearestHighlyCorrelatedMovementRelatedSpine = NearestHighCorrMovSpine;
    a.NextClosestFunctionallyClusteredMovementRelatedSpine = NextClosestFuncClustMovSpine;
    a.NextClosestHighlyCorrelatedMovementRelatedSpine = NextClosestHighCorrMovSpine; 
    a.ThirdClosestFunctionallyClusteredMovementRelatedSpine = ThirdClosestFuncClustMovSpine;
    a.ThirdClosestHighlyCorrelatedMovementRelatedSpine = ThirdClosestHighCorrMovSpine;
    a.FourthClosestFunctionallyClusteredMovementRelatedSpine = FourthClosestFuncClustMovSpine;
    a.FourthClosestHighlyCorrelatedMovementRelatedSpine = FourthClosestHighCorrMovSpine; 
    a.DistanceBetweenAllSpines = DistanceBetweenAllSpines;
        a.CorrelationBetweenAllSpines = CorrelationBetweenAllSpines;
        a.CorrelationBetweenAllSpinesMovementPeriods = CorrelationBetweenAllSpinesMovePeriods;
        a.CorrelationBetweenAllSpinesStillPeriods = CorrelationBetweenAllSpinesStillPeriods;
        a.MeanCorrelationBetweenAllSpines = MeanCorrelationBetweenAllSpines;
        a.AdjacencyValuesforAllSpines = AdjacencyValuesforAllSpines;
        a.SharedPairwiseCorrelationValuesforAllSpines = SharedPairwiseCorrelationValuesforAllSpines;
        a.SharedPairwiseReliabilityValuesforAllSpines = SharedPairwiseReliabilityValuesforAllSpines;
    a.DistanceBetweenCueSpines = DistanceBetweenCueSpines;
    a.MeanDistanceBetweenCueSpines = MeanDistanceBetweenCueSpines;
    a.DistanceBetweenMovementSpines = DistanceBetweenMovementSpines;
    a.MeanDistanceBetweenMovementSpines = MeanDistanceBetweenMovementSpines;
        a.CorrelationBetweenMovementSpines = CorrelationBetweenMovementSpines;
        a.CorrelationBetweenMovementSpinesMovementPeriods = CorrelationBetweenMovementSpinesMovePeriods;
        a.CorrelationBetweenMovementSpinesStillPeriods = CorrelationBetweenMovementSpinesStillPeriods;
        a.MeanCorrelationBetweenMovementSpines = MeanCorrelationBetweenMovementSpines;
    a.DistanceBetweenPreSuccessSpines = DistanceBetweenPreSuccessSpines;
    a.MeanDistanceBetweenPreSuccessSpines = MeanDistanceBetweenPreSuccessSpines;
        a.CorrelationBetweenPreMovementSpines = CorrelationBetweenPreSuccessSpines;
        a.MeanCorrelationBetweenPreSuccessSpines = MeanCorrelationBetweenPreSuccessSpines;
    a.DistanceBetweenSuccessSpines = DistanceBetweenSuccessSpines;
        a.CorrelationBetweenSuccessSpines = CorrelationBetweenSuccessSpines;
        a.CorrelationBetweenSuccessSpinesMovementPeriods = CorrelationBetweenSuccessSpinesMovePeriods;
        a.CorrelationBetweenSuccessSpinesStillPeriods = CorrelationBetweenSuccessSpinesStillPeriods;
        a.MeanCorrelationBetweenSuccessSpines = MeanCorrelationBetweenSuccessSpines;
    a.MeanDistanceBetweenSuccessSpines = MeanDistanceBetweenSuccessSpines;
    a.DistanceBetweenMovementDuringCueSpines = DistanceBetweenMovementDuringCueSpines;
    a.MeanDistanceBetweenMovementDuringCueSpines = MeanDistanceBetweenMovementDuringCueSpines;
    a.DistanceBetweenRewardSpines = DistanceBetweenRewardSpines;
    a.MeanDistanceBetweenRewardSpines = MeanDistanceBetweenRewardSpines;
    a.DistanceBetweenFarSpines = DistanceBetweenFarSpines;
    a.CorrelationBetweenFarSpines = CorrelationBetweenAlloDendriticSpines;
    a.DistanceBetweenFarMovementSpines = DistanceBetweenFarMovementSpines;
    a.CorrelationBetweenFarMovementSpines = CorrelationBetweenAllodendriticMovementSpines;
    a.CorrelationBetweenAllBranchSpines = CorrelationBetweenAllBranchSpines; 
    a.DistanceBetweenAllBranchSpines = DistanceBetweenAllBranchSpines;
    a.CorrelationBetweenBranchMovementSpines = CorrelationBetweenBranchMoveSpines;
    a.DistanceBetweenBranchMovementSpines = DistanceBetweenBranchMoveSpines;
    a.CorrelationBetweenBranchSuccessSpines = CorrelationBetweenBranchSuccessSpines;
    a.DistanceBetweenBranchSuccessSpines = DistanceBetweenBranchSuccessSpines;
    
    a.MeanNumberofSpinesinEachCluster = MeanNumberofSpinesinEachCluster;
    a.MeanNumberofSpinesinEachCausalCluster = MeanNumberofSpinesinEachCausalCluster;
    a.NumberofClusters = NumClusters;
    a.NumberofCausalClusters = NumCausalClusters;
    a.MeanNumberofSpinesinEachMovCluster = NumberofSpinesinEachMovCluster;
    a.NumberofMovClusters = NumMovClusters;
    
    a.ClusteredSpines_CorrwithDend = ClusteredSpines_CorrwithDend;
    a.FilteredClusteredSpines_CorrwithDend = FilteredClusteredSpines_CorrwithDend;
    a.NonClusteredSpines_CorrwithDend = NonClusteredSpines_CorrwithDend;
    a.CausalClusteredSpines_CorrwithDend = CausalClusteredSpines_CorrwithDend;
    a.FilteredCausalClusteredSpines_CorrwithDend = FilteredCausalClusteredSpines_CorrwithDend;
    a.NonCausalClusteredSpines_CorrwithDend = NonCausalClusteredSpines_CorrwithDend;
    a.CueRelClusteredSpines_CorrwithDend = CueRelClusteredSpines_CorrwithDend;
    a.MovRelClusteredSpines_CorrwithDend = MovRelClusteredSpines_CorrwithDend;
    a.PreSucRelClusteredSpines_CorrwithDend = PreSucRelClusteredSpines_CorrwithDend;
    a.SucRelClusteredSpines_CorrwithDend = SucRelClusteredSpines_CorrwithDend;
    a.MovDuringCueRelClusteredSpines_CorrwithDend = MovDuringCueRelClusteredSpines_CorrwithDend;
    a.RewRelClusteredSpines_CorrwithDend = RewRelClusteredSpines_CorrwithDend;
    a.CueRelCausalClusteredSpines_CorrwithDend = CueRelCausalClusteredSpines_CorrwithDend;
    a.MovRelCausalClusteredSpines_CorrwithDend = MovRelCausalClusteredSpines_CorrwithDend;
    a.SucRelCausalClusteredSpines_CorrwithDend = SucRelCausalClusteredSpines_CorrwithDend;
    a.RewRelCausalClusteredSpines_CorrwithDend = RewRelCausalClusteredSpines_CorrwithDend;

    a.SpatioTemporalAdjacencyMatrix = SpatioTemporalAdjacencyMatrix;
    a.SpatialDegree = Spatial_Deg;
    a.MeanDendriticSpatialDegree = MeanSpatialDegree;
    a.TemporalDegree = Temporal_Deg;
    a.MeanDendriticTemporalDegree = MeanTemporalDegree;
    a.SpatioTemporalDegree = Spatiotemporal_Deg;
    a.MeanDendriticSpatioTemporalDegree = MeanSpatioTemporalDegree;
    a.SpatioTemporalOverlap = Spatiotemporal_Overlap;
    a.SpectralMovementCorrelation = MovementCorrelationsforAllSpinesonDend;
    a.SpatialDegreevsMovement = SpatialDegree_vs_Movement;
    a.TemporalDegreevsMovement = TemporalDegree_vs_Movement;
    a.SpatioTemporalDegreevsMovement = SpatiotemporalDegree_vs_Movement;
    a.InterspineMovementCorrelation = InterspineMovementCorrelation;
    a.InterspineMovementReliability = InterspineMovementReliability;
    a.SpatialDegreevsMovement = SpatialDegree_vs_Movement;
    a.TemporalDegreevsMovement = TemporalDegree_vs_Movement;
    a.SpectralDendriteInformation = DendClust_Deg;                  %%% Col 1-3 = Eigenvalue/Fiedler value, col 4 = dend freq., col 5 = dend corr with movment, col 6 = number of spines
    a.SpatioTemporalFiedlerValues = SpatioTemporalFiedler;
    a.SpatioTemporalPartitionVector  = SpatioTemporalPartition;     %%% The Fiedler vector can be used as a partition for the graph (positive in one group, negative in another)
    a.SpatioTemporal_FirstEigenVector = SpatioTemporal_FirstEigenvector;
    a.MeanSpatialDegreeofCueSpines = MeanSpatialDegreeofCueSpines;
    a.MeanTemporalDegreeofCueSpines = MeanTemporalDegreeofCueSpines;
    a.MeanSpatioTemporalDegreeofCueSpines = MeanSpatioTemporalDegreeofCueSpines;
    a.MeanSpatialDegreeofMovementSpines = MeanSpatialDegreeofMovementSpines;
    a.MeanTemporalDegreeofMovementSpines = MeanTemporalDegreeofMovementSpines;
    a.MeanSpatioTemporalDegreeofMovementSpines = MeanSpatioTemporalDegreeofMovementSpines;
    a.MeanSpatialDegreeofMovementDuringCueSpines = MeanSpatialDegreeofMDCSpines;
    a.MeanTemporalDegreeofMovementDuringCueSpines = MeanTemporalDegreeofMDCSpines;
    a.MeanSpatioTemporalDegreeofMovementDuringCueSpines = MeanSpatioTemporalDegreeofMDCSpines;
    a.MeanSpatialDegreeofPreSuccessSpines = MeanSpatialDegreeofPreSuccessSpines;
    a.MeanTemporalDegreeofPreSuccessSpines = MeanTemporalDegreeofPreSuccessSpines;
    a.MeanSpatioTemporalDegreeofPreSuccessSpines = MeanSpatioTemporalDegreeofPreSuccessSpines;
    a.MeanSpatialDegreeofSuccessSpines = MeanSpatialDegreeofSuccessSpines;
    a.MeanTemporalDegreeofSuccessSpines = MeanTemporalDegreeofSuccessSpines;
    a.MeanSpatioTemporalDegreeofSuccessSpines = MeanSpatioTemporalDegreeofSuccessSpines;
    a.MeanSpatialDegreeofRewardSpines = MeanSpatialDegreeofRewardSpines;
    a.MeanTemporalDegreeofRewardSpines = MeanTemporalDegreeofRewardSpines;
    a.MeanSpatioTemporalDegreeofRewardSpines = MeanSpatioTemporalDegreeofRewardSpines;

%     a.AverageFractionofaClusterThatsMovementRelated = FractionofClusterThatsMR;
%     a.AverageFractionofaCausalClusterThatsMovementRelated = FractionofCausalClusterThatsMR;
    a.PercentofCueRelatedDendrites = PercentCueRelDends;
    a.PercentofMovementRelatedDendrites = PercentMovRelDends;
    a.PercentofPreSuccessRelatedDendrites = PercentPreSucRelDends;
    a.PercentofSuccessRelatedDendrites = PercentSucRelDends;
    a.PercentofMovementDuringCueRelatedDendrites = PercentMovDuringCueRelDends;
    a.PercentofRewardRelatedDendrites = PercentRewRelDends;
    
    a.MovementSpineReliability = MovementSpineReliability;
    a.AllSpineReliability = AllSpineReliability;
    
    fname = inputname(1);
    fname = fname(1:5);
    fname = [fname, '_SpineCorrelationTimecourse'];
    eval([fname, '= a;'])
    cd('C:\Users\Komiyama\Desktop\Output Data');
    save(fname, fname);
else
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% Averaging %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%
    %%% Collect Data from input
    %%%

    %%%% Initialize variables
    
    LengthofDendrites = cell(1,14);
    NumberofImagedSpines = nan(length(varargin),14);
    FractionofMovementRelatedSpinesPerDendrite = nan(length(varargin),14);
    MovementRelatedSpinesPer10Microns = nan(length(varargin),14);
    FractionofSuccessRelatedSpinesPerDendrite = nan(length(varargin),14);
    SuccessRelatedSpinesPer10Microns = nan(length(varargin),14);
    SpatialDegree = cell(1,14);
    TemporalDegree = cell(1,14);
    SpatioTemporalDegree = cell(1,14);
    SpatialMovementCorrelation = cell(1,14);
    TemporalMovementCorrelation = cell(1,14);
    SpatioTemporalMovementCorrelation = cell(1,14);
    DendClusteringDegree = cell(1,14);
    SpatioTemporalOverlap = cell(1,14);
    CorrelationofClusters = cell(1,14);
    AllDistancesBetweenAllSpines = cell(1,14);
    AllMovClustLengths = cell(1,14);
        AllDistancesBetweenAlloDendriticSpines = cell(1,14);
        AllDistancesBetweenSameCellDiffBranchSpines = cell(1,14);
    CorrelationBetweenAllSpines = cell(1,14);
        MeanCorrelationBetweenAllSpines = nan(length(varargin),14);
        MeanCorrelationBetweenAllCloseSpines = nan(length(varargin),14);
        MeanCorrelationBetweenAllDistantSpines = nan(length(varargin),14);
    AdjacencyValuesforAllSpines = cell(1,14);
    SharedPairwiseCorrelationValuesforAllSpines = cell(1,14);
    SharedPairwiseReliabilityValuesforAllSpines = cell(1,14);

        
    CorrelationBetweenAllSpinesMovePeriods = cell(1,14);
    CorrelationBetweenAllSpinesStillPeriods = cell(1,14);
        CorrelationBetweenAlloDendriticSpines = cell(1,14);
        MeanCorrelationBetweenAlloDendriticSpines = nan(length(varargin),14);
        CorrelationBetweenSameCellDiffBranchSpines = cell(1,14);
        MeanCorrelationBetweenSameCellDiffBranchSpines = nan(length(varargin),14);
        
    AllDistancesBetweenMovementSpines = cell(1,14);
        AllDistancesBetweenAlloDendriticMovementSpines = cell(1,14);
        AllDistancesBetweenSameCellDiffBranchMovementSpines = cell(1,14);
        AllDistancesBetweenSameCellDiffBranchSuccessSpines = cell(1,14);
    CorrelationBetweenMovementSpines = cell(1,14);
        condendweights = nan(length(varargin),14);
        MeanCorrelationBetweenMovementSpines = nan(length(varargin),14);
        MeanCorrelationBetweenCloseMovementSpines = nan(length(varargin),14);
        MeanCorrelationBetweenDistantMovementSpines = nan(length(varargin),14);
        CorrelationBetweenAllodendriticMovementSpines = cell(1,14);
        MeanCorrelationBetweenAlloDendriticMovementSpines = nan(length(varargin),14);
        CorrelationBetweenSameCellDiffBranchMovementSpines = cell(1,14);
        MeanCorrelationBetweenSameCellDiffBranchMovementSpines = nan(length(varargin),14);
        CorrelationBetweenSameCellDiffBranchSuccessSpines = cell(1,14);
        MeanCorrelationBetweenSameCellDiffBranchSuccessSpines = nan(length(varargin),14);
    CorrelationBetweenMovementSpinesMovePeriods = cell(1,14);
        CorrelationBetweenMovementSpinesAtDistanceBin = cell(1,20);
    CorrelationBetweenMovementSpinesStillPeriods = cell(1,14);
    
    AllDistancesBetweenPreSuccessSpines = cell(1,14);
    CorrelationBetweenPreMovementSpines = cell(1,14);
    
    CorrelationBetweenSuccessSpines = cell(1,14);    
        MeanCorrelationBetweenSuccessSpines = nan(length(varargin),14);
        MeanCorrelationBetweenCloseSuccessSpines = nan(length(varargin),14);
        MeanCorrelationBetweenDistantSuccessSpines = nan(length(varargin),14);
    CorrelationBetweenSuccessSpinesMovePeriods = cell(1,14);
    CorrelationBetweenSuccessSpinesStillPeriods = cell(1,14);
    AllDistancesBetweenSuccessSpines = cell(1,14);
    
    MovSpinetoNearestMovementRelatedSpine = cell(1,14);
    MovSpinetoNextClosestMovementRelatedSpine= cell(1,14);
    MovSpinetoThirdClosestMovementRelatedSpine = cell(1,14);
    MovSpinetoFourthClosestMovementRelatedSpine = cell(1,14);
    CorrelationwithNearestMovementRelatedSpine = cell(1,14);
    CorrelationwithFarthestMovementRelatedSpine = cell(1,14);
    MoveSpinetoNearestFunctionallyClusteredMoveSpine = cell(1,14);
    MoveSpinetoNextFunctionallyClusteredMoveSpine = cell(1,14);
    MoveSpinetoThirdFunctionallyClusteredMoveSpine = cell(1,14);
    MoveSpinetoFourthFunctionallyClusteredMoveSpine = cell(1,14);
    AllCorrelationswithNearbyMetaClusters = cell(1,14);
    AllCorrelationswithDistantMetaClusters = cell(1,14);
    CorrofNearestMetaCluster = cell(1,14);
    CorrofNextMetaCluster = cell(1,14);
    CorrofThirdMetaCluster = cell(1,14);
    CorrofFourthMetaCluster = cell(1,14);
    RandomMovementPairCorr = cell(1,14);
    NearestFunctionallyClusteredMovementRelatedSpine = cell(1,14);
    NearestHighlyCorrelatedMovementRelatedSpine = cell(1,14);
    NextClosestFunctionallyClusteredMovementRelatedSpine = cell(1,14);
    NextClosestHighlyCorrelatedMovementRelatedSpine = cell(1,14);
    ThirdClosestFunctionallyClusteredMovementRelatedSpine = cell(1,14);
    ThirdClosestHighlyCorrelatedMovementRelatedSpine = cell(1,14);
    FourthClosestFunctionallyClusteredMovementRelatedSpine = cell(1,14);
    FourthClosestHighlyCorrelatedMovementRelatedSpine = cell(1,14);
    MovementClusters = cell(length(varargin), 14);
    MovementSpineReliability = cell(1,14);
    AllSpineReliability = cell(1,14);
    InterspineMovementCorrelation = cell(1,14);
    InterspineMovementReliability = cell(1,14);
        
    for i = 1:length(varargin)
        AllClustersCorrwithCue(i,1:14) = varargin{i}.ClustCorrwithCue;
        NonClusteredCorrwithCue(i,1:14) = varargin{i}.NonClusteredCorrwithCue;
        AllClustersCorrwithMDC(i,1:14) = varargin{i}.ClustCorrwithMovementDuringCue;
        NonClusteredCorrwithMDC(i,1:14) = varargin{i}.NonClusteredCorrwithMovementDuringCue;
        AllSpinesCorrwithMovement(i,1:14) = varargin{i}.AllSpinesCorrwithMovement;
        MovementSpinesCorrwithMovement(i,1:14) = varargin{i}.MovementSpinesCorrwithMovement;
        AllClustersCorrwithMovement(i,1:14) = varargin{i}.ClustCorrwithMovement;
        NonClusteredCorrwithMovement(i,1:14) = varargin{i}.NonClusteredCorrwithMovement;
        AllClustersCorrwithSuccess(i,1:14) = varargin{i}.ClustCorrwithSuccess;
        NonClusteredCorrwithSuccess(i,1:14) = varargin{i}.NonClusteredCorrwithSuccess;
        AllClustCorrwithReward(i,1:14) = varargin{i}.ClustCorrwithReward;
        NonClusteredCorrwithReward(i,1:14) = varargin{i}.NonClusteredCorrwithReward;
        

        AllCausalClustersCorrwithCue(i,1:14) = varargin{i}.CausalClustCorrwithCue;
        CausalNonClusteredCorrwithCue(i,1:14) = varargin{i}.CausalNonClusteredCorrwithCue;
        AllCausalClustersCorrwithMovement(i,1:14) = varargin{i}.CausalClustCorrwithMovement;
        CausalNonClusteredCorrwithMovement(i,1:14) = varargin{i}.CausalNonClusteredCorrwithMovement;
        AllCausalClustersCorrwithMDC(i,1:14) = varargin{i}.CausalClustCorrwithMovementDuringCue;
        CausalNonClusteredCorrwithMDC(i,1:14) = varargin{i}.CausalNonClusteredCorrwithMovementDuringCue;
        AllCausalClustersCorrwithSuccess(i,1:14) = varargin{i}.CausalClustCorrwithSuccess;
        CausalNonClusteredCorrwithSuccess(i,1:14) = varargin{i}.CausalNonClusteredCorrwithSuccess;
        AllCausalClustCorrwithReward(i,1:14) = varargin{i}.CausalClustCorrwithReward;
        CausalNonClusteredCorrwithReward(i,1:14) = varargin{i}.CausalNonClusteredCorrwithReward;
        
        CueRelatedClustersCorrwithCue(i,1:14) = varargin{i}.CueClustersCorrwithCue;
            CueRelatedNonClusteredCorrwithCue(i,1:14) = varargin{i}.CueNonClustCorrwithCue;
        MDCRelatedClustersCorrwithMDC(i,1:14) = varargin{i}.MovementDuringCueClustersCorrwithMovementDuringCue;
            MDCRelatedNonClusteredCorrwithMDC(i,1:14) = varargin{i}.MovementDuringCueNonClustCorrwithMovementDuringCue;
        MovementRelatedClustersCorrwithMovement(i,1:14) = varargin{i}.MovementClustersCorrwithMovement;
            MovementRelatedNonClusteredCorrwithMovement(i,1:14) = varargin{i}.MovementNonClustCorrwithMovement;
        SuccessRelatedClustersCorrwithSuccess(i,1:14) = varargin{i}.SuccessClustersCorrwithSuccess;
            SuccessRelatedNonClusteredCorrwithSuccess(i,1:14) = varargin{i}.SuccessNonClustCorrwithSuccess;
        RewardRelatedClustersCorrwithReward(i,1:14) = varargin{i}.RewardClustersCorrwithReward; 
            RewardRelatedNonClusteredCorrwithReward(i,1:14) = varargin{i}.RewardNonClustCorrwithReward; 
            
        CausalCueRelatedClustersCorrwithCue(i,1:14) = varargin{i}.CausalCueClustersCorrwithCue;
            CausalCueRelatedNonClusteredCorrwithCue(i,1:14) = varargin{i}.CausalCueNonClustCorrwithCue;
        CausalMDCRelatedClustersCorrwithMDC(i,1:14) = varargin{i}.CausalMovementDuringCueClustersCorrwithMovementDuringCue;
            CausalMDCRelatedNonClusteredCorrwithMDC(i,1:14) = varargin{i}.CausalMovementDuringCueNonClustCorrwithMovementDuringCue;
        CausalMovementRelatedClustersCorrwithMovement(i,1:14) = varargin{i}.CausalMovementClustersCorrwithMovement;
            CausalMovementRelatedNonClusteredCorrwithMovement(i,1:14) = varargin{i}.CausalMovementNonClustCorrwithMovement;
        CausalSuccessRelatedClustersCorrwithSuccess(i,1:14) = varargin{i}.CausalSuccessClustersCorrwithSuccess;
            CausalSuccessRelatedNonClusteredCorrwithSuccess(i,1:14) = varargin{i}.CausalSuccessNonClustCorrwithSuccess;
        CausalRewardRelatedClustersCorrwithReward(i,1:14) = varargin{i}.CausalRewardClustersCorrwithReward; 
            CausalRewardRelatedNonClusteredCorrwithReward(i,1:14) = varargin{i}.CausalRewardNonClustCorrwithReward; 
% 
%         if any(cell2mat(cellfun(@isempty, varargin{i}.MeanCorrelationBetweenMovementSpines, 'Uni', false)))
%             varargin{i}.MeanCorrelationBetweenMovementSpines(cell2mat(cellfun(@isempty, varargin{i}.MeanCorrelationBetweenMovementSpines, 'Uni', false))) = {NaN};
%         end
%         MeanCorrelationBetweenMovementSpines(i,1:14) = cell2mat(varargin{i}.MeanCorrelationBetweenMovementSpines);
                
        FractionofCueSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofCueSpinesThatAreClustered;
        FractionofMovementSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofMovementSpinesThatAreClustered;
        FractionofPreSuccessSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofPreSuccessSpinesThatAreClustered;
        FractionofSuccessSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofSuccessSpinesThatAreClustered;
        FractionofMovementDuringCueSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofMovementDuringCueSpinesThatAreClustered;
        FractionofRewardSpinesThatAreClustered(i,1:14) = varargin{i}.FractionofRewardSpinesThatAreClustered;
        
    
        for j = 1:14    %%% Sessions
            for k = 1:length(varargin{i}.SpatioTemporalDegree{j})
%                 SpatialDegree{j} = [SpatialDegree{j}; varargin{i}.SpectralDendriteInformation{j}
                SpatioTemporalDegree{j} = [SpatioTemporalDegree{j}; varargin{i}.SpatioTemporalDegree{j}{k}];
                SpatialMovementCorrelation{j} = [SpatialMovementCorrelation{j}; varargin{i}.SpatialDegreevsMovement{j}'];
                TemporalMovementCorrelation{j} = [TemporalMovementCorrelation{j}; varargin{i}.TemporalDegreevsMovement{j}'];
                SpatioTemporalMovementCorrelation{j} = [SpatioTemporalMovementCorrelation{j}; varargin{i}.SpatioTemporalDegreevsMovement{j}'];
            end
            if ~isempty(varargin{i}.SpectralDendriteInformation{j})
                DendClusteringDegree{j} = [DendClusteringDegree{j}; varargin{i}.SpectralDendriteInformation{j}];
            end
%             AssociatedDendFreq{i} = [AssociatedDendFreq{i}; varargin{i}.SpectralDendriteInformation{j}];
%             AssociatedDendCorr{i} = [AssociatedDendCorr{i}; varargin{i}.SpectralDendriteInformation{j}];
            SpatioTemporalOverlap{j} = [SpatioTemporalOverlap{j}; nanmean(varargin{i}.SpatioTemporalOverlap{j})];
            for k = 1:length(varargin{i}.SpatialDegree{j})
                SpatialDegree{j} = [SpatialDegree{j}; varargin{i}.SpatialDegree{j}{k}];
                TemporalDegree{j} = [TemporalDegree{j}; varargin{i}.TemporalDegree{j}{k}];
            end
            CorrelationofClusters{j} = [CorrelationofClusters{j}; reshape(varargin{i}.CorrelationofClusters{j},length(varargin{i}.CorrelationofClusters{j}),1)];
        end
        
        SpatialDegreeofCueSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofCueSpines;
        TemporalDegreeofCueSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofCueSpines;
        SpatioTemporalDegreeofCueSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofCueSpines;
        SpatialDegreeofMovementSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofMovementSpines;
        TemporalDegreeofMovementSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofMovementSpines;
        SpatioTemporalDegreeofMovementSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofMovementSpines;
        SpatialDegreeofMovementDuringCueSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofMovementDuringCueSpines;
        TemporalDegreeofMovementDuringCueSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofMovementDuringCueSpines;
        SpatioTemporalDegreeofMovementDuringCueSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofMovementDuringCueSpines;
        SpatialDegreeofPreSuccessSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofPreSuccessSpines;
        TemporalDegreeofPreSuccessSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofPreSuccessSpines;
        SpatioTemporalDegreeofPreSuccessSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofPreSuccessSpines;
        SpatialDegreeofSuccessSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofSuccessSpines;
        TemporalDegreeofSuccessSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofSuccessSpines;
        SpatioTemporalDegreeofSuccessSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofSuccessSpines;
        SpatialDegreeofRewardSpines(i,1:14) = varargin{i}.MeanSpatialDegreeofRewardSpines;
        TemporalDegreeofRewardSpines(i,1:14) = varargin{i}.MeanTemporalDegreeofRewardSpines;
        SpatioTemporalDegreeofRewardSpines(i,1:14) = varargin{i}.MeanSpatioTemporalDegreeofRewardSpines;
        
        AllSpineFreq(i,1:14) = varargin{i}.AllSpineFrequency;
        MovementSpineFreq(i,1:14) = varargin{i}.MovementSpineFrequency;
        ClusterFreq(i,1:14) = varargin{i}.ClusterFrequency;
        NonClusteredFreq(i,1:14) = varargin{i}.NonClusteredFrequency;
        CueClusterFrequency(i,1:14) = varargin{i}.CueClusterFrequency;
        MovementClusterFrequency(i,1:14) = varargin{i}.MovementClusterFrequency;
        MovementDuringCueClusterFrequency(i,1:14) = varargin{i}.MovementDuringCueClusterFrequency;
        PreSuccessClusterFrequency(i,1:14) = varargin{i}.PreSuccessClusterFrequency;
        SuccessClusterFrequency(i,1:14) = varargin{i}.SuccessClusterFrequency;
        RewardClusterFrequency(i,1:14) = varargin{i}.RewardClusterFrequency;
        CausalClusterFreq(i,1:14) = varargin{i}.CausalClusterFrequency;
        NonClusteredCausalFreq(i,1:14) = varargin{i}.NonClusteredCausalFrequency;
        CausalCueClusterFrequency(i,1:14) = varargin{i}.CausalCueClusterFrequency;
        CausalMovementClusterFrequency(i,1:14) = varargin{i}.CausalMovementClusterFrequency;
        CausalMovementDuringCueClusterFrequency(i,1:14) = varargin{i}.CausalMovementDuringCueClusterFrequency;
        CausalPreSuccessClusterFrequency(i,1:14) = varargin{i}.CausalPreSuccessClusterFrequency;
        CausalSuccessClusterFrequency(i,1:14) = varargin{i}.CausalSuccessClusterFrequency;
        CausalRewardClusterFrequency(i,1:14) = varargin{i}.CausalRewardClusterFrequency;

        ClusteredSpineAmp(i,1:14) = varargin{i}.ClusteredSpineAmp;
        NonClusteredSpineAmp(i,1:14) = varargin{i}.NonClusteredSpineAmp;
        ClusteredCueSpineAmp(i,1:14) = varargin{i}.ClusteredCueSpineAmp;
        ClusteredMoveSpineAmp(i,1:14) = varargin{i}.ClusteredMovSpineAmp;
        ClusteredMovDuringCueSpineAmp(i,1:14) = varargin{i}.ClusteredMovDuringCueSpineAmp;
        ClusteredPreSuccessSpineAmp(i,1:14) = varargin{i}.ClusteredPreSuccessSpineAmp;
        ClusteredSuccessSpineAmp(i,1:14) = varargin{i}.ClusteredSuccessSpineAmp;
        ClusteredRewardSpineAmp(i,1:14) = varargin{i}.ClusteredRewardSpineAmp;
        CausalClusteredSpineAmp(i,1:14) = varargin{i}.CausalClusteredSpineAmp;
        CausalNonClusteredSpineAmp(i,1:14) = varargin{i}.CausalNonClusteredSpineAmp;
        CausalClusteredCueSpineAmp(i,1:14) = varargin{i}.CausalClusteredCueSpineAmp;
        CausalClusteredMoveSpineAmp(i,1:14) = varargin{i}.CausalClusteredMovSpineAmp;
        CausalClusteredMovDuringCueSpineAmp(i,1:14) = varargin{i}.CausalClusteredMovDuringCueSpineAmp;
        CausalClusteredPreSuccessSpineAmp(i,1:14) = varargin{i}.CausalClusteredPreSuccessSpineAmp;
        CausalClusteredSuccessSpineAmp(i,1:14) = varargin{i}.CausalClusteredSuccessSpineAmp;
        CausalClusteredRewardSpineAmp(i,1:14) = varargin{i}.CausalClusteredRewardSpineAmp;
        
        AllDendFreq(i,1:14) = varargin{i}.AllDendritesFrequency;
        MoveDendFreq(i,1:14) = varargin{i}.MovementDendritesFrequency;
        NonMoveDendFreq(i,1:14) = varargin{i}.NonMovementDendritesFrequency;
        ClustDendFreq(i,1:14) = varargin{i}.DendriteswithClustersFrequency;
        NonClustDendFreq(i,1:14) = varargin{i}.DendriteswithoutClustersFrequency;
        CueClustDendFreq(i,1:14) = varargin{i}.DendriteswithCueClustersFrequency;
        MovClustDendFreq(i,1:14) = varargin{i}.DendriteswithMovClustersFrequency;
        MovDuringCueClustDendFreq(i,1:14) = varargin{i}.DendriteswithMovDuringCueClustersFrequency;
        PreSucClustDendFreq(i,1:14) = varargin{i}.DendriteswithPreSucClustersFrequency;
        SucClustDendFreq(i,1:14) = varargin{i}.DendriteswithSucClustersFrequency;
        RewClustDendFreq(i,1:14) = varargin{i}.DendriteswithRewClustersFrequency;
        NonMovClustDendFreq(i,1:14) = varargin{i}.DendriteswithoutMovClustersFrequency;        
        
        NumberofImagedSpines(i,1:length(varargin{i}.NumberofImagedSpines(3:end))) = varargin{i}.NumberofImagedSpines(3:end); %%%%%%%%%%%%%%%% FIX!!!
        NumCueRelSpines(i,1:14) = varargin{i}.NumberofCueSpines;
        NumMovRelSpines(i,1:14) = varargin{i}.NumberofMovementRelatedSpines;
            LengthofDendrites(1:14) = cellfun(@(x,y) [x,y], LengthofDendrites, varargin{i}.LengthofDendrites, 'Uni', false);
%             FractionofMovementRelatedSpinesPerDendrite(1:14) = cellfun(@(x,y) [x,y], FractionofMovementRelatedSpinesPerDendrite, varargin{i}.FractionofMovementRelatedSpinesPerDendrite, 'Uni', false);
            FractionofMovementRelatedSpinesPerDendrite(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.FractionofMovementRelatedSpinesPerDendrite, 'Uni', false));
%             MovementRelatedSpinesPer10Microns(1:14) = cellfun(@(x,y) [x,y], MovementRelatedSpinesPer10Microns, varargin{i}.MovementRelatedSpinesPer10Microns, 'Uni', false);
            MovementRelatedSpinesPer10Microns(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.MovementRelatedSpinesPer10Microns, 'Uni', false));
%             FractionofSuccessRelatedSpinesPerDendrite(1:14) = cellfun(@(x,y) [x,y], FractionofSuccessRelatedSpinesPerDendrite, varargin{i}.FractionofSuccessRelatedSpinesPerDendrite, 'Uni', false);
            FractionofSuccessRelatedSpinesPerDendrite(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.FractionofSuccessRelatedSpinesPerDendrite, 'Uni', false));
%             SuccessRelatedSpinesPer10Microns(1:14) = cellfun(@(x,y) [x,y], SuccessRelatedSpinesPer10Microns, varargin{i}.SuccessRelatedSpinesPer10Microns, 'Uni', false);
            SuccessRelatedSpinesPer10Microns(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.SuccessRelatedSpinesPer10Microns, 'Uni', false));
        NumCueORMovRelSpines(i,1:14) = varargin{i}.NumberofCueORMovementRelatedSpines;
        NumPreSucRelSpines(i,1:14) = varargin{i}.NumberofPreSuccessSpines;
        NumSucRelSpines(i,1:14) = varargin{i}.NumberofSuccessSpines;
        NumMovDuringCueRelSpines(i,1:14) = varargin{i}.NumberofMovementDuringCueSpines;
        NumRewRelSpines(i,1:14) = varargin{i}.NumberofRewardSpines;
        NumCausalMovSpines(i,1:14) = varargin{i}.NumberofCausalMvmntSpines;
        NumCausalSucSpines(i,1:14) = varargin{i}.NumberofCausalSuccessSpines;
        NumCausalCueSpines(i,1:14) = varargin{i}.NumberofCausalCueSpines;
        
        NumHSCs(i,1:14) = varargin{i}.NumberofHighlyCorrelatedSpines;
        NumClustSpines(i,1:14) = varargin{i}.NumberofClusteredSpines;
        NumClustCueSpines(i,1:14) = varargin{i}.NumberofClusteredCueSpines;
        NumClustMovSpines(i,1:14) = varargin{i}.NumberofClusteredMovementSpines;
        NumClustMixSpines(i,1:14) = varargin{i}.NumberofClusteredMixedFunctionSpines;
        NumClustPreSucSpines(i,1:14) = varargin{i}.NumberofClusteredPreSuccessSpines;
        NumClustSucSpines(i,1:14) = varargin{i}.NumberofClusteredSuccessSpines;
        NumClustMovDuringCueSpines(i,1:14) = varargin{i}.NumberofClusteredMovementDuringCueSpines;
        NumClustRewSpines(i,1:14) = varargin{i}.NumberofClusteredRewardSpines;
        
        NumFarClustSpines(i,1:14) = varargin{i}.NumberofFarClusteredSpines;
        NumFarClustCueSpines(i,1:14) = varargin{i}.NumberofFarClusteredCueSpines;
        NumFarClustMovSpines(i,1:14) = varargin{i}.NumberofFarClusteredMovementSpines;
        NumFarClustMixSpines(i,1:14) = varargin{i}.NumberofClusteredMixedFunctionSpines;
        NumFarClustPreSucSpines(i,1:14) = varargin{i}.NumberofFarClusteredPreSuccessSpines;
        NumFarClustSucSpines(i,1:14) = varargin{i}.NumberofFarClusteredSuccessSpines;
        NumFarClustMovDuringCueSpines(i,1:14) = varargin{i}.NumberofFarClusteredMovementDuringCueSpines;
        NumFarClustRewSpines(i,1:14) = varargin{i}.NumberofFarClusteredRewardSpines;
        
        NumCausClustSpines(i,1:14) = varargin{i}.NumberofCausalClusteredSpines;
        NumCausClustCueSpines(i,1:14) = varargin{i}.NumberofCausalClusteredCueSpines;
        NumCausClustMovSpines(i,1:14) = varargin{i}.NumberofCausalClusteredMovementSpines;
        NumCausClustMovDuringCueSpines(i,1:14) = varargin{i}.NumberofCausalClusteredMovementDuringCueSpines;
        NumCausClustPreSucSpines(i,1:14) = varargin{i}.NumberofCausalClusteredSuccessSpines;
        NumCausClustSucSpines(i,1:14) = varargin{i}.NumberofCausalClusteredSuccessSpines;
        NumCausClustRewSpines(i,1:14) = varargin{i}.NumberofCausalClusteredRewardSpines;

        NumberofClusters(i,1:14) = varargin{i}.NumberofClusters;
        NumberofCausalClusters(i,1:14) = varargin{i}.NumberofCausalClusters;
        NumberofSpinesinEachCluster(i,1:14) = varargin{i}.MeanNumberofSpinesinEachCluster;
        NumberofSpinesinEachCausalCluster(i,1:14) = varargin{i}.MeanNumberofSpinesinEachCausalCluster;
        NumberofMovClusters(i,1:14) = varargin{i}.NumberofMovClusters;
        NumberofSpinesinEachMovCluster(i,1:14) = varargin{i}.MeanNumberofSpinesinEachMovCluster;
        
        CueClusterLength(i,1:14) = varargin{i}.MeanCueClustLength;
        CueClusterMax(i,1:14) = varargin{i}.MaxCueClustLength;
        MovClusterLength(i,1:14) = varargin{i}.MeanMovClustLength;
            AllMovClustLengths(1:14) = cellfun(@(x,y) [x,y], AllMovClustLengths, varargin{i}.AllMovClustLengths, 'Uni', false);
        MovClusterMax(i,1:14) = varargin{i}.MaxMovClustLength;
        MixClusterLength(i,1:14) = varargin{i}.MeanMixClustLength;
        MixClusterMax(i,1:14) = varargin{i}.MaxMixClustLength;
        PreSucClusterLength(i,1:14) = varargin{i}.MeanPreSucClustLength;
        PreSucClusterMax(i,1:14) = varargin{i}.MaxPreSucClustLength;
        SucClusterLength(i,1:14) = varargin{i}.MeanSucClustLength;
        SucClusterMax(i,1:14) = varargin{i}.MaxSucClustLength;
        MovDuringCueClusterLength(i,1:14) = varargin{i}.MeanMovDuringCueClustLength;
        MovDuringCueClusterMax(i,1:14) = varargin{i}.MaxMovDuringCueClustLength;
        RewClusterLength(i,1:14) = varargin{i}.MeanRewClustLength;
        RewClusterMax(i,1:14) = varargin{i}.MaxRewClustLength;
        
        AllClusterLength(i,1:14) = varargin{i}.MeanAllClustLength;
        AllClusterMax(i,1:14) = varargin{i}.MaxAllClustLength;
        CausalCueClusterLength(i,1:14) = varargin{i}.MeanCausalCueClustLength;
        CausalCueClusterMax(i,1:14) = varargin{i}.MaxCausalCueClustLength;
        CausalMovClusterLength(i,1:14) = varargin{i}.MeanCausalMovClustLength;
        CausalMovClusterMax(i,1:14) = varargin{i}.MaxCausalMovClustLength;
        CausalSucClusterLength(i,1:14) = varargin{i}.MeanCausalSucClustLength;
        CausalSucClusterMax(i,1:14) = varargin{i}.MaxCausalSucClustLength;
        CausalRewClusterLength(i,1:14) = varargin{i}.MeanCausalRewClustLength;
        CausalRewClusterMax(i,1:14) = varargin{i}.MaxCausalRewClustLength;
        AllCausalClusterLength(i,1:14) = varargin{i}.MeanCausalAllClustLength;
        AllCausalClusterMax(i,1:14) = varargin{i}.MaxCausalAllClustLength;
        
        AllFarClusterLength(i,1:14) = varargin{i}.MeanAllFarClustLength;
        FarCueClusterLength(i,1:14) = varargin{i}.MeanFarCueClustLength;
        FarMovClusterLength(i,1:14) = varargin{i}.MeanFarMovClustLength;
        FarMixClusterLength(i,1:14) = varargin{i}.MeanFarMixClustLength;
        FarPreSucClusterLength(i,1:14) = varargin{i}.MeanFarPreSucClustLength;
        FarSucClusterLength(i,1:14) = varargin{i}.MeanFarSucClustLength;
        FarMovDuringCueClusterLength(i,1:14) = varargin{i}.MeanFarMovDuringCueClustLength;
        FarRewClusterLength(i,1:14) = varargin{i}.MeanFarRewClustLength;
        
        AllDistancesBetweenAllSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenAllSpines, varargin{i}.DistanceBetweenAllSpines, 'Uni', false);
        CorrelationBetweenAllSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenAllSpines, varargin{i}.CorrelationBetweenAllSpines, 'Uni', false);
            MeanCorrelationBetweenAllSpines(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.CorrelationBetweenAllSpines, 'Uni', false));
            MeanCorrelationBetweenAllCloseSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y<15)), varargin{i}.CorrelationBetweenAllSpines,varargin{i}.DistanceBetweenAllSpines, 'Uni', false));
            MeanCorrelationBetweenAllDistantSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y>15)), varargin{i}.CorrelationBetweenAllSpines,varargin{i}.DistanceBetweenAllSpines, 'Uni', false));
        CorrelationBetweenAllSpinesMovePeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenAllSpinesMovePeriods, varargin{i}.CorrelationBetweenAllSpinesMovementPeriods, 'Uni', false);
        CorrelationBetweenAllSpinesStillPeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenAllSpinesStillPeriods, varargin{i}.CorrelationBetweenAllSpinesStillPeriods, 'Uni', false);
        AdjacencyValuesforAllSpines = cellfun(@(x,y) [x,y], AdjacencyValuesforAllSpines, varargin{i}.AdjacencyValuesforAllSpines, 'Uni', false);
        SharedPairwiseCorrelationValuesforAllSpines = cellfun(@(x,y) [x,y], SharedPairwiseCorrelationValuesforAllSpines, varargin{i}.SharedPairwiseCorrelationValuesforAllSpines, 'Uni', false);
        SharedPairwiseReliabilityValuesforAllSpines = cellfun(@(x,y) [x,y], SharedPairwiseReliabilityValuesforAllSpines, varargin{i}.SharedPairwiseReliabilityValuesforAllSpines, 'Uni', false);

                
        MovementSpineReliability(1:14) =  cellfun(@(x,y) [x;y], MovementSpineReliability, varargin{i}.MovementSpineReliability, 'Uni', false);
            MeanMovementSpineReliability(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.MovementSpineReliability', 'Uni', false));
        AllSpineReliability(1:14) = cellfun(@(x,y) [x;y], AllSpineReliability, varargin{i}.AllSpineReliability, 'Uni', false);
            MeanAllSpineReliability(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.AllSpineReliability, 'Uni', false));

        if any(cell2mat(cellfun(@(x,y) length(x)~=length(y), varargin{i}.CorrelationBetweenFarSpines, varargin{i}.DistanceBetweenFarSpines, 'Uni', false)))
            problemdays = find(cell2mat(cellfun(@(x,y) length(x)~=length(y), varargin{i}.CorrelationBetweenFarSpines, varargin{i}.DistanceBetweenFarSpines, 'Uni', false)));
            file = inputname(i); file = file(1:5);
            for c = 1:length(problemdays)
                fprintf('Corr. and dist. vectors \n not equal for session %d \n from input %2s, \n (check spine/dend grouping in original file) \n', problemdays(c), file);  %%% If this happens, check the original file; this usually comes from Spine-Dendrite grouping data having duplicate values!!
            end
        end
        
        AllDistancesBetweenAlloDendriticSpines(1:14) = cellfun(@(x,y) [x;y], AllDistancesBetweenAlloDendriticSpines, varargin{i}.DistanceBetweenFarSpines, 'Uni', false);
        CorrelationBetweenAlloDendriticSpines(1:14) = cellfun(@(x,y) [x;y], CorrelationBetweenAlloDendriticSpines, varargin{i}.CorrelationBetweenFarSpines, 'Uni', false);
            MeanCorrelationBetweenAlloDendriticSpines(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.CorrelationBetweenFarSpines, 'Uni', false));
        AllDistancesBetweenSameCellDiffBranchSpines(1:14) = cellfun(@(x,y) [x;y], AllDistancesBetweenSameCellDiffBranchSpines, varargin{i}.DistanceBetweenAllBranchSpines, 'Uni', false);
        CorrelationBetweenSameCellDiffBranchSpines(1:14) = cellfun(@(x,y) [x;y], CorrelationBetweenSameCellDiffBranchSpines, varargin{i}.CorrelationBetweenAllBranchSpines, 'Uni', false);
            MeanCorrelationBetweenSameCellDiffBranchSpines(1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.CorrelationBetweenAllBranchSpines, 'Uni', false));
        MovSpinetoNearestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], MovSpinetoNearestMovementRelatedSpine, varargin{i}.NearestMovementRelatedSpine, 'Uni', false);
        MovSpinetoNextClosestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], MovSpinetoNextClosestMovementRelatedSpine, varargin{i}.NextClosestMovementRelatedSpine, 'Uni', false);
        MovSpinetoThirdClosestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], MovSpinetoThirdClosestMovementRelatedSpine, varargin{i}.ThirdClosestMovementRelatedSpine, 'Uni', false);
        MovSpinetoFourthClosestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], MovSpinetoFourthClosestMovementRelatedSpine, varargin{i}.FourthClosestMovementRelatedSpine, 'Uni', false);
        CorrelationwithNearestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], CorrelationwithNearestMovementRelatedSpine, varargin{i}.CorrelationwithNearestMovementRelatedSpine, 'Uni', false);
        CorrelationwithFarthestMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], CorrelationwithFarthestMovementRelatedSpine, varargin{i}.CorrelationwithFarthestMovementRelatedSpine, 'Uni', false);
        MoveSpinetoNearestFunctionallyClusteredMoveSpine(1:14) = cellfun(@(x,y) [x,y], MoveSpinetoNearestFunctionallyClusteredMoveSpine, varargin{i}.MoveSpinetoNearestFunctionallyClusteredMoveSpine, 'Uni', false);
        MoveSpinetoNextFunctionallyClusteredMoveSpine(1:14) = cellfun(@(x,y) [x,y], MoveSpinetoNextFunctionallyClusteredMoveSpine, varargin{i}.MoveSpinetoNextFunctionallyClusteredMoveSpine, 'Uni', false);
        MoveSpinetoThirdFunctionallyClusteredMoveSpine(1:14) = cellfun(@(x,y) [x,y], MoveSpinetoThirdFunctionallyClusteredMoveSpine, varargin{i}.MoveSpinetoThirdFunctionallyClusteredMoveSpine, 'Uni', false);
        MoveSpinetoFourthFunctionallyClusteredMoveSpine(1:14) = cellfun(@(x,y) [x,y], MoveSpinetoFourthFunctionallyClusteredMoveSpine, varargin{i}.MoveSpinetoFourthFunctionallyClusteredMoveSpine, 'Uni', false);
        AllCorrelationswithNearbyMetaClusters(1:14) = cellfun(@(x,y) [x;y], AllCorrelationswithNearbyMetaClusters, varargin{i}.AllCorrelationswithNearbyMetaClusters, 'Uni', false);
        AllCorrelationswithDistantMetaClusters(1:14) = cellfun(@(x,y) [x;y], AllCorrelationswithDistantMetaClusters, varargin{i}.AllCorrelationswithDistantMetaClusters, 'uni', false);
        CorrofNearestMetaCluster(1:14) = cellfun(@(x,y) [x,y], CorrofNearestMetaCluster, varargin{i}.CorrelationofNearestMetaCluster, 'Uni', false);
        CorrofNextMetaCluster(1:14) = cellfun(@(x,y) [x,y], CorrofNextMetaCluster, varargin{i}.CorrelationofNextMetaCluster, 'uni', false);
        CorrofThirdMetaCluster(1:14) = cellfun(@(x,y) [x,y], CorrofThirdMetaCluster, varargin{i}.CorrelationofThirdMetaCluster, 'uni', false);
        CorrofFourthMetaCluster(1:14) = cellfun(@(x,y) [x,y], CorrofFourthMetaCluster, varargin{i}.CorrelationofFourthMetaCluster, 'uni', false);
        RandomMovementPairCorr(1:14) = cellfun(@(x,y) [x,y,], RandomMovementPairCorr, varargin{i}.RandomMovementPairCorrelation, 'uni', false);
        NearestFunctionallyClusteredMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], NearestFunctionallyClusteredMovementRelatedSpine, varargin{i}.NearestFunctionallyClusteredMovementRelatedSpine, 'Uni', false);
        NearestHighlyCorrelatedMovementRelatedSpine(1:14) = cellfun(@(x,y) [x,y], NearestHighlyCorrelatedMovementRelatedSpine, varargin{i}.NearestHighlyCorrelatedMovementRelatedSpine, 'Uni', false);
        NextClosestFunctionallyClusteredMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], NextClosestFunctionallyClusteredMovementRelatedSpine, varargin{i}.NextClosestFunctionallyClusteredMovementRelatedSpine, 'Uni', false);
        NextClosestHighlyCorrelatedMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], NextClosestHighlyCorrelatedMovementRelatedSpine, varargin{i}.NextClosestHighlyCorrelatedMovementRelatedSpine, 'Uni', false);
        ThirdClosestFunctionallyClusteredMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], ThirdClosestFunctionallyClusteredMovementRelatedSpine, varargin{i}.ThirdClosestFunctionallyClusteredMovementRelatedSpine, 'Uni', false);
        ThirdClosestHighlyCorrelatedMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], ThirdClosestHighlyCorrelatedMovementRelatedSpine, varargin{i}.ThirdClosestHighlyCorrelatedMovementRelatedSpine, 'Uni', false);
        FourthClosestFunctionallyClusteredMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], FourthClosestFunctionallyClusteredMovementRelatedSpine, varargin{i}.FourthClosestFunctionallyClusteredMovementRelatedSpine, 'Uni', false);
        FourthClosestHighlyCorrelatedMovementRelatedSpine(1:14) =  cellfun(@(x,y) [x,y], FourthClosestHighlyCorrelatedMovementRelatedSpine, varargin{i}.FourthClosestHighlyCorrelatedMovementRelatedSpine, 'Uni', false);
        DistanceBetweenCueSpines(i,1:14) = varargin{i}.MeanDistanceBetweenCueSpines;
        DistanceBetweenMovementSpines(i,1:14) = varargin{i}.MeanDistanceBetweenMovementSpines;
        AllDistancesBetweenMovementSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenMovementSpines, varargin{i}.DistanceBetweenMovementSpines, 'Uni', false);
        AllDistancesBetweenPreSuccessSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenPreSuccessSpines, varargin{i}.DistanceBetweenPreSuccessSpines, 'Uni', false);
        AllDistancesBetweenSuccessSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenSuccessSpines, varargin{i}.DistanceBetweenSuccessSpines, 'Uni', false);
        CorrelationBetweenMovementSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenMovementSpines, varargin{i}.CorrelationBetweenMovementSpines, 'Uni', false);
            condendweights(i,1:14) = cell2mat(cellfun(@(x) numel(x), varargin{i}.CorrelationBetweenMovementSpines, 'Uni', false));
            MeanCorrelationBetweenMovementSpines(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.CorrelationBetweenMovementSpines, 'Uni', false));
            MeanCorrelationBetweenCloseMovementSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y<10)), varargin{i}.CorrelationBetweenMovementSpines,varargin{i}.DistanceBetweenMovementSpines, 'Uni', false));
            MeanCorrelationBetweenDistantMovementSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y>10 & y<50)), varargin{i}.CorrelationBetweenMovementSpines,varargin{i}.DistanceBetweenMovementSpines, 'Uni', false));
        CorrelationBetweenMovementSpinesMovePeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenMovementSpinesMovePeriods, varargin{i}.CorrelationBetweenMovementSpinesMovementPeriods, 'Uni', false);
        CorrelationBetweenMovementSpinesStillPeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenMovementSpinesStillPeriods, varargin{i}.CorrelationBetweenMovementSpinesStillPeriods, 'Uni', false);
        CorrelationBetweenPreMovementSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenPreMovementSpines, varargin{i}.CorrelationBetweenPreMovementSpines, 'Uni', false);
        CorrelationBetweenSuccessSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenSuccessSpines, varargin{i}.CorrelationBetweenSuccessSpines, 'Uni', false);
            MeanCorrelationBetweenSuccessSpines(i,1:14) = cell2mat(cellfun(@(x) nanmean(x), varargin{i}.CorrelationBetweenSuccessSpinesMovementPeriods, 'Uni', false));
            MeanCorrelationBetweenCloseSuccessSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y<15)), varargin{i}.CorrelationBetweenSuccessSpinesMovementPeriods,varargin{i}.DistanceBetweenSuccessSpines, 'Uni', false));
            MeanCorrelationBetweenDistantSuccessSpines(i,1:14) = cell2mat(cellfun(@(x,y) nanmean(x(y>15 & y<50)), varargin{i}.CorrelationBetweenSuccessSpinesMovementPeriods,varargin{i}.DistanceBetweenSuccessSpines, 'Uni', false));
        CorrelationBetweenSuccessSpinesMovePeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenSuccessSpinesMovePeriods, varargin{i}.CorrelationBetweenSuccessSpinesMovementPeriods, 'Uni', false);
        CorrelationBetweenSuccessSpinesStillPeriods(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenSuccessSpinesStillPeriods, varargin{i}.CorrelationBetweenSuccessSpinesStillPeriods, 'Uni', false);
        AllDistancesBetweenAlloDendriticMovementSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenAlloDendriticMovementSpines, varargin{i}.DistanceBetweenFarMovementSpines, 'Uni', false);
        CorrelationBetweenAllodendriticMovementSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenAllodendriticMovementSpines, varargin{i}.CorrelationBetweenFarMovementSpines, 'Uni', false);
            MeanCorrelationBetweenAlloDendriticMovementSpines(i,1:14) = cell2mat(cellfun(@nanmean, varargin{i}.CorrelationBetweenFarMovementSpines, 'Uni', false));
        AllDistancesBetweenSameCellDiffBranchMovementSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenSameCellDiffBranchMovementSpines, varargin{i}.DistanceBetweenBranchMovementSpines, 'Uni', false);
        CorrelationBetweenSameCellDiffBranchMovementSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenSameCellDiffBranchMovementSpines, varargin{i}.CorrelationBetweenBranchMovementSpines, 'Uni', false);
            branchweights(i,1:14) = cell2mat(cellfun(@(x) numel(x), varargin{i}.CorrelationBetweenBranchMovementSpines, 'Uni', false));
            MeanCorrelationBetweenSameCellDiffBranchMovementSpines(i,1:14) = cell2mat(cellfun(@nanmean, varargin{i}.CorrelationBetweenBranchMovementSpines, 'Uni', false));
        AllDistancesBetweenSameCellDiffBranchSuccessSpines(1:14) = cellfun(@(x,y) [x,y], AllDistancesBetweenSameCellDiffBranchSuccessSpines, varargin{i}.DistanceBetweenBranchSuccessSpines, 'Uni', false);
        CorrelationBetweenSameCellDiffBranchSuccessSpines(1:14) = cellfun(@(x,y) [x,y], CorrelationBetweenSameCellDiffBranchSuccessSpines, varargin{i}.CorrelationBetweenBranchSuccessSpines, 'Uni', false);
            MeanCorrelationBetweenSameCellDiffBranchSuccessSpines(i,1:14) = cell2mat(cellfun(@nanmean, varargin{i}.CorrelationBetweenBranchSuccessSpines, 'Uni', false));
        DistanceBetweenPreSuccessSpines(i,1:14) = varargin{i}.MeanDistanceBetweenPreSuccessSpines;
        DistanceBetweenSuccessSpines(i,1:14) = varargin{i}.MeanDistanceBetweenSuccessSpines;
        DistanceBetweenMovementDuringCueSpines(i,1:14) = varargin{i}.MeanDistanceBetweenMovementDuringCueSpines;
        DistanceBetweenRewardSpines(i,1:14) = varargin{i}.MeanDistanceBetweenRewardSpines;
        
        ClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.ClusteredSpines_CorrwithDend;
        FilteredClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.FilteredClusteredSpines_CorrwithDend;
        NonClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.NonClusteredSpines_CorrwithDend;
        CausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.CausalClusteredSpines_CorrwithDend;
        FilteredCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.FilteredCausalClusteredSpines_CorrwithDend;
        NonCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.NonCausalClusteredSpines_CorrwithDend;
        CueRelClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.CueRelClusteredSpines_CorrwithDend;
        MovRelClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.MovRelClusteredSpines_CorrwithDend;
        SucRelClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.SucRelClusteredSpines_CorrwithDend;
        RewRelClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.RewRelClusteredSpines_CorrwithDend;
        CueRelCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.CueRelCausalClusteredSpines_CorrwithDend;
        MovRelCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.MovRelCausalClusteredSpines_CorrwithDend;
        SucRelCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.SucRelCausalClusteredSpines_CorrwithDend;
        RewRelCausalClusteredSpines_CorrwithDend(i,1:14) = varargin{i}.RewRelCausalClusteredSpines_CorrwithDend;
        
%         FractionofClusterThatsMovementRelated(i,1:14) = varargin{i}.AverageFractionofaClusterThatsMovementRelated;
%         FractionofCausalClusterThatsMovementRelated(i,1:14) = varargin{i}.AverageFractionofaCausalClusterThatsMovementRelated;
    
        PercentofCueRelatedDendrites(i,1:14) = varargin{i}.PercentofCueRelatedDendrites;
        PercentofMovementRelatedDendrites(i,1:14) = varargin{i}.PercentofMovementRelatedDendrites;
        PercentofPreSuccessRelatedDendrites(i,1:14) = varargin{i}.PercentofPreSuccessRelatedDendrites;
        PercentofSuccessRelatedDendrites(i,1:14) = varargin{i}.PercentofSuccessRelatedDendrites;
        PercentofMovementDuringCueRelatedDendrites(i,1:14) = varargin{i}.PercentofMovementDuringCueRelatedDendrites;
        PercentofRewardRelatedDendrites(i,1:14) = varargin{i}.PercentofRewardRelatedDendrites;
        
%         Spatial_Degree(i,1:14) = varargin{i}.MeanDendriticSpatialDegree;
%         Temporal_Degree(i,1:14) = varargin{i}.MeanDendriticTemporalDegree;
%         ST_Degree(i,1:14) = varargin{i}.MeanDendriticSpatioTemporalDegree;

        MovementClusters(i,1:14) = varargin{i}.HighlyCorrelatedMovementRelatedSpines;
    end
    
        totalnums = sum(condendweights,1);
        totalnums = repmat(totalnums,length(varargin),1);
        condendweights = condendweights./totalnums;
    
        MeanCorrelationBetweenMovementSpines = MeanCorrelationBetweenMovementSpines.*condendweights;
        MeanCorrelationBetweenCloseMovementSpines = MeanCorrelationBetweenCloseMovementSpines.*condendweights;
        MeanCorrelationBetweenDistantMovementSpines = MeanCorrelationBetweenDistantMovementSpines.*condendweights;
        MeanCorrelationBetweenSuccessSpines = MeanCorrelationBetweenSuccessSpines.*condendweights;
        MeanCorrelationBetweenCloseSuccessSpines = MeanCorrelationBetweenCloseSuccessSpines.*condendweights;
        MeanCorrelationBetweenDistantSuccessSpines = MeanCorrelationBetweenDistantSuccessSpines.*condendweights;
        
        branchnums = sum(branchweights,1);
        branchnums = repmat(branchnums,length(varargin),1);
        branchweights = branchweights./branchnums;
        MeanCorrelationBetweenSameCellDiffBranchMovementSpines = MeanCorrelationBetweenSameCellDiffBranchMovementSpines.*branchweights;

    
    %%% Save Organized data for stats %%%
        
        a.AllClustersCorrwithCue = AllClustersCorrwithCue;
        a.NonClusteredCorrwithCue = NonClusteredCorrwithCue;
        a.AllSpinesCorrwithMovement = AllSpinesCorrwithMovement;
        a.AllClustersCorrwithMovement = AllClustersCorrwithMovement;
        a.NonClusteredCorrwithMovement = NonClusteredCorrwithMovement;
        a.AllClustersCorrwithMDC = AllClustersCorrwithMDC;
        a.NonClusteredCorrwithMDC = NonClusteredCorrwithMDC;
        a.AllClustersCorrwithSuccess = AllClustersCorrwithSuccess;
        a.NonClusteredCorrwithSuccess = NonClusteredCorrwithSuccess;
        a.AllClustCorrwithReward = AllClustCorrwithReward;
        a.NonClusteredCorrwithReward = NonClusteredCorrwithReward;
        
        a.CorrelationofClusters = CorrelationofClusters;
        
        a.AllCausalClustersCorrwithMovement = AllCausalClustersCorrwithMovement;
        a.CausalNonClusteredCorrwithMovement = CausalNonClusteredCorrwithMovement;
        a.AllCausalClustersCorrwithCue = AllCausalClustersCorrwithCue;
        a.CausalNonClusteredCorrwithCue = CausalNonClusteredCorrwithCue;
        a.AllCausalClustersCorrwithMDC = AllCausalClustersCorrwithMDC;
        a.CausalNonClusteredCorrwithMDC = CausalNonClusteredCorrwithMDC;
        a.AllCausalClustersCorrwithSuccess = AllCausalClustersCorrwithSuccess;
        a.CausalNonClusteredCorrwithSuccess = CausalNonClusteredCorrwithSuccess;
        a.AllCausalClustCorrwithReward = AllCausalClustCorrwithReward;
        a.CausalNonClusteredCorrwithReward = CausalNonClusteredCorrwithReward;
        
        a.CueRelatedClustersCorrwithCue = CueRelatedClustersCorrwithCue;
        a.CueRelatedNonClusteredCorrwithCue = CueRelatedNonClusteredCorrwithCue;
        a.MovementRelatedClustersCorrwithMovement = MovementRelatedClustersCorrwithMovement;
        a.MovementRelatedNonClusteredCorrwithMovement = MovementRelatedNonClusteredCorrwithMovement;
        a.MDCRelatedClustersCorrwithMDC = MDCRelatedClustersCorrwithMDC;
        a.MDCRelatedNonClusteredCorrwithMDC = MDCRelatedNonClusteredCorrwithMDC; 
        a.SuccessRelatedClustersCorrwithSuccess = SuccessRelatedClustersCorrwithSuccess;
        a.SuccessRelatedNonClsuteredCorrwithSuccess = SuccessRelatedNonClusteredCorrwithSuccess;
        a.RewardRelatedClutersCorrwithReward = RewardRelatedClustersCorrwithReward;
        a.RewardRelatedNonClusteredCorrwithReward = RewardRelatedNonClusteredCorrwithReward;
        
        a.CausalCueRelatedClustersCorrwithCue = CausalCueRelatedClustersCorrwithCue;
        a.CausalCueRelatedNonClusteredCorrwithCue = CausalCueRelatedNonClusteredCorrwithCue;
        a.CausalMovementRelatedClustersCorrwithMovement = CausalMovementRelatedClustersCorrwithMovement;
        a.CausalMovementRelatedNonClusteredCorrwithMovement = CausalMovementRelatedNonClusteredCorrwithMovement;
        a.CausalMDCRelatedClustersCorrwithMDC = CausalMDCRelatedClustersCorrwithMDC;
        a.CausalMDCRelatedNonClusteredCorrwithMDC = CausalMDCRelatedNonClusteredCorrwithMDC; 

        a.CausalSuccessRelatedClustersCorrwithSuccess = CausalSuccessRelatedClustersCorrwithSuccess;
        a.CausalSuccessRelatedNonClsuteredCorrwithSuccess = CausalSuccessRelatedNonClusteredCorrwithSuccess;
        a.CausalRewardRelatedClutersCorrwithReward = CausalRewardRelatedClustersCorrwithReward;
        a.CausalRewardRelatedNonClusteredCorrwithReward = CausalRewardRelatedNonClusteredCorrwithReward;
        
        a.FractionofCueSpinesThatAreClustered = FractionofCueSpinesThatAreClustered;
        a.FractionofMovementSpinesThatAreClustered = FractionofMovementSpinesThatAreClustered;
        a.FractionofPreSuccessSpinesThatAreClustered = FractionofPreSuccessSpinesThatAreClustered;
        a.FractionofSuccessSpinesThatAreClustered = FractionofSuccessSpinesThatAreClustered;
        a.FractionofMDCSpinesThatAreClustered = FractionofMovementDuringCueSpinesThatAreClustered;
        a.FractionofRewardSpinesThatAreClustred = FractionofRewardSpinesThatAreClustered;
        
    
        a.SpatioTemporalDegree = SpatioTemporalDegree;
        a.SpatialMovementCorrelation = SpatialMovementCorrelation;
        a.TemporalMovementCorrelation = TemporalMovementCorrelation;
        a.SpatioTemporalMovementCorrelation = SpatioTemporalMovementCorrelation;
        a.DendClusteringDegree = DendClusteringDegree;
        a.DendClusteringDegree = SpatioTemporalOverlap;
        a.SpatialDegree = SpatialDegree;
        a.TemporalDegree = TemporalDegree;
        a.SpatialDegreeofCueSpines = SpatialDegreeofCueSpines;
        a.TemporalDegreeofCueSpines = TemporalDegreeofCueSpines;
        a.SpatioTemporalDegreeofCueSpines = SpatioTemporalDegreeofCueSpines;
        a.SpatialDegreeofMovementSpines = SpatialDegreeofMovementSpines;
        a.TemporalDegreeofMovementSpines = TemporalDegreeofMovementSpines;
        a.SpatioTemporalDegreeofMovementSpines = SpatioTemporalDegreeofMovementSpines;
        a.SpatialDegreeofMovementDuringCueSpines = SpatialDegreeofMovementDuringCueSpines;
        a.TemporalDegreeofMovementDuringCueSpines = TemporalDegreeofMovementDuringCueSpines;
        a.SpatioTemporalDegreeofMovementDuringCueSpines = SpatioTemporalDegreeofMovementDuringCueSpines;
        a.SpatialDegreeofPreSuccessSpines = SpatialDegreeofPreSuccessSpines;
        a.TemporalDegreeofPreSuccessSpines = TemporalDegreeofPreSuccessSpines;
        a.SpatioTemporalDegreeofPreSuccessSpines = SpatioTemporalDegreeofPreSuccessSpines;
        a.SpatialDegreeofSuccessSpines = SpatialDegreeofSuccessSpines;
        a.TemporalDegreeofSuccessSpines = TemporalDegreeofSuccessSpines;
        a.SpatioTemporalDegreeofSuccessSpines = SpatioTemporalDegreeofSuccessSpines;
        a.SpatialDegreeofRewardSpines = SpatialDegreeofRewardSpines;
        a.TemporalDegreeofRewardSpines = TemporalDegreeofRewardSpines;
        a.SpatioTemporalDegreeofRewardSpines = SpatioTemporalDegreeofRewardSpines;
        
        a.AllSpineFrequency = AllSpineFreq;
        a.MovementSpineFrequency = MovementSpineFreq;
        a.ClusterFreq = ClusterFreq;
        a.NonClusterFreq = NonClusteredFreq;
        a.CueClusterFrequency = CueClusterFrequency;
        a.MovementClusterFrequency = MovementClusterFrequency;
        a.MovementDuringCueClusterFrequency = MovementDuringCueClusterFrequency;
        a.PreSuccessClusterFrequency = PreSuccessClusterFrequency;
        a.SuccessClusterFrequency = SuccessClusterFrequency;
        a.RewardClusterFrequency = RewardClusterFrequency;
        a.CausalClusterFreq = CausalClusterFreq;
        a.NonClusteredCausalFreq = NonClusteredCausalFreq;
        a.CausalCueClusterFrequency = CausalCueClusterFrequency;
        a.CausalMovementClusterFrequency = CausalMovementClusterFrequency;
        a.CausalMovementDuringCueClusterFrequency = CausalMovementDuringCueClusterFrequency;
        a.CausalPreSuccessClusterFrequency = CausalPreSuccessClusterFrequency;
        a.CausalSuccessClusterFrequency = CausalSuccessClusterFrequency;
        a.CausalRewardClusterFrequency = CausalRewardClusterFrequency;

        a.ClusteredSpineAmp = ClusteredSpineAmp;
        a.NonClusteredSpineAmp = NonClusteredSpineAmp;
        a.ClusteredCueSpineAmp = ClusteredCueSpineAmp;
        a.ClusteredMoveSpineAmp = ClusteredMoveSpineAmp;
        a.ClusteredMovDuringCueSpineAmp = ClusteredMovDuringCueSpineAmp;
        a.ClusteredPreSuccessSpineAmp = ClusteredPreSuccessSpineAmp;
        a.ClusteredSuccessSpineAmp = ClusteredSuccessSpineAmp;
        a.ClusteredRewardSpineAmp = ClusteredRewardSpineAmp;
        a.CausalClusteredSpineAmp = CausalClusteredSpineAmp;
        a.CausalNonClusteredSpineAmp = CausalNonClusteredSpineAmp;
        a.CausalClusteredCueSpineAmp = CausalClusteredCueSpineAmp;
        a.CausalClusteredMoveSpineAmp = CausalClusteredMoveSpineAmp;
        a.CausalClusteredMovDuringCueSpineAmp = CausalClusteredMovDuringCueSpineAmp;
        a.CausalClusteredPreSuccessSpineAmp = CausalClusteredPreSuccessSpineAmp;
        a.CausalClusteredSuccessSpineAmp = CausalClusteredSuccessSpineAmp;
        a.CausalClusteredRewardSpineAmp = CausalClusteredRewardSpineAmp;
        
        a.AllDendriteFrequencies = AllDendFreq;
        a.MovementDendriteFrequencies = MoveDendFreq;
        a.NonMovementDendriteFrequencies = NonMoveDendFreq;
        a.ClustDendFreq = ClustDendFreq;
        a.NonClustDendFreq =NonClustDendFreq;
        a.MovClustDendFreq = MovClustDendFreq;
        a.NonMovClustDendFreq = NonMovClustDendFreq;
        
        a.NumberofImagedSpines = NumberofImagedSpines;
        a.NumCueRelSpines = NumCueRelSpines;
        a.NumMvmtSpines = NumMovRelSpines;
        a.LengthofDendrites = LengthofDendrites;
        a.FractionofMovementRelatedSpinesPerDendrite = FractionofMovementRelatedSpinesPerDendrite;
        a.MovementRelatedSpinesPer10Microns = MovementRelatedSpinesPer10Microns;
        a.FractionofSuccessRelatedSpinesPerDendrite = FractionofSuccessRelatedSpinesPerDendrite;
        a.SuccessRelatedSpinesPer10Microns = SuccessRelatedSpinesPer10Microns;
        a.NumCueORMovRelSpines = NumCueORMovRelSpines;
        a.NumPreSucRelSpines = NumPreSucRelSpines;
        a.NumSucRelSpines = NumSucRelSpines;
        a.NumMovDuringCueRelSpines = NumMovDuringCueRelSpines;
        a.NumRewRelSpines = NumRewRelSpines;
        a.NumCausalMovSpines = NumCausalMovSpines;
        a.NumCausalSucSpines = NumCausalSucSpines;
        a.NumCausalCueSpines = NumCausalCueSpines;
        a.NumHSCs = NumHSCs;
        a.NumClustSpines = NumClustSpines;
        a.NumClustCueSpines = NumClustCueSpines;
        a.NumClustMovSpines = NumClustMovSpines;
        a.NumClustMixSpines = NumClustMixSpines;
        a.NumClustPreSucSpines = NumClustPreSucSpines;
        a.NumClustSucSpines = NumClustSucSpines;
        a.NumClustMovDuringCueSpines = NumClustMovDuringCueSpines;
        a.NumClustRewSpines = NumClustRewSpines;
        a.NumFarClustSpines = NumFarClustSpines;
        a.NumFarClustCueSpines = NumFarClustCueSpines;
        a.NumFarClustMovSpines = NumFarClustMovSpines;
        a.NumFarClustMixSpines = NumFarClustMixSpines;
        a.NumFarClustPreSucSpines = NumFarClustPreSucSpines;
        a.NumFarClustSucSpines = NumFarClustSucSpines;
        a.NumFarClustMovDuringCueSpines = NumFarClustMovDuringCueSpines;
        a.NumFarClustRewSpines = NumFarClustRewSpines;
        a.NumCausClustSpines = NumCausClustSpines;
        a.NumCausClustCueSpines = NumCausClustCueSpines;
        a.NumCausClustMovSpines = NumCausClustMovSpines;
        a.NumCausClustMovDuringCueSpines = NumCausClustMovDuringCueSpines;
        a.NumCausClustPreSucSpines = NumCausClustPreSucSpines;
        a.NumCausClustSucSpines = NumCausClustSucSpines;
        a.NumCausClustRewSpines = NumCausClustRewSpines;

        a.NumberofClusters = NumberofClusters;
        a.NumberofCausalClusters = NumberofCausalClusters;
        a.NumberofSpinesinEachCluster = NumberofSpinesinEachCluster;
        a.NumberofSpinesinEachCausalCluster = NumberofSpinesinEachCausalCluster;
        a.NumberofMovClusters = NumberofMovClusters;
        a.NumberofSpinesinEachMovCluster= NumberofSpinesinEachMovCluster;
        
        a.CueClusterLength = CueClusterLength;
        a.CueClusterMax = CueClusterMax;
        a.MovClusterLength = MovClusterLength;
        a.MovClusterMax = MovClusterMax;
        a.MixClusterLength = MixClusterLength;
        a.MixClusterMax = MixClusterMax;
        a.SucClusterLength = SucClusterLength;
        a.SucClusterMax = SucClusterMax;
        a.RewClusterLength = RewClusterLength;
        a.RewClusterMax = RewClusterMax;
        a.AllClusterLength = AllClusterLength;
        a.AllClusterLength = AllClusterMax;
        a.CausalCueClusterLength = CausalCueClusterLength;
        a.CausalCueClusterMax = CausalCueClusterMax;
        a.CausalMovClusterLength = CausalMovClusterLength;
        a.CausalMovClusterMax = CausalMovClusterMax;
        a.CausalSucClusterLength = CausalSucClusterLength;
        a.CausalSucClusterMax = CausalSucClusterMax;
        a.CausalRewClusterLength = CausalRewClusterLength;
        a.CausalRewClusterMax = CausalRewClusterMax;
        a.AllCausalClusterLength = AllCausalClusterLength;
        a.AllCausalClusterMax = AllCausalClusterMax;
        a.FarCueClusterLength = FarCueClusterLength;
        a.FarMovClusterLength = FarMovClusterLength;
        a.FarMixClusterLength = FarMixClusterLength;
        a.FarPreSucClusterLength = FarPreSucClusterLength;
        a.FarSucClusterLength = FarSucClusterLength;
        a.FarMovDuringCueClusterLength = FarMovDuringCueClusterLength;
        a.FarRewClusterLength = FarRewClusterLength;
        
        a.DistancesBetweenAllSpines = AllDistancesBetweenAllSpines;
        a.CorrelationBetweenAllSpines = CorrelationBetweenAllSpines;
        a.MeanCorrelationBetweenAllSpines = MeanCorrelationBetweenAllSpines;
        a.MeanCorrelationBetweenAllCloseSpines = MeanCorrelationBetweenAllCloseSpines;
        a.MeanCorrelationBetweenAllDistantSpines = MeanCorrelationBetweenAllDistantSpines;
        a.AdjacencyValuesforAllSpines = AdjacencyValuesforAllSpines;
        a.SharedPairwiseCorrelationValuesforAllSpines = SharedPairwiseCorrelationValuesforAllSpines;
        a.SharedPairwiseReliabilityValuesforAllSpines = SharedPairwiseReliabilityValuesforAllSpines;
        a.DistanceBetweenCueSpines = DistanceBetweenCueSpines;
        a.DistanceBetweenMovementSpines = DistanceBetweenMovementSpines;
        a.AllDistancesBetweenMovementSpines = AllDistancesBetweenMovementSpines;
        a.AllDistancesBetweenPreSuccessSpines = AllDistancesBetweenPreSuccessSpines;
        a.AllDistancesBetweenSuccessSpines = AllDistancesBetweenSuccessSpines;
        a.CorrelationBetweenMovementSpines = CorrelationBetweenMovementSpines;
        a.MeanCorrelationBetweenMovementSpines = MeanCorrelationBetweenMovementSpines;
        a.MeanCorrelationBetweenCloseMovementSpines = MeanCorrelationBetweenCloseMovementSpines;
        a.MeanCorrelationBetweenDistantMovementSpines = MeanCorrelationBetweenDistantMovementSpines;
        a.AllDistancesBetweenAlloDendriticMovementSpines = AllDistancesBetweenAlloDendriticMovementSpines;
        a.CorrelationBetweenFarMovementSpines = CorrelationBetweenAllodendriticMovementSpines;
        a.MeanCorrelationBetweenAlloDendriticSpines = MeanCorrelationBetweenAlloDendriticSpines;
        a.AllDistancesBetweenSameCellDiffBranchSpines = AllDistancesBetweenSameCellDiffBranchSpines;
        a.CorrelationBetweenSameCellDiffBranchSpines = CorrelationBetweenSameCellDiffBranchSpines;
        a.MeanCorrelationBetweenSameCellDiffBranchSpines = MeanCorrelationBetweenSameCellDiffBranchSpines;
        a.AllDistancesBetweenSameCellDiffBranchMovementSpines = AllDistancesBetweenSameCellDiffBranchMovementSpines;
        a.CorrelationBetweenSameCellDiffBranchMovementSpines = CorrelationBetweenSameCellDiffBranchMovementSpines;
        a.MeanCorrelationBetweenSameCellDiffBranchMovementSpines = MeanCorrelationBetweenSameCellDiffBranchMovementSpines;
        a.AllDistancesBetweenSameCellDiffBranchSuccessSpines = AllDistancesBetweenSameCellDiffBranchSuccessSpines;
        a.CorrelationBetweenSameCellDiffBranchSuccessSpines = CorrelationBetweenSameCellDiffBranchSuccessSpines;
        a.MeanCorrelationbetweenSameCellDiffBranchSuccessSpines = MeanCorrelationBetweenSameCellDiffBranchSuccessSpines;


        a.MeanCorrelationBetweenAlloDendriticMovementSpines = MeanCorrelationBetweenAlloDendriticMovementSpines;
        a.DistanceBetweenSuccessSpines = DistanceBetweenSuccessSpines;
        a.CorrelationBetweenSuccessSpines = CorrelationBetweenSuccessSpines;
        a.MeanCorrelationBetweenSuccessSpines = MeanCorrelationBetweenSuccessSpines;
        a.MeanCorrelationBetweenCloseSuccessSpines = MeanCorrelationBetweenCloseSuccessSpines;
        a.MeanCorrelationBetweenDistantSuccessSpines = MeanCorrelationBetweenDistantSuccessSpines;
        a.DistanceBetweenRewardSpines = DistanceBetweenRewardSpines;
        
        a.ClusteredSpines_CorrwithDend = ClusteredSpines_CorrwithDend;
        a.FilteredClusteredSpines_CorrwithDend = FilteredClusteredSpines_CorrwithDend;
        a.NonClusteredSpines_CorrwithDend = NonClusteredSpines_CorrwithDend;
        a.CausalClusteredSpines_CorrwithDend = CausalClusteredSpines_CorrwithDend;
        a.FilteredCausalClusteredSpines_CorrwithDend = FilteredCausalClusteredSpines_CorrwithDend;
        a.NonCausalClusteredSpines_CorrwithDend = NonCausalClusteredSpines_CorrwithDend;
        a.CueRelClusteredSpines_CorrwithDend = CueRelClusteredSpines_CorrwithDend;
        a.MovRelClusteredSpines_CorrwithDend = MovRelClusteredSpines_CorrwithDend;
        a.SucRelClusteredSpines_CorrwithDend = SucRelClusteredSpines_CorrwithDend;
        a.RewRelClusteredSpines_CorrwithDend = RewRelClusteredSpines_CorrwithDend;
        a.CueRelCausalClusteredSpines_CorrwithDend = CueRelCausalClusteredSpines_CorrwithDend;
        a.MovRelCausalClusteredSpines_CorrwithDend = MovRelCausalClusteredSpines_CorrwithDend;
        a.SucRelCausalClusteredSpines_CorrwithDend = SucRelCausalClusteredSpines_CorrwithDend;
        a.RewRelCausalClusteredSpines_CorrwithDend = RewRelCausalClusteredSpines_CorrwithDend; 

%         a.FractionofClusterThatsMovementRelated = FractionofClusterThatsMovementRelated;
%         a.FractionofCausalClusterThatsMovementRelated = FractionofCausalClusterThatsMovementRelated;
        
        a.PercentofCueRelatedDendrites = PercentofCueRelatedDendrites;
        a.PercentofMovementRelatedDendrites = PercentofMovementRelatedDendrites;
        a.PercentofPreSuccessRelatedDendrites = PercentofPreSuccessRelatedDendrites;
        a.PercentofSuccessRelatedDendrites = PercentofSuccessRelatedDendrites;
        a.PercentofMovementDuringCueRelatedDendrites = PercentofMovementDuringCueRelatedDendrites;
        a.PercentofRewardRelatedDendrites = PercentofRewardRelatedDendrites;
        
        a.MovementClusters = MovementClusters; 
        
    eval('ClusteringAllData = a;')
    save('ClusteringAllData', 'ClusteringAllData');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Plots %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
    red = [0.85 0.11 0.14];     black = [0.1 0.1 0.15];
    dred = [0.6 0 0];           dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 1: Spine-Movement correlation using different separation
    %%%           criteria
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    scrsz = get(0, 'ScreenSize');
    figure('Position', scrsz); 
    
    stattype = 'parametric';
    
    subplot(2,5,1)
        flex_plot(1:14, AllClustersCorrwithCue, stattype, black, 2); 
        flex_plot(1:14, NonClusteredCorrwithCue, stattype, dred, 2);
        flex_plot(1:14, CueRelatedClustersCorrwithCue, stattype, blue, 2);
        flex_plot(1:14, CueRelatedNonClusteredCorrwithCue, stattype, gray, 2);
        title('Synaptic Events with Cue', 'Fontsize', 14)
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,2)
        flex_plot(1:14, AllClustersCorrwithMDC, stattype, black, 2); 
        flex_plot(1:14, NonClusteredCorrwithMDC, stattype, dred, 2);
        flex_plot(1:14, MDCRelatedClustersCorrwithMDC, stattype, blue, 2);
        flex_plot(1:14, MDCRelatedNonClusteredCorrwithMDC, stattype, gray, 2);
        title('Synaptic Events with Cue', 'Fontsize', 14)
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,3)
        flex_plot(1:14, AllSpinesCorrwithMovement, stattype, lblue,2);
        flex_plot(1:14, MovementSpinesCorrwithMovement, stattype, purple,2);
        flex_plot(1:14, AllClustersCorrwithMovement, stattype, black, 2);
        flex_plot(1:14, NonClusteredCorrwithMovement, stattype, dred, 2);
        flex_plot(1:14, MovementRelatedClustersCorrwithMovement, stattype, blue, 2);
        flex_plot(1:14, MovementRelatedNonClusteredCorrwithMovement,stattype, gray, 2);
        title('Synaptic Events with Movement', 'Fontsize', 14)
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,4)
        flex_plot(1:14, AllClustersCorrwithSuccess, stattype, black,  2); hold on;
        flex_plot(1:14, NonClusteredCorrwithSuccess, stattype, dred',  2);
        flex_plot(1:14, SuccessRelatedClustersCorrwithSuccess, stattype, blue, 2);
        flex_plot(1:14, SuccessRelatedNonClusteredCorrwithSuccess, stattype, gray, 2);
        title([{'Synaptic Events with'}, {'Successful Movements'}], 'Fontsize', 14)
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,5)
        a = flex_plot(1:14, AllClustCorrwithReward, stattype, black, 2); hold on;
        b = flex_plot(1:14, NonClusteredCorrwithReward, stattype, dred', 2);
        c = flex_plot(1:14, RewardRelatedClustersCorrwithReward, stattype, blue, 2);
        d = flex_plot(1:14, RewardRelatedNonClusteredCorrwithReward, stattype, gray, 2);
        title('Synaptic Events with Reward', 'Fontsize', 14)
        xlim([0 15])
        legend([a,b,c,d],{'Clustered Spines', 'Nonclustered spines', '(Function)-related clustered spines', '(Function)-related nonclustered spines'});
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,6)
        flex_plot(1:14, AllCausalClustersCorrwithCue, stattype, black, 2); hold on;
        flex_plot(1:14, CausalNonClusteredCorrwithCue, stattype, dred, 2);
        flex_plot(1:14, CausalCueRelatedClustersCorrwithCue, stattype, blue, 2);
        flex_plot(1:14, CausalCueRelatedNonClusteredCorrwithCue, stattype, gray, 2);
        xlim([0 15])
        title('Causal Events with Cue', 'Fontsize', 14);
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15);
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,7)
        flex_plot(1:14, AllCausalClustersCorrwithMDC, stattype, black, 2); hold on;
        flex_plot(1:14, CausalNonClusteredCorrwithMDC, stattype, dred, 2);
        flex_plot(1:14, CausalMDCRelatedClustersCorrwithMDC, stattype, blue, 2);
        flex_plot(1:14, CausalMDCRelatedNonClusteredCorrwithMDC, stattype, gray, 2);
        title('Synaptic Events with MDC', 'Fontsize', 14)
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,8)
        flex_plot(1:14, AllCausalClustersCorrwithMovement, stattype, black, 2); hold on;
        flex_plot(1:14, CausalNonClusteredCorrwithMovement, stattype, dred, 2);
        flex_plot(1:14, CausalMovementRelatedClustersCorrwithMovement, stattype, blue, 2);
        flex_plot(1:14, CausalMovementRelatedNonClusteredCorrwithMovement, stattype, gray, 2);
        xlim([0 15])
        title('Causal Events with Movement', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,9)
        flex_plot(1:14, AllCausalClustersCorrwithSuccess, stattype, black, 2); hold on;
        flex_plot(1:14, CausalNonClusteredCorrwithSuccess, stattype, dred, 2);
        flex_plot(1:14, CausalSuccessRelatedClustersCorrwithSuccess, stattype, blue, 2);
        flex_plot(1:14, CausalSuccessRelatedNonClusteredCorrwithSuccess, stattype, gray, 2);
        xlim([0 15])
        title([{'Causal Events with'}, {'Successful Movements'}], 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
    subplot(2,5,10)
        flex_plot(1:14, AllCausalClustCorrwithReward, stattype, black, 2); hold on;
        flex_plot(1:14, CausalNonClusteredCorrwithReward, stattype, dred, 2);
        flex_plot(1:14, CausalRewardRelatedClustersCorrwithReward, stattype, blue, 2);
        flex_plot(1:14, CausalRewardRelatedNonClusteredCorrwithReward, stattype, gray, 2)
        xlim([0 15])
        title('Causal Events with Reward', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
        ylabel('Correlation', 'Fontsize', 14)
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 2: Clustered vs. nonclustered frequency, amp, etc. and
    %%%           dendrite information
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    figure('Position', scrsz);
    subplot(2,3,1);
    considersessions = ones(1,14);
        considersessions([4,9,14]) = 0;
        considersessions = logical(considersessions);
        sessions = 1:14; sessions = sessions(:,considersessions);
        
        a = flex_plot(sessions, AllSpineFreq(:,considersessions), stattype, black, 2); hold on;
        b = flex_plot(sessions, MovementSpineFreq(:,considersessions), stattype, lgreen, 2);
        c = flex_plot(sessions, ClusterFreq(:,considersessions), stattype, lpurple, 2); 
        d = flex_plot(sessions, CausalClusterFreq(:,considersessions), stattype, orange, 2); hold on;
        e = flex_plot(sessions, NonClusteredFreq(:,considersessions), stattype, dred, 2);
        f = flex_plot(sessions, NonClusteredCausalFreq(:,considersessions), stattype, gray, 2);
        ylabel('Event Frequency', 'FontSize', 14)
        xlabel('Session', 'FontSize', 14)
        xlim([0 15])
    legend([a,b,c,d,e,f], {'All', 'Movement','Clustered', 'Causal', 'Nonclustered', 'NonClust Caus'});
    subplot(2,3,2)
        a = flex_plot(sessions, ClusteredSpineAmp(:,considersessions), stattype, black, 2); hold on;
        b = flex_plot(sessions, CausalClusteredSpineAmp(:,considersessions), stattype, bgreen, 2);
        c = flex_plot(sessions, NonClusteredSpineAmp(:,considersessions), stattype, dred, 2);
        d = flex_plot(sessions, CausalNonClusteredSpineAmp(:,considersessions), stattype, gray, 2);
        legend([a,b,c,d],{'Clustered', 'Causal clustered', 'Nonclustered', 'Causal nonclustered'})
        ylabel('Event Amp', 'FontSize', 14);
        xlabel('Session', 'FontSize', 14);
        xlim([0 15])
    subplot(2,3,3)
        a = flex_plot(sessions, AllDendFreq(:,considersessions), stattype, gray, 2);
        b = flex_plot(sessions, MoveDendFreq(:,considersessions), stattype, black, 2);
        c = flex_plot(sessions, NonMoveDendFreq(:,considersessions), stattype, red, 2);
        d = flex_plot(sessions, ClustDendFreq(:,considersessions), stattype, bgreen, 2); hold on;
        e = flex_plot(sessions, NonClustDendFreq(:,considersessions), stattype, lpurple, 2); 
        ylabel('Event Frequency', 'Fontsize', 14);
        xlabel('Session', 'Fontsize', 14)
        xlim([0 15])
        legend([a,b,c,d,e], {'All Dends', 'Move Dends','NonMov Dends', 'Dends with Clusts', 'Dends w/o Clusts'})
    subplot(2,3,4); 
        flex_plot(1:14, CueClusterFrequency, stattype, lgreen, 2); hold on;
        flex_plot(1:14, MovementClusterFrequency, stattype, black, 2);
        flex_plot(1:14, MovementDuringCueClusterFrequency, stattype, green, 2);
        flex_plot(1:14, PreSuccessClusterFrequency, stattype, bgreen, 2);
        flex_plot(1:14, SuccessClusterFrequency, stattype, lblue, 2);
        flex_plot(1:14, RewardClusterFrequency, stattype, purple, 2);
        title([{'Frequency of Functionally relevant'}, {'clustered spines'}])
        ylabel('Event Frequency', 'Fontsize', 14);
        xlabel('Session', 'Fontsize', 14);
        xlim([0 15])
    subplot(2,3,5);
        flex_plot(1:14, ClusteredCueSpineAmp, stattype, lgreen, 2); hold on;
        flex_plot(1:14, ClusteredMoveSpineAmp, stattype, black, 2);
        flex_plot(1:14, ClusteredMovDuringCueSpineAmp, stattype, green, 2);
        flex_plot(1:14, ClusteredPreSuccessSpineAmp, stattype, bgreen, 2);
        flex_plot(1:14, ClusteredSuccessSpineAmp, stattype, lblue, 2);
        flex_plot(1:14, ClusteredRewardSpineAmp, stattype, purple, 2);
        title([{'Amp. of Functionally relevant'}, {'clustered spines'}])
        ylabel('Event Amp', 'FontSize', 14);
        xlabel('Session', 'FontSize', 14);
        xlim([0 15])
    subplot(2,3,6)
        a = flex_plot(1:14, CueClustDendFreq, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, MovClustDendFreq, stattype, black, 3);
        c = flex_plot(1:14, MovDuringCueClustDendFreq, stattype, green, 2);
        d = flex_plot(1:14, PreSucClustDendFreq, stattype, bgreen, 2);
        f = flex_plot(1:14, SucClustDendFreq, stattype, lblue, 2);
        g = flex_plot(1:14, RewClustDendFreq, stattype, purple, 2);
        h = flex_plot(1:14, NonMovClustDendFreq, stattype, dred, 2);
        uistack(b, 'top');
        title([{'Frequency of dendrites with functionally'}, {'relevant clustered spines'}])
        ylabel('Event Frequency', 'Fontsize', 14);
        xlabel('Session', 'Fontsize', 14)
        xlim([0 15])
        legend([a b c d f g h],{'Dends with CueClusts','Dends with MovClusts', 'Dends with MDC Clusts', 'Dends w/ presuc clusts', 'Dends with SucClusts', 'Dends with RewClusts', 'Dends w/o MovClusts'});

  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 3: Num of task-related spines over time, in different
    %%%           categories
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure('Position', scrsz); 
    sub1 = 3;
    sub2 = 3;
    subplot(sub1,sub2,1)
        a = flex_plot(sessions, NumCueRelSpines(:,considersessions),stattype, lgreen, 2); hold on;
        b = flex_plot(sessions, NumMovRelSpines(:,considersessions),stattype, black, 3);
        c = flex_plot(sessions, FractionofMovementRelatedSpinesPerDendrite(:,considersessions),stattype, gray, 3);
        d = flex_plot(sessions, NumCueORMovRelSpines(:,considersessions), stattype, red, 2);
        e = flex_plot(sessions, NumPreSucRelSpines(:,considersessions), stattype, bgreen, 2);
        f = flex_plot(sessions, NumSucRelSpines(:,considersessions),stattype, lblue, 2);
        g = flex_plot(sessions, FractionofSuccessRelatedSpinesPerDendrite(:,considersessions), stattype, blue,3);
        h = flex_plot(sessions, NumMovDuringCueRelSpines(:,considersessions), stattype, green, 2);
        i = flex_plot(sessions, NumRewRelSpines(:,considersessions),stattype, purple, 2);
        legend([a b c d e f g h i], {'All Cue Spines', 'All Mvmt Spines', 'Mov Spines/Dend', 'Cue OR Mov Spines', 'Pre Success Spines', 'All Success Spines', 'Suc Spines/Dend' 'Mov. during Cue Spines', 'All Reward Spines'});
        uistack(b, 'top');
        xlim([0 15]);
        xlabel('Session', 'FontSize', 14);
        ylabel('Fraction of total spines', 'FontSize', 14);
        title('Classes of Spines', 'Fontsize', 14);
                pos = get(gca,'Position');
        axes('Position', [pos(1)+0.2*pos(3), pos(2)+0.6*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        flex_plot(sessions, MovementRelatedSpinesPer10Microns(:,considersessions), stattype, gray, 3); hold on;
        flex_plot(sessions, SuccessRelatedSpinesPer10Microns(:,considersessions), stattype, lblue, 3); 
        xlabel('Session', 'Fontsize', 10)
        ylabel('Spines/5\mum')
        title('Move Spines /5\mum', 'Fontsize', 8)

    
    subplot(sub1,sub2,2)
        a = flex_plot(sessions, NumHSCs(:,considersessions), stattype, lgreen, 2); hold on;
        b = flex_plot(sessions, NumClustSpines(:,considersessions), stattype, black, 2);
        c = flex_plot(sessions, NumFarClustSpines(:,considersessions), stattype, gray, 2);
        legend([a b c],{'Condend. HCSs', 'Clusters', 'Allodend. HCS'});
        xlabel('Session','FontSize', 14)
        xlim([0 15])
        ylabel('Fraction of total spines','FontSize', 14)
    
    subplot(sub1,sub2,3)
        a = flex_plot(sessions, NumberofClusters(:,considersessions), stattype, black, 2); hold on;
        b = flex_plot(sessions, NumberofCausalClusters(:,considersessions), stattype, bgreen, 2);
        c = flex_plot(sessions, NumberofSpinesinEachCluster(:,considersessions), stattype, gray, 2);
        d = flex_plot(sessions, NumberofSpinesinEachCausalCluster(:,considersessions), stattype, dorange, 2);
        legend([a b c d], {'Number of Clusters', 'Number of Causal Clusters', 'Spines in each cluster', 'Spines in each causal cluster'});
        xlabel('Session', 'FontSize', 14)
        xlim([0 15])
        ylabel('Raw Number', 'FontSize', 14)
        
    subplot(sub1,sub2,4)
        a = flex_plot(sessions, PercentofCueRelatedDendrites(:,considersessions), stattype, lgreen, 2); hold on;
        b = flex_plot(sessions, PercentofMovementRelatedDendrites(:,considersessions), stattype, black, 2); 
        c = flex_plot(sessions, PercentofPreSuccessRelatedDendrites(:,considersessions), stattype, bgreen, 2);
        d = flex_plot(sessions, PercentofSuccessRelatedDendrites(:,considersessions), stattype, lblue, 2); 
        f = flex_plot(sessions, PercentofMovementDuringCueRelatedDendrites(:,considersessions), stattype, green, 2);
        g = flex_plot(sessions, PercentofRewardRelatedDendrites(:,considersessions), stattype, purple, 2);
        xlim([0 15])
        legend([a b c d f g],{'Cue Dends', 'Mov Dends', 'PreSuc Dends','Suc Dends', 'Mov During Cue Dends', 'Rew Dends'})
        xlabel('Session', 'FontSize', 14)
        ylabel('Fraction of dendrites', 'FontSize', 14)
        
    subplot(sub1,sub2,5)
        a = flex_plot(sessions, NumClustCueSpines(:,considersessions), stattype, lgreen, 2); hold on;
%             flex_plot(sessions, NumCausClustCueSpines, '--', stattype, lgreen, 2);
        b = flex_plot(sessions, NumClustMovSpines(:,considersessions), stattype, black, 3);
%             flex_plot(sessions, NumCausClustMovSpines, '--', stattype, black, 2);
        c = flex_plot(sessions, NumClustMixSpines(:,considersessions), stattype, red, 2);
        d = flex_plot(sessions, NumClustPreSucSpines(:,considersessions), stattype, bgreen, 2);
%             flex_plot(sessions, NumCausClustPreSucSpines, '--', stattype, bgreen, 2);
        f = flex_plot(sessions, NumClustSucSpines(:,considersessions), stattype, lblue, 2);
%             flex_plot(sessions, NumCausClustSucSpines, '--', stattype, lblue, 2);
        g = flex_plot(sessions, NumClustMovDuringCueSpines(:,considersessions), stattype, green, 2);
%             flex_plot(sessions, NumCausClustMovDuringCueSpines, '--', stattype, green, 2);
        h = flex_plot(sessions, NumClustRewSpines(:,considersessions), stattype, purple, 2);
%             flex_plot(sessions, NumCausClustRewSpines, '--', stattype, purple, 2);
        xlim([0 15]);
        legend([a b c d f g h],{'Clust. Cue Spines','Clust. Mov. Spines', 'Clust. Mixed Spines', 'Clust Pre suc.', 'Clust. Suc. Spines', 'Clust Mov during Cue', 'Clust Rew. Spines'});
        uistack(b, 'top');
        xlabel('Session', 'FontSize', 14);
        ylabel('Fraction of total spines', 'FontSize', 14);
        title('Clustered function-related spines');
        
        
    subplot(sub1,sub2,6)
        for i = 1:14
            MovClustCount{i} = cell2mat(cellfun(@(x) x(:), NumberofSpinesinEachMovCluster(:,i), 'Uni', false));
            MovClustCount{i} = MovClustCount{i}(~isnan(MovClustCount{i}));
        end
        a = flex_plot(1:14, NumberofMovClusters, stattype, black, 2); hold on;
        b = flex_plot(1:14, MovClustCount, stattype, blue, 2);
        legend([a b],{'Number of Mov Clusters', 'Spines in each mov cluster'});
        xlabel('Session', 'FontSize', 14)
        xlim([0 15])
        ylabel('Raw Number', 'FontSize', 14)
        
    subplot(sub1,sub2,7)
        a = flex_plot(sessions, NumFarClustCueSpines(:,considersessions), stattype, lgreen, 2); hold on;
        b = flex_plot(sessions, NumFarClustMovSpines(:,considersessions), stattype, black, 2);
        c = flex_plot(sessions, NumFarClustPreSucSpines(:,considersessions), stattype, bgreen, 2);
        d = flex_plot(sessions, NumFarClustSucSpines(:,considersessions), stattype, lblue, 2);
        f = flex_plot(sessions, NumFarClustMovDuringCueSpines(:,considersessions), stattype, green, 2);
        g = flex_plot(sessions, NumFarClustRewSpines(:,considersessions), stattype, purple, 2);
        xlim([0 15])
        legend([a b c d f g],{'Clust. Cue Spines' 'Clust. Mov. Spines','Clust Pre suc.','Clust. Suc. Spines','Clust Mov during Cue', 'Clust Rew. Spines'});
        xlabel('Session', 'FontSize', 14)
        ylabel('Fraction of total spines', 'FontSize', 14)
        title('Correlated spines on sep. dendrites')

    subplot(sub1,sub2,8)
        a = flex_plot(sessions, FractionofCueSpinesThatAreClustered(:,considersessions), stattype, lgreen, 2); hold on;
        b = flex_plot(sessions, FractionofMovementSpinesThatAreClustered(:,considersessions), stattype, black, 2);
        c = flex_plot(sessions, FractionofPreSuccessSpinesThatAreClustered(:,considersessions), stattype, bgreen, 2);
        d = flex_plot(sessions, FractionofSuccessSpinesThatAreClustered(:,considersessions), stattype, lblue, 2);
        f = flex_plot(sessions, FractionofMovementDuringCueSpinesThatAreClustered(:,considersessions), stattype, green, 2);
        g = flex_plot(sessions, FractionofRewardSpinesThatAreClustered(:,considersessions), stattype, purple, 2);
        xlim([0 15])
        xlabel('Session', 'Fontsize', 14)
        ylabel('Fraction of Function-related Spines', 'Fontsize', 14)
        title([{'Fraction of (function) spines'},{'that are clustered'}], 'Fontsize', 14)
        legend([a b c d f g],{'Cue related','Movement related', 'Pre Success', 'Success related', 'MovDuringCue', 'Reward related'})
        
    subplot(sub1,sub2,9)
%         allspinesessions = find(any(~isnan(AllSpineReliability),1));
%         movementspinesessions = find(any(~isnan(MovementSpineReliability),1));
%         allspinenormmat = AllSpineReliability;
%         for i = 1:length(allspinesessions)
%             allspinenormmat(:,allspinesessions(i)) = AllSpineReliability(:,i)./nanmean(nanmean(AllSpineReliability(:,1:4)));
%         end
%         movespinenormmat = MovementSpineReliability;
%         for i = 1:length(movementspinesessions)
%             movespinenormmat(:,movementspinesessions(i)) = MovementSpineReliability(:,i)./nanmean(nanmean(MovementSpineReliability(:,1:4)));
%         end
        
        
        a = flex_plot(sessions, MeanMovementSpineReliability(:,considersessions), stattype, green, 2);
        b = flex_plot(sessions, MeanAllSpineReliability(:,considersessions), stattype, black, 2);
        c = flex_plot(sessions, AllSpinesCorrwithMovement(:,considersessions), stattype, blue,2);
        d = flex_plot(sessions, MovementSpinesCorrwithMovement(:,considersessions), stattype, purple, 2);
        
        xlabel('Session', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        legend([a,b,c,d], {'Move Spines Rel.', 'All Spines Rel.', 'All Spines Corr.', 'Move Spines Corr'})
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Figure 4: Spatial extent of clusters
    %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure('Position', scrsz);
    subplot(2,3,1)
        a = flex_plot(1:14, AllClusterLength, stattype, black, 2); hold on;
        b = flex_plot(1:14, AllCausalClusterLength, stattype, bgreen, 2);
        legend([a b],{'Clustered spines', 'Caus. clust.'})
        xlabel('Session', 'FontSize', 14)
        xlim([0 15])
        ylabel('Ave. Dist. between spines', 'FontSize', 14)
        title('Mean Spatial Extent of Clusters', 'Fontsize', 14)
    subplot(2,3,2)
        a = flex_plot(1:14, AllClusterMax, stattype, black, 2); hold on;
        b = flex_plot(1:14, AllCausalClusterMax, stattype, bgreen, 2);
        legend([a b],{'Clustered spines', 'Caus. clust.'})
        xlabel('Session', 'FontSize', 14)
        xlim([0 15])
        ylabel('Max Dist. between spines', 'FontSize', 14)
        title('MAX Spatial Extent of Clusters', 'Fontsize', 14)
    subplot(2,3,3)
        a = flex_plot(1:14, DistanceBetweenCueSpines, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, DistanceBetweenMovementSpines, stattype, black, 3);
        c = flex_plot(1:14, DistanceBetweenSuccessSpines, stattype, lblue, 2);
        d = flex_plot(1:14, DistanceBetweenRewardSpines, stattype, purple, 2);
        uistack(b, 'top');
        xlabel('Session', 'FontSize', 14)
        ylabel('Distance (um)', 'FontSize', 14)
        ylim([0 30])
        xlim([0 15])
        legend([a b c d],{'Cue Spines', 'Movement Spines', 'Success Spines', 'Reward Spines'})

    subplot(2,3,4)
        a = flex_plot(1:14, CueClusterLength, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, MovClusterLength, stattype, black, 3);
        c = flex_plot(1:14, MixClusterLength, stattype, red, 2);
        d = flex_plot(1:14, PreSucClusterLength, stattype, bgreen, 2);
        f = flex_plot(1:14, SucClusterLength, stattype, lblue, 2);
        g = flex_plot(1:14, MovDuringCueClusterLength, stattype, green, 2);
        h = flex_plot(1:14, RewClusterLength, stattype, purple, 2);
        legend([a b c d f g h],{'Cue Clusters', 'Mov clusters', 'Mix Clusters', 'PreSuc', 'Suc Clusters', 'MovDuringCue', 'Rew Clusters'});
        uistack(b, 'top');
        xlabel('Session', 'FontSize', 14)
        ylabel('Mean spatial extent of clusters', 'FontSize', 14)
        ylim([0 30])
        xlim([0 15])
    subplot(2,3,5)
        a = flex_plot(1:14, CueClusterMax, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, MovClusterMax, stattype, black, 2);
        c = flex_plot(1:14, MixClusterMax, stattype, red, 2);
        d = flex_plot(1:14, SucClusterMax, stattype, lblue, 2);
        f = flex_plot(1:14, RewClusterMax, stattype, purple, 2);
        legend([a b c d f],{'Cue Clusters', 'Mov clusters', 'Mix Clusters', 'Suc Clusters', 'Rew Clusters'});
        xlabel('Session', 'FontSize', 14)
        ylabel('Max spatial extent of clusters', 'FontSize', 14)
        ylim([0 30])
        xlim([0 15])
        
    subplot(2,3,6)
        a = flex_plot(1:14, FarCueClusterLength, stattype, lgreen, 2); hold on; 
        b = flex_plot(1:14, FarMovClusterLength, stattype, black, 2);
        c = flex_plot(1:14, FarMixClusterLength, stattype, red, 2);
        d = flex_plot(1:14, FarSucClusterLength, stattype, lblue, 2);
        f = flex_plot(1:14, FarRewClusterLength, stattype, purple, 2);
        g = flex_plot(1:14, AllFarClusterLength, stattype, gray, 2);
        legend([a b c d f g],{'Far Cue', 'Far Mov', 'Far Mix', 'Far Suc', 'Far Rew', 'Far All'})
        
    %%%
    %%% Figure 5: Correlation with Dendrite
    %%%
    
    figure('Position', scrsz);
    
    subplot(3,2,1)
        a = flex_plot(1:14, ClusteredSpines_CorrwithDend, stattype,black, 2); hold on;
        b = flex_plot(1:14, FilteredClusteredSpines_CorrwithDend,stattype, orange, 2);
        c = flex_plot(1:14, NonClusteredSpines_CorrwithDend,stattype,dred, 2);

        legend([a b c],{'Clust','Filt Clust','Non Clust'})
        
        ylabel('Correlation with dendrite', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        title('Clustered Spines', 'Fontsize', 14)
        xlim([0 15])

    subplot(3,2,2)
        a = flex_plot(1:14, CausalClusteredSpines_CorrwithDend, stattype,black, 2); hold on;
        b = flex_plot(1:14, FilteredCausalClusteredSpines_CorrwithDend, stattype, orange, 2);
        c = flex_plot(1:14, NonCausalClusteredSpines_CorrwithDend, stattype,dred, 2);
    
        legend([a b c],{'Caus Clust','Filt Caus Clust', 'Caus Non Clust'});

        ylabel('Correlation with dendrite', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        title('Causal Clustered Spines', 'Fontsize', 14)
        xlim([0 15])
        
    subplot(3,2,3)
        flex_plot(1:14, CorrelationofClusters, stattype, black, 2); hold on;
        
        ylabel('Correlation', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        title('Mean Correlation of Clustered Spines', 'Fontsize', 14)
        xlim([0 15])
        
    subplot(3,2,4)
        a = flex_plot(1:14, MeanCorrelationBetweenMovementSpines, stattype, black, 2);
        b = flex_plot(1:14, MeanCorrelationBetweenSameCellDiffBranchMovementSpines, stattype, gray, 2);
        c = flex_plot(1:14, MeanCorrelationBetweenSuccessSpines, stattype, lblue,2);
        d = flex_plot(1:14, MeanCorrelationBetweenCloseMovementSpines, stattype, lpurple, 2);
        e = flex_plot(1:14, MeanCorrelationBetweenDistantMovementSpines, stattype, blue, 2);
        legend([a b c d e],{'Mov spines condend', 'Mov spines allodend','Condend Success Spines', 'Condend mov spines <15 \mum', 'Condend mov spines >15 \mum'});
        xlim([0 15])
        ylabel('Correlation', 'Fontsize', 14)
        xlabel('Session', 'Fontsize', 14)
        title('Correlation between mov spines', 'Fontsize', 14);

    subplot(3,2,5)
        a = flex_plot(1:14, CueRelClusteredSpines_CorrwithDend, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, MovRelClusteredSpines_CorrwithDend, stattype, black, 2);
        c = flex_plot(1:14, SucRelClusteredSpines_CorrwithDend, stattype, lblue, 2);
        d = flex_plot(1:14, RewRelClusteredSpines_CorrwithDend, stattype, purple, 2);
        
        legend([a b c d],{'Cue rel clusters', 'Mov-rel clusters', 'Suc-rel clusters', 'Rew-rel clusters'});
                
        xlim([0 15])
        ylabel('Correlation with Dendrite')
        xlabel('Session')
        title('Functional Clusters')
       
    subplot(3,2,6)
        a = flex_plot(1:14, CueRelCausalClusteredSpines_CorrwithDend, stattype, lgreen, 2); hold on;
        b = flex_plot(1:14, MovRelCausalClusteredSpines_CorrwithDend, stattype, black, 2);
        c = flex_plot(1:14, SucRelCausalClusteredSpines_CorrwithDend, stattype, lblue, 2);
        d = flex_plot(1:14, RewRelCausalClusteredSpines_CorrwithDend, stattype, purple, 2);
        
        legend([a b c d], {'Cue rel clusters', 'Mov-rel clusters', 'Suc-rel clusters', 'Rew-rel clusters'});
                
        xlim([0 15])
        title('Causal Functional Clusters')
        xlabel('Session')
        ylabel('Correlation with Dendrite')
        
    %%%
    %%% Figure 6: Fraction of clusters that are movement related
    %%%
    
%     figure('Position', scrsz); hold on;
%     flex_plot(MeanFractionofClusterThatsMovementRelated,'Color',black, 'LineWidth', 2)
%     flex_plot(MeanFractionofCausalClusterThatsMovementRelated, 'Color', bgreen, 'Linewidth',2)
%     
%     legend({'Synapse only clusters', 'Causal Clusters'}, 'Location', 'SouthEast')
%     r_errorbar(1:14, FractionofClusterThatsMovementRelated, FractionofClusterThatsMovementRelatedSEM, 'k')
%     r_errorbar(1:14, FractionofCausalClusterThatsMovementRelated, FractionofCausalClusterThatsMovementRelatedSEM, bgreen)
%     
%     xlabel('Session')
%     ylabel('Fraction of Cluster That is Movement Related', 'Fontsize', 14)
%     ylim([0 1.2])
    
    
    %%%
    %%% Figure 7: Spectral graph analysis of clusters
    %%%
                
    figure('Position', scrsz); hold on;
    subplot(2,4,1)
    a = flex_plot(1:14, SpatialDegree, stattype, black, 2); hold on;
    b = flex_plot(1:14, TemporalDegree, stattype,red, 2);
    c = flex_plot(1:14, SpatioTemporalDegree, stattype,green, 2); 

    legend([a b c], {'Spatial Degree', 'Temporal Degree', 'Spatiotemporal Degree'});

    ylabel('Mean Degree', 'Fontsize', 14)
    xlabel('Session', 'Fontsize', 14)
    xlim([0 15])
    set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
    
    subplot(2,4,2)
    flex_plot(1:14, SpatialMovementCorrelation, stattype,black, 2); hold on;
    flex_plot(1:14, TemporalMovementCorrelation, stattype,red, 2);
    flex_plot(1:14, SpatioTemporalMovementCorrelation, stattype,green, 2);
    ylabel([{'Mean Correlation of Spatiotemporal'}, {'Degree with Movement'}],'Fontsize', 14)
    xlabel('Session', 'Fontsize', 14);
    xlim([0 15]);
    set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
    
    subplot(2,4,3)
    xlim([0 15])
    try
        a = flex_plot(1:14, cellfun(@(x) x(:,1), DendClusteringDegree, 'uni', false), stattype,black, 2); hold on;
        b = flex_plot(1:14, cellfun(@(x) x(:,2), DendClusteringDegree, 'uni', false), stattype,red, 2);
        c = flex_plot(1:14, cellfun(@(x) x(:,3), DendClusteringDegree, 'uni', false), stattype,green, 2);
        legend([a b c], {'Spatial Fiedler', 'Temporal Fiedler', 'Spatiotemporal Fiedler'});
    catch
    end
    
    ylabel('Mean Algebraic Connectivity of Dendrites (Clustering)');
    xlabel('Session');
    xlim([0 15]);
    set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15);
    
    subplot(2,4,4)
    flex_plot(1:14, SpatioTemporalOverlap, stattype,black, 2);
    ylabel('Mean Correlation of Spatial and Temporal Eigenvectors');
    xlabel('Session');
    xlim([0 15]);
    set(gca, 'XTick', 0:15); set(gca, 'XTickLabel', 0:15)
    
    subplot(2,4,5)
    a = flex_plot(1:14, SpatialDegreeofCueSpines, stattype, lgreen, 2); hold on;
    b = flex_plot(1:14, SpatialDegreeofMovementSpines, stattype, black, 2);
    c = flex_plot(1:14, SpatialDegreeofMovementDuringCueSpines, stattype, green , 2);
    d = flex_plot(1:14, SpatialDegreeofPreSuccessSpines, stattype, bgreen, 2);
    f = flex_plot(1:14, SpatialDegreeofSuccessSpines, stattype, lblue, 2);
    g = flex_plot(1:14, SpatialDegreeofRewardSpines, stattype, purple, 2);
    
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14)
    ylabel('Mean Degree')
    legend([a b c d f g],{'Cue spines', 'Movement Spines', 'MDC Spines', 'PreMov Spines', 'Success Spines', 'Reward Spines'})
    title([{'Mean Spatial Degree of'},{'feature-related spines'}], 'Fontsize', 14)
        
    subplot(2,4,6)
    a = flex_plot(1:14, TemporalDegreeofCueSpines, stattype, lgreen, 2); hold on;
    b = flex_plot(1:14, TemporalDegreeofMovementSpines, stattype, black, 2);
    c = flex_plot(1:14, TemporalDegreeofMovementDuringCueSpines, stattype, green, 2);
    d = flex_plot(1:14, TemporalDegreeofPreSuccessSpines, stattype, bgreen, 2);
    f = flex_plot(1:14, TemporalDegreeofSuccessSpines, stattype, lblue, 2);
    g = flex_plot(1:14, TemporalDegreeofRewardSpines, stattype, purple, 2);    
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14)
    ylabel('Mean Degree')
    legend([a b c d f g],{'Cue spines', 'Movement Spines', 'MDC Spines', 'PreMov Spines', 'Success Spines', 'Reward Spines'});
    title([{'Mean Temporal Degree of'},{'feature-related spines'}], 'Fontsize', 14)
        
    subplot(2,4,7)
    a = flex_plot(1:14, SpatioTemporalDegreeofCueSpines, stattype, lgreen, 2); hold on;
    b = flex_plot(1:14, SpatioTemporalDegreeofMovementSpines, stattype, black, 2);
    c = flex_plot(1:14, SpatioTemporalDegreeofMovementDuringCueSpines, stattype, green, 2);
    d = flex_plot(1:14, SpatioTemporalDegreeofPreSuccessSpines, stattype, bgreen, 2);
    f = flex_plot(1:14, SpatioTemporalDegreeofSuccessSpines, stattype, lblue, 2);
    g = flex_plot(1:14, SpatioTemporalDegreeofRewardSpines, stattype, purple, 2);
    
    xlim([0 15])
    xlabel('Session', 'Fontsize', 14)
    ylabel('Mean Degree')
    legend([a b c d f g],{'Cue spines', 'Movement Spines', 'MDC Spines', 'PreMov Spines', 'Success Spines', 'Reward Spines'});
    title([{'Mean SpatioTemporal Degree of'},{'feature-related spines'}], 'Fontsize', 14)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%
    %% Figure 8: Correlation vs. Distance Distributions
    %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    earlysessions = 1:3;
    latesessions  = 11:13; 
    
    ConDendDistanceUmbrellaDataChoice = AllDistancesBetweenAllSpines; 
    ConDendCorrelationUmbrellaDataChoice = CorrelationBetweenAllSpines; 
    
    ConDendDistanceStatDataChoice = AllDistancesBetweenMovementSpines;
    ConDendCorrelationStatDataChoice = CorrelationBetweenMovementSpinesMovePeriods;
    
%     AlloDendDistanceUmbrellaDataChoice = AllDistancesBetweenSameCellDiffBranchSpines; 
%     AlloDendCorrelationUmbrellaDataChoice = CorrelationBetweenSameCellDiffBranchSpines; 
    
    AlloDendDistanceUmbrellaDataChoice = AllDistancesBetweenAlloDendriticSpines; 
    AlloDendCorrelationUmbrellaDataChoice = CorrelationBetweenAlloDendriticSpines; 
    
    AlloDendDistanceStatDataChoice = AllDistancesBetweenSameCellDiffBranchMovementSpines; 
    AlloDendCorrelationStatDataChoice = CorrelationBetweenSameCellDiffBranchMovementSpines; 

%     AlloDendDistanceStatDataChoice = AllDistancesBetweenMovementSpines;
%     AlloDendCorrelationStatDataChoice = CorrelationBetweenMovementSpinesStillPeriods;

    for i = 1:length(varargin)
        binstep = 5; maxdist = 100;
        bincount = 1;
        for b = 1:binstep:maxdist
            corrdataatbin = cell2mat(cellfun(@(y,x) nanmedian(y(logical(x>=(b-1) & x<(b+binstep)))),varargin{i}.CorrelationBetweenMovementSpines, varargin{i}.DistanceBetweenMovementSpines, 'uni', false));
            CorrelationBetweenMovementSpinesAtDistanceBin{bincount} = [CorrelationBetweenMovementSpinesAtDistanceBin{bincount}; corrdataatbin];
            bincount = bincount+1;
        end
    end

    figure('Position', scrsz)
    currentplot = 1;
    subplot(2,4,1)
        xdata = cell2mat(ConDendDistanceStatDataChoice(earlysessions))';
        ydata = cell2mat(ConDendCorrelationStatDataChoice(earlysessions))';
        ydata(isnan(ydata)) = 0;
        %%% K-means clustering 
%         X = [(xdata-nanmean(xdata))/nanstd(xdata), (ydata-nanmean(ydata))/nanstd(ydata)];   %%% Standardized data!!!!
%         [idx, C] = kmeans(X,2);
%         x1 = min(X(:,1)):0.01:max(X(:,1));
%         x2 = min(X(:,2)):0.01:max(X(:,2));
%         [x1G,x2G] = meshgrid(x1,x2);
%         XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the flex_plot
%         col1 = orange; col2 = lblue;
%         idx2Region = kmeans(XGrid,2,'MaxIter',1,'Start',C);
%         gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
%         [col1; col2],'..');hold on;
%         % Assigns each node in the grid to the closest centroid
%         %%%
%         plot(xdata(idx==1), ydata(idx==1), '.', 'Color', lgreen); hold on;
%         plot(xdata(idx==2), ydata(idx==2), '.k')

%         plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', lgreen);
         hold on;
%         plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', black);
          for ns = 1:length(varargin)
            distset = cell2mat(varargin{ns}.DistanceBetweenMovementSpines(earlysessions));
            corrset = cell2mat(varargin{ns}.CorrelationBetweenMovementSpines(earlysessions));
            col1 = mod(ns-1, length(rnbo))+1;
            plot(distset, corrset, '.k', 'Color', rnbo{col1})
            plot(5, nanmedian(corrset(distset>=0 & distset<5)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
            plot(10, nanmedian(corrset(distset>=5 & distset<10)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
            plot(15, nanmedian(corrset(distset>=10 & distset<15)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
          end
%         decay = fit(xdata, ydata, 'exp1'); 
%             fline = flex_plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
%     %         flex_plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['Movement Spines, Sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end))],  'FontSize', 14)
        corratbin = cell(1,8);
        highcorratbin = cell(1,8);
        binstep = 5;
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        maxdist = 100;
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', lgreen, 'EdgeColor', 'k'); hold on;
%         bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray); hold on;
        bar(cell2mat(cellfun(@(x) nanmean(nanmean(x(:,earlysessions))), CorrelationBetweenMovementSpinesAtDistanceBin, 'uni', false)), 'FaceColor', 'k', 'EdgeColor', gray); hold on;
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 2;
    subplot(2,4,currentplot)
        xdata = cell2mat(AlloDendDistanceStatDataChoice(earlysessions))';
        ydata = cell2mat(AlloDendCorrelationStatDataChoice(earlysessions))';
        ydata(isnan(ydata)) = 0;
        try
            plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', lgreen); hold on;
        catch
        end
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', gray)
%         decay = fit(xdata, ydata, 'exp1'); 
%             fline = flex_plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
%     %         flex_plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['Movement Spines, Sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end))],  'FontSize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', lgreen, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 3;
    subplot(2,4,currentplot)
        xdata = cell2mat(ConDendDistanceStatDataChoice(latesessions))';
        ydata = cell2mat(ConDendCorrelationStatDataChoice(latesessions))';
        ydata(isnan(ydata)) = 0;
%         X = [(xdata-nanmedian(xdata))/nanstd(xdata), (ydata-nanmean(ydata))/nanstd(ydata)];   %%% Standardized data!!!!
%         [idx, C] = kmeans(X,2);
%         x1 = min(X(:,1)):0.01:max(X(:,1));
%         x2 = min(X(:,2)):0.01:max(X(:,2));
%         [x1G,x2G] = meshgrid(x1,x2);
%         XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the flex_plot
%         col1 = orange; col2 = lblue;
%         idx2Region = kmeans(XGrid,2,'MaxIter',1,'Start',C);
%         gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
%         [col1; col2],'..');hold on;
%         % Assigns each node in the grid to the closest centroid
%         %%%
%         plot(xdata(idx==1), ydata(idx==1), '.', 'Color', lgreen); hold on;
%         plot(xdata(idx==2), ydata(idx==2), '.k')

%         plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', lgreen); 
            hold on;
        plot(xdata, ydata, '.', 'Color', black);

          for ns = 1:length(varargin)
            distset = cell2mat(varargin{ns}.DistanceBetweenMovementSpines(latesessions));
            corrset = cell2mat(varargin{ns}.CorrelationBetweenMovementSpines(latesessions));
            col1 = mod(ns-1, length(rnbo))+1;
            plot(distset, corrset, '.k', 'Color', rnbo{col1})
            plot(5, nanmedian(corrset(distset>=0 & distset<5)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
            plot(10, nanmedian(corrset(distset>=5 & distset<10)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
            plot(15, nanmedian(corrset(distset>=10 & distset<15)), 'ok', 'MarkerEdgeColor', rnbo{col1}, 'MarkerFaceColor', rnbo{col1})
          end
          
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
    %         plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['Movement Spines, Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'FontSize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', lgreen, 'EdgeColor', 'k'); hold on;
%         bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray);  hold on;
        bar(cell2mat(cellfun(@(x) nanmean(nanmean(x(:,latesessions))), CorrelationBetweenMovementSpinesAtDistanceBin, 'uni', false)), 'FaceColor', 'k', 'EdgeColor', gray); hold on;
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 4;
    subplot(2,4,currentplot)
        xdata = cell2mat(AlloDendDistanceStatDataChoice(latesessions))';
        ydata = cell2mat(AlloDendCorrelationStatDataChoice(latesessions))';
        ydata(isnan(ydata)) = 0;
        try
            plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', lgreen); hold on;
        catch
        end
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', gray)
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
%     %         plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['Movement Spines, Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'FontSize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', lgreen, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 5;
    subplot(2,4,currentplot)
        xdata = cell2mat(ConDendDistanceUmbrellaDataChoice(earlysessions))';
        ydata = cell2mat(ConDendCorrelationUmbrellaDataChoice(earlysessions))';
        ydata(isnan(ydata)) = 0;
        use_normalization = 0;
        if use_normalization
            xdata = xdata+1; %%% can't work with zeros using log
            ydata = abs(ydata);
            xdata = log(xdata);
            ydata = log(ydata);
        end
%         X = [(xdata-nanmedian(xdata))/nanstd(xdata), (ydata-nanmean(ydata))/nanstd(ydata)];   %%% Standardized data!!!!
%         [idx, C] = kmeans(X,2);
%         x1 = min(X(:,1)):0.01:max(X(:,1));
%         x2 = min(X(:,2)):0.01:max(X(:,2));
%         [x1G,x2G] = meshgrid(x1,x2);
%         XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot
%         col1 = orange; col2 = lblue;
%         idx2Region = kmeans(XGrid,2,'MaxIter',1,'Start',C);
%         gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
%         [col1; col2],'..');hold on;
%         % Assigns each node in the grid to the closest centroid
%         %%%
%         plot(xdata(idx==1), ydata(idx==1), '.', 'Color', dred); hold on;
%         plot(xdata(idx==2), ydata(idx==2), '.k')
        plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', dred); hold on;
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', black);
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
    %         plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['All Spines, Sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'FontSize', 14)
        
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', dred, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 6;
    subplot(2,4,currentplot)
        xdata = cell2mat(AlloDendDistanceUmbrellaDataChoice(earlysessions)');
        ydata = cell2mat(AlloDendCorrelationUmbrellaDataChoice(earlysessions)');
        ydata(isnan(ydata)) = 0;
        if use_normalization
            xdata = xdata+1; %%% can't work with zeros using log
            ydata = abs(ydata);
            xdata = log(xdata);
            ydata = log(ydata);
        end
        try
            plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', dred); hold on;
        catch
        end
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', gray)
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
    %         plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['All Far Spines, Sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'FontSize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', dred, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        
    currentplot = 7;
    subplot(2,4,currentplot)
        xdata = cell2mat(ConDendDistanceUmbrellaDataChoice(latesessions))';
        ydata = cell2mat(ConDendCorrelationUmbrellaDataChoice(latesessions))';
        ydata(isnan(ydata)) = 0;
        if use_normalization
            xdata = xdata+1; %%% can't work with zeros using log
            ydata = abs(ydata);
            xdata = log(xdata);
            ydata = log(ydata);
        end
%         X = [(xdata-nanmean(xdata))/nanstd(xdata), (ydata-nanmean(ydata))/nanstd(ydata)];   %%% Standardized data!!!!
%         [idx, C] = kmeans(X,2);
%         x1 = min(X(:,1)):0.01:max(X(:,1));
%         x2 = min(X(:,2)):0.01:max(X(:,2));
%         [x1G,x2G] = meshgrid(x1,x2);
%         XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot
%         col1 = orange; col2 = lblue;
%         idx2Region = kmeans(XGrid,2,'MaxIter',1,'Start',C);
%         gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
%         [col1; col2],'..');hold on;
%         % Assigns each node in the grid to the closest centroid
%         %%%
%         plot(xdata(idx==1), ydata(idx==1), '.', 'Color', dred); hold on;
%         plot(xdata(idx==2), ydata(idx==2), '.k')
        plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', dred); hold on;
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', black);
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
%             plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['All Spines, Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
            highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
            bincount = bincount+1;
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', dred, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
    currentplot = 8;
    subplot(2,4,currentplot)
        xdata = cell2mat(AlloDendDistanceUmbrellaDataChoice(latesessions)');
        ydata = cell2mat(AlloDendCorrelationUmbrellaDataChoice(latesessions)');
        ydata(isnan(ydata)) = 0;
        if use_normalization
            xdata = xdata+1; %%% can't work with zeros using log
            ydata = abs(ydata);
            xdata = log(xdata);
            ydata = log(ydata);
        end
        try
            plot(xdata(ydata>=0.5), ydata(ydata>=0.5), '.', 'Color', dred); hold on;
        catch
        end
        plot(xdata(ydata<0.5), ydata(ydata<0.5), '.', 'Color', gray)
%             decay = fit(xdata, ydata, 'exp1'); 
%             fline = plot(decay); 
%             set(fline, 'Color', 'k')
%             legend off
    %         plot(-1/decay.b,0.368*decay.a, 'ok', 'MarkerFaceColor', 'k') %%% 0.368 corresponds to the decay constant, tau
        xlim([0 100])
        ylim([-0.05 1])
        xlabel('Distance (\mum)', 'FontSize', 14)
        ylabel('Correlation', 'FontSize', 14)
        title(['All Spines, Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize', 14)
        bincount = 1;
        ydata2 = ydata(ydata>0.5);
        xdata2 = xdata(ydata>0.5);
        for i = 1:binstep:maxdist
            try
                corratbin{currentplot}(1,bincount) = nanmedian(ydata(find(xdata>=(i-1) & xdata<(i+binstep))));
                highcorratbin{currentplot}(1,bincount) = nanmedian(ydata2(find(xdata2>=(i-1) & xdata2<(i+binstep))));
                bincount = bincount+1;
            catch
            end
        end
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.6*pos(3), pos(2)+0.7*pos(4), 0.35*pos(3), 0.25*pos(4)]);
        bar(highcorratbin{currentplot}, 'FaceColor', dred, 'EdgeColor', 'k'); hold on;
        bar(corratbin{currentplot}, 'FaceColor', 'k', 'EdgeColor', gray)
        xlim([-1 (maxdist/binstep)+1])
        ylim([0 1])
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Figure 9: Adjacency and Movement relatedness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    
    figure('Position', scrsz, 'Name', 'Adjacency and Movement Relatedness'); hold on;

    h1 = subplot(2,4,1); hold on;
    xdata = cell2mat(AdjacencyValuesforAllSpines(earlysessions))';
    ydata = abs(cell2mat(SharedPairwiseCorrelationValuesforAllSpines(earlysessions))');
    xdata = xdata(~isnan(ydata)); ydata = ydata(~isnan(ydata)); %%% Correlation values can be NaN if there is no activity, which will prevent calculation of the fit
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    use_normalization = 0;
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Correlation')
    xlabel('Spatiotemporal Adjacency')
    title('Early')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h2 = subplot(2,4,2); hold on;
    xdata = cell2mat(AdjacencyValuesforAllSpines(latesessions))'; 
    ydata = abs(cell2mat(SharedPairwiseCorrelationValuesforAllSpines(latesessions))');
    xdata = xdata(~isnan(ydata)); ydata = ydata(~isnan(ydata)); %%% Correlation values can be NaN if there is no activity, which will prevent calculation of the fit
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Movement Correlation')
    xlabel('Spatiotemporal Adjacency')
    title('Late')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h3 = subplot(2,4,3); hold on;
    xdata = cell2mat(ConDendCorrelationUmbrellaDataChoice(earlysessions))'; xdata(isnan(xdata)) = 0;
    ydata = abs(cell2mat(SharedPairwiseCorrelationValuesforAllSpines(earlysessions))');
    xdata = xdata(~isnan(ydata)); ydata = ydata(~isnan(ydata)); %%% Correlation values can be NaN if there is no activity, which will prevent calculation of the fit
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata); 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Movement Correlation')
    xlabel('Spine Correlation')
    title('Early')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h4 = subplot(2,4,4); hold on;
    xdata = cell2mat(ConDendCorrelationUmbrellaDataChoice(latesessions))';xdata(isnan(xdata)) = 0;
    ydata = abs(cell2mat(SharedPairwiseCorrelationValuesforAllSpines(latesessions))');
    xdata = xdata(~isnan(ydata)); ydata = ydata(~isnan(ydata)); %%% Correlation values can be NaN if there is no activity, which will prevent calculation of the fit
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Movement Correlation')
    xlabel('Spine Correlation')
    title('Late')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h5 = subplot(2,4,5); hold on;
    xdata = cell2mat(AdjacencyValuesforAllSpines(earlysessions))';
    ydata = abs(cell2mat(SharedPairwiseReliabilityValuesforAllSpines(earlysessions))');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Reliability')
    xlabel('Spatiotemporal Adjacency')
    title('Early')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h6 = subplot(2,4,6); hold on;
    xdata = cell2mat(AdjacencyValuesforAllSpines(latesessions))';
    ydata = abs(cell2mat(SharedPairwiseReliabilityValuesforAllSpines(latesessions))');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)    
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Reliability')
    xlabel('Spatiotemporal Adjacency')
    title('Late')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h7 = subplot(2,4,7); hold on;
    xdata = cell2mat(ConDendCorrelationUmbrellaDataChoice(earlysessions))';xdata(isnan(xdata)) = 0;
    ydata = abs(cell2mat(SharedPairwiseReliabilityValuesforAllSpines(earlysessions))');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)    
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Reliability')
    xlabel('Spine Correlation')
    title('Early')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    h8 = subplot(2,4,8); hold on;
    xdata = cell2mat(ConDendCorrelationUmbrellaDataChoice(latesessions))';xdata(isnan(xdata)) = 0;
    ydata = abs(cell2mat(SharedPairwiseReliabilityValuesforAllSpines(latesessions))');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydata = ydata(xdata>0.2);
    xdata = xdata(xdata>0.2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if use_normalization
%         xdata = xdata(xdata~=0);
%         ydata = ydata(xdata~=0); 
%         xdata = log(xdata);
        xdata = zscore(xdata);
        ydata = zscore(ydata);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    plot(xdata, ydata, '.k', 'Markersize', 14)    
    X = [ones(length(xdata),1), xdata];
    beta = X\ydata;
    ycalc = X*beta;
    plot(xdata,ycalc, 'r')
    ylabel('Shared Reliability')
    xlabel('Spine Correlation')
    title('Late')
    [r,p] = corrcoef(xdata,ydata);
    if p(1,2) < 0.05
        text(max(xdata),ycalc(xdata==max(xdata)), '*', 'Color', 'r', 'Fontsize', 20)
    end
    
    linkaxes([h1,h2], 'xy')
    linkaxes([h3,h4], 'xy')
    linkaxes([h5,h6], 'xy')
    linkaxes([h7,h8], 'xy')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Figure 10: Clustering validation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure('Position', scrsz, 'Name', 'Clustering Validation'); hold on;
    %%% Shuffled data plots: uncomment the following and set stop point
    
    corrtouse{1} = cell2mat(ConDendCorrelationUmbrellaDataChoice(earlysessions));
    disttouse{1} = cell2mat(ConDendDistanceUmbrellaDataChoice(earlysessions));
    %         farcorrtouse = CorrelationBetweenFarSpines{sessiontouse};

    corrtouse{2} = cell2mat(ConDendCorrelationUmbrellaDataChoice(latesessions));
    disttouse{2} = cell2mat(ConDendDistanceUmbrellaDataChoice(latesessions));

    corrtouse{3} = cell2mat(ConDendCorrelationStatDataChoice(earlysessions));
    disttouse{3} = cell2mat(ConDendDistanceStatDataChoice(earlysessions));
    %         farcorrtouse = CorrelationBetweenFarSpines{sessiontouse};

    corrtouse{4} = cell2mat(ConDendCorrelationStatDataChoice(latesessions));
    disttouse{4} = cell2mat(ConDendDistanceStatDataChoice(latesessions));
    
    usenorm = 1;

    for i = 1:4
        if i<3
            subplot(2,4,i); hold on;
            color = dred;
        else
            subplot(2,4,i+2); hold on;
            color = lgreen;
        end
        if i == 1 || i == 3
            sessiontag = [num2str(earlysessions(1)), '-', num2str(earlysessions(end))];
        elseif i == 2 || i ==4 
            sessiontag = [num2str(latesessions(1)), '-', num2str(latesessions(end))];
        end
        [sortedDistances, sortedDistIndices] = sort(disttouse{i});
    %         [sortedFarDistances, sortedFarDistInd] = sort(AllDistancesBetweenFarSpines{sessiontouse});
        shuffled = [];
        sortedshuffled = [];
        for j = 1:1000
            shuffled(1:length(corrtouse{i}),j) = corrtouse{i}(randperm(length(corrtouse{i})));
            shuffled(isnan(shuffled(:,j)),:) = 0;
            sortedshuffled(:,j) = shuffled(sortedDistIndices,j)./nansum(shuffled(sortedDistIndices,j));
            sortedshuffled(isnan(sortedshuffled(:,j)),:) = 0;
            plot(sortedDistances, cumsum(sortedshuffled(:,j)),'color', [0.5 0.5 0.5]);
        %             farshuffled(1:length(farcorrtouse),j) = farcorrtouse(randperm(length(farcorrtouse)));
        %             sortedFarshuffled(:,j) = farshuffled(sortedFarDistInd,j)./nansum(farshuffled(sortedFarDistInd,j));
        %             plot(sortedFarDistances,cumsum(sortedFarshuffled(:,j)),'color', [0.5 0.5 0.5]);
        end
        plot(sortedDistances, cumsum(nanmean(sortedshuffled,2)), 'k', 'Linewidth', 2)
        Correlations_fraction = corrtouse{i}(sortedDistIndices)./nansum(corrtouse{i}(sortedDistIndices));
        Correlations_fraction(isnan(Correlations_fraction))= 0;
        plot(sortedDistances,cumsum(Correlations_fraction),'color',color, 'LineWidth', 3)
        plot(sortedDistances(2:end),(smooth(diff(cumsum(Correlations_fraction)),1000)-smooth(diff(cumsum(nanmean(sortedshuffled,2)))',1000))/max(smooth(diff(cumsum(Correlations_fraction)),1000)-smooth(diff(cumsum(nanmean(sortedshuffled,2)))',1000)), 'color', green, 'Linewidth', 2)
        plot(sortedDistances, cumsum(Correlations_fraction)-cumsum(nanmean(sortedshuffled,2))', 'Color', lpurple, 'Linewidth', 2)
        ylabel('Cumulative Correlation', 'Fontsize', 14)
        xlabel('Distance (\mum)')
        title(['Session(s) ', sessiontag], 'Fontsize', 14)
        xlim([0 100])
        ylim([0 1])
    end

    subplot(2,4,3); hold on;
        neardist = cell2mat(MovSpinetoNearestMovementRelatedSpine(earlysessions));
        nextdist = cell2mat(MovSpinetoNextClosestMovementRelatedSpine(earlysessions));
        thirddist = cell2mat(MovSpinetoThirdClosestMovementRelatedSpine(earlysessions));
        fourthdist = cell2mat(MovSpinetoFourthClosestMovementRelatedSpine(earlysessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'}, 'Location', 'SouthEast')
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',14)
        set(gca, 'XTick', 0:30, 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3), 'Fontsize', 6)
        xlim([0 20])
        xlabel('Distance bins', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        
        try
            text(1.5, nd(1), ['median = ', num2str(nanmedian(neardist))], 'Color', lpurple);
            text(2.5, nx(1), ['median = ', num2str(nanmedian(nextdist))], 'Color', orange);
            text(3.5, nt(1), ['median = ', num2str(nanmedian(thirddist))], 'Color', lgreen);
            text(4.5, nf(1), ['median = ', num2str(nanmedian(fourthdist))], 'Color', blue);
        catch
        end
        
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        nearcorr = cell2mat(CorrelationwithNearestMovementRelatedSpine(earlysessions)); hold on;
        plot(nanmean(nearcorr)*ones(1,max(hist(nearcorr))), 1:max(hist(nearcorr)), ':k')
        hist(nearcorr); set(findobj(gca, 'Facecolor', 'flat'), 'FaceColor', dred)
        ylabel('Count')
        xlabel('Correlation with nearest MRS')
       
        
    subplot(2,4,4); hold on;
        h = hist(disttouse{1}, round(max(disttouse{1}))/5);
        if usenorm
            h = h/sum(h);
        else
        end
        bar(h, 'FaceColor', dred)
        
        m = hist(disttouse{3}, round(max(disttouse{3}))/5);
        if usenorm
            m = m/sum(m);
        else
        end
        bar(m, 'FaceColor', lgreen)
        if usenorm
            ylim([-0.1 1])
        else
        end
        bar(m-h(1:length(m)), 'FaceColor', blue);
        legend({'All spine pairs', 'MR spines', 'Diff'})
        title(['Sessions ' num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize', 14)
        set(gca, 'XTick', [0:30], 'XTickLabel',mat2cell(num2str([0:5:150]'),ones(31,1),3), 'Fontsize', 6)
        xlabel('Distance bins')
        ylabel('Fraction of Distances Measured', 'Fontsize', 14)
        
%         maxlength = max([length(n),length(h),length(m)]);
%         h(length(h)+1:maxlength) = 0;
%         m(length(m)+1:maxlength) = 0;
%         n(length(n)+1:maxlength) = 0;

        
    subplot(2,4,7); hold on;
        neardist = cell2mat(MovSpinetoNearestMovementRelatedSpine(latesessions));
        nextdist = cell2mat(MovSpinetoNextClosestMovementRelatedSpine(latesessions));
        thirddist = cell2mat(MovSpinetoThirdClosestMovementRelatedSpine(latesessions));
        fourthdist = cell2mat(MovSpinetoFourthClosestMovementRelatedSpine(latesessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'}, 'Location', 'SouthEast')
        title(['Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',14)
        set(gca, 'XTick', 0:30, 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3), 'Fontsize', 6)
        xlim([0 20])
        xlabel('Distance bins', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        
        try
            text(1.5, nd(1), ['median = ', num2str(nanmedian(neardist))], 'Color', lpurple);
            text(2.5, nx(1), ['median = ', num2str(nanmedian(nextdist))], 'Color', orange);
            text(3.5, nt(1), ['median = ', num2str(nanmedian(thirddist))], 'Color', lgreen);
            text(4.5, nf(1), ['median = ', num2str(nanmedian(fourthdist))], 'Color', blue);
        catch
        end
        
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        nearcorr = cell2mat(CorrelationwithNearestMovementRelatedSpine(latesessions)); hold on;
        plot(nanmean(nearcorr)*ones(1,max(hist(nearcorr))), 1:max(hist(nearcorr)), ':', 'Color', lblue)
        hist(nearcorr); set(findobj(gca, 'Facecolor', 'flat'), 'FaceColor', dred)
        ylabel('Count')
        xlabel('Correlation with nearest MRS')
        
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.35*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        plot(1:2, [nanmean(cell2mat(CorrelationwithNearestMovementRelatedSpine(earlysessions))), nanmean(cell2mat(CorrelationwithNearestMovementRelatedSpine(latesessions)))], '-', 'Color', lpurple, 'Linewidth', 2); hold on;
        plot(1:2, [nanmean(cell2mat(CorrelationwithFarthestMovementRelatedSpine(earlysessions))), nanmean(cell2mat(CorrelationwithFarthestMovementRelatedSpine(latesessions)))], '-', 'Color', blue, 'Linewidth', 2)
        r_errorbar(1:2,  [nanmean(cell2mat(CorrelationwithNearestMovementRelatedSpine(earlysessions))), nanmean(cell2mat(CorrelationwithNearestMovementRelatedSpine(latesessions)))],  [nanstd(cell2mat(CorrelationwithNearestMovementRelatedSpine(earlysessions)))/sqrt(length(cell2mat(CorrelationwithNearestMovementRelatedSpine(earlysessions)))), nanstd(cell2mat(CorrelationwithNearestMovementRelatedSpine(latesessions)))/sqrt(length(cell2mat(CorrelationwithNearestMovementRelatedSpine(latesessions))))], 'k')
        r_errorbar(1:2,  [nanmean(cell2mat(CorrelationwithFarthestMovementRelatedSpine(earlysessions))), nanmean(cell2mat(CorrelationwithFarthestMovementRelatedSpine(latesessions)))],  [nanstd(cell2mat(CorrelationwithFarthestMovementRelatedSpine(earlysessions)))/sqrt(length(cell2mat(CorrelationwithFarthestMovementRelatedSpine(earlysessions)))), nanstd(cell2mat(CorrelationwithFarthestMovementRelatedSpine(latesessions)))/sqrt(length(cell2mat(CorrelationwithFarthestMovementRelatedSpine(latesessions))))], 'k')
        xlim([0 3])
        ylabel({'Correlation with nearest', 'movement-related spine'})
        set(gca, 'XTick', [1 2])
        set(gca, 'XTickLabel', {'Early', 'Late'})
        
    subplot(2,4,8); hold on;
        h = hist(disttouse{2}, round(max(disttouse{2}))/5);
        h = h/sum(h);
        bar(h, 'FaceColor', dred)
        
        m = hist(disttouse{4}, round(max(disttouse{4}))/5);
        if usenorm
            m = m/sum(m);
        else
        end
        bar(m, 'FaceColor', lgreen)
        if usenorm
            ylim([-0.1 1])
        else
        end
        bar(m-h(1:length(m)), 'FaceColor', blue)
        legend({'All spine pairs', 'MR spines', 'Diff'})
        title(['Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize', 14)
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3), 'Fontsize', 6)
        xlabel('Distance bins')
        ylabel('Fraction of Distances Measured', 'Fontsize', 14)
        
%         maxlength = max([length(n),length(h),length(m)]);
%         h(length(h)+1:maxlength) = 0;
%         m(length(m)+1:maxlength) = 0;
%         n(length(n)+1:maxlength) = 0;
    
    %%%
    %% Figure 10
    %%%
    
    figure('Position', scrsz, 'Name', 'Clustering Characterization'); hold on;
%             axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.3*pos(4), 0.25*pos(3), 0.25*pos(4)]);
    
    subplot(2,4,1)
        neardist = cell2mat(MovSpinetoNearestMovementRelatedSpine(earlysessions));
        nextdist = cell2mat(MovSpinetoNextClosestMovementRelatedSpine(earlysessions));
        thirddist = cell2mat(MovSpinetoThirdClosestMovementRelatedSpine(earlysessions));
        fourthdist = cell2mat(MovSpinetoFourthClosestMovementRelatedSpine(earlysessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title(['Distribution of all Movement Spines Sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end))], 'Fontsize',12)
        set(gca, 'XTick', 0:30, 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        xlim([0 10])
                
    subplot(2,4,5)
        neardist = cell2mat(MovSpinetoNearestMovementRelatedSpine(latesessions));
        nextdist = cell2mat(MovSpinetoNextClosestMovementRelatedSpine(latesessions));
        thirddist = cell2mat(MovSpinetoThirdClosestMovementRelatedSpine(latesessions));
        fourthdist = cell2mat(MovSpinetoFourthClosestMovementRelatedSpine(latesessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title(['Distribution of all Movement Spines Sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end))], 'Fontsize',12)
        set(gca, 'XTick', 0:30, 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        xlim([0 10])
                
    subplot(2,4,2)
        neardist = cell2mat(MoveSpinetoNearestFunctionallyClusteredMoveSpine(earlysessions));
        nextdist = cell2mat(MoveSpinetoNextFunctionallyClusteredMoveSpine(earlysessions));
        thirddist = cell2mat(MoveSpinetoThirdFunctionallyClusteredMoveSpine(earlysessions));
        fourthdist = cell2mat(MoveSpinetoFourthFunctionallyClusteredMoveSpine(earlysessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        title({'Distance from Any Move Spine to', ['Nearest Functionally Clustered Mov-Rel Spine (sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end)),')']}, 'Fontsize', 10)
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
        
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        nearcorr = cell2mat(CorrofNearestMetaCluster(earlysessions)); hold on;
        nextcorr = cell2mat(CorrofNextMetaCluster(earlysessions)); 
        thirdcorr = cell2mat(CorrofThirdMetaCluster(earlysessions));
        fourthcorr = cell2mat(CorrofFourthMetaCluster(earlysessions));
        [nc,ncent] = hist(nearcorr);
        [nxc,xcent] = hist(nextcorr);
        [ntc,tcent] = hist(thirdcorr);
        [nfc,fcent] = hist(fourthcorr);
        if usenorm
            nc = nc/sum(nc);
            nxc = nxc/sum(nxc);
            ntc = ntc/sum(ntc);
            nfc = nfc/sum(nfc);
        else
        end
        bar(ncent, nc, 'FaceColor', lpurple)
        bar(xcent, nxc, 'FaceColor',orange)
        bar(tcent, ntc, 'FaceColor',lgreen)
        bar(fcent, nfc, 'FaceColor', blue)
        ylabel('Count')
        ylim([0 1])


        
    subplot(2,4,6)
        neardist = cell2mat(MoveSpinetoNearestFunctionallyClusteredMoveSpine(latesessions));
        nextdist = cell2mat(MoveSpinetoNextFunctionallyClusteredMoveSpine(latesessions));
        thirddist = cell2mat(MoveSpinetoThirdFunctionallyClusteredMoveSpine(latesessions));
        fourthdist = cell2mat(MoveSpinetoFourthFunctionallyClusteredMoveSpine(latesessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        title({'Distance from Any Move Spine to', ['Nearest Functionally Clustered Mov-Rel Spine (sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end)),')']}, 'Fontsize', 10)
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
        
        pos = get(gca,'Position');
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        nearcorr = cell2mat(CorrofNearestMetaCluster(latesessions)); hold on;
        nextcorr = cell2mat(CorrofNextMetaCluster(latesessions)); 
        thirdcorr = cell2mat(CorrofThirdMetaCluster(latesessions));
        fourthcorr = cell2mat(CorrofFourthMetaCluster(latesessions));
        [nc,ncent] = hist(nearcorr);
        [nxc,xcent] = hist(nextcorr);
        [ntc,tcent] = hist(thirdcorr);
        [nfc,fcent] = hist(fourthcorr);
        if usenorm
            nc = nc/sum(nc);
            nxc = nxc/sum(nxc);
            ntc = ntc/sum(ntc);
            nfc = nfc/sum(nfc);
        else
        end
        bar(ncent, nc, 'FaceColor', lpurple)
        bar(xcent, nxc, 'FaceColor',orange)
        bar(tcent, ntc, 'FaceColor',lgreen)
        bar(fcent, nfc, 'FaceColor', blue)
        ylabel('Count')
        ylim([0 1])
        
        axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.4*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
        nearearly = cell2mat(AllCorrelationswithNearbyMetaClusters(earlysessions)');
        nearlate = cell2mat(AllCorrelationswithNearbyMetaClusters(latesessions)');
        near{1} = nearearly; near{2} = nearlate;
        flex_plot(1:2, near, 'nonparametric', lpurple, 2);
        distantearly = cell2mat(AllCorrelationswithDistantMetaClusters(earlysessions)');
        distantlate = cell2mat(AllCorrelationswithDistantMetaClusters(latesessions)');
        distant{1} = distantearly; distant{2} = distantlate;
        flex_plot(1:2, distant, 'nonparametric', lgreen, 2);
        randomearly = cell2mat(RandomMovementPairCorr(earlysessions))';
        randomlate = cell2mat(RandomMovementPairCorr(latesessions))';
        random{1} = randomearly; random{2} = randomlate;
        flex_plot(1:2, random, 'nonparametric', black, 2);
        set(gca, 'XTick', [1 2]);
        xlim([0 3])
        set(gca, 'XTickLabel', {'Early', 'Late'})
        ylabel('Correlation')
        ylim([0 1])
        
    subplot(2,4,3)
        neardist = cell2mat(NearestFunctionallyClusteredMovementRelatedSpine(earlysessions));
        nextdist = cell2mat(NextClosestFunctionallyClusteredMovementRelatedSpine(earlysessions));
        thirddist = cell2mat(ThirdClosestFunctionallyClusteredMovementRelatedSpine(earlysessions));
        fourthdist = cell2mat(FourthClosestFunctionallyClusteredMovementRelatedSpine(earlysessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title({'Distance from Functionally Clustered Spine to', ['Nearest Functionally Clustered Mov-Rel Spine (sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end)),')']}, 'Fontsize', 10)
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
        ylim([0 1])
        
    subplot(2,4,7)
%                 axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.3*pos(4), 0.25*pos(3), 0.25*pos(4)]);
        neardist = cell2mat(NearestFunctionallyClusteredMovementRelatedSpine(latesessions));
        nextdist = cell2mat(NextClosestFunctionallyClusteredMovementRelatedSpine(latesessions));
        thirddist = cell2mat(ThirdClosestFunctionallyClusteredMovementRelatedSpine(latesessions));
        fourthdist = cell2mat(FourthClosestFunctionallyClusteredMovementRelatedSpine(latesessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title({'Distance from Functionally Clustered Spine to', ['Nearest Functionally Clustered Mov-Rel Spine (sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end)),')']}, 'Fontsize', 10)
        if usenorm
            ylim([0 1])
        else
        end
        
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
        ylim([0 1])

    subplot(2,4,4)
        neardist = cell2mat(NearestHighlyCorrelatedMovementRelatedSpine(earlysessions));
        nextdist = cell2mat(NextClosestHighlyCorrelatedMovementRelatedSpine(earlysessions));
        thirddist = cell2mat(ThirdClosestHighlyCorrelatedMovementRelatedSpine(earlysessions));
        fourthdist = cell2mat(FourthClosestHighlyCorrelatedMovementRelatedSpine(earlysessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title({'Distance to Nearest Highly', ['Correlated Mov-Rel Spine (sessions ', num2str(earlysessions(1)), '-', num2str(earlysessions(end)), ')']}, 'Fontsize', 12)
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
        
    subplot(2,4,8)
        neardist = cell2mat(NearestHighlyCorrelatedMovementRelatedSpine(latesessions));
        nextdist = cell2mat(NextClosestHighlyCorrelatedMovementRelatedSpine(latesessions));
        thirddist = cell2mat(ThirdClosestHighlyCorrelatedMovementRelatedSpine(latesessions));
        fourthdist = cell2mat(FourthClosestHighlyCorrelatedMovementRelatedSpine(latesessions));
        try
            nd = hist(neardist, round(max(neardist)/5));
            nx = hist(nextdist, round(max(nextdist)/5));
            nt = hist(thirddist, round(max(thirddist)/5));
            nf = hist(fourthdist, round(max(fourthdist)/5));
        catch
            nd = [];
            nx = [];
            nt = [];
            nf = [];
        end
        if usenorm
            nd = nd/sum(nd);
            nx = nx/sum(nx);
            nt = nt/sum(nt);
            nf = nf/sum(nf);
        else
        end
        allmat = zeros(4,max([length(nd), length(nx), length(nt), length(nf)]));
        allmat(1,1:length(nd)) = nd;
        allmat(2,1:length(nx)) = nx;
        allmat(3,1:length(nt)) = nt;
        allmat(4,1:length(nf)) = nf;
        bar(allmat')
        barmap = [lpurple; orange; lgreen; blue];
        colormap(barmap)
        legend({'Nearest', 'Second', 'Third', 'Fourth'})
        title({'Distance to Nearest Highly', ['Correlated Mov-Rel Spine (sessions ', num2str(latesessions(1)), '-', num2str(latesessions(end)), ')']}, 'Fontsize', 12)
        xlabel('Distance (\mum)', 'Fontsize', 14)
        ylabel('Fraction', 'Fontsize', 14)
        if usenorm
            ylim([0 1])
        else
        end
        
        set(gca, 'XTick', [0:30], 'XTickLabel', mat2cell(num2str([0:5:150]'),ones(31,1),3))
        xlim([0 10])
end



