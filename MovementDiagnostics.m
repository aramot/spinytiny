% function MovementDiagnostics(varargin)

global gui_KomiyamaLabHub
experimentnames = gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.String(gui_KomiyamaLabHub.figure.handles.AnimalName_ListBox.Value);

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    cd(gui_KomiyamaLabHub.DefaultOutputFolder)
end
h = waitbar(0, 'Collecting animal information');

for i = 1:length(experimentnames)
    waitbar(i/length(experimentnames), h, ['Collecting information for ', experimentnames{i}]);
    targetfile = [experimentnames{i}, '_Aligned'];
    load(targetfile)
    eval(['currentdata = ',targetfile, ';'])
    eval(['clear ', targetfile])

    used_sessions = cellfun(@(x) ~isempty(x), currentdata);
    all_lever_traces = cellfun(@(x) x.LeverMovement, currentdata(used_sessions), 'uni', false);
    all_lever_velocity = cellfun(@(x) diff([x.LeverMovement(1); x.LeverMovement]), currentdata(used_sessions), 'uni', false);
    
    for j = 1:length(all_lever_velocity)
        [~,tf] = rmoutliers(all_lever_velocity{j}, 'movmedian', 20);
        all_lever_velocity{j}(tf) = nan;
        nanx = isnan(all_lever_velocity{j}); t = 1:numel(all_lever_velocity{j});
        all_lever_velocity{j}(nanx) = interp1(t(~nanx), all_lever_velocity{j}(~nanx), t(nanx));
    end
    
    all_binary_traces = cellfun(@(x) x.Binarized_Lever, currentdata(used_sessions), 'uni', false);
    binary_sep = cellfun(@(x,y) mat2cell(y,diff(find(diff([~x(1); x; ~x(end)])~=0))), all_binary_traces, all_binary_traces, 'uni', false);
    velocity_sep = cellfun(@(x,y) mat2cell(y,diff(find(diff([~x(1); x; ~x(end)])~=0))), all_binary_traces, all_lever_velocity, 'uni', false);


    for j = 1:length(binary_sep)
        velocity_during_movs{j} = velocity_sep{j}(cellfun(@any, binary_sep{j}));
        all_velocity_during_movs_mat{j} = nan(size(velocity_during_movs{j},1),(max(cellfun(@length, velocity_during_movs{j}))));
        for k = 1:size(velocity_during_movs{j},1)
            all_velocity_during_movs_mat{j}(k,1:length(velocity_during_movs{j}{k})) = velocity_during_movs{j}{k};
        end
    end
    
    valid_columns = cellfun(@(x) sum(~isnan(x),1)>2, all_velocity_during_movs_mat, 'uni', false);
    mean_mov_speed = cellfun(@(x,y) nanmean(abs(x(:,y)),1), all_velocity_during_movs_mat, valid_columns, 'uni', false);
    lever_SD = cellfun(@(x,y) nanstd(x(:,y),[],1), all_velocity_during_movs_mat, valid_columns, 'uni', false);
    
    AllMeanMovSpeed{i} = mean_mov_speed;
    AllLeverSD{i} = lever_SD;
    
    clearvars '-except' 'AllMeanMovSpeed' 'AllLeverSD' 'experimentnames' 'gui_KomiyamaLabHub' 'h'
end

delete(h)