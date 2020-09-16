function NewSpineAnalysis(varargin)

global gui_KomiyamaLabHub
experimentnames = varargin;

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
end

shuffnum = 1000;
bootstrpnum = shuffnum;
alphaforbootstrap = 0.05;
spine_enlargement_cutoff = 1.25;

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
    LeverSlopeTraces{i} = currentdata.LeverSlopeTraces;
    ShuffledClustActivityStart{i} = currentdata.ShuffledClustActivityStart;
    ShuffledActivityStartNormalizedtoMovementLength{i} = currentdata.ShuffledActivityStartNormalizedtoMovementLength;
    StandardDeviationofShuffledActivityOnset{i} = currentdata.StandardDeviationofShuffledActivityOnset;
    StandardDeviationofNormShuffledActivityOnset{i} = currentdata.StandardDeviationofNormShuffledActivityOnset;
    LeverPositionatShuffledActivityOnset{i} = currentdata.LeverPositionatShuffledActivityOnset;
    LeverVelocityatShuffledActivityOnset{i} = currentdata.LeverVelocityatShuffledActivityOnset;
    FMActivityStartRelativetoMovement{i} = currentdata.FMActivityStartRelativetoMovement;
    MRSDMActivityStartRelativetoMovement{i} = currentdata.MRSDMActivityStartRelativetoMovement;
    NSDMActivityStartRelativetoMovement{i} = currentdata.NSDMActivityStartRelativetoMovement;
    NSonlyActivityStartRelativetoMovement{i} = currentdata.NSonlyActivityStartRelativetoMovement;
    StandardDeviationofNSOnlyActivityOnset{i} = currentdata.StandardDeviationofNSOnlyActivityOnset;
    LeverPositionatNSOnlyActivityOnset{i} = currentdata.LeverPositionatNSOnlyActivityOnset;
    LeverVelocityatNSOnlyActivityOnset{i} = currentdata.LeverVelocityatNSOnlyActivityOnset;
    
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
%     AllDeltaSpineVolume{i} = currentdata.AllDeltaSpineVolume;
    ClusteredMovementSpineVolume{i} = currentdata.ClusteredMovementSpineVolume;
    
    NewSpineAllDistancestoEarlyMovementSpines{i} = currentdata.NewSpineAllDistancestoEarlyMovementSpines;
    SimilarityofClusteredMovementwithSeedlingMRSMovement{i} = currentdata.SimilarityofClusteredMovementwithSeedlingMRSMovement;
    AllCoActivityDotProductsforDistanceMeasurement{i} = currentdata.AllCoActivityDotProductsforDistanceMeasurement;
    AllCoActivityChanceLevelDotProductsforDistanceMeasurement{i} = currentdata.AllCoActivityChanceLevelDotProductsforDistanceMeasurement;

    FractionofNewSpinesMeetingClusterCriteria{i} = currentdata.FractionofNewSpinesMeetingClusterCriteria;
    SimClusterCorr{i} = currentdata.SimClusterCorr;
    
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 1: Prevalence of Spine Dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 2: Spine Dynamics and Movement Relatedness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 3: Predictive Features of Becoming movement related
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 5: Movement-Relatedness and Clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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

%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 5: Characterization of Dynamic Spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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

PofA = length(cell2mat(PersistentNewSpines'))/length(cell2mat(cellfun(@(x) cell2mat(x'), MiddleSessionNewSpines,'uni', false)'));
PofB = NumberofMovementClusteredNewSpines(ind)./NumberofNewSpines(ind);
PofAnB = NumberofMovementClusteredNewSpinesThatAreMR(ind)./NumberofNewSpines(ind);

subplot(2,3,6)
bar(1,PofA); hold on;
set(gca, 'XTickLabel', {'Middle Session New Spines Preserved'})
text(1, PofA+0.02, [num2str(length(cell2mat(PersistentNewSpines'))), '/', num2str(length(cell2mat(cellfun(@(x) cell2mat(x'), MiddleSessionNewSpines,'uni', false)')))])


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

%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 6: Persistence of Movement Related Spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

figure; 
subplot(1,2,1)

NumberofPersistentMovementSpinesClustered(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false))) = mat2cell(zeros(1,sum(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false)))),1,ones(1,sum(cell2mat(cellfun(@isempty, NumberofPersistentMovementSpinesClustered, 'uni', false))))); %%% Replace any empty cells with cells of {0}

allmat = [sum(cell2mat(NumberofPersistentMovementRelatedSpines))/sum(NumberofEarlierSessionMovementRelatedSpines), sum(cell2mat(NumberofPersistentMovementSpinesClustered))/sum(cell2mat(NumberofPersistentMovementRelatedSpines))];
bar(allmat, 'FaceColor', red);

text(1,sum(cell2mat(NumberofPersistentMovementRelatedSpines))/sum(NumberofEarlierSessionMovementRelatedSpines)+0.05, [num2str(sum(cell2mat(NumberofPersistentMovementRelatedSpines))), '/', num2str(sum(NumberofEarlierSessionMovementRelatedSpines))])
text(2,sum(cell2mat(NumberofPersistentMovementSpinesClustered))/sum(cell2mat(NumberofPersistentMovementRelatedSpines))+0.05, [num2str(sum(cell2mat(NumberofPersistentMovementSpinesClustered))), '/', num2str(sum(cell2mat(NumberofPersistentMovementRelatedSpines)))])
ylim([0 1])   
xlim([0 3])
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'Persistent MRS', 'Persistent MRS that cluster'})
ylabel('Fraction')
title('Fraction of Persistent MRSs')

ind = find(NumberofEarlierSessionMovementRelatedSpines);

PersistentMRSbyanimal = cell2mat(cellfun(@sum, NumberofPersistentMovementRelatedSpines, 'uni', false));
PofA = PersistentMRSbyanimal(ind)./(NumberofEarlierSessionMovementRelatedSpines(ind));                                                 %%% The probability of a MRS from early sessions being PERSISTENT
PofB = cell2mat(cellfun(@sum ,NumberofClusteredMoveSpines(ind), 'uni', false))./NumberofEarlierSessionMovementRelatedSpines(ind);    %%% The probability of a MRS from early sessions being CLUSTERED (i.e. having a new spine form nearby)
persistentandclustered = cell2mat(cellfun(@sum, NumberofPersistentMovementSpinesClustered, 'uni', false));
PofAnB = persistentandclustered(ind)./NumberofEarlierSessionMovementRelatedSpines(ind);

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


if signrank([PofA.*PofB], PofAnB)<0.05
    text(1.4, maxline+0.03, '*')
else
    text(1.4, maxline+0.03, ['ns (p = ', num2str(signrank([PofA.*PofB], PofAnB))])
end

%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 7: Number of Movement Spines on Dynamic vs. Static Dendrites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 8: Distance Between Dynamic Spines and MR spines based on
%%% several metrics (closest, enlarged, highest movement-relatedness, etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

AllNewSpineDistances = [];AllNoiseCorr = [];HighCorrDistances = [];AllVolumes = []; EnlargedSpinesDistances = []; AllSeedlingMovCorr = []; DotProducts = []; ChanceDotProducts = [];AllMMCorr = []; WithinMovCorr = []; AllFractions = [];IsRew = []; IsChanceRew = [];AllCoARates = []; AllLeverVelocitySD = [];
AllTransDistances = []; AllTransCorr = []; AllTransCoA = [];
AllTransDistancesbyField = cell(1,sum(cell2mat(NumFields))); AllTransCorrbyField = cell(1,sum(cell2mat(NumFields))); AllTransCoAbyField = cell(1,sum(cell2mat(NumFields)));
transientnewspines = 0;
fieldcount = 1;
for animal = 1:length(DistancetoHighCorrMovementSpines)
    for field = 1:length(DistancetoHighCorrMovementSpines{animal})
        if size(AllMovementSpines{animal}{field},2) == 3
            midMRSs = AllMovementSpines{animal}{field}(:,2);
        else
            midMRSs = [];
        end
        for ns = 1:length(DistancetoHighCorrMovementSpines{animal}{field})
            AllNewSpineDistances = [AllNewSpineDistances, NewSpineAllDistancestoEarlyMovementSpines{animal}{field}{ns}];
            AllNoiseCorr = [AllNoiseCorr, AllMoveCentricClusterCorrelationsbyNewSpine{animal}{field}{ns}];
            AllVolumes = [AllVolumes, ClusteredMovementSpineVolume{animal}{field}{ns}];
            HighCorrDistances = [HighCorrDistances, DistancetoHighCorrMovementSpines{animal}{field}{ns}];
            EnlargedSpinesDistances = [EnlargedSpinesDistances, nanmin(DistancetoEnlargedSpines{animal}{field}{ns})];
%             AllSeedlingMovCorr = [AllSeedlingMovCorr, SimilarityofClusteredMovementwithSeedlingMRSMovement{animal}{field}{ns}];
            if ~isempty(LeverVelocityatClustActivityOnset{animal}{field}{ns}{1})
                AllLeverVelocitySD = [AllLeverVelocitySD, cellfun(@(x) std(x(:,4))/sqrt(size(x,1)), LeverVelocityatClustActivityOnset{animal}{field}{ns})];
            else
            end
            DotProducts = [DotProducts, AllCoActivityDotProductsforDistanceMeasurement{animal}{field}{ns}];
            ChanceDotProducts = [ChanceDotProducts, AllCoActivityChanceLevelDotProductsforDistanceMeasurement{animal}{field}{ns}];
            AllMMCorr = [AllMMCorr, cellfun(@nanmedian, CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{animal}{field}{ns})];
            WithinMovCorr = [WithinMovCorr, cellfun(@nanmedian, CorrelationofMovementswithCoActiveClusterActivitybyCluster{animal}{field}{ns})];
            AllFractions = [AllFractions, FractionofMovementswithClusterCoActivitybyCluster{animal}{field}{ns}];
            if ~isempty(IsCoActiveMovementRewarded{animal}{field}{ns})
                IsRew = [IsRew, cellfun(@nanmean, IsCoActiveMovementRewarded{animal}{field}{ns})];
                IsChanceRew = [IsChanceRew, ChanceRewardedLevel{animal}{field}{ns}];
            end
            AllCoARates = [AllCoARates, cell2mat(ClustCoActiveRate{animal}{field}{ns})];
        end
        if ~isempty(AllTransientNewSpinesDistance{animal}{field})
            transientnewspines = transientnewspines+size(AllTransientNewSpinesDistance{animal}{field},1);
            AllTransDistances = [AllTransDistances, reshape(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs)))];
            AllTransDistancesbyField{fieldcount} = [AllTransDistancesbyField{fieldcount}, reshape(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesDistance{animal}{field}(:,midMRSs)))];
            AllTransCorr = [AllTransCorr, reshape(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs)))];
            AllTransCorrbyField{fieldcount} = [AllTransCorrbyField{fieldcount}, reshape(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs),1,numel(AllTransientNewSpinesMidCorr{animal}{field}(:,midMRSs)))];
            midCoAdata = vertcat(TransientSpineCoActiveRateGeoNormalized{animal}{field}{:});
            AllTransCoA = [AllTransCoA, reshape(midCoAdata(:,:),1,numel(midCoAdata(:,:)))];
            AllTransCoAbyField{fieldcount} = [AllTransCoAbyField{fieldcount}, reshape(midCoAdata(:,:),1,numel(midCoAdata(:,:)))];
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

AllNewSpineDistances = AllNewSpineDistances(~isnan(AllNewSpineDistances));

AllTransCorr = AllTransCorr(~isnan(AllTransDistances));
AllTransCoA = AllTransCoA(~isnan(AllTransDistances));
AllTransDistances = AllTransDistances(~isnan(AllTransDistances));


simcorr = []; simwithincorr = []; simtranscorr = []; simtransCoA = [];
for shuff = 1:1000
    [~,ind] = sort(shake(AllNewSpineDistances));
    simDP(:,shuff) = DotProducts(ind);
    simcorr(:,shuff) = AllMMCorr(ind);
    simwithincorr(:,shuff) = WithinMovCorr(ind);
    simVelSD(:,shuff) = AllLeverVelocitySD(ind);
    simRewFrac(:,shuff) = IsRew(ind);
    [~,ind] = sort(shake(AllTransDistances));
    simtranscorr(:,shuff) = AllTransCorr(ind);
    simtransCoA(:,shuff) = AllTransCoA(ind); 
end

count = 1;
DPBins = []; DPBinsSEM = []; CDPBins = []; CDPBinsSEM = []; MMBins = []; MMBinsSEM = []; ChanceMMBins = []; ChanceMMBinsSEM = []; SeedBins = []; SeedBinsError = []; LevVelSDBins = []; LevVelSDBinsSEM = []; WithinMovBins = []; WithinMovBinsSEM = []; ChanceWithinMovBins = []; ChanceWithinMovBinsSEM = []; IsRewBins = []; IsRewBinsError = []; IsChanceRewBins = []; IsChanceRewError = [];
TransBins = []; TransBinsSEM = []; ChanceTransBins = []; ChanceTransBinsSEM = []; TransCoABins = []; TransCoAError = []; ChanceTransCoABins = []; ChanceTransCoABinsError = [];
%%%
binsize = 5;
xvals = 0:binsize:25;
%%%

for i = xvals
    data = DotProducts(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
    DPBins(count) = nanmean(data);
    DPBinsSEM(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimDPvals = simDP(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    CDPBins(count) = nanmean(allsimDPvals(:));
    CDPBinsSEM(count) = nanstd(allsimDPvals(:))/sqrt(sum(~isnan(data)));
    
    data = AllMMCorr(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
    MMBins(count) = nanmean(data);
    MMBinsSEM(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simcorr(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    ChanceMMBins(count) = nanmean(allsimcorrvals(:));
    ChanceMMBinsSEM(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
%     
%     data = AllSeedlingMovCorr(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
%     SeedBins(count) = nanmean(data);
%     SeedBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = AllLeverVelocitySD(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
    LevVelSDBins(count) = nanmean(data);
    LevVelSDBinsSEM(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimvals = simVelSD(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    ChanceVelSDBins(count) = nanmean(allsimvals(:));
    ChanceVelSDBinsSEM(count) = nanstd(allsimvals(:))/sqrt(sum(~isnan(data)));
    
    data = WithinMovCorr(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
    WithinMovBins(count) = nanmean(data);
    WithinMovBinsSEM(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simwithincorr(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    ChanceWithinMovBins(count) = nanmean(allsimcorrvals(:));
    ChanceWithinMovBinsSEM(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
    data = IsRew(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize);
    IsRewBins(count) = nanmean(data);
    IsRewBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimfracvals = simRewFrac(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    IsChanceRewBins(count) = nanmean(allsimfracvals(:));
    IsChanceRewError(count) = nanstd(allsimfracvals(:))/sqrt(sum(~isnan(data)));
    
    data = AllTransCorr(AllTransDistances>=i & AllTransDistances<i+binsize);
    TransBins(count) = nanmean(data);
    TransBinsSEM(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simtranscorr(AllTransDistances>=i & AllTransDistances<i+binsize,:);
    ChanceTransBins(count) = nanmean(allsimcorrvals(:));
    ChanceTransBinsSEM(count) =  nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
    data = AllTransCoA(AllTransDistances>=i & AllTransDistances<i+binsize);
    TransCoABins(count) = nanmean(data);
    TransCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimCoAvals = simtransCoA(AllTransDistances>=i & AllTransDistances<i+binsize,:);
    ChanceTransCoABins(count) = nanmean(allsimCoAvals(:));
    ChanceTransCoABinsError(count) =  nanstd(allsimCoAvals(:))/sqrt(sum(~isnan(data)));

    count = count+1;
end

figure('Name', 'Distance Dependence of Mov. Relatedness'); 
subplot(4,2,1); hold on; 
plot(AllNewSpineDistances, DotProducts, '.k', 'markersize',  14)
plot(AllNewSpineDistances, nanmean(simDP,2), '.', 'markersize', 14, 'color', dred)
xlabel('Distance (\mum)')
ylabel('Normalized Dot Product')

subplot(4,2,2); hold on; 
tempX = xvals(~isnan(DPBins));
DPBinsSEM = DPBinsSEM(~isnan(DPBins));
DPBins = DPBins(~isnan(DPBins));
plot(tempX, DPBins, 'k','linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [DPBins+DPBinsSEM,fliplr(DPBins-DPBinsSEM)], lgreen);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(CDPBins));
CDPBinsSEM = CDPBinsSEM(~isnan(CDPBins));
CDPBins = CDPBins(~isnan(CDPBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [CDPBins+CDPBinsSEM,fliplr(CDPBins-CDPBinsSEM)], dred);
set(patch_chance, 'FaceAlpha', 0.75);
plot(tempX, CDPBins, 'k','linewidth', 2)
xlabel('Distance Bins')
ylabel('Mean Normalized Dot Product')
legend([patch_chance, patch_data], {'Chance', 'Data'})

subplot(4,2,3); hold on; 
plot(AllNewSpineDistances, IsRew, '.k', 'Markersize', 14)
plot(AllNewSpineDistances, IsChanceRew, '.', 'markersize', 14, 'color', purple)
ylabel('Fraction Movements Rewarded')
xlabel('Distance (\mum)')

subplot(4,2,4); hold on; 
tempX = xvals(~isnan(IsRewBins));
IsRewBinsError = IsRewBinsError(~isnan(IsRewBins));
IsRewBins = IsRewBins(~isnan(IsRewBins));
plot(tempX, IsRewBins, 'k','linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [IsRewBins+IsRewBinsError,fliplr(IsRewBins-IsRewBinsError)], purple);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(IsChanceRewBins));
IsChanceRewError = IsChanceRewError(~isnan(IsChanceRewBins));
IsChanceRewBins = IsChanceRewBins(~isnan(IsChanceRewBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [IsChanceRewBins+IsChanceRewError,fliplr(IsChanceRewBins-IsChanceRewError)], purple);
plot(tempX, IsChanceRewBins, 'k','linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75)
xlabel('Distance Bins')
ylabel('Fraction Movements Rewarded')
xlabel('Distance (\mum)')
legend([patch_chance, patch_data], {'Chance', 'Data'})

subplot(4,2,5); hold on; 
plot(AllNewSpineDistances, AllMMCorr, '.k', 'markersize', 14, 'linewidth', 2)
plot(AllNewSpineDistances, nanmean(simcorr,2), '.', 'markersize', 14, 'color', yellow, 'linewidth', 2)
ylabel('Corr. with Model Mvmt')
xlabel('Distance (\mum)')

subplot(4,2,6); hold on; 
tempX = xvals(~isnan(MMBins));
MMBinsSEM = MMBinsSEM(~isnan(MMBins));
MMBins = MMBins(~isnan(MMBins));
plot(tempX, MMBins, 'k','linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [MMBins+MMBinsSEM,fliplr(MMBins-MMBinsSEM)], lgreen);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(ChanceMMBins));
ChanceMMBinsSEM = ChanceMMBinsSEM(~isnan(ChanceMMBins));
ChanceMMBins = ChanceMMBins(~isnan(ChanceMMBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [ChanceMMBins+ChanceMMBinsSEM,fliplr(ChanceMMBins-ChanceMMBinsSEM)], yellow);
plot(tempX, ChanceMMBins, 'k','linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75)
xlabel('Distance Bins')
ylabel('Corr. with Model Mvmt')
xlabel('Distance (\mum)')
legend([patch_data, patch_chance], {'Data', 'Chance'})


subplot(4,2,7); hold on; 
plot(AllNewSpineDistances, WithinMovCorr, '.k', 'markersize', 14)
plot(AllNewSpineDistances, nanmean(simwithincorr,2), '.', 'markersize', 14, 'color', blue)
ylabel('Correlation of Mvmts.')
xlabel('Distance (\mum)')

subplot(4,2,8); hold on; 
tempX = xvals(~isnan(WithinMovBins));
WithinMovBinsSEM = WithinMovBinsSEM(~isnan(WithinMovBins));
WithinMovBins = WithinMovBins(~isnan(WithinMovBins));
plot(tempX, WithinMovBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [WithinMovBins+WithinMovBinsSEM,fliplr(WithinMovBins-WithinMovBinsSEM)], lgreen);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(ChanceWithinMovBins));
ChanceWithinMovBinsSEM = ChanceWithinMovBinsSEM(~isnan(ChanceWithinMovBins));
ChanceWithinMovBins = ChanceWithinMovBins(~isnan(ChanceWithinMovBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [ChanceWithinMovBins+ChanceWithinMovBinsSEM,fliplr(ChanceWithinMovBins-ChanceWithinMovBinsSEM)], blue);
plot(tempX, ChanceWithinMovBins, 'k','linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75)
xlabel('Distance Bins')
ylabel('Correlation of Mvmts.')
xlabel('Distance (\mum)')
legend([patch_data, patch_chance], {'Data', 'Chance'})

%%%
figure; subplot(1,2,1); hold on; 
plot(AllNewSpineDistances, AllLeverVelocitySD, '.k', 'markersize', 14)
plot(AllNewSpineDistances, nanmean(simVelSD,2), '.', 'markersize', 14, 'color', blue)
ylabel('Lever Velocity SD')
xlabel('Distance (\mum)')

subplot(1,2,2); hold on; 
tempX = xvals(~isnan(LevVelSDBins));
LevVelSDBinsSEM = LevVelSDBinsSEM(~isnan(LevVelSDBins));
LevVelSDBins = LevVelSDBins(~isnan(LevVelSDBins));
plot(tempX, LevVelSDBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [LevVelSDBins+LevVelSDBinsSEM,fliplr(LevVelSDBins-LevVelSDBinsSEM)], lgreen);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(ChanceVelSDBins));
ChanceVelSDBinsSEM = ChanceVelSDBinsSEM(~isnan(ChanceVelSDBins));
ChanceVelSDBins = ChanceVelSDBins(~isnan(ChanceVelSDBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [ChanceVelSDBins+ChanceVelSDBinsSEM,fliplr(ChanceVelSDBins-ChanceVelSDBinsSEM)], blue);
plot(tempX, ChanceVelSDBins, 'k','linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75)
xlabel('Distance Bins')
ylabel('Lever Velocity SD')
xlabel('Distance (\mum)')
legend([patch_data, patch_chance], {'Data', 'Chance'})

%=====
allearlyMRSs = []; alllateMRSs = []; 
allspinecorrlist = []; allspinedistlist = []; 
NStoAllSpinesDistances = []; AllEarlyMRSwrtNSs = []; AllPrevSeshMRSwrtNSs = []; AllLateMRSwrtNSs = [];
earlydistlist = []; distlist = []; ClosestLateMRS = []; ClosestPersMRS = []; PrevSeshMRSdistlist = []; 
corrlist = []; rawcorrlist = []; midcorrlist = []; midCoAlist = []; middistlist = []; noisecorrlist = []; nonMRSdistlist = []; nonMRScorrlist = []; nonMRSnoisecorrlist = []; persistentMRSs = []; pers_shuf = []; newspine_toallspines_distlist = []; gainedMRSs = []; noisecorrlist = []; ClosestEnlargedSpineList = []; CorrwithClosestEnlargedSpine = []; FractionEnlargedSpinesThatAreMRSs = [];FractionofSpinesThatAreEnlarged = []; simcount = 1;
distlistbyfield = cell(1,sum(cell2mat(NumFields))); corrlistbyfield = cell(1,sum(cell2mat(NumFields))); nonMRSdistlistbyfield = cell(1,sum(cell2mat(NumFields))); nonMRScorrlistbyfield = cell(1,sum(cell2mat(NumFields)));
middistlistbyfield = cell(1,sum(cell2mat(NumFields))); midcorrlistbyfield = cell(1,sum(cell2mat(NumFields))); midCoAlistbyfield = cell(1,sum(cell2mat(NumFields)));
MRScoAlist = []; nonMRScoAlist = []; 
CorrwithClosestEnlargedSpine = []; CoARatewithClosestEnlargedSpine = [];
AllVolumeChanges = []; AllMRSVolumeChanges = []; AllPlasticityIndices = []; MRSPlasticityIndex = []; NumberofNearbyEnlargedMRSs = [];
SpineDensity = [];

fieldcount = 1;
selectedanimals = 1:length(varargin);
% selectedanimals = [5,18];
for animal = selectedanimals
%     NewSpines{animal} = NewSpines{animal}(~cellfun(@isempty, NewSpines{animal}));
%     ElimSpines{animal} = ElimSpines{animal}(~cellfun(@isempty, ElimSpines{animal}));
    for field = 1:length(NewSpines{animal})
        %%% Define Movement-Related Spines
        earlyMRSs = AllMovementSpines{animal}{field}(:,1);
        if size(AllMovementSpines{animal}{field},2) > 2
            midMRSs = logical(AllMovementSpines{animal}{field}(:,2));
            lateMRSs = logical(AllMovementSpines{animal}{field}(:,end));
            %%% Need to remove eliminated spines to make this the same
            %%% size as variables from "cluster" code
            lateMRSs(ElimSpines{animal}{field}) = 0;
        else
            midMRSs = logical(zeros(size(AllMovementSpines{animal}{field},1),1));
            lateMRSs = logical(AllMovementSpines{animal}{field}(:,end));
            lateMRSs(ElimSpines{animal}{field}) = 0;
        end
        
        allearlyMRSs = [allearlyMRSs; earlyMRSs];
        alllateMRSs = [alllateMRSs; lateMRSs];

        MRSs_to_use = lateMRSs;
        %%% Retrieve all spine-pair correlations, and exclude some
        %%% according to needs
        allspinecorrmat = AllSpineCorrelationsonLateSession{animal}{field};
        allspinecorrmat(NewSpines{animal}{field},:) = nan; allspinecorrmat(:,NewSpines{animal}{field}) = nan;
%         allspinecorrmat(MRSs_to_use,:) = nan; allspinecorrmat(:,MRSs_to_use) = nan;
        allspinecorrlist = [allspinecorrlist; allspinecorrmat(:)];
        allspinedistmat = AllDendriteDistances{animal}{field}; 
        allspinedistmat(NewSpines{animal}{field},:) = nan; allspinedistmat(:,NewSpines{animal}{field}) = nan;
%         allspinedistmat(MRSs_to_use,:) = nan; allspinedistmat(:,MRSs_to_use) = nan;
        allspinedistlist = [allspinedistlist; allspinedistmat(:)];  
        %%%
        for newspine = 1:size(NewSpineAllSpinesDistance{animal}{field},1)
            NStoAllSpinesDistances = [NStoAllSpinesDistances; NewSpineAllSpinesDistance{animal}{field}(newspine,:)'];
            AllEarlyMRSwrtNSs = [AllEarlyMRSwrtNSs; earlyMRSs];
            AllLateMRSwrtNSs = [AllLateMRSwrtNSs; lateMRSs];
            if ismember(NewSpines{animal}{field}(newspine), MiddleSessionNewSpines{animal}{field})
                isNSMidorLate = 'Mid';
            else
                isNSMidorLate = 'Late';
            end
            switch isNSMidorLate
                case 'Mid'
                    midcorrlist = [midcorrlist; NewSpineAllSpinesMidCorr{animal}{field}(newspine, :)'];
                    midCoAlist = [midCoAlist; NewSpineMidCoActiveRateGeoNormalized{animal}{field}{newspine}'];
                    middistlist = [middistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,:)'];
                    
                    midcorrlistbyfield{fieldcount} = [midcorrlistbyfield{fieldcount}; NewSpineAllSpinesMidCorr{animal}{field}(newspine, :)'];
                    midCoAlistbyfield{fieldcount} = [midCoAlistbyfield{fieldcount}; NewSpineMidCoActiveRateNormalized{animal}{field}{newspine}'];
                    middistlistbyfield{fieldcount} = [middistlistbyfield{fieldcount}; NewSpineAllSpinesDistance{animal}{field}(newspine,:)'];
            end
            earlydistlist = [earlydistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs)'];
            distlist = [distlist; NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use)'];
            ClosestLateMRS = [ClosestLateMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use))];
            ClosestPersMRS = [ClosestPersMRS; nanmin(NewSpineAllSpinesDistance{animal}{field}(newspine,earlyMRSs & lateMRSs))];
            
            corrlist = [corrlist; NewSpineAllSpinesLateCorr{animal}{field}(newspine,MRSs_to_use)'];
                distlistbyfield{fieldcount} = [distlistbyfield{fieldcount}; NewSpineAllSpinesDistance{animal}{field}(newspine,MRSs_to_use)'];
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
            
            persistentMRSs = [persistentMRSs; earlyMRSs & lateMRSs];
            gainedMRSs = [gainedMRSs; diff([earlyMRSs, lateMRSs],[],2)];

            newspinelabel = NewSpines{animal}{field}(newspine);
            parentdendrite = find(cellfun(@(x) ismember(newspinelabel, x), SpineDendriteGrouping{animal}{field}));
            spinesfromparentdend = SpineDendriteGrouping{animal}{field}{parentdendrite};
            DendDistances = AllDendriteDistances{animal}{field}(spinesfromparentdend(1):spinesfromparentdend(end),spinesfromparentdend(1):spinesfromparentdend(end));
            MRSonthisDend = MRSs_to_use(spinesfromparentdend);
            [dendlength, longeststretch] = nanmax(nanmax(DendDistances,[],2));
            SpineDensity = [SpineDensity, dendlength/size(DendDistances,1)];
            if ~isempty(AllSpineVolumeData{animal}{field})
                switch isNSMidorLate
                    case 'Mid'
                        SpineVol = AllSpineVolumeData{animal}{field}(:,2)./AllSpineVolumeData{animal}{field}(:,1);
                        SpineVol(NewSpines{animal}{field},:) = nan;
                        prev_sesh_MRSs = earlyMRSs;
                    case 'Late'
                        SpineVol = AllSpineVolumeData{animal}{field}(:,end)./AllSpineVolumeData{animal}{field}(:,end-1);
                        SpineVol(NewSpines{animal}{field},:) = nan;
                        prev_sesh_MRSs = midMRSs;
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
%                 PlasticityContingency = VolIncreaseIndex;
%                 PlasticityContingency = prev_sesh_MRSs(spinesfromparentdend);
                PlasticityContingency = VolIncreaseIndex & prev_sesh_MRSs(spinesfromparentdend) & lateMRSs(spinesfromparentdend);
%                 PlasticityContingency = VolIncreaseIndex & (earlyMRSs(spinesfromparentdend)); 
%                 PlasticityContingency = VolIncreaseIndex & (earlyMRSs(spinesfromparentdend) | midMRSs(spinesfromparentdend));
                %%%
                %==========================================================
                FractionEnlargedSpinesThatAreMRSs = [FractionEnlargedSpinesThatAreMRSs; PlasticityContingency];
                RelativeDistances = DendDistances(NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1,:);
                %%% Remove new spine from the lists
%                 RelativeDistances = RelativeDistances(setdiff(1:length(RelativeDistances), NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1)); %%% Need to remove the new spine itself from the distance measurements!
%                 PlasticityContingency = PlasticityContingency(setdiff(1:length(PlasticityContingency), NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1));
%                 spinesfromparentdend = spinesfromparentdend(setdiff(1:length(spinesfromparentdend), NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1));
%                 SpineVol = SpineVol(setdiff(1:length(spinesfromparentdend), NewSpines{animal}{field}(newspine)-spinesfromparentdend(1)+1));
                %%%
                [CESval,CESind] = nanmin(RelativeDistances(PlasticityContingency));
                NumberofNearbyEnlargedMRSs = [NumberofNearbyEnlargedMRSs, sum(RelativeDistances(PlasticityContingency)<=10)];
                ClosestEnlargedSpineList = [ClosestEnlargedSpineList, CESval];
                corr_struct_on_this_dend = NewSpineAllSpinesLateCorr{animal}{field}(newspine, spinesfromparentdend);
                corrwithbigbois = corr_struct_on_this_dend(PlasticityContingency);
                CorrwithClosestEnlargedSpine = [CorrwithClosestEnlargedSpine, corrwithbigbois(CESind)];
                if ~isempty(CESval)
                    CoAstructonthisdend = NewSpineAllCoActiveRatesGeoNormalized{animal}{field}{newspine}(spinesfromparentdend);
                    coAwithbigbois = CoAstructonthisdend(PlasticityContingency);
                    CoARatewithClosestEnlargedSpine = [CoARatewithClosestEnlargedSpine, coAwithbigbois(CESind)];
                end
                
%                 AllSpineVolumeChanges = [AllSpineVolumeChanges; SpineVol(logical(prev_sesh_MRSs(spinesfromparentdend)))];
                MRSPlasticityIndex = [MRSPlasticityIndex; FullSpineVolList(logical(MRSs_to_use))>= spine_enlargement_cutoff];
                AllPlasticityIndices = [AllPlasticityIndices; FullSpineVolList > spine_enlargement_cutoff];
                AllVolumeChanges = [AllVolumeChanges; FullSpineVolList];
                AllMRSVolumeChanges = [AllMRSVolumeChanges; FullSpineVolList(logical(MRSs_to_use))];
                PrevSeshMRSdistlist = [PrevSeshMRSdistlist; NewSpineAllSpinesDistance{animal}{field}(newspine,prev_sesh_MRSs)'];
            else
            end
%             for shuff = 1:100
%                 simNewSpine = randi([1,4*round(dendlength)])/4;
%                 DistancesReltoSimNewSpine = DendDistances(longeststretch,:)-simNewSpine;
%                 DistancesReltoSimNewSpine(~AllMovementSpines{animal}{field}(:,1)) = NaN;
%                 corr_struct_on_this_dend = NewSpineAllSpinesLateNoiseCorr{animal}{field}(newspine, spinesfromparentdend);
%                 if sum(~isnan(DistancesReltoSimNewSpine)) == 1 && DistancesReltoSimNewSpine(~isnan(DistancesReltoSimNewSpine)) == 0
%                     closesthighcorrsim(simcount) = nan;
%                 else
%                     closesthighcorrsim(simcount) = nanmean(abs(DistancesReltoSimNewSpine));
%                 end
% %                 DistancesReltoSimNewSpine = abs(DendDistances(longeststretch,:)-simNewSpine);
% %                 DistancesReltoSimNewSpine(~AllMovementSpines{animal}{field}(:,1)) = NaN;
% %                 DistancesReltoSimNewSpine(~VolIncreaseIndex) = NaN;
% %                 SimClosestEnlargedSpine = find(DistancesReltoSimNewSpine == min(DistancesReltoSimNewSpine))
% %                 
%                 simcount = simcount+1;
%             end
        end
        fieldcount = fieldcount+1;
    end
end

AllEarlyMRSwrtNSs = AllEarlyMRSwrtNSs(~isnan(NStoAllSpinesDistances));
AllPrevSeshMRSwrtNSs = AllPrevSeshMRSwrtNSs(~isnan(NStoAllSpinesDistances));
AllLateMRSwrtNSs = AllLateMRSwrtNSs(~isnan(NStoAllSpinesDistances));
persistentMRSs = persistentMRSs(~isnan(NStoAllSpinesDistances));
gainedMRSs = gainedMRSs(~isnan(NStoAllSpinesDistances));
AllPlasticityIndices = AllPlasticityIndices(~isnan(NStoAllSpinesDistances));
NStoAllSpinesDistances = NStoAllSpinesDistances(~isnan(NStoAllSpinesDistances));


%========================

%%% Determine if NS correlation with MRS is distance-dependent
allspinecorrlist = allspinecorrlist(~isnan(allspinedistlist)); allspinedistlist = allspinedistlist(~isnan(allspinedistlist));
corrlist = corrlist(~isnan(distlist)); rawcorrlist = rawcorrlist(~isnan(distlist)); noisecorrlist = noisecorrlist(~isnan(distlist)); MRScoAlist = MRScoAlist(~isnan(distlist)); nonMRScoAlist = nonMRScoAlist(~isnan(distlist));
AllMRSVolumeChanges = AllMRSVolumeChanges(~isnan(distlist));
distlist = distlist(~isnan(distlist));
midcorrlist = midcorrlist(~isnan(middistlist)); midCoAlist = midCoAlist(~isnan(middistlist)); middistlist = middistlist(~isnan(middistlist));
nonMRScorrlist = nonMRScorrlist(~isnan(nonMRSdistlist)); nonMRSnoisecorrlist = nonMRSnoisecorrlist(~isnan(nonMRSdistlist)); nonMRSdistlist = nonMRSdistlist(~isnan(nonMRSdistlist));

tempNCdist = AllNewSpineDistances; 
tempNCdist = tempNCdist(~isnan(AllNoiseCorr));
AllNoiseCorr = AllNoiseCorr(~isnan(AllNoiseCorr));

enlargedCompDistList = distlist(~ismember(corrlist, CorrwithClosestEnlargedSpine));
enlargedCompCorrList = corrlist(~ismember(corrlist, CorrwithClosestEnlargedSpine));
enlargedCompCoAList = MRScoAlist(~ismember(corrlist, CorrwithClosestEnlargedSpine));

% figure; hold on; 
% binedges = [0:1:100];
% histogram(HighCorrDistances, 'normalization', 'probability', 'binedges', binedges)
% hold on; histogram(closesthighcorrsim, 'normalization', 'probability', 'binedges', binedges)

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
AllMixedCoAList = allspinecoAlist(mixedLate);

allinterspinedistlist = cell2mat(horzcat(AllInterSpineDistancesList{:}));
BothEarlyMRSDistList = allinterspinedistlist(bothEarlyMRS);
BothLateMRSDistList = allinterspinedistlist(bothLateMRS);
NeitherEarlyMRSDistList = allinterspinedistlist(neitherEarlyMRS);
NeitherLateMRSDistList = allinterspinedistlist(neitherLateMRS);
MixedEarlyDistList = allinterspinedistlist(mixedEarly);
MixedLateDistList = allinterspinedistlist(mixedLate);

%==========================================================================

simcorr = []; simrawcorr = []; simnoisecorr = []; simmidcorr = []; simmidCoA = [];  simnonMRScorr = []; simnonMRSnoisecorr = []; simpersist = []; simgained = []; simfrac = []; simrate = [];
for shuff = 1:1000
    [~,ind] = sort(shake(distlist));
    simcorr(:,shuff) = corrlist(ind);
    simrawcorr(:,shuff) = rawcorrlist(ind);
    simnoisecorr(:,shuff) = noisecorrlist(ind);
    [~,ind] = sort(shake(middistlist));
    simmidcorr(:,shuff) = midcorrlist(ind); 
    simmidCoA(:,shuff) = midCoAlist(ind);
    [~,nMRSind] = sort(shake(nonMRSdistlist));
    simnonMRScorr(:,shuff) = nonMRScorrlist(nMRSind);
    simnonMRSnoisecorr(:,shuff) = nonMRSnoisecorrlist(nMRSind);
    [~,persind] = sort(shake(NStoAllSpinesDistances));
    simpersist(:,shuff) = persistentMRSs(persind);
    [~,gainedind] = sort(shake(NStoAllSpinesDistances));
    simgained(:,shuff) = gainedMRSs(gainedind);
    [~,fracind] = sort(shake(AllNewSpineDistances));    
    simfrac(:,shuff) = AllFractions(fracind);
    [~,rateind] = sort(shake(AllNewSpineDistances));
    simrate(:,shuff) = AllCoARates(rateind);
end


count = 1;
AllSpineCorrBins = []; AllSpineCorrBinsError = []; AllSpineEarlyCoABins = []; AllSpineEarlyCoABinsError = []; AllSpineCoABins = []; AllSpineCoABinsError = []; 
CorrBins = []; CorrBinsError = []; SimCorrBins = []; SimCorrBinsError = [];
EnlargedPartnerBins = []; EnlargedPartnerBinsError = []; EnlargedPartnerComp = []; EnlargedPartnerCompError = [];
RawCorrBins = []; RawCorrBinsError = []; SimRawCorrBins = []; SimRawCorrBinsError = []; 
MidCorrBins = []; MidCorrBinsError = []; SimMidCorrBins = []; SimMidCorrBinsError = []; 
NoiseCorrBins = []; NoiseCorrBinsError = []; SimNoiseCorrBins = []; SimNoiseCorrBinsError = [];
nonMRSCorrBins = []; nonMRSCorrBinsError = []; nonMRSSimCorrBins = []; nonMRSSimCorrBinsError = []; 
nonMRSNoiseCorrBins = []; nonMRSNoiseCorrBinsError = []; nonMRSSimNoiseCorrBins = []; nonMRSSimNoiseCorrBinsError = []; 
for i = xvals
    data = allspinecorrlist(allspinedistlist>=i & allspinedistlist<i+binsize);
    AllSpineCorrBins(count) = nanmean(data);
    AllSpineCorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = allspineEarlycoAlist(allinterspinedistlist>=i & allinterspinedistlist<i+binsize);
    AllSpineEarlyCoABins(count) = nanmean(data);
    AllSpineEarlyCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = allspinecoAlist(allinterspinedistlist>=i & allinterspinedistlist<i+binsize);
    AllSpineCoABins(count) = nanmean(data);
    AllSpineCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = corrlist(distlist>=i & distlist<i+binsize);
    CorrBins(count) = nanmean(data);
    CorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
%     CorrBinsError(count,:) = bootci(bootstrpnum, {@median, corrlist(tempdist>=i & tempdist<i+binsize)}, 'alpha', alphaforbootstrap);
    allsimcorrvals = simcorr(distlist>=i & distlist<i+binsize,:);
    SimCorrBins(count) = nanmean(allsimcorrvals(:));
    SimCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
%     SimCorrBinsError(count,:) = bootci(bootstrpnum, {@median, nanmean(allsimcorrvals,2)}, 'alpha', alphaforbootstrap);

    data = CorrwithClosestEnlargedSpine(ClosestEnlargedSpineList>=i & ClosestEnlargedSpineList<i+binsize);
    EnlargedPartnerBins(count) = nanmean(data);
    EnlargedPartnerBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    data = enlargedCompCorrList(enlargedCompDistList>=i & enlargedCompDistList<i+binsize);
    EnlargedPartnerComp(count) = nanmean(data);
    EnlargedPartnerCompError(count) = nanstd(data)/sqrt(sum(~isnan(data)));

    data = rawcorrlist(distlist>=i & distlist<i+binsize);
    RawCorrBins(count) = nanmean(data);
    RawCorrBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simrawcorr(distlist>=i & distlist<i+binsize,:);
    SimRawCorrBins(count) = nanmean(allsimcorrvals(:));
    SimRawCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(sum(~isnan(data)));
    
    data = MRScoAlist(distlist>=i & distlist<i+binsize);
    MRSCoABins(count) = nanmean(data);
    MRSCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = CoARatewithClosestEnlargedSpine(ClosestEnlargedSpineList>=i & ClosestEnlargedSpineList<i+binsize);
    EnlargedPartnerCoABins(count) = nanmean(data);
    EnlargedPartnerCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    
    data = nonMRScoAlist(distlist>=i & distlist<i+binsize);
    nonMRSCoABins(count) = nanmean(data);
    nonMRSCoABinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));

    MidCorrBins(count) = nanmean(midcorrlist(middistlist>=i & middistlist<i+binsize));
    MidCorrBinsError(count) = nanstd(midcorrlist(middistlist>=i & middistlist<i+binsize))/sqrt(length(midcorrlist(middistlist>=i & middistlist<i+binsize)));
%     CorrBinsError(count,:) = bootci(bootstrpnum, {@median, corrlist(tempdist>=i & tempdist<i+binsize)}, 'alpha', alphaforbootstrap);
    allsimcorrvals = simmidcorr(middistlist>=i & middistlist<i+binsize,:);
    SimMidCorrBins(count) = nanmean(allsimcorrvals(:));
    SimMidCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(midcorrlist(middistlist>=i & middistlist<i+binsize)));
    
    MidCoABins(count) = nanmean(midCoAlist(middistlist>=i & middistlist<i+binsize));
    MidCoABinsError(count) = nanstd(midCoAlist(middistlist>=i & middistlist<i+binsize))/sqrt(length(midCoAlist(middistlist>=i & middistlist<i+binsize)));
%     CorrBinsError(count,:) = bootci(bootstrpnum, {@median, corrlist(tempdist>=i & tempdist<i+binsize)}, 'alpha', alphaforbootstrap);
    allsimCoAvals = simmidCoA(middistlist>=i & middistlist<i+binsize,:);
    SimMidCoABins(count) = nanmean(allsimCoAvals(:));
    SimMidCoABinsError(count) = nanstd(allsimCoAvals(:))/sqrt(length(midCoAlist(middistlist>=i & middistlist<i+binsize)));

    NoiseCorrBins(count) = nanmean(noisecorrlist(distlist>=i & distlist<i+binsize));
    NoiseCorrBinsError(count) = nanstd(noisecorrlist(distlist>=i & distlist<i+binsize))/sqrt(length(noisecorrlist(distlist>=i & distlist<i+binsize)));
    allsimcorrvals = simnoisecorr(distlist>=i & distlist<i+binsize,:);
    SimNoiseCorrBins(count) = nanmean(allsimcorrvals(:));
    SimNoiseCorrBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(AllNoiseCorr(tempNCdist>=i & tempNCdist<i+binsize)));
    
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

    data = persistentMRSs(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize);
    PersMRSBins(count) = nanmean(data);
    PersMRSBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simpersist(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize);
    SimPersMRSBins(count) = nanmean(allsimcorrvals(:));
    SimPersMRSBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(persistentMRSs(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize)));
    
    data = gainedMRSs(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize);
    GainedMRSBins(count) = nanmean(data);
    GainedMRSBinsError(count) = nanstd(data)/sqrt(sum(~isnan(data)));
    allsimcorrvals = simgained(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize);
    SimGainedMRSBins(count) = nanmean(allsimcorrvals(:));
    SimGainedMRSBinsError(count) = nanstd(allsimcorrvals(:))/sqrt(length(gainedMRSs(NStoAllSpinesDistances>=i & NStoAllSpinesDistances<i+binsize)));
    
    FracBin(count) = nanmean(AllFractions(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize));
    FracBinError(count) = nanstd(AllFractions(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize))/sqrt(length(AllFractions(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize)));
    allsimfractions = simfrac(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    SimFracBin(count) = nanmean(allsimfractions(:));
    SimFracBinError(count) = nanstd(allsimfractions(:))/sqrt(length(AllFractions(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize)));
    
    RateBin(count) = nanmean(AllCoARates(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize));
    RateBinError(count) = nanstd(AllCoARates(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize))/sqrt(length(AllCoARates(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize)));
    allsimrates = simrate(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize,:);
    SimRateBin(count) = nanmean(allsimrates(:));
    SimRateBinError(count) = nanstd(allsimrates(:))/sqrt(length(AllCoARates(AllNewSpineDistances>=i & AllNewSpineDistances<i+binsize)));
    
    data = AllMRSVolumeChanges(distlist>=i & distlist<i+binsize);
    AllSpineVolumeBins(count) = nanmean(data);
    AllSpineVolumeBinsError(count) = nanstd(data)./sqrt(sum(~isnan(data)));
    count = count+1;
end

%%%
figure('Name', 'Distance Dependence of All Spine Correlations')
subplot(1,2,1)
plot(allspinedistlist, allspinecorrlist, '.k', 'markersize', 14)

subplot(1,2,2); hold on; 
tempX = xvals(~isnan(AllSpineCorrBins));
AllSpineCorrBinsError = AllSpineCorrBinsError(~isnan(AllSpineCorrBins));
AllSpineCorrBins = AllSpineCorrBins(~isnan(AllSpineCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [AllSpineCorrBins+AllSpineCorrBinsError,fliplr(AllSpineCorrBins-AllSpineCorrBinsError)], red);
plot(tempX, AllSpineCorrBins, 'k', 'linewidth', 2)
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')
title('Overall Correlation')

%%%

figure('Name', 'Distance Dependence of NS Correlation with MRSs'); 
subplot(4,2,1); 
plot(distlist, corrlist, '.k', 'markersize', 14)
hold on; plot(distlist, nanmean(simcorr,2), '.k', 'markersize', 14, 'color', lblue)
xlabel('Distance (\mum)')
ylabel('Correlation')
title('Overall Corr. with Mvmt Spines')


mrs_corr_plot = subplot(4,2,2); hold on; 
tempX = xvals(~isnan(CorrBins));
CorrBinsError = CorrBinsError(~isnan(CorrBins));
CorrBins = CorrBins(~isnan(CorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [CorrBins+CorrBinsError,fliplr(CorrBins-CorrBinsError)], lgreen);
plot(tempX, CorrBins, 'k', 'linewidth', 2)
set(patch_data, 'FaceAlpha', 1);
title('Overall Correlation')

tempX = xvals(~isnan(SimCorrBins));
SimCorrBinsError = SimCorrBinsError(~isnan(SimCorrBins));
SimCorrBins = SimCorrBins(~isnan(SimCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimCorrBins+SimCorrBinsError,fliplr(SimCorrBins-SimCorrBinsError)], lblue);
plot(tempX, SimCorrBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Correlation')

subplot(4,2,3); plot(distlist, noisecorrlist, '.k', 'markersize', 14)
hold on; plot(distlist, nanmean(simnoisecorr,2), '.k', 'markersize', 14, 'color', lblue)
xlabel('Distance (\mum)')
ylabel('Noise Correlation')
title('Noise Correlation')

subplot(4,2,4); hold on; 
tempX = xvals(~isnan(NoiseCorrBins));
NoiseCorrBinsError = NoiseCorrBinsError(~isnan(NoiseCorrBins));
NoiseCorrBins = NoiseCorrBins(~isnan(NoiseCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [NoiseCorrBins+NoiseCorrBinsError,fliplr(NoiseCorrBins-NoiseCorrBinsError)], green);
plot(tempX, NoiseCorrBins, 'k', 'linewidth', 2)
set(patch_data, 'FaceAlpha', 1);


tempX = xvals(~isnan(SimNoiseCorrBins));
SimNoiseCorrBinsError = SimNoiseCorrBinsError(~isnan(SimNoiseCorrBins));
SimNoiseCorrBins = SimNoiseCorrBins(~isnan(SimNoiseCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimNoiseCorrBins+SimNoiseCorrBinsError,fliplr(SimNoiseCorrBins-SimNoiseCorrBinsError)], lblue);
plot(tempX, SimNoiseCorrBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Noise Correlation')
title('Noise Correlation')

subplot(4,2,5); hold on; 
plot(nonMRSdistlist, nonMRScorrlist, '.', 'markersize', 14, 'color', dred)
hold on; plot(nonMRSdistlist, nanmean(simnonMRScorr,2), '.k', 'markersize', 14, 'color', lblue)
title('nonMRS Correlation')
xlabel('Distance (\mum)')
ylabel('Correlation')

nmrs_corr_plot = subplot(4,2,6); hold on; 
tempX = xvals(~isnan(nonMRSCorrBins));
nonMRSCorrBinsError = nonMRSCorrBinsError(~isnan(nonMRSCorrBins));
nonMRSCorrBins = nonMRSCorrBins(~isnan(nonMRSCorrBins));
plot(tempX, nonMRSCorrBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [nonMRSCorrBins+nonMRSCorrBinsError,fliplr(nonMRSCorrBins-nonMRSCorrBinsError)], dred);
plot(tempX, nonMRSCorrBins, 'k', 'linewidth', 2)
set(patch_data, 'FaceAlpha', 1);

tempX = xvals(~isnan(nonMRSSimCorrBins));
nonMRSSimCorrBinsError = nonMRSSimCorrBinsError(~isnan(nonMRSSimCorrBins));
nonMRSSimCorrBins = nonMRSSimCorrBins(~isnan(nonMRSSimCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [nonMRSSimCorrBins+nonMRSSimCorrBinsError,fliplr(nonMRSSimCorrBins-nonMRSSimCorrBinsError)], lblue);
plot(tempX, nonMRSSimCorrBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Correlation')
title('nonMRS Correlation')
linkaxes([mrs_corr_plot, nmrs_corr_plot], 'y');

subplot(4,2,7); hold on; 
plot(nonMRSdistlist, nonMRSnoisecorrlist, '.', 'markersize', 14, 'color', dred)
hold on; plot(nonMRSdistlist, nanmean(simnonMRSnoisecorr,2), '.k', 'markersize', 14, 'color', lblue)
title('nonMRS Correlation')
xlabel('Distance (\mum)')
ylabel('Correlation')

subplot(4,2,8); hold on; 
tempX = xvals(~isnan(nonMRSNoiseCorrBins));
nonMRSNoiseCorrBinsError = nonMRSNoiseCorrBinsError(~isnan(nonMRSNoiseCorrBins));
nonMRSNoiseCorrBins = nonMRSNoiseCorrBins(~isnan(nonMRSNoiseCorrBins));
plot(tempX, nonMRSNoiseCorrBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [nonMRSNoiseCorrBins+nonMRSNoiseCorrBinsError,fliplr(nonMRSNoiseCorrBins-nonMRSNoiseCorrBinsError)], dred);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(nonMRSSimNoiseCorrBins));
nonMRSSimNoiseCorrBinsError = nonMRSSimNoiseCorrBinsError(~isnan(nonMRSSimNoiseCorrBins));
nonMRSSimNoiseCorrBins = nonMRSSimNoiseCorrBins(~isnan(nonMRSSimNoiseCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [nonMRSSimNoiseCorrBins+nonMRSSimNoiseCorrBinsError,fliplr(nonMRSSimNoiseCorrBins-nonMRSSimNoiseCorrBinsError)], lblue);
plot(tempX, nonMRSSimNoiseCorrBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Correlation')
title('nonMRS Correlation')
%%%

figure; hold on; 

tempX = xvals(~isnan(EnlargedPartnerComp));
EnlargedPartnerCompError = EnlargedPartnerCompError(~isnan(EnlargedPartnerComp));
EnlargedPartnerComp = EnlargedPartnerComp(~isnan(EnlargedPartnerComp));
plot(tempX, EnlargedPartnerComp, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [EnlargedPartnerComp+EnlargedPartnerCompError,fliplr(EnlargedPartnerComp-EnlargedPartnerCompError)], lgreen);
set(patch_data, 'FaceAlpha', 1);
uistack(patch_data, 'bottom')
title('Overall Correlation')

tempX = xvals(~isnan(EnlargedPartnerBins));
EnlargedPartnerBinsError = EnlargedPartnerBinsError(~isnan(EnlargedPartnerBins));
EnlargedPartnerBins = EnlargedPartnerBins(~isnan(EnlargedPartnerBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [EnlargedPartnerBins+EnlargedPartnerBinsError,fliplr(EnlargedPartnerBins-EnlargedPartnerBinsError)], lpurple);
plot(tempX, EnlargedPartnerBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Correlation')

%%%
figure('Name', 'Correlation vs. Distance of Transient NSs'); 
subplot(4,2,1); hold on; 
plot(AllTransDistances, AllTransCorr, '.', 'markersize', 14, 'color', lpurple)
plot(AllTransDistances, nanmean(simtranscorr,2), '.', 'markersize', 14, 'color', black)
xlabel('Distance (\mum)')
ylabel('Correlation')

trans_ax = subplot(4,2,2); hold on; 
tempX = xvals(~isnan(TransBins));
TransBinsSEM = TransBinsSEM(~isnan(TransBins));
TransBins = TransBins(~isnan(TransBins));
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [TransBins+TransBinsSEM,fliplr(TransBins-TransBinsSEM)], lpurple);
plot(tempX, TransBins, 'k', 'linewidth', 2)
xlabel('Distance (\mum)')
ylabel('Correlation')
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(ChanceTransBins));
ChanceTransBinsSEM = ChanceTransBinsSEM(~isnan(ChanceTransBins));
ChanceTransBins = ChanceTransBins(~isnan(ChanceTransBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [ChanceTransBins+ChanceTransBinsSEM,fliplr(ChanceTransBins-ChanceTransBinsSEM)], gray);
set(patch_chance, 'FaceAlpha', 0.75)
plot(tempX, ChanceTransBins, 'k','linewidth', 2)
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})

subplot(4,2,3); hold on; 
plot(middistlist, midcorrlist, '.', 'markersize', 14, 'color', lgreen)
plot(middistlist, nanmean(simmidcorr,2), '.', 'markersize', 14, 'color', gray)
xlabel('Distance (\mum)')
ylabel('Correlation')

mid_ax = subplot(4,2,4); hold on; 
tempX = xvals(~isnan(MidCorrBins));
MidCorrBinsError = MidCorrBinsError(~isnan(MidCorrBins));
MidCorrBins = MidCorrBins(~isnan(MidCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [MidCorrBins+MidCorrBinsError,fliplr(MidCorrBins-MidCorrBinsError)], lgreen);
plot(tempX, MidCorrBins, 'k', 'linewidth', 2)
xlabel('Distance (\mum)')
ylabel('Correlation')
set(patch_data, 'FaceAlpha', 0.75);

tempX = xvals(~isnan(SimMidCorrBins));
SimMidCorrBinsError = SimMidCorrBinsError(~isnan(SimMidCorrBins));
SimMidCorrBins = SimMidCorrBins(~isnan(SimMidCorrBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimMidCorrBins+SimMidCorrBinsError,fliplr(SimMidCorrBins-SimMidCorrBinsError)], gray);
set(patch_chance, 'FaceAlpha', 0.75)
plot(tempX, SimMidCorrBins, 'k','linewidth', 2)
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
linkaxes([trans_ax, mid_ax], 'y')

subplot(4,2,5); hold on; 
plot(AllTransDistances, AllTransCoA, '.', 'markersize', 14, 'color', lpurple)
plot(AllTransDistances, nanmean(simtransCoA,2), '.', 'markersize', 14, 'color', black)
xlabel('Distance (\mum)')
ylabel('Co-Activity Rate')

transCoA_ax = subplot(4,2,6); hold on; 
tempX = xvals(~isnan(TransCoABins));
TransCoABinsError = TransCoABinsError(~isnan(TransCoABins));
TransCoABins = TransCoABins(~isnan(TransCoABins));
plot(tempX, TransCoABins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [TransCoABins+TransCoABinsError,fliplr(TransCoABins-TransCoABinsError)], lpurple);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(ChanceTransCoABins));
ChanceTransCoABinsError = ChanceTransCoABinsError(~isnan(ChanceTransCoABins));
ChanceTransCoABins = ChanceTransCoABins(~isnan(ChanceTransCoABins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [ChanceTransCoABins+ChanceTransCoABinsError,fliplr(ChanceTransCoABins-ChanceTransCoABinsError)], gray);
set(patch_chance, 'FaceAlpha', 0.75)
plot(tempX, ChanceTransCoABins, 'k','linewidth', 2)
xlabel('Distance Bins')
ylabel('Co-Activity Rate')
legend([patch_data, patch_chance], {'Data', 'Chance'})

subplot(4,2,7); hold on; 
plot(middistlist, midCoAlist, '.', 'markersize', 14, 'color', lgreen)
plot(middistlist, nanmean(simmidCoA,2), '.', 'markersize', 14, 'color', black)
xlabel('Distance (\mum)')
ylabel('Co-Activity Rate')

midCoA_ax = subplot(4,2,8); hold on; 
tempX = xvals(~isnan(MidCoABins));
MidCoABinsError = MidCoABinsError(~isnan(MidCoABins));
MidCoABins = MidCoABins(~isnan(MidCoABins));
plot(tempX, MidCoABins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [MidCoABins+MidCoABinsError,fliplr(MidCoABins-MidCoABinsError)], lgreen);
xlabel('Distance (\mum)')
ylabel('Correlation')
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(SimMidCoABins));
SimMidCoABinsError = SimMidCoABinsError(~isnan(SimMidCoABins));
SimMidCoABins = SimMidCoABins(~isnan(SimMidCoABins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimMidCoABins+SimMidCoABinsError,fliplr(SimMidCoABins-SimMidCoABinsError)], gray);
set(patch_chance, 'FaceAlpha', 0.75)
plot(tempX, SimMidCoABins, 'k','linewidth', 2)
xlabel('Distance Bins')
ylabel('Co-Activity Rate')
legend([patch_data, patch_chance], {'Data', 'Chance'})



%%%


figure('Name', 'Distance Dependence of Encoding More Movements'); 
subplot(2,2,1); plot(AllNewSpineDistances, AllFractions, '.k', 'markersize', 14)
avesimfrac = nanmean(simfrac,2);
hold on; plot(AllNewSpineDistances, avesimfrac, '.k', 'markersize', 14, 'color', blue)
xlabel('Distance (\mum)')
ylabel('Fraction of Movements with Co-activity')
title('Fraction of All Movements')

subplot(2,2,2); hold on; 
tempX = xvals(~isnan(FracBin));
FracBinError = FracBinError(~isnan(FracBin));
FracBin = FracBin(~isnan(FracBin));
plot(tempX, FracBin, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [FracBin+FracBinError,fliplr(FracBin-FracBinError)], orange);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(SimFracBin));
SimFracBinError = SimFracBinError(~isnan(SimFracBin));
SimFracBin = SimFracBin(~isnan(SimFracBin));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimFracBin+SimFracBinError,fliplr(SimFracBin-SimFracBinError)], blue);
plot(tempX, SimFracBin, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Correlation')
legend([patch_data, patch_chance], {'Data', 'Chance'})
xlabel('Distance Bins (\mum)')
ylabel('Fraction of Movements with Co-activity')
title('Fraction of Movements')

subplot(2,2,3); plot(AllNewSpineDistances, AllCoARates, '.k', 'markersize', 14)
avesimrate = nanmean(simrate,2);
hold on; plot(AllNewSpineDistances, avesimrate, '.k', 'markersize', 14, 'color', gray)
xlabel('Distance (\mum)')
ylabel('CoActive Rate')
title('CoActive Rate')

subplot(2,2,4); hold on; 
tempX = xvals(~isnan(RateBin));
RateBinError = RateBinError(~isnan(RateBin));
RateBin = RateBin(~isnan(RateBin));
plot(tempX, RateBin, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [RateBin+RateBinError,fliplr(RateBin-RateBinError)], red);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(SimRateBin));
SimRateBinError = SimRateBinError(~isnan(SimRateBin));
SimRateBin = SimRateBin(~isnan(SimRateBin));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimRateBin+SimRateBinError,fliplr(SimRateBin-SimRateBinError)], gray);
plot(tempX, SimRateBin, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('CoActive Rate')
legend([patch_data, patch_chance], {'Data', 'Chance'})
title('CoActive Rate')

figure; subplot(2,2,1); hold on;
plot(NStoAllSpinesDistances, persistentMRSs, '.k', 'Markersize', 14)
plot(NStoAllSpinesDistances, nanmean(simpersist,2), '.', 'markersize', 14, 'color', purple)
xlabel('Distance (\mum)')
ylabel('Is MRS Persistent')

subplot(2,2,2); hold on; 
tempX = xvals(~isnan(PersMRSBins));
PersMRSBinsError = PersMRSBinsError(~isnan(PersMRSBins));
PersMRSBins = PersMRSBins(~isnan(PersMRSBins));
plot(tempX, PersMRSBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [PersMRSBins+PersMRSBinsError,fliplr(PersMRSBins-PersMRSBinsError)], gray);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(SimPersMRSBins));
SimPersMRSBinsError = SimPersMRSBinsError(~isnan(SimPersMRSBins));
SimPersMRSBins = SimPersMRSBins(~isnan(SimPersMRSBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimPersMRSBins+SimPersMRSBinsError,fliplr(SimPersMRSBins-SimPersMRSBinsError)], purple);
plot(tempX, SimPersMRSBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Probabiliy of Staying MR')
legend([patch_data, patch_chance], {'Data', 'Chance'})
title('Probability of MRS Persisting')

subplot(2,2,3); hold on;
plot(NStoAllSpinesDistances, gainedMRSs, '.k', 'Markersize', 14)
plot(NStoAllSpinesDistances, nanmean(simgained,2), '.', 'markersize', 14, 'color', pink)
xlabel('Distance (\mum)')
ylabel('Is MRSness Gained')

subplot(2,2,4); hold on; 
tempX = xvals(~isnan(GainedMRSBins));
GainedMRSBinsError = GainedMRSBinsError(~isnan(GainedMRSBins));
GainedMRSBins = GainedMRSBins(~isnan(GainedMRSBins));
plot(tempX, GainedMRSBins, 'k', 'linewidth', 2)
x_vector = [tempX, fliplr(tempX)];
patch_data = fill(x_vector, [GainedMRSBins+GainedMRSBinsError,fliplr(GainedMRSBins-GainedMRSBinsError)], gray);
set(patch_data, 'FaceAlpha', 0.75);
uistack(patch_data, 'bottom')

tempX = xvals(~isnan(SimGainedMRSBins));
SimGainedMRSBinsError = SimGainedMRSBinsError(~isnan(SimGainedMRSBins));
SimGainedMRSBins = SimGainedMRSBins(~isnan(SimGainedMRSBins));
x_vector = [tempX, fliplr(tempX)];
patch_chance = fill(x_vector, [SimGainedMRSBins+SimGainedMRSBinsError,fliplr(SimGainedMRSBins-SimGainedMRSBinsError)], pink);
plot(tempX, SimGainedMRSBins, 'k', 'linewidth', 2)
set(patch_chance, 'FaceAlpha', 0.75);
xlabel('Distance Bins')
ylabel('Probabiliy of Gained MRness')
legend([patch_data, patch_chance], {'Data', 'Chance'})
title('Probability of Becoming MRS')

%=======================

newspinesrandspines = cell2mat(DistancesBetweenNewSpinesandRandomSpines);
newspinesshuffledearlyspines = cell2mat(DistancesBetweenNewSpinesandShuffledEarlyMovementSpines);
newspinesearlymovspines = cell2mat(DistancesBetweenNewSpinesandNearestEarlyMovementSpines);
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
ShuffledVolumeIncreaseDistances = cell(1,shuffnum);

%%% Determine whether each NS appears on the middle or late session, which
%%% will allow you to simulate the effect of this variable instead of
%%% always taking the early session
count= 1;
dudcount = 1;
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
    mocklatenewspinedistribution = nan(1,sum(NumberofNewSpines));
    mockearlyelimspinedistribution = nan(1,sum(NumberofElimSpines));
    mocklateelimspinedistribution = nan(1,sum(NumberofElimSpines));
    for j = 1:sum(NumberofNewSpines)
        %%% Select random data within the set
        randAnimal = randi([1,length(AllDendriteDistances)],1);
        randField = randi([1,length(AllDendriteDistances{randAnimal})]);
        randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
        spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
        DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        [dendLength, ~] = max(max(DistancesfromRandDend,[],2));
        simNewSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
%         doesRandDendhaveAddition = find(DendriteDynamics{randAnimal}{randField}{randDend}==1);
        %%%
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end); %%% 'end' index corresponds to late session
%         while ~any(EarlyMovementSpines) %|| isempty(doesRandDendhaveAddition)
%             randAnimal = randi([1,length(AllDendriteDistances)],1);
%             randField = randi([1,length(AllDendriteDistances{randAnimal})]);
%             randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
%             spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
%             DistancesfromRandDend = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
%             [dendLength, longeststretch] = max(max(DistancesfromRandDend,[],2));
%             simNewSpine = randi([1,round(dendLength)]); %%% The 2x multiplier is to provide 0,5um precision
%             EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1);
% %             doesRandDendhaveAddition = find(DendriteDynamics{randAnimal}{randField}{randDend}==1);
%         end

        if isMid(j)
            MRSs_to_use = EarlyMovementSpines & LateMovementSpines;
        else
            if size(AllMovementSpines{randAnimal}{randField},1)> 2
                MidMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,2);
%                 randsesh = randi(2);
%                 if randsesh == 1
%                     MRSs_to_use = EarlyMovementSpines;
%                 elseif randsesh == 2
%                     MRSs_to_use = MidMovementSpines;
%                 end
                MRSs_to_use = MidMovementSpines & LateMovementSpines;
%                 MRSs_to_use = LateMovementSpines;
            else
                MRSs_to_use = EarlyMovementSpines & LateMovementSpines;
%                 MRSs_to_use = LateMovementSpines;
            end
        end 
        %%%
        if ~isempty(NewSpines{randAnimal})
            try
                RealNewSpines = NewSpines{randAnimal}{randField};
            catch
                RealNewSpines = [];
            end
            try 
                RealNewSpines = union(RealNewSpines, MiddleSessionNewSpines{randAnimal}{randField});
            catch
                RealNewSpines = RealNewSpines;
            end
        else
            RealNewSpines = [];
        end
        DistancesfromRandDend  = DistancesfromRandDend(~ismember(spinesfromrandDend,RealNewSpines),~ismember(spinesfromrandDend,RealNewSpines));
        [~, longeststretch] = max(max(DistancesfromRandDend,[],2));
        MRSs_to_use = MRSs_to_use(~ismember(spinesfromrandDend,RealNewSpines));
        %%%
        if ~any(MRSs_to_use)
%             mockearlynewspinedistribution{i}(j) = nanmin(abs(simNewSpine-DistancesfromRandDend(longeststretch,[2,end])));
            mockearlynewspinedistribution{i}(j) = nan;
        else
            mockearlynewspinedistribution{i}(j) = nanmin(abs(DistancesfromRandDend(longeststretch, MRSs_to_use)-simNewSpine));
        end
        if ~isempty(AllSpineVolumeData{randAnimal}{randField})
            if size(AllMovementSpines{randAnimal}{randField},1)> 2
                if isMid
                    SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,2)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,1);
                else
                    SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,end)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,end-1);
                end
            else
                SpineVol = AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,end)./AllSpineVolumeData{randAnimal}{randField}(spinesfromrandDend,1);
            end
            SpineVol(SpineVol==Inf) = NaN;
            VolIncreaseIndex = SpineVol(~ismember(spinesfromrandDend,RealNewSpines))>= spine_enlargement_cutoff;
            RelativeDistances = abs(DistancesfromRandDend(longeststretch,:)-simNewSpine);
            %==============================================================
            %%%
%             PlasticityContingency = VolIncreaseIndex;
%             PlasticityContingency = VolIncreaseIndex & (EarlyMovementSpines | MidMovementSpines);
            PlasticityContingency = VolIncreaseIndex & (MRSs_to_use);
            %%%
            if ~any(PlasticityContingency)
%                 PlasticityContingency([1,end]) = 1;
                dudcount = dudcount+1;
                ShuffledVolumeIncreaseDistances{i}{j} = nan;
            else
                ShuffledVolumeIncreaseDistances{i}{j} = nanmin(RelativeDistances(PlasticityContingency));
            end
            %==============================================================
        else
            ShuffledVolumeIncreaseDistances{i}{j} = nan;
        end
        %%%
    end
    %================================Stats=================================
    SimNewSpinetoEarlyMovementSpineDistance(i) = nanmedian(mockearlynewspinedistribution{i});
        if SimNewSpinetoEarlyMovementSpineDistance(i) > nanmedian(newspinesearlymovspines)
            NewSpineEarlyMoveSpinesNullDistTest(i) = 1;
        else
            NewSpineEarlyMoveSpinesNullDistTest(i) = 0;
        end
    SimNewSpinetoEnlargedSpineDistance(i) = nanmedian(cell2mat(ShuffledVolumeIncreaseDistances{i}));
        if SimNewSpinetoEnlargedSpineDistance(i) > nanmedian(ClosestEnlargedSpineList)
            NewSpinetoEnlargedSpinesNullDistTest(i) = 1;
        else
            NewSpinetoEnlargedSpinesNullDistTest(i) = 0;
        end
    %======================================================================
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
            simElimSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
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
datamat = [{SimNewSpinetoEarlyMovementSpineDistance},{newspinesearlymovspines},{distancetoMaxCorrPartner}, {SimElimSpinetoEarlyMovementSpineDistance},{elimspinesearlymovspines}];
figure; subplot(2,2,1);
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', dred'); hold on;
%     r_errorbar(1:6, [nanmedian(randspines),nanmedian(shuffledearlyspines),nanmedian(earlyspines),nanmedian(shuffledspines),nanmedian(newspines),nanmedian(elimspines)], [nanstd(randspines)/sum(~isnan(randspines)),nanstd(shuffledearlyspines)/sum(~isnan(shuffledearlyspines)),nanstd(earlyspines)/sum(~isnan(earlyspines)),nanstd(shuffledspines)/sum(~isnan(shuffledspines)), nanstd(newspines)/sum(~isnan(newspines)), nanstd(elimspines)/sum(~isnan(elimspines))], 'k')
Y = cell(1,length(datamat));
for i = 1:length(datamat)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'Shuff New Spine-Early MRS','New Spine-Early MRS','MaxCorrPartner','Shuff. Elim Sp - Early MRS', 'Elim Sp - Early MRS'})
ylabel('Median Distance')
xtickangle(gca, 45)

plot(1:2, (max([Y{1}; Y{2}])+1)*ones(1,2), 'k', 'Linewidth', 2)
text(1.4, (max([Y{1}; Y{2}])+2), num2str((shuffnum-sum(NewSpineEarlyMoveSpinesNullDistTest))/shuffnum))

plot(4:5, (max([Y{4}; Y{5}])+1)*ones(1,2), 'k', 'Linewidth', 2)
text(4.5, max([Y{4}; Y{5}])+2, num2str((shuffnum-sum(NewSpineLateMoveSpinesNullDistTest))/shuffnum))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allmovementspinedistances = [];
% for animal = 1:length(AllMovementSpines)
%     for field = 1:length(AllMovementSpines{animal})
%         for session = 1:size(AllMovementSpines{animal}{field},2)
%             sessionmovespines = find(AllMovementSpines{animal}{field}(:,session));
%             if length(sessionmovespines)>1
%                 spinecombos = nchoosek(sessionmovespines,2);
%                 for cmb = 1:size(spinecombos,1)
%                     allmovementspinedistances = [allmovementspinedistances, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
%                 end
%             else
%             end
%         end
%     end
% end
% allmovementspinedistancesearly = [];
% allearlymovementspinedistancesshuffled = [];
% for animal = 1:length(AllMovementSpines)
%     for field = 1:length(AllMovementSpines{animal})
%         sessionmovespines = find(AllMovementSpines{animal}{field}(:,1));
%         if length(sessionmovespines)>1
%             spinecombos = nchoosek(sessionmovespines,2);
%             for cmb = 1:size(spinecombos,1)
%                 allmovementspinedistancesearly = [allmovementspinedistancesearly, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
%             end
%         else
%         end
%         for shuff = 1:100
%             sessionmovespines = find(shake(AllMovementSpines{animal}{field}(:,1)));
%             if length(sessionmovespines)>1
%                 spinecombos = nchoosek(sessionmovespines,2);
%                 for cmb = 1:size(spinecombos,1)
%                     allearlymovementspinedistancesshuffled = [allearlymovementspinedistancesshuffled, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
%                 end
%             else
%             end
%         end
%     end
% end
% 
% allmovementspinedistanceslate = [];
% for animal = 1:length(AllMovementSpines)
%     for field = 1:length(AllMovementSpines{animal})
%         sessionmovespines = find(AllMovementSpines{animal}{field}(:,end));
%         if length(sessionmovespines)>1
%             spinecombos = nchoosek(sessionmovespines,2);
%             for cmb = 1:size(spinecombos,1)
%                 allmovementspinedistanceslate = [allmovementspinedistanceslate, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
%             end
%         else
%         end
%     end
% end
% allmovementspinedistancesshuffled = [];
% for animal = 1:length(AllMovementSpines)
%     for field = 1:length(AllMovementSpines{animal})
%         for session = 1:size(AllMovementSpines{animal}{field},2)
%             for shuff = 1:10
%                 sessionmovespines = find(shake(AllMovementSpines{animal}{field}(:,session)));
%                 if length(sessionmovespines)>1
%                     spinecombos = nchoosek(sessionmovespines,2);
%                     for cmb = 1:size(spinecombos,1)
%                         allmovementspinedistancesshuffled = [allmovementspinedistancesshuffled, AllDendriteDistances{animal}{field}(spinecombos(cmb,1), spinecombos(cmb,2))];
%                     end
%                 else
%                 end
%             end
%         end
%     end
% end

%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 9: Dynamic Spines Max Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

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

%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 10: Dynamic Spines Correlation with Nearby Movement-related
%%% spines (as a function of distance, and overall)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

figure; a = subplot(2,2,1); hold on; 
plot(cell2mat(DistancesBetweenNewSpinesandNearestEarlyMovementSpines), cell2mat(LateCorrofNewSpinesandNearestMovementSpinefromEarlySessions), '.k', 'Markersize', 14)
title('New spines vs. Nearest Early Movement Spines')

b = subplot(2,2,2); 
plot(cell2mat(DistancesBetweenNewSpinesandLateMovementSpines), cell2mat(LateCorrofNewSpinesandMovementSpinefromLateSessions), '.k', 'Markersize', 14)
title('New spines vs. Nearest Late Movement Spines')

c = subplot(2,2,3);
plot(cell2mat(DistancesBetweenElimSpinesandEarlyMovementSpines), cell2mat(CorrelationsofElimSpinesandEarlyMovementSpines), '.k', 'Markersize', 14)
title('Elim spines vs. Nearest Early Movement Spines')
linkaxes([a,b,c], 'xy')

subplot(2,2,4); hold on
% datamat = [{cell2mat(NewSpinesCorrwithNearbyEarlyMRSs)},{cell2mat(NewSpinesCorrwithNearbyLateMRSs)},{cell2mat(ElimSpinesCorrwithNearbyMRSs)},{cell2mat(FrequencyMatchedControlCorrelation)},{cell2mat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)}, {cell2mat(MovementSpineDistanceMatchedControlCorrelation)}];
% datamat = [{cellfun(@nanmedian, NewSpinesCorrwithNearbyEarlyMRSs)},{cellfun(@nanmedian, NewSpinesCorrwithNearbyLateMRSs)},{cellfun(@nanmedian, ElimSpinesCorrwithNearbyMRSs)},{cellfun(@nanmedian, FrequencyMatchedControlCorrelation)},{cellfun(@nanmedian, NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)}, {cellfun(@nanmedian, MovementSpineDistanceMatchedControlCorrelation)}];
% datamat = [{cellfun(@nanmedian, horzcat(NewSpinesCorrwithNearbyEarlyMRSs)},{cellfun(@nanmedian, FrequencyMatchedControlCorrelation)},{cellfun(@nanmedian, cellfun(@(x,y) [x,y], NewSpinesCorrwithDistanceMatchedNonEarlyMRSs,MovementSpineDistanceMatchedControlCorrelation,'uni', false))}];
datamat = [{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(NewSpinesCorrwithNearbyEarlyMRSs{:}), 'uni', false))}, {cellfun(@nanmedian, horzcat(FrequencyMatchedControlCorrelation{:}))}, {cellfun(@nanmedian, cellfun(@cell2mat, cellfun(@(x,y) [x,y], horzcat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{:}),horzcat(MovementSpineDistanceMatchedControlCorrelation{:}),'uni', false), 'uni', false))}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
bootstrpnum = shuffnum;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'NS-Max Nearby eMRS','Freq-Matched Control', 'Dist-matched'})
xtickangle(gca, 45)
title('Max Correlation with Nearby MRSs')

maxline = max(cell2mat(Y')); 

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
        text(mean([1,(i)])-0.1, maxline+0.05, statsymbol)
    else
        plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([1,(i)])-0.1, maxline+0.05, 'ns')
    end
    maxline = maxline+0.075;
end


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 11: Clustered Spines' Correlation with dendritic activity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================


%%% New Spines
useabsval = 0;
figure;subplot(1,3,1)

datamat = [{cellfun(@nanmedian, ClusteredNewSpineCorrwithDendrite)}, {cellfun(@nanmedian, ClusteredMoveSpineCorrwithDendrite)}, {cellfun(@nanmedian, CoActiveClusterCorrwithDendrite)}];

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
    datamat = [{cellfun(@nanmedian, ClusteredNewSpineCorrwithMovement)}, {cellfun(@nanmedian, ClusteredMoveSpineCorrwithMovement)}, {cellfun(@nanmedian, CoActiveClusterCorrwithMovement)}];
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
    datamat2 = [{cellfun(@nanmedian, ClusteredNewSpineCorrwithSuccess)}, {cellfun(@nanmedian, ClusteredMoveSpineCorrwithSuccess)}, {cellfun(@nanmedian, CoActiveClusterCorrwithSuccess)}];
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


%==========================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 12: Correlation of clustered spines DURING specified presses
%%% (Noise Correlation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==========================================================================

%%% New Spines
useabsval = 0;
figure;hold on

subplot(1,2,1)

ClustNoiseCorr = cell(1,length(MoveCentricClusterCorrelation));
for animal = 1:length(MoveCentricClusterCorrelation)
    for field = 1:length(MoveCentricClusterCorrelation{animal})
        ClustNoiseCorr{animal} = [ClustNoiseCorr{animal}, cell2mat(MoveCentricClusterCorrelation{animal}{field})];
    end
end

% datamat = [{cell2mat(MoveCentricClusterCorrelation)}, {cell2mat(MoveCentricDistanceMatchedCorrelation)}, {cell2mat(MoveCentricDistanceMatchedCorrelationforMRS)}, {cell2mat(MoveCentricCorrelationofAllOtherSpines')}, {cell2mat(MoveCentricFrequencyMatchedCorrelation)}, {cell2mat(FailureCentricClusterCorrelation)}];
datamat = [{cellfun(@nanmedian, ClustNoiseCorr)}, {cellfun(@nanmedian, MoveCentricDistanceMatchedCorrelation)}, {cellfun(@nanmedian, MoveCentricDistanceMatchedCorrelationforMRS)}, {cellfun(@nanmedian, MoveCentricCorrelationofAllOtherSpines')}, {cellfun(@nanmedian, MoveCentricFrequencyMatchedCorrelation)}, {cellfun(@nanmedian, FailureCentricClusterCorrelation)}];
datamat = [{cellfun(@nanmedian, ClustNoiseCorr)}, {cellfun(@nanmedian, cellfun(@(x,y) [x,y], MoveCentricDistanceMatchedCorrelation,MoveCentricDistanceMatchedCorrelationforMRS, 'uni', false))}, {cellfun(@nanmedian, MoveCentricCorrelationofAllOtherSpines')}, {cellfun(@nanmedian, MoveCentricFrequencyMatchedCorrelation)}, {cellfun(@nanmedian, FailureCentricClusterCorrelation)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = [];
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', 1:length(datamat))
set(gca, 'XTickLabel', {'Clusters', 'Dist. Matched', 'All other spines', 'Freq matched', 'Clusters with failure'})
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
%%% Figure 13: Combined reliability of clusters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on

datamat = [{cellfun(@nanmedian, ClusterMovementReliability)},{cellfun(@nanmedian, ControlPairMovementReliability)}, {cellfun(@nanmedian, ClusterSuccessReliability)}, {cellfun(@nanmedian, ControlPairSuccessReliability)}];

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

[p,~] = signrank(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

[p,~] = signrank(datamat{3},datamat{4});

if p<0.05
    text(3.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(3.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 14: Correlation of MOVEMENTS during co-active cluster periods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%==========================================================================
%%% Choose data carefully!

%%% Option 1: This presents all correlation values of all movement sets found in a
%%% single animal; averaging is done with ANIMALS as the sample, and error
%%% taken accordingly. Note: movement correlation is still found on a
%%% cluster-by-cluster basis, so movements are NOT compared between
%%% clusters

useabsval = 0;
sub1 = 3;
sub2 = 5;
subcount = 1;

figure;hold on

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
            NSonly_byAnimal{i} = [NSonly_byAnimal{i}; MovementCorrelationwithNSonlyActivitybyCluster{i}{j}{k}];
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

MedianClusterValuebyAnimal = cellfun(@nanmean, Clusters_byAnimal);
MedianAnyClusterbyAnimal = cellfun(@nanmean, AnyClusterValuesbyAnimal);
MedianMRSOnlybyAnimal = cellfun(@nanmean, MRSonly_byAnimal);
MedianNSOnlybyAnimal = cellfun(@nanmean, NSonly_byAnimal);
MedianMRSDMbyAnimal = cellfun(@nanmean, MRSDM_byAnimal);
MedianFMControlbyAnimal = cellfun(@nanmean, FMctrl_byAnimal);
MedianOtherSpinePairsbyAnimal = cellfun(@nanmean, OtherSpines_byAnimal);
MedianAllOtherbyAnimal = cellfun(@nanmean, AllOthers_byAnimal);

Animal_datamat = [{MedianClusterValuebyAnimal}, {MedianAnyClusterbyAnimal},{MedianMRSOnlybyAnimal}, {MedianNSOnlybyAnimal}, {MedianMRSDMbyAnimal},{MedianFMControlbyAnimal},{MedianOtherSpinePairsbyAnimal},{MedianAllOtherbyAnimal}];

datamat = Animal_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmean, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

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
        NSValuesbyField{i} = [NSValuesbyField{i}; NSOnly_AllFields{i}{j}];
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

MedianClusterValuebyField = cellfun(@nanmean, AllClusterValuesbyField);
MedianAnyClusterbyField = cellfun(@nanmean, AnyClusterValuesbyField);
MedianMRSOnlybyField = cellfun(@nanmean, MRSValuesbyField);
MedianNSOnlybyField = cellfun(@nanmean, NSValuesbyField);
MedianMRSDMbyField = cellfun(@nanmean, MRSDMValuesbyField);
MedianFMControlbyField = cellfun(@nanmean, FMControlValuesbyField);
MedianOtherSPbyField = cellfun(@nanmean, OtherPairs_AllFields);
MedianAllOtherbyField = cellfun(@nanmean, AllOthers_AllFields);

Fields_datamat = [{MedianClusterValuebyField}, {MedianAnyClusterbyField}, {MedianMRSOnlybyField}, {MedianNSOnlybyField}, {MedianMRSDMbyField}, {MedianFMControlbyField}, {MedianOtherSPbyField}, {MedianAllOtherbyField'}];

datamat = Fields_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmean, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    try
        plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
        Y{i} = bootci(bootstrpnum, {@mean, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
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
MRSValues_AllNewSpines = horzcat(MRSOnly_AllFields{:});
MRSDM_AllNewSpines = horzcat(MRSDM_AllFields{:});
FMPairs_AllNewSpines = horzcat(FMPairs_AllFields{:});

num_NewSpines = length(Clusters_AllNewSpines);
AllClusterValuesbyNS = cell(1,num_NewSpines);
NSValuesbyNS = cell(1,num_NewSpines);
MRSonlyValuesbyNS = cell(1,num_NewSpines);
MRSDMValuesbyNS = cell(1,num_NewSpines);
FMControlValuesbyNS = cell(1,num_NewSpines);

for i = 1:num_NewSpines
    for j = 1:length(Clusters_AllNewSpines{i})
        AllClusterValuesbyNS{i} = [AllClusterValuesbyNS{i}; Clusters_AllNewSpines{i}{j}];
        MRSonlyValuesbyNS{i} = [MRSonlyValuesbyNS{i}; MRSValues_AllNewSpines{i}{j}];
        MRSDMValuesbyNS{i} = [MRSDMValuesbyNS{i}; MRSDM_AllNewSpines{i}{j}];
        FMControlValuesbyNS{i} = [FMControlValuesbyNS{i}; FMPairs_AllNewSpines{i}{j}];
    end
    NSValuesbyNS{i} = [NSValuesbyNS{i}; NSValues_AllNewSpiness{i}];
end

MedianClusterValuebyNS = cellfun(@nanmean, AllClusterValuesbyNS);
MedianNSOnlybyNS = cellfun(@nanmean, NSValuesbyNS);
MedianMRSOnlybyNS = cellfun(@nanmean, MRSonlyValuesbyNS);
MedianMRSDMbyNS = cellfun(@nanmean, MRSDMValuesbyNS);
MedianFMControlbyNS = cellfun(@nanmean, FMControlValuesbyNS);

NS_datamat = [{MedianClusterValuebyNS}, {MedianNSOnlybyNS}, {MedianMRSOnlybyNS}, {MedianMRSDMbyNS}, {MedianFMControlbyNS}, {MedianAllOtherbyField}];

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
set(gca, 'XTickLabel', {'With CoActive Clusters', 'NS only', 'MRS only', 'MRSDM', 'FM ctrl', 'All Other'})
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
AllNSbyCluster = NSValues_AllNewSpiness;
AllMRSonlybyCluster = horzcat(MRSValues_AllNewSpines{:});
AllMRSDMPairs = horzcat(MRSDM_AllNewSpines{:});
AllFMPairs = horzcat(FMPairs_AllNewSpines{:});

MedianClusterValuebyCluster = cellfun(@nanmean, AllClusters);
MedianNSOnlybyCluster = cellfun(@nanmean, AllNSbyCluster);
MedianMRSOnlybyCluster = cellfun(@nanmean, AllMRSonlybyCluster); 
MedianMRSDMbyCluster = cellfun(@nanmean, AllMRSDMPairs);
MedianFMControlbyCluster = cellfun(@nanmean, AllFMPairs);

Cluster_datamat = [{MedianClusterValuebyCluster(AllCoARates>0.45)}, {MedianNSOnlybyCluster}, {MedianMRSOnlybyCluster},{MedianMRSDMbyCluster}, {MedianFMControlbyCluster}, {MedianOtherSPbyField}, {MedianAllOtherbyField}];
datamat = Cluster_datamat;

subplot(sub1,sub2,subcount)

bar(1:length(datamat), cell2mat(cellfun(@nanmean, datamat, 'uni', false)), 'FaceColor', lblue); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    try
        plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
        Y{i} = bootci(bootstrpnum, {@mean, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
        line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
    catch
        Y{i} = [];
    end
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'NS only', 'MRS only', 'MRSDM', 'Freq matched pairs', 'Other SP', 'Without'})
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
if any(cellfun(@(x) length(x)>10000, datamat))
    disp('Too many data points to display; for stats, run manually')
else
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
end


%======== Begin combining movements across different levels
%%% Option 6: This method concatenates all target movements together for a
%%% particular FIELD, thus broadening the definition of what, e.g.,
%%% movements with cluster co-activity can mean (i.e. movements with ANY
%%% cluster co-activity, taken across any of the late sessions). The
%%% assumption here is that cluster co-activity might represent a larger
%%% circuit-wide movement scheme 
subcount = 6;

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

if any(cellfun(@(x) length(x)>10000, datamat))
    disp('Too many data points to display; for stats, run manually')
else
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

if any(cellfun(@(x) length(x)>10000, datamat))
    disp('Too many data points to display; for stats, run manually')
else
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 15: PCA of different movement groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp = horzcat(MovementswithClusteredCoActivity{:});
AllClustMovs = horzcat(temp{:});

temp = horzcat(WithoutGroupMovements{:});
WithoutGroupMovs = horzcat(temp{:});

ClustMovsbyAnimal = cellfun(@(x) horzcat(x{:}), MovementswithClusteredCoActivity, 'uni', false);
OtherMovsbyAnimal = cellfun(@(x) horzcat(x{:}), WithoutGroupMovements, 'uni', false);

for i = 1:length(ClustMovsbyAnimal)
    if ~isempty(ClustMovsbyAnimal{i})
        Data{i} = zscore([ClustMovsbyAnimal{i}'; OtherMovsbyAnimal{i}'],[],2);
        [coeffs{i}, scores{i},~,~,explained{i}, ~] = pca(Data{i});
        clustcorrs = corrcoef([coeffs{i}(:,1), ClustMovsbyAnimal{i}]);
        clustcorrwithPC1{i} = nanmedian(clustcorrs(1,2:end));
        othercorrs = corrcoef([coeffs{i}(:,1), OtherMovsbyAnimal{i}]);
        othercorrwithPC1{i} = nanmedian(othercorrs(1,2:end));
%         PC1proj{i} = scores{i}(:,1)'*Data{i};
%         PC2proj{i} = scores{i}(:,2)'*Data{i};
%         PC3proj{i} = scores{i}(:,3)'*Data{i};
        [NMFcoeffs{i}, NMFscores{i}] = nnmf(Data{i}',10);
        indbyanimal{i} = size(ClustMovsbyAnimal{i},2);
    end
end

clustPC1scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,1), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));
otherPC1scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,1), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));

clustPC2scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,2), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));
otherPC2scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,2), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));

clustPC3scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,3), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));
otherPC3scoresbyanimal = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,3), scores(~cellfun(@isempty, scores)), indbyanimal(~cellfun(@isempty, scores)), 'uni', false), 'uni', false));

clustNNMFscoresbyanimal = cellfun(@nanmedian, cellfun(@(x,y) x(1,1:y), NMFscores(~cellfun(@isempty, NMFscores)), indbyanimal(~cellfun(@isempty, NMFscores)), 'uni', false));
otherNNMFscoresbyanimal = cellfun(@nanmedian, cellfun(@(x,y) x(1,y+1:end), NMFscores(~cellfun(@isempty, NMFscores)), indbyanimal(~cellfun(@isempty, NMFscores)), 'uni', false));

figure; subplot(1,2,1)
datamat = [{clustPC1scoresbyanimal}, {otherPC1scoresbyanimal}, {clustPC2scoresbyanimal}, {otherPC2scoresbyanimal}, {clustPC3scoresbyanimal}, {otherPC3scoresbyanimal}];

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
set(gca, 'XTickLabel', {'Clust PC1', 'Other PC1', 'Clust PC2', 'Other PC2'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Principal Component Analysis by Animal')

maxline = cellfun(@max, Y);
statline_increment = nanmedian(datamat{1})/5;

for i = [1,3,5]
    [p,~] = signrank(datamat{i},datamat{i+1});
    if p<0.05
        if p < 0.001
            statsymbol = '***';
        elseif p<0.01
            statsymbol = '**';
        elseif p<0.05
            statsymbol = '*';
        end
        plot(i:i+1, (max(maxline(i:i+1))+0.01)*ones(1,2), '-', 'Linewidth', 2, 'Color', 'g')
        text(mean([1,(i+1)])-0.1, max(maxline(i:i+1))+0.5, statsymbol)
    else
        plot(i:i+1, (max(maxline(i:i+1))+0.01)*ones(1,2), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([i,(i+1)])-0.1, max(maxline(i:i+1))+0.5, 'ns')
    end
end

ClustMovsbyField = horzcat(MovementswithClusteredCoActivity{:});
OtherMovsbyField = horzcat(WithoutGroupMovements{:});

for i = 1:length(ClustMovsbyField)
    if~isempty(ClustMovsbyField{i})
        FieldData{i} = zscore([ClustMovsbyField{i}'; OtherMovsbyField{i}'],[],2);
        [fieldcoeffs{i}, fieldscores{i}, ~,~,fieldexplained{i}, ~] = pca(FieldData{i});
        [NMFfieldcoeffs{i}, NMFfieldscores{i}] = nnmf(FieldData{i}', 10);
        indbyfield{i} = size(ClustMovsbyField{i},2);
    end
end

clustPC1scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,1), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));
otherPC1scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,1), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));

clustPC2scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,2), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));
otherPC2scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,2), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));

clustPC3scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(1:y,3), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));
otherPC3scoresbyfield = cellfun(@nanmedian, cellfun(@abs, cellfun(@(x,y) x(y+1:end,3), fieldscores(~cellfun(@isempty, fieldscores)), indbyfield(~cellfun(@isempty, fieldscores)), 'uni', false), 'uni', false));

clustNNMFscoresbyfield = cellfun(@nanmedian, cellfun(@(x,y) x(1,1:y), NMFfieldscores(~cellfun(@isempty, NMFfieldscores)), indbyfield(~cellfun(@isempty, NMFfieldscores)), 'uni', false));
otherNNMFscoresbyfield = cellfun(@nanmedian, cellfun(@(x,y) x(1,y+1:end), NMFfieldscores(~cellfun(@isempty, NMFfieldscores)), indbyfield(~cellfun(@isempty, NMFfieldscores)), 'uni', false));

subplot(1,2,2)
datamat = [{clustPC1scoresbyfield}, {otherPC1scoresbyfield}, {clustPC2scoresbyfield}, {otherPC2scoresbyfield}, {clustPC3scoresbyfield}, {otherPC3scoresbyfield}];

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
set(gca, 'XTickLabel', {'Clust PC1', 'Other PC1', 'Clust PC2', 'Other PC2'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Principal Component Analysis by Field')

maxline = cellfun(@max, Y);
statline_increment = nanmedian(datamat{1})/5;

for i = [1,3,5]
    [p,~] = signrank(datamat{i},datamat{i+1});
    if p<0.05
        if p < 0.001
            statsymbol = '***';
        elseif p<0.01
            statsymbol = '**';
        elseif p<0.05
            statsymbol = '*';
        end
        plot(i:i+1, (max(maxline(i:i+1))+0.01)*ones(1,2), '-', 'Linewidth', 2, 'Color', 'g')
        text(mean([1,(i+1)])-0.1, max(maxline(i:i+1))+0.5, statsymbol)
    else
        plot(i:i+1, (max(maxline(i:i+1))+0.01)*ones(1,2), '-', 'Linewidth', 2, 'Color', 'r')
        text(mean([i,(i+1)])-0.1, max(maxline(i:i+1))+0.5, 'ns')
    end
end

%==========================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 16: Movement Relatedness of different spine types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; hold on; 
sub1 = 1;
sub2 = 4;

subplot(sub1,sub2,1)
% datamat = [{cell2mat(vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:})')}, {cell2mat(horzcat(AllOtherMovementsCorrelationwithModelMovement{:}))}, {cell2mat(horzcat(FMControlMovementsCorrelationwithModelMovement{:}))}];
% datamat = [{cellfun(@nanmedian, vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(AllOtherMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(FMControlMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, vertcat(MRSOnlyMovementsCorrelationwithModelMovement{:}))'}, {cellfun(@nanmedian, vertcat(NSActivityOnlyMovementsCorrelationwithModelMovement{:}))'}];
% 
% AllMRSDMmodelcorrbyanimal = cell(1,length(MRSDMControlMovementsCorrelationwithModelMovementbyCluster)); 
% % AllMRSDMmodelcorrbyanimal = cell(1,length(horzcat(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{:})));
% for i = 1:length(MRSDMControlMovementsCorrelationwithModelMovementbyCluster)
%     for j = 1:length(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{i})
%         for k = 1:length(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{i}{j})
%             AllMRSDMmodelcorrbyanimal{i} = [AllMRSDMmodelcorrbyanimal{i}, cell2mat(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{i}{j}{k})];
%         end
%     end
% end
% 
% AllNSDMmodelcorrbyanimal = cell(1,length(MRSDMControlMovementsCorrelationwithModelMovementbyCluster)); 
% % AllNSDMmodelcorrbyanimal = cell(1,length(horzcat(NSDMControlMovementsCorrelationwithModelMovementbyCluster{:})));
% for i = 1:length(NSDMControlMovementsCorrelationwithModelMovementbyCluster)
%     for j = 1:length(NSDMControlMovementsCorrelationwithModelMovementbyCluster{i})
%         for k = 1:length(NSDMControlMovementsCorrelationwithModelMovementbyCluster{i}{j})
%             AllNSDMmodelcorrbyanimal{i} = [AllNSDMmodelcorrbyanimal{i}, NSDMControlMovementsCorrelationwithModelMovementbyCluster{i}{j}{k}];
%         end
%     end
% end
% 
% AllDistMatched = cellfun(@(x,y) [x,y], AllMRSDMmodelcorrbyanimal, AllNSDMmodelcorrbyanimal, 'uni', false);
% 
% datamat = [{cellfun(@nanmedian, cellfun(@(x) cell2mat(x'), CoActiveClusterMovementsCorrelationwithModelMovement, 'uni', false))'},{cellfun(@nanmedian, cellfun(@(x) cell2mat(x'), NSActivityOnlyMovementsCorrelationwithModelMovement, 'uni', false))'}, {cellfun(@nanmedian, cellfun(@(x) cell2mat(x), FMControlMovementsCorrelationwithModelMovement, 'uni', false))'},{cellfun(@nanmedian, AllDistMatched)'}, {cellfun(@nanmedian, cellfun(@(x) cell2mat(x), AllOtherMovementsCorrelationwithModelMovement, 'uni', false))'}];
% bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lblue); hold on;
% 
% for i = 1:length(datamat)
%     plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
%     Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
%     line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
% end
% set(gca, 'XTick', [1:length(datamat)])
% set(gca, 'XTickLabel', {'With CoActive Clusters','NS only', 'FM ctrls', 'Dist-Matched', 'Without'})
% xtickangle(gca, 45)
% ylabel('Correlation')
% title('Corr. of Mvmts with Model')
% 
% maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
% plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)
% 
% [p,~] = signrank(datamat{1},datamat{2});
% 
% if p<0.05
%     text(1.4, maxline+0.05, ['* p =', num2str(p)])
% else
%     text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
% end

%% Organize by field instead

CoAbyCluster = vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:});
CoAbyCluster = CoAbyCluster(~cellfun(@isempty, CoAbyCluster));

AllMRSDMmodelcorrbyfield = horzcat(MRSDMControlMovementsCorrelationwithModelMovementbyCluster{:});
AllMRSDMmodelcorrbyfield = AllMRSDMmodelcorrbyfield(~cellfun(@isempty, AllMRSDMmodelcorrbyfield));
AllMRSDMmodelcorrbyfield  = cellfun(@(x) horzcat(x{:}), AllMRSDMmodelcorrbyfield , 'uni', false);
AllMRSDMmodelcorrbyfield = cellfun(@cell2mat, AllMRSDMmodelcorrbyfield, 'uni', false);

AllNSDMmodelcorrbyfield = horzcat(NSDMControlMovementsCorrelationwithModelMovementbyCluster{:});
AllNSDMmodelcorrbyfield = AllNSDMmodelcorrbyfield(~cellfun(@isempty, AllNSDMmodelcorrbyfield));
AllNSDMmodelcorrbyfield  = cellfun(@cell2mat, AllNSDMmodelcorrbyfield , 'uni', false);

AllDistMatchedbyField = cellfun(@(x,y) [x,y], AllMRSDMmodelcorrbyfield, AllNSDMmodelcorrbyfield, 'uni', false);

datamat = [{cellfun(@nanmedian, vertcat(CoActiveClusterMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, vertcat(NSActivityOnlyMovementsCorrelationwithModelMovement{:}))},{cellfun(@nanmedian, vertcat(MRSOnlyMovementsCorrelationwithModelMovement{:}))}, {cellfun(@nanmedian, horzcat(FMControlMovementsCorrelationwithModelMovement{:}))'},{cellfun(@nanmedian, AllDistMatchedbyField)'}, {cellfun(@nanmedian, horzcat(AllOtherMovementsCorrelationwithModelMovement{:}))'}];
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

%%% Organize the data in such a way that NS-MRS pairs can be tracked to,
%%% e.g., coactivity data

temp = (vertcat(CoActiveClusterMovementsCorrelationwithModelMovementbyCluster{:}));
temp2 = horzcat(temp{:}); 
temp3 = horzcat(temp2{:}); %%% Should now be the same length as MRScoAlist


chosen_cutoff = 0.25;    %%% This value comes from the EM data of confirmed axon-sharing pairs; you can remove any coactivity rates above this level to test whether the results require axon-sharing pair-like coactivity levels to be true
temp3(temp3>chosen_cutoff) = {NaN};

% Now, put the data back in the original organization scheme
back1 = mat2cell(temp3, 1, cellfun(@length, temp2));
back2 = mat2cell(back1, 1, cellfun(@length, temp)); %%% Should now be the size of the number of fields in the data

FilteredData = cell(1,sum(cell2mat(NumFields))); 
for i = 1:length(back2)
    for j = 1:length(back2{i})
        FilteredData{i} = [FilteredData{i}, cellfun(@nanmedian, back2{i}{j})]; %%% This data should now be comparable to all of the above data sets, and can be compared to the "without" group readily
    end
end


%==========================================================================

%%%
%%% Dot products of cluster co-activity with movements
subplot(sub1,sub2,2) 
% datamat = [{cell2mat(DotProductofCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofCoactivityMovementOverlap)}, {cell2mat(DotProductofFMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofFMCoActivitywithmovement)}, {cell2mat(DotProductofNSDMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofNSDMCoActivitywithMovement)}, {cell2mat(DotProductofMRSDMCoActivePeriodsDuringMovement)}, {cell2mat(ChanceLevelofMRSDMCoActivitywithMovement)}];

AllDistMatched = cellfun(@(x,y) [x,y], cellfun(@cell2mat, horzcat(DotProductofNSDMCoActivePeriodsDuringMovement{:}),'uni', false),cellfun(@cell2mat, horzcat(DotProductofMRSDMCoActivePeriodsDuringMovement{:}), 'uni', false), 'uni', false);
AllDistMatchedChance = cellfun(@(x,y) [x,y], cellfun(@cell2mat, horzcat(ChanceLevelofNSDMCoActivitywithMovement{:}),'uni', false),cellfun(@cell2mat, horzcat(ChanceLevelofMRSDMCoActivitywithMovement{:}), 'uni', false),'uni', false);

datamat = [{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofCoActivePeriodsDuringMovement{:}), 'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofCoactivityMovementOverlap{:}),'uni', false))},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofNSOnlyActivePeriodsDuringMovement{:}), 'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofNSOnlyActivitywithMovement{:}), 'uni', false))},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofMRSOnlyPeriodsDuringMovement{:}), 'uni', false))},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofMRSOnlyActivitywithMovement{:}), 'uni', false))},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofFMCoActivePeriodsDuringMovement{:}), 'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofFMCoActivitywithmovement{:}),'uni', false))}, {cellfun(@nanmedian, AllDistMatched)}, {cellfun(@nanmedian, AllDistMatchedChance)}];
%%% plot ratios of dot products instead
datamat  = [{datamat{1}./datamat{2}}, {datamat{3}./datamat{4}}, {datamat{5}./datamat{6}}, {datamat{7}./datamat{8}}, {datamat{9}./datamat{10}}];
%%% plot difference of dot products with their own chance
% datamat =  [{datamat{1}-datamat{2}}, {datamat{3}-datamat{4}}, {datamat{5}-datamat{6}}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
xtickangle(gca, 45)
set(gca, 'XTickLabel', {'CoA w Movement', 'NS only', 'MRS only', 'FMCoA w Movement', 'Dist-Matched'})
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

% datamat = [{cell2mat(DotProductofCoActivePeriodsDuringCRMovement)}, {cell2mat(ChanceLevelofCoActivityCRMovementOverlap)}, {cell2mat(DotProductofFMCoActivePeriodsDuringCRMovement)}, {cell2mat(ChanceLevelofFMCoActivityCRMovementOverlap)}];
datamat = [{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofCoActivePeriodsDuringCRMovement{:}), 'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofCoActivityCRMovementOverlap{:}), 'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(DotProductofFMCoActivePeriodsDuringCRMovement{:}),'uni', false))}, {cellfun(@nanmedian, cellfun(@cell2mat, horzcat(ChanceLevelofFMCoActivityCRMovementOverlap{:}), 'uni', false))}];

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

CoActiveRew = cell(1,sum(cell2mat(NumFields))); ChanceRew = cell(1,sum(cell2mat(NumFields))); MoveOnlyRew = cell(1,sum(cell2mat(NumFields))); fieldcount = 1;
CoActiveRewNum = cell(1,sum(cell2mat(NumFields)));
for animal = 1:length(IsCoActiveMovementRewarded)
    for field = 1:length(IsCoActiveMovementRewarded{animal})
        for ns = 1:length(IsCoActiveMovementRewarded{animal}{field})
            CoActiveRew{fieldcount} = [CoActiveRew{fieldcount}, cellfun(@(x) sum(x)/length(x), IsCoActiveMovementRewarded{animal}{field}{ns})];
            ChanceRew{fieldcount} = [ChanceRew{fieldcount}, ChanceRewardedLevel{animal}{field}{ns}];
        end
        MoveOnlyRew{fieldcount} = [MoveOnlyRew{fieldcount}, sum(IsMoveOnlyRewarded{animal}{field})./length(IsMoveOnlyRewarded{animal}{field})];
        fieldcount = fieldcount+1;
    end
end

% datamat = [{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCoActiveMovementRewarded)}, {cellfun(@nanmedian, ChanceRewardedLevel)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsCompCoActiveMovementRewarded)}, {cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsMoveOnlyRewarded)},{cellfun(@(x) sum(cell2mat(x'))/length(cell2mat(x')), IsNewOnlyRewarded)}];
AllDistMatched = cellfun(@(x,y) [x;y], horzcat(IsMRSDMCoActiveMovementRewarded{:}), horzcat(IsNSDMCoActiveMovementRewarded{:}), 'uni', false);
AllDistMatchedChance = cellfun(@(x,y) [x;y], horzcat(MRSDMChanceRewardedLevel{:}), horzcat(NSDMChanceRewardedLevel{:}), 'uni', false);

datamat = [{cellfun(@nanmedian, CoActiveRew)}, {cellfun(@nanmedian, ChanceRew)},{cellfun(@(x) sum(x)/length(x'), horzcat(IsNewOnlyRewarded{:}))}, {cellfun(@(x) sum(x)/length(x'), horzcat(NewOnlyChanceRewardedLevel{:}))}, {cellfun(@(x) sum(x)/length(x), horzcat(IsMoveOnlyRewarded{:}))}, {cellfun(@(x) sum(x)/length(x), horzcat(MoveOnlyChanceRewardedLevel{:}))},{cellfun(@(x) sum(x)/length(x), horzcat(IsCompCoActiveMovementRewarded{:}))},{cellfun(@(x) sum(x)/length(x), horzcat(FMChanceRewardedLevel{:}))} ,{cellfun(@(x) sum(x)/length(x), AllDistMatched)}, {cellfun(@(x) sum(x)/length(x), AllDistMatchedChance)}];

%%% plot ratios instead
% datamat = [{datamat{1}./datamat{2}}, {datamat{3}./datamat{4}}, {datamat{5}./datamat{6}}, {datamat{7}./datamat{8}}, {datamat{9}./datamat{10}}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

Y = cell(1,length(datamat));
for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
end
ylabel('Fraction of Movements Rewarded')
set(gca, 'XTickLabel', {'CoA with Movement', 'chance', 'NS only', 'chance', 'MRS only', 'chance', 'FMCoA w Movement','chance', 'DistMatched','chance', })
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 20: Timing, Position, and Velocity of activity-containing
%%% movements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%lags = [0, 25, 50, 100, 150, 200, 250, 500]; 

chosen_lag_address = 6;

a = horzcat(ClustActivityStartRelativetoMovement{:});
b = horzcat(ClustActivityStartNormalizedtoMovementLength{:});
for i = 1:length(a)
    if ~isempty(a{i})
        ClustActivityStartTime{i} = cell2mat(cellfun(@cell2mat, a{i}, 'uni', false));
        ClustActivityNormStart{i} = cell2mat(cellfun(@cell2mat, b{i}, 'uni', false));
    end
end

a = horzcat(ShuffledClustActivityStart{:});
b = horzcat(ShuffledActivityStartNormalizedtoMovementLength{:});
for i = 1:length(a)
    if ~isempty(a{i})
        ShuffActivityStartTime{i} = cell2mat(cellfun(@(x) cell2mat(x'), a{i}, 'uni', false)');
        ShuffActivityNormStart{i} = cell2mat(cellfun(@(x) cell2mat(x'), a{i}, 'uni', false)');
    end
end

a = horzcat(FMActivityStartRelativetoMovement{:});
for i = 1:length(a)
    if ~isempty(a{i})
        FMActivityStartTime{i} = cell2mat(cellfun(@cell2mat, a{i}, 'uni', false));
    end
end

a = horzcat(MRSDMActivityStartRelativetoMovement{:});
for i = 1:length(a)
    if ~isempty(a{i})
        MRSDMActivityStartTime{i} = cell2mat(cellfun(@cell2mat, a{i}, 'uni', false));
    end
end

datamat = [{cellfun(@nanmedian, ClustActivityStartTime)},{cellfun(@nanmedian, ShuffActivityStartTime)},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(NSonlyActivityStartRelativetoMovement{:}), 'uni', false))}, {cellfun(@nanmedian, FMActivityStartTime)}, {cellfun(@nanmedian, MRSDMActivityStartTime)},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(NSDMActivityStartRelativetoMovement{:}), 'uni', false))}];

figure; subplot(3,2,1); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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


set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only', 'FM', 'MRSDM', 'NSDM'})

ylabel('Activity Timing Onset wrt Movement (s)')

%%%
a = horzcat(StandardDeviationofClustActivityOnset{:});
b = horzcat(StandardDeviationofNormClustActivityOnset{:});
for i = 1:length(a)
    if ~isempty(a{i})
        savedSD = cell2mat(cellfun(@cell2mat, a{i}, 'uni', false));
        savedSD = savedSD(savedSD>0);
        ClustActivityStartTimeSD{i} = savedSD;
        savedSD = cell2mat(cellfun(@cell2mat, b{i}, 'uni', false));
        savedSD = savedSD(savedSD>0);
        ClustActivityNormStartSD{i} = savedSD;
    end
end

a = horzcat(StandardDeviationofShuffledActivityOnset{:});
b = horzcat(StandardDeviationofNormShuffledActivityOnset{:});
for i = 1:length(a)
    if ~isempty(a{i})
        savedSD = cell2mat(cellfun(@cell2mat, a{i}, 'uni', false));
        savedSD = savedSD(savedSD>0);
        ShuffActivityStartTimeSD{i} = savedSD;
        savedSD = cell2mat(cellfun(@cell2mat, b{i}, 'uni', false));
        savedSD = savedSD(savedSD>0);
        ShuffActivityNormStartSD{i} = savedSD;
    end
end

NSOnlyActivityStartTimeSD = cellfun(@cell2mat, horzcat(StandardDeviationofNSOnlyActivityOnset{:}), 'uni', false);
for i = 1:length(NSOnlyActivityStartTimeSD)
    NSOnlyActivityStartTimeSD{i} = NSOnlyActivityStartTimeSD{i}(NSOnlyActivityStartTimeSD{i}~=0);
end

datamat = [{cellfun(@nanmedian, ClustActivityStartTimeSD)},{cellfun(@nanmedian, ShuffActivityStartTimeSD)},{cellfun(@nanmedian, cellfun(@cell2mat, horzcat(StandardDeviationofNSOnlyActivityOnset{:}), 'uni', false))}];

subplot(3,2,2); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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


set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Activity Timing SD')

%%%
a = horzcat(LeverPositionatClustActivityOnset{:});
b = horzcat(LeverVelocityatClustActivityOnset{:});
ClustLeverPos = [];
ClustLeverPosSD = cell(1,length(a));
ClustLeverVel = [];
ClustLeverVelSD = cell(1,length(b));
for field = 1:length(a)
    for newspine = 1:length(a{field})
        ClustLeverPos = [ClustLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}{newspine}, 'uni', false)')];   %%% Needs to be stored BY SPINE PAIR; i.e. cannot average by field/animal
        samplenumfilt = cellfun(@(x) size(x,1), a{field}{newspine})>1;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}{newspine}(samplenumfilt), 'uni', false)');
        ClustLeverPosSD{field} = [ClustLeverPosSD{field}; posSD];
        ClustLeverVel = [ClustLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}{newspine}, 'uni', false)')];                 %%% Needs to be stored BY SPINE PAIR; i.e. cannot average by field/animal
        velSD = cell2mat(cellfun(@(x) nanstd(x,[],1), b{field}{newspine}(samplenumfilt), 'uni', false)');
        ClustLeverVelSD{field} = [ClustLeverVelSD{field}; velSD];
    end
end

a = horzcat(LeverPositionatShuffledActivityOnset{:});
b = horzcat(LeverVelocityatShuffledActivityOnset{:});
ShuffLeverPos = [];
ShuffLeverPosSD = cell(1,length(a));
ShuffLeverVel = [];
ShuffLeverVelSD = cell(1,length(b));
for field = 1:length(a)
    for newspine = 1:length(a{field})
        ShuffLeverPos = [ShuffLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}{newspine}, 'uni', false)')];
        samplenumfilt = cellfun(@(x) size(x,1), a{field}{newspine})>1;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}{newspine}(samplenumfilt), 'uni', false)');
        ShuffLeverPosSD{field} = [ShuffLeverPosSD{field}; posSD];
        ShuffLeverVel = [ShuffLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}{newspine}, 'uni', false)')];
        velSD = cell2mat(cellfun(@(x) nanstd(x,[],1), b{field}{newspine}(samplenumfilt), 'uni', false)');
        ShuffLeverVelSD{field} = [ShuffLeverVelSD{field}; velSD];
    end
end


a = horzcat(LeverPositionatNSOnlyActivityOnset{:});
b = horzcat(LeverVelocityatNSOnlyActivityOnset{:});
NSOnlyLeverPos = [];
NSOnlyLeverPosSD = cell(1,length(a));
NSOnlyLeverVel = [];
NSOnlyLeverVelSD = cell(1,length(b));
for field = 1:length(a)
    if ~isempty(a{field})
        NSOnlyLeverPos = [NSOnlyLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}, 'uni', false)')];
        samplenumfilt = cellfun(@(x) size(x,1), a{field})>1;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}(samplenumfilt), 'uni', false)');
        NSOnlyLeverPosSD{field} = [NSOnlyLeverPosSD{field}; posSD];
        NSOnlyLeverVel = [NSOnlyLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}, 'uni', false)')];
        velSD = cell2mat(cellfun(@(x) nanstd(x,[],1), b{field}(samplenumfilt), 'uni', false)');
        NSOnlyLeverVelSD{field} = [NSOnlyLeverVelSD{field}; velSD];
    end
end

datamat = [{ClustLeverPos(:,chosen_lag_address)},{ShuffLeverPos(:,chosen_lag_address)},{NSOnlyLeverPos(:,chosen_lag_address)}];

subplot(3,2,3); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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

set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Lever Position')

datamat = [{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ClustLeverPosSD(~cellfun(@isempty,ClustLeverPosSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ShuffLeverPosSD(~cellfun(@isempty,ShuffLeverPosSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSOnlyLeverPosSD(~cellfun(@isempty, NSOnlyLeverPosSD)))}];

subplot(3,2,4); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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

set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Lever Position SD')

datamat = [{ClustLeverVel(:,chosen_lag_address)},{ShuffLeverVel(:,chosen_lag_address)},{NSOnlyLeverVel(:,chosen_lag_address)}];
subplot(3,2,5); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;

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

set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Lever Velocity SD')

set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Lever Velocity')

datamat = [{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ClustLeverVelSD(cellfun(@(x) size(x,1)>1, ClustLeverVelSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ShuffLeverVelSD(cellfun(@(x) size(x,1)>1, ClustLeverVelSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSOnlyLeverVelSD(~cellfun(@isempty, NSOnlyLeverVelSD)))}];

subplot(3,2,6); hold on; 
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

set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})

ylabel('Lever Velocity SD')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 21: Correlation of movements during co-active ANTI-cluster periods;
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

figure; subplot(2,2,1); hold on; 
datamat = [{cellfun(@nanmedian, ClusteredMoveSpineFrequency)}, {cellfun(@nanmedian, ClusteredNewSpineFrequency)}, {cellfun(@nanmedian, OtherSpineFrequencyOnDendswithClusters)}, {cellfun(@nanmedian, OtherSpineFrequencyOnDendswithoutClusters)},];

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
plot(1:3, (maxline+0.01)*ones(1,3), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{3});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

subplot(2,2,2); hold on;

datamat = [{cell2mat(ClusteredMoveSpineDeltaFrequency')}, {cell2mat(OtherSpineDeltaFrequencyOnDendswithClusters')}, {cell2mat(OtherSpineDeltaFrequencyOnDendswithoutClusters')}];
datamat = [{cellfun(@nanmedian, ClusteredMoveSpineDeltaFrequency)}, {cellfun(@nanmedian, OtherSpineDeltaFrequencyOnDendswithClusters)}, {cellfun(@nanmedian, OtherSpineDeltaFrequencyOnDendswithoutClusters)},];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clust. Mov', 'Other on Clust Dends', 'Other'})
xtickangle(gca, 45)
ylabel('Event Frequency (/min)')
title('Delta Frequency of Clusters vs. Other Spines')

subplot(2,2,3)

% datamat = [{cell2mat(ClusteredMoveSpineAmplitude)}, {cell2mat(ClusteredNewSpineAmplitude)}, {cell2mat(OtherSpineAmplitudeOnDendswithClusters)}, {cell2mat(OtherSpineAmplitudeOnDendswithoutClusters)},];
datamat = [{cellfun(@nanmedian, ClusteredMoveSpineAmplitude)}, {cellfun(@nanmedian, ClusteredNewSpineAmplitude)}, {cellfun(@nanmedian, OtherSpineAmplitudeOnDendswithClusters)}, {cellfun(@nanmedian, OtherSpineAmplitudeOnDendswithoutClusters)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clust. Mov', 'Clust. New', 'Other on Clust Dends', 'Other'})
xtickangle(gca, 45)
ylabel('Event Amplitude')
title('Amplitude of Clusters vs. Other Spines')

maxline = max([nanmax(datamat{1}), nanmax(datamat{2})]);
plot(1:3, (maxline+0.01)*ones(1,3), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{3});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

subplot(2,2,4)

% datamat = [{cell2mat(ClusteredMoveSpineDeltaAmplitude)}, {cell2mat(OtherSpineDeltaAmplitudeOnDendswithClusters)}, {cell2mat(OtherSpineDeltaAmplitudeOnDendswithoutClusters)},];
datamat = [{cellfun(@nanmedian, ClusteredMoveSpineDeltaAmplitude)}, {cellfun(@nanmedian, OtherSpineDeltaAmplitudeOnDendswithClusters)}, {cellfun(@nanmedian, OtherSpineDeltaAmplitudeOnDendswithoutClusters)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', lgreen); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clust. Mov', 'Other on Clust Dends', 'Other'})
xtickangle(gca, 45)
ylabel('Event Amplitude')
title('Delta Amplitude of Clusters vs. Other Spines')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 22: Fraction of Dendrites showing both types of spine dynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FractionofDendswithBothDynamics = sum(cell2mat(DendsWithBothDynamics))/sum(NumberofImagedDendrites);
FractionofDendswithBothClustDynamics = sum(cell2mat(DendsWithBothClustDynamics))/sum(NumberofImagedDendrites);

NewSpinesOrganizedByDendritesImaged = cellfun(@(x) horzcat(x{:}), NewSpinesbyDendrite, 'uni', false);   %%% "NewSpinesbyDendrite" organizes by animal, >mindFoFtoconsiderCoActive, then dendrite; this removes the field component and concatenates all dendrites imaged by animal
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