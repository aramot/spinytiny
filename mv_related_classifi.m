function [movement_cells, quiescent_cells, movement_p] = mv_related_classifi (df, lever_switch_frame, type)
% Classifiy whether roi is movement related based on shuffling procedure
%[movement_cells, quiescent_cells] = mv_related_classifi (df, lever)
%
%INPUT: 
%   df: roi x frame df/f matrix
%   lever: can be either lever_switch_frame [nx2] or lever_active_frames [1xnframe]
%OUTPUT:
%   movement_cells: label logic vector for ROIs
%   quiescent_cells
%   also return the percentile
%%
%make epochs
% workable with both switch frame format nx2 or lever_active_frames format
% 1xn

% disp(['classifying ', type , ' related ROIs']);

if size(df,1)>size(df,2)
    df = df';
else
end

lever_switch_frame = lever_switch_frame';

if any(size(lever_switch_frame) == 1) % input is a vector = lever_active_frames
    lever_active_frames = lever_switch_frame;
    if size(df,2) ~= length(lever_active_frames)
       disp('df and lever length does not match, use the shorter one');
       df = df(:,1:min([size(df,2),length(lever_active_frames)]));
       lever_active_frames = lever_active_frames(1:min([size(df,2),length(lever_active_frames)]));       
    end      
else    
    frame_num = size(df, 2);
    % remake the active vector
    lever_active_frames = false(frame_num,1);
    for i = 1:size(lever_switch_frame)
        lever_active_frames(lever_switch_frame(i,1):lever_switch_frame(i,2)) = true;
    end
end
% use Andy's method
% make re-format epochs
boundary_frames = find(diff([Inf;lever_active_frames;Inf]) ~= 0);
lever_active_frames_split = mat2cell(lever_active_frames,diff(boundary_frames));

% shuffle
num_rep = 1000;
shuffle_perms = shake(repmat([1:length(lever_active_frames_split)]',1,num_rep),1);
lever_active_shuffle = nan(length(lever_active_frames),num_rep);
for i = 1:num_rep
    lever_active_shuffle(:,i) = ...
        vertcat(lever_active_frames_split{shuffle_perms(:,i)});
end
clear shuffle_perms

%%% Classify ROIs according to movement/quiescence preference
movement_activity = df*lever_active_frames;

shuffle_movement_activity = df*lever_active_shuffle;
clear lever_active_shuffle

movement_rank = tiedrank([movement_activity shuffle_movement_activity]')';
movement_p = movement_rank(:,1)/(num_rep+1);
movement_cells = movement_p > 0.975;
quiescent_cells = movement_p < 0.025;

return
%% plot

lever_logic = lever_active_frames + 1-1;
lever_logic(lever_logic==0) = NaN;
figure; hold on
for i_cell = 1:size(df,1)
    if movement_cells(i_cell)
        plot(1:size(df,2), df(i_cell,:)+i_cell-1,'b');
        plot(1:size(df,2), bsxfun(@times,  df(i_cell,:), lever_logic')+i_cell-1,'r');
    elseif quiescent_cells(i_cell)
        plot(1:size(df,2), df(i_cell,:)+i_cell-1,'g');
        plot(1:size(df,2), bsxfun(@times,  df(i_cell,:), lever_logic')+i_cell-1,'r');
    else
        plot(1:size(df,2), df(i_cell,:)+i_cell-1,'k');
        plot(1:size(df,2), bsxfun(@times,  df(i_cell,:), lever_logic')+i_cell-1,'r');
    end
end

return
figure; hold on
for i_cell = 1:size(df_F,1)
    plot(1:size(df_F,2), df_F(i_cell,:)+i_cell-1);
    plot(1:size(df_F,2), bsxfun(@times,  df_F(i_cell,:), lever_logic')+i_cell-1,'r');
    
end


figure; hold on
for i_cell = 1:size(df,1)
    plot(1:size(df,2), df_raw(i_cell,:)+i_cell-1,'k');
    
    plot(1:size(df,2), caEvents_2(i_cell,:)+i_cell-1,'r');
    
end
return

%% old
%%
%swith points
points = lever_switch_frame'; points = points(:);
%add first and last
if points(1) ~= 1; points = [1; points]; end
if points(end) ~= frame_num; points = [points; frame_num]; end

epoch = cat(2,points(1:end-1), points(2:end));
if lever_switch_frame(1,1) == 1 % first epoch is active -> active epoch are odds
    idx_active = 1:2:size(epoch,1);
    idx_quite = 2:2:size(epoch,1);
    %fix overlap
    epoch(idx_quite,1) = epoch(idx_quite,1)+1;
    epoch(idx_quite,2) = epoch(idx_quite,2)-1;
    epoch(end) = frame_num;
else % active are even
    idx_quite = 1:2:size(epoch,1);
    idx_active = 2:2:size(epoch,1);
    %fix overlap
    epoch(idx_quite(2:end),1) = epoch(idx_quite(2:end),1)+1;
    epoch(idx_quite,2) = epoch(idx_quite,2)-1;
    epoch(end) = frame_num;
end
%make frame number arrays
for i = 1:size(epoch,1)
    epoch_frame{i} = epoch(i,1):epoch(i,2);
end

mean_df_active = mean( df(:, [epoch_frame{idx_active}]),2);
mean_df_quite = mean( df(:, [epoch_frame{idx_quite}]),2);

%shuffle
n_shuffle = 100;
mean_df_active_shufle = zeros(size(df,1),n_shuffle);
mean_df_quite_shufle = mean_df_active_shufle;
for i = 1:n_shuffle
    epoch_frame_perm = epoch_frame(randperm(length(epoch_frame)));
    mean_df_active_shufle(:,i) = mean( df(:, [epoch_frame_perm{idx_active}]),2);
    mean_df_quite_shufle(:,i) = mean( df(:, [epoch_frame_perm{idx_quite}]),2);
end

figure; hold on;
plot(mean_df_active,'k');
plot(max(mean_df_active_shufle,[],2),'r');

% different way perm
%shuffle
n_shuffle = 100;
mean_df_active_shufle = zeros(size(df,1),n_shuffle);
mean_df_quite_shufle = mean_df_active_shufle;
for i = 1:n_shuffle
    %     epoch_frame_perm = epoch_frame(randperm(length(epoch_frame)));
    mean_df_active_shufle(:,i) = mean( df(:, [epoch_frame{randperm(length(epoch_frame),length(idx_active))}]),2);
    mean_df_quite_shufle(:,i) = mean( df(:, [epoch_frame{randperm(length(epoch_frame),length(idx_quite))}]),2);
end

figure; hold on;
plot(mean_df_active,'k');
plot(max(mean_df_active_shufle,[],2),'r');

%same result: real > max shuffle

mean_df_active_thre = median(mean_df_active_shufle,2);
mean_df_quite_thre =  median(mean_df_quite_shufle,2);

logic_active = (mean_df_active - mean_df_active_thre)>0;
logic_quite = (mean_df_quite - mean_df_quite_thre)>0;


return
%plot
hist(mean_df_active_shufle(7,:))
figure; hist(mean_df_quite_shufle(7,:))

plot(median(mean_df_active_shufle,2),median(mean_df_quite,2),'o')

figure; hold on;
plot(mean_df_active,'k');
plot(max(mean_df_active_shufle,[],2),'r');

figure; hold on;
plot(mean_df_active,'k');
plot(mean_df_quite,'r');

i=i+1;
figure; hold on
plot(df(i,:),'k');
plot(bsxfun(@times,  df(i,:), lever_logic{1}),'r');



% below are old attemps


%% extend movement epoch by 5 frame before and after

move_epochs = lever_switch_frame;
move_epochs(:,1) = move_epochs(:,1) -5;
move_epochs(:,2) = move_epochs(:,2) +5;
if move_epochs(1,1) <0 ; move_epochs(1,1) = 1; end
move_epoch_length = move_epochs(:,2) - move_epochs(:,1);
logic_available = ones(1,frame_num);
for i = 1:size(move_epochs,1)
    %pick a insertion point
    idx_start = ceil(rand(1)*frame_num);
    idx_end = idx_start + move_epoch_length(i) -1;
    n = 1;
    while (idx_end > frame_num || ~isempty(find(logic_available (idx_start:idx_end) == 0))) % not valid selection
        idx_start = ceil(rand(1)*frame_num);
        idx_end = idx_start + move_epoch_length(i) -1;
        n = n+1;
        if n> 10000
            disp(n)
        end
    end
    move_epochs_shuffle(i,:) = [idx_start idx_end];
    logic_available(idx_start:idx_end) = 0;
end


% this method is slow
% make epochs as each quite frame is a epoch -> then permute is like doing
% insertion

%% Andy's new way, permute quiescent and movement epochs; keep quiet epochs' statistic the same
