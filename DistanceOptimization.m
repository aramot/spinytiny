

record_count = 1;

h = waitbar(0, 'Collecting animal information');

for distance_cutoff = 1:50
    
    waitbar(record_count/length(experimentnames), h, ['Running cutoff distance = ', num2str(distance_cutoff)]);
    
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
    FractionMRSsonDendswithNS = []; FractionMRSsonDendswithoutNS = [];
    nonNSClosestEarlyMRS =[]; nonNSClosestEarlynonMRS = []; nonNS_Range = []; nonNS_NearbySpineCount = []; nonNS_NearbySpineDensity = []; nonNSEarlyMRSEnvironment = []; nonNSEarlynonMRSEnvironment = [];
    
    allspinecorrlist = []; allspinedistlist = [];
    NStoAllSpinesDistances = []; AllEarlyMRSwrtNSs = []; AllPrevSeshMRSwrtNSs = []; AllLateMRSwrtNSs = [];
    AllNewSpinetoEarlyMRSDistances = []; AllNewSpinetoMRSDistances = []; AllNewSpinetonMRSDistances = []; NSAllSpineDensity = []; NSMRSDensity = []; NSnonMRSDensity = []; ClosestEarlyMRS = []; ClosestEarlynonMRS = []; ClosestPrevSeshMRS = []; ClosestLateMRS = []; ClosestPersMRS = []; ClosestGainedMRS = []; PrevSeshMRSdistlistwrtNS = [];
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
    NSMRS_record{record_count} = NearbyEarlyMRSEnvironment;
    NSnonMRS_record{record_count} = NearbyEarlynonMRSEnvironment;
    nonNSMRS_record{record_count} = nonNSEarlyMRSEnvironment;
    nonNSnonMRS_record{record_count} = nonNSEarlynonMRSEnvironment;
    NS_Range_record{record_count} = NS_Range; 
    nonNS_Range_record{record_count} = nonNS_Range;
    specificity_p(record_count) = ranksum((NSMRS_record{record_count}./NSnonMRS_record{record_count}), (nonNSMRS_record{record_count}./nonNSnonMRS_record{record_count}));
    record_count = record_count+1;
end
delete(h)

figure;
subplot(1,2,1); plot(cellfun(@nanmedian, NSMRS_record), 'color', lgreen, 'linewidth', 2)
hold on; plot(cellfun(@nanmedian, nonNSMRS_record), 'color', gray, 'linewidth', 2)
subplot(1,2,2); plot(cellfun(@nanmedian, NSnonMRS_record), 'color', dred, 'linewidth', 2)
hold on; plot(cellfun(@nanmedian, nonNSnonMRS_record), 'color', gray, 'linewidth', 2)

figure; hold on; plot(cellfun(@nanmedian, NSMRS_record)-cellfun(@nanmedian, nonNSMRS_record), 'color', lgreen, 'linewidth', 2)
plot(cellfun(@nanmedian, NSnonMRS_record)-cellfun(@nanmedian, nonNSnonMRS_record), 'color', dred, 'linewidth', 2)
plot((cellfun(@nanmedian, NSMRS_record)-cellfun(@nanmedian, nonNSMRS_record))-(cellfun(@nanmedian, NSnonMRS_record)-cellfun(@nanmedian, nonNSnonMRS_record)), 'color', blue, 'linewidth', 2)
title('Difference')

figure; hold on; plot(cellfun(@nanmedian, NSMRS_record)./cellfun(@nanmedian, nonNSMRS_record), 'color', lgreen, 'linewidth', 2)
plot(cellfun(@nanmedian, NSnonMRS_record)./cellfun(@nanmedian, nonNSnonMRS_record), 'color', dred, 'linewidth', 2)
plot((cellfun(@nanmedian, NSMRS_record)./cellfun(@nanmedian, nonNSMRS_record))-(cellfun(@nanmedian, NSnonMRS_record)./cellfun(@nanmedian, nonNSnonMRS_record)), 'color', blue, 'linewidth', 2)
title('Ratio')

figure; plot(specificity_p)
ylabel('P Value')
xlabel('Distance Cutoff')

