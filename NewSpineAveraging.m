function NewSpineAnalysis(varargin)

experimentnames = varargin;

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd('C:\Users\Komiyama\Desktop\Output Data')
end

for i = 1:length(experimentnames)
    targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
    load(targetfile)
    eval(['currentdata = ',targetfile, ';'])
    
    NumFields = length(currentdata.SpineDynamics);
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
    LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions{i} = cell2mat(currentdata.LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions);
    NewSpinesCorrwithDistanceMatchedNonEarlyMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithDistanceMatchedNonEarlyMRSs);
    MovementSpineDistanceMatchedControlCorrelation{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementSpineDistanceMatchedControlCorrelation(~cell2mat(cellfun(@isempty, currentdata.MovementSpineDistanceMatchedControlCorrelation, 'uni', false))), 'uni', false));
    TaskCorrelationofClusteredNewSpines{i} = cell2mat(currentdata.TaskCorrelationofClusteredNewSpines);
    NewSpinesCorrwithNearbyEarlyMRSs{i} = cell2mat(currentdata.NewSpinesCorrwithNearbyEarlyMRSs);
    TaskCorrelationofNearbyEarlyMRSs{i} = cell2mat(currentdata.TaskCorrelationofNearbyEarlyMRSs);
    MovementReliabilityofNearbyEarlyMRSs{i} = cell2mat(currentdata.MovementReliabilityofNearbyEarlyMRSs');
    MovementReliabilityofOtherMoveSpines{i} = cell2mat(currentdata.MovementReliabilityofOtherMoveSpines');
    
    DistancesBetweenNewSpinesandLateMovementSpines{i} = cell2mat(currentdata.DistancesBetweenNewSpinesandMovementSpines);
    LateCorrfNewSpinesandMovementSpinefromLateSessions{i} = cell2mat(currentdata.LateCorrfNewSpinesandNearestMovementSpinefromLateSessions);
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
    
    SuccessCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.SuccessCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.SuccessCentricClusterCorrelation, 'uni', false))),'uni', false));
    SuccessCentricDistanceMatchedCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.SuccessCentricDistanceMatchedCorrelation(~cell2mat(cellfun(@isempty, currentdata.SuccessCentricDistanceMatchedCorrelation, 'uni', false))),'uni', false));
    SuccessCentricDistanceMatchedCorrelationforMRS{i} = cell2mat(cellfun(@cell2mat,currentdata.SuccessCentricDistanceMatchedCorrelationforMRS(~cell2mat(cellfun(@isempty, currentdata.SuccessCentricDistanceMatchedCorrelationforMRS, 'uni', false))),'uni', false));
    SuccessCentricCorrelationofAllOtherSpines{i} = cell2mat(currentdata.SuccessCentricCorrelationofAllOtherSpines');
    FailureCentricClusterCorrelation{i} = cell2mat(cellfun(@cell2mat, currentdata.FailureCentricClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.FailureCentricClusterCorrelation, 'uni', false))), 'uni', false));
    SuccessCentricAntiClusterCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.SuccessCentricAntiClusterCorrelation(~cell2mat(cellfun(@isempty, currentdata.SuccessCentricAntiClusterCorrelation, 'uni', false))),'uni', false));
    SuccessCentricDistanceMatchedtoAntiClustCorrelation{i} = cell2mat(cellfun(@cell2mat,currentdata.SuccessCentricDistanceMatchedtoAntiClustCorrelation(~cell2mat(cellfun(@isempty, currentdata.SuccessCentricDistanceMatchedtoAntiClustCorrelation, 'uni', false))),'uni', false));
    
    CombinedClusterActivityCorrwithMovement{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithMovement(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithMovement, 'uni', false))),'uni', false));
    CombinedClusterActivityCorrwithSuccess{i} = cell2mat(cellfun(@cell2mat,currentdata.CombinedClusterActivityCorrwithSuccess(~cell2mat(cellfun(@isempty, currentdata.CombinedClusterActivityCorrwithSuccess, 'uni', false))),'uni', false));
    ClusterMovementReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterMovementReliability, 'uni', false))),'uni', false));
    ClusterSuccessReliability{i} = cell2mat(cellfun(@cell2mat,currentdata.ClusterSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ClusterSuccessReliability, 'uni', false))),'uni', false));
    ControlPairMovementReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairMovementReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairMovementReliability, 'uni', false))), 'uni', false));
    ControlPairSuccessReliability{i} = cell2mat(cellfun(@cell2mat, currentdata.ControlPairSuccessReliability(~cell2mat(cellfun(@isempty, currentdata.ControlPairSuccessReliability, 'uni', false))), 'uni', false));
    
    MovementCorrelationwithCoActiveClusters{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationwithCoActiveClusters(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationwithCoActiveClusters, 'uni', false))), 'uni', false));
    CoActiveClusterMovementsCorrelationwithModelMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.CoActiveClusterMovementsCorrelationwithModelMovement(~cell2mat(cellfun(@isempty, currentdata.CoActiveClusterMovementsCorrelationwithModelMovement, 'uni', false))), 'uni', false));
    MovementCorrelationofAllOtherMovements{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationofAllOtherMovements(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationofAllOtherMovements, 'uni', false))), 'uni', false));
    AllOtherMovementsCorrelationwithModelMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.AllOtherMovementsCorrelationwithModelMovement(~cell2mat(cellfun(@isempty, currentdata.AllOtherMovementsCorrelationwithModelMovement, 'uni', false))), 'uni', false));
    MovementCorrelationofFrequencyMatchedPairs{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationofFrequencyMatchedPairs(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationofFrequencyMatchedPairs, 'uni', false))), 'uni', false));
    FrequencyMatchedPairMovementsCorrelationwithModelMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.FrequencyMatchedPairMovementsCorrelationwithModelMovement(~cell2mat(cellfun(@isempty, currentdata.FrequencyMatchedPairMovementsCorrelationwithModelMovement, 'uni', false))), 'uni', false));
    
    HCPClusteredNewSpineCorrwithMovement{i} = cell2mat(currentdata.HCPClusteredNewSpineCorrwithMovement);
    HCPClusteredNewSpineCorrwithSuccess{i} = cell2mat(currentdata.HCPClusteredNewSpineCorrwithSuccess);
    HCPCorrwithMovement{i} = cell2mat(currentdata.HCPCorrwithMovement);
    HCPCorrwithSuccess{i} = cell2mat(currentdata.HCPCorrwithSuccess);
    CoActiveHCPClusterCorrwithMovement{i} = cell2mat(currentdata.CoActiveHCPClusterCorrwithMovement);
    CoActiveHCPClusterCorrwithSuccess{i} = cell2mat(currentdata.CoActiveHCPClusterCorrwithSuccess);
    SuccessCentricHCPClusterCorrelation{i} = cell2mat(currentdata.SuccessCentricHCPClusterCorrelation);
    MovementCorrelationwithCoActiveHCPClusters{i} = cell2mat(currentdata.MovementCorrelationwithCoActiveHCPClusters);
    MovementCorrelationofAllOtherNonHCPMovements{i} = cell2mat(currentdata.MovementCorrelationofAllOtherNonHCPMovements);
    MovementCorrelationofHCPComparatorSpines{i} = cell2mat(currentdata.MovementCorrelationofHCPComparatorSpines);
    
    MovementCorrelationwithCoActiveAntiClusters{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationwithCoActiveAntiClusters(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationwithCoActiveClusters, 'uni', false))), 'uni', false));
    CoActiveAntiClusterMovementsCorrelationwithModelMovement{i} = cell2mat(cellfun(@cell2mat, currentdata.CoActiveAntiClusterMovementsCorrelationwithModelMovement(~cell2mat(cellfun(@isempty, currentdata.CoActiveClusterMovementsCorrelationwithModelMovement, 'uni', false))), 'uni', false));
    MovementCorrelationofAllOtherMovementsElimVersion{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationofAllOtherMovementsElimVersion(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationofAllOtherMovementsElimVersion, 'uni', false))), 'uni', false));
    AllOtherMovementsCorrelationwithModelMovementElimVersion{i} = cell2mat(cellfun(@cell2mat, currentdata.AllOtherMovementsCorrelationwithModelMovementElimVersion(~cell2mat(cellfun(@isempty, currentdata.AllOtherMovementsCorrelationwithModelMovementElimVersion, 'uni', false))), 'uni', false));
    MovementCorrelationofFrequencyMatchedPairsElimVersion{i} = cell2mat(cellfun(@cell2mat, currentdata.MovementCorrelationofFrequencyMatchedPairsElimVersion(~cell2mat(cellfun(@isempty, currentdata.MovementCorrelationofFrequencyMatchedPairsElimVersion, 'uni', false))), 'uni', false));
    FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion{i} = cell2mat(cellfun(@cell2mat, currentdata.FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion(~cell2mat(cellfun(@isempty, currentdata.FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion, 'uni', false))), 'uni', false));

    ClusteredMoveSpineFrequency{i} = cell2mat(currentdata.ClusteredMoveSpineFrequency');
    ClusteredNewSpineFrequency{i} = cell2mat(currentdata.ClusteredNewSpineFrequency');
    OtherSpineFrequencyOnDendswithClusters{i} = cell2mat(currentdata.OtherSpineFrequencyOnDendswithClusters');
    OtherSpineFrequencyOnDendswithoutClusters{i} = cell2mat(currentdata.OtherSpineFrequencyOnDendswithoutClusters');
    
    MovementTracesOccurringwithClusterCoActivity{i} = currentdata.MovementTracesOccurringwithClusterCoActivity';
    IsMovementRewardedLate{i} = currentdata.IsMovementRewardedLate;
    IsCoActiveMovementRewarded{i} = currentdata.IsCoActiveMovementRewarded;
    ChanceRewardedLevel{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceRewardedLevel(~cell2mat(cellfun(@isempty, currentdata.ChanceRewardedLevel, 'uni', false))), 'uni', false));
    
    MovementTracesOccuringwithAntiClusterCoActivity{i} = currentdata.MovementTracesOccurringwithAntiClusterCoActivity';
    IsMovementRewardedEarly{i} = currentdata.IsMovementRewardedEarly;
    IsCoActiveAntiClusterMovementRewarded{i} = currentdata.IsCoActiveAntiClusterMovementRewarded;
    ChanceRewardedLevelElimVersion{i} = cell2mat(cellfun(@cell2mat, currentdata.ChanceRewardedLevelElimVersion(~cell2mat(cellfun(@isempty, currentdata.ChanceRewardedLevelElimVersion, 'uni', false))), 'uni', false));
    
    DendsWithBothDynamics{i} = cell2mat(currentdata.DendsWithBothDynamics);
    DendsWithBothClustDynamics{i} = cell2mat(currentdata.DendsWithBothClustDynamics);

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

shuffnum = 1000;
bootstrpnum = shuffnum;
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
        randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        [dendLength, longeststretch] = max(max(randDendDistances,[],2));
        simNewSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
        %%%
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        while ~any(EarlyMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(randDendDistances,[],2));
            simNewSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1);
        end
        %%%
        mockearlynewspinedistribution{i}(j) = abs(nanmin(randDendDistances(longeststretch, EarlyMovementSpines))-simNewSpine);
        %%%%
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);      %%% 'end' index corresponds to final session'
        while ~any(LateMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(randDendDistances,[],2));
            simNewSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);
        end
        mocklatenewspinedistribution(j) =abs(nanmin(randDendDistances(longeststretch, LateMovementSpines))-simNewSpine);
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
        randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
        [dendLength, longeststretch] = max(max(randDendDistances,[],2));
        simElimSpine = randi([1,2*round(dendLength)])/2; %%% The 2x multiplier is to provide 0,5um precision
        EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); %%% 1 index corresponds to early session
        while ~any(EarlyMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(randDendDistances,[],2));
            simElimSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            EarlyMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,1); 
        end
        mockearlyelimspinedistribution(j) = abs(nanmin(randDendDistances(longeststretch, EarlyMovementSpines))-simElimSpine);
        LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);%%% 'end' index corresponds to final session
        while ~any(LateMovementSpines)
            randAnimal = randi([1,length(AllDendriteDistances)],1);
            randField = randi([1,length(AllDendriteDistances{randAnimal})]);
            randDend = randi([1,length(SpineDendriteGrouping{randAnimal}{randField})]);
            spinesfromrandDend = SpineDendriteGrouping{randAnimal}{randField}{randDend}(1:end);
            randDendDistances = AllDendriteDistances{randAnimal}{randField}(spinesfromrandDend(1):spinesfromrandDend(end), spinesfromrandDend(1):spinesfromrandDend(end));
            [dendLength, longeststretch] = max(max(randDendDistances,[],2));
            simElimSpine = randi([1,2*round(dendLength)])/2; %%% THe 2x multiplier is to provide 0,5um precision
            LateMovementSpines = AllMovementSpines{randAnimal}{randField}(spinesfromrandDend,end);
        end
        mocklateelimspinedistribution(j) = abs(nanmin(randDendDistances(longeststretch, LateMovementSpines))-simElimSpine);
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

figure; subplot(1,3,1);hold on;
NS = histogram(cell2mat(NewSpinesMaxCorr'),25); title('New Spines Max Corr. Dist.'); xlim([0 1]);
plot(nanmedian(cell2mat(NewSpinesMaxCorr'))*ones(1,11),0:(max(hist(cell2mat(NewSpinesMaxCorr')))/10):max(hist(cell2mat(NewSpinesMaxCorr'))), '--r')
text(nanmedian(cell2mat(NewSpinesMaxCorr')), max(hist(cell2mat(NewSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(NewSpinesMaxCorr')))])
ES = histogram(cell2mat(ElimSpinesMaxCorr'),25);
legend([NS, ES], {'New Spines', 'Elim Spines'})
subplot(1,3,2);hold on;
MaxCorrs = cell2mat(NewSpinesMaxCorr');
NSSD = histogram(MaxCorrs(~isnan(distancetoMaxCorrPartner)),25); %%% Perform the same calculations for only spines on the same dendrites
 title('New Spines Max Corr. Dist.'); xlim([0 1]);
% plot(nanmedian(cell2mat(NewSpinesMaxCorr'))*ones(1,11),0:(max(hist(cell2mat(NewSpinesMaxCorr')))/10):max(hist(cell2mat(NewSpinesMaxCorr'))), '--r')
% text(nanmedian(cell2mat(NewSpinesMaxCorr')), max(hist(cell2mat(NewSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(NewSpinesMaxCorr')))])
subplot(1,3,3); hold on
histogram(cell2mat(OtherSpinesMaxCorr'),25); title('All Other Spines Max Corr. Dist.'); xlim([0 1])
plot(nanmedian(cell2mat(OtherSpinesMaxCorr'))*ones(1,11),0:(max(hist(cell2mat(OtherSpinesMaxCorr')))/10):max(hist(cell2mat(OtherSpinesMaxCorr'))), '--r')
text(nanmedian(cell2mat(OtherSpinesMaxCorr')), max(hist(cell2mat(OtherSpinesMaxCorr'))), [num2str(nanmedian(cell2mat(OtherSpinesMaxCorr')))])

p = Chi2DiffProportions(cell2mat(NewSpinesMaxCorr'), cell2mat(OtherSpinesMaxCorr'), 0.1);

% if p<0.05
%     disp('Hey')
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 10: Dynamic Spines Correlation with Nearby Movement-related
%%% spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; a = subplot(2,2,1); hold on; 
plot(cell2mat(DistancesBetweenNewSpinesandEarlyMovementSpines), cell2mat(LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions), '.k', 'Markersize', 14)
title('New spines vs. Early Movement Spines')

b = subplot(2,2,2); 
plot(cell2mat(DistancesBetweenNewSpinesandLateMovementSpines), cell2mat(LateCorrfNewSpinesandMovementSpinefromLateSessions), '.k', 'Markersize', 14)
title('New spines vs. Late Movement Spines')

c = subplot(2,2,3);
plot(cell2mat(DistancesBetweenElimSpinesandEarlyMovementSpines), cell2mat(CorrelationsofElimSpinesandEarlyMovementSpines), '.k', 'Markersize', 14)
title('Elim spines vs. Early movement Spines')
linkaxes([a,b,c], 'xy')

subplot(2,2,4)
datamat = [{cell2mat(NewSpinesCorrwithNearbyEarlyMRSs)},{cell2mat(NewSpinesCorrwithNearbyLateMRSs)},{cell2mat(ElimSpinesCorrwithNearbyMRSs)}, {cell2mat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)}, {cell2mat(MovementSpineDistanceMatchedControlCorrelation)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
bootstrpnum = shuffnum;
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel',{'New Spines-Nearby Early MRS','New Spines-Nearby Late MRS', 'Elim Spines-Nearby Early MRS','Dist-matched for NS', 'Dist-matched for MRS'})
xtickangle(gca, 45)
title('Max Correlation with Nearby MRSs')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 11: Dynamic Spines Correlation with Nearby Movement-related
%%% spines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; 
subplot(1,2,1); hold on;
datamat = [{cell2mat(LateCorrfNewSpinesandNearestMovementSpinefromEarlySessions)}, {cell2mat(NewSpinesCorrwithDistanceMatchedNonEarlyMRSs)},{cell2mat(MovementSpineDistanceMatchedControlCorrelation)}];
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
datamat = [{cell2mat(LateCorrfNewSpinesandMovementSpinefromLateSessions)}, {cell2mat(NewSpinesCorrwithDistanceMatchedNonLateMRSs)}];
bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', gray')
for i = 1:length(datamat)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', alphaforbootstrap);
%     plot(ones(1,numel(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'k');
end
set(gca, 'XTick', 1:length(datamat), 'XTickLabel', {'New Sp. vs. Near MRS', 'New Sp. vs. Dist-matched nMRS'})
xtickangle(gca, 45)
title('New Spines Correlation with Closest lMRS')
[p,~] = ranksum(datamat{1},datamat{2});
% if p<0.05 
%     plot(1:2, (max(nanmean(cell2mat(datamat)))/10)*ones(1,2), 'k')
% end

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
%%% Figure 13: Dynamic Spines MRS Behavior Correlation
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
%%% Figure 16: Correlation of clustered spines DURING successful presses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on

subplot(1,2,1)

datamat = [{cell2mat(SuccessCentricClusterCorrelation)}, {cell2mat(SuccessCentricDistanceMatchedCorrelation)}, {cell2mat(SuccessCentricDistanceMatchedCorrelationforMRS)}, {cell2mat(SuccessCentricCorrelationofAllOtherSpines')}, {cell2mat(FailureCentricClusterCorrelation)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Clusters', 'Dist. Matched to New Spine', 'Dist matched to MRS', 'All other spines', 'Clusters with failure'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Cluster Correlation During Successful Presses')

maxline = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
plot(1:2, (maxline+0.01)*ones(1,2), 'k', 'Linewidth', 2)

[p,~] = ranksum(datamat{1},datamat{2});

if p<0.05
    text(1.4, maxline+0.05, ['* p =', num2str(p)])
else
    text(1.4, maxline+0.05, ['ns, p = ', num2str(p)])
end

subplot(1,2,2)

datamat = [{cell2mat(SuccessCentricAntiClusterCorrelation)}, {cell2mat(SuccessCentricDistanceMatchedtoAntiClustCorrelation)}];

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
%%% Figure 18: Correlation of movements during co-active cluster periods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on
subplot(1,3,1)
datamat = [{cell2mat(MovementCorrelationwithCoActiveClusters)}, {cell2mat(MovementCorrelationofAllOtherMovements)}, {cell2mat(MovementCorrelationofFrequencyMatchedPairs)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'With CoActive Clusters', 'Without', 'Freq matched pairs'})
xtickangle(gca, 45)
ylabel('Correlation')
title('Correlation of Movements during CoActive Cluster Periods')

maxline1 = max([nanmedian(datamat{1}), nanmedian(datamat{2})]);
maxline2 = max([nanmedian(datamat{1}), nanmedian(datamat{3})]);
plot(1:2, (maxline1+0.01)*ones(1,2), 'k', 'Linewidth', 2)
plot(1:3, (maxline2+0.01)*ones(1,3), 'k', 'Linewidth', 2)

[p(1),~] = ranksum(datamat{1},datamat{2});
[p(2),~] = ranksum(datamat{1},datamat{3});

if p(1)<0.05
    text(1.4, maxline1+0.075, ['* p =', num2str(p(1))])
else
    text(1.4, maxline1+0.075, ['ns, p = ', num2str(p(1))])
end

if p(2)<0.05
    text(1.9, maxline2+0.125, ['* p = ', num2str(p(2))])
else
    text(1.9, maxline2+0.125, ['ns, p = ', num2str(p(2))])
end

%%% Correlation with model movement (i.e. average movement from final
%%% session of training 

subplot(1,3,2)
datamat = [{cell2mat(CoActiveClusterMovementsCorrelationwithModelMovement)}, {cell2mat(AllOtherMovementsCorrelationwithModelMovement)}, {cell2mat(FrequencyMatchedPairMovementsCorrelationwithModelMovement)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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
datamat = [{cellfun(@nanmean, IsCoActiveMovementRewarded)}, {cellfun(@nanmean, cellfun(@(x) cell2mat(x'), IsMovementRewardedLate, 'uni', false))}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

for i = 1:length(datamat)
    plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
    Y = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
    line([i,i], [Y(1), Y(2)], 'linewidth', 0.5, 'color', 'r');
end
set(gca, 'XTick', [1:length(datamat)])
set(gca, 'XTickLabel', {'Co-active cluster periods', 'shuffled'})
ylabel('% Rewarded')
title('Likelihood of co-active cluster movements being rewarded')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 19: Correlation of movements during co-active ANTI-cluster periods;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% New Spines
useabsval = 0;
figure;hold on
subplot(1,3,1)
datamat = [{cell2mat(MovementCorrelationwithCoActiveAntiClusters)}, {cell2mat(MovementCorrelationofAllOtherMovementsElimVersion)}, {cell2mat(MovementCorrelationofFrequencyMatchedPairsElimVersion)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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
datamat = [{cell2mat(CoActiveAntiClusterMovementsCorrelationwithModelMovement)}, {cell2mat(AllOtherMovementsCorrelationwithModelMovementElimVersion)}, {cell2mat(FreqMatchedPairMovementsCorrelationwithModelMovementElimVersion)}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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
datamat = [{cellfun(@nanmean, IsCoActiveAntiClusterMovementRewarded)}, {cellfun(@nanmean, cellfun(@(x) cell2mat(x'), IsMovementRewardedEarly, 'uni', false))}];

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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

bar(1:length(datamat), cell2mat(cellfun(@nanmedian, datamat, 'uni', false)), 'FaceColor', purple); hold on;

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