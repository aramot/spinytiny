function NewSpineAnalysis(varargin)

global gui_KomiyamaLabHub
experimentnames = varargin;

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
end

shuffnum = 1000;
bootstrpnum = shuffnum;
alphaforbootstrap = 0.05;
spine_enlargement_cutoff = 1.1;
spine_shrinkage_cutoff = 0.9;
distance_cutoff = 10;
min_distance_considered = distance_cutoff*2;
CoA_Cutoff = 0.3191;

for i = 1:length(experimentnames)
    targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
    load(targetfile)
    eval(['currentdata = ',targetfile, ';'])
    eval(['clear ', targetfile])
    
    NumFields{i} = length(currentdata.SpineDynamics);
    SpineDynamics{i} = currentdata.SpineDynamics;
    DendriteDynamics{i} =  currentdata.DendriteDynamics;
    AllDendriteDistances{i} = currentdata.AllDendriteDistances;
    SpineDendriteGrouping{i} = currentdata.SpineDendriteGrouping;
    AllMovementSpines{i} = currentdata.AllMovementSpines;
    AllMovementRanks{i} = currentdata.AllMovementRanks; 
    AllRewMovementSpines{i} = currentdata.AllRewMovementSpines;
    NumberofEarlyMovementRelatedSpines(1,i) = currentdata.NumberofEarlyMovementRelatedSpines;
    NumberofMidSessionMovementRelatedSpines(1,i) = currentdata.NumberofMidSessionMovementRelatedSpines;
    NumberofEarlierSessionMovementRelatedSpines(1,i) = currentdata.NumberofEarlierSessionMovementRelatedSpines;
    NumberofLateMovementRelatedSpines(1,i) = currentdata.NumberofLateMovementRelatedSpines;
    NumberofPersistentMovementRelatedSpines{i} = cell2mat(currentdata.NumberofPersistentMovementRelatedSpines);
    NumberofPersistentMovementSpinesClustered{i} = cell2mat(currentdata.NumberofPersistentMovementSpinesClustered);
    
    NewSpines{i} = currentdata.NewSpines';
    NewSpinesbyDendrite{i} = currentdata.NewSpinesbyDendrite;
    MiddleSessionNewSpines{i} = currentdata.MiddleSessionNewSpines;
    LateSessionNewSpines{i} = currentdata.LateSessionNewSpines;
    PersistentNewSpines{i} = cell2mat(currentdata.PersistentNewSpines');
    ClusteredNewSpines{i} = cell2mat(currentdata.ClusteredNewSpines(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpines, 'uni', false))));
    ClusteredNewSpinesbyDendrite{i} = currentdata.ClusteredNewSpinesbyDendrite;
    ElimSpines{i} = currentdata.ElimSpines';
    ElimSpinesbyDendrite{i} = currentdata.ElimSpinesbyDendrite; 
    AntiClusteredElimSpinesbyDendrite{i} = currentdata.AntiClusteredElimSpinesbyDendrite;
    
    AllSpineCorrelationsonLateSession{i} = currentdata.AllSpineCorrelationsonLateSession;
    AllSpineNoiseCorrelationsonLateSession{i} = currentdata.AllSpineNoiseCorrelationsonLateSession;

 
    NumberofClusteredMoveSpines{i} = cell2mat(currentdata.NumberofClusteredMoveSpines(~cell2mat(cellfun(@isempty, currentdata.NumberofClusteredMoveSpines, 'uni', false)))');
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
    ListofDendswithClusters{i} = currentdata.ListofDendswithClusters;
    ListofDendsThatAreEarlyMoveRelated{i} = currentdata.ListofDendsThatAreEarlyMoveRelated;
    ListofDendsThatAreLateMoveRelated{i} = currentdata.ListofDendsThatAreLateMoveRelated;
   
    NumberofNewSpines(1,i) = currentdata.NumberofNewSpines;
    NumberofElimSpines(1,i) = currentdata.NumberofElimSpines;
    NumberofNewSpinesThatAreMR(1,i) = currentdata.NumberofNewSpinesThatAreMR;
    NumberofNewSpinesThatArePreSR(1,i) = currentdata.NumberofNewSpinesThatArePreSR;
    NumberofNewSpinesThatAreSR(1,i) = currentdata.NumberofNewSpinesThatAreSR;
    NumberofNewSpinesThatAreRR(1,i) = currentdata.NumberofNewSpinesThatAreSR;
    NumberofElimSpinesThatWereMR(1,i) = currentdata.NumberofElimSpinesThatWereMR;
    NewSpineswithNoMoveSpinePartner(1,i) = currentdata.NewSpineswithNoMoveSpinePartner;
    NumberofMovementClusteredNewSpines(1,i) = currentdata.NumberofMovementClusteredNewSpines;
    NumberofMovementClusteredNewSpinesThatAreMR(1,i) = currentdata.NumberofMovementClusteredNewSpinesThatAreMR;
    FractionofNewMovementSpinesThatAreClustered(1,i) = currentdata.FractionofNewMovementSpinesThatAreClustered;
    ClusteredEarlyMoveSpines{i} = currentdata.ClusteredEarlyMoveSpines;
    
    NewSpineAllSpinesDistance{i} = currentdata.NewSpineAllSpinesDistance;
    NewSpineAllSpinesMidCorr{i} = currentdata.NewSpineAllSpinesMidCorr;
    NewSpineAllSpinesLateCorr{i} = currentdata.NewSpineAllSpinesLateCorr;
    NewSpineAllSpinesLateRawCorr{i} = currentdata.NewSpineAllSpinesLateRawCorr; 
    NewSpineAllSpinesLateNoiseCorr{i} = currentdata.NewSpineAllSpinesLateNoiseCorr;
    
    DistancesBetweenNewSpinesandNearestEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandNearestEarlyMovementSpines);
    LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions{i} = cell2mat(currentdata.LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions);
    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{i} = currentdata.NewSpinesCorrwithDistanceMatchedNonEarlyMRSs;
    FrequencyMatchedControlCorrelation{i} = currentdata.FrequencyMatchedControlCorrelation;
    MovementSpineDistanceMatchedControlCorrelation{i} = currentdata.MovementSpineDistanceMatchedControlCorrelation;
    TaskCorrelationofClusteredNewSpines{i} = cell2mat(currentdata.TaskCorrelationofClusteredNewSpines);
    NewSpinesCorrwithNearbyEarlyMRSs{i} = currentdata.NewSpinesCorrwithNearbyEarlyMRSs;
    TaskCorrelationofNearbyEarlyMRSs{i} = cell2mat(currentdata.TaskCorrelationofNearbyEarlyMRSs);
    MovementReliabilityofNearbyEarlyMRSs{i} = cell2mat(currentdata.MovementReliabilityofNearbyEarlyMRSs');
    MovementReliabilityofOtherMoveSpines{i} = cell2mat(currentdata.MovementReliabilityofOtherMoveSpines');
    DistancesBetweenNewSpinesandLateMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandMovementSpines);
    
    DistancetoHighCorrMovementSpines{i} = currentdata.DistancetoHighCorrMovementSpines;
    DistancetoEnlargedSpines{i} = currentdata.DistancetoEnlargedSpines;
    
    LateCorrofNewSpinesandMovementSpinefromLateSessions{i} = cell2mat(currentdata.LateCorrofNewSpinesandNearestMovementSpinefromLateSessions);
    NewSpinesCorrwithDistanceMatchedNonLateMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithDistanceMatchedNonLateMRSs);
    NewSpinesCorrwithNearbyLateMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithNearbyLateMRSs);
    TaskCorrelationofNearbyLateMRSs{i} = cell2mat(currentdata.TaskCorrelationofNearbyLateMRSs);
    MovementReliabilityofNearbyLateMRSs{i} = cell2mat(currentdata.MovementReliabilityofNearbyLateMRSs');
    
    DistancesBetweenElimSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandEarlyMovementSpines);
    CorrelationsofElimSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.CorrelationsofElimSpinesandEarlyMovementSpines);
    ElimSpinesCorrwithNearbyMRSs{i} = cell2mat(currentdata.ElimSpinesCorrwithNearbyMRSs);
    TaskCorrelationofNearbyEarlyMRSsforElimSp{i} = cell2mat(currentdata.TaskCorrelationofNearbyEarlyMRSsforElimSp);
    MovementReliabilityofNearbyEarlyMRSsforElimSp{i} = cell2mat(currentdata.MovementReliabilityofNearbyEarlyMRSsforElimSp');
    DistancesBetweenElimSpinesandMovementSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandMovementSpines);
    DistancesBetweenNewSpinesandRandomSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandRandomSpines);
    DistancesBetweenElimSpinesandRandomSpines{i} = cell2mat(currentdata.DistancesBetweenElimSpinesandRandomSpines);
    DistancesBetweenNewSpinesandShuffledEarlyMovementSpines{i} = cell2mat(cellfun(@cell2mat,currentdata.DistancesBetweenNewSpinesandShuffledEarlyMovementSpines(~cell2mat(cellfun(@isempty, currentdata.DistancesBetweenNewSpinesandShuffledEarlyMovementSpines, 'uni', false))),'uni', false));
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
    DistanceToMaxCorrPartner{i} = cell2mat(currentdata.DistanceToMaxCorrPartner');
    ElimSpinesMaxCorr{i} = cell2mat(currentdata.ElimSpinesMaxCorrelation');
    OtherSpinesMaxCorr{i} = cell2mat(currentdata.OtherSpinesMaxCorrelation');
    FractionofHCPsThatAreMR{i} = cell2mat(currentdata.FractionofHCPsThatAreMR');
    NewSpineMaxCorrPartnerEarlyMoveCorrelation{i} = cell2mat(currentdata.NewSpineMaxCorrPartnerEarlyMoveCorrelation);
    NewSpineMaxCorrPartnerLateMoveCorrelation{i} = cell2mat(currentdata.NewSpineMaxCorrPartnerLateMoveCorrelation);
    NewSpineMaxCorrPartnerEarlyMoveReliability{i} = cell2mat(currentdata.NewSpineMaxCorrPartnerEarlyMoveReliability');
    NewSpineMaxCorrPartnerLateMoveReliability{i} = cell2mat(currentdata.NewSpineMaxCorrPartnerLateMoveReliability');
    ElimSpineMaxCorrPartnerEarlyMoveReliability{i} = cell2mat(currentdata.ElimSpineMaxCorrPartnerEarlyMoveReliability');
    ElimSpineMaxCorrPartnerEarlyMoveCorrelation{i} = cell2mat(currentdata.ElimSpineMaxCorrPartnerEarlyMoveCorrelation);

    NewSpinesBehaviorCorrelation{i} = cell2mat(currentdata.NewSpinesBehaviorCorrelation');
    ElimSpinesBehaviorCorrelation{i} = cell2mat(currentdata.ElimSpinesBehaviorCorrelation');
    NonNewSpinesBehaviorCorrelationEarly{i} = cell2mat(currentdata.NonNewSpinesBehaviorCorrelationEarly)';
    NonNewSpinesBehaviorCorrelationLate{i} = cell2mat(currentdata.NonNewSpinesBehaviorCorrelationLate)';
    
    ClusteredNewSpineCorrwithDendrite{i} =   cell2mat(cellfun(@cell2mat,currentdata.ClusteredNewSpineCorrwithDendrite(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpineCorrwithDendrite, 'uni', false))),'uni', false));
    ClusteredMoveSpineCorrwithDendrite{i} =   cell2mat(cellfun(@cell2mat,currentdata.ClusteredMoveSpineCorrwithDendrite(~cell2mat(cellfun(@isempty, currentdata.ClusteredMoveSpineCorrwithDendrite, 'uni', false))),'uni', false));
    CoActiveClusterCorrwithDendrite{i} =  cell2mat(cellfun(@cell2mat,currentdata.CoActiveClusterCorrwithDendrite(~cell2mat(cellfun(@isempty, currentdata.CoActiveClusterCorrwithDendrite, 'uni', false))),'uni', false));

    ClusteredNewSpineCorrwithMovement{i} =  cell2mat(cellfun(@cell2mat,currentdata.ClusteredNewSpineCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpineCorrwithMovement, 'uni', false))),'uni', false));
    ClusteredMoveSpineCorrwithMovement{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusteredMoveSpineCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.ClusteredMoveSpineCorrwithMovement, 'uni', false))),'uni', false));
    CoActiveClusterCorrwithMovement{i} = cell2mat(cellfun(@cell2mat,currentdata.CoActiveClusterCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.CoActiveClusterCorrwithMovement, 'uni', false))),'uni', false));
    ClusteredNewSpineCorrwithSuccess{i} =  cell2mat(cellfun(@cell2mat,currentdata.ClusteredNewSpineCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpineCorrwithSuccess, 'uni', false))),'uni', false));
    ClusteredMoveSpineCorrwithSuccess{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusteredMoveSpineCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.ClusteredMoveSpineCorrwithSuccess, 'uni', false))),'uni', false));
    CoActiveClusterCorrwithSuccess{i} = cell2mat(cellfun(@cell2mat,currentdata.CoActiveClusterCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.CoActiveClusterCorrwithSuccess, 'uni', false))),'uni', false));
    
    AllMoveCentricClusterCorrelationbyNewSpines{i} = currentdata.AllMoveCentricClusterCorrelationsbyNewSpine;
%     MoveCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricClusterCorrelation, 'uni', false))),'uni', false));
    MoveCentricClusterCorrelation{i} = currentdata.MoveCentricClusterCorrelation;
    MoveCentricDistanceMatchedCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedCorrelation, 'uni', false))),'uni', false));
    MoveCentricDistanceMatchedCorrelationforMRS{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedCorrelationforMRS(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedCorrelationforMRS, 'uni', false))),'uni', false));
    MoveCentricCorrelationofAllOtherSpines{i} = cell2mat(currentdata.MoveCentricCorrelationofAllOtherSpines');
    FailureCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat, currentdata.FailureCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.FailureCentricClusterCorrelation, 'uni', false))), 'uni', false));
    MoveCentricAntiClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricAntiClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricAntiClusterCorrelation, 'uni', false))),'uni', false));
    MoveCentricDistanceMatchedtoAntiClustCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedtoAntiClustCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedtoAntiClustCorrelation, 'uni', false))),'uni', false));
    MoveCentricFrequencyMatchedCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricFrequencyMatchedCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricFrequencyMatchedCorrelation, 'uni', false))),'uni', false));
    
    AllClusterCorrelationsbyNewSpine{i} = currentdata.AllClusterCorrelationsbyNewSpine;
    AllMoveCentricClusterCorrelationsbyNewSpine{i} = currentdata.AllMoveCentricClusterCorrelationsbyNewSpine;
    
    CombinedClusterActivityCorrwithMovement{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithMovement, 'uni', false))),'uni', false));
    CombinedClusterActivityCorrwithSuccess{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithSuccess, 'uni', false))),'uni', false));
    ClusterMovementReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterMovementReliability, 'uni', false))),'uni', false));
    ClusterSuccessReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterSuccessReliability, 'uni', false))),'uni', false));
    ControlPairMovementReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairMovementReliability, 'uni', false))), 'uni', false));
    ControlPairSuccessReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairSuccessReliability, 'uni', false))), 'uni', false));
    
    ModelMovement{i} = currentdata.ModelMovement;
    CorrelationofMovementswithCoActiveClusterActivity{i} = currentdata.CorrelationofMovementswithCoActiveClusterActivity';
        CorrelationofMovementswithCoActiveClusterActivitybyCluster{i} = currentdata.CorrelationofMovementswithCoActiveClusterActivitybyCluster';
    CoActiveClusterMovementsCorrelationwithModelMovement{i} = currentdata.CoActiveClusterMovementsCorrelationwithModelMovement';
        CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.CoActiveClusterMovementsCorrelationwithModelMovementbyCluster';
    MovementCorrelationwithMRSonlyActivity{i} = currentdata.MovementCorrelationwithMRSonlyActivity';
        MovementCorrelationwithMRSonlyActivitybyCluster{i} = currentdata.MovementCorrelationwithMRSonlyActivitybyCluster';
    MRSOnlyMovementsCorrelationwithModelMovement{i} = currentdata.MRSActivityOnlyMovementsCorrelationwithModelMovement';
        MRSOnlyMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.MRSActivityOnlyMovementsCorrelationwithModelMovementbyCluster';
    MovementCorrelationwithNSonlyActivity{i} = currentdata.MovementCorrelationwithNSonlyActivity';
        MovementCorrelationwithNSonlyActivitybyCluster{i} = currentdata.MovementCorrelationwithNSonlyActivitybyCluster';
    NSActivityOnlyMovementsCorrelationwithModelMovement{i} = currentdata.NSActivityOnlyMovementsCorrelationwithModelMovement';
        NSActivityOnlyMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.NSActivityOnlyMovementsCorrelationwithModelMovementbyCluster';

    MovementCorrelationofAllOtherMovements{i} = currentdata.MovementCorrelationofAllOtherMovements';
    AllOtherMovementsCorrelationwithModelMovement{i} = currentdata.AllOtherMovementsCorrelationwithModelMovement;
    CorrelationofMovementswithCoActiveFMControlActivity{i} = currentdata.CorrelationofMovementswithCoActiveFMControlActivity';
        CorrelationofMovementswithCoActiveFMControlActivitybyCluster{i} = currentdata.CorrelationofMovementswithCoActiveFMControlActivitybyCluster';
    FMControlMovementsCorrelationwithModelMovement{i} = currentdata.FMControlMovementsCorrelationwithModelMovement;
        FMControlMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.FMControlMovementsCorrelationwithModelMovementbyCluster;
    StereotypyDiagnostics{i} = currentdata.StereotypyDiagnostics;
    CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{i} = currentdata.CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster;
    MRSDMControlMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.MRSDMControlMovementsCorrelationwithModelMovementbyCluster;
    CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster{i} = currentdata.CorrelationofMovementswithCoActiveNSDMControlActivitybyCluster;
    NSDMControlMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.NSDMControlMovementsCorrelationwithModelMovementbyCluster;
    CorrelationofMovementswithAllOtherSpineCoActivity{i} = currentdata.CorrelationofMovementswithAllOtherSpineCoActivity;
    AllOtherSpineCoActivityMovementsCorrelationwithModelMovement{i} = currentdata.AllOtherSpineCoActivityMovementsCorrelationwithModelMovement;
    
    HCPClusteredNewSpineCorrwithMovement{i} = cell2mat(currentdata.HCPClusteredNewSpineCorrwithMovement);
    HCPClusteredNewSpineCorrwithSuccess{i} = cell2mat(currentdata.HCPClusteredNewSpineCorrwithSuccess);
    HCPCorrwithMovement{i} = cell2mat(currentdata.HCPCorrwithMovement);
    HCPCorrwithSuccess{i} = cell2mat(currentdata.HCPCorrwithSuccess);
    CoActiveHCPClusterCorrwithMovement{i} = cell2mat(currentdata.CoActiveHCPClusterCorrwithMovement);
    CoActiveHCPClusterCorrwithSuccess{i} = cell2mat(currentdata.CoActiveHCPClusterCorrwithSuccess);
    MoveCentricHCPClusterCorrelation{i} = cell2mat(currentdata.MoveCentricHCPClusterCorrelation);
    MovementCorrelationwithCoActiveHCPClusters{i} = cell2mat(currentdata.MovementCorrelationwithCoActiveHCPClusters);
    MovementCorrelationofAllOtherNonHCPMovements{i} = cell2mat(currentdata.MovementCorrelationofAllOtherNonHCPMovements);
    MovementCorrelationofHCPComparatorSpines{i} = cell2mat(currentdata.MovementCorrelationofHCPComparatorSpines);
    
    MovementCorrelationwithCoActiveAntiClusters{i} = cell2mat(currentdata.MovementCorrelationwithCoActiveAntiClusters');
    CoActiveAntiClusterMovementsCorrelationwithModelMovement{i} = cell2mat(currentdata.CoActiveAntiClusterMovementsCorrelationwithModelMovement');
    MovementCorrelationofAllOtherMovementsElimVersion{i} = cell2mat(currentdata.MovementCorrelationofAllOtherMovementsElimVersion');
    AllOtherMovementsCorrelationwithModelMovementElimVersion{i} = cell2mat(currentdata.AllOtherMovementsCorrelationwithModelMovementElimVersion');
    MovementCorrelationofFrequencyMatchedPairsElimVersion{i} = cell2mat(currentdata.MovementCorrelationofFrequencyMatchedPairsElimVersion');
    FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion{i} = cell2mat(currentdata.FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion');

    ClusteredMoveSpineFrequency{i} = cell2mat(currentdata.ClusteredMoveSpineFrequency');
    ClusteredNewSpineFrequency{i} = cell2mat(currentdata.ClusteredNewSpineFrequency');
    OtherSpineFrequencyOnDendswithClusters{i} = cell2mat(currentdata.OtherSpineFrequencyOnDendswithClusters');
    OtherSpineFrequencyOnDendswithoutClusters{i} = cell2mat(currentdata.OtherSpineFrequencyOnDendswithoutClusters');
    ClusteredMovementSpineDeltaFrequency{i} = currentdata.ClusteredMovementSpineDeltaFrequency';
    OtherSpineDeltaFrequencyOnDendswithClusters{i} = cell2mat(currentdata.OtherSpineDeltaFrequencyOnDendswithClusters');
    OtherSpineDeltaFrequencyOnDendswithoutClusters{i} = cell2mat(currentdata.OtherSpineDeltaFrequencyOnDendswithoutClusters');

    ClusteredMoveSpineAmplitude{i} = cell2mat(currentdata.ClusteredMoveSpineAmplitude);
    ClusteredNewSpineAmplitude{i} = cell2mat(currentdata.ClusteredNewSpineAmplitude);
    OtherSpineAmplitudeOnDendswithClusters{i} = cell2mat(currentdata.OtherSpineAmplitudeOnDendswithClusters);
    OtherSpineAmplitudeOnDendswithoutClusters{i} = cell2mat(currentdata.OtherSpineAmplitudeOnDendswithoutClusters);
    ClusteredMovementSpineDeltaAmplitude{i} = currentdata.ClusteredMovementSpineDeltaAmplitude;
    OtherSpineDeltaAmplitudeOnDendswithClusters{i} = cell2mat(currentdata.OtherSpineDeltaAmplitudeOnDendswithClusters);
    OtherSpineDeltaAmplitudeOnDendswithoutClusters{i} = cell2mat(currentdata.OtherSpineDeltaAmplitudeOnDendswithoutClusters);

    AllInterSpineDistancesList{i} = currentdata.AllInterSpineDistancesList;
    AllSpinesEarlyCoActiveRates{i} = currentdata.AllSpinesEarlyCoActiveRates;
    AllSpinesEarlyCoActiveRatesGeoNormalized{i} = currentdata.AllSpinesEarlyCoActiveRatesGeoNormalized;
    AllSpinesLateCoActiveRates{i} = currentdata.AllSpinesLateCoActiveRates;
    AllSpinesLateCoActiveRatesGeoNormalized{i} = currentdata.AllSpinesLateCoActiveRatesGeoNormalized;
    NewSpineAllCoActiveRates{i} = currentdata.NewSpineAllCoActiveRates;     %%% These variables (compared to the below "ClustCoActiveRate") include all spine pair combos, not just MRSs
    NewSpineAllCoActiveRatesNormalized{i} = currentdata.NewSpineAllCoActiveRatesNormalized; %%% Normalization against the event rate of the NS only
    NewSpineAllCoActiveRatesGeoNormalized{i} = currentdata.NewSpineAllCoActiveRatesGeoNormalized;   %%% Geometric normalization for both spines, instead of just by the new spine
    ClustCoActiveRate{i} = currentdata.ClustCoActiveRate;
    ClustIntegratedCoactivity{i} = currentdata.ClustIntegratedCoactivity;
    FractionofClustActivityDuringMovements{i} = currentdata.FractionofClustActivityDuringMovements;
    FMcompCoActiveRate{i} = currentdata.FMcompCoActiveRate;
    MRSDMcompCoActiveRate{i} = currentdata.MRSDMcompCoActiveRate;
    NSDMcompCoActiveRate{i} = currentdata.NSDMcompCoActiveRate;
    NSonlyEventRate{i} = currentdata.NSonlyEventRate;
    NSonlyIntegratedActivity{i} = currentdata.NSonlyIntegratedActivity;
    FractionofNSActivityDuringMovements{i} = currentdata.FractionofNSActivityDuringMovements;
    FractionofMRSActivityDuringMovements{i} = currentdata.FractionofMRSActivityDuringMovements;
    
    ClustActivityStartRelativetoMovement{i} = currentdata.ClustActivityStartRelativetoMovement;
    ClustActivityStartNormalizedtoMovementLength{i} = currentdata.ClustActivityStartNormalizedtoMovementLength;
    StandardDeviationofClustActivityOnset{i} = currentdata.StandardDeviationofClustActivityOnset;
    StandardDeviationofNormClustActivityOnset{i} = currentdata.StandardDeviationofClustActivityOnset;
    LeverPositionatClustActivityOnset{i} = currentdata.LeverPositionatClustActivityOnset;
    LeverVelocityatClustActivityOnset{i} = currentdata.LeverVelocityatClustActivityOnset;
    LeverVelocityatRandomLagsfromOnset{i} = currentdata.LeverVelocityatRandomLagsfromOnset;
    LeverSlopeTraces{i} = currentdata.LeverSlopeTraces;
    ShuffledClustActivityStart{i} = currentdata.ShuffledClustActivityStart;
    ShuffledActivityStartNormalizedtoMovementLength{i} = currentdata.ShuffledActivityStartNormalizedtoMovementLength;
    StandardDeviationofShuffledActivityOnset{i} = currentdata.StandardDeviationofShuffledActivityOnset;
    StandardDeviationofNormShuffledActivityOnset{i} = currentdata.StandardDeviationofNormShuffledActivityOnset;
    LeverPositionatShuffledActivityOnset{i} = currentdata.LeverPositionatShuffledActivityOnset;
    LeverVelocityatShuffledActivityOnset{i} = currentdata.LeverVelocityatShuffledActivityOnset;
    LeverVelocityatShuffledMRSActivityOnset{i} = currentdata.LeverVelocityatShuffledMRSActivityOnset;
    LeverVelocityatShuffledNSActivityOnset{i} = currentdata.LeverVelocityatShuffledNSActivityOnset;
    FMActivityStartRelativetoMovement{i} = currentdata.FMActivityStartRelativetoMovement;
    MRSDMActivityStartRelativetoMovement{i} = currentdata.MRSDMActivityStartRelativetoMovement;
    NSDMActivityStartRelativetoMovement{i} = currentdata.NSDMActivityStartRelativetoMovement;
    NSonlyActivityStartRelativetoMovement{i} = currentdata.NSonlyActivityStartRelativetoMovement;
    StandardDeviationofNSOnlyActivityOnset{i} = currentdata.StandardDeviationofNSOnlyActivityOnset;
    LeverPositionatNSOnlyActivityOnset{i} = currentdata.LeverPositionatNSOnlyActivityOnset;
    LeverVelocityatNSOnlyActivityOnset{i} = currentdata.LeverVelocityatNSOnlyActivityOnset;
    LeverVelocityatMRSOnlyActivityOnset{i} = currentdata.LeverVelocityatMRSOnlyActivityOnset;
    MeanSpeedofActMovementPeriods{i} = currentdata.MeanSpeedofActMovementPeriods;
    MeanSpeedofOtherMovementPeriods{i} = currentdata.MeanSpeedofOtherMovementPeriods;
    
    MovementsEncodedbySeedlingMRS{i} = currentdata.MovementsEncodedbySeedlingMRS;
    MovementswithClusteredCoActivity{i} = currentdata.MovementswithClusteredCoActivity;
    MovementswithClusteredCoActivitybyCluster{i} = currentdata.MovementswithClusteredCoActivitybyCluster;
    MedianMovementCorrelationbyNewSpine{i} = currentdata.MedianMovementCorrelationbyNewSpine;
    MovementswithFMControlCoActivity{i} = currentdata.MovementswithFMControlCoActivity;
    MovementswithMRSOnlyActivity{i} = currentdata.MovementswithMRSOnlyActivity;
    MovementswithNSOnlyActivity{i} = currentdata.MovementswithNSOnlyActivity;
    MovementswithMRSDMCoActivity{i} = currentdata.MovementswithMRSDMCoActivity;
    MovementswithAllOtherSpineCoActivity{i} = currentdata.MovementswithAllOtherSpineCoActivity;
    WithoutGroupMovements{i} = currentdata.WithoutGroupMovements;
    
    NumberofMovementswithClusterCoActivitybyCluster{i} = currentdata.NumberofMovementswithClusterCoActivitybyCluster;
    FractionofMovementswithClusterCoActivitybyCluster{i} = currentdata.FractionofMovementswithClusterCoActivitybyCluster;
    NumberofMovementswithAnyClusterCoActivity{i} = currentdata.NumberofMovementswithAnyClusterCoActivity;
    FractionofMovementswithAnyClusterCoActivity{i} = currentdata.FractionofMovementswithAnyClusterCoActivity;
    
    IsMovementRewardedLate{i} = currentdata.IsMovementRewardedLate;
    IsCoActiveMovementRewarded{i} = currentdata.IsCoActiveMovementRewarded;
    ChanceRewardedLevel{i} = currentdata.ChanceRewardedLevel;
    IsMoveOnlyRewarded{i} = currentdata.IsMoveOnlyRewarded;
    MoveOnlyChanceRewardedLevel{i} = currentdata.MoveOnlyChanceRewardedLevel;
    IsMRSDMCoActiveMovementRewarded{i} = currentdata.IsMRSDMCoActiveMovementRewarded;
    MRSDMChanceRewardedLevel{i} = currentdata.MRSDMChanceRewardedLevel;
    IsNewOnlyRewarded{i} = currentdata.IsNewOnlyRewarded;
    NewOnlyChanceRewardedLevel{i} = currentdata.NewOnlyChanceRewardedLevel;
    IsNSDMCoActiveMovementRewarded{i} = currentdata.IsNSDMCoActiveMovementRewarded;
    NSDMChanceRewardedLevel{i} = currentdata.NSDMChanceRewardedLevel;
    IsCompCoActiveMovementRewarded{i} = currentdata.IsCompCoActiveMovementRewarded;
    FMChanceRewardedLevel{i} = currentdata.FMChanceRewardedLevel;
    
    DotProductofCoActivePeriodsDuringMovement{i} = currentdata.DotProductofCoActivePeriodsDuringMovement;
    DotProductofFMCoActivePeriodsDuringMovement{i} = currentdata.DotProductofFMCoActivePeriodsDuringMovement;
    DotProductofNSDMCoActivePeriodsDuringMovement{i} = currentdata.DotProductofNSDMCoActivePeriodsDuringMovement;
    DotProductofNSOnlyActivePeriodsDuringMovement{i} = currentdata.DotProductofNSOnlyActivePeriodsDuringMovement;
    DotProductofMRSDMCoActivePeriodsDuringMovement{i} = currentdata.DotProductofMRSDMCoActivePeriodsDuringMovement;
    DotProductofMRSOnlyPeriodsDuringMovement{i} = currentdata.DotProductofMRSOnlyPeriodsDuringMovement;
    DotProductofCoActivePeriodsDuringCRMovement{i} = currentdata.DotProductofCoActivePeriodsDuringCRMovement;
    DotProductofCoActivePeriodsDuringStillness{i} = currentdata.DotProductofCoActivePeriodsDuringStillness;
    DotProductofFMCoActivePeriodsDuringCRMovement{i} = currentdata.DotProductofFMCoActivePeriodsDuringCRMovement;
    
    ChanceLevelofCoactivityMovementOverlap{i} = currentdata.ChanceLevelofCoactivityMovementOverlap;
    ChanceLevelofFMCoActivitywithmovement{i} = currentdata.ChanceLevelofFMCoActivitywithmovement;
    ChanceLevelofNSDMCoActivitywithMovement{i} = currentdata.ChanceLevelofNSDMCoActivitywithMovement;
    ChanceLevelofNSOnlyActivitywithMovement{i} = currentdata.ChanceLevelofNSOnlyActivitywithMovement;
    ChanceLevelofMRSDMCoActivitywithMovement{i} = currentdata.ChanceLevelofMRSDMCoActivitywithMovement;
    ChanceLevelofMRSOnlyActivitywithMovement{i} = currentdata.ChanceLevelofMRSOnlyPeriodsDuringMovement;
    ChanceLevelofCoActivityCRMovementOverlap{i} = currentdata.ChanceLevelofCoActivityCRMovementOverlap;
    ChanceLevelofFMCoActivityCRMovementOverlap{i} = currentdata.ChanceLevelofFMCoActivityCRMovementOverlap;
    
    DotProductofCoActivePeriodsDuringStillness{i} = currentdata.DotProductofCoActivePeriodsDuringStillness;
    
    IsMovementRewardedEarly{i} = currentdata.IsMovementRewardedEarly;
    IsCoActiveAntiClusterMovementRewarded{i} = currentdata.IsCoActiveAntiClusterMovementRewarded;
    ChanceRewardedLevelElimVersion{i} = cell2mat(currentdata.ChanceRewardedLevelElimVersion');
    
    DendsWithBothDynamics{i} = cell2mat(currentdata.DendsWithBothDynamics);
    DendsWithBothClustDynamics{i} = cell2mat(currentdata.DendsWithBothClustDynamics);
    
    CoActivityDifferenceOptimizationCurve{i} = currentdata.CoActivityDifferenceOptimizationCurve;
    
    AllSpineVolumeData{i} = currentdata.AllSpineVolumeData;
    AllSpineFrequency{i} = currentdata.AllSpineFrequency;
%     AllDeltaSpineVolume{i} = currentdata.AllDeltaSpineVolume;
    ClusteredMovementSpineVolume{i} = currentdata.ClusteredMovementSpineVolume;
    
    NewSpineAllDistancestoEarlyMovementSpines{i} = currentdata.NewSpineAllDistancestoEarlyMovementSpines;
    SimilarityofClusteredMovementwithSeedlingMRSMovement{i} = currentdata.SimilarityofClusteredMovementwithSeedlingMRSMovement;
    AllCoActivityDotProductsforDistanceMeasurement{i} = currentdata.AllCoActivityDotProductsforDistanceMeasurement;
    AllCoActivityChanceLevelDotProductsforDistanceMeasurement{i} = currentdata.AllCoActivityChanceLevelDotProductsforDistanceMeasurement;

    FractionofNewSpinesMeetingClusterCriteria{i} = currentdata.FractionofNewSpinesMeetingClusterCriteria;
    SimClusterCorr{i} = currentdata.SimClusterCorr;
    
    TransientNewSpines{i} = currentdata.TransientNewSpines;
    AllTransientNewSpinesDistance{i} = currentdata.AllTransientNewSpinesDistance;
    AllTransientNewSpinesMidCorr{i} = currentdata.AllTransientNewSpinesMidCorr;
    TransientSpineCoActiveRate{i} = currentdata.TransientSpineCoActiveRate;
    TransientSpineCoActiveRateNormalized{i} = currentdata.TransientSpineCoActiveRateNormalized;
    TransientSpineCoActiveRateGeoNormalized{i} = currentdata.TransientSpineCoActiveRateGeoNormalized;
    NewSpineMidCoActiveRate{i} = currentdata.NewSpineMidCoActiveRate;
    NewSpineMidCoActiveRateNormalized{i} = currentdata.NewSpineMidCoActiveRateNormalized;
    NewSpineMidCoActiveRateGeoNormalized{i} = currentdata.NewSpineMidCoActiveRateGeoNormalized;
    TransientNewSpinesFrequency{i} = currentdata.TransientNewSpinesFrequency;
    NewSpineMidFrequency{i} = currentdata.NewSpineMidFrequency;
    
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


%==========================================================================

%==========================================================================

AllDendriteLengths = []; 
DendriteswithNewSpines = []; 
NumberofNewSpinesperDendrite = []; 
NStoNSDist = []; NStoNSCoA = []; 

AllNoiseCorr = [];HighCorrDistances = []; EnlargedSpinesDistances = []; 
NStoAllSpineMoveRanks = []; AllSeedlingMovCorr = []; DotProducts = []; ChanceDotProducts = [];AllMMCorr = []; WithinMovCorr = []; FractionofMovementsEncoded = [];IsRew = []; IsChanceRew = []; AllCoARates = []; AllLeverVelocitySD = [];
nMRSTransDistances = []; MRSTransDistances = []; AllTransCorr = []; nMRSTransCoA = []; MRSTransCoA = [];
AllTransDistancesbyField = cell(1,sum(cell2mat(NumFields))); AllTransCorrbyField = cell(1,sum(cell2mat(NumFields))); AllTransCoAbyField = cell(1,sum(cell2mat(NumFields)));
transientnewspines_count = 0;

AllEarlyMRSs = []; AllLateMRSs = []; 
EarlyMRS_ClosestNS = []; EarlyMRSVolumeChanges = [];
MRSDensity_by_Dendrite = []; nonMRSDensity_by_Dendrite = []; FractionMRSsonDendswithNS = []; FractionMRSsonDendswithoutNS = []; 
nonNSClosestEarlyMRS =[]; nonNSClosestEarlynonMRS = []; nonNS_Range = []; nonNS_NearbySpineCount = []; nonNS_NearbySpineDensity = []; nonNSEarlyMRSEnvironment = []; nonNSEarlynonMRSEnvironment = []; 

allspinecorrlist = []; allspinedistlist = [];
NStoAllSpinesDistances = []; AllEarlyMRSwrtNSs = []; AllPrevSeshMRSwrtNSs = []; AllLateMRSwrtNSs = [];
AllNewSpinetoEarlyMRSDistances = []; AllNewSpinetoMRSDistances = []; AllNewSpinetonMRSDistances = []; NSAllSpineDensity = []; NSMRSDensity = []; NSnonMRSDensity = []; ClosestEarlyMRS = []; ClosestEarlynonMRS = []; ClosestPrevSeshMRS = []; ClosestLateMRS = []; ClosestPersMRS = []; ClosestGainedMRS = []; PrevSeshMRSdistlistwrtNS = []; 
nonNSMRSDensity = []; nonNSnonMRSDensity = []; 
Shuffled_NSMRSDensity = []; Shuffled_NSnonMRSDensity = []; Shuffled_NSAllSpineDensity = []; 
shuff_dist_considered_list = []; NSallspinewindows = []; 
NS_Range = []; NS_NearbySpineCount = []; 
NS_NearbySpineDensity = []; NearbyEarlyMRSEnvironment = []; NearbyEarlynonMRSEnvironment = []; NearbyPrevSeshMRSEnvironment = []; NearbyLateMRSEnvironment = []; NearbyPersMRSEnvironment = [];
corrlist = []; rawcorrlist = []; midcorrlist = []; midNSMRSCoAlist = []; midNSMRSdistlist = []; midNSnMRSCoAlist = []; midNSnMRSdistlist = []; 
noisecorrlist = []; nonMRSdistlist = []; nonMRScorrlist = []; nonMRSnoisecorrlist = []; 

GainedLostPersDistList = []; persistentMRSs = []; gainedMRSs = []; lostMRSs = []; 

ClosestEnlargedSpineList = []; ClosestEnlargedMRSList = []; ClosestEnlargedPersMRSList = []; ClosestEnlargedGainedMRSList = [];
CorrwithClosestEnlargedSpine = []; FractionEnlargedSpinesThatAreMRSs = [];FractionofSpinesThatAreEnlarged = []; 
distlistbyfield = cell(1,sum(cell2mat(NumFields))); corrlistbyfield = cell(1,sum(cell2mat(NumFields))); nonMRSdistlistbyfield = cell(1,sum(cell2mat(NumFields))); nonMRScorrlistbyfield = cell(1,sum(cell2mat(NumFields)));
middistlistbyfield = cell(1,sum(cell2mat(NumFields))); midcorrlistbyfield = cell(1,sum(cell2mat(NumFields))); midCoAlistbyfield = cell(1,sum(cell2mat(NumFields)));
MRScoAlist = []; nonMRScoAlist = []; 
CoARatewithClosestEnlargedSpine = [];
AllVolumeChangeswrtNS = []; AllEarlyMRSVolumeChangeswrtNS = []; AllPlasticityIndiceswrtNS = []; EarlyMRSPlasticityDistList = []; EarlyMRSPlasticityIndexwrtNS = []; EarlyMRSDepressionIndexwrtNS = []; 
AllLateMRSVolumeChangeswrtNS = []; LateMRSPlasticityDistList = []; LateMRSPlasticityIndexwrtNS = []; 
NumberofNearbyEnlargedSpines = []; NumberofNearbyEnlargedMRSs = [];
EarlynonMRSPlasticityIndexwrtNS = []; EarlynonMRSDepressionIndexwrtNS = []; EarlynonMRSPlasticityDistList = []; 
SpineDensity = []; MRSDensity = [];

fieldcount = 1;
selectedanimals = 1:length(varargin);
% selectedanimals = [5,18];

for animal = selectedanimals
    for field = 1:length(NewSpines{animal})
        %==================================================================
        % Define Movement-Related Spines
        earlyMRSs = AllMovementSpines{animal}{field}(:,1);
        earlyMovRanks = AllMovementRanks{animal}{field}(:,1);
        if size(AllMovementSpines{animal}{field},2) > 2
            isThreeSessions = 1;
        else
            isThreeSessions = 0;
        end
        if isThreeSessions
            midMRSs = logical(AllMovementSpines{animal}{field}(:,2));
            lateMRSs = logical(AllMovementSpines{animal}{field}(:,end));
            %%% Need to remove eliminated spines to make this the same
            %%% size as variables from "cluster" code
            lateMRSs(ElimSpines{animal}{field}) = 0;
        else
            midMRSs = false(size(AllMovementSpines{animal}{field},1),1);
            lateMRSs = logical(AllMovementSpines{animal}{field}(:,end));
            lateMRSs(ElimSpines{animal}{field}) = 0;
        end
        %%% Exclude New Spines
        earlyMRSs(NewSpines{animal}{field}) = 0;
        midMRSs(MiddleSessionNewSpines{animal}{field}) = 0;
        
        AllEarlyMRSs = [AllEarlyMRSs; earlyMRSs];
        AllLateMRSs = [AllLateMRSs; lateMRSs];

        MRSs_to_use = lateMRSs;
%         if ~any(MRSs_to_use)
%             continue
%         end
        %==============================================================
        % Find New Spine positions (by dendrite); when there is more than one new spine on a dendrite, 
        % distance relationships can be confounded, such that spines that
        % are distant from one NS can be close to another, and vice-versa.
        % As such, it's necessary to break down these situations, and
        % assign each non-NS to its closest NS in order to make accurate
        % claims about any distance relationship. Note: this doesn't apply 
        % to anything that describes, e.g., the coactivity between two
        % designated spines, but instead only to those features that rely
        % on the "proximity to a NS" as the central dependent variable
        NonNSComparisonSpinestoUse = ones(1,length(earlyMRSs));
        if ~isempty(NewSpines{animal}{field})
            DendswithNSs = cellfun(@any, cellfun(@(x) ismember(NewSpines{animal}{field},x), SpineDendriteGrouping{animal}{field}, 'uni', false));
            DendLengthStarters = cellfun(@(x) x(1), SpineDendriteGrouping{animal}{field}(DendswithNSs))';
            NumNSsonDends = cellfun(@sum, cellfun(@(x) ismember(NewSpines{animal}{field},x), SpineDendriteGrouping{animal}{field}, 'uni', false));
            tempdist = AllDendriteDistances{animal}{field};
            tempdist(1:size(tempdist,1)+1:numel(tempdist)) = 0;
            DendsDivided = cellfun(@(x) tempdist(x(1:end),x(1:end)), SpineDendriteGrouping{animal}{field}, 'uni', false);
            SpinePosbyDend = cellfun(@(x) x(1,:),DendsDivided, 'uni', false);
            SpineVol = AllSpineVolumeData{animal}{field}(:,end)./AllSpineVolumeData{animal}{field}(:,1);
            SpineVol(NewSpines{animal}{field},:) = nan;
            SpineVol(SpineVol==Inf) = NaN; SpineVol(SpineVol==-Inf) = NaN;
            
            for d = 1:length(SpinePosbyDend)
                if NumNSsonDends(d) > 1
                    spinesonthisdend = SpineDendriteGrouping{animal}{field}{d};
                    NSsonthisDend = NewSpines{animal}{field}(ismember(NewSpines{animal}{field},SpineDendriteGrouping{animal}{field}{d}));
                    thisdenddistances = AllDendriteDistances{animal}{field}(spinesonthisdend(1):spinesonthisdend(end), spinesonthisdend(1):spinesonthisdend(end)); thisdenddistances(1:size(thisdenddistances,1)+1:numel(thisdenddistances)) = 0;
                    NS_locs = thisdenddistances(1,NSsonthisDend-spinesonthisdend(1)+1);
                    dendlength = max(AllDendriteDistances{animal}{field}(spinesonthisdend(1),:));
                    nonNSsonthisDend = setdiff(SpineDendriteGrouping{animal}{field}{d},NSsonthisDend);
                    MRSsonthisDend = earlyMRSs(spinesonthisdend); MRSsonthisDend(NSsonthisDend-spinesonthisdend(1)+1) = 0;
                    NumberofNewSpinesperDendrite = [NumberofNewSpinesperDendrite, NumNSsonDends(d)];
                    MRSDensity_by_Dendrite = [MRSDensity_by_Dendrite; sum(MRSsonthisDend)./dendlength];
                    FractionMRSsonDendswithNS = [FractionMRSsonDendswithNS; sum(MRSsonthisDend)/length(MRSsonthisDend)];
                    nonMRSsonthisDend = ~earlyMRSs(spinesonthisdend);
                    nonMRSDensity_by_Dendrite = [nonMRSDensity_by_Dendrite; sum(nonMRSsonthisDend)./dendlength];
                    [val,ind] = min(cell2mat(arrayfun(@(x) AllDendriteDistances{animal}{field}(x,NSsonthisDend), nonNSsonthisDend, 'uni', false)'),[],2); %%% Find the closest NS, which is returned as an ordinal list of the new spines (1,2...n) that correspond to their place in the 'NSsonthisDend' list
                    
                    representedNSs = unique(ind); 
                    for rn = 1:length(representedNSs)
                        GainedLostPersDistList = [GainedLostPersDistList; val(ind == representedNSs(rn))];
                        persistentMRSs = [persistentMRSs; earlyMRSs(nonNSsonthisDend(ind == representedNSs(rn))) & lateMRSs(nonNSsonthisDend(ind == representedNSs(rn)))];
                        gainedMRSs = [gainedMRSs; diff([earlyMRSs(nonNSsonthisDend(ind == representedNSs(rn))), lateMRSs(nonNSsonthisDend(ind == representedNSs(rn)))],[],2)>0];
                        lostMRSs = [lostMRSs; diff([(earlyMRSs(nonNSsonthisDend(ind == representedNSs(rn)))),lateMRSs(nonNSsonthisDend(ind == representedNSs(rn)))],[],2)<0];
                        
                        earlyMRSsbeingconsidered = find(earlyMRSs(nonNSsonthisDend(ind == representedNSs(rn))));   %%% This might appear to return weird indices, (i.e. the labels are no longer consistent with the original MRS numbers!) BUT this indexing system is consistent 
                        earlynonMRSsbeingconsidered = find(~earlyMRSs(nonNSsonthisDend(ind == representedNSs(rn))));
                        lateMRSsbeingconsidered = find(lateMRSs(nonNSsonthisDend(ind == representedNSs(rn))));
                        SpineVolsbeingconsidered = SpineVol(nonNSsonthisDend(ind == representedNSs(rn)));
                        AllEarlyMRSVolumeChangeswrtNS = [AllEarlyMRSVolumeChangeswrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)];
                        currentdistances = val(earlyMRSsbeingconsidered);
                        EarlyMRSPlasticityDistList = [EarlyMRSPlasticityDistList; val(earlyMRSsbeingconsidered)];
                        EarlyMRSPlasticityIndexwrtNS = [EarlyMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)>spine_enlargement_cutoff];
                        EarlyMRSDepressionIndexwrtNS = [EarlyMRSDepressionIndexwrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)<spine_shrinkage_cutoff];
                        EarlynonMRSPlasticityIndexwrtNS = [EarlynonMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(earlynonMRSsbeingconsidered)>spine_enlargement_cutoff];
                        EarlynonMRSDepressionIndexwrtNS = [EarlynonMRSDepressionIndexwrtNS; SpineVolsbeingconsidered(earlynonMRSsbeingconsidered)<spine_shrinkage_cutoff];
                        EarlynonMRSPlasticityDistList = [EarlynonMRSPlasticityDistList; val(earlynonMRSsbeingconsidered)];
                        LateMRSPlasticityIndexwrtNS = [LateMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(lateMRSsbeingconsidered)>spine_enlargement_cutoff];
                        LateMRSPlasticityDistList = [LateMRSPlasticityDistList; val(lateMRSsbeingconsidered)]; 
                        AllLateMRSVolumeChangeswrtNS = [AllLateMRSVolumeChangeswrtNS; SpineVolsbeingconsidered(lateMRSsbeingconsidered)];
                    end
                    for ns = 1:length(NSsonthisDend)
                        tempcount = 1;
                        relativedistancestoNS = abs(NS_locs(ns)-thisdenddistances(1,:));
                        relativedistancestoNS(NSsonthisDend(ns)-spinesonthisdend(1)+1) = nan;
                        otherNSs = setdiff(1:length(NS_locs),ns);
                        relative_NS_locs = NS_locs(ns)-NS_locs(setdiff(1:length(NS_locs),ns));
                        left_side_otherNSs = otherNSs(relative_NS_locs>0);
                        if ~isempty(left_side_otherNSs)
                            [~,ind] = min(relative_NS_locs(ismember(otherNSs, left_side_otherNSs)));
                            closest_left_side_NS = left_side_otherNSs(ind);
                        else
                            closest_left_side_NS = []; 
                        end
                        right_side_otherNSs = otherNSs(relative_NS_locs<0);
                        if ~isempty(right_side_otherNSs)
                            [~,ind] = min(abs(relative_NS_locs(ismember(otherNSs, right_side_otherNSs))));
                            closest_right_side_NS = right_side_otherNSs(ind);
                        else
                            closest_right_side_NS = [];
                        end
                        
%                         [~,ind] = min(abs(NS_locs(ns)-NS_locs(setdiff(1:length(NS_locs),ns))));
%                         closest_other_NS = otherNSs(ind);
%                         other_NS_barrier = NS_locs(ns)-NS_locs(closest_other_NS);
                        
                        binsize = 5;
                        maxdist = 25;
                        allspinecount = []; 
                        MRScount = []; 
                        nonMRScount = []; 
                        for distbins = 0:binsize:maxdist
                            if NS_locs(ns)-(distbins)<=0 && NS_locs(ns)+(distbins)>dendlength %%% If there aren't actually distance values matching this bin, obviously don't make the spine count zero!
                                distance_accounted_for(tempcount) = nan;
                                allspinecount(tempcount) = nan;
                                MRScount(tempcount) = nan;
                                nonMRScount(tempcount) = nan;
                                tempcount = tempcount+1;
                            else
                                if ~isempty(closest_left_side_NS)        %%% If there is another NS on the left side, account for the creeping area of consideration of this spine
                                    shared_region = diff([(NS_locs(ns)-(distbins+binsize)),(NS_locs(closest_left_side_NS)+(distbins+binsize))]);
%                                     left_boundary = max([0, NS_locs(ns)-(distbins+binsize), NS_locs(ns)-(distbins+binsize)+(shared_region/2)]);
                                    left_boundary = max([0, NS_locs(ns)-(distbins+binsize), nanmean([NS_locs(ns), NS_locs(closest_left_side_NS)])]); %%% Boundary is either 0 (left edge of dendrite), the NS location minus the distance being investated, OR the distance halfway between the NS and another NS on the left side
                                else
                                    left_boundary = max([0 NS_locs(ns)-(distbins+binsize)]);
                                end
                                if ~isempty(closest_right_side_NS)     %%% If there is another NS on the right side
                                    shared_region = (NS_locs(ns)+(distbins+binsize))-(NS_locs(closest_right_side_NS)-(distbins+binsize));
%                                     right_boundary = min([NS_locs(ns)+(distbins+binsize), dendlength, NS_locs(ns)+(distbins+binsize)-(shared_region/2)]);
                                    right_boundary = min([NS_locs(ns)+(distbins+binsize), dendlength, nanmean([NS_locs(ns), NS_locs(closest_right_side_NS)])]); 
                                else
                                    right_boundary = min([NS_locs(ns)+(distbins+binsize), dendlength]);
                                end
                                if tempcount>1
                                    distance_accounted_for(tempcount) = diff([left_boundary, right_boundary])-nansum(distance_accounted_for(1:tempcount-1));  %%% You only want to account for new distance covered by the bin
                                else
                                    distance_accounted_for(tempcount) = diff([left_boundary, right_boundary]);
                                end
                                if distance_accounted_for(tempcount) <= 0
                                    distance_accounted_for(tempcount) = nan;
                                    allspinecount(tempcount) = nan;
                                    k = 1;
                                end
                                spinesinrange = thisdenddistances(1,:) >= left_boundary & relativedistancestoNS >= distbins & thisdenddistances(1,:) <= right_boundary & relativedistancestoNS < distbins+binsize;
                                allspinecount(tempcount) = sum(spinesinrange);
                                MRScount(tempcount) = sum(MRSsonthisDend(spinesinrange));
                                nonMRScount(tempcount) = sum(nonMRSsonthisDend(spinesinrange));
                                tempcount = tempcount+1;
                            end
                        end
                        %==================================================
                        allspinecount(distance_accounted_for<binsize) = nan;
                        distance_accounted_for(distance_accounted_for < binsize) = nan;
                        
                        NSallspinewindows = [NSallspinewindows; distance_accounted_for]; 
                        NSAllSpineDensity = [NSAllSpineDensity; allspinecount./distance_accounted_for];
                        allspinecount(allspinecount==0) = nan;
                        
                        sanitycheck = nansum([MRScount; nonMRScount],1);
                        sanitycheck(isnan(allspinecount)) = nan;
                        if ~any(sanitycheck(~isnan(sanitycheck)) == allspinecount(~isnan(allspinecount)))
                            k = 1;
                        end
                        
                        NSMRSDensity = [NSMRSDensity; MRScount./distance_accounted_for];
                        NSnonMRSDensity = [NSnonMRSDensity; nonMRScount./distance_accounted_for];
                    end
                elseif NumNSsonDends(d) == 1
                    spinesonthisdend = SpineDendriteGrouping{animal}{field}{d};
                    NSsonthisDend = NewSpines{animal}{field}(ismember(NewSpines{animal}{field},SpineDendriteGrouping{animal}{field}{d}));
                    thisdenddistances = AllDendriteDistances{animal}{field}(spinesonthisdend(1):spinesonthisdend(end), spinesonthisdend(1):spinesonthisdend(end)); thisdenddistances(1:size(thisdenddistances,1)+1:numel(thisdenddistances)) = 0;
                    NS_loc = thisdenddistances(1,NSsonthisDend-spinesonthisdend(1)+1);
                    dendlength = max(AllDendriteDistances{animal}{field}(spinesonthisdend(1),:));
                    NumberofNewSpinesperDendrite = [NumberofNewSpinesperDendrite, NumNSsonDends(d)];
                    nonNSsonthisDend = setdiff(SpineDendriteGrouping{animal}{field}{d},NSsonthisDend);
                    MRSsonthisDend = earlyMRSs(spinesonthisdend); MRSsonthisDend(NSsonthisDend-spinesonthisdend(1)+1) = 0;
                    MRSDensity_by_Dendrite = [MRSDensity_by_Dendrite; sum(MRSsonthisDend)./dendlength];
                    FractionMRSsonDendswithNS = [FractionMRSsonDendswithNS; sum(MRSsonthisDend)/length(spinesonthisdend)];
                    nonMRSsonthisDend = ~earlyMRSs(spinesonthisdend);
                    nonMRSDensity_by_Dendrite = [nonMRSDensity_by_Dendrite; sum(nonMRSsonthisDend)./dendlength];
                    
                    if ~isempty(NSsonthisDend)
                        NScounteraddress = find(NewSpines{animal}{field}==NSsonthisDend);
                        tempcount = 1;
                        binsize = 5;
                        maxdist = 25;
                        allspinecount = []; 
                        MRScount = []; 
                        nonMRScount = []; 
                        for distbins = 0:binsize:maxdist
                            if NS_loc-(distbins)<=0 && NS_loc+(distbins)>dendlength
                                distance_accounted_for(tempcount) = nan;
                                allspinecount(tempcount) = nan;
                                MRScount(tempcount) = nan;
                                nonMRScount(tempcount) = nan;
                                tempcount = tempcount+1;
                            else
                                left_boundary = max([0 NS_loc-(distbins+binsize)]);
                                right_boundary = min([NS_loc+(distbins+binsize), dendlength]);
                                if tempcount>1
                                    distance_accounted_for(tempcount) = diff([left_boundary, right_boundary])-nansum(distance_accounted_for(1:tempcount-1));  %%% You only want to account for new distance covered by the bin
                                else
                                    distance_accounted_for(tempcount) = diff([left_boundary, right_boundary]);
                                end
                                spinesinrange = thisdenddistances(1,:) >= left_boundary & NewSpineAllSpinesDistance{animal}{field}(NScounteraddress,spinesonthisdend) >= distbins & thisdenddistances(1,:) <= right_boundary & NewSpineAllSpinesDistance{animal}{field}(NScounteraddress,spinesonthisdend) < distbins+binsize ;
                                allspinecount(tempcount) = sum(spinesinrange);
                                MRScount(tempcount) = sum(MRSsonthisDend(spinesinrange));
                                nonMRScount(tempcount) = sum(nonMRSsonthisDend(spinesinrange));
                                tempcount = tempcount+1;
                            end
                        end
                        %==================================================
                        allspinecount(distance_accounted_for < binsize) = nan;
                        distance_accounted_for(distance_accounted_for < binsize) = nan;

                        NSallspinewindows = [NSallspinewindows; distance_accounted_for]; 
                        NSAllSpineDensity = [NSAllSpineDensity; allspinecount./distance_accounted_for];
                        allspinecount(allspinecount==0) = nan;
                        
                        NSMRSDensity = [NSMRSDensity; MRScount./distance_accounted_for];
                        NSnonMRSDensity = [NSnonMRSDensity; nonMRScount./distance_accounted_for];
                        
                        GainedLostPersDistList = [GainedLostPersDistList; NewSpineAllSpinesDistance{animal}{field}(NScounteraddress,:)'];
                        persistentMRSs = [persistentMRSs; earlyMRSs & lateMRSs];
                        gainedMRSs = [gainedMRSs; diff([earlyMRSs, lateMRSs],[],2)>0];
                        lostMRSs = [lostMRSs; diff([(earlyMRSs),lateMRSs],[],2)<0];
                        earlyMRSsbeingconsidered = find(earlyMRSs(nonNSsonthisDend));
                        lateMRSsbeingconsidered = find(lateMRSs(nonNSsonthisDend));
                        earlynonMRSsbeingconsidered = find(~earlyMRSs(nonNSsonthisDend));
                        SpineVolsbeingconsidered = SpineVol(nonNSsonthisDend);
                        AllEarlyMRSVolumeChangeswrtNS = [AllEarlyMRSVolumeChangeswrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)];
                        currentdistances = NewSpineAllSpinesDistance{animal}{field}(NScounteraddress, nonNSsonthisDend(earlyMRSs(nonNSsonthisDend)))';
                        EarlyMRSPlasticityDistList = [EarlyMRSPlasticityDistList; NewSpineAllSpinesDistance{animal}{field}(NScounteraddress, nonNSsonthisDend(earlyMRSs(nonNSsonthisDend)))'];
                        EarlyMRSPlasticityIndexwrtNS = [EarlyMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)>= spine_enlargement_cutoff];
                        EarlyMRSDepressionIndexwrtNS = [EarlyMRSDepressionIndexwrtNS; SpineVolsbeingconsidered(earlyMRSsbeingconsidered)< 0.9];
                        EarlynonMRSPlasticityIndexwrtNS = [EarlynonMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(earlynonMRSsbeingconsidered)>=spine_enlargement_cutoff];
                        EarlynonMRSDepressionIndexwrtNS = [EarlynonMRSDepressionIndexwrtNS; SpineVolsbeingconsidered(earlynonMRSsbeingconsidered)<0.9];
                        EarlynonMRSPlasticityDistList = [EarlynonMRSPlasticityDistList; NewSpineAllSpinesDistance{animal}{field}(NScounteraddress, nonNSsonthisDend(~earlyMRSs(nonNSsonthisDend)))'];
                        LateMRSPlasticityIndexwrtNS = [LateMRSPlasticityIndexwrtNS; SpineVolsbeingconsidered(lateMRSsbeingconsidered)>= spine_enlargement_cutoff];
                        LateMRSPlasticityDistList = [LateMRSPlasticityDistList; NewSpineAllSpinesDistance{animal}{field}(NScounteraddress, nonNSsonthisDend(lateMRSs(nonNSsonthisDend)))'];
                        AllLateMRSVolumeChangeswrtNS = [AllLateMRSVolumeChangeswrtNS; SpineVolsbeingconsidered(lateMRSsbeingconsidered)];
                    end
                else
                    spinesonthisdend = SpineDendriteGrouping{animal}{field}{d};
                    MRSsonthisDend = earlyMRSs(spinesonthisdend);
                    nonMRSsonthisDend = ~earlyMRSs(spinesonthisdend);
                    dendlength = max(AllDendriteDistances{animal}{field}(spinesonthisdend(1),:));
                    NumberofNewSpinesperDendrite = [NumberofNewSpinesperDendrite, NumNSsonDends(d)];
                    MRSDensity_by_Dendrite = [MRSDensity_by_Dendrite; sum(MRSsonthisDend)./dendlength];
                    nonMRSDensity_by_Dendrite = [nonMRSDensity_by_Dendrite; sum(nonMRSsonthisDend)./dendlength];
                    FractionMRSsonDendswithoutNS = [FractionMRSsonDendswithoutNS; sum(MRSsonthisDend)/length(MRSsonthisDend)];
                end
            end
            %%%
%             if ~isempty(EarlyMRSPlasticityDistList) && length(earlyMRSsbeingconsidered)>1
%                 testfig = figure('Name', [varargin{animal}, ' Field', num2str(field)]); hold on; 
%                 subplot(1,2,1)
%                     x = currentdistances; y = double(SpineVolsbeingconsidered(earlyMRSsbeingconsidered)>= spine_enlargement_cutoff); y = y(~isnan(x)); x = x(~isnan(x));
%                     QuickLinearFit(x,y,1)
%                     xlim([0, max(x)])
%                     title('Enlargement vs Distance')
%                 subplot(1,2,2)
%                     x2 = currentdistances; y2 = double(SpineVolsbeingconsidered(earlyMRSsbeingconsidered)< 0.9); y = y(~isnan(x)); x = x(~isnan(x));
%                     QuickLinearFit(x2,y2,2)
%                     xlim([0, max(x)])
%                     title('Shrinkage vs Distance')
%                     delete(testfig)
%             end
            %%%
            allspinepos = cell2mat(SpinePosbyDend);
            NSPositionsonDend = allspinepos(NewSpines{animal}{field});
            nonNSreport = [];
            for n = 1:length(NewSpines{animal}{field})
                dendofint = cellfun(@(x) ismember(NewSpines{animal}{field}(n),x), SpineDendriteGrouping{animal}{field});
                nonNSreport = [nonNSreport,SpineDendriteGrouping{animal}{field}{dendofint}(abs(SpinePosbyDend{dendofint}-NSPositionsonDend(n))<distance_cutoff)];
                NonNSComparisonSpinestoUse(SpineDendriteGrouping{animal}{field}{dendofint}(abs(SpinePosbyDend{dendofint}-NSPositionsonDend(n))<distance_cutoff))= 0;
            end
        else
            DendswithNSs = zeros(1,length(SpineDendriteGrouping{animal}{field}));
            NumberofNewSpinesperDendrite = [NumberofNewSpinesperDendrite, zeros(1,length(SpineDendriteGrouping{animal}{field}))];
            for d = 1:length(SpineDendriteGrouping{animal}{field})
                spinesonthisdend = SpineDendriteGrouping{animal}{field}{d};
                MRSsonthisDend = earlyMRSs(spinesonthisdend);
                nonMRSsonthisDend = ~earlyMRSs(spinesonthisdend);
                FractionMRSsonDendswithoutNS = [FractionMRSsonDendswithoutNS; sum(MRSsonthisDend)/length(spinesonthisdend)];
                dendlength = max(AllDendriteDistances{animal}{field}(spinesonthisdend(1),:));
                MRSDensity_by_Dendrite = [MRSDensity_by_Dendrite; sum(MRSsonthisDend)./dendlength];
                nonMRSDensity_by_Dendrite = [nonMRSDensity_by_Dendrite; sum(nonMRSsonthisDend)./dendlength];
            end
        end
        DendriteswithNewSpines = [DendriteswithNewSpines, DendswithNSs];
        %==============================================================
        %%% Now that you've flagged spines that are within the cutoff
        %%% distance of any NS, go through and find the density of
        %%% different spine types, with barries like the dendrites' edges
        %%% and NS locations in mind
        if ~isempty(NewSpineAllSpinesDistance{animal}{field})
            EarlyMRS_ClosestNS = [EarlyMRS_ClosestNS; nanmin(NewSpineAllSpinesDistance{animal}{field}(:,:),[],1)'];
        else
            EarlyMRS_ClosestNS = [EarlyMRS_ClosestNS; nan(length(earlyMRSs),1)];
        end
        
        for nonNS = 1:length(earlyMRSs)
            parentdend = logical(cellfun(@(x) ismember(nonNS, x), SpineDendriteGrouping{animal}{field}));
            spinesonthisdend = SpineDendriteGrouping{animal}{field}{parentdend};
            MRSsonthisDend = earlyMRSs(spinesonthisdend);
            nonMRSsonthisDend = ~earlyMRSs(spinesonthisdend);
            NSsonthisDend = NewSpines{animal}{field}(ismember(NewSpines{animal}{field},SpineDendriteGrouping{animal}{field}{parentdend}));
            thisdenddistances = AllDendriteDistances{animal}{field}(spinesonthisdend(1):spinesonthisdend(end),spinesonthisdend(1):spinesonthisdend(end));
            thisdenddistances(1:size(thisdenddistances,1)+1:numel(thisdenddistances)) = 0;
            dendlength = thisdenddistances(1,end);
            nonNSClosestEarlyMRS = [nonNSClosestEarlyMRS; nanmin(AllDendriteDistances{animal}{field}(nonNS,earlyMRSs))];
            nonNSClosestEarlynonMRS = [nonNSClosestEarlynonMRS; nanmin(AllDendriteDistances{animal}{field}(nonNS,~earlyMRSs))];

            if NonNSComparisonSpinestoUse(nonNS)
                nonNS_loc = thisdenddistances(1,nonNS-spinesonthisdend(1)+1);
                nonNSrelativetodendrite_endpoints = abs([nonNS_loc-0 nonNS_loc-dendlength]);
                if any(nonNSrelativetodendrite_endpoints <= distance_cutoff)
                    nonNSrelativetodendrite_endpoints(nonNSrelativetodendrite_endpoints>=distance_cutoff) = distance_cutoff;
                    spines_in_range = AllDendriteDistances{animal}{field}(nonNS,:)<=distance_cutoff;
                    if sum(nonNSrelativetodendrite_endpoints) < min_distance_considered
                        continue
                    else
                        nonNS_Range = [nonNS_Range; sum(nonNSrelativetodendrite_endpoints)];
                        nonNS_NearbySpineDensity = [nonNS_NearbySpineDensity; sum(spines_in_range)./sum(nonNSrelativetodendrite_endpoints)];
                    end
                else
                    nonNS_Range = [nonNS_Range; 2*distance_cutoff];
                    nonNS_NearbySpineDensity = [nonNS_NearbySpineDensity; sum(AllDendriteDistances{animal}{field}(nonNS,:)<=distance_cutoff)./(2*distance_cutoff)];
                end
                nonNS_NearbySpineCount = [nonNS_NearbySpineCount; sum(AllDendriteDistances{animal}{field}(nonNS,:)<=distance_cutoff)];
                nonNSEarlyMRSEnvironment = [nonNSEarlyMRSEnvironment; sum(AllDendriteDistances{animal}{field}(nonNS,earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
                nonNSEarlynonMRSEnvironment = [nonNSEarlynonMRSEnvironment; sum(AllDendriteDistances{animal}{field}(nonNS,~earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
                
                %==========================================================
                relativedistancestononNS = abs(nonNS_loc-thisdenddistances(1,:));
                relativedistancestononNS(NSsonthisDend-spinesonthisdend(1)+1) = nan;

                if ~isempty(NSsonthisDend)
                    NS_locs = thisdenddistances(1,NSsonthisDend-spinesonthisdend(1)+1);
                    relative_NS_locs = nonNS_loc-NS_locs;
                    NS_list = 1:length(NS_locs);
                    left_side_NSs = NS_list(relative_NS_locs>0);
                    if ~isempty(left_side_NSs)
                        [~,ind] = min(relative_NS_locs(ismember(NS_list, left_side_NSs)));
                        closest_left_side_NS = left_side_NSs(ind);
                    else
                        closest_left_side_NS = [];
                    end
                    right_side_NSs = NS_list(relative_NS_locs<0);
                    if ~isempty(right_side_NSs)
                        [~,ind] = min(abs(relative_NS_locs(ismember(NS_list, right_side_NSs))));
                        closest_right_side_NS = right_side_NSs(ind);
                    else
                        closest_right_side_NS = [];
                    end
                else
                    continue
                    closest_left_side_NS = []; 
                    closest_right_side_NS = []; 
                end
                binsize = 5; maxdist = 25; tempcount = 1;
                distance_accounted_for = []; 
                allspinecount = []; 
                MRScount = []; 
                nonMRScount = []; 
                for distbins = 0:binsize:maxdist
                    if nonNS_loc-(distbins)<=0 && nonNS_loc+(distbins)>dendlength
                        distance_accounted_for(tempcount) = nan;
                        allspinecount(tempcount) = nan;
                        MRScount(tempcount) = nan;
                        nonMRScount(tempcount) = nan;
                        tempcount = tempcount+1;
                    else
                        if ~isempty(closest_left_side_NS)        %%% If there is an NS on the left side, account for the creeping area of consideration of this spine
                            shared_region = diff([(nonNS_loc-(distbins+binsize)),(NS_locs(closest_left_side_NS)+(distbins+binsize))]);
                            left_boundary = max([0, nonNS_loc-(distbins+binsize), nanmean([nonNS_loc, NS_locs(closest_left_side_NS)])]); %%% Boundary is either 0 (left edge of dendrite), the NS location minus the distance being investated, OR the distance halfway between the NS and another NS on the left side
                        else
                            left_boundary = max([0 nonNS_loc-(distbins+binsize)]);
                        end
                        if ~isempty(closest_right_side_NS)     %%% If there is an NS on the right side
                            shared_region = (nonNS_loc+(distbins+binsize))-(NS_locs(closest_right_side_NS)-(distbins+binsize));
                            right_boundary = min([nonNS_loc+(distbins+binsize), dendlength, nanmean([nonNS_loc, NS_locs(closest_right_side_NS)])]);
                        else
                            right_boundary = min([nonNS_loc+(distbins+binsize), dendlength]);
                        end
                        if tempcount>1
                            distance_accounted_for(tempcount) = diff([left_boundary, right_boundary])-nansum(distance_accounted_for(1:tempcount-1));  %%% You only want to account for new distance covered by the bin
                        else
                            distance_accounted_for(tempcount) = diff([left_boundary, right_boundary]);
                        end
                        if distance_accounted_for(tempcount) <= 0
                            distance_accounted_for(tempcount) = nan;
                            allspinecount(tempcount) = nan;
                            k = 1;
                        end
                        spinesinrange = thisdenddistances(1,:) >= left_boundary & relativedistancestononNS >= distbins & thisdenddistances(1,:) <= right_boundary & relativedistancestononNS < distbins+binsize;
                        allspinecount(tempcount) = sum(spinesinrange);
                        MRScount(tempcount) = sum(MRSsonthisDend(spinesinrange));
                        nonMRScount(tempcount) = sum(nonMRSsonthisDend(spinesinrange));
                        tempcount = tempcount+1;
                    end
                end
                allspinecount(distance_accounted_for < binsize) = nan;
                distance_accounted_for(distance_accounted_for < binsize) = nan;

                if any((MRScount./distance_accounted_for)>1)
                    k = 1;
                end
                nonNSMRSDensity = [nonNSMRSDensity; MRScount./distance_accounted_for];
                nonNSnonMRSDensity = [nonNSnonMRSDensity; nonMRScount./distance_accounted_for];
            else
%                 dendofint = cellfun(@(x) ismember(nonNS,x), SpineDendriteGrouping{animal}{field});
%                 NSsonthisDend = NewSpines{animal}{field}(ismember(NewSpines{animal}{field},SpineDendriteGrouping{animal}{field}{dendofint}));
%                 NS_locs = thisdenddistances(1,NSsonthisDend-spinesonthisdend(1)+1);
%                 nonNS_loc = thisdenddistances(1,nonNS-spinesonthisdend(1)+1);
%                 nonNSrelativetodendrite_endpoints = abs([nonNS_loc-0 nonNS_loc-dendlength]);
%                 nonNSrelativetodendrite_endpoints(nonNSrelativetodendrite_endpoints>=distance_cutoff) = distance_cutoff;
%                 if any(NS_locs == nonNS_loc) %%% If a nonNS is in the same place as a NS, don't consider it
%                     continue
%                 end
%                 if any(NS_locs<nonNS_loc)   %%% If there are any NSs on the left side of the current spine
%                     left_side_NSs = NS_locs(NS_locs<nonNS_loc);
%                     [~,ind] = nanmin(abs(left_side_NSs-nonNS_loc));
%                     left_side_boundary = max([nonNS_loc-distance_cutoff, left_side_NSs(ind)+distance_cutoff]);
%                 else
%                     left_side_boundary = nonNS_loc-min([nonNS_loc, distance_cutoff]);   %%% If there are no NSs on the left side, then the boundary is either the nonNS position (which counts from the left from the edge of the dendrite), OR the distance cutoff (whichever is smaller)
%                 end
%                 if any(NS_locs>nonNS_loc)   %%% If there are any NSs on the right side of the current spine
%                     right_side_NSs = NS_locs(NS_locs>=nonNS_loc);
%                     [~,ind] = nanmin(abs(right_side_NSs-nonNS_loc));
%                     right_side_boundary = min([nonNS_loc+distance_cutoff, right_side_NSs(ind)-distance_cutoff]);
%                 else
%                     right_side_boundary = nonNS_loc+min([nonNSrelativetodendrite_endpoints(2), distance_cutoff]);
%                 end
%                 if isempty(left_side_boundary:right_side_boundary)
%                     continue
%                 end
%                 if diff([left_side_boundary, right_side_boundary]) < min_distance_considered
%                 else
%                     nonNS_Range = [nonNS_Range; diff([left_side_boundary, right_side_boundary])];
%                     spinesinrange = thisdenddistances(1,:) >= left_side_boundary & thisdenddistances(1,:) < right_side_boundary & abs(thisdenddistances(1,:)-nonNS_loc) <= distance_cutoff ;
%                     nonNS_NearbySpineCount = [nonNS_NearbySpineCount; sum(spinesinrange)];
%                     nonNS_NearbySpineDensity = [nonNS_NearbySpineDensity; sum(spinesinrange)'./diff([left_side_boundary, right_side_boundary])];
%                     MRS_in_range = spinesinrange & earlyMRSs(spinesonthisdend)';
%                     nonNSEarlyMRSEnvironment = [nonNSEarlyMRSEnvironment; sum(MRS_in_range)];
%                     nonMRS_in_range = spinesinrange & ~earlyMRSs(spinesonthisdend)';
%                     nonNSEarlynonMRSEnvironment = [nonNSEarlynonMRSEnvironment; sum(nonMRS_in_range)]; %./diff([left_side_boundary, right_side_boundary])];
%                 end
            end
        end
        %==================================================================
        %%% Retrieve all spine-pair correlations, and exclude some
        %%% according to needs
        allspinecorrmat = AllSpineCorrelationsonLateSession{animal}{field};
        allspinecorrmat(NewSpines{animal}{field},:) = nan; allspinecorrmat(:,NewSpines{animal}{field}) = nan;
        allspinecorrlist = [allspinecorrlist; allspinecorrmat(:)];
        allspinedistmat = AllDendriteDistances{animal}{field}; 
        allspinedistmat(NewSpines{animal}{field},:) = nan; allspinedistmat(:,NewSpines{animal}{field}) = nan;
        allspinedistlist = [allspinedistlist; allspinedistmat(:)];  
        %%%
        %==================================================================
        if length(NewSpines{animal}{field})>1
            NScombos = nchoosek(NewSpines{animal}{field},2);
            for nsc = 1:size(NScombos,1)
                NScounteraddress = find(NewSpines{animal}{field}==NScombos(nsc,1));
                NStoNSDist = [NStoNSDist; NewSpineAllSpinesDistance{animal}{field}(NScounteraddress,NScombos(nsc,2))];
%                 NStoNSCoA = [NStoNSCoA; NewSpineAllCoActiveRatesGeoNormalized{animal}{field}{NScounteraddress}(NScombos(nsc,2))];
            end
        end
        
        for newspine = 1:size(NewSpineAllSpinesDistance{animal}{field},1)
            AllEarlyMRSwrtNSs = [AllEarlyMRSwrtNSs; earlyMRSs];
            AllLateMRSwrtNSs = [AllLateMRSwrtNSs; lateMRSs];
            if ismember(NewSpines{animal}{field}(newspine), MiddleSessionNewSpines{animal}{field})
                isNSMidorLate = 'Mid';
            else
                isNSMidorLate = 'Late';
            end
            switch isNSMidorLate
                case 'Mid'
                    prev_sesh_MRSs = earlyMRSs;
                    midcorrlist = [midcorrlist; NewSpineAllSpinesMidCorr{animal}{field}(newspine, :)'];
                    midNSMRSCoAlist = [midNSMRSCoAlist; NewSpineMidCoActiveRateGeoNormalized{animal}{field}{newspine}(:,midMRSs)'];
                    midNSMRSdistlist = [midNSMRSdistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,midMRSs)'];
                    midNSnMRSCoAlist = [midNSnMRSCoAlist; NewSpineMidCoActiveRateGeoNormalized{animal}{field}{newspine}(:,~midMRSs)'];
                    midNSnMRSdistlist = [midNSnMRSdistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,~midMRSs)'];

                    
                    midcorrlistbyfield{fieldcount} = [midcorrlistbyfield{fieldcount}; NewSpineAllSpinesMidCorr{animal}{field}(newspine, :)'];
                    midCoAlistbyfield{fieldcount} = [midCoAlistbyfield{fieldcount}; NewSpineMidCoActiveRateNormalized{animal}{field}{newspine}'];
                    middistlistbyfield{fieldcount} = [middistlistbyfield{fieldcount}; NewSpineAllSpinesDistance{animal}{field}(newspine,:)'];
                case 'Late'
                    if isThreeSessions
                        prev_sesh_MRSs = midMRSs;
                    else
                        prev_sesh_MRSs = earlyMRSs;
                    end
            end  
            switch isNSMidorLate
                case 'Mid'
                    pass = 0;
                case 'Late'
                    pass = 0;
            end
            if pass
                continue
            end
            %==============================================================
            % Specific section for transient new spines
            if ~isempty(AllTransientNewSpinesDistance{animal}{field})
                transientnewspines_count = transientnewspines_count+size(AllTransientNewSpinesDistance{animal}{field},1);
                nMRSTransDistances = [nMRSTransDistances, reshape(AllTransientNewSpinesDistance{animal}{field}(:,~midMRSs),1,numel(AllTransientNewSpinesDistance{animal}{field}(:,~midMRSs)))];
                MRSTransDistances = [MRSTransDistances, reshape(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs)))];
                AllTransDistancesbyField{fieldcount} = [AllTransDistancesbyField{fieldcount}, reshape(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs)))];
                AllTransCorr = [AllTransCorr, reshape(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs)))];
                AllTransCorrbyField{fieldcount} = [AllTransCorrbyField{fieldcount}, reshape(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs)))];
                midCoAdata = vertcat(TransientSpineCoActiveRateGeoNormalized{animal}{field}{:});
                nMRSTransCoA = [nMRSTransCoA, reshape(midCoAdata(:,~midMRSs),1,numel(midCoAdata(:,~midMRSs)))];
                MRSTransCoA = [MRSTransCoA, reshape(midCoAdata(:,midMRSs),1, numel(midCoAdata(:,midMRSs)))];
                AllTransCoAbyField{fieldcount} = [AllTransCoAbyField{fieldcount}, reshape(midCoAdata(:,:),1,numel(midCoAdata(:,:)))];
            end

            %==============================================================
            % Handle Distances
            NStoAllSpinesDistances = [NStoAllSpinesDistances; NewSpineAllSpinesDistance{animal}{field}(newspine,:)'];
            AllNewSpinetoEarlyMRSDistances = [AllNewSpinetoEarlyMRSDistances; NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs)'];
                distlistbyfield{fieldcount} = [distlistbyfield{fieldcount}; NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use)'];
                
            AllNewSpinetoMRSDistances = [AllNewSpinetoMRSDistances; NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use)'];
            AllNewSpinetonMRSDistances = [AllNewSpinetonMRSDistances; NewSpineAllSpinesDistance{animal}{field}(newspine,~MRSs_to_use)'];
            ClosestEarlyMRS = [ClosestEarlyMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs))];
            ClosestEarlynonMRS = [ClosestEarlynonMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,~earlyMRSs))];
            
            spinesonthisdend = SpineDendriteGrouping{animal}{field}{logical(cellfun(@(x) ismember(NewSpines{animal}{field}(newspine), x), SpineDendriteGrouping{animal}{field}))};
            dendlength = AllDendriteDistances{animal}{field}(spinesonthisdend(1),spinesonthisdend(end));
            NS_loc = AllDendriteDistances{animal}{field}(spinesonthisdend(1),NewSpines{animal}{field}(newspine));
            NSrelativetodendrite_endpoints = abs([NS_loc-0 NS_loc-dendlength]);
            if any(NSrelativetodendrite_endpoints<=distance_cutoff) %%% If the new spine is close to the edge of a dendrite
                NSrelativetodendrite_endpoints(NSrelativetodendrite_endpoints>=distance_cutoff) = distance_cutoff; %%% If you're going to normalize by the sum of lengths on either side, you need to cap it off at the maximum that would be considered if the spine weren't close to the edge (i.e. the distance cutoff)
                if sum(NSrelativetodendrite_endpoints) < min_distance_considered %%% If there aren't any nearby spines and the distance is small, it doesn't make sense to use this data
                else
                    NS_Range = [NS_Range; sum(NSrelativetodendrite_endpoints)];
                    NS_NearbySpineCount = [NS_NearbySpineCount; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,:)<=distance_cutoff)];
                    NS_NearbySpineDensity = [NS_NearbySpineDensity; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,:)<=distance_cutoff)./(2*distance_cutoff)];
                    NearbyEarlyMRSEnvironment = [NearbyEarlyMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
                    NearbyEarlynonMRSEnvironment = [NearbyEarlynonMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,~earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
                end
            else
                NS_Range = [NS_Range; 2*distance_cutoff];
                NS_NearbySpineCount = [NS_NearbySpineCount; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,:)<=distance_cutoff)];
                NS_NearbySpineDensity = [NS_NearbySpineDensity; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,:)<=distance_cutoff)./(2*distance_cutoff)];
                NearbyEarlyMRSEnvironment = [NearbyEarlyMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
                NearbyEarlynonMRSEnvironment = [NearbyEarlynonMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,~earlyMRSs)<=distance_cutoff)]; %./(2*distance_cutoff)];
            end
            
            ClosestPrevSeshMRS = [ClosestPrevSeshMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,prev_sesh_MRSs))];
            NearbyPrevSeshMRSEnvironment = [NearbyPrevSeshMRSEnvironment;  sum(NewSpineAllSpinesDistance{animal}{field}(newspine,prev_sesh_MRSs)<=distance_cutoff)];
            ClosestLateMRS = [ClosestLateMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use))];
            NearbyLateMRSEnvironment = [NearbyLateMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,lateMRSs)<=distance_cutoff)];
            ClosestPersMRS = [ClosestPersMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs & lateMRSs))];
            NearbyPersMRSEnvironment = [NearbyPersMRSEnvironment; sum(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs & lateMRSs)<=distance_cutoff)];
            ClosestGainedMRS = [ClosestGainedMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,diff([earlyMRSs, lateMRSs],[],2)>0))];
            
            %==============================================================
            % Correlation and CoActivity Rates
            
            if any(lateMRSs)
                AllNoiseCorr = [AllNoiseCorr, AllMoveCentricClusterCorrelationsbyNewSpine{animal}{field}{newspine}];
            end
            corrlist = [corrlist; NewSpineAllSpinesLateCorr{animal}{field}(newspine,MRSs_to_use)'];
                corrlistbyfield{fieldcount} = [corrlistbyfield{fieldcount}; NewSpineAllSpinesLateCorr{animal}{field}(newspine,MRSs_to_use)'];
            rawcorrlist = [rawcorrlist; NewSpineAllSpinesLateRawCorr{animal}{field}(newspine, MRSs_to_use)'];
            noisecorrlist = [noisecorrlist; NewSpineAllSpinesLateNoiseCorr{animal}{field}(newspine,MRSs_to_use)'];
            nonMRSdistlist = [nonMRSdistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,~MRSs_to_use)'];
                nonMRSdistlistbyfield{fieldcount} = [nonMRSdistlistbyfield{fieldcount}; NewSpineAllSpinesDistance{animal}{field}(newspine,~MRSs_to_use)'];
            nonMRScorrlist = [nonMRScorrlist; NewSpineAllSpinesLateCorr{animal}{field}(newspine,~MRSs_to_use)'];
                nonMRScorrlistbyfield{fieldcount} = [nonMRScorrlistbyfield{fieldcount}; NewSpineAllSpinesLateCorr{animal}{field}(newspine,~MRSs_to_use)'];
            nonMRSnoisecorrlist = [nonMRSnoisecorrlist; NewSpineAllSpinesLateNoiseCorr{animal}{field}(newspine,~MRSs_to_use)'];
            MRScoAlist = [MRScoAlist; NewSpineAllCoActiveRatesGeoNormalized{animal}{field}{newspine}(MRSs_to_use)'];
            nonMRScoAlist = [nonMRScoAlist; NewSpineAllCoActiveRatesGeoNormalized{animal}{field}{newspine}(~MRSs_to_use)'];
            
            %==============================================================
            % Behavioral encoding of spine pairs
            NStoAllSpineMoveRanks = [NStoAllSpineMoveRanks; earlyMovRanks];
%             AllSeedlingMovCorr = [AllSeedlingMovCorr, SimilarityofClusteredMovementwithSeedlingMRSMovement{animal}{field}{newspine}];
            if any(lateMRSs)
                if ~isempty(LeverVelocityatClustActivityOnset{animal}{field}{newspine}{1})
                    AllLeverVelocitySD = [AllLeverVelocitySD, cellfun(@(x) nanstd(x(:,5)), LeverVelocityatClustActivityOnset{animal}{field}{newspine})];
                end
                DotProducts = [DotProducts, AllCoActivityDotProductsforDistanceMeasurement{animal}{field}{newspine}];
                ChanceDotProducts = [ChanceDotProducts, AllCoActivityChanceLevelDotProductsforDistanceMeasurement{animal}{field}{newspine}];
                AllMMCorr = [AllMMCorr, cellfun(@nanmedian, CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{animal}{field}{newspine})];
                WithinMovCorr = [WithinMovCorr, cellfun(@nanmedian, CorrelationofMovementswithCoActiveClusterActivitybyCluster{animal}{field}{newspine})];
                FractionofMovementsEncoded = [FractionofMovementsEncoded, FractionofMovementswithClusterCoActivitybyCluster{animal}{field}{newspine}];
                if ~isempty(IsCoActiveMovementRewarded{animal}{field}{newspine})
                    IsRew = [IsRew, cellfun(@nanmean, IsCoActiveMovementRewarded{animal}{field}{newspine})];
                    IsChanceRew = [IsChanceRew, ChanceRewardedLevel{animal}{field}{newspine}];
                end
            end

            %==============================================================
%             persistentMRSs = [persistentMRSs; (earlyMRSs | midMRSs) & lateMRSs];
%             gainedMRSs = [gainedMRSs; diff([earlyMRSs, lateMRSs],[],2)>0];
%             lostMRSs = [lostMRSs; diff([(earlyMRSs | midMRSs),lateMRSs],[],2)<0];
            %==============================================================
            % Spine Plasticity Section
            newspinelabel = NewSpines{animal}{field}(newspine);
            parentdendrite = find(cellfun(@(x) ismember(newspinelabel, x), SpineDendriteGrouping{animal}{field}));
            spinesfromparentdend = SpineDendriteGrouping{animal}{field}{parentdendrite};
            DendDistances = AllDendriteDistances{animal}{field}(spinesfromparentdend(1):spinesfromparentdend(end),spinesfromparentdend(1):spinesfromparentdend(end));
            MRSonthisDend = MRSs_to_use(spinesfromparentdend);
            [dendlength, longeststretch] = nanmax(nanmax(DendDistances,[],2));
            AllDendriteLengths = [AllDendriteLengths; dendlength];
            SpineDensity = [SpineDensity, size(DendDistances,1)/dendlength];
            MRSDensity = [MRSDensity, sum(earlyMRSs(spinesfromparentdend))/dendlength];
            if ~isempty(AllSpineVolumeData{animal}{field})
                switch isNSMidorLate
                    case 'Mid'
                        SpineVol = AllSpineVolumeData{animal}{field}(:,2)./AllSpineVolumeData{animal}{field}(:,1);
                        SpineVol(NewSpines{animal}{field},:) = nan;
                    case 'Late'
                        SpineVol = AllSpineVolumeData{animal}{field}(:,end)./AllSpineVolumeData{animal}{field}(:,1);
                        SpineVol(NewSpines{animal}{field},:) = nan;
                end
                AllPrevSeshMRSwrtNSs = [AllPrevSeshMRSwrtNSs; prev_sesh_MRSs];
                SpineVol(SpineVol==Inf) = NaN;
                SpineVol(SpineVol==-Inf) = NaN;
                FullSpineVolList = SpineVol;
                SpineVol = SpineVol(spinesfromparentdend);
                VolIncreaseIndex = SpineVol >= spine_enlargement_cutoff;
                FractionofSpinesThatAreEnlarged = [FractionofSpinesThatAreEnlarged; VolIncreaseIndex];
                %==========================================================
                %%% Make absolutely sure this is the same thing being used
                %%% for the shuffled values below (find other
                %%% 'PlasticityContingency' variable in the code). 
                PlasticityContingency = VolIncreaseIndex & prev_sesh_MRSs(spinesfromparentdend);
%                 PlasticityContingency = VolIncreaseIndex & prev_sesh_MRSs(spinesfromparentdend);
                %%%
                %==========================================================
                FractionEnlargedSpinesThatAreMRSs = [FractionEnlargedSpinesThatAreMRSs; PlasticityContingency];
                RelativeDistances = DendDistances(NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1,:);
                
                [CESval,~] = nanmin(RelativeDistances(VolIncreaseIndex));
                ClosestEnlargedSpineList = [ClosestEnlargedSpineList, CESval];
                
                [CEMRSval,CEMRSind] = nanmin(RelativeDistances(PlasticityContingency));
                NumberofNearbyEnlargedSpines = [NumberofNearbyEnlargedSpines, sum(RelativeDistances(VolIncreaseIndex)<=distance_cutoff)];
                NumberofNearbyEnlargedMRSs = [NumberofNearbyEnlargedMRSs, sum(RelativeDistances(PlasticityContingency)<=distance_cutoff)];
                ClosestEnlargedMRSList = [ClosestEnlargedMRSList, CEMRSval];
                
                [CEPMRSval,~] = nanmin(RelativeDistances(VolIncreaseIndex & (earlyMRSs(spinesfromparentdend) | midMRSs(spinesfromparentdend)) & lateMRSs(spinesfromparentdend)));
                ClosestEnlargedPersMRSList = [ClosestEnlargedPersMRSList, CEPMRSval];
                
                [CEGMRSval,~] = nanmin(RelativeDistances(VolIncreaseIndex & (diff([earlyMRSs(spinesfromparentdend),lateMRSs(spinesfromparentdend)],[],2)>0)));
                ClosestEnlargedGainedMRSList = [ClosestEnlargedGainedMRSList, CEGMRSval];
                
                corr_struct_on_this_dend = NewSpineAllSpinesLateCorr{animal}{field}(newspine, spinesfromparentdend);
                corrwithbigbois = corr_struct_on_this_dend(PlasticityContingency);
                CorrwithClosestEnlargedSpine = [CorrwithClosestEnlargedSpine, corrwithbigbois(CEMRSind)];
                if ~isempty(CEMRSval)
                    CoAstructonthisdend = NewSpineAllCoActiveRatesGeoNormalized{animal}{field}{newspine}(spinesfromparentdend);
                    coAwithbigbois = CoAstructonthisdend(PlasticityContingency);
                    CoARatewithClosestEnlargedSpine = [CoARatewithClosestEnlargedSpine, coAwithbigbois(CEMRSind)];
                end
                
%                 AllSpineVolumeChanges = [AllSpineVolumeChanges; SpineVol(logical(prev_sesh_MRSs(spinesfromparentdend)))];
                AllPlasticityIndiceswrtNS = [AllPlasticityIndiceswrtNS; FullSpineVolList > spine_enlargement_cutoff];
%                 EarlyMRSPlasticityIndexwrtNS = [EarlyMRSPlasticityIndexwrtNS; FullSpineVolList(logical(earlyMRSs))>= spine_enlargement_cutoff];
                AllVolumeChangeswrtNS = [AllVolumeChangeswrtNS; FullSpineVolList];
%                 AllEarlyMRSVolumeChangeswrtNS = [AllEarlyMRSVolumeChangeswrtNS; FullSpineVolList(logical(earlyMRSs))];
                PrevSeshMRSdistlistwrtNS = [PrevSeshMRSdistlistwrtNS; NewSpineAllSpinesDistance{animal}{field}(newspine,prev_sesh_MRSs)'];
            else
            end
        end
        if isempty(newspine)
            EarlyMRSVolumeChanges = [EarlyMRSVolumeChanges; nan(length(earlyMRSs),1)]; 
        else
            if pass
                continue
            else
                EarlyMRSVolumeChanges = [EarlyMRSVolumeChanges; FullSpineVolList];
            end
        end
        fieldcount = fieldcount+1;
    end
end

%%% This section is only for filtering spine pairs that don't fall into the
%%% "shared axon" regime, as derived from EM; re-ordering is necessary for
%%% code to work!!!
% corr_cutoff = 0.14;
% AllDistances = AllDistances(corrlist<corr_cutoff);
% AllNoiseCorr = AllNoiseCorr(corrlist<corr_cutoff);
% AllSeedlingMovCorr = AllSeedlingMovCorr(corrlist<corr_cutoff);
% DotProducts = DotProducts(corrlist<corr_cutoff);
% ChanceDotProducts =ChanceDotProducts(corrlist<corr_cutoff);
% AllMMCorr = AllMMCorr(corrlist<corr_cutoff);
% WithinMovCorr = WithinMovCorr(corrlist<corr_cutoff);
% AllFractions = AllFractions(corrlist<corr_cutoff);
% IsRew = IsRew(corrlist<corr_cutoff);
% IsChanceRew = IsChanceRew(corrlist<corr_cutoff);
% AllCoARates = AllCoARates(corrlist<corr_cutoff);

% AllNoiseCorr = AllNoiseCorr(~isnan(DotProducts));
% AllMMCorr = AllMMCorr(~isnan(DotProducts));
% WithinMovCorr = WithinMovCorr(~isnan(DotProducts));
% DotProducts = DotProducts(~isnan(DotProducts));

%==========================================================================
% Data cleanup

AllEarlyMRSwrtNSs = AllEarlyMRSwrtNSs(~isnan(NStoAllSpinesDistances));
AllPrevSeshMRSwrtNSs = AllPrevSeshMRSwrtNSs(~isnan(NStoAllSpinesDistances));
AllLateMRSwrtNSs = AllLateMRSwrtNSs(~isnan(NStoAllSpinesDistances));
persistentMRSs = persistentMRSs(~isnan(GainedLostPersDistList));
gainedMRSs = gainedMRSs(~isnan(GainedLostPersDistList));
lostMRSs = lostMRSs(~isnan(GainedLostPersDistList));
GainedLostPersDistList = GainedLostPersDistList(~isnan(GainedLostPersDistList));
AllPlasticityIndiceswrtNS = AllPlasticityIndiceswrtNS(~isnan(NStoAllSpinesDistances));
AllVolumeChangeswrtNS = AllVolumeChangeswrtNS(~isnan(NStoAllSpinesDistances));
NStoAllSpinesDistances = NStoAllSpinesDistances(~isnan(NStoAllSpinesDistances));

% AllTransCorr = AllTransCorr(~isnan(AllTransDistances));
nMRSTransCoA = nMRSTransCoA(~isnan(nMRSTransDistances));
nMRSTransDistances = nMRSTransDistances(~isnan(nMRSTransDistances));
MRSTransCoA = MRSTransCoA(~isnan(MRSTransDistances));
MRSTransDistances = MRSTransDistances(~isnan(MRSTransDistances));

allspinecorrlist = allspinecorrlist(~isnan(allspinedistlist)); allspinedistlist = allspinedistlist(~isnan(allspinedistlist));
corrlist = corrlist(~isnan(AllNewSpinetoMRSDistances)); rawcorrlist = rawcorrlist(~isnan(AllNewSpinetoMRSDistances)); noisecorrlist = noisecorrlist(~isnan(AllNewSpinetoMRSDistances)); 
MRScoAlist = MRScoAlist(~isnan(AllNewSpinetoMRSDistances)); nonMRScoAlist = nonMRScoAlist(~isnan(AllNewSpinetonMRSDistances));
AllEarlyMRSVolumeChangeswrtNS = AllEarlyMRSVolumeChangeswrtNS(~isnan(EarlyMRSPlasticityDistList)); AllEarlyMRSVolumeChangeswrtNS(AllEarlyMRSVolumeChangeswrtNS<-20 | AllEarlyMRSVolumeChangeswrtNS>20) = nan;
AllLateMRSVolumeChangeswrtNS = AllLateMRSVolumeChangeswrtNS(~isnan(LateMRSPlasticityDistList)); AllLateMRSVolumeChangeswrtNS(AllLateMRSVolumeChangeswrtNS<-20 | AllLateMRSVolumeChangeswrtNS>20) = nan;
EarlyMRSPlasticityIndexwrtNS = EarlyMRSPlasticityIndexwrtNS(~isnan(EarlyMRSPlasticityDistList));
LateMRSPlasticityIndexwrtNS = LateMRSPlasticityIndexwrtNS(~isnan(LateMRSPlasticityDistList));
AllNewSpinetoEarlyMRSDistances = AllNewSpinetoEarlyMRSDistances(~isnan(AllNewSpinetoEarlyMRSDistances));
AllNewSpinetoMRSDistances = AllNewSpinetoMRSDistances(~isnan(AllNewSpinetoMRSDistances));
AllNewSpinetonMRSDistances = AllNewSpinetonMRSDistances(~isnan(AllNewSpinetonMRSDistances));
midcorrlist = midcorrlist(~isnan(midNSMRSdistlist)); midNSMRSCoAlist = midNSMRSCoAlist(~isnan(midNSMRSdistlist)); midNSMRSdistlist = midNSMRSdistlist(~isnan(midNSMRSdistlist)); midNSnMRSCoAlist = midNSnMRSCoAlist(~isnan(midNSnMRSdistlist)); midNSnMRSdistlist = midNSnMRSdistlist(~isnan(midNSnMRSdistlist));
nonMRScorrlist = nonMRScorrlist(~isnan(nonMRSdistlist)); nonMRSnoisecorrlist = nonMRSnoisecorrlist(~isnan(nonMRSdistlist)); nonMRSdistlist = nonMRSdistlist(~isnan(nonMRSdistlist));

% tempNCdist = AllNewSpinetoMRSDistances; 
% tempNCdist = tempNCdist(~isnan(AllNoiseCorr));
% AllNoiseCorr = AllNoiseCorr(~isnan(AllNoiseCorr));

enlargedCompDistList = AllNewSpinetoMRSDistances(~ismember(corrlist, CorrwithClosestEnlargedSpine));
enlargedCompCorrList = corrlist(~ismember(corrlist, CorrwithClosestEnlargedSpine));
enlargedCompCoAList = MRScoAlist(~ismember(corrlist, CorrwithClosestEnlargedSpine));


%==========================================================================
%%% Set up lists of all spines' coactivity, and separate into specified
%%% pairs, such as MRS-MRS pairs, nonMRS-nonMRS pairs, etc.

allspineEarlycoAlist = cell2mat(horzcat(AllSpinesEarlyCoActiveRatesGeoNormalized{:}));
allspinecoAlist = cell2mat(horzcat(AllSpinesLateCoActiveRatesGeoNormalized{:}));
    temp = horzcat(AllMovementSpines{:});
    CoAListReorg = mat2cell(allspinecoAlist, 1, cellfun(@(x) nchoosek(length(x),2), temp));
    bothEarlyMRS = cell2mat(cellfun(@(x,y) x(y(:,1)) & x(y(:,2)), cellfun(@(x) x(:,1), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');
    bothLateMRS = cell2mat(cellfun(@(x,y) x(y(:,1)) & x(y(:,2)), cellfun(@(x) x(:,end), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');
    
    neitherEarlyMRS = cell2mat(cellfun(@(x,y) ~x(y(:,1)) & ~x(y(:,2)), cellfun(@(x) x(:,1), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');
    neitherLateMRS = cell2mat(cellfun(@(x,y) ~x(y(:,1)) & ~x(y(:,2)), cellfun(@(x) x(:,end), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');
    
    mixedEarly = cell2mat(cellfun(@(x,y) (~x(y(:,1)) & x(y(:,2))) | (x(y(:,1)) & ~x(y(:,2))), cellfun(@(x) x(:,1), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');
    mixedLate = cell2mat(cellfun(@(x,y) (~x(y(:,1)) & x(y(:,2))) | (x(y(:,1)) & ~x(y(:,2))), cellfun(@(x) x(:,end), temp, 'uni', false), cellfun(@(z) nchoosek(1:length(z),2), temp, 'uni', false), 'uni', false)');

AllEarlyMRSCoAList = allspineEarlycoAlist(bothEarlyMRS); 
AllLateMRSCoAList = allspinecoAlist(bothLateMRS); 
AllEarlynonMRSCoAList = allspineEarlycoAlist(neitherEarlyMRS);
AllLatenonMRSCoAList = allspinecoAlist(neitherLateMRS);
AllMixedEarlyCoAList = allspineEarlycoAlist(mixedEarly);
AllMixedLateCoAList = allspinecoAlist(mixedLate);

allinterspinedistlist = cell2mat(horzcat(AllInterSpineDistancesList{:}));
BothEarlyMRSDistList = allinterspinedistlist(bothEarlyMRS);
BothLateMRSDistList = allinterspinedistlist(bothLateMRS);
NeitherEarlyMRSDistList = allinterspinedistlist(neitherEarlyMRS);
NeitherLateMRSDistList = allinterspinedistlist(neitherLateMRS);
MixedEarlyDistList = allinterspinedistlist(mixedEarly);
MixedLateDistList = allinterspinedistlist(mixedLate);

%==========================================================================

simcorr = []; simwithincorr = []; simtranscorr = []; simtransCoA = [];
imrawcorr = []; simnoisecorr = []; simmidcorr = []; simmidCoA = [];  simnonMRScorr = []; 
simnonMRSnoisecorr = []; simpersist = []; simgained = []; simfrac = []; 

for shuff = 1:1000
    [~,ind] = sort(shake(AllNewSpinetoMRSDistances));
    simDP(:,shuff) = DotProducts(ind);
    simcorr(:,shuff) = AllMMCorr(ind);
    simwithincorr(:,shuff) = WithinMovCorr(ind);
    simVelSD(:,shuff) = AllLeverVelocitySD(ind);
    simRewFrac(:,shuff) = IsRew(ind);
    [~,ind] = sort(shake(nMRSTransDistances));
%     simtranscorr(:,shuff) = AllTransCorr(ind);
    simtransCoA(:,shuff) = nMRSTransCoA(ind); 
    [~,ind] = sort(shake(AllNewSpinetoMRSDistances));
    simcorr(:,shuff) = corrlist(ind);
    simrawcorr(:,shuff) = rawcorrlist(ind);
    simnoisecorr(:,shuff) = noisecorrlist(ind);
    [~,ind] = sort(shake(midNSMRSdistlist));
    simmidcorr(:,shuff) = midcorrlist(ind); 
    simmidCoA(:,shuff) = midNSMRSCoAlist(ind);
    [~,nMRSind] = sort(shake(nonMRSdistlist));
    simnonMRScorr(:,shuff) = nonMRScorrlist(nMRSind);
    simnonMRSnoisecorr(:,shuff) = nonMRSnoisecorrlist(nMRSind);
    [~,persind] = sort(shake(GainedLostPersDistList));
    simpersist(:,shuff) = persistentMRSs(persind);
    [~,gainedind] = sort(shake(GainedLostPersDistList));
    simgained(:,shuff) = gainedMRSs(gainedind);
    [~,fracind] = sort(shake(AllNewSpinetoMRSDistances));    
    simfrac(:,shuff) = FractionofMovementsEncoded(fracind);
end

%==========================================================================
EarlyMRSPairBins = []; EarlyMRSPairBinsError = []; LateMRSPairBins = []; LateMRSPairBinsError = []; 
MRSCoABins = []; nonMRSCoABins = []; MRSCoABinsError = []; nonMRSCoABinsError = []; 
DPBins = []; DPBinsError = []; CDPBins = []; CDPBinsSEM = []; MMBins = []; MMBinsError = []; ChanceMMBins = []; ChanceMMBinsSEM = []; SeedBins = []; SeedBinsError = []; LevVelSDBins = []; LevVelSDBinsError = []; WithinMovBins = []; WithinMovBinsError = []; ChanceWithinMovBins = []; ChanceWithinMovBinsSEM = []; IsRewBins = []; IsRewBinsError = []; IsChanceRewBins = []; IsChanceRewError = [];
TransBins = []; TransBinsSEM = []; ChanceTransBins = []; ChanceTransBinsSEM = []; nMRSTransCoABins = []; nMRSTransCoABinsError = []; ChanceTransCoABins = []; ChanceTransCoABinsError = [];
AllSpineCorrBins = []; AllSpineCorrBinsError = []; AllSpineEarlyCoABins = []; AllSpineEarlyCoABinsError = []; AllSpineCoABins = []; AllSpineCoABinsError = []; 
CorrBins = []; CorrBinsError = []; SimCorrBins = []; SimCorrBinsError = [];
EnlargedPartnerBins = []; EnlargedPartnerBinsError = []; EnlargedPartnerComp = []; EnlargedPartnerCompError = [];
RawCorrBins = []; RawCorrBinsError = []; SimRawCorrBins = []; SimRawCorrBinsError = []; 
MidCorrBins = []; MidCorrBinsError = []; SimMidCorrBins = []; SimMidCorrBinsError = []; 
NoiseCorrBins = []; NoiseCorrBinsError = []; SimNoiseCorrBins = []; SimNoiseCorrBinsError = [];
nonMRSCorrBins = []; nonMRSCorrBinsError = []; nonMRSSimCorrBins = []; nonMRSSimCorrBinsError = []; 
nonMRSNoiseCorrBins = []; nonMRSNoiseCorrBinsError = []; nonMRSSimNoiseCorrBins = []; nonMRSSimNoiseCorrBinsError = []; 

%%%
count = 1;
binsize = 5;
maxdist = 25;
xvals = 0:binsize:maxdist;
%%%

for i = xvals
    %======================================================================
    data = AllEarlyMRSCoAList(BothEarlyMRSDistList>=i & BothEarlyMRSDistList<i+binsize);
    EarlyMRSPairBins(count) = nanmean(data);
    EarlyMRSPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllEarlynonMRSCoAList(NeitherEarlyMRSDistList>=i & NeitherEarlyMRSDistList<i+binsize);
    EarlynonMRSPairBins(count) = nanmean(data);
    EarlynonMRSPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllLateMRSCoAList(BothLateMRSDistList>=i & BothLateMRSDistList<i+binsize);
    LateMRSPairBins(count) = nanmean(data);
    LateMRSPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllLatenonMRSCoAList(NeitherLateMRSDistList>=i & NeitherLateMRSDistList<i+binsize);
    LatenonMRSPairBins(count) = nanmean(data);
    LatenonMRSPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllMixedEarlyCoAList(MixedEarlyDistList>=i & MixedEarlyDistList<i+binsize);
    EarlyMixedPairBins(count) = nanmean(data);
    EarlyMixedPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllMixedLateCoAList(MixedLateDistList>=i & MixedLateDistList<i+binsize);
    LateMixedPairBins(count) = nanmean(data);
    LateMixedPairBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    %======================================================================
    data = DotProducts(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    DPBins(count) = nanmean(data);
    DPBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimDPvals = simDP(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    CDPBins(count) = nanmean(allsimDPvals(:));
    CDPBinsSEM(count) = nanstd(allsimDPvals(:))/sqrt(sum(~isnan(data)));
    
    data = AllMMCorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    MMBins(count) = nanmean(data);
    MMBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simcorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    ChanceMMBins(count) = nanmean(allsimcorrvals(:));
    ChanceMMBinsSEM(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
%     data = AllSeedlingMovCorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
%     SeedBins(count) = nanmean(data);
%     SeedBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllLeverVelocitySD(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    LevVelSDBins(count) = nanmedian(data);
    LevVelSDBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimvals = simVelSD(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    ChanceVelSDBins(count) = nanmean(allsimvals(:));
    ChanceVelSDBinsSEM(count) = nanstd(allsimvals(:))/sqrt(sum(~isnan(data)));
    
    data = WithinMovCorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    WithinMovBins(count) = nanmean(data);
    WithinMovBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simwithincorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    ChanceWithinMovBins(count) = nanmean(allsimcorrvals(:));
    ChanceWithinMovBinsSEM(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
    data = IsRew(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    IsRewBins(count) = nanmean(data);
    IsRewBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimfracvals = simRewFrac(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    IsChanceRewBins(count) = nanmean(allsimfracvals(:));
    IsChanceRewError(count) = nanstd(allsimfracvals(:))/sqrt(sum(~isnan(data)));
    
    %======================================================================
    data = allspinecorrlist(allspinedistlist>=i & allspinedistlist<i+binsize);
    AllSpineCorrBins(count) = nanmean(data);
    AllSpineCorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = allspineEarlycoAlist(allinterspinedistlist>=i & allinterspinedistlist<i+binsize);
    AllSpineEarlyCoABins(count) = nanmean(data);
    AllSpineEarlyCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = allspinecoAlist(allinterspinedistlist>=i & allinterspinedistlist<i+binsize);
    AllSpineCoABins(count) = nanmean(data);
    AllSpineCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = corrlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    CorrBins(count) = nanmean(data);
    CorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
%     CorrBinsError(count,:) = bootci(bootstrpnum, {@median, corrlist(tempdist>=i & tempdist<i+binsize)}, 'alpha', alphaforbootstrap);
    allsimcorrvals = simcorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    SimCorrBins(count) = nanmean(allsimcorrvals(:));
    SimCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
%     SimCorrBinsError(count,:) = bootci(bootstrpnum, {@median, nanmean(allsimcorrvals,2)}, 'alpha', alphaforbootstrap);

    data = CorrwithClosestEnlargedSpine(ClosestEnlargedMRSList>=i & ClosestEnlargedMRSList<i+binsize);
    EnlargedPartnerBins(count) = nanmean(data);
    EnlargedPartnerBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    data = enlargedCompCorrList(enlargedCompDistList>=i & enlargedCompDistList<i+binsize);
    EnlargedPartnerComp(count) = nanmean(data);
    EnlargedPartnerCompError(count) = nanstd(data)/sqrt(sum(~isnan(data)));

    data = rawcorrlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    RawCorrBins(count) = nanmean(data);
    RawCorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simrawcorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    SimRawCorrBins(count) = nanmean(allsimcorrvals(:));
    SimRawCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
    %======================================================================
    data = MRScoAlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize);
    MRSCoABins(count) = nanmean(data);
    MRSCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = CoARatewithClosestEnlargedSpine(ClosestEnlargedMRSList>=i & ClosestEnlargedMRSList<i+binsize);
    EnlargedPartnerCoABins(count) = nanmean(data);
    EnlargedPartnerCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = nonMRScoAlist(AllNewSpinetonMRSDistances>=i & AllNewSpinetonMRSDistances<i+binsize);
    nonMRSCoABins(count) = nanmean(data);
    nonMRSCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));

    MidCorrBins(count) = nanmean(midcorrlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize));
    MidCorrBinsError(count) = nanstd(midcorrlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize))/sqrt(length(midcorrlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize)));
    
    MidNSMRSCoABins(count) = nanmean(midNSMRSCoAlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize));
    MidNSMRSCoABinsError(count) = nanstd(midNSMRSCoAlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize))/sqrt(length(midNSMRSCoAlist(midNSMRSdistlist>=i & midNSMRSdistlist<i+binsize)));
    
    MidNSnMRSCoABins(count) = nanmean(midNSnMRSCoAlist(midNSnMRSdistlist>=i & midNSnMRSdistlist<i+binsize));
    MidNSnMRSCoABinsError(count) = nanstd(midNSnMRSCoAlist(midNSnMRSdistlist>=i & midNSnMRSdistlist<i+binsize))/sqrt(length(midNSnMRSCoAlist(midNSnMRSdistlist>=i & midNSnMRSdistlist<i+binsize)));

%     
    data = nMRSTransCoA(nMRSTransDistances>=i & nMRSTransDistances<i+binsize);
    nMRSTransCoABins(count) = nanmean(data);
    nMRSTransCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = MRSTransCoA(MRSTransDistances>=i & MRSTransDistances<i+binsize);
    MRSTransCoABins(count) = nanmean(data);
    MRSTransCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));


    %======================================================================
    NoiseCorrBins(count) = nanmean(noisecorrlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize));
    NoiseCorrBinsError(count) = nanstd(noisecorrlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize))/sqrt(length(noisecorrlist(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize)));
    allsimcorrvals = simnoisecorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    SimNoiseCorrBins(count) = nanmean(allsimcorrvals(:));
    SimNoiseCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(AllNoiseCorr(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize)));
    
    nonMRSCorrBins(count) = nanmean(nonMRScorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize));
    nonMRSCorrBinsError(count) = nanstd(nonMRScorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize))/sqrt(length(nonMRScorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize)));
    allsimcorrvals = simnonMRScorr(nonMRSdistlist>=i & nonMRSdistlist<i+binsize,:);
    nonMRSSimCorrBins(count) = nanmean(allsimcorrvals(:));
    nonMRSSimCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(nonMRSnoisecorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize)));
    nonMRSNoiseCorrBins(count) = nanmean(nonMRSnoisecorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize));
    nonMRSNoiseCorrBinsError(count) = nanstd(nonMRSnoisecorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize))/sqrt(length(nonMRSnoisecorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize)));
    allsimcorrvals = simnonMRSnoisecorr(nonMRSdistlist>=i & nonMRSdistlist<i+binsize,:);
    nonMRSSimNoiseCorrBins(count) = nanmean(allsimcorrvals(:));
    nonMRSSimNoiseCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(nonMRSnoisecorrlist(nonMRSdistlist>=i & nonMRSdistlist<i+binsize)));
    %======================================================================

    data = persistentMRSs(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize);
    PersMRSBins(count) = nanmean(data);
    PersMRSBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simpersist(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize);
    SimPersMRSBins(count) = nanmean(allsimcorrvals(:));
    SimPersMRSBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(persistentMRSs(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize)));
    
    data = gainedMRSs(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize);
    GainedMRSBins(count) = nanmean(data);
    GainedMRSBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simgained(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize);
    SimGainedMRSBins(count) = nanmean(allsimcorrvals(:));
    SimGainedMRSBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(gainedMRSs(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize)));
    
    data = lostMRSs(GainedLostPersDistList>=i & GainedLostPersDistList<i+binsize);
    LostMRSBins(count) = nanmean(data);
    LostMRSBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    FracBin(count) = nanmean(FractionofMovementsEncoded(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize));
    FracBinError(count) = nanstd(FractionofMovementsEncoded(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize))/sqrt(length(FractionofMovementsEncoded(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize)));
    allsimfractions = simfrac(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize,:);
    SimFracBin(count) = nanmean(allsimfractions(:));
    SimFracBinError(count) = nanstd(allsimfractions(:))/sqrt(length(FractionofMovementsEncoded(AllNewSpinetoMRSDistances>=i & AllNewSpinetoMRSDistances<i+binsize)));
        
    data = AllLateMRSVolumeChangeswrtNS(LateMRSPlasticityDistList>=i & LateMRSPlasticityDistList<i+binsize);
    AllLateSpineVolumeBins(count) = nanmean(data);
    AllLateSpineVolumeBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));
    
    data = AllEarlyMRSVolumeChangeswrtNS(EarlyMRSPlasticityDistList>=i & EarlyMRSPlasticityDistList<i+binsize);
    AllEarlySpineVolumeBins(count) = nanmean(data);
    AllEarlySpineVolumeBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));
        
    data = EarlyMRSPlasticityIndexwrtNS(EarlyMRSPlasticityDistList>=i & EarlyMRSPlasticityDistList<i + binsize);
    AllEarlyEnlargedBins(count) = nanmean(data);
    AllEarlyEnlargedBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));
    
    data = EarlyMRSDepressionIndexwrtNS(EarlyMRSPlasticityDistList>=i & EarlyMRSPlasticityDistList<i + binsize);
    AllEarlyDepressedBins(count) = nanmean(data);
    AllEarlyDepressedBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));

    data = EarlynonMRSPlasticityIndexwrtNS(EarlynonMRSPlasticityDistList>=i & EarlynonMRSPlasticityDistList<i+binsize);
    AllnonEarlyMRSEnlargedBins(count) = nanmean(data);
    AllnonEarlyMRSEnlargedBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));

    data = EarlynonMRSDepressionIndexwrtNS(EarlynonMRSPlasticityDistList>=i & EarlynonMRSPlasticityDistList<i+binsize);
    AllnonEarlyMRSDepressedBins(count) = nanmean(data);
    AllnonEarlyMRSDepressedBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));

    data = LateMRSPlasticityIndexwrtNS(LateMRSPlasticityDistList>=i & LateMRSPlasticityDistList<i + binsize);
    AllLateEnlargedBins(count) = nanmean(data);
    AllLateEnlargedBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));
    
    count = count+1;
end

%==========================================================================

figure('Name', 'Preexisting spine pairs over learning'); 

s1 = subplot(1,2,1); hold on; 
errorbar(xvals+(binsize/2), EarlyMRSPairBins, EarlyMRSPairBinsError, 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), EarlynonMRSPairBins, EarlynonMRSPairBinsError, 'color', dred, 'linewidth', 2)
errorbar(xvals+(binsize/2), EarlyMixedPairBins, EarlyMixedPairBinsError, 'color', blue, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Norm. CoActivity Rate')
title('Early Sessions')

s2 = subplot(1,2,2); hold on; 
errorbar(xvals+(binsize/2), LateMRSPairBins, LateMRSPairBinsError, 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), LatenonMRSPairBins, LatenonMRSPairBinsError, 'color', dred, 'linewidth', 2)
errorbar(xvals+(binsize/2), LateMixedPairBins, LateMixedPairBinsError, 'color', blue, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Norm. CoActivity Rate')
title('Late Sessions')

legend({'MRS-MRS', 'nMRS-nMRS', 'Mixed'})

linkaxes([s1,s2], 'y')

%==========================================================================

figure('Name', 'NS CoActivity Rates'); hold on;

errorbar(xvals+(binsize/2), MRSCoABins, MRSCoABinsError, 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), nonMRSCoABins, nonMRSCoABinsError, 'color', dred, 'linewidth', 2)
% errorbar(xvals+(binsize/2), EnlargedPartnerCoABins, EnlargedPartnerCoABinsError, 'color', lpurple, 'linewidth', 2)
set(gca, 'XTick', xvals+(binsize/2))
xlabel('Distance Bins')
ylabel('Norm. CoActivity Rate')
legend({'NS-MRS', 'NS-nMRS'})

%==========================================================================

figure('Name', 'Transient vs Sustained New Spine CoActivity Rates'); hold on;

errorbar(xvals+(binsize/2), MidNSMRSCoABins, MidNSMRSCoABinsError, 'color', green, 'linewidth', 2)
errorbar(xvals+(binsize/2), MidNSnMRSCoABins, MidNSnMRSCoABinsError, 'color', lgreen, 'linewidth', 2)

errorbar(xvals+(binsize/2), MRSTransCoABins, MRSTransCoABinsError, 'color', purple, 'linewidth', 2)
errorbar(xvals+(binsize/2), nMRSTransCoABins, nMRSTransCoABinsError, 'color', lpurple, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Norm. CoActivity Rate')
legend({'Sustained MRS', 'Sustained nonMRS', 'Transient MRS', 'Transient nonMRS'})

%==========================================================================

figure('Name', 'Behavioral Features of NS CoActivity'); 

subplot(2,2,1)
errorbar(xvals+(binsize/2), DPBins, DPBinsError, 'color', dred, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Norm. Act-Mov Dot Product')

subplot(2,2,2)
errorbar(xvals+(binsize/2), FracBin, FracBinError, 'color', blue, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Fract. Mvmts Encoded')

subplot(2,2,3)
errorbar(xvals+(binsize/2), MMBins, MMBinsError, 'color', orange, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Corr. with LMP')

subplot(2,2,4)
errorbar(xvals+(binsize/2), LevVelSDBins, LevVelSDBinsError, 'color', purple, 'linewidth', 2)
xlabel('Distance Bins')
ylabel('Lev. Vel. SD')

%==========================================================================
figure; hold on; 

CoAbyCluster = vertcat(CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{:});
CoAbyCluster = CoAbyCluster(~cellfun(@isempty, CoAbyCluster));

AllMRSDMmodelcorrbyfield = horzcat(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{:});
AllMRSDMmodelcorrbyfield = AllMRSDMmodelcorrbyfield(~cellfun(@isempty, AllMRSDMmodelcorrbyfield));
AllMRSDMmodelcorrbyfield  = cellfun(@(x) horzcat(x{:}), AllMRSDMmodelcorrbyfield , 'uni', false);
AllMRSDMmodelcorrbyfield = cellfun(@cell2mat, AllMRSDMmodelcorrbyfield, 'uni', false);

AllNSDMmodelcorrbyfield = horzcat(NSDMControlMovementsCorrelationwithModelMovementbyCluster{:});
AllNSDMmodelcorrbyfield = AllNSDMmodelcorrbyfield(~cellfun(@isempty, AllNSDMmodelcorrbyfield));
AllNSDMmodelcorrbyfield  = cellfun(@cell2mat, AllNSDMmodelcorrbyfield , 'uni', false);

AllDistMatchedbyField = cellfun(@(x,y) [x,y], AllMRSDMmodelcorrbyfield, AllNSDMmodelcorrbyfield, 'uni', false);

CoActiveClusterMovementsCorrelationwithModelMovement{12}{2} = nan;

datamat = [{cellfun(@nanmedian, vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, vertcat(NSActivityOnlyMovementsCorrelationwithModelMovement{:}))},{cellfun(@nanmedian, vertcat(MRSOnlyMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(FMControlMovementsCorrelationwithModelMovement{:}))'},{cellfun(@nanmedian, AllDistMatchedbyField)'}, {cellfun(@nanmedian, horzcat(AllOtherMovementsCorrelationwithModelMovement{:}))'}];
subplot(1,2,1)
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clust CoA', 'NS only', 'MRS only', 'FM ctrls', 'Dist-Matched', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Corr. of Mvmts with Model')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

for i = 2:length(datamat)
    [p,~] = ranksum(datamat{1},datamat{i});
    if p<0.05
        if p < 0.001
            statsymbol = '***';
        elseif p<0.01
            statsymbol = '**';
        elseif p<0.05
            statsymbol = '*';
        end
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'g')
        text(mean([1,(i)])-0.1, maxline+0.01, statsymbol)
    else
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
    end
    maxline = maxline+statline_increment;
end


subplot(1,2,2)
plot([ones(1,length(datamat{1}));2*ones(1,length(datamat{6}))], [datamat{1}';datamat{6}'], '-ok')
xlim([0 3])

hold on; plot([0.75 1.25], [nanmedian(datamat{1}) nanmedian(datamat{1})], 'color', lblue, 'linewidth', 2)
hold on; plot([1.75 2.25], [nanmedian(datamat{6}) nanmedian(datamat{6})], 'color', dred, 'linewidth', 2)

%%% If you want to exclude values above CoA_Cutoff, run the following
% count = 1; temp = []; 
% for i = 1:length(CoAbyCluster)
%     if ~isempty(CoAbyCluster{i})
%         for j = 1:length(CoAbyCluster{i})
%             if ~isempty(CoAbyCluster{i}{j})
%                 for k = 1:length(CoAbyCluster{i}{j})
%                     if ~isempty(CoAbyCluster{i}{j}{k})
%                         if MRScoAlist(count) < CoA_Cutoff
%                             temp{i}{j}{k} = CoAbyCluster{i}{j}{k};
%                         else
%                             temp{i}{j}{k} = nan;
%                         end
%                         count = count+1;
%                     else
%                         temp{i}{j}{k} = CoAbyCluster{i}{j}{k};
%                         count = count+1;
%                     end
%                 end
%             else
%                 temp{i}{j} = CoAbyCluster{i}{j};
%                 count = count+1;
%             end
%         end
%     else
%         temp{i} = CoAbyCluster{i};
%     end
% end

%==========================================================================

figure; 

subplot(1,2,1)
errorbar(xvals+(binsize/2), PersMRSBins, PersMRSBinsError, 'color', purple, 'linewidth', 2)
xlabel('Distance from NS')
ylabel('Probability')
title('Persistence of MRS')

subplot(1,2,2); hold on;
errorbar(xvals+(binsize/2), GainedMRSBins, GainedMRSBinsError, 'color', green, 'linewidth', 2)
errorbar(xvals+(binsize/2), LostMRSBins, LostMRSBinsError, 'color', red, 'linewidth',2)
legend({'Gained MRS', 'Lost MRS'})
xlabel('Distance from NS')
ylabel('Probability')


%==========================================================================
figure; 

normalize = 0;

subplot(2,2,1); hold on; 
histogram(ClosestEarlyMRS, 'normalization', 'probability', 'binedges', 0:1:50, 'FaceColor', lgreen)
histogram(nonNSClosestEarlyMRS, 'normalization', 'probability', 'binedges', 0:1:50, 'FaceColor', gray)

subplot(2,2,2); hold on; 
histogram(ClosestEarlynonMRS, 'normalization', 'probability', 'binedges', 0:1:50, 'FaceColor', dred)
histogram(nonNSClosestEarlynonMRS, 'normalization', 'probability', 'binedges', 0:1:50, 'FaceColor', gray)

subplot(2,2,3); hold on; 
if normalize
    histogram(nonNSEarlyMRSEnvironment./nonNS_Range, 'normalization', 'probability', 'binedges', 0:0.2:2, 'FaceColor', gray)
    histogram(NearbyEarlyMRSEnvironment./NS_Range, 'normalization', 'probability', 'binedges', 0:0.2:2, 'FaceColor', lgreen)
    xlabel('Nearby Early MRS Density')
else
    histogram(nonNSEarlyMRSEnvironment, 'normalization', 'probability', 'binedges', 0:1:20, 'FaceColor', gray)
    histogram(NearbyEarlyMRSEnvironment, 'normalization', 'probability', 'binedges', 0:1:20, 'FaceColor', lgreen)
    xlabel('Num. Nearby Early MRSs')
end
ylabel('Probability')


subplot(2,2,4); hold on; 
if normalize
    histogram(nonNSEarlynonMRSEnvironment./nonNS_Range, 'normalization', 'probability', 'binedges', 0:0.2:2, 'FaceColor', gray)
    histogram(NearbyEarlynonMRSEnvironment./NS_Range, 'normalization', 'probability', 'binedges', 0:0.2:2, 'FaceColor', dred)
    xlabel('Nearby Early MRS Density')
else
    histogram(nonNSEarlynonMRSEnvironment, 'normalization', 'probability', 'binedges', 0:1:20, 'FaceColor', gray)
    histogram(NearbyEarlynonMRSEnvironment, 'normalization', 'probability', 'binedges', 0:1:20, 'FaceColor', dred)
    xlabel('Num. Nearby Early MRSs')
end

ylabel('Probability')
xlabel('Num. Nearby Early nonMRSs')

%==========================================================================
%%% Spine Density of different types

count = 1;
binsize = 5;
maxdist = 25;
xvals = 0:binsize:maxdist;

figure; hold on; 

errorbar(xvals+(binsize/2), nanmean(NSMRSDensity,1), nanstd(NSMRSDensity,[],1)./sqrt(sum(~isnan(NSMRSDensity))), 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), nanmean(NSnonMRSDensity,1), nanstd(NSnonMRSDensity,[],1)./sqrt(sum(~isnan(NSnonMRSDensity))), 'color', dred, 'linewidth', 2)
errorbar(xvals+(binsize/2), nanmean(NSAllSpineDensity,1), nanstd(NSAllSpineDensity,[],1)./sqrt(sum(~isnan(NSAllSpineDensity))), 'color', blue, 'linewidth', 2)
legend({'MRS Density', 'nonMRS Density', 'Spine Density'})
xlabel('Distance from NS')
ylabel('Spine Density')

figure; hold on; 

errorbar(xvals+(binsize/2), nanmean(nonNSMRSDensity,1), nanstd(nonNSMRSDensity,[],1)./sqrt(sum(~isnan(nonNSMRSDensity))), 'color', black, 'linewidth', 2)
errorbar(xvals+(binsize/2), nanmean(nonNSnonMRSDensity,1), nanstd(nonNSnonMRSDensity,[],1)./sqrt(sum(~isnan(nonNSnonMRSDensity))), 'color', gray, 'linewidth', 2)
legend({'MRS Density', 'nonMRS Density'})
xlabel('Distance from nonNS')
ylabel('Spine Density')

%==========================================================================

figure; 

subplot(1,3,1); hold on; 
errorbar(xvals+(binsize/2), AllEarlySpineVolumeBins, AllEarlySpineVolumeBinsError, 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), AllLateSpineVolumeBins, AllLateSpineVolumeBinsError, 'color', black, 'linewidth', 2)
xlabel('Distance from NS')
ylabel('SpineVolume Change')
legend({'Early MRS', 'Late MRS'})

subplot(1,3,2); hold on;
errorbar(xvals+(binsize/2), AllEarlyEnlargedBins, AllEarlyEnlargedBinsError, 'color', lgreen, 'linewidth', 2)
errorbar(xvals+(binsize/2), AllnonEarlyMRSEnlargedBins, AllnonEarlyMRSEnlargedBinsError, 'color', gray, 'linewidth', 2)
errorbar(xvals+(binsize/2), AllLateEnlargedBins, AllLateEnlargedBinsError, 'color', black, 'linewidth', 2)
xlabel('Distance from NS')
ylabel(['Probability of \DeltaV >=', num2str(spine_enlargement_cutoff)])
legend({'Early MRS', 'Early nMRS', 'Late MRS'})

subplot(1,3,3); hold on;
errorbar(xvals+(binsize/2), AllEarlyDepressedBins, AllEarlyDepressedBinsError, 'color', red, 'linewidth', 2)
errorbar(xvals+(binsize/2), AllnonEarlyMRSDepressedBins, AllnonEarlyMRSDepressedBinsError, 'color', gray, 'linewidth', 2)
xlabel('Distance from NS')
ylabel(['Probability of \DeltaV <= ', num2str(spine_shrinkage_cutoff)])
legend({'Early MRS', 'Early nMRS'})

%==========================================================================
simNewSpineList = [];
SimNewSpinetoEarlyMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoPrevSeshMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoLateMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoPersMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoGainedMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoEnlargedSpineDistance = nan(1,shuffnum); 
SimNewSpinetoEnlargedMRSDistance = nan(1,shuffnum);
SimNewSpinetoEnlargedPersMRSDistance = nan(1,shuffnum);
SimNewSpinetoEnlargedGainedMRSDistance = nan(1,shuffnum);

mockearlynewspinedistribution = cell(1,shuffnum);
mockearlyMRSenvironment = cell(1,shuffnum);
mockprevseshnewspinedistribution = cell(1,shuffnum);
mockprevseshMRSenvironment = cell(1,shuffnum);
mocklatenewspinedistribution = cell(1,shuffnum);
mocklateMRSenvironment = cell(1,shuffnum);
mockpersMRSenvironment = cell(1,shuffnum);
mockpersnewspinedistribution = cell(1,shuffnum); 
mockgainednewspinedistribution = cell(1,shuffnum);
mockearlyenlargedspinesdistribution = cell(1,shuffnum);
ShuffledVolumeIncreaseDistances = cell(1,shuffnum);
ShuffledVolumeIncreasewithMRSDistances = cell(1,shuffnum);
ShuffledVolumeIncreasewithPersMRSDistances = cell(1,shuffnum);
ShuffledVolumeIncreasewithGainedMRSDistances = cell(1,shuffnum);

%%% Determine whether each NS appears on the middle or late session, which
%%% will allow you to simulate the effect of this variable instead of
%%% always taking the early session
count= 1;
dudcount = 1;
max_reshuffles = 100; 
for i = 1:length(NewSpines)
    for j = 1:length(NewSpines{i})
        for k = 1:length(NewSpines{i}{j})
            isMid(count) = ismember(NewSpines{i}{j}(k), MiddleSessionNewSpines{i}{j});
            count = count+1;
        end
    end
end

for i = 1:shuffnum
    mockearlynewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    mockprevseshnewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    mocklatenewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    mockpersnewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    mockgainednewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    for j = 1:sum(NumberofNewSpines)
        
        %==================================================================
        %%% Select random data within the set
        randAnimal = randi([1,length(AllDendriteDistances)],1);
        randField = randi([1,length(AllDendriteDistances{randAnimal})]);
        randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
        spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
        DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        DistancesfromRandDend(1:1+size(DistancesfromRandDend,1):numel(DistancesfromRandDend)) = 0;
        [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
        simNewSpine = randi([0,4*ceil(dendLength)])/4; %%% The 2x multiplier is to provide 0,5um precision   
        % Exclude real new spines from consideration
        if ~isempty(NewSpines{randAnimal})
            try
                RealNewSpines = NewSpines{randAnimal}{randField};
            catch
                RealNewSpines = [];
            end
            try 
                RealNewSpines = union(RealNewSpines, MiddleSessionNewSpines{randAnimal}{randField});
            catch
            end
        else
            RealNewSpines = [];
        end
        RealNewSpines = RealNewSpines(RealNewSpines>= spinesfromrandDend(1) & RealNewSpines<= spinesfromrandDend(end));
        if ~isempty(RealNewSpines)
            RealNewSpinePos = DistancesfromRandDend(longeststretch,logical(sum(spinesfromrandDend == RealNewSpines,1))); % when finding multiple (n x 1) indices from a 1 x m matrix, Matlab creates a n x m matrix, which needs to be collapsed in the n dimension to return indices compatible with the original searched 1 x m matrix
            %%% Add contingency to not consider sim NSs that are similar to the
            %%% real ones
            attempts = 1;
            while any(RealNewSpinePos-simNewSpine<5) && attempts < max_reshuffles
                simNewSpine = randi([0,4*ceil(dendLength)])/4; %%% The 2x multiplier is to provide 0,5um precision 
                attempts = attempts+1;
            end
        end
        simNewSpineList = [simNewSpineList; simNewSpine];
        RelativeDistances = abs(DistancesfromRandDend(longeststretch,:)-simNewSpine);

        %==================================================================
        % Define MRSs from the above selected data
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end); %%% 'end' index corresponds to late session
        if isMid(j)
            prev_sesh_MRS = EarlyMovementSpines;
            MidMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,2);
        else
            if size(AllMovementSpines{randAnimal}{randField},2)> 2
                MidMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,2);
                prev_sesh_MRS = MidMovementSpines;
%                 MRSs_to_use = LateMovementSpines;
            else
                MidMovementSpines = zeros(length(EarlyMovementSpines),1);
                prev_sesh_MRS = EarlyMovementSpines;
%                 MRSs_to_use = LateMovementSpines;
            end
        end 
        PersMovementSpines = (EarlyMovementSpines | MidMovementSpines) & LateMovementSpines; 
        GainedMovementSpines = diff([EarlyMovementSpines, LateMovementSpines],[],2)>0;
        %==================================================================

        EarlyMovementSpines(RealNewSpines) = 0; 
        prev_sesh_MRS(RealNewSpines) = 0; 
        MidMovementSpines(RealNewSpines) = 0; 
        LateMovementSpines(RealNewSpines) = 0; 
        PersMovementSpines(RealNewSpines) = 0; 
        GainedMovementSpines(RealNewSpines) = 0; 
        %==================================================================
        if ~any(EarlyMovementSpines)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mockearlynewspinedistribution{i}(j) = nan;
        else
            mockearlynewspinedistribution{i}(j) = nanmin(RelativeDistances(EarlyMovementSpines));
        end
        mockearlyMRSenvironment{i}(j) = sum(RelativeDistances(EarlyMovementSpines)<=distance_cutoff);
        if ~any(prev_sesh_MRS)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mockprevseshnewspinedistribution{i}(j) = nan;
        else
            mockprevseshnewspinedistribution{i}(j) = nanmin(RelativeDistances(prev_sesh_MRS));
        end
        mockprevseshMRSenvironment{i}(j) = sum(RelativeDistances(prev_sesh_MRS)<=distance_cutoff);
        if ~any(LateMovementSpines)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mocklatenewspinedistribution{i}(j) = nan;
        else
            mocklatenewspinedistribution{i}(j) = nanmin(RelativeDistances(LateMovementSpines));
        end
        mocklateMRSenvironment{i}(j) = sum(RelativeDistances(LateMovementSpines)<=distance_cutoff);
        if ~any(PersMovementSpines)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mockpersnewspinedistribution{i}(j) = nan;
        else
            mockpersnewspinedistribution{i}(j) = nanmin(RelativeDistances(PersMovementSpines));
        end
        mockpersMRSenvironment{i}(j) = sum(RelativeDistances(PersMovementSpines)<=distance_cutoff);
        if ~any(GainedMovementSpines)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mockgainednewspinedistribution{i}(j) = nan;
        else
            mockgainednewspinedistribution{i}(j) = nanmin(RelativeDistances(GainedMovementSpines));
        end
        %==================================================================
        % Add plasticity to the mix
        if ~isempty(AllSpineVolumeData{randAnimal}{randField})
            if size(AllMovementSpines{randAnimal}{randField},1)> 2
                if isMid
                    SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,2)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,1);
                else
                    SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,end)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,1);
                end
            else
                SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,end)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,1);
            end
            SpineVol(SpineVol==Inf) = NaN;
            SpineVol(RealNewSpines) = NaN;
            VolIncreaseIndex = SpineVol >= spine_enlargement_cutoff;
            %==============================================================
            PlasticityAlone = VolIncreaseIndex;
            if ~any(PlasticityAlone)
%                 PlasticityContingency([1,end]) = 1;
                dudcount = dudcount+1;
                ShuffledVolumeIncreaseDistances{i}{j} = nan;
            else
                ShuffledVolumeIncreaseDistances{i}{j} = nanmin(RelativeDistances(PlasticityAlone));
            end
            mockearlyenlargedspinesdistribution{i}(j) = sum(RelativeDistances(VolIncreaseIndex)<distance_cutoff);
            PlasticitywithEarlyMRS = VolIncreaseIndex & (prev_sesh_MRS);
            if ~any(PlasticitywithEarlyMRS)
%                 PlasticityContingency([1,end]) = 1;
                dudcount = dudcount+1;
                ShuffledVolumeIncreasewithMRSDistances{i}{j} = nan;
            else
                ShuffledVolumeIncreasewithMRSDistances{i}{j} = nanmin(RelativeDistances(PlasticitywithEarlyMRS));
            end
            PlasticitywithPersMRS = VolIncreaseIndex & (PersMovementSpines);
            if ~any(PlasticitywithPersMRS)
%                 PlasticityContingency([1,end]) = 1;
                dudcount = dudcount+1;
                ShuffledVolumeIncreasewithPersMRSDistances{i}{j} = nan;
            else
                ShuffledVolumeIncreasewithPersMRSDistances{i}{j} = nanmin(RelativeDistances(PlasticitywithPersMRS));
            end
            PlasticitywithGainedMRS = VolIncreaseIndex & (PersMovementSpines);
            if ~any(PlasticitywithGainedMRS)
%                 PlasticityContingency([1,end]) = 1;
                dudcount = dudcount+1;
                ShuffledVolumeIncreasewithGainedMRSDistances{i}{j} = nan;
            else
                ShuffledVolumeIncreasewithGainedMRSDistances{i}{j} = nanmin(RelativeDistances(PlasticitywithGainedMRS));
            end
            
            %==============================================================
        else
            ShuffledVolumeIncreaseDistances{i}{j} = nan;
        end
        %%%
    end
    %================================Stats=================================
    SimNewSpinetoEarlyMovementSpineDistance(i) = nanmedian(mockearlynewspinedistribution{i});
        if SimNewSpinetoEarlyMovementSpineDistance(i) > nanmedian(ClosestEarlyMRS)
            NewSpineEarlyMoveSpinesNullDistTest(i) = 1;
        else
            NewSpineEarlyMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpineLocalEarlyMRSEnvironment(i) = nanmedian(mockearlyMRSenvironment{i});
        if SimNewSpineLocalEarlyMRSEnvironment(i) < nanmedian(NearbyEarlyMRSEnvironment)
            LocalEarlyMRSEnvironmentNullDistTest(i) = 1;
        else
            LocalEarlyMRSEnvironmentNullDistTest(i) = 0;
        end
    SimNewSpinetoPrevSeshMovementSpineDistance(i) = nanmedian(mockprevseshnewspinedistribution{i});
        if SimNewSpinetoPrevSeshMovementSpineDistance(i) > nanmedian(ClosestPrevSeshMRS)
            NewSpinePrevSeshMoveSpinesNullDistTest(i) = 1;
        else
            NewSpinePrevSeshMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpineLocalPrevSeshMRSEnvironment(i) = nanmedian(mockprevseshMRSenvironment{i});
        if SimNewSpineLocalPrevSeshMRSEnvironment(i) < nanmedian(NearbyPrevSeshMRSEnvironment)
            LocalPrevSeshMRSEnvironmentNullDistTest(i) = 1;
        else
            LocalPrevSeshMRSEnvironmentNullDistTest(i) = 0;
        end
    SimNewSpinetoLateMovementSpineDistance(i) = nanmedian(mocklatenewspinedistribution{i});
        if SimNewSpinetoLateMovementSpineDistance(i) > nanmedian(ClosestLateMRS)
            NewSpineLateMoveSpinesNullDistTest(i) = 1;
        else
            NewSpineLateMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpineLocalLateMRSEnvironment(i) = nanmedian(mocklateMRSenvironment{i});
        if SimNewSpineLocalLateMRSEnvironment(i) < nanmedian(NearbyLateMRSEnvironment)
            LocalLateMRSEnvironmentNullDistTest(i) = 1;
        else
            LocalLateMRSEnvironmentNullDistTest(i) = 0;
        end
    SimNewSpinetoPersMovementSpineDistance(i) = nanmedian(mockpersnewspinedistribution{i});
        if SimNewSpinetoPersMovementSpineDistance(i) > nanmedian(ClosestPersMRS)
            NewSpinePersMoveSpinesNullDistTest(i) = 1;
        else
            NewSpinePersMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpineLocalPersMRSEnvironment(i) = nanmedian(mockpersMRSenvironment{i});
        if SimNewSpineLocalPersMRSEnvironment(i) < nanmedian(NearbyPersMRSEnvironment)
            LocalPersMRSEnvironmentNullDistTest(i) = 1;
        else
            LocalPersMRSEnvironmentNullDistTest(i) = 0;
        end
    SimNewSpinetoGainedMovementSpineDistance(i) = nanmedian(mockgainednewspinedistribution{i});
        if SimNewSpinetoGainedMovementSpineDistance(i) > nanmedian(ClosestGainedMRS)
            NewSpineGainedMoveSpinesNullDistTest(i) = 1;
        else
            NewSpineGainedMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpinetoEnlargedSpineDistance(i) = nanmedian(cell2mat(ShuffledVolumeIncreaseDistances{i}));
        if SimNewSpinetoEnlargedSpineDistance(i) > nanmedian(ClosestEnlargedSpineList)
            NewSpinetoEnlargedSpinesNullDistTest(i) = 1;
        else
            NewSpinetoEnlargedSpinesNullDistTest(i) = 0;
        end
    SimNewSpinetoEnlargedMRSDistance(i) = nanmedian(cell2mat(ShuffledVolumeIncreasewithMRSDistances{i}));
        if SimNewSpinetoEnlargedMRSDistance(i) > nanmedian(ClosestEnlargedMRSList)
            NewSpinetoEnlargedMRSNullDistTest(i) = 1;
        else
            NewSpinetoEnlargedMRSNullDistTest(i) = 0;
        end
    SimNewSpinetoEnlargedPersMRSDistance(i) = nanmedian(cell2mat(ShuffledVolumeIncreasewithPersMRSDistances{i}));
        if SimNewSpinetoEnlargedPersMRSDistance(i) > nanmedian(ClosestEnlargedPersMRSList)
            NewSpinetoEnlargedPersMRSNullDistTest(i) = 1;
        else
            NewSpinetoEnlargedPersMRSNullDistTest(i) = 0;
        end
    SimNewSpinetoEnlargedGainedMRSDistance(i) = nanmedian(cell2mat(ShuffledVolumeIncreasewithGainedMRSDistances{i}));
        if SimNewSpinetoEnlargedGainedMRSDistance(i) > nanmedian(ClosestEnlargedGainedMRSList)
            NewSpinetoEnlargedGainedMRSNullDistTest(i) = 1;
        else
            NewSpinetoEnlargedGainedMRSNullDistTest(i) = 0;
        end
    %======================================================================
end


figure;

subplot(2,4,1); hold on;
histogram(ClosestEarlyMRS, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(cell2mat(mockearlynewspinedistribution), 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Early MRS (p = ', num2str(1-(sum(NewSpineEarlyMoveSpinesNullDistTest)/length(NewSpineEarlyMoveSpinesNullDistTest))), ')'])

subplot(2,4,2); hold on;
histogram(ClosestPrevSeshMRS, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(cell2mat(mockprevseshnewspinedistribution), 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Prev Sesh MRS (p = ', num2str(1-(sum(NewSpinePrevSeshMoveSpinesNullDistTest)/length(NewSpinePrevSeshMoveSpinesNullDistTest))), ')'])

subplot(2,4,3); hold on;
histogram(ClosestLateMRS, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(cell2mat(mocklatenewspinedistribution), 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Late MRS (p = ', num2str(1-(sum(NewSpineLateMoveSpinesNullDistTest)/length(NewSpineLateMoveSpinesNullDistTest))), ')'])

subplot(2,4,4); hold on;
histogram(ClosestPersMRS, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(cell2mat(mockpersnewspinedistribution), 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Pers MRS (p = ', num2str(1-(sum(NewSpinePersMoveSpinesNullDistTest)/length(NewSpinePersMoveSpinesNullDistTest))), ')'])

temp = cell2mat(cellfun(@cell2mat, ShuffledVolumeIncreaseDistances, 'uni', false));
temp = temp(~isnan(temp));
subplot(2,4,5); hold on;
histogram(ClosestEnlargedSpineList, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(temp, 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Enlarged Spine (p = ', num2str(1-(sum(NewSpinetoEnlargedSpinesNullDistTest)/length(NewSpinetoEnlargedSpinesNullDistTest))), ')'])

temp = cell2mat(cellfun(@cell2mat, ShuffledVolumeIncreasewithMRSDistances, 'uni', false));
temp = temp(~isnan(temp));
subplot(2,4,6); hold on;
histogram(ClosestEnlargedMRSList, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(temp, 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Enlarged MRS (p = ', num2str(1-(sum(NewSpinetoEnlargedMRSNullDistTest)/length(NewSpinetoEnlargedMRSNullDistTest))), ')'])

temp = cell2mat(cellfun(@cell2mat, ShuffledVolumeIncreasewithPersMRSDistances, 'uni', false));
temp = temp(~isnan(temp));
subplot(2,4,7); hold on;
histogram(ClosestEnlargedPersMRSList, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(temp, 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Enlarged Pers MRS (p = ', num2str(1-(sum(NewSpinetoEnlargedPersMRSNullDistTest)/length(NewSpinetoEnlargedPersMRSNullDistTest))), ')'])

temp = cell2mat(cellfun(@cell2mat, ShuffledVolumeIncreasewithGainedMRSDistances, 'uni', false));
temp = temp(~isnan(temp));
subplot(2,4,8); hold on;
histogram(ClosestEnlargedGainedMRSList, 'normalization', 'probability', 'binedges', [0:1:30], 'Facecolor', lblue)
histogram(temp, 'normalization', 'probability', 'binedges', [0:1:50], 'Facecolor', gray)
title(['NS to Closest Enlarged Gained MRS (p = ', num2str(1-(sum(NewSpinetoEnlargedGainedMRSNullDistTest)/length(NewSpinetoEnlargedGainedMRSNullDistTest))), ')'])

%==========================================================================

figure; 

subplot(1,4,1); hold on; 
histogram(NearbyEarlyMRSEnvironment, 'normalization', 'probability', 'binedges', [0:1:15])
histogram(cell2mat(mockearlyMRSenvironment), 'normalization', 'probability', 'binedges', [0:1:15])
title('Number of Early MRSs Nearby NS')
xlabel('Number of MRSs')
ylabel('Probability')

subplot(1,4,2); hold on; 
histogram(NearbyPrevSeshMRSEnvironment, 'normalization', 'probability', 'binedges', [0:1:15])
histogram(cell2mat(mockprevseshMRSenvironment), 'normalization', 'probability', 'binedges', [0:1:15])
title('Number of PrevSesh MRSs Nearby NS')
xlabel('Number of MRSs')
ylabel('Probability')

subplot(1,4,3); hold on; 
histogram(NearbyLateMRSEnvironment, 'normalization', 'probability', 'binedges', [0:1:15])
histogram(cell2mat(mocklateMRSenvironment), 'normalization', 'probability', 'binedges', [0:1:15])
title('Number of Late MRSs Nearby NS')
xlabel('Number of MRSs')
ylabel('Probability')

subplot(1,4,4); hold on; 
histogram(NearbyPersMRSEnvironment, 'normalization', 'probability', 'binedges', [0:1:15])
histogram(cell2mat(mockpersMRSenvironment), 'normalization', 'probability', 'binedges', [0:1:15])
title('Number of Late MRSs Nearby NS')
xlabel('Number of MRSs')
ylabel('Probability')

%==========================================================================

% deltaVs = EarlyMRSVolumeChanges;
% deltaVs = deltaVs(logical(AllEarlyMRSs));
% deltaVs(deltaVs<=0) = NaN;
% MRS_by_NearestNS = EarlyMRS_ClosestNS;
% MRS_by_NearestNS = MRS_by_NearestNS(logical(AllEarlyMRSs));
% 
% a = deltaVs(MRS_by_NearestNS<=distance_cutoff);
% a = a(~isnan(a));
% b = deltaVs(MRS_by_NearestNS>=distance_cutoff);
% b = b(~isnan(b));
% 
% figure; hold on; 
% histogram(a, 'normalization', 'probability', 'binedges', [-5:0.1:5], 'FaceColor', lgreen)
% histogram(b, 'normalization', 'probability', 'binedges', [-5:0.1:5], 'FaceColor', gray)
% legend({['Early MRS <=', num2str(distance_cutoff), 'um to NS'],['Early MRS >=',num2str(distance_cutoff) ,'um to NS']})
% xlabel('Spine Volume Ratio (Late/Early)')
% ylabel('Probability')
%==========================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 19: Comparison of Cluster vs. NS only activity occurring during
%%% movements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a = horzcat(FractionofClustActivityDuringMovements{:});
for i = 1:length(a)
    if ~isempty(a{i})
        FractionClustActwithMovement{i} = cell2mat(cellfun(@cell2mat, a{i},'uni', false));
    end
end
datamat = [];

datamat{1} = [cellfun(@nanmedian, FractionClustActwithMovement)]; datamat{1} = datamat{1}(~isnan(datamat{1}));
datamat{2} = cellfun(@nanmedian, horzcat(FractionofNSActivityDuringMovements{:}));
MRSonlyFraction = []; count = 1;
for i = 1:length(FractionofMRSActivityDuringMovements)
    for j = 1:length(FractionofMRSActivityDuringMovements{i})
        if ~isempty(FractionofMRSActivityDuringMovements{i}{j})
            MRSonlyFraction = [MRSonlyFraction, nanmedian(horzcat(FractionofMRSActivityDuringMovements{i}{j}{:}))];
        else
            count = count+1;
        end
    end
end
datamat{3} = MRSonlyFraction;

figure; hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    try
        plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
        Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
        line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
    catch
        Y{i} = [];
    end
end

set(gca, 'XTick', [1:3])
set(gca, 'XTickLabel', {'Clusters', 'NS only', 'MRS only'})

%%% If you want to remove portions based on a CoA_Cutoff, run this section
% count = 1; temp = []; for i = 1:length(a)
%     if ~isempty(a{i})
%         for j = 1:length(a{i})
%             if ~isempty(a{i}{j})
%                 for k = 1:length(a{i}{j})
%                     if ~isempty(a{i}{j}{k})
%                         if MRScoAlist(count) < CoA_Cutoff
%                             temp{i}{j}{k} = a{i}{j}{k};
%                         else
%                             temp{i}{j}{k} = nan;
%                         end
%                         count = count+1;
%                     end
%                 end
%             end
%         end
%     end
% end


