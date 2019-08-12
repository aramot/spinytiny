function [HCSs, Clustered, CorrelationofClusters, FarClustered, CausalClustered] = binaryclusterclass(Data, Correlations, Causal)
            

%%% Find all values that are greater than the cluster threshold

ClusterThresh = 0.5;       %%% BASED ON THE 75th PERCENTILE OF CORRELATIONS OF MOVEMENT-RELATED SPINES (considering all data together); UPDATE AS NECESSARY

HCSnum = 0;
Clustnum = 0;
FarClustnum = 0;

Correlations(Correlations==1) = nan; Correlations = round(Correlations.*100)/100; %%% Round to the nearest hundredths place
Causal(Causal==1) = nan; Causal = round(Causal.*100)/100;

[row, col] = find(triu(Correlations)>=ClusterThresh);
[Crow, Ccol] = find(triu(Causal)>=ClusterThresh);
Dendind = [];
CDendind = [];

DendNum = Data.NumberofDendrites;
addresses = cell(1,DendNum);
faraddresses = {};
Caddresses = cell(1,DendNum);
farcount = 1;


%%% 'Synapse only' clusters

%%% Find the parent dendrites of highly correlated spines
HCSs = {[]};
Clustered = {[]};
for r = 1:length(row)
    for D = 1:DendNum
        if ~isempty(find(Data.SpineDendriteGrouping{D} == row(r))) && ~isempty(find(Data.SpineDendriteGrouping{D} == col(r)))   %%% Spines on the same dendrite
            Dendind = [Dendind; D];
            addresses{D} = [addresses{D}; row(r), col(r)];
        elseif xor(~isempty(find(Data.SpineDendriteGrouping{D} == row(r))), ~isempty(find(Data.SpineDendriteGrouping{D} == col(r)))) %%% Spines on separate dendrites
            faraddresses{farcount} = [row(r), col(r)];
            farcount = farcount+1;
        end
    end
end

usedDend = unique(Dendind);

for A = 1:length(addresses)
    clust = [];
    if ~isempty(addresses{A})
        if length(unique(addresses{A}))>2
            spines = unique(addresses{A});
            
            for root = 1:length(spines)
                clust{root} = spines(root);
                otherspines = setdiff(spines,spines(root));
                for s = 1:length(otherspines)
                    if sum(Correlations(clust{root}, otherspines(s))>=ClusterThresh)==length(clust{root})  %%% If all the indices in the 'clust' array yield correlation values > ClustThresh, then it should return all logical == 1, so the sum should be the same as the length of the 'clust' array
                        clust{root} = [clust{root}; otherspines(s)];
                    end
                end
            end
            
            %%% search for identical clusters, then remove them
            for i = 1:length(clust)
                for j = 1:length(clust)
                    if i ~= j && ~isempty(clust{i}) && ~isempty(clust{j}) && length(clust{i}) == length(union(clust{i},clust{j})) %%% If cluster n and cluster n+1 are both populated and the length of cluster n == length of the union of n and n+1, then the groups are identical, as no new indices are added from the union
                        clust{j} = [];
                    end
                end
            end
            
            clust = clust(~cellfun(@isempty, clust));
            
            %%% Add contingency to remove spines that appear in multiple
            %%% clusters
            
            if length(clust)>1
                combs = nchoosek(1:length(clust),2); 
                for i = 1:size(combs,1)
                    if ~isempty(find(ismember(clust{combs(i,1)}, clust{combs(i,2)}),1))
%                         if length(clust{combs(i,1)})>length(clust{combs(i,2)})
%                             clust{combs(i,2)} = setdiff(clust{combs(i,2)},clust{combs(i,2)}(find(ismember(clust{combs(i,2)},clust{combs(i,1)}))));
%                         else
%                             clust{combs(i,1)} = setdiff(clust{combs(i,1)},clust{combs(i,1)}(find(ismember(clust{combs(i,1)},clust{combs(i,2)}))));
%                         end
                        clust{combs(i,1)} = union(clust{combs(i,1)},clust{combs(i,2)});
                        clust{combs(i,2)} = [];
                    end
                end

                clust = clust(cell2mat(cellfun(@(x) length(x)>1, clust, 'uni', false)));    %%% Remove clusters that only have one spine remaining
            else
            end
            
            %%% Add distance contingency
            DistanceMax = 20;
%             
            a = Data.DistanceHeatMap;
            b = a';
            a(isnan(a)) = b(isnan(a));
            Distances = a;
            clust2 = clust;
            
            toofar = [];
            for i = 1:length(clust)
                for j = 1:length(clust{i})
                    partnerdist = [];
                    for k = 1:length(clust{i})
                        partnerdist(k) = Distances(clust{i}(j), clust{i}(k));
                    end
                    if min(partnerdist) > DistanceMax
                        toofar = [toofar; clust{i}(j)];
                    end
                end
                clust2{i} = setdiff(clust2{i},toofar);
                if length(clust2{i})<2
                    clust2{i} = [];
                end
            end
            
            clust2 = clust2(~cellfun(@isempty, clust2));
            

            HCSs(HCSnum+1:HCSnum+sum(~cellfun(@(x) isempty(x), clust))) = clust(~cellfun(@(x) isempty(x), clust));
            CorrelationofClusters(HCSnum+1:HCSnum+sum(~cellfun(@(x) isempty(x), clust))) = cellfun(@(x) nanmean(nanmean(Correlations(x,x))), clust(~cellfun(@(x) isempty(x), clust)));
            HCSnum = HCSnum+sum(~cellfun(@(x) isempty(x), clust));
       
            Clustered(Clustnum+1:Clustnum+sum(~cellfun(@(x) isempty(x), clust2))) = clust2(~cellfun(@(x) isempty(x), clust2));
            CorrelationofClusters(Clustnum+1:Clustnum+sum(~cellfun(@(x) isempty(x), clust2))) = cellfun(@(x) nanmean(nanmean(Correlations(x,x))), clust2(~cellfun(@(x) isempty(x), clust2)));
            Clustnum = Clustnum+sum(~cellfun(@(x) isempty(x), clust2));
            
        else
            spines = unique(addresses{A});
            HCSs{HCSnum+1} = spines';
            CorrelationofClusters(HCSnum+1) = nanmean(nanmean(Correlations(spines,spines)));
            HCSnum = HCSnum+1;
            
            Clustered{Clustnum+1} = spines';
            Clustnum = Clustnum+1;
        end
    else
        HCSs{HCSnum+1} = [];
        Clustered{Clustnum+1} = [];
        CorrelationofClusters(HCSnum+1) = nan;
    end
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Highly correlated spines on different dendrites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FarClustered = {[]};

for A = 1:length(faraddresses)
    clust = [];
    if ~isempty(faraddresses{A})
        if length(unique(faraddresses{A}))>2
            farspines = unique(faraddresses{A});
            
            for root = 1:length(farspines)
                farclust{root} = farspines(root);
                otherspines = setdiff(farspines,farspines(root));
                for s = 1:length(otherspines)
                    if sum(Correlations(farclust{root}, otherspines(s))>=ClusterThresh)==length(farclust{root})  %%% If all the indices in the 'clust' array yield correlation values > ClustThresh, then it should return all logical == 1, so the sum should be the same as the length of the 'clust' array
                        farclust{root} = [farclust{root}; otherspines(s)];
                    end
                end
            end
            
            %%% search for identical clusters, then remove them
            for i = 1:length(farclust)
                for j = 1:length(farclust)
                    if i ~= j && ~isempty(farclust{i}) && ~isempty(farclust{j}) && length(farclust{i}) == length(union(farclust{i},farclust{j}))
                        farclust{j} = [];
                    end
                end
            end
            
            farclust = farclust(~cellfun(@isempty, farclust));
            

            FarClustered(FarClustnum+1:FarClustnum+sum(~cellfun(@(x) isempty(x), farclust))) = farclust(~cellfun(@(x) isempty(x), farclust));
            FarClustnum = FarClustnum+sum(~cellfun(@(x) isempty(x), farclust));

            
        else
            farspines = unique(faraddresses{A});
            FarClustered{FarClustnum+1} = farspines';
            FarClustnum = FarClustnum+1;
        end
    else
        FarClustered{FarClustnum+1} = [];
    end
end

%%% Causal clusters

HCSnum = 1;

CausalClustered = {[]};
for Cr = 1:length(Crow)
    for D = 1:DendNum
        if ~isempty(find(Data.SpineDendriteGrouping{D} == Crow(Cr)))
            CDendind = [CDendind; D];
            Caddresses{D} = [Caddresses{D}; Crow(Cr), Ccol(Cr)];
        end
    end
end

CusedDend = unique(CDendind);


for A = 1:length(Caddresses)
    if ~isempty(Caddresses{A})
        if size(Caddresses{A},1)>1
            spines = unique(Caddresses{A});
            clust = spines(1);
            for s = 2:length(spines)
                if sum(Causal(clust, spines(s))>ClusterThresh)==length(clust)  %%% If all the indices in the 'clust' array yield correlation values > 0.5, then it should return all logical == 1, so the sum should be the same as the length of the 'clust' array
                    clust = [clust; spines(s)];
                end
            end
            if length(clust)>1
                CausalClustered{HCSnum} = clust;
                HCSnum = HCSnum+1;
            end
            while length(clust)<length(spines)
                for c = 1:length(clust)
                    spines = spines(spines~=clust(c));  %%% Replace 'spines' array with only the ones that haven't been used yet
                end
%                 if length(spines) == 1
%                     continue
%                 end
                clust = spines(1);
                options = unique(Caddresses{A});
                for o = 1:length(options)
                    if sum(Causal(clust, options(o))>ClusterThresh)==length(clust)
                        clust = [clust; options(o)];
                    end
                end
                if length(clust)>1
                    CausalClustered{HCSnum} = clust;
                    HCSnum = HCSnum+1;
                end
            end
        else
            spines = unique(Caddresses{A});
            CausalClustered{HCSnum} = spines';
            HCSnum = HCSnum+1;
        end
    else
        CausalClustered{HCSnum} = [];
    end
end
end