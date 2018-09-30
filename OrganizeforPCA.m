function [PCAdata] = OrganizeForPCA(data,correlations,statclass,session)

if session ~= data.Session
    session = data.Session;
else
end

%%%
feature = 1;

%%% Event Rates

expTime = length(data.SynapseOnlyBinarized_DendriteSubtracted)/30.5/60;

AllRates = diff(data.SynapseOnlyBinarized_DendriteSubtracted,1,2);
AllRates(AllRates<0) = 0;
AllRates = sum(AllRates,2)/expTime;

movementMat = correlations{session}.BinarizedBehavior;

if length(movementMat)~=length(data.SynapseOnlyBinarized_DendriteSubtracted)
    if length(movementMat)>length(data.SynapseOnlyBinarized_DendriteSubtracted)
        movementMat = movementMat(1:length(data.SynapseOnlyBinarized_DendriteSubtracted));
    else
        movementMat = [movementMat; zeros(abs(length(data.SynapseOnlyBinarized_DendriteSubtracted)-length(movementMat)),1)];
    end
end

numspines = data.NumberofSpines;

movementMat = repmat(movementMat,1,numspines);

MovementAct = movementMat'.*data.SynapseOnlyBinarized_DendriteSubtracted;

MovementRates = diff(MovementAct,1,2);
MovementRates(MovementRates<0) = 0;
MovementRates = sum(MovementRates,2)/expTime;

QuietAct = ~movementMat'.*data.SynapseOnlyBinarized_DendriteSubtracted;

QuietRates = diff(QuietAct,1,2);
QuietRates(QuietRates<0) = 0;
QuietRates = sum(QuietRates,2)/expTime;

PCAdata(:,feature) = (AllRates-nanmean(AllRates))/std(AllRates);
    varlist{1,feature} = 'AllRates';
    feature = feature+1;
    
PCAdata(:,feature) = (MovementRates-nanmean(MovementRates))/std(MovementRates);
    varlist{1,feature} = 'MovementRates';
    feature = feature+1;
    
PCAdata(:,feature) = (QuietRates-nanmean(QuietRates))/std(QuietRates);
    varlist{1,feature} = 'StillRates';
    feature = feature+1;
    
%%% Movement Spine Classification
PCAdata(:,feature) = statclass{session}.DendSub_MovementSpines;
    varlist{1,feature} = 'MovementSpines';
    feature = feature+1;

%%% Session
PCAdata(:,feature) = session*ones(numspines,1);
    varlist{1,feature} = 'Session';
    feature = feature+1;


%%% Distance and correlation data
DistanceMap = data.DistanceHeatMap;
a = DistanceMap;
b = DistanceMap';
a(isnan(a) & ~isnan(b)) = b(isnan(a) & ~isnan(b));
DistanceMap = a;

Spine1_address = 9; %%% MAKE SURE THIS IS ACCURATE ACCORDING TO HOW THE CORRELOGRAMS ARE CONSTRUCTED!!!

samedendcorrection = DistanceMap; samedendcorrection(~isnan(samedendcorrection)) = 1;
AllCorrelations = correlations{session}.DendSubtractedSpineCorrelations(Spine1_address+1:end-data.NumberofDendrites,Spine1_address+1:end-data.NumberofDendrites).*samedendcorrection;
MoveCorrelations = correlations{session}.SpineDuringMovePeriods.*samedendcorrection;
StillCorrelations = correlations{session}.SpineDuringStillPeriods.*samedendcorrection;

%%% Max correlation with another spine
xaddresses = 1:numspines;
[valA,indA] = nanmax(AllCorrelations,[],1);
indA(isnan(valA)) = NaN;
valA(isnan(valA)) = 0;
PCAdata(:,feature) = valA;
    varlist{1,feature} = 'MaxCorrAll';
    feature = feature+1;
    for i = 1:length(indA)
        if ~isnan(indA(i))
            DistfromMaxA(i,1) = DistanceMap(xaddresses(i),indA(i));
        else
            DistfromMaxA(i,1) = NaN;
        end
    end
    
PCAdata(:,feature) = (DistfromMaxA-nanmean(DistfromMaxA))/nanstd(DistfromMaxA);    %%% Feature standardization
    varlist{1,feature} = 'DisttoMaxCorrAll';
    feature = feature+1;
    
[valM,indM] = nanmax(MoveCorrelations,[],1);
indM(isnan(valM)) = NaN;
valM(isnan(valM)) = 0;
PCAdata(:,feature) = valM;
    varlist{1,feature} = 'MaxCorrMove';
    feature = feature+1;
    
    for i = 1:length(indM)
        if ~isnan(indM(i))
            DistfromMaxM(i,1) = DistanceMap(xaddresses(i),indM(i));
        else
            DistfromMaxM(i,1) = NaN;
        end
    end
PCAdata(:,feature) = (DistfromMaxM-nanmean(DistfromMaxM))/nanstd(DistfromMaxM);
    varlist{1,feature} = 'DusttoMaxCorrMove';
    feature = feature+1;
    
[valS, indS] = nanmax(StillCorrelations,[],1);
indS(isnan(valS)) = NaN;
valS(isnan(valS)) = 0;
PCAdata(:,feature) = valS;
    varlist{1,feature} = 'MaxCorrStill';
    feature = feature+1;
    
    for i = 1:length(indS)
        if ~isnan(indS(i))
            DistfromMaxS(i,1) = DistanceMap(xaddresses(i),indS(i));
        else
            DistfromMaxS(i,1) = NaN;
        end
    end
PCAdata(:,feature) = (DistfromMaxS-nanmean(DistfromMaxS))/nanstd(DistfromMaxS);
    varlist{1,feature} = 'DisttoMaxCorrStill';
    feature = feature+1;
    
[coeff, score, latent,~, explained,mu] = pca(PCAdata);
    
figure; biplot(coeff(:,1:2), 'scores', score(:,1:2), 'varlabels', varlist)
        
% if sum(MovementSpines)>1
%     spinelist = find(MovementSpines);
%     for s = 1:length(spinelist)
%         currentspine = spinelist(s);            %%% Select current spine on the list
%         otherspines = setdiff(spinelist, currentspine); %%% Make a list of all other spines in the list
%         movspinedistlist = sort(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false)));
%         NearestMovSpine{session}(1,s) = movspinedistlist(1);   %%% Find the smallest distance from the current spine to other spines on the same dendrite
%         if length(movspinedistlist) >1
%             NextClosest{session}(1,s) = movspinedistlist(2);
%         else
%             NextClosest{session}(1,s) = NaN;
%         end
%         minloc = find(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false)) == nanmin(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherspines, 'uni', false))));
%         if ~isempty(minloc)
%             CorrwithNearestMovSpine{session}(1,s) = mean(samedendcorrmat(currentspine, otherspines(minloc)));
%             otherhighcorrspines = mov_cluster_ind-Spine1_address;
%             if ismember(currentspine, otherhighcorrspines)
%                 NearestHighCorrMovSpine{session}(1,s) = nanmin(cell2mat(arrayfun(@(x) DistanceMap(currentspine,x), otherhighcorrspines, 'uni', false)));
%             end
%         end
%     end
% end