
laglist = [-60:2:60];

AllPosDiffList = [];
AllPosSTDList = [];
NSPosSTDList = []; 
for i = 1:length(PairPositionDiff)
    for j = 1:length(PairPositionDiff{i})
        AllPosDiffList = [AllPosDiffList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), PairPositionDiff{i}{j}, 'uni', false)')'];
        AllPosSTDList = [AllPosSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), MRSPositionSTD{i}{j}, 'uni', false)')'];
        NSPosSTDList = [NSPosSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), NSPositionSTD{i}{j}, 'uni', false)')'];
    end
end
for i = 1:length(laglist)
count = 1;
for j = 0:5:60
data = abs(AllPosDiffList(AllNSMRSDist>=j & AllNSMRSDist<j+5,i));
PosBins{i}(count) = nanmean(data);
PosBinsError{i}(count) = nanstd(data)./sqrt(sum(~isnan(data)));
count = count+1;
end
end
figure; 
subplot(1,3,3)
hold on; plot(1:length(laglist), 0.05*ones(1,length(laglist)), '--r')
hold on; plot(1:length(laglist), zeros(1,length(laglist)), '--k')
for i = 1:length(laglist)
subplot(1,3,1)
cla
errorbar(1:length(PosBins{i}), PosBins{i}, PosBinsError{i})
title([num2str(laglist(i))])
subplot(1,3,2)
cla
[r(i),p(i)] = QuickLinearFit(AllNSMRSDist, abs(AllPosDiffList(:,i)),2);
title([num2str(laglist(i))])
subplot(1,3,3)
if i == 1
    plot(p(i))
    hold on; plot(r(i))
else
    temp = get(gca, 'Children');
    set(temp(2),'YData', p(1:i))
    set(temp(1),'YData', r(1:i))
    xlim('auto')
    ylim('auto')
end
pause
end


AllVelDiffList = [];
AllVelSTDList = []; 
NSVelSTDList = []; 
for i = 1:length(PairVelocityDiff)
for j = 1:length(PairVelocityDiff{i})
AllVelDiffList = [AllVelDiffList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), PairVelocityDiff{i}{j}, 'uni', false)')'];
AllVelSTDList = [AllVelSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), MRSVelocitySTD{i}{j}, 'uni', false)')'];
NSVelSTDList = [NSVelSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), NSVelocitySTD{i}{j}, 'uni', false)')'];
end
end
for i = 1:length(laglist)
count = 1;
for j = 0:5:60
data = abs(AllVelDiffList(AllNSMRSDist>=j & AllNSMRSDist<j+5,i));
VelBins{i}(count) = nanmean(data);
VelBinsError{i}(count) = nanstd(data)./sqrt(sum(~isnan(data)));
count = count+1;
end
end

figure; 
subplot(1,3,3)
hold on; plot(1:length(laglist), 0.05*ones(1,length(laglist)), '--r')
hold on; plot(1:length(laglist), zeros(1,length(laglist)), '--k')

for i = 1:length(laglist)
subplot(1,3,1)
cla
errorbar(1:length(VelBins{i}), VelBins{i}, VelBinsError{i})
title([num2str(laglist(i))])
subplot(1,3,2)
cla
[r(i),p(i)] = QuickLinearFit(AllNSMRSDist, abs(AllVelDiffList(:,i)),2);
title([num2str(laglist(i))])
subplot(1,3,3)
if i == 1
    plot(p(i))
    hold on; plot(r(i))
else
    temp = get(gca, 'Children');
    set(temp(1),'YData', p(1:i))
    set(temp(2),'YData', r(1:i))
    xlim('auto')
    ylim('auto')
end
pause
end
hold on; plot(1:length(laglist), 0.05*ones(1,length(laglist)), '--r')

AllSpdDiffList = [];
AllSpdSTDList = []; 
NSSpdSTDList = []; 
for i = 1:length(PairVelocityDiff)
for j = 1:length(PairVelocityDiff{i})
AllSpdDiffList = [AllSpdDiffList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), PairSpeedDiff{i}{j}, 'uni', false)')'];
AllSpdSTDList = [AllSpdSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), MRSSpeedSTD{i}{j}, 'uni', false)')'];
NSSpdSTDList = [NSSpdSTDList; cell2mat(cellfun(@(x) reshape(x,1,numel(x)), NSSpeedSTD{i}{j}, 'uni', false)')'];
end
end
for i = 1:length(laglist)
count = 1;
for j = 0:5:60
data = abs(AllSpdDiffList(AllNSMRSDist>=j & AllNSMRSDist<j+5,i));
SpdBins{i}(count) = nanmean(data);
SpdBinsError{i}(count) = nanstd(data)./sqrt(sum(~isnan(data)));
count = count+1;
end
end

figure; hold on;
subplot(1,3,3)
hold on; plot(1:length(laglist), 0.05*ones(1,length(laglist)), '--r')
hold on; plot(1:length(laglist), zeros(1,length(laglist)), '--k')
for i = 1:length(laglist)
subplot(1,3,1)
cla
errorbar(1:length(SpdBins{i}), SpdBins{i}, SpdBinsError{i})
title([num2str(laglist(i))])
subplot(1,3,2)
cla
[r(i),p(i)] = QuickLinearFit(AllNSMRSDist, abs(AllSpdDiffList(:,i)),2);
title([num2str(laglist(i))])
subplot(1,3,3)
if i == 1
    plot(p(i))
    hold on; plot(r(i))
else
    temp = get(gca, 'Children');
    set(temp(1),'YData', p(1:i))
    set(temp(2),'YData', r(1:i))
    xlim('auto')
    ylim('auto')
end
pause
end
hold on; plot(1:length(laglist), 0.05*ones(1,length(laglist)), '--r')
