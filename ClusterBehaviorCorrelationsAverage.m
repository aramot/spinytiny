function ClusterBehaviorCorrelationsAverage(varargin)


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
ConDendCorrelationStatDataChoice = CorrelationBetweenMovementSpines;

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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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
[~,p] = corrcoef(xdata,ydata);
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