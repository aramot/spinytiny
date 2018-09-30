function [ClusterInfo] = findclusterind(ClusteredSpines, StatClass, Spine1_address)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

global gui_KomiyamaLabHub

dendsubtract = get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'value');
dendexclude = get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'value');

if dendexclude
    MovementSpines = StatClass.MovementSpines;
    CueSpines = StatClass.CueSpines;
    CueORMovementSpines = StatClass.CueORMovementSpines;
    PreSuccessSpines = StatClass.PreSuccessSpines;
    SuccessSpines = StatClass.SuccessSpines;
    MovementDuringCueSpines = StatClass.MovementDuringCueSpines;
    RewardSpines = StatClass.RewardSpines;
elseif dendsubtract
    MovementSpines = StatClass.DendSub_MovementSpines;
    CueSpines = StatClass.DendSub_CueSpines;
    CueORMovementSpines = StatClass.CueORMovementSpines;
    PreSuccessSpines = StatClass.DendSub_PreSuccessSpines;
    SuccessSpines = StatClass.DendSub_SuccessSpines;
    MovementDuringCueSpines = StatClass.DendSub_MovementDuringCueSpines;
    RewardSpines = StatClass.DendSub_RewardSpines;
end

cluster_ind = [];
cue_cluster_ind = [];
mov_cluster_ind = [];
mix_cluster_ind = [];
presuc_cluster_ind = [];
suc_cluster_ind = [];
movduringcue_cluster_ind = [];
rew_cluster_ind = [];
invmov_cluster_ind = [];

cuenum = 0;
movnum = 0;
mixnum = 0;
presucnum = 0;
sucnum = 0;
movduringcuenum = 0;
rewnum = 0;
antimovementnum = 0;
clustnum = 0;

NumSpinesinCluster = nan;
NumClusters = 0;
FractionofCluster = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    usethiscluster = zeros(length(ClusteredSpines));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(ClusteredSpines)
    return
end
    
if ~isempty(ClusteredSpines{1})
    for j = 1:length(ClusteredSpines)
        alreadyused = 0;
                
        fractionreq = 2;
        
        cue_related = sum(CueSpines(ClusteredSpines{j})) >= fractionreq;
        movement_related = sum(MovementSpines(ClusteredSpines{j})) >= fractionreq;
%         mixed = sum(CueSpines(ClusteredSpines{j})) > 0 && sum(MovementSpines(ClusteredSpines{j})) > 0; 
        mixed = sum(CueORMovementSpines(ClusteredSpines{j})) >= fractionreq;
        presuccess_related = sum(PreSuccessSpines(ClusteredSpines{j})) >= fractionreq;
        success_related = sum(SuccessSpines(ClusteredSpines{j})) >= fractionreq;
        movduringcue_related = sum(MovementDuringCueSpines(ClusteredSpines{j})) >= fractionreq;
        reward_related = sum(RewardSpines(ClusteredSpines{j}))>= fractionreq;
        
        if cue_related
            cuenum = cuenum+1;
            clustnum = clustnum+1;
            alreadyused = 1;
            
            cue_cluster_ind(cuenum,1:length(ClusteredSpines{j}(logical(CueSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(CueSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        end
        if movement_related
            movnum = movnum+1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
            mov_cluster_ind(movnum,1:length(ClusteredSpines{j}(logical(MovementSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(MovementSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};  
        end
        if mixed
            mixnum = mixnum + 1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
%             checkmat = MovementSpines(ClusteredSpines{j})+CueSpines(ClusteredSpines{j});
%             checkmat(checkmat~=2) = 0;
%             checkmat(checkmat~=0) = 1;
%             checkmat = logical(checkmat);
            
            mix_cluster_ind(mixnum, 1:length(ClusteredSpines{j}(logical(CueORMovementSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(CueORMovementSpines(ClusteredSpines{j})));
        end
        if presuccess_related
            presucnum = presucnum+1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
            presuc_cluster_ind(presucnum,1:length(ClusteredSpines{j}(logical(PreSuccessSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(PreSuccessSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        end
        if success_related
            sucnum = sucnum+1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
            suc_cluster_ind(sucnum,1:length(ClusteredSpines{j}(logical(SuccessSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(SuccessSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        end
        if movduringcue_related
            movduringcuenum = movduringcuenum+1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
            movduringcue_cluster_ind(movduringcuenum,1:length(ClusteredSpines{j}(logical(MovementDuringCueSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(MovementDuringCueSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        end
        if reward_related
            rewnum = rewnum+1;
            if ~alreadyused
                clustnum = clustnum+1;
                alreadyused = 1;
            end
            
            rew_cluster_ind(rewnum,1:length(ClusteredSpines{j}(logical(RewardSpines(ClusteredSpines{j}))))) = Spine1_address+ClusteredSpines{j}(logical(RewardSpines(ClusteredSpines{j}))); %%% Add spine address
            cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        end
        
        clustnum = clustnum + 1;
        cluster_ind(clustnum, 1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j};
        
        cluster_ind(clustnum,1:length(ClusteredSpines{j})) = Spine1_address+ClusteredSpines{j}; %%% Add spine address
        NumSpinesinCluster(1,j) = length(cluster_ind);
    end
end



%%% Make a list of all the clustered, cue-clustered, and
%%% mov-clustered indices

cluster_ind(cluster_ind==0) = nan;
cue_cluster_ind(cue_cluster_ind ==0) = nan;
mov_cluster_ind(mov_cluster_ind ==0) = nan;
mix_cluster_ind(mix_cluster_ind ==0) = nan;
presuc_cluster_ind(presuc_cluster_ind ==0) = nan;
suc_cluster_ind(suc_cluster_ind ==0) = nan;
movduringcue_cluster_ind(movduringcue_cluster_ind ==0) = nan;
rew_cluster_ind(rew_cluster_ind ==0) = nan;
invmov_cluster_ind(invmov_cluster_ind ==0) = nan;

cluster_ind = unique(cluster_ind);
cue_cluster_ind = unique(cue_cluster_ind);
mov_cluster_ind = unique(mov_cluster_ind);
mix_cluster_ind = unique(mix_cluster_ind);
presuc_cluster_ind = unique(presuc_cluster_ind);
suc_cluster_ind = unique(suc_cluster_ind);
movduringcue_cluster_ind = unique(movduringcue_cluster_ind);
rew_cluster_ind = unique(rew_cluster_ind);
invmov_cluster_ind = unique(invmov_cluster_ind);

cluster_ind = cluster_ind(~isnan(cluster_ind));
cue_cluster_ind = cue_cluster_ind(~isnan(cue_cluster_ind));
mov_cluster_ind = mov_cluster_ind(~isnan(mov_cluster_ind));
mix_cluster_ind = mix_cluster_ind(~isnan(mix_cluster_ind));
presuc_cluster_ind = presuc_cluster_ind(~isnan(presuc_cluster_ind));
suc_cluster_ind = suc_cluster_ind(~isnan(suc_cluster_ind));
movduringcue_cluster_ind = movduringcue_cluster_ind(~isnan(movduringcue_cluster_ind));
rew_cluster_ind = rew_cluster_ind(~isnan(rew_cluster_ind));
invmov_cluster_ind = invmov_cluster_ind(~isnan(invmov_cluster_ind));


cluster_ind = reshape(cluster_ind, length(cluster_ind), 1);
cue_cluster_ind = reshape(cue_cluster_ind, length(cue_cluster_ind),1);
mov_cluster_ind = reshape(mov_cluster_ind, length(mov_cluster_ind),1);
mix_cluster_ind = reshape(mix_cluster_ind, length(mix_cluster_ind),1);
presuc_cluster_ind = reshape(presuc_cluster_ind, length(presuc_cluster_ind),1);
suc_cluster_ind = reshape(suc_cluster_ind, length(suc_cluster_ind),1);
movduringcue_cluster_ind = reshape(movduringcue_cluster_ind, length(movduringcue_cluster_ind),1);
rew_cluster_ind = reshape(rew_cluster_ind, length(rew_cluster_ind),1);
invmov_cluster_ind = reshape(invmov_cluster_ind, length(invmov_cluster_ind),1);


ClusterInfo.NumSpinesinCluster = NumSpinesinCluster;
ClusterInfo.cluster_ind = cluster_ind;
ClusterInfo.cue_cluster_ind = cue_cluster_ind;
ClusterInfo.mov_cluster_ind = mov_cluster_ind;
ClusterInfo.mix_cluster_ind = mix_cluster_ind;
ClusterInfo.presuc_cluster_ind = presuc_cluster_ind;
ClusterInfo.suc_cluster_ind = suc_cluster_ind;
ClusterInfo.movduringcue_cluster_ind = movduringcue_cluster_ind;
ClusterInfo.rew_cluster_ind = rew_cluster_ind;
