function AverageBehavior(varargin)

rewards = nan(length(varargin), 14);
ReactionTime = nan(length(varargin),14);
CuetoReward = nan(length(varargin),14);
MovementCorrelation = nan(14,14,length(varargin));
MovingAtTrialStartFaults = nan(length(varargin),14);
MoveDurationBeforeIgnoredTrials = nan(length(varargin),14);
NumberofMovementsDuringITIPreIgnoredTrials = nan(length(varargin),14);
FractionITISpentMoving = nan(length(varargin),14);
VarExpbyFirstComp = nan(length(varargin),14);

%%%%%%%%%%%%%%%%%%%%%%
%%Color Information%%%
%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    red = [0.93 0.11 0.14];     black = [0 0 0];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,magenta,orange,brown,lbrown};
    
%%%%%%%%%%%%%%%%%%%%%%%

rewards = nan(length(varargin), 14);
ReactionTime = nan(length(varargin), 14);
CuetoReward = nan(length(varargin), 14);
MovingAtTrialStartFaults = nan(length(varargin), 14);
MoveDurationBeforeIgnoredTrials = nan(length(varargin), 14);
NumberofMovementsDuringITIPreIgnoredTrials = nan(length(varargin), 14);
FractionITISpentMovingPreIgnoredTrials = nan(length(varargin), 14);
NumberofMovementsDuringITIPreRewardedTrials = nan(length(varargin), 14);
FractionITISpentMovingPreRewardedTrials = nan(length(varargin), 14);

for i = 1:length(varargin)
    %%%%
    FilteredSessions = find(cellfun(@(x) size(x,1),varargin{i}.MovementMat)>10);
    FilteredSessions = FilteredSessions(FilteredSessions<=14);
    %%%
    rewards(i,FilteredSessions) = varargin{i}.rewards(FilteredSessions);
    ReactionTime(i,FilteredSessions) = varargin{i}.ReactionTime(FilteredSessions);
    CuetoReward(i,FilteredSessions) = varargin{i}.CuetoReward(FilteredSessions);
    missingsessions = setdiff([1:14], FilteredSessions);
    MovingAtTrialStartFaults(i,FilteredSessions) = varargin{i}.MovingAtTrialStartFaults(FilteredSessions);
    MoveDurationBeforeIgnoredTrials(i,FilteredSessions) = varargin{i}.MoveDurationBeforeIgnoredTrials(FilteredSessions);
    NumberofMovementsDuringITIPreIgnoredTrials(i,FilteredSessions) = varargin{i}.NumberofMovementsDuringITIPreIgnoredTrials(FilteredSessions);
    FractionITISpentMovingPreIgnoredTrials(i,FilteredSessions) = varargin{i}.FractionITISpentMovingPreIgnoredTrials(FilteredSessions);
    NumberofMovementsDuringITIPreRewardedTrials(i,FilteredSessions) = varargin{i}.NumberofMovementsDuringITIPreRewardedTrials(FilteredSessions);
    FractionITISpentMovingPreRewardedTrials(i,FilteredSessions) = varargin{i}.FractionITISpentMovingPreRewardedTrials(FilteredSessions);

    
    if ~isempty(missingsessions)
        sessionsaccountedfor = [];
        for j = 1:length(missingsessions)
            if length(varargin{i}.MovementCorrelation)>=missingsessions(j)
                if ~sum(~isnan(varargin{i}.MovementCorrelation(missingsessions(j),:)))
                    sessionsaccountedfor = [sessionsaccountedfor, j];
                end
            end
        end
        sessionstoadd = setdiff(missingsessions, sessionsaccountedfor);
        newlength = length(varargin{i}.MovementCorrelation)+length(sessionstoadd);
        newmat = nan(newlength,newlength);
        newmat(FilteredSessions,FilteredSessions) = varargin{i}.MovementCorrelation(FilteredSessions,FilteredSessions);
        varargin{i}.MovementCorrelation = newmat;
    end
    MovementCorrelation(:,:,i) = varargin{i}.MovementCorrelation(1:14,1:14);
    VarExpbyFirstComp(i,FilteredSessions) = cellfun(@(x) x(1), varargin{i}.PCA_VarianceExplained(FilteredSessions));
end

rewards = rewards(:,1:14);
ReactionTime = ReactionTime(:,1:14);
CuetoReward = CuetoReward(:,1:14);
MovingAtTrialStartFaults = MovingAtTrialStartFaults(:,1:14);
MoveDurationBeforeIgnoredTrials = MoveDurationBeforeIgnoredTrials(:,1:14);
NumberofMovementsDuringITIPreIgnoredTrials = NumberofMovementsDuringITIPreIgnoredTrials(:,1:14);
FractionITISpentMovingPreIgnoredTrials = FractionITISpentMovingPreIgnoredTrials(:,1:14);

for i = 1:14
    rewardsSEM(1,i) = nanstd(rewards(:,i),0,1)/sqrt(sum(~isnan(rewards(:,i))));
    RTSEM(1,i) = nanstd(ReactionTime(:,i),0,1)/sqrt(length(~isnan(ReactionTime(:,i))));
    CtRSEM(1,i) = nanstd(CuetoReward(:,i),0,1)/sqrt(length(~isnan(CuetoReward(:,i))));
end

scrsz = get(0, 'ScreenSize');
figure('Position', scrsz);

subnum = ceil(sqrt(length(varargin)));

for i = 1:length(varargin)
    ax(i) = subplot(subnum,subnum,i); hold on;
    plot(FilteredSessions,varargin{i}.rewards(FilteredSessions)/100, 'Color', black, 'Linewidth', 2)
    plot(FilteredSessions,varargin{i}.ReactionTime(FilteredSessions)./nanmax(varargin{i}.ReactionTime(FilteredSessions)), 'Color',red, 'Linewidth', 2)
    plot(FilteredSessions,varargin{i}.CuetoReward(FilteredSessions)./nanmax(varargin{i}.CuetoReward(FilteredSessions)), 'Color', lblue, 'Linewidth', 2)
    withinsessions = diag(MovementCorrelation(1:14,1:14,i));
    plot(1:14,withinsessions./nanmax(withinsessions), 'Color', green, 'Linewidth', 2)
    acrosssessions = diag(MovementCorrelation(1:14,1:14, i),+1);
    plot(2:14,acrosssessions./nanmax(acrosssessions), 'Color', lgreen, 'Linewidth', 2)
    set(gca, 'XTick', 1:14)
%     ylim([-0.05 1.05])
    ylabel('Percent Max')
    xlabel('Session')
    file = regexp(inputname(i), '[A-Z]{2,3}0+[A-Z,0-9]*', 'match');
    title(file{1});
    plot(1:14, ones(1,14),'--k')
end

linkaxes(ax);

legend({'Percent Rewarded', 'Reaction Time', 'Cue to Reward', 'Mov Corr within', 'Mov Corr Across'},'Location','BestOutside')


scrsz = get(0, 'ScreenSize');
figure('Position', scrsz);

subplot(6,6,[1:3, 7:9]); 
flex_plot(1:14,rewards,'parametric','b',4); xlim([0 15]); ylabel('% Rewarded'); xlabel('Session');
set(gca, 'XTick', 1:14)
subplot(6,6,[4:6, 10:12]); 
reactplot = flex_plot(1:14, ReactionTime,'parametric', 'k',4); xlim([0 15]); ylabel('Time (s)'); xlabel('Session');
hold on; c2rplot = flex_plot(1:14, CuetoReward, 'parametric','r',4);
legend([reactplot, c2rplot], {'Reaction Time', 'Cue to Reward'});
set(gca, 'XTick', 1:14, 'YTick', 1:14)
subplot(6,6,[13:15, 19:21, 25:27, 31:33]); imagesc(nanmean(MovementCorrelation, 3))
set(gcf, 'ColorMap', hot); colorbar;
ylabel('Session', 'Fontsize', 14)
xlabel('Session', 'Fontsize', 14)
set(gca, 'XTick', 1:14, 'YTick', 1:14)
title('Movement correlation over sessions')

for i = 1:size(MovementCorrelation,3)
    within(i,1:14) = diag(MovementCorrelation(:,:,i));
end
for i = 1:size(MovementCorrelation,3)
    across(i,1:13) = diag(MovementCorrelation(:,:,i),1);
end

stattype = 'parametric'; 

subplot(6,6,[16:18, 22:24, 28:30, 34:36]);
withinplot = flex_plot(1:14,within,stattype,'k', 4); hold on;
acrossplot = flex_plot(2:14, across, stattype, [0.5 0.5 0.5], 4);

source = within;
data = source(logical(~isnan(source)));
session = 1:14;
session = repmat(session,size(source,1),1);
sesh = session(logical(~isnan(source)));
[~, p] = corrcoef(data, sesh);
if p(2,1) < 0.05
    statmessage = ['* ',num2str(p(2,1))];
else
    statmessage = ['n.s. (', num2str(p(2,1)), ')'];
end
text(14.5, max(nanmean(source,1)), statmessage)


source = across;
data = source(logical(~isnan(source)));
session = 1:14;
session = repmat(session,size(source,1),1);
sesh = session(logical(~isnan(source)));
[~, p] = corrcoef(data, sesh);
if p(2,1) < 0.05
    statmessage = ['* ',num2str(p(2,1))];
else
    statmessage = ['n.s. (', num2str(p(2,1)), ')'];
end
text(14.5, max(nanmean(source,1)), statmessage, 'Color', [0.5 0.5 0.5])

PCAplot = flex_plot(1:14, VarExpbyFirstComp./100, stattype, 'r', 4);

legend([withinplot, acrossplot, PCAplot], {'Within sessions', 'Across sessions', 'Expl. by PC1'})
ylabel('Correlation')
xlabel('Session')
xlim([0 16])
ylim([0 1])
set(gca, 'XTick', 1:14)

stattype = 'parametric';

figure('Position', scrsz); subplot(2,2,1); hold on; 
plot(MovingAtTrialStartFaults', 'Color', [ 0.7 0.7 0.7])
flex_plot(1:14, MovingAtTrialStartFaults, stattype, 'k', 4)
xlabel('Session')
ylabel({'% of Movements Ignored','Due to Movement at Start'})
ylim([0 100])

subplot(2,2,2); hold on; 
plot(MoveDurationBeforeIgnoredTrials', 'Color', [0.7 0.7 0.7])
flex_plot(1:14, MoveDurationBeforeIgnoredTrials, stattype, 'k', 4)
xlabel('Session')
ylabel('Duration of Movement Before Ignored Trials (s)')

subplot(2,2,3); hold on;
plot(NumberofMovementsDuringITIPreIgnoredTrials', 'Color', [0.7 0.7 0.7])
ignored = flex_plot(1:size(NumberofMovementsDuringITIPreIgnoredTrials,2), NumberofMovementsDuringITIPreIgnoredTrials, stattype, 'k',4);
rewarded = flex_plot(1:size(NumberofMovementsDuringITIPreRewardedTrials,2), NumberofMovementsDuringITIPreRewardedTrials, stattype, 'g', 4);
ylabel('Number of Movements During ITI')
xlabel('Session')
legend([ignored, rewarded], {'Ignored', 'Rewarded'}, 'Location', 'Northwest')
pos = get(gca,'Position');
axes('Position', [pos(1)+0.7*pos(3), pos(2)+0.7*pos(4), 0.25*pos(3), 0.25*pos(4)], 'Fontsize', 6);
integratedoversessions = nanmean(nansum(NumberofMovementsDuringITIPreIgnoredTrials,2));
bar(integratedoversessions)
r_errorbar(1,integratedoversessions, nanstd(nansum(NumberofMovementsDuringITIPreIgnoredTrials,2))/sqrt(size(NumberofMovementsDuringITIPreIgnoredTrials,1)), 'k');
xlim([0 2])

subplot(2,2,4); hold on;
plot(FractionITISpentMovingPreIgnoredTrials', 'Color', [0.7 0.7 0.7])
flex_plot(1:size(FractionITISpentMovingPreIgnoredTrials,2), FractionITISpentMovingPreIgnoredTrials, stattype, 'k',4)
flex_plot(1:size(FractionITISpentMovingPreRewardedTrials,2), FractionITISpentMovingPreRewardedTrials, stattype, 'g', 4)
xlabel('Session')
ylabel('Fraction of ITI Spent Moving')
