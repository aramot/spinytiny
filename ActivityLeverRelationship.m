
global gui_KomiyamaLabHub
experimentnames = gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.String(gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.Value);

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
%     cd(gui_KomiyamaLabHub.DefaultOutputFolder)
    cd('F:\Output Data Backup 9_2_2020')
end

h = waitbar(0, 'Collecting animal information');

lagcurve = cell(1,length(experimentnames));
preferred_lag = cell(1,length(experimentnames));
CoAlagcurve = cell(1,length(experimentnames));
maxlag = 120;
PreMovWindow = 300;
PostMovWindow = 120;

for i = 1:length(experimentnames)
    
    waitbar(i/length(experimentnames), h, ['Collecting information for ', experimentnames{i}]);

    %===================================
    %%% Load lever and activity data
    targetfile = [experimentnames{i}, '_Aligned'];
    load(targetfile)
    eval(['AlignedData = ',targetfile, ';'])
    eval(['clear ', targetfile])
    %===================================
    %%% Extract behavioral measurements, timing, etc.

    used_sessions = cellfun(@(x) ~isempty(x), AlignedData);
    
    all_lever_traces = cellfun(@(x) x.LeverMovement, AlignedData(used_sessions), 'uni', false);

    all_lever_velocity = cellfun(@(x) diff([x.LeverMovement(1); x.LeverMovement]), AlignedData(used_sessions), 'uni', false);
    
    %%% Correct lever velocity traces for "buzzes" from when non-continuous
    %%% imaging is concatenated
    for j = 1:length(all_lever_velocity)
        [~,tf] = rmoutliers(all_lever_velocity{j}, 'movmedian', 20);
        all_lever_velocity{j}(tf) = nan;
        nanx = isnan(all_lever_velocity{j}); 
        t = 1:numel(all_lever_velocity{j});
        all_lever_velocity{j}(nanx) = interp1(t(~nanx), all_lever_velocity{j}(~nanx), t(nanx));
        all_lever_traces{j}(nanx) = interp1(t(~nanx), all_lever_traces{j}(~nanx), t(nanx));
        for lt = 1:length(all_lever_traces)
            if any(isnan(all_lever_traces{lt}))
                nanx = isnan(all_lever_traces{lt});
                all_lever_traces{lt}(nanx) = nanmedian(all_lever_traces{lt});
            end
        end
        nanx = isnan(all_lever_velocity{j}); %%% interpolation won't cover NaNs at position 1
        if any(nanx)
            if find(nanx)==1
               all_lever_velocity{j}(nanx) = all_lever_velocity{j}(2);
            end
            if any(find(nanx) == length(all_lever_velocity{j}))
                last_good_value = find(~nanx(end:-1:end-50), 1, 'first');
                all_lever_velocity{j}(nanx) = all_lever_velocity{j}(end-last_good_value);
            end
        end
    end
    
    all_cue_periods = cellfun(@(x) x.Cue, AlignedData(used_sessions), 'uni', false);
    all_binary_movement_traces = cellfun(@(x) x.Binarized_Lever, AlignedData(used_sessions), 'uni', false);
    all_rew_periods = cellfun(@(x) x.RewardDelivery, AlignedData(used_sessions), 'uni', false);
    binary_sep = cellfun(@(x,y) mat2cell(y,diff(find(diff([~x(1); x; ~x(end)])~=0))), all_binary_movement_traces, all_binary_movement_traces, 'uni', false);
    velocity_sep = cellfun(@(x,y) mat2cell(y,diff(find(diff([~x(1); x; ~x(end)])~=0))), all_binary_movement_traces, all_lever_velocity, 'uni', false);
    %===================================
    %%% Pull out cued-rewarded movements
    PreCueTolerance = 10/1000;
    PreCueTolerance = round(58.3*PreCueTolerance);

    [CRBounds, CMovements, CRMovementsTrace] = cellfun(@(x,y,z) FindCuedRewardedMovements(PreCueTolerance,x,y,z) , all_cue_periods, all_binary_movement_traces, all_rew_periods, 'uni', false);
    %===================================
    %%% Pull out pre-movement periods
    MovStart = cellfun(@(x) diff([~x(1); x])>0, all_binary_movement_traces, 'uni', false);
    
    all_preMov_periods = cellfun(@(x) zeros(1,length(x)), all_binary_movement_traces, 'uni', false);
    preMov_backshift = cellfun(@(x,y) arrayfun(@(x,y) x:y, x,y, 'uni', false), cellfun(@(x) find(x)-3, MovStart, 'uni', false), cellfun(@(x) find(x)-1, MovStart, 'uni', false), 'uni', false);    %%% For all sessions, shift the movement back by X frames to capture the pre-movement window
    for sesh = 1:length(all_binary_movement_traces)
        addresses = cell2mat(preMov_backshift{sesh});
        addresses = addresses(~any(addresses'<=0),:);    %%% Ensure that no pre-movement periods are negative
        all_preMov_periods{sesh}(addresses) = 1;
    end
    %===================================
    %%% Pull out all spine activity data
    all_raw_spine_activity = cellfun(@(x) x.ProcessedSpineActivity, AlignedData(used_sessions), 'uni', false);
    all_spine_activity = cellfun(@(x) x.BinarizedOverallSpineData, AlignedData(used_sessions), 'uni', false);
    %===================================
    %%% Run XCorr for all spines to find their preferred lags
    for session = 1:length(all_spine_activity)
        xcorrcount = 1;
        for spine = 1:size(all_spine_activity{session},1)
            if any(all_spine_activity{session}(spine,:))
                [c,lags] = xcorr(all_spine_activity{session}(spine,:), (all_lever_velocity{session}), maxlag, 'coeff');
                lagcurve{i}{session}(xcorrcount,:) = c;
                bestlag = lags(c==max(c));
                if length(bestlag)>1
                    bestlag = nanmean(bestlag);
                end
                preferred_lag{i}{session}(spine,1) = bestlag;
                xcorrcount = xcorrcount+1;
            else
                lagcurve{i}{session}(xcorrcount,:) = nan(1,maxlag*2+1);
                preferred_lag{i}{session}(spine,1) = nan;
                xcorrcount = xcorrcount+1;
            end
        end
    end
    %===================================
    %%% Correlate spine activity with position, velocity, and speed
    %%% If you want to incorporate a lag, do so here
    
    %%% Use this if preferred lag is positive (i.e. the lever feature needs
    %%% to be shifted to the right to maximize xcorr). 
    chosen_lag = 10;
    [r_pos,p_pos] = cellfun(@(x,y) corrcoef([y(chosen_lag+1:end),x(:,1:end-chosen_lag)']), all_spine_activity, all_lever_traces, 'uni', false);
    [r_vel,p_vel] = cellfun(@(x,y) corrcoef([y(chosen_lag+1:end),x(:,1:end-chosen_lag)']), all_spine_activity, all_lever_velocity, 'uni', false);
    [r_spd,p_spd] = cellfun(@(x,y) corrcoef([abs(y(chosen_lag+1:end)),x(:,1:end-chosen_lag)']), all_spine_activity, all_lever_velocity, 'uni', false);
    %%% Use this if preferred lag is negative
%     [r_pos,p_pos] = cellfun(@(x,y) corrcoef([[y(1)*ones(5,1);y(1:end-5)],x']), all_spine_activity, all_lever_traces, 'uni', false);
%     [r_vel,p_vel] = cellfun(@(x,y) corrcoef([[y(1)*ones(5,1);y(1:end-5)],x']), all_spine_activity, all_lever_velocity, 'uni', false);
%     [r_spd,p_spd] = cellfun(@(x,y) corrcoef([[y(1)*ones(5,1);y(1:end-5)],abs(x)']), all_spine_activity, all_lever_velocity, 'uni', false);   
    %%% Run the following if you want to align each spine using its
    %%% preferred lag
%     for f = 1:length(all_spine_activity)
%         for sp = 1:size(all_spine_activity{f},1)
%             if ~isnan(preferred_lag{i}{f}(sp))
%                 if preferred_lag{i}{f}(sp)>0
%                     shifted_velocity = [all_lever_velocity{f}(preferred_lag{i}{f}(sp):end); all_lever_velocity{f}(end)*ones(preferred_lag{i}{f}(sp)-1,1)];
%                     [r_temp, p_temp] = corrcoef([shifted_velocity, all_spine_activity{f}(sp,:)']);
%                     r_vel{f}(1,sp+1) = r_temp(1,2);
%                     p_vel{f}(1,sp+1) = p_temp(1,2);
%                 elseif preferred_lag{i}{f}(sp)<0
%                     shifted_velocity = [all_lever_velocity{f}(1)*ones(-preferred_lag{i}{f}(sp),1); all_lever_velocity{f}(1:end+preferred_lag{i}{f}(sp))];
%                     [r_temp, p_temp] = corrcoef([shifted_velocity, all_spine_activity{f}(sp,:)']);
%                     r_vel{f}(1,sp+1) = r_temp(1,2);
%                     p_vel{f}(1,sp+1) = p_temp(1,2);                
%                 elseif preferred_lag{i}{f}(sp)==0
%                     [r_temp, p_temp] = corrcoef([all_lever_velocity{f}, all_spine_activity{f}(sp,:)']);
%                     r_vel{f}(1,sp+1) = r_temp(1,2);
%                     p_vel{f}(1,sp+1) = p_temp(1,2);                
%                 end
%             end
%         end
%     end
    
    %%% Otherwise, use this portion
%     [r_pos,p_pos] = cellfun(@(x,y) corrcoef([y,x']), all_spine_activity, all_lever_traces, 'uni', false);
%     [r_vel,p_vel] = cellfun(@(x,y) corrcoef([y,x']), all_spine_activity, all_lever_velocity, 'uni', false);
%     [r_spd,p_spd] = cellfun(@(x,y) corrcoef([y,abs(x')]), all_spine_activity, all_lever_velocity, 'uni', false);
    %===================================
    
    %%% Find the "preferred" position, velocity, and speed for each spine
    [AllSpine_Pref_Position{i}, AllSpine_PrefPos_STD{i}] = FindPreferredPeriods(all_spine_activity, all_lever_traces, all_binary_movement_traces, chosen_lag);
    [AllSpine_Pref_Velocity{i}, AllSpine_PrefVel_STD{i}] = FindPreferredPeriods(all_spine_activity, all_lever_velocity, all_binary_movement_traces, chosen_lag);
    [AllSpine_Pref_Speed{i}, AllSpine_PrefSpd_STD{i}] = FindPreferredPeriods(all_spine_activity, cellfun(@abs,all_lever_velocity, 'uni', false),all_binary_movement_traces, chosen_lag);
   
    %===================================
    %%% Load Statistical Classification Data
    targetfile = [experimentnames{i}, '_StatClassified'];
    load(targetfile)
    eval(['ClassData = ', targetfile, ';'])
    eval(['clear ', targetfile])
    
    allMRSs{i} = cellfun(@(x) x.OverallMovementSpines, ClassData(used_sessions), 'uni', false);
    allnonMRSs{i} = cellfun(@(x) ~x.OverallMovementSpines, ClassData(used_sessions), 'uni', false);
    
    %===================================
    %%% Find the correlations of each spine with p,v,and s, according to
    %%% sessions of interest
    earlySessions{i} = find(used_sessions)<=3;
    lateSessions{i} = find(used_sessions)>9 & find(used_sessions)<=14;
    
    CorrofMRSswithPosition{i} = cellfun(@(x,y) x(1,y), r_pos(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofMRSSigCorrwithPos{i} = cellfun(@(x,y) x(1,y)<0.05, p_pos(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    CorrofnMRSswithPosition{i} = cellfun(@(x,y) x(1,~y), r_pos(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofnMRSSigCorrwithPos{i} = cellfun(@(x,y) x(1,~y)<0.05, p_pos(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    
    CorrofMRSswithVelocity{i} = cellfun(@(x,y) x(1,y), r_vel(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofMRSSigCorrwithVel{i} = cellfun(@(x,y) x(1,y)<0.05, p_vel(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    CorrofnMRSswithVelocity{i} = cellfun(@(x,y) x(1,~y), r_vel(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofnMRSSigCorrwithVel{i} = cellfun(@(x,y) x(1,~y)<0.05, p_vel(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    
    CorrofMRSswithSpeed{i} = cellfun(@(x,y) x(1,y), r_spd(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofMRSSigCorrwithSpd{i} = cellfun(@(x,y) x(1,y)<0.05, p_spd(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    CorrofnMRSswithSpeed{i} = cellfun(@(x,y) x(1,~y), r_spd(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    FractionofnMRSSigCorrwithSpd{i} = cellfun(@(x,y) x(1,~y)<0.05, p_spd(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);

    %===================================
    %%% Load Spine Dynamics Summary Data
    targetfile = [experimentnames{i}, '_SpineDynamicsSummary'];
    load(targetfile)
    eval(['DynamicsData = ', targetfile, ';'])
    eval(['clear ', targetfile])

    %======================================================================
    %%% New Spine Section
    NewSpines = cell(1,14);
    NewSpines(cellfun(@(x) x(end), DynamicsData.SessionsbyField)) = DynamicsData.NewSpines;
    used_sessions_count = cumsum(used_sessions).*used_sessions;
    NS_list_for_later{i} = cell(1,length(r_pos));
    
%     relative_final_sessions_for_field = used_sessions_count(cellfun(@(x) x(end), DynamicsData.SessionsbyField));
    
    if any(~cellfun(@isempty, NewSpines))
        %===================================
        NS_address = ~cellfun(@isempty, NewSpines);
        sessions_with_NS = used_sessions_count(NS_address);
        corresponding_early_sessions = cellfun(@(x) x(1), DynamicsData.SessionsbyField);
        corresponding_mid_sessions = used_sessions_count(cellfun(@(x) x(2), DynamicsData.SessionsbyField(cellfun(@length, DynamicsData.SessionsbyField)==3)));
        NS_list_for_later{i}(sessions_with_NS) = NewSpines(NS_address);
        %===================================
        %%% Find correlation of NS with lever p,s, and v
        CorrofNSwithPosition{i} = cellfun(@(x,y) x(1,y), r_pos(sessions_with_NS), NewSpines(NS_address), 'uni', false);
        FractionofNSSigCorrwithPos{i} = cellfun(@(x,y) x(1,y)<0.05, p_pos(sessions_with_NS), NewSpines(NS_address), 'uni', false);

        CorrofNSwithVelocity{i} = cellfun(@(x,y) x(1,y), r_vel(sessions_with_NS), NewSpines(NS_address), 'uni', false);
        FractionofNSSigCorrwithVel{i} = cellfun(@(x,y) x(1,y)<0.05, p_vel(sessions_with_NS), NewSpines(NS_address), 'uni', false);

        CorrofNSwithSpeed{i} = cellfun(@(x,y) x(1,y), r_spd(sessions_with_NS), NewSpines(NS_address), 'uni', false);
        FractionofNSSigCorrwithSpd{i} = cellfun(@(x,y) x(1,y)<0.05, p_spd(sessions_with_NS), NewSpines(NS_address), 'uni', false);
        
        %==================================================================
        %%% NS-MRS Pairs (distances, co-activity, pair differences in
        %%% tuning, etc) 
        
        NS_MRS_Distances{i} = cellfun(@(x,y) x(:,y), DynamicsData.NewSpineAllSpinesDistance(~cellfun(@isempty,DynamicsData.NewSpineAllSpinesDistance)), allMRSs{i}(sessions_with_NS), 'uni', false);

        NS_activity = cellfun(@(x,y) x(y,:), all_spine_activity(sessions_with_NS), NewSpines(NS_address), 'uni', false); 
        Corresponding_early_MRS_activity = cellfun(@(x,y) x(y,:), all_spine_activity(corresponding_early_sessions), allMRSs{i}(corresponding_early_sessions), 'uni', false);
        Corresponding_mid_MRS_activity = cellfun(@(x,y) x(y,:), all_spine_activity(corresponding_mid_sessions), allMRSs{i}(corresponding_mid_sessions), 'uni', false);
        Corresponding_MRS_activity = cellfun(@(x,y) x(y,:), all_spine_activity(sessions_with_NS), allMRSs{i}(sessions_with_NS), 'uni', false);
        Corresponding_nonMRS_activity = cellfun(@(x,y) x(y,:), all_spine_activity(sessions_with_NS), allnonMRSs{i}(sessions_with_NS), 'uni', false);
        
        CoActivity = cell(1,length(NS_activity));
        SingleCoActivityUnit = cell(1,length(NS_activity)); %%% Maybe NS should be considered as part of a whole ensemble?
        for f = 1:length(NS_activity)
            for ns = 1:size(NS_activity{f},1)
                CoActivity{f} = [CoActivity{f}; NS_activity{f}(ns,:) & Corresponding_MRS_activity{f}(:,:)];
                SingleCoActivityUnit{f} = [SingleCoActivityUnit{f}; sum(NS_activity{f}(ns,:) & Corresponding_MRS_activity{f}(:,:),1)];
                MRSonlyActivity{f}{ns} = [Corresponding_MRS_activity{f}(:,:) & ~NS_activity{f}(ns,:)];
                NSonlyActivity{f}{ns} = [NS_activity{f}(ns,:) & ~ Corresponding_MRS_activity{f}(:,:)];
            end
        end
        MRSonlyActivity = cellfun(@(x) vertcat(x{:}), MRSonlyActivity, 'uni', false);
        NSonlyActivity = cellfun(@(x) vertcat(x{:}), NSonlyActivity, 'uni', false);

%         [PreMovementRelatedPairs{i},~,~] = cellfun(@(x,y) mv_related_classifi(x,y,'movement'), CoActivity, all_preMov_periods(sessions_with_NS), 'uni', false);
        
        [earlyMRS_onset_time{i},earlyMRSMovAlignedActivity{i},earlyMRSIndividual_Trials{i}] = cellfun(@(w,x,y,z) FindOnsetStart(w,x(z,:),y,PreMovWindow, PostMovWindow), all_binary_movement_traces(corresponding_early_sessions), all_raw_spine_activity(corresponding_early_sessions), Corresponding_early_MRS_activity, allMRSs{i}(corresponding_early_sessions), 'uni', false);
        [midMRS_onset_time{i},midMRSMovAlignedActivity{i},midMRSIndividual_Trials{i}] = cellfun(@(w,x,y,z) FindOnsetStart(w,x(z,:),y,PreMovWindow, PostMovWindow), all_binary_movement_traces(corresponding_mid_sessions), all_raw_spine_activity(corresponding_mid_sessions), Corresponding_mid_MRS_activity, allMRSs{i}(corresponding_mid_sessions), 'uni', false);
        [MRS_onset_time{i},MRSMovAlignedActivity{i},MRSIndividual_Trials{i}] = cellfun(@(w,x,y,z) FindOnsetStart(w,x(z,:),y,PreMovWindow, PostMovWindow), all_binary_movement_traces(sessions_with_NS), all_raw_spine_activity(sessions_with_NS), Corresponding_MRS_activity, allMRSs{i}(sessions_with_NS), 'uni', false);
        [nonMRS_onset_time{i},nonMRSMovAlignedActivity{i},nonMRSIndividual_Trials{i}] = cellfun(@(w,x,y,z) FindOnsetStart(w,x(z,:),y,PreMovWindow, PostMovWindow), all_binary_movement_traces(sessions_with_NS), all_raw_spine_activity(sessions_with_NS), Corresponding_nonMRS_activity, allnonMRSs{i}(sessions_with_NS), 'uni', false);
        [NS_onset_time{i},NSMovAlignedActivity{i}, NSIndividual_Trials{i}] = cellfun(@(w,x,y,z) FindOnsetStart(w,x(z,:),y,PreMovWindow, PostMovWindow), all_binary_movement_traces(sessions_with_NS), all_raw_spine_activity(sessions_with_NS), NS_activity, NewSpines(NS_address), 'uni', false);
        
        %==================================================================
                        
%         PairPositionDiff{i} = cell(1,length(NS_activity)); MRSPositionSTD{i} = cell(1,length(NS_activity)); NSPositionSTD{i} = cell(1,length(NS_activity));
%         PairVelocityDiff{i} = cell(1,length(NS_activity));  MRSVelocitySTD{i} = cell(1,length(NS_activity)); NSVelocitySTD{i} = cell(1,length(NS_activity));
%         PairSpeedDiff{i} = cell(1,length(NS_activity)); MRSSpeedSTD{i} = cell(1,length(NS_activity)); NSSpeedSTD{i} = cell(1,length(NS_activity));

%         lag_count = 1;    %%% Use this loop structure for the following variables to explore over multiple lag values
%         for chosen_lag = -30:1:30
        %%% Find the lever positions encoded individually by NS and MRS
            selected_lever_traces = all_lever_traces(sessions_with_NS);
            selected_binary_traces = all_binary_movement_traces(sessions_with_NS);
            selected_lever_velocity = all_lever_velocity(sessions_with_NS);
            [MRS_position_encoded, MRS_Pos_STD] = FindPreferredPeriods(MRSonlyActivity, selected_lever_traces,selected_binary_traces,chosen_lag);
            [MRS_velocity_encoded, MRS_Vel_STD] = FindPreferredPeriods(MRSonlyActivity, selected_lever_velocity,selected_binary_traces, chosen_lag);
            [MRS_speed_encoded, MRS_Spd_STD] = FindPreferredPeriods(MRSonlyActivity, cellfun(@abs,selected_lever_velocity, 'uni', false),selected_binary_traces, chosen_lag);
            [NS_position_encoded, NS_Pos_STD] = FindPreferredPeriods(NSonlyActivity, all_lever_traces(sessions_with_NS),all_binary_movement_traces(sessions_with_NS), chosen_lag);
            [NS_velocity_encoded, NS_Vel_STD] = FindPreferredPeriods(NSonlyActivity, all_lever_velocity(sessions_with_NS),all_binary_movement_traces(sessions_with_NS), chosen_lag);
            [NS_speed_encoded, NS_Spd_STD] = FindPreferredPeriods(NSonlyActivity, cellfun(@abs,all_lever_velocity(sessions_with_NS), 'uni', false), all_binary_movement_traces(sessions_with_NS), chosen_lag);

            PairPositionDiff{i} = cell(1,length(NS_activity)); MRSPositionSTD{i} = cell(1,length(NS_activity));
            PairVelocityDiff{i} = cell(1,length(NS_activity));
            PairSpeedDiff{i} = cell(1,length(NS_activity));
            PairOnsetDiff{i} = cell(1,length(NS_activity));
            MRSPairOnsetDiff{i} = cell(1,length(Corresponding_MRS_activity));
            nMRSPairOnsetDiff{i} = cell(1,length(Corresponding_nonMRS_activity));
            for f = 1:length(NS_activity)
                for ns = 1:size(NS_activity{f},1)
                    for mrs = 1:size(Corresponding_MRS_activity{f},1)
                        PairOnsetDiff{i}{f} = [PairOnsetDiff{i}{f}; diff([NS_onset_time{i}{f}(ns),MRS_onset_time{i}{f}(mrs)])];
                    end
                end
                for pair = 1:length(NS_position_encoded{f})
                    PairPositionDiff{i}{f} = [PairPositionDiff{i}{f}; diff([NS_position_encoded{f}(pair), MRS_position_encoded{f}(pair)])];
                    MRSPositionSTD{i}{f} = [MRSPositionSTD{i}{f}; MRS_Pos_STD{f}(pair)];
                    PairVelocityDiff{i}{f} = [PairVelocityDiff{i}{f}; diff([NS_velocity_encoded{f}(pair), MRS_velocity_encoded{f}(pair)])];
                    PairSpeedDiff{i}{f} = [PairSpeedDiff{i}{f}; diff([NS_speed_encoded{f}(pair), MRS_speed_encoded{f}(pair)])];
                end
                for mrs = 1:size(Corresponding_MRS_activity{f},1)
                    for comp_mrs = 1:size(Corresponding_MRS_activity{f},1)
                        if mrs ~= comp_mrs
                            MRSPairOnsetDiff{i}{f} = [MRSPairOnsetDiff{i}{f}; diff([MRS_onset_time{i}{f}(mrs),MRS_onset_time{i}{f}(comp_mrs)])];
                        end
                    end
                end
                for nmrs = 1:size(Corresponding_nonMRS_activity{f},1)
                    for comp_nmrs = 1:size(Corresponding_nonMRS_activity{f},1)
                        if nmrs ~= comp_nmrs
                            nMRSPairOnsetDiff{i}{f} = [nMRSPairOnsetDiff{i}{f}; diff([nonMRS_onset_time{i}{f}(nmrs),nonMRS_onset_time{i}{f}(comp_nmrs)])];
                        end
                    end
                end
            end
            
            
            
% 
%             for f = 1:length(NS_activity)
%                 for NSMRSpair = 1:size(NSonlyActivity{f},1)
%                     NSPositionSTD{i}{f}{lag_count}(NSMRSpair) = NS_Pos_STD{f}(NSMRSpair);
%                     NSVelocitySTD{i}{f}{lag_count}(NSMRSpair) = NS_Vel_STD{f}(NSMRSpair);
%                     NSSpeedSTD{i}{f}{lag_count}(NSMRSpair) = NS_Spd_STD{f}(NSMRSpair);
%                         MRSPositionSTD{i}{f}{lag_count}(NSMRSpair,1) = MRS_Pos_STD{f}(NSMRSpair);
%                         PairPositionDiff{i}{f}{lag_count}(NSMRSpair,1) = diff([NS_position_encoded{f}(NSMRSpair), MRS_position_encoded{f}(NSMRSpair)]);
%                         MRSVelocitySTD{i}{f}{lag_count}(NSMRSpair,1) = MRS_Vel_STD{f}(NSMRSpair);
%                         PairVelocityDiff{i}{f}{lag_count}(NSMRSpair,1) = diff([NS_velocity_encoded{f}(NSMRSpair), MRS_velocity_encoded{f}(NSMRSpair)]);
%                         MRSSpeedSTD{i}{f}{lag_count}(NSMRSpair,1) = MRS_Spd_STD{f}(NSMRSpair);
%                         PairSpeedDiff{i}{f}{lag_count}(NSMRSpair,1) = diff([NS_speed_encoded{f}(NSMRSpair), MRS_speed_encoded{f}(NSMRSpair)]);
%                 end
%             end
%             lag_count = lag_count+1;
%         end
%         
        selected_lever_velocity = all_lever_velocity(sessions_with_NS);
        [CoA_Pref_Velocity{i}] = FindPreferredPeriods(CoActivity, selected_lever_velocity, all_binary_movement_traces(sessions_with_NS), chosen_lag);
        
        CoARates{i} = cellfun(@(x) reshape(x,numel(x),1), cellfun(@(x,y) x(:,y), cellfun(@(x) vertcat(x{:}), DynamicsData.NewSpineAllCoActiveRatesGeoNormalized(~cellfun(@isempty,DynamicsData.NewSpineAllCoActiveRatesGeoNormalized)), 'uni', false), allMRSs{i}(sessions_with_NS), 'uni', false), 'uni', false);
        %==================================================================
        
        %%% Recalculate lever feature correlations
        chosen_lag = 10;
        %%% Use this is preferred lag is positive
        [r_pos,p_pos] = cellfun(@(x,y) corrcoef([y(chosen_lag+1:end),x(:,1:end-chosen_lag)']), CoActivity, all_lever_traces(sessions_with_NS), 'uni', false);
        [r_vel,p_vel] = cellfun(@(x,y) corrcoef([y(chosen_lag+1:end),x(:,1:end-chosen_lag)']), CoActivity, all_lever_velocity(sessions_with_NS), 'uni', false);
        [r_spd,p_spd] = cellfun(@(x,y) corrcoef([abs(y(chosen_lag+1:end)),x(:,1:end-chosen_lag)']), CoActivity, all_lever_velocity(sessions_with_NS), 'uni', false);
        %%% Use this is preferred lag is negative
%         [r_pos,p_pos] = cellfun(@(x,y) corrcoef([[y(1)*ones(7,1);y(1:end-7)],x']), CoActivity, all_lever_traces(sessions_with_NS), 'uni', false);
%         [r_vel,p_vel] = cellfun(@(x,y) corrcoef([[y(1)*ones(7,1);y(1:end-7)],x']), CoActivity, all_lever_velocity(sessions_with_NS), 'uni', false);
%         [r_spd,p_spd] = cellfun(@(x,y) corrcoef([[y(1)*ones(7,1);y(1:end-7)],abs(x)']), CoActivity, all_lever_velocity(sessions_with_NS), 'uni', false);

        for pf = 1:length(p_vel)
            r_vel{pf}(1:size(p_vel{pf},1)+1:numel(p_vel{pf})) = nan;
            p_vel{pf}(1:size(p_vel{pf},1)+1:numel(p_vel{pf})) = nan;
        end
        CorrofCoAwithPosition{i} = cellfun(@(x) x(1,2:end), r_pos, 'uni', false);
        FractionofCoASigCorrwithPos{i} = cellfun(@(x) x(1,2:end)<0.05, p_pos, 'uni', false);

        CorrofCoAwithVelocity{i} = cellfun(@(x) x(1,2:end), r_vel, 'uni', false);
        FractionofCoASigCorrwithVel{i} = cellfun(@(x) x(1,2:end)<0.05, p_vel, 'uni', false);
        
        CorrofCoAwithSpeed{i} = cellfun(@(x) x(1,2:end), r_spd, 'uni', false);
        FractionofCoASigCorrwithSpd{i} = cellfun(@(x) x(1,2:end)<0.05, p_spd, 'uni', false);

        xcorrcount = 1;
        associated_lever_position = all_lever_traces(sessions_with_NS);
        associated_lever_velocity = all_lever_velocity(sessions_with_NS);
        for session = 1:length(CoActivity)
            for spine = 1:size(CoActivity{session},1)
                if any(CoActivity{session}(spine,:))
                    [c,lags] = xcorr(CoActivity{session}(spine,:), (associated_lever_velocity{session}), maxlag, 'coeff');
                    CoAlagcurve{i}{session}(xcorrcount,:) = c;
                    bestlag = lags(c==max(c));
                    if length(bestlag)>1
                        bestlag = nanmean(bestlag);
                    end
                    CoApreferred_lag{i}{session}(spine,1) = bestlag;
                    xcorrcount = xcorrcount+1;
                else
                    CoAlagcurve{i}{session}(xcorrcount,:) = nan(1,maxlag*2+1);
                    CoApreferred_lag{i}{session}(spine,1) = nan;
                    xcorrcount = xcorrcount+1;
                end
            end
        end
    end
    %======================================================================
    clearvars '-except' ...
        'h' 'maxlag' 'PreMovWindow' 'PostMovWindow'...
        'earlySessions' 'lateSessions' 'allMRSs' 'NS_list_for_later' 'NS_MRS_Distances'...
        'lagcurve' 'preferred_lag' 'CoAlagcurve'...
        'CorrofMRSswithPosition' 'CorrofnMRSswithPosition' 'FractionofMRSSigCorrwithPos' 'FractionofnMRSSigCorrwithPos' ...
        'CorrofMRSswithVelocity' 'CorrofnMRSswithVelocity' 'FractionofMRSSigCorrwithVel' 'FractionofnMRSSigCorrwithVel' ...
        'CorrofMRSswithSpeed' 'CorrofnMRSswithSpeed' 'FractionofMRSSigCorrwithSpd' 'FractionofnMRSSigCorrwithSpd'...
        'CorrofNSwithPosition' 'FractionofNSSigCorrwithPos' 'CorrofNSwithVelocity' 'FractionofNSSigCorrwithVel' 'CorrofNSwithSpeed' 'FractionofNSSigCorrwithSpd'...
        'CorrofCoAwithPosition' 'FractionofCoASigCorrwithPos' 'CorrofCoAwithVelocity' 'FractionofCoASigCorrwithVel' 'CorrofCoAwithSpeed' 'FractionofCoASigCorrwithSpd'...
        'AllSpine_Pref_Position' 'AllSpine_Pref_Velocity' 'AllSpine_Pref_Speed'...
        'EncodingSlope' 'PairPositionDiff' 'MRSPositionSTD' 'NSPositionSTD' 'MRSVelocitySTD' 'NSVelocitySTD' 'MRSSpeedSTD' 'NSSpeedSTD' 'PairVelocityDiff' 'PairSpeedDiff' 'PairOnsetDiff' 'CoA_Pref_Velocity' 'CoARates'...
        'PreMovementRelatedPairs'...
        'earlyMRS_onset_time' 'midMRS_onset_time' 'MRS_onset_time' 'nonMRS_onset_time' 'NS_onset_time' 'earlyMRSMovAlignedActivity' 'midMRSMovAlignedActivity' 'MRSMovAlignedActivity' 'nonMRSMovAlignedActivity' 'NSMovAlignedActivity' 'earlyMRSIndividual_Trials' 'MRSIndividual_Trials' 'nonMRSIndividual_Trials' 'NSIndividual_Trials'... 
        'MRSPairOnsetDiff' 'nMRSPairOnsetDiff'...
        'experimentnames' 'gui_KomiyamaLabHub'
end

delete(h)

AllNSMRSDist = cell2mat(cellfun(@(x) reshape(x,numel(x),1), horzcat(NS_MRS_Distances{:}),'uni',false)');

a = horzcat(FractionofnMRSSigCorrwithPos{:});
AllnMRS_Sig_CorrwithPosition = cell2mat(a);
a = horzcat(FractionofMRSSigCorrwithPos{:});
AllMRS_Sig_CorrwithPosition = cell2mat(a);
a = horzcat(FractionofNSSigCorrwithPos{:});
AllNS_Sig_CorrwithPosition = cell2mat(a);
a = horzcat(FractionofCoASigCorrwithPos{:});
AllCoA_Sig_CorrwithPosition = cell2mat(a);

a = horzcat(FractionofnMRSSigCorrwithVel{:});
AllnMRS_Sig_CorrwithVelocity = cell2mat(a);
a = horzcat(FractionofMRSSigCorrwithVel{:});
AllMRS_Sig_CorrwithVelocity = cell2mat(a);
a = horzcat(FractionofNSSigCorrwithVel{:});
AllNS_Sig_CorrwithVelocity = cell2mat(a);
a = horzcat(FractionofCoASigCorrwithVel{:});
AllCoA_Sig_CorrwithVelocity = cell2mat(a);

a = horzcat(FractionofnMRSSigCorrwithSpd{:});
AllnMRS_Sig_CorrwithSpeed = cell2mat(a);
a = horzcat(FractionofMRSSigCorrwithSpd{:});
AllMRS_Sig_CorrwithSpeed = cell2mat(a);
a = horzcat(FractionofNSSigCorrwithSpd{:});
AllNS_Sig_CorrwithSpeed = cell2mat(a);
a = horzcat(FractionofCoASigCorrwithSpd{:});
AllCoA_Sig_CorrwithSpeed = cell2mat(a);

figure;
s1 = subplot(1,3,1); hold on; 
bar(1,nanmean(AllnMRS_Sig_CorrwithPosition))
bar(2,nanmean(AllMRS_Sig_CorrwithPosition))
bar(3,nanmean(AllNS_Sig_CorrwithPosition))
bar(4,nanmean(AllCoA_Sig_CorrwithPosition))
title('Position')

s2 = subplot(1,3,2); hold on; 
bar(1,nanmean(AllnMRS_Sig_CorrwithVelocity))
bar(2,nanmean(AllMRS_Sig_CorrwithVelocity))
bar(3,nanmean(AllNS_Sig_CorrwithVelocity))
bar(4,nanmean(AllCoA_Sig_CorrwithVelocity))
title('Velocity')

s3 = subplot(1,3,3); hold on; 
bar(1,nanmean(AllnMRS_Sig_CorrwithSpeed))
bar(2,nanmean(AllMRS_Sig_CorrwithSpeed))
bar(3,nanmean(AllNS_Sig_CorrwithSpeed))
bar(4,nanmean(AllCoA_Sig_CorrwithSpeed))
title('Speed')

linkaxes([s1,s2,s3], 'xy')

for i = 1:length(lagcurve)
    earlylags{i} = cellfun(@(x) nanmean(x,1), lagcurve{i}(earlySessions{i}), 'uni', false);
    earlyMRSlags{i} = cellfun(@(x,y) nanmean(x(y,:),1), lagcurve{i}(earlySessions{i}), allMRSs{i}(earlySessions{i}), 'uni', false);
end
figure; plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(earlylags{:})'))', 'g', 'linewidth', 2)
hold on; plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(earlyMRSlags{:})'))', '--g', 'linewidth', 2)

for i = 1:length(lagcurve)
    latelags{i} = cellfun(@(x) nanmean(x,1), lagcurve{i}(lateSessions{i}), 'uni', false);
    lateMRSlags{i} = cellfun(@(x,y) nanmean(x(y,:),1), lagcurve{i}(lateSessions{i}), allMRSs{i}(lateSessions{i}), 'uni', false);
    lateNSlags{i} = cellfun(@(x,y) nanmean(x(y,:),1), lagcurve{i}(lateSessions{i}), NS_list_for_later{i}(lateSessions{i}), 'uni', false);
end
plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(latelags{:})'))', 'k', 'linewidth', 2)
plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(lateMRSlags{:})'))', '--k', 'linewidth', 2)
plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(lateNSlags{:})'))', 'c', 'linewidth', 2)

for i = 1:length(CoAlagcurve)
    if ~isempty(CoAlagcurve{i})
        lateCoAlags{i} = cellfun(@(x) nanmean(x), CoAlagcurve{i}, 'uni', false);
    end
end
hold on; plot([-maxlag:maxlag], nanmean(cell2mat(horzcat(lateCoAlags{:})'))', 'r', 'linewidth', 2)

xlabel('Lag (frames)')
ylabel('Mean XCorr')


for i = 1:length(AllSpine_Pref_Position)
    for j = 1:length(AllSpine_Pref_Position{i})
        pos_data = AllSpine_Pref_Position{i}{j}(allMRSs{i}{j});
        vel_data = AllSpine_Pref_Velocity{i}{j}(allMRSs{i}{j});
        spd_data = AllSpine_Pref_Speed{i}{j}(allMRSs{i}{j});
        if length(pos_data)>1
            options = nchoosek(1:length(pos_data),2);       
            for k = 1:size(options,1)
                PosTuningDiff{i}{j}(k) = abs(diff([pos_data(options(k,1)),pos_data(options(k,2))]));
                VelTuningDiff{i}{j}(k) = abs(diff([vel_data(options(k,1)),vel_data(options(k,2))]));
                SpdTuningDiff{i}{j}(k) = abs(diff([spd_data(options(k,1)),spd_data(options(k,2))]));
            end
        else
            PosTuningDiff{i}{j}(k) = nan;
            VelTuningDiff{i}{j}(k) = nan;
            SpdTuningDiff{i}{j}(k) = nan;
        end
    end
end
AllNSMRSDist = cell2mat(cellfun(@(x) reshape(x,numel(x),1), horzcat(NS_MRS_Distances{:}),'uni',false)');

AllNSMRSPosDiff = cell2mat(horzcat(PairPositionDiff{:})');
    AllNSMRSPosDiffSameDend = AllNSMRSPosDiff(~isnan(AllNSMRSDist));
AllNSMRSVelDiff = cell2mat(horzcat(PairVelocityDiff{:})'); 
    AllNSMRSVelDiffSameDend = AllNSMRSVelDiff(~isnan(AllNSMRSDist));
AllNSMRSSpdDiff = cell2mat(horzcat(PairSpeedDiff{:})');
    AllNSMRSSpdDiffSameDend = AllNSMRSSpdDiff(~isnan(AllNSMRSDist));
    
figure;
subplot(1,3,1); hold on; 
bar(1,nanmedian(cell2mat(cellfun(@(x) horzcat(x{:}), cellfun(@(x,y) x(y), PosTuningDiff, earlySessions, 'uni', false), 'uni', false))))
bar(2,nanmedian(abs(AllNSMRSPosDiffSameDend)))
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'MRS-MRS', 'NS-MRS'})
xtickangle(45)
title('Position')
ylabel('Tuning Difference')

subplot(1,3,2); hold on; 
bar(1,nanmedian(cell2mat(cellfun(@(x) horzcat(x{:}), cellfun(@(x,y) x(y), VelTuningDiff, earlySessions, 'uni', false), 'uni', false))))
bar(2,nanmedian(abs(AllNSMRSVelDiffSameDend)))
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'MRS-MRS', 'NS-MRS'})
xtickangle(45)
title('Velocity')
ylabel('Tuning Difference')

subplot(1,3,3); hold on; 
bar(1,nanmedian(cell2mat(cellfun(@(x) horzcat(x{:}), cellfun(@(x,y) x(y), SpdTuningDiff, earlySessions, 'uni', false), 'uni', false))))
bar(2,nanmedian(abs(AllNSMRSSpdDiffSameDend)))
set(gca, 'XTick', [1 2])
set(gca, 'XTickLabel', {'MRS-MRS', 'NS-MRS'})
xtickangle(45)
title('Speed')
ylabel('Tuning Difference')

%==========================================================================
allearlyMRSaligned = cell2mat(horzcat(earlyMRSMovAlignedActivity{:})');
earlyMRS_Onset = cell2mat(horzcat(earlyMRS_onset_time{:}));
[early_val, early_ind] = sort(earlyMRS_Onset);
figure('Name', 'MRS Sorted by Onset'); 
subplot(1,3,1); 
imagesc(zscore(allearlyMRSaligned(early_ind(~isnan(early_val)),PreMovWindow-60:end),[],2))
hold on; plot([60 60], [1 size(allearlyMRSaligned,1)], '--w', 'linewidth', 2)
title('Early MRSs')
allmidMRSaligned = cell2mat(horzcat(midMRSMovAlignedActivity{:})');
midMRS_Onset = cell2mat(horzcat(midMRS_onset_time{:}));
[mid_val, mid_ind] = sort(midMRS_Onset);
subplot(1,3,2); 
imagesc(zscore(allmidMRSaligned(mid_ind(~isnan(mid_val)),PreMovWindow-60:end),[],2))
hold on; plot([60 60], [1 size(allmidMRSaligned,1)], '--w', 'linewidth', 2)
title('mid MRSs')
subplot(1,3,3); 
allMRSaligned = cell2mat(horzcat(MRSMovAlignedActivity{:})');
MRS_Onset = cell2mat(horzcat(MRS_onset_time{:}));
[val, ind] = sort(MRS_Onset);
imagesc(zscore(allMRSaligned(ind(~isnan(val)),PreMovWindow-60:end),[],2))
hold on; plot([60 60], [1 size(allMRSaligned,1)], '--w', 'linewidth', 2)
title('Late MRSs')
%==========================================================================

figure('Name', 'MRSs Sorted by Peak'); 
subplot(1,3,1)
activitydata = allearlyMRSaligned(:,PreMovWindow-60:end);
[earlyMRSpeak,earlyMRSpeak_loc] = max(activitydata,[],2);
[earlyMRSpeaksortedval, earlyMRSpeaksorted_loc] = sort(earlyMRSpeak_loc);
imagesc(zscore(activitydata(earlyMRSpeaksorted_loc(~isnan(earlyMRSpeaksortedval)),:),[],2))
title('Early')

subplot(1,3,2)
activitydata = allmidMRSaligned(:,PreMovWindow-60:end);
[midMRSpeak,midMRSpeak_loc] = max(activitydata,[],2);
[midMRSpeaksortedval, midMRSpeaksorted_loc] = sort(midMRSpeak_loc);
imagesc(zscore(activitydata(midMRSpeaksorted_loc(~isnan(midMRSpeaksortedval)),:),[],2))
title('Mid')

subplot(1,3,3)
activitydata = allMRSaligned(:,PreMovWindow-60:end);
[MRSpeak,MRSpeak_loc] = max(activitydata,[],2);
[MRSpeaksortedval, MRSpeaksorted_loc] = sort(MRSpeak_loc);
imagesc(zscore(activitydata(MRSpeaksorted_loc(~isnan(MRSpeaksortedval)),:),[],2))
title('Late')

%==========================================================================
NS_Onset = cell2mat(horzcat(NS_onset_time{:}));
NS_Onset = NS_Onset(~isnan(NS_Onset));
MRS_Onset = MRS_Onset(~isnan(MRS_Onset));
figure; hold on; 
histogram(MRS_Onset/58.3, 'normalization', 'probability', 'binedges', [-3:0.1:1.5])
histogram(NS_Onset/58.3, 'normalization', 'probability', 'binedges', [-3:0.1:1.5])
%==========================================================================

allNSaligned = cell2mat(horzcat(NSMovAlignedActivity{:})');

figure('Name', 'NSs Sorted by Peak'); 
activitydata = allNSaligned(:,PreMovWindow-60:end);
[NSpeak,NSpeak_loc] = max(activitydata,[],2);
[NSpeaksortedval, NSpeaksorted_loc] = sort(NSpeak_loc);
imagesc(zscore(activitydata(NSpeaksorted_loc(~isnan(NSpeaksortedval)),:),[],2))
title('NS Activity Peak')
