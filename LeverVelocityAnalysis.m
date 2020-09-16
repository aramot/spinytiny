
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 20: Timing, Position, and Velocity of activity-containing
%%% movements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lags = [-250, -150, -100, -50, -25, 0, 50, 100, 150, 250, 500, 750, 1000, 1250, 1500]; 
use_lags = 1:length(lags);

LevVelSD_record = [];
ShuffSD_record = [];


min_acceptable_mov_num = 2;
%%%
a = horzcat(LeverPositionatClustActivityOnset{:});
b = horzcat(LeverVelocityatClustActivityOnset{:});
c = horzcat(LeverVelocityatRandomLagsfromOnset{:});
ClustLeverPos = [];
ClustLeverPosSD = cell(1,length(a));
ClustLeverVel = [];
ClustLeverVelSD = cell(1,length(b));
ClustLeverVelSD_ForFiltering = cell(1,length(b));
ClustLeverSpeed = cell(1,length(b));
RandLagLeverSpeed = cell(1,length(c));
RandLagLeverVelSD = cell(1,length(c));
lowestSD_lag = [];
for field = 1:length(a)
    for newspine = 1:length(a{field})
        ClustLeverPos = [ClustLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}{newspine}, 'uni', false)')];   %%% Needs to be stored BY SPINE PAIR; i.e. cannot average by field/animal
        samplenumfilt = cellfun(@(x) size(x,1), a{field}{newspine})>=min_acceptable_mov_num;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}{newspine}(samplenumfilt), 'uni', false)');
        ClustLeverPosSD{field} = [ClustLeverPosSD{field}; posSD];
        ClustLeverVel = [ClustLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}{newspine}, 'uni', false)')];                 %%% Needs to be stored BY SPINE PAIR; i.e. cannot average by field/animal
        ave_speed = cell2mat(cellfun(@(x) nanmean(abs(x),1), b{field}{newspine}(samplenumfilt), 'uni', false)');
        ClustLeverSpeed{field} = [ClustLeverSpeed{field}; ave_speed];
        velSD = cell2mat(cellfun(@(x) nanstd(x(:,use_lags),[],1)./nanmean(abs(x(:,use_lags)),1), b{field}{newspine}(samplenumfilt), 'uni', false)');
%         velSD(velSD==0) = nan;
        [~,ind] = min(velSD,[],2);
        lowestSD_lag = [lowestSD_lag; ind];
        ClustLeverVelSD_ForFiltering{field} = [ClustLeverVelSD_ForFiltering{field}; cell2mat(cellfun(@(x) nanstd(x,[],1), b{field}{newspine}, 'uni', false)')];
        ClustLeverVelSD{field} = [ClustLeverVelSD{field}; velSD];
        
        randlag_speed = cell2mat(cellfun(@(x) nanmean(abs(x),1), c{field}{newspine}(samplenumfilt), 'uni', false)');
        RandLagLeverSpeed{field} = [RandLagLeverSpeed{field}; randlag_speed];
        rand_lag_velSD = cell2mat(cellfun(@(x) nanstd(x(:,use_lags),[],1)./nanmean(abs(x(:,use_lags)),1), c{field}{newspine}(samplenumfilt), 'uni', false)');
%         rand_lag_velSD(rand_lag_velSD==0) = nan;
%         [~,ind] = min(rand_lag_velSD,[],2);
        RandLagLeverVelSD{field} = [RandLagLeverVelSD{field}; rand_lag_velSD];
    end
end

%% Align each NS-MRS pair to its preferred lag (i.e. lowest SD)

AllClustSD = vertcat(ClustLeverVelSD{:});
AllClustSD = AllClustSD(setdiff(1:size(AllClustSD,1),find(~(sum(~isnan(AllClustSD),2)))),:);
AllClustSD_AlignedMat = nan(size(AllClustSD,1),2*length(use_lags)-1);
AllRandLag = vertcat(RandLagLeverVelSD{:});
AllRandLag = AllRandLag(setdiff(1:size(AllRandLag,1),find(~(sum(~isnan(AllRandLag),2)))),:);
AllRandLag_AlignedMat = nan(size(AllRandLag,1),2*length(use_lags)-1);
figure; dip_plot = gca; hold on; 

xvals = [1:length(use_lags)];
for i = 1:size(AllClustSD,1)
    coord = xvals-find(AllClustSD(i,:) == nanmin(AllClustSD(i,:)), 1,'first');
    AllClustSD_AlignedMat(i,coord+length(use_lags)) = AllClustSD(i,:);
    coord = xvals-find(AllRandLag(i,:) == nanmin(AllRandLag(i,:)), 1, 'first');
    AllRandLag_AlignedMat(i,coord+length(use_lags)) = AllRandLag(i,:);
%     plot(coord, AllClustSD(i,:))
end
plot(dip_plot,nanmean(AllClustSD_AlignedMat,1), 'k', 'linewidth', 2)
plot(dip_plot,nanmean(AllRandLag_AlignedMat,1), 'color', purple, 'linewidth', 2)

%%% Only when filtering for high CoA values; inelegant way to remove zero
%%% STD sets, which are always from n = 1 movement (checks to see if ALL
%%% lags get zero std, which should be impossible unless only 1 movement)
for i = 1:length(ClustLeverVelSD_ForFiltering)
    for j = 1:size(ClustLeverVelSD_ForFiltering{i},1)
        if ~any(~isnan(ClustLeverVelSD_ForFiltering{i}(j,:)))
            ClustLeverVelSD_ForFiltering{i}(j,:) = nan(1,length(lags));
        end
    end
end

a = horzcat(LeverPositionatShuffledActivityOnset{:});
b = horzcat(LeverVelocityatShuffledActivityOnset{:});
ShuffLeverPos = [];
ShuffLeverPosSD = cell(1,length(a));
ShuffLeverVel = [];
ShuffLeverVelSD = cell(1,length(b));
ShuffLeverVelSD_ForFiltering = cell(1,length(b));
ShuffLeverSpeed = cell(1,length(b));
for field = 1:length(a)
    for newspine = 1:length(a{field})
        ShuffLeverPos = [ShuffLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}{newspine}, 'uni', false)')];
        samplenumfilt = cellfun(@(x) size(x,1), a{field}{newspine})>=min_acceptable_mov_num;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}{newspine}(samplenumfilt), 'uni', false)');
        ShuffLeverPosSD{field} = [ShuffLeverPosSD{field}; posSD];
        ShuffLeverVel = [ShuffLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}{newspine}, 'uni', false)')];
        ave_speed = cell2mat(cellfun(@(x) nanmean(abs(x),1), b{field}{newspine}(samplenumfilt), 'uni', false)');
        ShuffLeverSpeed{field} = [ShuffLeverSpeed{field}; ave_speed];

        %             b{field}{newspine} = cellfun(@(x) [x; shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2);shake(shake(x,1),2)], b{field}{newspine}, 'uni', false);
        velSD = cell2mat(cellfun(@(x) nanstd(x(:,use_lags),[],1)./nanmean(abs(x(:,use_lags)),1), b{field}{newspine}(samplenumfilt), 'uni', false)');
%         velSD(velSD==0) = nan;
        ShuffLeverVelSD_ForFiltering{field} = [ShuffLeverVelSD_ForFiltering{field}; cell2mat(cellfun(@(x) nanstd(x,[],1), b{field}{newspine}, 'uni', false)')];
        ShuffLeverVelSD{field} = [ShuffLeverVelSD{field}; velSD];
    end
end

%%% Only when filtering for high CoA values; inelegant way to remove zero
%%% STD sets, which are always from n = 1 movement (checks to see if ALL
%%% lags get zero std, which should be impossible unless only 1 movement)
for i = 1:length(ShuffLeverVelSD_ForFiltering)
    for j = 1:size(ShuffLeverVelSD_ForFiltering{i},1)
        if ~any(~isnan(ShuffLeverVelSD_ForFiltering{i}(j,:)))
            ShuffLeverVelSD_ForFiltering{i}(j,:) = nan(1,length(lags));
        end
    end
end

%% Align each NS-MRS pair to its preferred lag (i.e. lowest SD)
AllShuffSD = vertcat(ShuffLeverVelSD{:});
AllShuffSD = AllShuffSD(setdiff(1:size(AllShuffSD,1),find(~(sum(~isnan(AllShuffSD),2)))),:);
AllShuffSD_AlignedMat = nan(size(AllShuffSD,1),2*length(use_lags)-1);
for i = 1:size(AllShuffSD,1)
    coord = xvals-find(AllShuffSD(i,:) == nanmin(AllShuffSD(i,:)), 1, 'first');
    AllShuffSD_AlignedMat(i,coord+length(use_lags)) = AllShuffSD(i,:);
%     plot(coord, AllShuffSD(i,:))
end
plot(dip_plot,nanmean(AllShuffSD_AlignedMat,1), 'r', 'linewidth', 2)


%%% If you want to exclude high CoA values, run the following:
% count = 1;
% for i = 1:length(ClustLeverVelSD_ForFiltering)
%     for j = 1:size(ClustLeverVelSD_ForFiltering{i})
%         if MRScoAlist(count) > CoA_Cutoff
%             ClustLeverVelSD_ForFiltering{i}(j,:) = nan(1,length(lags));
%             ShuffLeverVelSD_ForFiltering{i}(j,:) = nan(1,length(lags));
%             count = count+1;
%         else
%             count = count+1;
%         end
%     end
% end

a = horzcat(LeverPositionatNSOnlyActivityOnset{:});
b = horzcat(LeverVelocityatNSOnlyActivityOnset{:});
c = horzcat(LeverVelocityatShuffledNSActivityOnset{:});
NSOnlyLeverPos = [];
NSOnlyLeverPosSD = cell(1,length(a));
NSOnlyLeverVel = [];
NSOnlyLeverVelSD = cell(1,length(b));
NSOnlyShuffledVelSD = cell(1,length(c));
NSonlyLeverSpeed = cell(1,length(b));
for field = 1:length(a)
    if ~isempty(a{field})
        NSOnlyLeverPos = [NSOnlyLeverPos; cell2mat(cellfun(@(x) nanmedian(x,1), a{field}, 'uni', false)')];
        samplenumfilt = cellfun(@(x) size(x,1), a{field})>=min_acceptable_mov_num;
        posSD = cell2mat(cellfun(@(x) nanstd(x,[],1), a{field}(samplenumfilt), 'uni', false)');
        NSOnlyLeverPosSD{field} = [NSOnlyLeverPosSD{field}; posSD];
        NSOnlyLeverVel = [NSOnlyLeverVel; cell2mat(cellfun(@(x) nanmedian(x,1), b{field}, 'uni', false)')];
        ave_speed = cell2mat(cellfun(@(x) nanmean(abs(x),1), b{field}(samplenumfilt), 'uni', false)');
        NSonlyLeverSpeed{field} = [NSonlyLeverSpeed{field}; ave_speed];

        velSD = cell2mat(cellfun(@(x) nanstd(x(:,use_lags),[],1)./nanmean(abs(x(:,use_lags)),1), b{field}(samplenumfilt), 'uni', false)');
%         velSD(velSD==0) = nan;
        NSOnlyLeverVelSD{field} = [NSOnlyLeverVelSD{field}; velSD];
        shuffSD = cell2mat(cellfun(@(x) nanstd(x,[],1) , c{field}(samplenumfilt), 'uni', false)');
        shuffSD(shuffSD==0) = nan;

        NSOnlyShuffledVelSD{field} = [NSOnlyShuffledVelSD{field}; shuffSD];
    end
end

AllNSOnlySD = vertcat(NSOnlyLeverVelSD{:});
AllNSOnlySD = AllNSOnlySD(setdiff(1:size(AllNSOnlySD,1),find(~(sum(~isnan(AllNSOnlySD),2)))),:);
AllNSOnlySD_AlignedMat = nan(size(AllNSOnlySD,1),2*length(use_lags)-1);
for i = 1:size(AllNSOnlySD,1)
    coord = xvals-find(AllNSOnlySD(i,:) == nanmin(AllNSOnlySD(i,:)), 1, 'first');
    AllNSOnlySD_AlignedMat(i,coord+length(use_lags)) = AllNSOnlySD(i,:);
%     plot(coord, AllShuffSD(i,:))
end
plot(dip_plot,nanmean(AllNSOnlySD_AlignedMat,1), 'c', 'linewidth', 2)

a = horzcat(LeverVelocityatMRSOnlyActivityOnset{:});
b = horzcat(LeverVelocityatShuffledMRSActivityOnset{:});
MRSOnlyLeverVelSD = cell(1,length(a));
MRSOnlyShuffledVelSD = cell(1,length(b));
MRSonlyLeverSpeed = cell(1,length(b)); 
for field = 1:length(a)
    for newspine = 1:length(a{field})
        if ~isempty(a{field})
            samplenumfilt = cellfun(@(x) size(x,1), a{field}{newspine})>=min_acceptable_mov_num;
            ave_speed = cell2mat(cellfun(@(x) nanmean(abs(x),1), a{field}{newspine}(samplenumfilt), 'uni', false)');
            MRSonlyLeverSpeed{field} = [MRSonlyLeverSpeed{field}; ave_speed];
            velSD = cell2mat(cellfun(@(x) nanstd(x(:,use_lags),[],1)./nanmean(abs(x(:,use_lags)),1), a{field}{newspine}(samplenumfilt), 'uni', false)');
%             velSD(velSD==0) = nan;
            MRSOnlyLeverVelSD{field} = [MRSOnlyLeverVelSD{field}; velSD];
            shuffSD = cell2mat(cellfun(@(x) nanstd(x,[],1) , b{field}{newspine}(samplenumfilt), 'uni', false)');
            MRSOnlyShuffledVelSD{field} = [MRSOnlyShuffledVelSD{field}; shuffSD];
        end
    end
end
    
AllMRSOnlySD = vertcat(MRSOnlyLeverVelSD{:});
AllMRSOnlySD = AllMRSOnlySD(setdiff(1:size(AllMRSOnlySD,1),find(~(sum(~isnan(AllMRSOnlySD),2)))),:);
AllMRSOnlySD_AlignedMat = nan(size(AllMRSOnlySD,1),2*length(use_lags)-1);
for i = 1:size(AllMRSOnlySD,1)
    coord = xvals-find(AllMRSOnlySD(i,:) == nanmin(AllMRSOnlySD(i,:)), 1, 'first');
    AllMRSOnlySD_AlignedMat(i,coord+length(use_lags)) = AllMRSOnlySD(i,:);
%     plot(coord, AllShuffSD(i,:))
end
plot(dip_plot,nanmean(AllMRSOnlySD_AlignedMat,1), 'g', 'linewidth', 2)
    
for chosen_lag_address = 1:length(use_lags)

%     datamat = [{ClustLeverPos(:,chosen_lag_address)},{ShuffLeverPos(:,chosen_lag_address)},{NSOnlyLeverPos(:,chosen_lag_address)}];

%     subplot(3,2,3); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;
% 
%     Y = cell(1,length(datamat));
%     for i = 1:length(datamat)
%         try
%             plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
%             Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
%             line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
%         catch
%             Y{i} = [];
%         end
%     end
% 
%     maxline = max(cell2mat(Y'));
%     statline_increment = nanmedian(datamat{1})/5;
% 
%     for i = 2:length(datamat)
%         [p,~] = ranksum(datamat{1},datamat{i});
%         if p<0.05
%             if p < 0.001
%                 statsymbol = '***';
%             elseif p<0.01
%                 statsymbol = '**';
%             elseif p<0.05
%                 statsymbol = '*';
%             end
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'g')
%             text(mean([1,(i)])-0.1, maxline+0.01, statsymbol)
%         else
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
%             text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
%         end
%         maxline = maxline+statline_increment;
%     end
% 
%     set(gca, 'XTick', [1:length(datamat)])
%     set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})
% 
%     ylabel('Lever Position')

%     datamat = [{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ClustLeverPosSD(~cellfun(@isempty,ClustLeverPosSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ShuffLeverPosSD(~cellfun(@isempty,ShuffLeverPosSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSOnlyLeverPosSD(~cellfun(@isempty, NSOnlyLeverPosSD)))}];

%     subplot(3,2,4); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;
% 
%     Y = cell(1,length(datamat));
%     for i = 1:length(datamat)
%         try
%             plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
%             Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
%             line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
%         catch
%             Y{i} = [];
%         end
%     end
% 
%     maxline = max(cell2mat(Y'));
%     statline_increment = nanmedian(datamat{1})/5;
% 
%     for i = 2:length(datamat)
%         [p,~] = ranksum(datamat{1},datamat{i});
%         if p<0.05
%             if p < 0.001
%                 statsymbol = '***';
%             elseif p<0.01
%                 statsymbol = '**';
%             elseif p<0.05
%                 statsymbol = '*';
%             end
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'g')
%             text(mean([1,(i)])-0.1, maxline+0.01, statsymbol)
%         else
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
%             text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
%         end
%         maxline = maxline+statline_increment;
%     end
% 
%     set(gca, 'XTick', [1:length(datamat)])
%     set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})
% 
%     ylabel('Lever Position SD')
% 
%     datamat = [{ClustLeverVel(:,chosen_lag_address)},{ShuffLeverVel(:,chosen_lag_address)},{NSOnlyLeverVel(:,chosen_lag_address)}];
%     subplot(3,2,5); hold on; bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;
% 
%     Y = cell(1,length(datamat));
%     for i = 1:length(datamat)
%         try
%             plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
%             Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
%             line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
%         catch
%             Y{i} = [];
%         end
%     end
% 
%     maxline = max(cell2mat(Y'));
%     statline_increment = nanmedian(datamat{1})/5;
% 
%     for i = 2:length(datamat)
%         [p,~] = ranksum(datamat{1},datamat{i});
%         if p<0.05
%             if p < 0.001
%                 statsymbol = '***';
%             elseif p<0.01
%                 statsymbol = '**';
%             elseif p<0.05
%                 statsymbol = '*';
%             end
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'g')
%             text(mean([1,(i)])-0.1, maxline+0.01, statsymbol)
%         else
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
%             text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
%         end
%         maxline = maxline+statline_increment;
%     end
% 
%     set(gca, 'XTick', [1:length(datamat)])
%     set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})
% 
%     ylabel('Lever Velocity SD')
% 
%     set(gca, 'XTick', [1:length(datamat)])
%     set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only'})
% 
%     ylabel('Lever Velocity')

    datamat = [{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ClustLeverVelSD(cellfun(@(x) size(x,1)>1, ClustLeverVelSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ShuffLeverVelSD(cellfun(@(x) size(x,1)>1, ClustLeverVelSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSOnlyLeverVelSD(~cellfun(@isempty, NSOnlyLeverVelSD)))}, {cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSOnlyShuffledVelSD(~cellfun(@isempty, NSOnlyShuffledVelSD)))},{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), MRSOnlyLeverVelSD(~cellfun(@isempty, MRSOnlyLeverVelSD)))}, {cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), MRSOnlyShuffledVelSD(~cellfun(@isempty, MRSOnlyShuffledVelSD)))}];

    datamat2 = [{cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ClustLeverSpeed(cellfun(@(x) size(x,1)>1, ClustLeverSpeed)))}, {cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), ShuffLeverSpeed(cellfun(@(x) size(x,1)>1, ShuffLeverSpeed)))}, {cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), NSonlyLeverSpeed(cellfun(@(x) size(x,1)>1, NSonlyLeverSpeed)))}, {cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), MRSonlyLeverSpeed(cellfun(@(x) size(x,1)>1, MRSonlyLeverSpeed)))}]; 
%     subplot(3,2,6); hold on; 
%     bar(1:length(datamat), cellfun(@nanmedian, datamat), 'FaceColor', lblue); hold on;
% 
%     Y = cell(1,length(datamat));
%     for i = 1:length(datamat)
%         try
%             plot(linspace(i-0.25,i+0.25,length(datamat{i})), datamat{i}, '.k', 'Markersize', 14)
%             Y{i} = bootci(bootstrpnum, {@median, datamat{i}(~isnan(datamat{i}))}, 'alpha', 0.05);
%             line([i,i], [Y{i}(1), Y{i}(2)], 'linewidth', 0.5, 'color', 'r');
%         catch
%             Y{i} = [];
%         end
%     end
% 
%     maxline = max(cell2mat(Y'));
%     statline_increment = nanmedian(datamat{1})/5;
% 
%     for i = 2:length(datamat)
%         [p,~] = ranksum(datamat{1},datamat{i});
%         if p<0.05
%             if p < 0.001
%                 statsymbol = '***';
%             elseif p<0.01
%                 statsymbol = '**';
%             elseif p<0.05
%                 statsymbol = '*';
%             end
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'g')
%             text(mean([1,(i)])-0.1, maxline+0.01, statsymbol)
%         else
%             plot(1:i, (maxline+0.01)*ones(1,i), '-', 'Linewidth', 2, 'Color', 'r')
%             text(mean([1,(i)])-0.1, maxline+0.01, 'ns')
%         end
%         maxline = maxline+statline_increment;
%     end
% 
%     set(gca, 'XTick', [1:length(datamat)])
%     set(gca, 'XTickLabel', {'Clusters','Shuffled','NS only', 'Shuffled', 'MRS Only', 'Shuffled'})
%     set(gcf, 'Name', ['lag = ', num2str(lags(chosen_lag_address)), 'ms'])

    ylabel('Lever Velocity SD')
    
    LevVelSD_record{chosen_lag_address} = datamat{1};
    NSonly_record{chosen_lag_address} = datamat{3};
    MRSonly_record{chosen_lag_address} = datamat{5};
    ShuffSD_record{chosen_lag_address} = datamat{2}; 
    randlag_record{chosen_lag_address} = cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), RandLagLeverVelSD(cellfun(@(x) size(x,1)>1, RandLagLeverVelSD)));
    
    LevSpeed_record{chosen_lag_address} = datamat2{1};
    ShuffSpeed_record{chosen_lag_address} = datamat2{2};
    NSonlySpeed_record{chosen_lag_address} = datamat2{3};
    MRSonlySpeed_record{chosen_lag_address} = datamat2{4};
    randlagSpeed_record{chosen_lag_address} = cellfun(@(x) nanmedian(x(:,chosen_lag_address),1), RandLagLeverSpeed(cellfun(@(x) size(x,1)>1, RandLagLeverSpeed)));
end

