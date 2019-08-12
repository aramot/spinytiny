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

animalstodo = get(gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox, 'value');

if length(animalstodo)>1
    showfigs = 0;
else
    showfigs = 1;
end

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

animal = regexp(varargin{firstdatainput}{1}, ['[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}0+\d+'], 'match');

disp(['File ', animal{1}, ' analyzed'])

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
for i = 1:length(varargin{firstdatainput}) 
    cd('E:\ActivitySummary');
    load(varargin{firstdatainput}{i});
    eval(['currentfile = ', varargin{firstdatainput}{i}(1:end-4), ';'])
    clear(varargin{firstdatainput}{i})
    session = currentfile.Session;
    SpineToSpineDistance = currentfile.DistanceHeatMap;
        tempC = SpineToSpineDistance;
        tempD = SpineToSpineDistance';
        tempC(isnan(tempC) & ~isnan(tempD)) = tempD(isnan(tempC) & ~isnan(tempD));
        DistanceMap = tempC;
    NumClusters(1,session) = 0;
    NumCausalClusters(1,session) = 0;

    if currentfile.NumberofSpines ~= length(currentfile.dF_over_F)
        currentfile.NumberofSpines = length(currentfile.dF_over_F);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    denominator = currentfile.NumberofSpines;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    NumberofImagedSpines(1,session) = currentfile.NumberofSpines;

    if NumberofImagedSpines(1,session) ~= length(currentfile.dF_over_F)
        NumberofImagedSpines(1,session) = length(currentfile.dF_over_F);
    end

    for d = 1:currentfile.NumberofDendrites
        LengthofDendrites{session}(1,d) = sum(currentfile.DendriteLengthValues{d});
    end

    if ~isempty(Correlations{session})

        if isfield(currentfile, 'SpineDendriteGrouping')
            for d = 1:currentfile.NumberofDendrites
                firstspine = currentfile.SpineDendriteGrouping{d}(1);
                lastspine = currentfile.SpineDendriteGrouping{d}(end);
                if d == currentfile.NumberofDendrites
                    if lastspine ~= currentfile.NumberofSpines
                        lastspine = currentfile.NumberofSpines;
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
            if currentfile.NumberofDendrites ==1
                currentfile.SpineDendriteGrouping = {1:currentfile.NumberofSpines};
                SpinesonCueDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.CueDends;
                SpinesonMovementDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.MovementDends;
                SpinesonPreSuccessDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.PreSuccessDends;
                SpinesonSuccessDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.SuccessDends;
                SpinesonMovementDuringCueDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.MovementDuringCueDends;
                SpinesonRewardDend{session} = ones(currentfile.NumberofSpines,1).*StatClass{session}.RewardDends;
                disp(['File ', currentfile.Filename, ' did not have spine-dendrite grouping information, but can be correctly filled in']);
            else
                disp(['File ', currentfile.Filename, ' does NOT have necessary spine-dendrite grouping info!']);
            end
        end

        PercentCueRelDends(1,session) = sum(StatClass{session}.CueDends)/currentfile.NumberofDendrites;
        PercentMovRelDends(1,session) = sum(StatClass{session}.MovementDends)/currentfile.NumberofDendrites;
        PercentPreSucRelDends(1,session) = sum(StatClass{session}.PreSuccessDends)/currentfile.NumberofDendrites;
        PercentSucRelDends(1,session) = sum(StatClass{session}.SuccessDends)/currentfile.NumberofDendrites;
        PercentMovDuringCueRelDends(1,session) = sum(StatClass{session}.MovementDuringCueDends)/currentfile.NumberofDendrites;
        PercentRewRelDends(1,session) = sum(StatClass{session}.RewardDends)/currentfile.NumberofDendrites;


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

        [SpectralData] = SpectralClustering(currentfile, SessionCorrData, StatClass, Choices);

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
            dendcheck = ones(1,length(currentfile.deltaF)); %%% Set this variable to one to allow use of ALL spines on ALL (non just feature-related) dendrites
            dendcheckC = ones(1,length(currentfile.deltaF));
            dendcheckM = ones(1,length(currentfile.deltaF));
            dendcheckPS = ones(1,length(currentfile.deltaF));
            dendcheckS = ones(1,length(currentfile.deltaF));
            dendcheckMDC = ones(1,length(currentfile.deltaF));
            dendcheckR = ones(1,length(currentfile.deltaF));
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

            corrmat = SessionCorrData(Spine1_address+1:Spine1_address+length(currentfile.dF_over_F),Spine1_address+1:Spine1_address+length(currentfile.dF_over_F));
            movcorrmat = SessionMovCorrData;
            stillcorrmat = SessionStillCorrData;
            causalmat = Correlations{session}.CausalCorrelations(Spine1_address+1:Spine1_address+length(currentfile.dF_over_F),Spine1_address+1:Spine1_address+length(currentfile.dF_over_F));

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
            alldends = 1:currentfile.NumberofDendrites;
            if length(alldends)>1
                dendcombs = nchoosek(alldends,2)+Spine1_address+length(currentfile.dF_over_F);
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

                samecell = cellfun(@(x) unique(x)-(Spine1_address+length(currentfile.dF_over_F)), samecell, 'uni', false);
            else
                samecell = {[]};
            end


            DiffDendSameCell = [];
            spinesonthiscell = [];
            for sc = 1:length(samecell)
                if ~isempty(samecell{sc})
                    spinesonthiscell{sc} = cell2mat(cellfun(@(x) cell2mat(currentfile.SpineDendriteGrouping(x)), samecell, 'uni', false));
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


        [HSCs{1,session}, ClusteredSpines{1,session}, CorrelationofClusts, FarClusteredSpines, CausalClusteredSpines] = binaryclusterclass(currentfile, corrmat, causalmat);

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
            for d = 1:length(currentfile.SpineDendriteGrouping)
                FractionofMovRelSpinesPerDendrite{session}(1,d) = sum(MovementSpines(currentfile.SpineDendriteGrouping{d}))/length(currentfile.SpineDendriteGrouping{d});
                MovRelSpinesPer10Microns{session}(1,d) = sum(MovementSpines(currentfile.SpineDendriteGrouping{d}))/(sum(currentfile.DendriteLengthValues{d})/10);
                FractionofSucRelSpinesPerDendrite{session}(1,d) = sum(SuccessSpines(currentfile.SpineDendriteGrouping{d}))/length(currentfile.SpineDendriteGrouping{d});
                SucRelSpinesPer10Microns{session}(1,d) = sum(SuccessSpines(currentfile.SpineDendriteGrouping{d}))/(sum(currentfile.DendriteLengthValues{d})/10);
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

        pixpermicron = 0.5;
        if isfield(currentfile, 'ZoomValue')
            if currentfile.ZoomValue ~= 0
                pixpermicron = (pixpermicron*currentfile.ZoomValue);
            end
        end

        FarDistanceMap = DistanceMap;
        FarDistanceMap(logical(eye(length(DistanceMap),length(DistanceMap)))) = 0;
        [r,c] = find(isnan(triu(FarDistanceMap)));

        if length(currentfile.PolyLinePos{1})>2
            method = 'old';    
        elseif length(currentfile.PolyLinePos{1}) == 2
            method = 'new';
        else
            error('Could not determine method used to draw ROIs')
        end

        for m = 1:length(r)
            switch method
                case 'old'
                    spine_pos1 = [currentfile.ROIPosition{r(m)+1}(1)+currentfile.ROIPosition{r(m)+1}(3)/2, currentfile.ROIPosition{r(m)+1}(2)+currentfile.ROIPosition{r(m)+1}(4)/2];
                    spine_pos2 = [currentfile.ROIPosition{c(m)+1}(1)+currentfile.ROIPosition{c(m)+1}(3)/2, currentfile.ROIPosition{c(m)+1}(2)+currentfile.ROIPosition{c(m)+1}(4)/2];
                    FarDistanceMap(r(m),c(m)) = (sqrt((spine_pos1(1)-spine_pos2(1)).^2 +(spine_pos1(2)-spine_pos2(2)).^2))/pixpermicron;
                case 'new'
                    spine_pos1 = [currentfile.ROIPosition{r(m)+1}(1)+currentfile.ROIPosition{r(m)+1}(3)/2, currentfile.ROIPosition{r(m)+1}(2)+currentfile.ROIPosition{r(m)+1}(4)/2];
                    spine_pos2 = [currentfile.ROIPosition{c(m)+1}(1)+currentfile.ROIPosition{c(m)+1}(3)/2, currentfile.ROIPosition{c(m)+1}(2)+currentfile.ROIPosition{c(m)+1}(4)/2];
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

        allspine_combos = nchoosek(1:length(currentfile.dF_over_F),2);

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
                    dist_between_far_mov_spines(1,n) = currentfile.FarSpineToSpineDistance(numpos);
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
                        dist_between_branch_mov_spines(1,n) = currentfile.FarSpineToSpineDistance(numpos);
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
                    dist_between_far_suc_spines(1,n) = currentfile.FarSpineToSpineDistance(numpos);
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
                        dist_between_branch_suc_spines(1,n) = currentfile.FarSpineToSpineDistance(numpos);
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

        if isempty(separatedendcorrlist) && ~isempty(currentfile.FarSpineToSpineDistance)
            if sum(currentfile.FarSpineToSpineDistance)
                DistanceBetweenFarSpines{session} = [];
            else
            end
        else
            DistanceBetweenFarSpines{session} = currentfile.FarSpineToSpineDistance;
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
        invcheckmat = ones(currentfile.NumberofSpines,1);

        allspines = Spine1_address+(1:length(currentfile.deltaF));
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

        allspine_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq);

        movspine_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(logical(MovementSpines)));

        cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(cluster_ind-Spine1_address));

        nonclustered_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(nonclustered-Spine1_address));

        cue_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(cue_cluster_ind-Spine1_address));

        mov_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(mov_cluster_ind-Spine1_address));

        movduringcue_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(movduringcue_cluster_ind-Spine1_address));

        presuc_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(presuc_cluster_ind-Spine1_address));

        suc_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(suc_cluster_ind-Spine1_address));

        rew_cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(rew_cluster_ind-Spine1_address));

        Caus_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_cluster_ind-Spine1_address));

        Caus_nonclustered_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(causal_nonclustered-Spine1_address));

        Caus_cue_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_cue_cluster_ind-Spine1_address));

        Caus_mov_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_mov_cluster_ind-Spine1_address));

        Caus_movduringcue_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_movduringcue_cluster_ind-Spine1_address));

        Caus_presuc_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_presuc_cluster_ind-Spine1_address));

        Caus_suc_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_suc_cluster_ind-Spine1_address));

        Caus_rew_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_rew_cluster_ind-Spine1_address));


        %%% Amplitude
        AmpList = cellfun(@(x) nanmedian(x(x<100)), currentfile.AllSpineAmpData, 'Uni', false);
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

        DendNum = currentfile.NumberofDendrites;

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

        if isfield(currentfile, 'SpineDendriteGrouping')
            ClustersoneachDend = cell(length(currentfile.SpineDendriteGrouping),1);
            CausalClustersoneachDend = cell(length(currentfile.SpineDendriteGrouping),1);
            dcounter = cell(length(currentfile.SpineDendriteGrouping),1);
            Cdcounter = cell(length(currentfile.SpineDendriteGrouping),1);
            for k = 1:currentfile.NumberofDendrites
                dcounter{k} = 0;
                Cdcounter{k} = 0;
            end
            for k = 1:length(ClusteredSpines{1,session})
                if ~isempty(ClusteredSpines{1,session}{k})
                    for m = 1:length(currentfile.SpineDendriteGrouping)
                        if ~isempty(find(currentfile.SpineDendriteGrouping{m} == ClusteredSpines{1,session}{k}(1)))
                            ClustersoneachDend{m}{dcounter{m}+1} = ClusteredSpines{1,session}{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                            dcounter{m} = dcounter{m}+1;
                        end
                    end
                end
            end
            for k = 1:length(CausalClusteredSpines)
                if ~isempty(CausalClusteredSpines{k})
                    for m = 1:length(currentfile.SpineDendriteGrouping)
                        if ~isempty(find(currentfile.SpineDendriteGrouping{m} == CausalClusteredSpines{k}(1)))
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
         [r_dendsubtracted, ~] = corrcoef([currentfile.SynapseOnlyBinarized_DendriteSubtracted', currentfile.Dendrite_Binarized']);

        corrmattouse = r_dendsubtracted;
        causcorrmattouse = r_dendsubtracted;

        %%% initialize variables

        Clusters_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        CausalClusters_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        Nonclustered_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        Noncausal_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        FiltClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        FiltCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);

        CueClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        MovClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        PreSucClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        SucClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        MovDuringCueClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        RewClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);

        CueCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        MovCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        SucCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        RewCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);


        for k = 1:currentfile.NumberofDendrites
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
                otherspinesonthisdend = currentfile.SpineDendriteGrouping{k}; %%% Labels spines by actual count/ROI num
                    nonclusteredcausalspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, causalclusteredspinesonthisdend));
                otherspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, clusteredspinesonthisdend));
                Clusters_CorrwithDend(1,k) = nanmean(corrmattouse(clusteredspinesonthisdend, length(currentfile.deltaF)+k));
                    CausalClusters_CorrwithDend(1,k) = nanmean(causcorrmattouse(causalclusteredspinesonthisdend, length(currentfile.deltaF)+k));
                Nonclustered_CorrwithDend(1,k) = nanmean(corrmattouse(otherspinesonthisdend, length(currentfile.deltaF)+k));
                    Noncausal_CorrwithDend(1,k) = nanmean(causcorrmattouse(nonclusteredcausalspinesonthisdend, length(currentfile.deltaF)+k));

                Filtered_Clusts = clusteredspinesonthisdend(ismember(clusteredspinesonthisdend, cluster_ind-Spine1_address)); %%% Correct for addressing scheme           %%% Apply all the filtering criteria established in the first section of this function
                    Filtered_CausalClusts = causalclusteredspinesonthisdend(ismember(causalclusteredspinesonthisdend, cluster_ind-Spine1_address));
                FiltClusts_CorrwithDend(1,k) = nanmean(corrmattouse(Filtered_Clusts, length(currentfile.deltaF)+k));
                    FiltCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Filtered_CausalClusts, length(currentfile.deltaF)+k));
                CueClusts_CorrwithDend(1,k) = nanmean(corrmattouse(cue_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    CueCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_cue_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                MovClusts_CorrwithDend(1,k) = nanmean(corrmattouse(mov_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    MovCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_mov_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                PreSucClusts_CorrwithDend(1,k) = nanmean(corrmattouse(presuc_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    PreSucCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_presuc_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                SucClusts_CorrwithDend(1,k) = nanmean(corrmattouse(suc_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    SucCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_suc_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                MovDuringCueClusts_CorrwithDend(1,k) = nanmean(corrmattouse(movduringcue_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    MovDuringCueCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(movduringcue_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                RewClusts_CorrwithDend(1,k) = nanmean(corrmattouse(rew_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
                    RewCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Caus_rew_cluster_ind-Spine1_address, length(currentfile.deltaF)+k));
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
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == cluster_ind(k)-Spine1_address))
                        DendswithClusts = [DendswithClusts; m];
                    end
                end
            end
        else
        end

        if ~isempty(Caus_cluster_ind)
            for k = 1:numel(Caus_cluster_ind)
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == Caus_cluster_ind(k)-Spine1_address))
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
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == cue_cluster_ind(k)-Spine1_address))
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
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == mov_cluster_ind(k)-Spine1_address))
                        DendswithMovClusts = [DendswithMovClusts; m];
                    end
                end
            end
        else
        end
        if ~isempty(movduringcue_cluster_ind)
            for k = 1:numel(movduringcue_cluster_ind)
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == movduringcue_cluster_ind(k)-Spine1_address))
                        DendswithMovDuringCueClusts = [DendswithMovDuringCueClusts; m];
                    end
                end
            end
        else
        end
        if ~isempty(presuc_cluster_ind)
            for k = 1:numel(presuc_cluster_ind)
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == presuc_cluster_ind(k)-Spine1_address))
                        DendswithPreSucClusts = [DendswithPreSucClusts; m];
                    end
                end
            end
        else
        end
        if ~isempty(suc_cluster_ind)
            for k = 1:numel(suc_cluster_ind)
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == suc_cluster_ind(k)-Spine1_address))
                        DendswithSucClusts = [DendswithSucClusts; m];
                    end
                end
            end
        else
        end
        if ~isempty(rew_cluster_ind)
            for k = 1:numel(rew_cluster_ind)
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == rew_cluster_ind(k)-Spine1_address))
                        DendswithRewClusts = [DendswithRewClusts; m];
                    end
                end
            end
        else
        end
        if ~isempty(Caus_mov_cluster_ind)
            for k = 1:numel(Caus_mov_cluster_ind)
                Caus_movAmp(1,k) = nanmean(currentfile.AllSpineAmpData{Caus_mov_cluster_ind(k)-Spine1_address});
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == Caus_mov_cluster_ind(k)-Spine1_address))
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

        DendritesArray = [1:currentfile.NumberofDendrites]';                                      %%% All dendrites from the current experiment
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
            DendNumClust{session}(n,5) = currentfile.Dendritic_Frequency(n);                    %%% Column 5: Frequency of dendrite
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

                ClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithClusts));
                NoClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendsnoClusts));
                CueClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithCueClusts));
                MovClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithMovClusts));
                MovDuringCueClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithMovDuringCueClusts));
                PreSuccessClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithPreSucClusts));
                SuccessClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithSucClusts));
                RewardClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithRewClusts));
                NoMovClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendsnomovClusts));
                counter = 1;

                for j = 1:DendNum
                    firstspine = currentfile.SpineDendriteGrouping{j}(1);
                    lastspine = currentfile.SpineDendriteGrouping{j}(end);

                    if length(currentfile.SpineDendriteGrouping{j})>mindendsize
                        if strcmpi(laplaciantouse, 'Normalized')
                            L = currentfile.NormalizedLaplacian{j};
                        elseif strcmpi(laplaciantouse, 'Original')
                            L = currentfile.LaplacianMatrix{j};
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
                            DendClust_Deg{session}(counter,4) = currentfile.Dendritic_Frequency(j);
                            DendClust_Deg{session}(counter,5) = SessionCorrData(Movement_address, Spine1_address+length(currentfile.deltaF)+j);
                            DendClust_Deg{session}(counter,6) = length(currentfile.SpineDendriteGrouping{j});
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
                AllDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency);
                MoveDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(StatClass{session}.MovementDends));
                NonMoveDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(~StatClass{session}.MovementDends));
                ClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithClusts));
                NoClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendsnoClusts));
                CueClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithCueClusts));
                MovClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithMovClusts));
                MovDuringCueClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithMovDuringCueClusts));
                PreSucClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithPreSucClusts));
                SucClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithSucClusts));
                RewClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithRewClusts));
                NoMovClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendsnomovClusts));
                counter = 1;

                for j = 1:DendNum
                    firstspine = currentfile.SpineDendriteGrouping{j}(1);
                    lastspine = currentfile.SpineDendriteGrouping{j}(end);

                    if length(currentfile.SpineDendriteGrouping{j})>mindendsize
                        if strcmpi(laplaciantouse, 'Normalized')
                            L = currentfile.NormalizedLaplacian{j};
                        elseif strcmpi(laplaciantouse, 'Original')
                            L = currentfile.LaplacianMatrix{j};
                        end
                        eigenvalues = eig(L);
                        Fiedlerval = min(eigenvalues(~ismember(eigenvalues,min(eigenvalues)))); %%% Finds the second smallest eigenvalue (the Fiedler value, or measure or algebraic connectivity)

                        temporalvalues = eig(Temporal_Laplacian{session}{j});
                        temporalvalues(temporalvalues==min(temporalvalues)) = nan;
                        [TemporalFiedlerval, ~] = min(temporalvalues);
                        DendClust_Deg{session}(counter,1) = real(Fiedlerval);
                        DendClust_Deg{session}(counter,2) = real(TemporalFiedlerval);
                        DendClust_Deg{session}(counter,3) = real(SpatioTemporalFiedler{session}(j));
                        DendClust_Deg{session}(counter,4) = currentfile.Dendritic_Frequency(j);
                        DendClust_Deg{session}(counter,5) = SessionCorrData(Movement_address, Spine1_address+length(currentfile.deltaF)+j);
                        DendClust_Deg{session}(counter,6) = length(currentfile.SpineDendriteGrouping{j});
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


        if isfield(currentfile, 'SpineDendriteGrouping')
            for d = 1:currentfile.NumberofDendrites
                firstspine = currentfile.SpineDendriteGrouping{d}(1);
                lastspine = currentfile.SpineDendriteGrouping{d}(end);
            end
        else
            if currentfile.NumberofDendrites == 1
                currentfile.SpineDendriteGrouping = {1:length(currentfile.deltaF)};
                disp(['File ', currentfile.Filename, ' did not have spine-dendrite grouping information, but can be correctly filled in']);
            else
                disp(['File ', currentfile.Filename, ' does NOT have necessary spine-dendrite grouping info!']);
            end
        end

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% Spectral analysis of dendrites %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% When no behavioral data is available, simply use
        %%% correlations of calcium traces alone

        if dendexclude
            [rsp, ~] = corrcoef(currentfile.SynapseOnlyBinarized');
        elseif dendsubtract
            [rsp, ~] = corrcoef(currentfile.SynapseOnlyBinarized_DendriteSubtracted');
        else
            [rsp, ~] = corrcoef(currentfile.OverallSpineActivity');
        end

        corrmat = nan(currentfile.NumberofSpines+Spine1_address, currentfile.NumberofSpines+Spine1_address);

        corrmat(Spine1_address+1:Spine1_address+size(rsp,1),Spine1_address+1:Spine1_address+size(rsp,2)) = rsp;

        [SpectralData] = SpectralClustering(currentfile, corrmat, StatClass, Choices);


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
            corrmat = corrcoef([currentfile.SynapseOnlyBinarized]');
        elseif dendsubtract
            corrmat = corrcoef([currentfile.SynapseOnlyBinarized_DendriteSubtracted]');
        end
%             corrmat = corrcoef([currentfile.OverallSpineActivity]');

        %%% Causal clusters

        Clustnum = 1;
        tempA = currentfile.CausalHeatMap;
        tempB = currentfile.CausalHeatMap';
        tempA(isnan(tempA) & ~isnan(tempB)) = tempB(isnan(tempA) & ~isnan(tempB));
        causalmat = tempA;

        [HSCs{1,session}, ClusteredSpines{1,session}, CorrelationofClusts, FarClusteredSpines, CausalClusteredSpines] = binaryclusterclass(currentfile,corrmat, causalmat);

        CorrelationofClusters{session} = CorrelationofClusts;

        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Find indices for clusters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Find indices for movement- and cue-related clusters
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%% Correlation indices for synapse-only events

        StatClass{session}.MovementSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.CueSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.CueORMovementSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.PreSuccessSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.SuccessSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.MovementDuringCueSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.RewardSpines = zeros(length(currentfile.deltaF),1);

        StatClass{session}.DendSub_MovementSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.DendSub_CueSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.DendSub_PreSuccessSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.DendSub_SuccessSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.DendSub_MovementDuringCueSpines = zeros(length(currentfile.deltaF),1);
        StatClass{session}.DendSub_RewardSpines = zeros(length(currentfile.deltaF),1);

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

        StatClass{i}.CausalMovementSpines = zeros(length(currentfile.deltaF),1);

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
        if isfield(currentfile, 'ZoomValue')
            if currentfile.ZoomValue ~= 0
                pixpermicron = (pixpermicron*currentfile.ZoomValue)/12.1;
            end
        end

        FarDistanceMap = DistanceMap;
        FarDistanceMap(logical(eye(length(DistanceMap),length(DistanceMap)))) = 0;
        [r,c] = find(isnan(triu(FarDistanceMap)));

        for m = 1:length(r)
            spine_pos1 = [currentfile.ROIPosition{r(m)+1}(1)+currentfile.ROIPosition{r(m)+1}(3)/2, currentfile.ROIPosition{r(m)+1}(2)+currentfile.ROIPosition{r(m)+1}(4)/2];
            spine_pos2 = [currentfile.ROIPosition{c(m)+1}(1)+currentfile.ROIPosition{c(m)+1}(3)/2, currentfile.ROIPosition{c(m)+1}(2)+currentfile.ROIPosition{c(m)+1}(4)/2];
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

        allspines = Spine1_address+(1:length(currentfile.deltaF));
        nonclustered = allspines(~ismember(allspines,cluster_ind));
        causal_nonclustered = allspines(~ismember(allspines,Caus_cluster_ind));

        %%% Frequency

        allspine_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq);

        movspine_freq(1,session) = NaN;

        cluster_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(cluster_ind-Spine1_address));

        nonclustered_freq(1,session) = nanmedian(currentfile.SynapseOnlyFreq(nonclustered-Spine1_address));

        Caus_cluster_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(Caus_cluster_ind-Spine1_address));

        Caus_nonclustered_freq(1,session) = nanmedian(currentfile.SpikeTimedEvents(causal_nonclustered-Spine1_address));


        %%% Amplitude
        AmpList = cellfun(@(x) nanmean(x(x<100)), currentfile.AllSpineAmpData, 'Uni', false);
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

        DendNum = currentfile.NumberofDendrites; 

        %%%%%
        %%% Find which dendrites contain clusters
        %%%%%

        DendswithClusts = [];
        DendswithCausClusts = [];
        DendsnoClusts = [];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Count the number of clusters on each dendrite
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if isfield(currentfile, 'SpineDendriteGrouping')
            ClustersoneachDend = cell(length(currentfile.SpineDendriteGrouping),1);
            CausalClustersoneachDend = cell(length(currentfile.SpineDendriteGrouping),1);
            dcounter = cell(length(currentfile.SpineDendriteGrouping),1);
            Cdcounter = cell(length(currentfile.SpineDendriteGrouping),1);
            for k = 1:currentfile.NumberofDendrites
                dcounter{k} = 0;
                Cdcounter{k} = 0;
            end
            for k = 1:length(ClusteredSpines{1,session})
                if ~isempty(ClusteredSpines{1,session}{k})
                    for m = 1:length(currentfile.SpineDendriteGrouping)
                        if ~isempty(find(currentfile.SpineDendriteGrouping{m} == ClusteredSpines{1,session}{k}(1)))
                            ClustersoneachDend{m}{dcounter{m}+1} = ClusteredSpines{1,session}{k}; %%% Note that this labels spine by ROI number, and thus their actual count, NOT by the addressing scheme!
                            dcounter{m} = dcounter{m}+1;
                        end
                    end
                end
            end
            for k = 1:length(CausalClusteredSpines)
                if ~isempty(CausalClusteredSpines{k})
                    for m = 1:length(currentfile.SpineDendriteGrouping)
                        if ~isempty(find(currentfile.SpineDendriteGrouping{m} == CausalClusteredSpines{k}(1)))
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

        spinedatatouse = currentfile.SynapseOnlyBinarized_DendriteSubtracted;

         [r_dendsubtracted, ~] = corrcoef([spinedatatouse', currentfile.Dendrite_Binarized']);

        corrmattouse = r_dendsubtracted;
        causcorrmattouse = r_dendsubtracted;

        %%% initialize variables
        Clusters_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        CausalClusters_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        Nonclustered_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        Noncausal_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        FiltClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        FiltCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        MovClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites);
        MovCausClusts_CorrwithDend = nan(1,currentfile.NumberofDendrites); 

        for k = 1:currentfile.NumberofDendrites
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
                otherspinesonthisdend = currentfile.SpineDendriteGrouping{k}; %%% Labels spines by actual count/ROI num
                    nonclusteredcausalspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, causalclusteredspinesonthisdend));
                otherspinesonthisdend = otherspinesonthisdend(~ismember(otherspinesonthisdend, clusteredspinesonthisdend));
                Clusters_CorrwithDend(1,k) = nanmean(corrmattouse(clusteredspinesonthisdend, length(currentfile.deltaF)+k));
                    CausalClusters_CorrwithDend(1,k) = nanmean(causcorrmattouse(causalclusteredspinesonthisdend, length(currentfile.deltaF)+k));
                Nonclustered_CorrwithDend(1,k) = nanmean(corrmattouse(otherspinesonthisdend, length(currentfile.deltaF)+k));
                    Noncausal_CorrwithDend(1,k) = nanmean(causcorrmattouse(nonclusteredcausalspinesonthisdend, length(currentfile.deltaF)+k));

                Filtered_Clusts = clusteredspinesonthisdend(ismember(clusteredspinesonthisdend, cluster_ind-Spine1_address)); %%% Correct for addressing scheme           %%% Apply all the filtering criteria established in the first section of this function
                    Filtered_CausalClusts = causalclusteredspinesonthisdend(ismember(causalclusteredspinesonthisdend, cluster_ind-Spine1_address));
                FiltClusts_CorrwithDend(1,k) = nanmean(corrmattouse(Filtered_Clusts, length(currentfile.deltaF)+k));
                    FiltCausClusts_CorrwithDend(1,k) = nanmean(causcorrmattouse(Filtered_CausalClusts, length(currentfile.deltaF)+k));
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
                clusterAmp(1,k) = nanmean(currentfile.AllSpineAmpData{cluster_ind(k)-Spine1_address});
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == cluster_ind(k)-Spine1_address))
                        DendswithClusts = [DendswithClusts; m];
                    end
                end
            end
        else
            clusterAmp = nan;
        end

        if ~isempty(Caus_cluster_ind)
            for k = 1:numel(Caus_cluster_ind)
                Caus_clusterAmp(1,k) = nanmean(currentfile.AllSpineAmpData{Caus_cluster_ind(k)-Spine1_address});
                for m = 1:length(currentfile.SpineDendriteGrouping)
                    if ~isempty(find(currentfile.SpineDendriteGrouping{m} == Caus_cluster_ind(k)-Spine1_address))
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

        DendritesArray = [1:currentfile.NumberofDendrites]';                                    %%% All dendrites from the current experiment
        allindex = ismember(DendritesArray, DendswithClusts);
        DendsnoClusts = DendritesArray(allindex ==  0);

        DendNumClust{session} = DendritesArray;                                                 %%% Will be a 4-column array; column 1 is the dendrites index
        for n = 1:length(DendNumClust{session})
            DendNumClust{session}(n,2) = sum(DendswithClusts == DendNumClust{session}(n,1));    %%% Column 2: Counts number of clustered spines on a given dendrite
            DendNumClust{session}(n,3) = nan;                                                   %%% Column 3: Counts number of movement-related clustered spines on a given dendrite 
            DendNumClust{session}(n,4) = length(ClustersoneachDend{n});                         %%% Column 4: Number of separate clusters on each dendrite
            DendNumClust{session}(n,5) = currentfile.Dendritic_Frequency(n);                    %%% Column 5: Frequency of dendrite
        end


            DendswithClusts = unique(DendswithClusts);
            DendsnoClusts = unique(DendsnoClusts);               

            AllDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency);
            MoveDendFreq(1,session) = nan;
            NonMoveDendFreq(1,session) = nan;
            ClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendswithClusts));
            NoClustDendFreq(1,session) = nanmean(currentfile.Dendritic_Frequency(DendsnoClusts));
            CueClustDendFreq(1,session) = nan;
            MovClustDendFreq(1,session) = nan;
            SucClustDendFreq(1,session) = nan;
            RewClustDendFreq(1,session) = nan;
            NoMovClustDendFreq(1,session) = nan;
            counter = 1;

            for j = 1:DendNum
                firstspine = currentfile.SpineDendriteGrouping{j}(1);
                lastspine = currentfile.SpineDendriteGrouping{j}(end);

                if length(currentfile.SpineDendriteGrouping{j})>mindendsize
                    if strcmpi(laplaciantouse, 'Normalized')
                        L = currentfile.NormalizedLaplacian{j};
                    elseif strcmpi(laplaciantouse, 'Original')
                        L = currentfile.LaplacianMatrix{j};
                    end
                    eigenvalues = eig(L);
                    Fiedlerval = min(eigenvalues(~ismember(eigenvalues,min(eigenvalues)))); %%% Finds the second smallest eigenvalue (the Fiedler value, or measure of algebraic connectivity)

                    temporalvalues = eig(Temporal_Laplacian{session}{j});
                    temporalvalues(temporalvalues==min(temporalvalues)) = nan;
                    [TemporalFiedlerval, ~] = min(temporalvalues);
                    DendClust_Deg{session}(counter,1) = real(Fiedlerval);
                    DendClust_Deg{session}(counter,2) = real(TemporalFiedlerval);
                    DendClust_Deg{session}(counter,3) = real(SpatioTemporalFiedler{session}(j));
                    DendClust_Deg{session}(counter,4) = currentfile.Dendritic_Frequency(j);
                    DendClust_Deg{session}(counter,5) = nan;
                    DendClust_Deg{session}(counter,6) = length(currentfile.SpineDendriteGrouping{j});
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
    clear currentfile
end

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


if showfigs
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
else
end

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

fname = regexp(varargin{3}{1}, '[A-Z]{2,3}0+[0-9]+', 'match');
fname = fname{1};
fname = [fname, '_SpineCorrelationTimecourse'];
eval([fname, '= a;'])
cd('C:\Users\Komiyama\Desktop\Output Data');
save(fname, fname);