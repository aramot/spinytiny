function NewSpineAnalysis(varargin)

global gui_KomiyamaLabHub
experimentnames = varargin;

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
end

shuffnum = 1000;
bootstrpnum = shuffnum;

for i = 1:length(experimentnames)
    targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
    load(targetfile)
    eval(['currentdata = ',targetfile, ';'])
    
    NumFields{i} = length(currentdata.SpineDynamics);
    SpineDynamics{i} = currentdata.SpineDynamics;
    DendriteDynamics{i} =  currentdata.DendriteDynamics;
    AllDendriteDistances{i} = currentdata.AllDendriteDistances;
    SpineDendriteGrouping{i} = currentdata.SpineDendriteGrouping;
    AllMovementSpines{i} = currentdata.AllMovementSpines;
    NumberofEarlyMovementRelatedSpines(1,i) = currentdata.NumberofEarlyMovementRelatedSpines;
    NumberofLateMovementRelatedSpines(1,i) = currentdata.NumberofLateMovementRelatedSpines;
    NumberofPersistentMovementRelatedSpines{i} = cell2mat(currentdata.NumberofPersistentMovementRelatedSpines);
    NumberofPersistentMovementSpinesClustered{i} = cell2mat(currentdata.NumberofPersistentMovementSpinesClustered);
    
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
    
    NewSpines{i} = cell2mat(currentdata.NewSpines');
    NewSpinesbyDendrite{i} = currentdata.NewSpinesbyDendrite;
    MiddleSessionNewSpines{i} = cell2mat(currentdata.MiddleSessionNewSpines');
    LateSessionNewSpines{i} = cell2mat(currentdata.LateSessionNewSpines');
    PersistentNewSpines{i} = cell2mat(currentdata.PersistentNewSpines');
    ClusteredNewSpines{i} = cell2mat(currentdata.ClusteredNewSpines(~cell2mat(cellfun(@isempty, currentdata.ClusteredNewSpines, 'uni', false))));
    ClusteredNewSpinesbyDendrite{i} = currentdata.ClusteredNewSpinesbyDendrite;
    ElimSpines{i} = cell2mat(currentdata.ElimSpines');
    ElimSpinesbyDendrite{i} = currentdata.ElimSpinesbyDendrite; 
    AntiClusteredElimSpinesbyDendrite{i} = currentdata.AntiClusteredElimSpinesbyDendrite;
    
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
    
    NewSpineAllSpinesDistance{i} = currentdata.NewSpineAllSpinesDistance(~cellfun(@isempty, currentdata.NewSpineAllSpinesDistance));
    NewSpineAllSpinesLateCorr{i} = currentdata.NewSpineAllSpinesLateCorr(~cellfun(@isempty, currentdata.NewSpineAllSpinesLateCorr));
    
    DistancesBetweenNewSpinesandEarlyMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandEarlyMovementSpines);
    LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions{i} = cell2mat(currentdata.LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions);
    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithDistanceMatchedNonEarlyMRSs);
    FrequencyMatchedControlCorrelation{i} = cell2mat(currentdata.FrequencyMatchedControlCorrelation);
    MovementSpineDistanceMatchedControlCorrelation{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementSpineDistanceMatchedControlCorrelation(~cell2mat(cellfun(@isempty, currentdata.MovementSpineDistanceMatchedControlCorrelation, 'uni', false))), 'uni', false));
    TaskCorrelationofClusteredNewSpines{i} = cell2mat(currentdata.TaskCorrelationofClusteredNewSpines);
    NewSpinesCorrwithNearbyEarlyMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithNearbyEarlyMRSs);
    TaskCorrelationofNearbyEarlyMRSs{i} = cell2mat(currentdata.TaskCorrelationofNearbyEarlyMRSs);
    MovementReliabilityofNearbyEarlyMRSs{i} = cell2mat(currentdata.MovementReliabilityofNearbyEarlyMRSs');
    MovementReliabilityofOtherMoveSpines{i} = cell2mat(currentdata.MovementReliabilityofOtherMoveSpines');
    
    DistancesBetweenNewSpinesandLateMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandMovementSpines);
    NumberofFields{i} = length(currentdata.DistancesBetweenNewSpinesandMovementSpines);
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
    
    MoveCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricClusterCorrelation, 'uni', false))),'uni', false));
    MoveCentricDistanceMatchedCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedCorrelation, 'uni', false))),'uni', false));
    MoveCentricDistanceMatchedCorrelationforMRS{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedCorrelationforMRS(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedCorrelationforMRS, 'uni', false))),'uni', false));
    MoveCentricCorrelationofAllOtherSpines{i} = cell2mat(currentdata.MoveCentricCorrelationofAllOtherSpines');
    FailureCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat, currentdata.FailureCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.FailureCentricClusterCorrelation, 'uni', false))), 'uni', false));
    MoveCentricAntiClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricAntiClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricAntiClusterCorrelation, 'uni', false))),'uni', false));
    MoveCentricDistanceMatchedtoAntiClustCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricDistanceMatchedtoAntiClustCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricDistanceMatchedtoAntiClustCorrelation, 'uni', false))),'uni', false));
    MoveCentricFrequencyMatchedCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.MoveCentricFrequencyMatchedCorrelation(~cell2mat(cellfun(@isempty, currentdata.MoveCentricFrequencyMatchedCorrelation, 'uni', false))),'uni', false));
    
    CombinedClusterActivityCorrwithMovement{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithMovement, 'uni', false))),'uni', false));
    CombinedClusterActivityCorrwithSuccess{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithSuccess, 'uni', false))),'uni', false));
    ClusterMovementReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterMovementReliability, 'uni', false))),'uni', false));
    ClusterSuccessReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterSuccessReliability, 'uni', false))),'uni', false));
    ControlPairMovementReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairMovementReliability, 'uni', false))), 'uni', false));
    ControlPairSuccessReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairSuccessReliability, 'uni', false))), 'uni', false));
    
    CorrelationofMovementswithCoActiveClusterActivity{i} = currentdata.CorrelationofMovementswithCoActiveClusterActivity';
        CorrelationofMovementswithCoActiveClusterActivitybyCluster{i} = currentdata.CorrelationofMovementswithCoActiveClusterActivitybyCluster';
    CoActiveClusterMovementsCorrelationwithModelMovement{i} = currentdata.CoActiveClusterMovementsCorrelationwithModelMovement';
        CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{i} = currentdata.CoActiveClusterMovementsCorrelationwithModelMovement';
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
    
    MovementswithClusteredCoActivity{i} = currentdata.MovementswithClusteredCoActivity;
    MovementswithClusteredCoActivitybyCluster{i} = currentdata.MovementswithClusteredCoActivitybyCluster;
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
    IsMoveOnlyRewarded{i} = currentdata.IsMoveOnlyRewarded;
    IsNewOnlyRewarded{i} = currentdata.IsNewOnlyRewarded;
    IsCompCoActiveMovementRewarded{i} = currentdata.IsCompCoActiveMovementRewarded;
    ChanceRewardedLevel{i} = cell2mat(currentdata.ChanceRewardedLevel');
    
    DotProductofCoActivePeriodsDuringMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofCoActivePeriodsDuringMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofCoActivePeriodsDuringMovement, 'uni', false))), 'uni', false));
    DotProductofFMCoActivePeriodsDuringMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofFMCoActivePeriodsDuringMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofFMCoActivePeriodsDuringMovement, 'uni', false))), 'uni', false));
    DotProductofNSDMCoActivePeriodsDuringMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofNSDMCoActivePeriodsDuringMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofNSDMCoActivePeriodsDuringMovement, 'uni', false))), 'uni', false));
    DotProductofMRSDMCoActivePeriodsDuringMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofMRSDMCoActivePeriodsDuringMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofMRSDMCoActivePeriodsDuringMovement, 'uni', false))), 'uni', false));
    DotProductofCoActivePeriodsDuringCRMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofCoActivePeriodsDuringCRMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofCoActivePeriodsDuringCRMovement, 'uni', false))), 'uni', false));
    DotProductofCoActivePeriodsDuringStillness{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofCoActivePeriodsDuringStillness(~cell2mat(cellfun(@isempty, currentdata.DotProductofCoActivePeriodsDuringStillness, 'uni', false))), 'uni', false));
    DotProductofFMCoActivePeriodsDuringCRMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofFMCoActivePeriodsDuringCRMovement(~cell2mat(cellfun(@isempty, currentdata.DotProductofFMCoActivePeriodsDuringCRMovement, 'uni', false))), 'uni', false));
    
    ChanceLevelofCoactivityMovementOverlap{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofCoactivityMovementOverlap(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofCoactivityMovementOverlap, 'uni', false))), 'uni', false));
    ChanceLevelofFMCoActivitywithmovement{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofFMCoActivitywithmovement(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofFMCoActivitywithmovement, 'uni', false))), 'uni', false));
    ChanceLevelofNSDMCoActivitywithMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofNSDMCoActivitywithMovement(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofNSDMCoActivitywithMovement, 'uni', false))), 'uni', false));
    ChanceLevelofMRSDMCoActivitywithMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofMRSDMCoActivitywithMovement(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofMRSDMCoActivitywithMovement, 'uni', false))), 'uni', false));
    ChanceLevelofCoActivityCRMovementOverlap{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofCoActivityCRMovementOverlap(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofCoActivityCRMovementOverlap, 'uni', false))), 'uni', false));
    ChanceLevelofFMCoActivityCRMovementOverlap{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceLevelofFMCoActivityCRMovementOverlap(~cell2mat(cellfun(@isempty, currentdata.ChanceLevelofFMCoActivityCRMovementOverlap, 'uni', false))), 'uni', false));
    
    DotProductofCoActivePeriodsDuringStillness{i} = cell2mat(cellfun(@cell2mat, currentdata.DotProductofCoActivePeriodsDuringStillness(~cell2mat(cellfun(@isempty, currentdata.DotProductofCoActivePeriodsDuringStillness, 'uni', false))), 'uni', false));
    
    IsMovementRewardedEarly{i} = currentdata.IsMovementRewardedEarly;
    IsCoActiveAntiClusterMovementRewarded{i} = currentdata.IsCoActiveAntiClusterMovementRewarded;
    ChanceRewardedLevelElimVersion{i} = cell2mat(currentdata.ChanceRewardedLevelElimVersion');
    
    DendsWithBothDynamics{i} = cell2mat(currentdata.DendsWithBothDynamics);
    DendsWithBothClustDynamics{i} = cell2mat(currentdata.DendsWithBothClustDynamics);
    
    CoActivityDifferenceOptimizationCurve{i} = currentdata.CoActivityDifferenceOptimizationCurve;

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
%%% Figure 5: Movement-Relatedness and Clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DendriteAddresses = 1:nansum(NumberofImagedDendrites);

PofA = cell2mat(cellfun(@(x) sum(x)/length(x), ListofDendswithClusters, 'uni', false)');
PofB = cell2mat(cellfun(@(x) sum(x)/length(x), ListofDendsThatAreEarlyMoveRelated, 'uni', false)');

PofAnB = cell2mat(cellfun(@(x,y) sum((x & y))/length(x), ListofDendswithClusters, ListofDendsThatAreEarlyMoveRelated, 'uni', false)');

figure; hold on;
subplot(1,2,1)
bar(1,nanmean(PofA.*PofB)); hold on;
scatterabout = 0.75 + (1.25-0.75)*rand(length(PofA),1);
plot(scatterabout, PofA.*PofB, '.k', 'Markersize', 14)
scatterabout = 1.75 + (2.25-1.75)*rand(length(PofA),1);
bar(2,nanmean(PofAnB))
plot(scatterabout, PofAnB, '.k', 'Markersize', 14)
maxline = max([nanmean(PofA.*PofB), nanmean(PofAnB)]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
set(gca, 'XTick', 1:2)
set(gca, 'XTickLabel', {'PofA*PofB', 'PofAnB'});
xtickangle(gca, 45)
ylabel('Probability')
title('Interaction of Clustering and Dendrite (Early) Move Relatedness')

if ranksum([PofA.*PofB], PofAnB)<0.05
    text(1.4, maxline+0.03, '*')
else
    text(1.4, maxline+0.03, 'ns')
end


PofA = cell2mat(cellfun(@(x) sum(x)/length(x), ListofDendswithClusters, 'uni', false)');
PofB = cell2mat(cellfun(@(x) sum(x)/length(x), ListofDendsThatAreLateMoveRelated, 'uni', false)');

PofAnB = cell2mat(cellfun(@(x,y) sum((x & y))/length(x), ListofDendswithClusters, ListofDendsThatAreLateMoveRelated, 'uni', false)');

subplot(1,2,2)
bar(1,nanmean(PofA.*PofB)); hold on;
scatterabout = 0.75 + (1.25-0.75)*rand(length(PofA),1);
plot(scatterabout, PofA.*PofB, '.k', 'Markersize', 14)
scatterabout = 1.75 + (2.25-1.75)*rand(length(PofA),1);
bar(2,nanmean(PofAnB))
plot(scatterabout, PofAnB, '.k', 'Markersize', 14)
maxline = max([nanmean(PofA.*PofB), nanmean(PofAnB)]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
set(gca, 'XTick', 1:2)
set(gca, 'XTickLabel', {'PofA*PofB', 'PofAnB'});
xtickangle(gca, 45)
ylabel('Probability')
title('Interaction of Clustering and Dendrite (Late) Move Relatedness')

if ranksum([PofA.*PofB], PofAnB)<0.05
    text(1.4, maxline+0.03, '*')
else
    text(1.4, maxline+0.03, 'ns')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 5: Characterization of Dynamic Spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; 
subplot(2,3,1)
ind = find(NumberofNewSpines);
FractionofNewSpinesClustered = sum(NumberofMovementClusteredNewSpines(ind))/sum(NumberofNewSpines(ind));
bar(FractionofNewSpinesClustered)
ylabel('Fraction', 'Fontsize', 14)
set(gca, 'XTickLabel', {'Clustered New Spines'})
ylim([0 1])
title('Fraction of New Spines Clustered')
text(1,sum(NumberofMovementClusteredNewSpines(ind))/sum(NumberofNewSpines(ind))+0.05, [num2str(sum(NumberofMovementClusteredNewSpines(ind))), '/', num2str(sum(NumberofNewSpines))])

subplot(2,3,2)
b1 = bar(1,sum(NewSpineswithNoMoveSpinePartner(ind))/sum(NumberofNewSpines(ind)));
text(1,sum(NewSpineswithNoMoveSpinePartner(ind))/sum(NumberofNewSpines(ind))+0.05, [num2str(sum(NewSpineswithNoMoveSpinePartner(ind))), '/', num2str(sum(NumberofNewSpines))])
ylim([0 1])
set(gca, 'XTick', [1])
set(gca, 'XTickLabel', {'No MRSP on Dend'})
title('Fraction of New Spines with no MRSP')

subplot(2,3,3)
allmat = [sum(NumberofNewSpinesThatAreMR)/sum(NumberofNewSpines), sum(NumberofElimSpinesThatWereMR)/sum(NumberofElimSpines)];
bar(allmat, 'FaceColor', red);

text(1,sum(NumberofNewSpinesThatAreMR)/sum(NumberofNewSpines)+0.05, [num2str(sum(NumberofNewSpinesThatAreMR)), '/', num2str(sum(NumberofNewSpines))])
text(2,sum(NumberofElimSpinesThatWereMR)/sum(NumberofElimSpines)+0.05, [num2str(sum(NumberofElimSpinesThatWereMR)), '/', num2str(sum(NumberofElimSpines))])
ylim([0 1])   
xlim([0 3])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'New Spines', 'Elim Spines'})
ylabel('Fraction', 'Fontsize',14)
title('Fraction of Dynamic Spines that are MR')

subplot(2,3,4)
y = [nanmean(FractionofNewMovementSpinesThatAreClustered),nanmean(1-FractionofNewMovementSpinesThatAreClustered)];
b1 = bar(1,sum(y)); hold on;
b2 = bar(1,y(1));
legend([b1, b2], {'Unclustered', 'Clustered'})
set(gca, 'XTickLabel', [])
ylabel('Fraction', 'Fontsize',14)
title('Fraction of New MR Spines that are Clustered')

PofA = NumberofNewSpinesThatAreMR(ind)./NumberofNewSpines(ind);
PofB = NumberofMovementClusteredNewSpines(ind)./NumberofNewSpines(ind);
PofAnB = NumberofMovementClusteredNewSpinesThatAreMR(ind)./NumberofNewSpines(ind);

subplot(2,3,5)
bar(1,nanmean(PofA.*PofB)); hold on;
scatterabout = 0.75 + (1.25-0.75)*rand(length(PofA),1);
plot(scatterabout, PofA.*PofB, '.k', 'Markersize', 14)
scatterabout = 1.75 + (2.25-1.75)*rand(length(PofA),1);
bar(2,nanmean(PofAnB))
plot(scatterabout, PofAnB, '.k', 'Markersize', 14)
maxline = max([nanmean(PofA.*PofB), nanmean(PofAnB)]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
set(gca, 'XTick', 1:2)
set(gca, 'XTickLabel', {'PofA*PofB', 'PofAnB'});
xtickangle(gca, 45)
ylabel('Probability', 'Fontsize', 14)
title('Interaction of Clustering and New Spine MR')

if ranksum([PofA.*PofB], PofAnB)<0.05
    text(1.4, maxline+0.03, '*')
else
    text(1.4, maxline+0.03, 'ns')
end

PofA = length(cell2mat(PersistentNewSpines'))/length(cell2mat(MiddleSessionNewSpines'));
PofB = NumberofMovementClusteredNewSpines(ind)./NumberofNewSpines(ind);
PofAnB = NumberofMovementClusteredNewSpinesThatAreMR(ind)./NumberofNewSpines(ind);

subplot(2,3,6)
bar(1,PofA); hold on;
set(gca, 'XTickLabel', {'Middle Session New Spines Preserved'})
text(1, PofA+0.02, [num2str(length(cell2mat(PersistentNewSpines'))), '/', num2str(length(cell2mat(MiddleSessionNewSpines')))])


% bar(1,nanmean(PofA.*PofB)); hold on;
% scatterabout = 0.75 + (1.25-0.75)*rand(length(PofA),1);
% plot(scatterabout, PofA.*PofB, '.k', 'Markersize', 14)
% scatterabout = 1.75 + (2.25-1.75)*rand(length(PofA),1);
% bar(2,nanmean(PofAnB))
% plot(scatterabout, PofAnB, '.k', 'Markersize', 14)
% maxline = max([nanmean(PofA.*PofB), nanmean(PofAnB)]);
% plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
% set(gca, 'XTick', 1:2)
% set(gca, 'XTickLabel', {'PofA*PofB', 'PofAnB'});
% xtickangle(gca, 45)
% ylabel('Probability')
% title('Interaction of Clustering and New Spine MR')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 6: Persistence of Movement Related Spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; 
subplot(1,2,1)

NumberofPersistentMovementSpinesClustered(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false))) = mat2cell(zeros(1,sum(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false)))),1,ones(1,sum(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false))))); %%% Replace any empty cells with cells of {0}

allmat = [sum(cell2mat(NumberofPersistentMovementRelatedSpines))/sum(NumberofEarlyMovementRelatedSpines), sum(cell2mat(NumberofPersistentMovementSpinesClustered))/sum(cell2mat(NumberofPersistentMovementRelatedSpines))];
bar(allmat, 'FaceColor', red);

text(1,sum(cell2mat(NumberofPersistentMovementRelatedSpines))/sum(NumberofEarlyMovementRelatedSpines)+0.05, [num2str(sum(cell2mat(NumberofPersistentMovementRelatedSpines))), '/', num2str(sum(NumberofEarlyMovementRelatedSpines))])
text(2,sum(cell2mat(NumberofPersistentMovementSpinesClustered))/sum(cell2mat(NumberofPersistentMovementRelatedSpines))+0.05, [num2str(sum(cell2mat(NumberofPersistentMovementSpinesClustered))), '/', num2str(sum(cell2mat(NumberofPersistentMovementRelatedSpines)))])
ylim([0 1])   
xlim([0 3])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Persistent MRS', 'Persistent MRS that cluster'})
ylabel('Fraction')
title('Fraction of Persistent MRSs')

ind = find(NumberofEarlyMovementRelatedSpines);

PersistentMRSbyanimal = cell2mat(cellfun(@sum, NumberofPersistentMovementRelatedSpines, 'uni', false));
PofA = PersistentMRSbyanimal(ind)./NumberofEarlyMovementRelatedSpines(ind);                                                 %%% The probability of a MRS from early sessions being PERSISTENT
PofB = cell2mat(cellfun(@sum ,NumberofClusteredMoveSpines(ind), 'uni', false))./NumberofEarlyMovementRelatedSpines(ind);    %%% The probability of a MRS from early sessions being CLUSTERED (i.e. having a new spine form nearby)
persistentandclustered = cell2mat(cellfun(@sum, NumberofPersistentMovementSpinesClustered, 'uni', false));
PofAnB = persistentandclustered(ind)./NumberofEarlyMovementRelatedSpines(ind);

subplot(1,2,2)
bar(1,nanmean(PofA.*PofB)); hold on;
scatterabout = 0.75 + (1.25-0.75)*rand(length(PofA),1);
plot(scatterabout, PofA.*PofB, '.k', 'Markersize', 14)
scatterabout = 1.75 + (2.25-1.75)*rand(length(PofA),1);
bar(2,nanmean(PofAnB))
plot(scatterabout, PofAnB, '.k', 'Markersize', 14)
maxline = max([nanmean(PofA.*PofB), nanmean(PofAnB)]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
set(gca, 'XTick', 1:2)
set(gca, 'XTickLabel', {'PofA*PofB', 'PofAnB'});
xtickangle(gca, 45)
ylabel('Probability')
title('Interaction of Clustering and Persistence of MRSs')

if ranksum([PofA.*PofB], PofAnB)<0.05
    text(1.4, maxline+0.03, '*')
else
    text(1.4, maxline+0.03, 'ns')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 7: Number of Movement Spines on Dynamic vs. Static Dendrites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MoveSpinesonAdditionDendrites = cell2mat(NumberofMovementSpinesOnAdditionDendrites');
MoveSpinesonEliminationDendrites = cell2mat(NumberofMovementSpinesOnEliminationDendrites');
MoveSpinesonStaticDendrites = cell2mat(NumberofMovementSpinesOnStaticDendrites');

allmat = [{MoveSpinesonAdditionDendrites}, {MoveSpinesonEliminationDendrites}, {MoveSpinesonStaticDendrites}];
figure; bar(1:length(allmat), cell2mat(cellfun(@nanmedian, allmat, 'uni', false)), 'FaceColor', lgreen)

alphaforbootstrap = 0.05;

for i = 1:length(allmat)
    Y = bootci(bootstrpnum, {@median, allmat{i}(~isnan(allmat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(allmat), 'XTickLabel',{'Add. Dends', 'Elim. Dends', 'Static Dends'})
ylabel('Median # of Move Spines')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 8: Distance Between Dynamic Spines and MR spines
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

distancetoMaxCorrPartner = (cell2mat(DistanceToMaxCorrPartner'))';

SimNewSpinetoEarlyMovementSpineDistance = nan(1,shuffnum);
SimNewSpinetoLateMovementSpineDistance = nan(1,shuffnum);

mockearlynewspinedistribution = cell(1,shuffnum);

for i = 1:shuffnum
    mockearlynewspinedistribution{i} = nan(1,sum(NumberofNewSpines));
    mocklatenewspinedistribution = nan(1,sum(NumberofNewSpines));
    mockearlyelimspinedistribution = nan(1,sum(NumberofElimSpines));
    mocklateelimspinedistribution = nan(1,sum(NumberofElimSpines));
    for j = 1:sum(NumberofNewSpines)
        randAnimal = randi([1,length(AllDendriteDistances)],1);
        randField = randi([1,length(AllDendriteDistances{randAnimal})]);
        randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
        spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
        DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
        simNewSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
        %%%
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        while ~any(EarlyMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
            simNewSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1);
        end
        %%%
        mockearlynewspinedistribution{i}(j) = abs(nanmin(DistancesfromRandDend(longeststretch, EarlyMovementSpines))-simNewSpine);
        %%%%
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);      %%% 'end' index corresponds to final session'
        while ~any(LateMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
            simNewSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);
        end
        mocklatenewspinedistribution(j) =abs(nanmin(DistancesfromRandDend(longeststretch, LateMovementSpines))-simNewSpine);
    end
    SimNewSpinetoEarlyMovementSpineDistance(i) = nanmedian(mockearlynewspinedistribution{i});
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
        randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
        spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
        DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
        simElimSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        while ~any(EarlyMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
            simElimSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); 
        end
        mockearlyelimspinedistribution(j) = abs(nanmin(DistancesfromRandDend(longeststretch, EarlyMovementSpines))-simElimSpine);
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);%%% 'end' index corresponds to final session
        while ~any(LateMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
            simElimSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);
        end
        mocklateelimspinedistribution(j) = abs(nanmin(DistancesfromRandDend(longeststretch, LateMovementSpines))-simElimSpine);
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
datamat = [{SimNewSpinetoEarlyMovementSpineDistance},{newspinesearlymovspines},{distancetoMaxCorrPartner}, {SimNewSpinetoLateMovementSpineDistance}, {newspineslatemovspines}, {SimElimSpinetoEarlyMovementSpineDistance},{elimspinesearlymovspines}, {SimElimSpinetoLateMovementSpineDistance}, {elimspineslatemovspines}];
figure; bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred'); hold on;
%     r_errorbar(1:6, [nanmedian(randspines),nanmedian(shuffledearlyspines),nanmedian(earlyspines),nanmedian(shuffledspines),nanmedian(newspines),nanmedian(elimspines)], [nanstd(randspines)/sum(~isnan(randspines)),nanstd(shuffledearlyspines)/sum(~isnan(shuffledearlyspines)),nanstd(earlyspines)/sum(~isnan(earlyspines)),nanstd(shuffledspines)/sum(~isnan(shuffledspines)), nanstd(newspines)/sum(~isnan(newspines)), nanstd(elimspines)/sum(~isnan(elimspines))], 'k')
Y = cell(1,length(datamat));
for i = 1:length(datamat)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'Shuff New Spine-Early MRS','New Spine-Early MRS','MaxCorrPartner','Shuff New Spine-MRS', 'New Spine-MRS','Shuff. Elim Sp - Early MRS', 'Elim Sp - Early MRS','Shuff Elim Sp - MRS', 'Elim Spine - MRS'})
ylabel('Median Distance')
xtickangle(gca, 45)

plot(1:2, (max([Y{1}; Y{2}])+1)*ones(1,2), 'k', 'Linewidth', 2)
text(1.4, (max([Y{1}; Y{2}])+2), num2str((shuffnum-sum(NewSpineEarlyMoveSpinesNullDistTest))/shuffnum))

plot(4:5, (max([Y{4}; Y{5}])+1)*ones(1,2), 'k', 'Linewidth', 2)
text(4.5, max([Y{4}; Y{5}])+2, num2str((shuffnum-sum(NewSpineLateMoveSpinesNullDistTest))/shuffnum))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allmovementspinedistances = [];
for animal = 1:length(AllMovementSpines)
    for field = 1:length(AllMovementSpines{animal})
        for session = 1:size(AllMovementSpines{animal}{field},2)
            sessionmovespines = find(AllMovementSpines{animal}{field}(:,session));
            if length(sessionmovespines)>1
                spinecombos = nchoosek(sessionmovespines,2);
                for cmb = 1:size(spinecombos,1)
                    allmovementspinedistances = [allmovementspinedistances, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
                end
            else
            end
        end
    end
end
allmovementspinedistancesearly = [];
for animal = 1:length(AllMovementSpines)
    for field = 1:length(AllMovementSpines{animal})
        sessionmovespines = find(AllMovementSpines{animal}{field}(:,1));
        if length(sessionmovespines)>1
            spinecombos = nchoosek(sessionmovespines,2);
            for cmb = 1:size(spinecombos,1)
                allmovementspinedistancesearly = [allmovementspinedistancesearly, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
            end
        else
        end
    end
end
allmovementspinedistanceslate = [];
for animal = 1:length(AllMovementSpines)
    for field = 1:length(AllMovementSpines{animal})
        sessionmovespines = find(AllMovementSpines{animal}{field}(:,end));
        if length(sessionmovespines)>1
            spinecombos = nchoosek(sessionmovespines,2);
            for cmb = 1:size(spinecombos,1)
                allmovementspinedistanceslate = [allmovementspinedistanceslate, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
            end
        else
        end
    end
end
allmovementspinedistancesshuffled = [];
for animal = 1:length(AllMovementSpines)
    for field = 1:length(AllMovementSpines{animal})
        for session = 1:size(AllMovementSpines{animal}{field},2)
            for shuff = 1:10
                sessionmovespines = find(shake(AllMovementSpines{animal}{field}(:,session)));
                if length(sessionmovespines)>1
                    spinecombos = nchoosek(sessionmovespines,2);
                    for cmb = 1:size(spinecombos,1)
                        allmovementspinedistancesshuffled = [allmovementspinedistancesshuffled, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
                    end
                else
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 9: Dynamic Spines Max Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; subplot(1,2,1);hold on;
binedges = [0:0.05:1];
NS = histogram(cell2mat(NewSpinesMaxCorr'),'binedges', binedges, 'normalization', 'probability'); title('New Spines Max Corr. Dist.'); xlim([0 1]);
plot(nanmedian(cell2mat(NewSpinesMaxCorr'))*ones(1,11),0:0.1:1, '--r')
text(nanmedian(cell2mat(NewSpinesMaxCorr')), max(hist(cell2mat(NewSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(NewSpinesMaxCorr')))])
ES = histogram(cell2mat(ElimSpinesMaxCorr'),'binedges', binedges, 'normalization', 'probability');
legend([NS, ES], {'New Spines', 'Elim Spines'})
subplot(1,2,2);
MaxCorrs = cell2mat(NewSpinesMaxCorr');
NSSD = histogram(MaxCorrs(~isnan(distancetoMaxCorrPartner)),'binedges', binedges, 'normalization', 'probability'); %%% Perform the same calculations for only spines on the same dendrites
hold on; title('New Spines Max Corr. Dist.'); xlim([0 1]);
OS = histogram(cell2mat(OtherSpinesMaxCorr'),'binedges', binedges, 'normalization', 'probability'); title('All Other Spines Max Corr. Dist.'); xlim([0 1])
plot(nanmedian(cell2mat(NewSpinesMaxCorr'))*ones(1,11),0:0.1:1, '--b')
plot(nanmedian(cell2mat(OtherSpinesMaxCorr'))*ones(1,11),0:0.1:1, '--r')
text(nanmedian(cell2mat(OtherSpinesMaxCorr')), 0.5, [num2str(nanmedian(cell2mat(OtherSpinesMaxCorr')))])
legend([NSSD, OS], {'New Spines', 'All Other Spines'})

p = Chi2DiffProportions(MaxCorrs(~isnan(distancetoMaxCorrPartner)), cell2mat(OtherSpinesMaxCorr'), 0.5);
if p <0.05
    text(nanmedian(cell2mat(NewSpinesMaxCorr')), 0.4, [num2str(nanmedian(cell2mat(NewSpinesMaxCorr'))), ' *'])
else
    text(nanmedian(cell2mat(NewSpinesMaxCorr')), 0.4, [num2str(nanmedian(cell2mat(NewSpinesMaxCorr')))])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 10: Dynamic Spines Correlation with Nearby Movement-related
%%% spines (as a function of distance, and overall)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; a = subplot(2,2,1); hold on; 
plot(cell2mat(DistancesBetweenNewSpinesandEarlyMovementSpines), cell2mat(LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions), '.k', 'Markersize', 14)
title('New spines vs. Early Movement Spines')

b = subplot(2,2,2); 
plot(cell2mat(DistancesBetweenNewSpinesandLateMovementSpines), cell2mat(LateCorrofNewSpinesandMovementSpinefromLateSessions), '.k', 'Markersize', 14)
title('New spines vs. Late Movement Spines')

c = subplot(2,2,3);
plot(cell2mat(DistancesBetweenElimSpinesandEarlyMovementSpines), cell2mat(CorrelationsofElimSpinesandEarlyMovementSpines), '.k', 'Markersize', 14)
title('Elim spines vs. Early movement Spines')
linkaxes([a,b,c], 'xy')

subplot(2,2,4); hold on
datamat = [{cell2mat(NewSpinesCorrwithNearbyEarlyMRSs)},{cell2mat(NewSpinesCorrwithNearbyLateMRSs)},{cell2mat(ElimSpinesCorrwithNearbyMRSs)},{cell2mat(FrequencyMatchedControlCorrelation)},{cell2mat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)}, {cell2mat(MovementSpineDistanceMatchedControlCorrelation)}];
% datamat = [{cellfun(@nanmedian, NewSpinesCorrwithNearbyEarlyMRSs)},{cellfun(@nanmedian, NewSpinesCorrwithNearbyLateMRSs)},{cellfun(@nanmedian, ElimSpinesCorrwithNearbyMRSs)},{cellfun(@nanmedian, FrequencyMatchedControlCorrelation)},{cellfun(@nanmedian, NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)}, {cellfun(@nanmedian, MovementSpineDistanceMatchedControlCorrelation)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
bootstrpnum = shuffnum;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'NS-Max Nearby eMRS','NS-Max Nearby lMRS', 'ES-Max Nearby eMRS','Freq-Matched Control', 'Dist-matched for NS', 'Dist-matched for MRS'})
xtickangle(gca, 45)
title('Max Correlation with Nearby MRSs')

maxline = max(cell2mat(Y')); 

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
        text(mean([1,(i)])-0.1, maxline+0.05, statsymbol)
    else
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([1,(i)])-0.1, maxline+0.05, 'ns')
    end
    maxline = maxline+0.075;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 11: Dynamic Spines Correlation with Nearby Movement-related
%%% spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; 
subplot(1,2,1); hold on;
datamat = [{cell2mat(LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions)}, {cell2mat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)},{cell2mat(MovementSpineDistanceMatchedControlCorrelation)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@nanmedian, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
%     plot(ones(1,numel(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel', {'New Sp. vs. Near MRS', 'New Sp. vs. Dist-matched nMRS', 'Move Sp. Dist-matched non-new'})
xtickangle(gca, 45)
title('New Spines Correlation with Closest eMRS')
[p,~] = ranksum(datamat{1},datamat{2});
if p<0.05
    plot(1:2, (max(nanmean(cell2mat(datamat))))*ones(1,2), 'k')
end

subplot(1,2,2); hold on;
datamat = [{cell2mat(LateCorrofNewSpinesandMovementSpinefromLateSessions)}, {cell2mat(NewSpinesCorrwithDistanceMatchedNonLateMRSs)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
Y = cell(1,length(datamat));
for i = 1:length(datamat)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
%     plot(ones(1,numel(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel', {'New Sp. vs. Near MRS', 'New Sp. vs. Dist-matched nMRS'})
xtickangle(gca, 45)
title('New Spines Correlation with Closest lMRS')

maxline = max(cell2mat(Y')); 

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
        text(mean([1,(i)])-0.1, maxline+0.05, statsymbol)
    else
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([1,(i)])-0.1, maxline+0.05, 'ns')
    end
    maxline = maxline+0.075;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 12: Dynamic Spines Behavior Corr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

useabsvalbehcorr = 0;

%%% New Spines
figure; newspplot = subplot(3,2,1); hold on; title('New Spines'' Correlation with Task')
tempnewspmat = cell2mat(NewSpinesBehaviorCorrelation');
if useabsvalbehcorr
    tempnewspmat = abs(tempnewspmat);
end
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

%%% All other spines from late sessions (i.e. not new spines) 
otherspplot = subplot(3,2,2); hold on; title('All Other Spines'' Correlation with Task (Late)')
tempotherspmat = cell2mat(NonNewSpinesBehaviorCorrelationLate'); %%% This variable excludes new and movement spines
if useabsvalbehcorr
    tempotherspmat = abs(tempotherspmat);
end
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

clustnewplot = subplot(3,2,3); hold on; title('All Clustered New Spines'' Correlation with Task')
tempclustnewspmat = cell2mat(TaskCorrelationofClusteredNewSpines); %%% This variable excludes new and movement spines
if useabsvalbehcorr
    tempclustnewspmat = abs(tempclustnewspmat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempclustnewspmat,2))
% linkaxes([newspplot,otherspplot],'y')
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempclustnewspmat(i,~isnan(tempclustnewspmat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')


%%% Eliminated spines
elimspplot = subplot(3,2,5); hold on; title('Elim Spines'' Correlation with Task')
tempelimspmat = cell2mat(ElimSpinesBehaviorCorrelation');
if useabsvalbehcorr
    tempelimspmat = abs(tempelimspmat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempelimspmat,1))
linkaxes([newspplot,elimspplot],'y')
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempelimspmat(~isnan(tempelimspmat(:,i)),i)}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')

%%% All other spines from early sessions (i.e. ones not eliminated)
otherspplot = subplot(3,2,6); hold on; title('All Other Spines'' Correlation with Task (Early)')
tempotherspmat = cell2mat(NonNewSpinesBehaviorCorrelationEarly');
if useabsvalbehcorr
    tempotherspmat = abs(tempotherspmat);
end
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 13: Dynamic Spines' MRS Partner Behavior Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; newspearlyplot = subplot(2,2,1); hold on; title('New Spines'' MRSP Correlation with Task, Early')
tempnewspearlymat = cell2mat(TaskCorrelationofNearbyEarlyMRSs);
if useabsvalbehcorr
    tempnewspearlymat = abs(tempnewspearlymat);
end
bar(nanmedian(tempnewspearlymat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempnewspearlymat(i,~isnan(tempnewspearlymat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')

newsplateplot = subplot(2,2,2); hold on; title('New Spines'' MRSP Correlation with Task, Late')
tempnewsplatemat = cell2mat(TaskCorrelationofNearbyLateMRSs);
if useabsvalbehcorr
    tempnewsplatemat = abs(tempnewsplatemat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempnewsplatemat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempnewsplatemat(i,~isnan(tempnewsplatemat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')

%%% Eliminated spines
elimspplot = subplot(2,2,3); hold on; title('Elim Spines'' Partner Correlation with Task')
tempelimspmat = cell2mat(TaskCorrelationofNearbyEarlyMRSsforElimSp);
if useabsvalbehcorr
    tempelimspmat = abs(tempelimspmat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempelimspmat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempelimspmat(i,~isnan(tempelimspmat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')
linkaxes([newspearlyplot,newsplateplot,elimspplot],'y')


%%% Movement reliability
subplot(2,2,4); hold on; title('Dynamic Spines'' MRSP Reliability')
datamat = [{cell2mat(MovementReliabilityofNearbyEarlyMRSs')}, {cell2mat(MovementReliabilityofNearbyLateMRSs')}, {cell2mat(MovementReliabilityofNearbyEarlyMRSsforElimSp')}, {cell2mat(MovementReliabilityofOtherMoveSpines')}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple)
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'New Sp-Early MRSP', 'New Sp-Late MRSP', 'Elim Sp- Early MRSP', 'Other Move Spines'})
xtickangle(gca, 45)
ylabel('Movement Reliability')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 14: Dynamic Spines' HCP Behavior Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
figure; newspearlyplot = subplot(2,2,1); hold on; title('New Spines'' HCP Correlation with Task, Early')
tempnewspearlymat = cell2mat(NewSpineMaxCorrPartnerEarlyMoveCorrelation);
if useabsvalbehcorr
    tempnewspearlymat = abs(tempnewspearlymat);
end
%     tempnewspmat(tempnewspmat>=0) = nan;
bar(nanmedian(tempnewspearlymat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempnewspearlymat(i,~isnan(tempnewspearlymat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')

%%% All other spines from late sessions (i.e. not new spines) 
newsplateplot = subplot(2,2,2); hold on; title('New Spines'' HCP Correlation with Task, Late')
tempnewsplatemat = cell2mat(NewSpineMaxCorrPartnerLateMoveCorrelation);
if useabsvalbehcorr
    tempnewsplatemat = abs(tempnewsplatemat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempnewsplatemat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempnewsplatemat(i,~isnan(tempnewsplatemat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')

%%% Eliminated spines
elimspplot = subplot(2,2,3); hold on; title('Elim Spines'' Partner Correlation with Task')
tempelimspmat = cell2mat(ElimSpineMaxCorrPartnerEarlyMoveCorrelation);
if useabsvalbehcorr
    tempelimspmat = abs(tempelimspmat);
end
%     tempotherspmat(tempotherspmat>=0) = nan;
bar(nanmedian(tempelimspmat,2))
for i = 1:9
    Y = bootci(bootstrpnum, {@median, tempelimspmat(i,~isnan(tempelimspmat(i,:)))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:9])
set(gca, 'XTickLabel', {'Cue', 'Movement', 'Wide Move', 'PreMove', 'Rewarded Move', 'Wider Reward Move', 'MDC', 'Reward Del', 'Punish'})
xtickangle(gca, 45)
ylabel('Correlation')
linkaxes([newspearlyplot,newsplateplot,elimspplot],'y')


%%% Movement Reliability of New Spines' Highly Corrleted Partner (HCP)
subplot(2,2,4); hold on; title('HCP Movement Reliability')
datamat = [{cell2mat(NewSpineMaxCorrPartnerEarlyMoveReliability')}, {cell2mat(NewSpineMaxCorrPartnerLateMoveReliability')}, {cell2mat(ElimSpineMaxCorrPartnerEarlyMoveReliability')}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple)
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'New Spines-Early HCP', 'New Spines-Late HCP', 'Elim Spines- Early HCP'})
xtickangle(gca, 45)
ylabel('Movement Reliability')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 15: Clustered Spines' Correlation with dendritic activity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;subplot(1,3,1)

datamat = [{cell2mat(ClusteredNewSpineCorrwithDendrite)}, {cell2mat(ClusteredMoveSpineCorrwithDendrite)}, {cell2mat(CoActiveClusterCorrwithDendrite)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'New Sp. vs. Dend', 'Move Sp. vs. Dend', 'Coactive vs. Dend'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation with Dendritic Activity')

subplot(1,3,2)
if useabsval
    datamat = [{abs(cell2mat(ClusteredNewSpineCorrwithMovement))}, {abs(cell2mat(ClusteredMoveSpineCorrwithMovement))}, {abs(cell2mat(CoActiveClusterCorrwithMovement))}];
else
    datamat = [{cell2mat(ClusteredNewSpineCorrwithMovement)}, {cell2mat(ClusteredMoveSpineCorrwithMovement)}, {cell2mat(CoActiveClusterCorrwithMovement)}];
end
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', green); hold on;
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'New Sp. vs. Mvmnt', 'eMove Sp. vs. Mvmnt', 'Coactive vs. Mvmnt'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation with Movement')

subplot(1,3,3)
if useabsval
    datamat2 = [{abs(cell2mat(ClusteredNewSpineCorrwithSuccess))}, {abs(cell2mat(ClusteredMoveSpineCorrwithSuccess))}, {abs(cell2mat(CoActiveClusterCorrwithSuccess))}];
else
    datamat2 = [{cell2mat(ClusteredNewSpineCorrwithSuccess)}, {cell2mat(ClusteredMoveSpineCorrwithSuccess)}, {cell2mat(CoActiveClusterCorrwithSuccess)}];
end
bar(1:length(datamat2), cell2mat(cellfun(@nanmedian, datamat2, 'uni', false)), 'FaceColor', lblue); hold on;
for i = 1:length(datamat2)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat2{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat2{i}(~isnan(datamat2{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat2)])
set(gca, 'XTickLabel', {'New Sp. vs. Success', 'eMove Sp. vs. Success', 'Coactive vs. Success'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation with Rewarded Presses')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 16: Correlation of clustered spines DURING specified presses
%%% (Noise Correlation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on

subplot(1,2,1)

% datamat = [{cell2mat(MoveCentricClusterCorrelation)}, {cell2mat(MoveCentricDistanceMatchedCorrelation)}, {cell2mat(MoveCentricDistanceMatchedCorrelationforMRS)}, {cell2mat(MoveCentricCorrelationofAllOtherSpines')}, {cell2mat(MoveCentricFrequencyMatchedCorrelation)}, {cell2mat(FailureCentricClusterCorrelation)}];
datamat = [{cellfun(@nanmedian, MoveCentricClusterCorrelation)}, {cellfun(@nanmedian, MoveCentricDistanceMatchedCorrelation)}, {cellfun(@nanmedian, MoveCentricDistanceMatchedCorrelationforMRS)}, {cellfun(@nanmedian, MoveCentricCorrelationofAllOtherSpines')}, {cellfun(@nanmedian, MoveCentricFrequencyMatchedCorrelation)}, {cellfun(@nanmedian, FailureCentricClusterCorrelation)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = [];
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', 1:length(datamat))
set(gca, 'XTickLabel', {'Clusters', 'Dist. Matched to New Spine', 'Dist matched to MRS', 'All other spines', 'Freq matched', 'Clusters with failure'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Cluster Correlation During Targeted Presses')

maxline = max(cell2mat(Y')); 

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
        text(mean([1,(i)])-0.1, maxline+0.05, statsymbol)
    else
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([1,(i)])-0.1, maxline+0.05, 'ns')
    end
    maxline = maxline+0.075;
end

subplot(1,2,2)

datamat = [{cell2mat(MoveCentricAntiClusterCorrelation)}, {cell2mat(MoveCentricDistanceMatchedtoAntiClustCorrelation)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters', 'Dist. Matched to Elim Spine'})
xtickangle(gca, 45)
ylabel('Correlation')
title('AntiCluster Correlation During Successful Presses')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 17: Combined reliability of clusters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on

datamat = [{cell2mat(ClusterMovementReliability)},{cell2mat(ControlPairMovementReliability)}, {cell2mat(ClusterSuccessReliability)}, {cell2mat(ControlPairSuccessReliability)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters', 'Dist. Matched Ctrls', 'Success Clusters', 'Dist. Matched Ctrls'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Combined Cluster Reliability')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
maxline2 = max([nanmedian(datamat{3}), nanmedian(datamat{4})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
plot(3:4, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

[p,~] = ranksum(datamat{3},datamat{4});

if p<0.05
    text(3.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(3.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 18: Correlation of MOVEMENTS during co-active cluster periods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
sub1 = 3;
sub2 = 5;
subcount = 1;

figure;hold on

%==========================================================================
%%% Choose data carefully!

%%% Option 1: This presents all correlation values of all movement sets found in a
%%% single animal; averaging is done with ANIMALS as the sample, and error
%%% taken accordingly. Note: movement correlation is still found on a
%%% cluster-by-cluster basis, so movements are NOT compared between
%%% clusters

numAnimals = length(CorrelationofMovementswithCoActiveClusterActivitybyCluster);

Clusters_byAnimal = cell(1,numAnimals);
MRSonly_byAnimal = cell(1,numAnimals);
NSonly_byAnimal = cell(1,numAnimals);
MRSDM_byAnimal = cell(1,numAnimals);
NSDM_byAnimal = cell(1,numAnimals);
FMctrl_byAnimal = cell(1,numAnimals);
OtherSpines_byAnimal = cell(1,numAnimals);
AllOthers_byAnimal = cell(1,numAnimals);

for i = 1:numAnimals
    for j = 1:length(CorrelationofMovementswithCoActiveClusterActivitybyCluster{i})
        for k = 1:length(CorrelationofMovementswithCoActiveClusterActivitybyCluster{i}{j})
            for l = 1:length(CorrelationofMovementswithCoActiveClusterActivitybyCluster{i}{j}{k})
                Clusters_byAnimal{i} = [Clusters_byAnimal{i}; CorrelationofMovementswithCoActiveClusterActivitybyCluster{i}{j}{k}{l}];
            end
        end
        for k = 1:length(MovementCorrelationwithMRSonlyActivitybyCluster{i}{j})
            for l = 1:length(MovementCorrelationwithMRSonlyActivitybyCluster{i}{j}{k})
                MRSonly_byAnimal{i} = [MRSonly_byAnimal{i}; MovementCorrelationwithMRSonlyActivitybyCluster{i}{j}{k}{l}];
            end
        end
        for k = 1:length(MovementCorrelationwithNSonlyActivitybyCluster{i}{j})
            for l = 1:length(MovementCorrelationwithNSonlyActivitybyCluster{i}{j}{k})
                NSonly_byAnimal{i} = [NSonly_byAnimal{i}; MovementCorrelationwithNSonlyActivitybyCluster{i}{j}{k}{l}];
            end
        end
        for k = 1:length(CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{i}{j})
            MRSDM_byAnimal{i} = [MRSDM_byAnimal{i}; cell2mat(CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{i}{j}{k}')];
        end
        for k = 1:length(CorrelationofMovementswithCoActiveFMControlActivitybyCluster{i}{j})
            for l = 1:length(CorrelationofMovementswithCoActiveFMControlActivitybyCluster{i}{j}{k})
                FMctrl_byAnimal{i} = [FMctrl_byAnimal{i}; CorrelationofMovementswithCoActiveFMControlActivitybyCluster{i}{j}{k}{l}];
            end
        end
        for k = 1:length(CorrelationofMovementswithAllOtherSpineCoActivity{i}{j})
            OtherSpines_byAnimal{i} = [OtherSpines_byAnimal{i}; CorrelationofMovementswithAllOtherSpineCoActivity{i}{j}'];
        end
    end
    for j = 1:length(MovementCorrelationofAllOtherMovements{i})
        AllOthers_byAnimal{i} = [AllOthers_byAnimal{i}; MovementCorrelationofAllOtherMovements{i}{j}];
    end
end
AnyClusterValuesbyAnimal = cellfun(@(x,y,z) [x;y;z], Clusters_byAnimal, MRSonly_byAnimal, NSonly_byAnimal, 'uni', false);

MedianClusterValuebyAnimal = cellfun(@nanmedian, Clusters_byAnimal);
MedianAnyClusterbyAnimal = cellfun(@nanmedian, AnyClusterValuesbyAnimal);
MedianMRSOnlybyAnimal = cellfun(@nanmedian, MRSonly_byAnimal);
MedianNSOnlybyAnimal = cellfun(@nanmedian, NSonly_byAnimal);
MedianMRSDMbyAnimal = cellfun(@nanmedian, MRSDM_byAnimal);
MedianFMControlbyAnimal = cellfun(@nanmedian, FMctrl_byAnimal);
MedianOtherSpinePairsbyAnimal = cellfun(@nanmedian, OtherSpines_byAnimal);
MedianAllOtherbyAnimal = cellfun(@nanmedian, AllOthers_byAnimal);

Animal_datamat = [{MedianClusterValuebyAnimal}, {MedianAnyClusterbyAnimal},{MedianMRSOnlybyAnimal}, {MedianNSOnlybyAnimal}, {MedianMRSDMbyAnimal},{MedianFMControlbyAnimal},{MedianOtherSpinePairsbyAnimal},{MedianAllOtherbyAnimal}];

datamat = Animal_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    try 
        Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
        line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
    catch
        Y{i} = [];
    end
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'With Any Clust Act', 'MRS only', 'NS only','MRSDM', 'FM ctrl', 'Other Sp. Pairs', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mv. Corr. by Animal')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
    [p,~] = signrank(datamat{1},datamat{i});
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

%%% Option 2: This presents all correlation values of all movement sets found in a
%%% single field; averaging is done with FIELDS as the sample, and error
%%% taken accordingly
subcount = subcount+1;

Clusters_AllFields = vertcat(CorrelationofMovementswithCoActiveClusterActivitybyCluster{:})';
AnyClusterAct_AllFields = cellfun(@(x,y,z) [x,y,z], vertcat(CorrelationofMovementswithCoActiveClusterActivitybyCluster{:}), vertcat(MovementCorrelationwithMRSonlyActivitybyCluster{:}), vertcat(MovementCorrelationwithNSonlyActivitybyCluster{:}), 'uni', false);
MRSOnly_AllFields = vertcat(MovementCorrelationwithMRSonlyActivitybyCluster{:});
NSOnly_AllFields = vertcat(MovementCorrelationwithNSonlyActivitybyCluster{:});
MRSDM_AllFields = horzcat(CorrelationofMovementswithCoActiveMRSDMControlActivitybyCluster{:});
FMPairs_AllFields = vertcat(CorrelationofMovementswithCoActiveFMControlActivitybyCluster{:});
OtherPairs_AllFields = horzcat(CorrelationofMovementswithAllOtherSpineCoActivity{:});
AllOthers_AllFields = vertcat(MovementCorrelationofAllOtherMovements{:});

numFields = length(Clusters_AllFields);
AllClusterValuesbyField = cell(1,numFields);
AnyClusterValuesbyField = cell(1,numFields);
MRSValuesbyField = cell(1,numFields);
NSValuesbyField = cell(1,numFields);
MRSDMValuesbyField = cell(1,numFields);
FMControlValuesbyField = cell(1,numFields);

for i = 1:numFields
    for j = 1:length(Clusters_AllFields{i})
        for k = 1:length(Clusters_AllFields{i}{j})
            AllClusterValuesbyField{i} = [AllClusterValuesbyField{i}; Clusters_AllFields{i}{j}{k}];
        end
        for k = 1:length(AnyClusterAct_AllFields{i}{j})
            AnyClusterValuesbyField{i} = [AnyClusterValuesbyField{i}; AnyClusterAct_AllFields{i}{j}{k}];
        end
        for k = 1:length(NSOnly_AllFields{i}{j})
            NSValuesbyField{i} = [NSValuesbyField{i}; NSOnly_AllFields{i}{j}{k}];
        end
        for k = 1:length(MRSDM_AllFields{i}{j})
            MRSDMValuesbyField{i} = [MRSDMValuesbyField{i}; MRSDM_AllFields{i}{j}{k}];
        end        
        for k = 1:length(FMPairs_AllFields{i}{j})
            FMControlValuesbyField{i} = [FMControlValuesbyField{i}; FMPairs_AllFields{i}{j}{k}];
        end
    end
    for j = 1:length(MRSOnly_AllFields{i})
        for k = 1:length(MRSOnly_AllFields{i}{j})
            MRSValuesbyField{i} = [MRSValuesbyField{i}; MRSOnly_AllFields{i}{j}{k}];
        end
    end
end

MedianClusterValuebyField = cellfun(@nanmedian, AllClusterValuesbyField);
MedianAnyClusterbyField = cellfun(@nanmedian, AnyClusterValuesbyField);
MedianMRSOnlybyField = cellfun(@nanmedian, MRSValuesbyField);
MedianNSOnlybyField = cellfun(@nanmedian, NSValuesbyField);
MedianMRSDMbyField = cellfun(@nanmedian, MRSDMValuesbyField);
MedianFMControlbyField = cellfun(@nanmedian, FMControlValuesbyField);
MedianOtherSPbyField = cellfun(@nanmedian, OtherPairs_AllFields);
MedianAllOtherbyField = cellfun(@nanmedian, AllOthers_AllFields);

Fields_datamat = [{MedianClusterValuebyField}, {MedianAnyClusterbyField}, {MedianMRSOnlybyField}, {MedianNSOnlybyField}, {MedianMRSDMbyField}, {MedianFMControlbyField}, {MedianOtherSPbyField}, {MedianAllOtherbyField'}];

datamat = Fields_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'With Any Clust Act', 'MRS only', 'NS only', 'MRSDM', 'FM ctrl', 'Other SP', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mv. Corr. by Field')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
    [p,~] = signrank(datamat{1},datamat{i});
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

%%% Option 3: This method takes the median of movement correlation values
%%% for each NEW SPINE, and thus averaging uses NEW SPINES as the sample,
%%% and error taken accordingly

%%% Note: MRS, 'Any', and 'Other' categories are not arranged by New Spine
%%% (intentionally) and therefore can't be included here 

subcount = subcount+1;

Clusters_AllNewSpines = horzcat(Clusters_AllFields{:});
NSValues_AllNewSpiness = horzcat(NSOnly_AllFields{:});
MRSDM_AllNewSpines = horzcat(MRSDM_AllFields{:});
FMPairs_AllNewSpines = horzcat(FMPairs_AllFields{:});

num_NewSpines = length(Clusters_AllNewSpines);
AllClusterValuesbyNS = cell(1,num_NewSpines);
NSValuesbyNS = cell(1,num_NewSpines);
MRSDMValuesbyNS = cell(1,num_NewSpines);
FMControlValuesbyNS = cell(1,num_NewSpines);

for i = 1:num_NewSpines
    for j = 1:length(Clusters_AllNewSpines{i})
        AllClusterValuesbyNS{i} = [AllClusterValuesbyNS{i}; Clusters_AllNewSpines{i}{j}];
        NSValuesbyNS{i} = [NSValuesbyNS{i}; NSValues_AllNewSpiness{i}{j}];
        MRSDMValuesbyNS{i} = [MRSDMValuesbyNS{i}; MRSDM_AllNewSpines{i}{j}];
        FMControlValuesbyNS{i} = [FMControlValuesbyNS{i}; FMPairs_AllNewSpines{i}{j}];
    end
end

MedianClusterValuebyNS = cellfun(@nanmedian, AllClusterValuesbyNS);
MedianNSOnlybyNS = cellfun(@nanmedian, NSValuesbyNS);
MedianMRSDMbyNS = cellfun(@nanmedian, MRSDMValuesbyNS);
MedianFMControlbyNS = cellfun(@nanmedian, FMControlValuesbyNS);

NS_datamat = [{MedianClusterValuebyNS}, {MedianNSOnlybyNS}, {MedianMRSDMbyNS}, {MedianFMControlbyNS}, {MedianAllOtherbyField}];

datamat = NS_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'NS only', 'MRSDM', 'FM ctrl', 'All Other'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mv. Corr. by NS')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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

%%% Option 4: This method takes the median of movement correlation values
%%% for each CLUSTER, and thus averaging uses CLUSTERS as the sample
subcount = subcount+1;

AllClusters = horzcat(Clusters_AllNewSpines{:});
AllNSbyCluster = horzcat(NSValues_AllNewSpiness{:});
AllMRSDMPairs = horzcat(MRSDM_AllNewSpines{:});
AllFMPairs = horzcat(FMPairs_AllNewSpines{:});

MedianClusterValuebyCluster = cellfun(@nanmedian, AllClusters);
MedianNSOnlybyCluster = cellfun(@nanmedian, AllNSbyCluster);
MedianMRSDMbyCluster = cellfun(@nanmedian, AllMRSDMPairs);
MedianFMControlbyCluster = cellfun(@nanmedian, AllFMPairs);

Cluster_datamat = [{MedianClusterValuebyCluster}, {MedianNSOnlybyCluster}, {MedianMRSDMbyCluster}, {MedianFMControlbyCluster}, {MedianOtherSPbyField}, {MedianAllOtherbyField}];
datamat = Cluster_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'NS only', 'MRSDM', 'Freq matched pairs', 'Other SP', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mv. Corr. by Clust')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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

%%% Option 5: This method looks at all movement correlations as a single
%%% sample, thus the same size is the number of MOVEMENT PAIRS. Note,
%%% however, that the movement pairs are still separated by cluster, and so
%%% we are not considering how similar movements across clusters are. 
subcount =subcount+1;

AllClusterMovementPairs = cell2mat(AllClusters');
AllMRSOnlyMovementPairs = cell2mat(MRSValuesbyField');
AllNSOnlyMovementPairs = cell2mat(AllNSbyCluster');
AnyClustActMovementPairs = [AllClusterMovementPairs; AllMRSOnlyMovementPairs; AllNSOnlyMovementPairs];
AllMRSDMMovementPairs = cell2mat(AllMRSDMPairs');
AllFMControlMovementPairs = cell2mat(AllFMPairs');
AllOtherSpinePairsMovementPairs = cell2mat(OtherPairs_AllFields);
AllOtherMovementPairs = cell2mat(AllOthers_AllFields);

MovementPair_datamat = [{AllClusterMovementPairs},{AnyClustActMovementPairs}, {AllMRSOnlyMovementPairs}, {AllNSOnlyMovementPairs}, {AllMRSDMMovementPairs},{AllFMControlMovementPairs}, {AllOtherMovementPairs}];

datamat = MovementPair_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'With Any Clust Act', 'MRS only', 'NS only', 'MRSDM', 'Freq matched pairs', 'All Other'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mv. Corr. by Mv. Pairs')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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


%======== Being combining movements across different levels
%%% Option 6: This method concatenates all target movements together for a
%%% particular FIELD, thus broadening the definition of what, e.g.,
%%% movements with cluster co-activity can mean (i.e. movements with ANY
%%% cluster co-activity, taken across any of the late sessions). The
%%% assumption here is that cluster co-activity might represent a larger
%%% circuit-wide movement scheme 
subcount = subcount +1;

% datamat = [{horzcat(MovementswithClusteredCoActivity{:})}, {cellfun(@(x,y,z) [x,y,z], horzcat(MovementswithClusteredCoActivity{:}), horzcat(MovementswithMRSOnlyActivity{:}), horzcat(MovementswithNSOnlyActivity{:}), 'uni', false)},{horzcat(AllOtherMovements{:})}, {horzcat(MovementswithMRSOnlyActivity{:})}, {horzcat(MovementswithNSOnlyActivity{:})}, {horzcat(MovementswithFMControlCoActivity{:})}];
% datamat = [{cell2mat(horzcat(MovementswithClusteredCoActivity{:}))}, {cell2mat(cellfun(@(x,y,z) [x,y,z], horzcat(MovementswithClusteredCoActivity{:}), horzcat(MovementswithMRSOnlyActivity{:}), horzcat(MovementswithNSOnlyActivity{:}), 'uni', false))},{cell2mat(horzcat(AllOtherMovements{:}))}, {cell2mat(horzcat(MovementswithMRSOnlyActivity{:}))}, {cell2mat(horzcat(MovementswithNSOnlyActivity{:}))}, {cell2mat(horzcat(MovementswithFMControlCoActivity{:}))}];
% datamat = [{cellfun(@cell2mat, MovementswithClusteredCoActivity, 'uni', false)}, {cellfun(@(x,y,z) [x,y,z], cellfun(@cell2mat, MovementswithClusteredCoActivity, 'uni', false), cellfun(@cell2mat, MovementswithMRSOnlyActivity, 'uni', false), cellfun(@cell2mat, MovementswithNSOnlyActivity, 'uni', false), 'uni', false)},{cellfun(@cell2mat, AllOtherMovements, 'uni', false)}, {cellfun(@cell2mat, MovementswithMRSOnlyActivity, 'uni', false)}, {cellfun(@cell2mat, MovementswithNSOnlyActivity, 'uni', false)}, {cellfun(@cell2mat, MovementswithFMControlCoActivity, 'uni', false)}];

%%% Reorganize MRSDM data to be like that of other movement set data (i.e.
%%% arranged by field and not by cluster)
% MovementswithMRSDMCoActivity = cell(1,length(MovementswithMRSDMCoActivity));
% for i = 1:length(MovementswithMRSDMCoActivity)
%     MovementswithMRSDMCoActivity{i} = cell(1,length(MovementswithMRSDMCoActivity{i}));
%     existingdata = MovementswithMRSDMCoActivity{i}(~cellfun(@isempty, MovementswithMRSDMCoActivity{i}));
%     for j = 1:length(existingdata)
%         fielddata = horzcat(existingdata{j}{:});
%         MovementswithMRSDMCoActivity{i}{j} = cell2mat(fielddata);
%     end
% end

datamat = [{MovementswithClusteredCoActivity}, {MovementswithMRSOnlyActivity}, {MovementswithNSOnlyActivity}, {MovementswithMRSDMCoActivity},{MovementswithFMControlCoActivity},{MovementswithAllOtherSpineCoActivity}, {WithoutGroupMovements}];

datamatmvpairs = [];
datamatfield = [];
datamatanimal = [];
ignorefields = [];
for i = 1:length(datamat)
    fieldcount = 1; 
    for j = 1:length(datamat{i})
        newcorr = cellfun(@corrcoef, datamat{i}{j}, 'uni', false);
        for k = 1:length(newcorr)
            newcorr{k}(1:size(newcorr{k},1)+1:end) = nan;
            fieldcount = fieldcount+1;
        end        
        datamatmvpairs{i}{j} = cell2mat(cellfun(@(x) x(:), newcorr, 'uni', false)');
        datamatfield{i}{j} = cellfun(@(x) nanmedian(x(:)), newcorr);
%         ignorefields = cellfun(@(x) size(x,2), datamat{i}{j}, 'uni', true)<3; %%% Filter for minimum MOVEMENT NUMBER!!!!!!!!
%         datamatfield{i}{j}(ignorefields) = nan;
    end
    datamatanimal{i} = cellfun(@nanmedian, datamatfield{i});
end

subplot(sub1,sub2,subcount)

%%% Average across animals
datamat = datamatanimal;
bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters','MRS only', 'NS only', 'MRSDM', 'Freq matched pairs', 'All Other SPs', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mvmts Comb. by Field, Ave by Animal')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
    [p,~] = signrank(datamat{1},datamat{i});
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
subcount = subcount+1; 

%%% Average across fields 
subplot(sub1,sub2,subcount)
datamat =  cellfun(@cell2mat, datamatfield, 'uni', false);
bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters','MRS only', 'NS only','MRSDM', 'Freq matched pairs', 'All Other SPs', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mvmts Comb. by Field, Ave. by Field')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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
        if i == cand(end)
            text(mean([1,(i)])-0.1, maxline+0.01, ['ns, (p = , ' num2str(p), ')'])
        else
            text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
        end
    end
    maxline = maxline+statline_increment;
end
subcount = subcount+1; 

%%% Average across movement pairs
subplot(sub1,sub2,subcount)
datamat = [];
for i = 1:length(datamatmvpairs)
    datamat{i} = cell2mat(datamatmvpairs{i}');
end
    
bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'MRS only', 'NS only', 'MRSDM', 'Freq matched pairs', 'All Other SPs', 'Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mvmts Comb. by Field, Ave by MvPairs')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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

%%% Option 7: This method concatenates all target movements together for a
%%% particular ANIMAL, thus broadening the definition of what, e.g.,
%%% movements with cluster co-activity can mean (i.e. movements with ANY
%%% cluster co-activity, taken across any of the late sessions). The
%%% assumption here is that cluster co-activity might represent a larger
%%% circuit-wide movement scheme 

subcount = 11;

AllClustCoAMovementsbyAnimal = cell(1,numAnimals);
AllMRSonlyMovementsbyAnimal = cell(1,numAnimals);
AllNSonlyMovementsbyAnimal = cell(1,numAnimals);
AllMRSDMMovementsbyAnimal = cell(1,numAnimals);
AllFMctrlMovementsbyAnimal = cell(1,numAnimals);
AllOtherMovementsbyAnimal = cell(1,numAnimals);

for i=1:numAnimals
    for j = 1:length(MovementswithClusteredCoActivity{i})
        AllClustCoAMovementsbyAnimal{i} = [AllClustCoAMovementsbyAnimal{i}, MovementswithClusteredCoActivity{i}{j}];
    end
    for j = 1:length(MovementswithMRSOnlyActivity{i})
        AllMRSonlyMovementsbyAnimal{i} = [AllMRSonlyMovementsbyAnimal{i}, MovementswithMRSOnlyActivity{i}{j}];
    end
    for j = 1:length(MovementswithNSOnlyActivity{i})
        AllNSonlyMovementsbyAnimal{i} = [AllNSonlyMovementsbyAnimal{i}, MovementswithNSOnlyActivity{i}{j}];
    end
    for j = 1:length(MovementswithMRSDMCoActivity{i})
        AllMRSDMMovementsbyAnimal{i} = [AllMRSDMMovementsbyAnimal{i}, MovementswithMRSDMCoActivity{i}{j}];
    end
    for j = 1:length(MovementswithFMControlCoActivity{i})
        AllFMctrlMovementsbyAnimal{i} = [AllFMctrlMovementsbyAnimal{i}, MovementswithFMControlCoActivity{i}{j}];
    end
    for j = 1:length(WithoutGroupMovements{i})
        AllOtherMovementsbyAnimal{i} = [AllOtherMovementsbyAnimal{i}, WithoutGroupMovements{i}{j}];
    end
end
AllAnyClustActMovementsbyAnimal = cellfun(@(x,y,z) [x,y,z], AllClustCoAMovementsbyAnimal,AllMRSonlyMovementsbyAnimal,AllNSonlyMovementsbyAnimal, 'uni', false);

datamat = [{AllClustCoAMovementsbyAnimal}, {AllAnyClustActMovementsbyAnimal},{AllMRSonlyMovementsbyAnimal}, {AllNSonlyMovementsbyAnimal}, {AllMRSDMMovementsbyAnimal}, {AllFMctrlMovementsbyAnimal}, {AllOtherMovementsbyAnimal}];

datamatmvpair = [];
datamatanimal = [];
for i = 1:length(datamat)
    newcorr = cellfun(@corrcoef, cellfun(@zscore,datamat{i}, 'uni', false), 'uni', false);
    for j = 1:length(newcorr)
        newcorr{j}(1:size(newcorr{j},1)+1:end) = nan;
    end
    datamatmvpair{i} = cell2mat(cellfun(@(x) x(:), newcorr, 'uni', false)');
    datamatanimal{i} = cellfun(@(x) nanmedian(x(:)), newcorr);
end

subplot(sub1,sub2,subcount)
%%% Average by animal
datamat = datamatanimal;
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'With Any Clust Act', 'MRS only', 'NS only', 'MRSDM', 'Freq matched pairs','Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('All Mvmts Comb by Animal, Ave by Animal')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
    [p,~] = signrank(datamat{1},datamat{i});
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

subcount = subcount+1;
subplot(sub1,sub2,subcount)
%%% Average by move pairs
datamat = datamatmvpair;

bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'Any Clust Act', 'MRS only', 'NS only','MRSDM', 'Freq matched pairs','Without'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Mvmts comb by animal, ave by mv pairs')

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

cand = find(~cellfun(@isempty, Y)); cand = cand(2:end);
for i = cand
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
%==========================================================================
%%% PCA of movements

temp = horzcat(MovementswithClusteredCoActivity{:});
AllClustMovs = horzcat(temp{:});

temp = horzcat(WithoutGroupMovements{:});
WithoutGroupMovs = horzcat(temp{:});

[coeffs, scores, ~, ~, explained, ~] = pca([AllClustMovs'; WithoutGroupMovs']);

figure; hold on; 

subplot(1,2,1); 
plot(scores(1:size(AllClustMovs,2),1), scores(1:size(AllClustMovs,2),2), 'o', 'MarkerEdgeColor', lblue, 'markerfacecolor', lblue); hold on;
plot(scores(size(AllClustMovs,2)+1:size(AllClustMovs,2)+size(WithoutGroupMovs,2),1), scores(size(AllClustMovs,2)+1:size(AllClustMovs,2)+size(WithoutGroupMovs,2),2), 'o', 'MarkerEdgeColor', 'k', 'markerfacecolor', gray)
xlabel('PC1')
ylabel('PC2')

subplot(1,2,2); %%% Summarize PC1 scores for the different movement groups
datamat = [{scores(1:size(AllClustMovs,2),1)},{scores(size(AllClustMovs,2)+1:size(AllClustMovs,2)+size(WithoutGroupMovs,2),1)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Corr. of Mvmts with Model')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%==========================================================================

figure; hold on; 
sub1 = 1;
sub2 = 4;

subplot(sub1,sub2,1)
% datamat = [{cell2mat(CoActiveClusterMovementsCorrelationwithModelMovement)}, {cell2mat(AllOtherMovementsCorrelationwithModelMovement)}, {cell2mat(FMControlMovementsCorrelationwithModelMovement)}];
datamat = [{cellfun(@nanmedian, vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(AllOtherMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(FMControlMovementsCorrelationwithModelMovement{:}))}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Corr. of Mvmts with Model')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%% Dot products of cluster co-activity with movements
subplot(sub1,sub2,2) 
% datamat = [{cell2mat(DotProductofCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofCoactivityMovementOverlap)}, {cell2mat(DotProductofFMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofFMCoActivitywithmovement)}, {cell2mat(DotProductofNSDMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofNSDMCoActivitywithMovement)}, {cell2mat(DotProductofMRSDMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofMRSDMCoActivitywithMovement)}];
datamat = [{cellfun(@nanmedian, DotProductofCoActivePeriodsDuringMovement)}, {cellfun(@nanmedian, ChanceLevelofCoactivityMovementOverlap)}, {cellfun(@nanmedian, DotProductofFMCoActivePeriodsDuringMovement)}, {cellfun(@nanmedian, ChanceLevelofFMCoActivitywithmovement)}, {cellfun(@nanmedian, DotProductofNSDMCoActivePeriodsDuringMovement)}, {cellfun(@nanmedian, ChanceLevelofNSDMCoActivitywithMovement)}, {cellfun(@nanmedian, DotProductofMRSDMCoActivePeriodsDuringMovement)}, {cellfun(@nanmedian, ChanceLevelofMRSDMCoActivitywithMovement)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
xtickangle(gca, 45)
set(gca, 'XTickLabel', {'CoA w Movement', 'chance', 'FMCoA w Movement', 'chance', 'NSDMCoA w Movement', 'chance', 'MRSDMCoA with Movement', 'chance'})
ylabel('Dot Product of Activity and Movement')
maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

for i = 2:length(datamat)
    [p,~] = signrank(datamat{1},datamat{i});
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

subplot(sub1,sub2,3)

datamat = [{cell2mat(DotProductofCoActivePeriodsDuringCRMovement)}, {cell2mat(ChanceLevelofCoActivityCRMovementOverlap)}, {cell2mat(DotProductofFMCoActivePeriodsDuringCRMovement)}, {cell2mat(ChanceLevelofFMCoActivityCRMovementOverlap)}];
datamat = [{cellfun(@nanmedian, DotProductofCoActivePeriodsDuringCRMovement)}, {cellfun(@nanmedian, ChanceLevelofCoActivityCRMovementOverlap)}, {cellfun(@nanmedian, DotProductofFMCoActivePeriodsDuringCRMovement)}, {cellfun(@nanmedian, ChanceLevelofFMCoActivityCRMovementOverlap)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTickLabel', {'CoA with CRMovements', 'Chance'})
ylabel('Dot Product of Activity and Movement')
xtickangle(gca, 45)

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

subplot(sub1,sub2,4)
% datamat = [{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCoActiveMovementRewarded)}, {cellfun(@nanmedian, ChanceRewardedLevel)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCompCoActiveMovementRewarded)}, {cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsMoveOnlyRewarded)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsNewOnlyRewarded)}];
datamat = [{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCoActiveMovementRewarded)}, {cellfun(@nanmedian, ChanceRewardedLevel)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCompCoActiveMovementRewarded)}, {cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsMoveOnlyRewarded)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsNewOnlyRewarded)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
ylabel('Fraction of Movements Rewarded')
set(gca, 'XTickLabel', {'CoA with Movement', 'chance', 'FMCoA w Movement', 'MRS only', 'NS only'})
xtickangle(gca, 45)

maxline = max(cell2mat(Y'));
statline_increment = nanmedian(datamat{1})/5;

for i = 2:length(datamat)
    [p,~] = signrank(datamat{1},datamat{i});
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 19: Correlation of movements during co-active ANTI-cluster periods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on
subplot(1,3,1)
datamat = [{cell2mat(MovementCorrelationwithCoActiveAntiClusters')}, {cell2mat(MovementCorrelationofAllOtherMovementsElimVersion')}, {cell2mat(MovementCorrelationofFrequencyMatchedPairsElimVersion')}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive AntiClusters', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation of Movements during CoActive AntiCluster Periods')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%% Correlation with model movement (i.e. average movement from final
%%% session of training 

subplot(1,3,2)
datamat = [{cell2mat(CoActiveAntiClusterMovementsCorrelationwithModelMovement')}, {cell2mat(AllOtherMovementsCorrelationwithModelMovementElimVersion')}, {cell2mat(FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion')}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation of Movements with Model Movement')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

subplot(1,3,3) 
datamat = [{cellfun(@nanmean, cellfun(@(x) cell2mat(x'), IsCoActiveAntiClusterMovementRewarded, 'uni', false))}, {cellfun(@nanmean, cellfun(@(x) cell2mat(x'), IsMovementRewardedEarly, 'uni', false))}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Co-active anticluster periods', 'shuffled'})
ylabel('% Rewarded')
title('Likelihood of co-active cluster movements being rewarded')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 19: New spine-HCP features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on

datamat = [{cell2mat(MovementCorrelationwithCoActiveHCPClusters)}, {cell2mat(MovementCorrelationofAllOtherNonHCPMovements)}, {cell2mat(MovementCorrelationofHCPComparatorSpines)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive HCP', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation of Movements during CoActive HCP Periods')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 20: Move Spine Frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; hold on; 
datamat = [{cell2mat(ClusteredMoveSpineFrequency')}, {cell2mat(ClusteredNewSpineFrequency')}, {cell2mat(OtherSpineFrequencyOnDendswithClusters')}, {cell2mat(OtherSpineFrequencyOnDendswithoutClusters')},];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clust. Mov', 'Clust. New', 'Other on Clust Dends', 'Other'})
xtickangle(gca, 45)
ylabel('Event Frequency (/min)')
title('Frequency of Clusters vs. Other Spines')

maxline = max([nanmax(datamat{1}), nanmax(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 22: Fraction of Dendrites showing both types of spine dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FractionofDendswithBothDynamics = sum(cell2mat(DendsWithBothDynamics))/sum(NumberofImagedDendrites);
FractionofDendswithBothClustDynamics = sum(cell2mat(DendsWithBothClustDynamics))/sum(NumberofImagedDendrites);

NewSpinesOrganizedByDendritesImaged = cellfun(@(x) horzcat(x{:}), NewSpinesbyDendrite, 'uni', false);   %%% "NewSpinesbyDendrite" organizes by animal, field, then dendrite; this removes the field component and concatenates all dendrites imaged by animal
fullnewspinelist = cell2mat(cellfun(@(x) cell2mat(x(:)), NewSpinesOrganizedByDendritesImaged, 'uni', false)');
ClusteredNewSpinesOrganizedByDendritesImaged = cellfun(@(x) horzcat(x{:}), ClusteredNewSpinesbyDendrite, 'uni', false);
fullclusterednewspinelist = cell2mat(cellfun(@(x) cell2mat(x(:)), ClusteredNewSpinesOrganizedByDendritesImaged, 'uni', false)');

ElimSpinesOrganizedByDendritesImaged = cellfun(@(x) horzcat(x{:}), ElimSpinesbyDendrite, 'uni', false);   %%% "NewSpinesbyDendrite" organizes by animal, field, then dendrite; this removes the field component and concatenates all dendrites imaged by animal
fullelimspinelist = cell2mat(cellfun(@(x) cell2mat(x(:)), ElimSpinesOrganizedByDendritesImaged, 'uni', false)');
AntiClusteredElimSpinesOrganizedByDendritesImaged = cellfun(@(x) horzcat(x{:}), AntiClusteredElimSpinesbyDendrite, 'uni', false);
fullanticlusteredelimspinelist = cell2mat(cellfun(@(x) cell2mat(x(:)), AntiClusteredElimSpinesOrganizedByDendritesImaged, 'uni', false)');

SpinesOnEachDend = [];
for i = 1:length(NewSpinesOrganizedByDendritesImaged)
    SpinesOnEachDend = [SpinesOnEachDend, cell2mat(cellfun(@length, NewSpinesOrganizedByDendritesImaged{i}, 'uni', false))];
end
DendArray = [];
for i = 1:length(SpinesOnEachDend)
    DendArray = [DendArray; i*ones(SpinesOnEachDend(i),1)];
end
boundsDend = find(diff([Inf;DendArray;Inf])~=0);

shuffnum = 1000;
for i = 1:shuffnum
    ShuffledNew = shake(fullnewspinelist);
    ShuffledClustNew = shake(fullclusterednewspinelist);
    ShuffledElim = shake(fullelimspinelist);
    ShuffAntiClustElim = shake(fullanticlusteredelimspinelist);
    
    ShuffledNewByDend = mat2cell(ShuffledNew, diff(boundsDend));
    ShuffClustNewByDend = mat2cell(ShuffledClustNew, diff(boundsDend));
    ShuffledElimByDend = mat2cell(ShuffledElim, diff(boundsDend));
    ShuffAntiClustElimByDend = mat2cell(ShuffAntiClustElim, diff(boundsDend));
    
    ShuffledBothDynamics(i) = sum(cell2mat(cellfun(@(x,y) any(x)&any(y), ShuffledNewByDend, ShuffledElimByDend, 'uni', false)));
    ShuffledBothClustDynamics(i) = sum(cell2mat(cellfun(@(x,y) any(x)&any(y), ShuffClustNewByDend,ShuffAntiClustElimByDend, 'uni', false)));
    if ShuffledBothDynamics(i) < sum(cell2mat(DendsWithBothDynamics))
        BothDynamicsStat(i) = 1;
    else
        BothDynamicsStat(i) = 0;
    end
    if ShuffledBothClustDynamics(i) < sum(cell2mat(DendsWithBothClustDynamics))
        BothClustDynamicsStat(i) = 1;
    else
        BothClustDynamicsStat(i) = 0;
    end
end

ChanceLevelofBothDynamics = ShuffledBothDynamics./sum(NumberofImagedDendrites);
ChanceLevelofBothClustDynamics = ShuffledBothClustDynamics./sum(NumberofImagedDendrites);

figure; a = subplot(1,2,1);
bar(1,FractionofDendswithBothDynamics);
hold on; bar(2,nanmedian(ChanceLevelofBothDynamics))
    Y = bootci(bootstrpnum, {@median, ChanceLevelofBothDynamics}, 'alpha', 0.05);
    line([2,2], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
title('Number of Dendrites with Both Types of Dynamics')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Data', 'Chance'})
ylabel('Fraction')

b = subplot(1,2,2);
bar(1,FractionofDendswithBothClustDynamics)
hold on; bar(2,nanmean(ChanceLevelofBothClustDynamics))
    Y = bootci(bootstrpnum, {@median, ChanceLevelofBothClustDynamics}, 'alpha', 0.05);
    line([2,2], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
title('Number of Dendrites with Both Types of Clust Dyn')
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Data', 'Chance'})
ylabel('Fraction')

linkaxes([a,b], 'y')
end