function TrialActivityPCA(trialdata, features)

%%%%% PCA Notes: Rows of input correspond to observations (i.e. points in a
%%%%% time series), while columns correspond to variables (e.g., in this
%%%%% case, different spines/dendrites)
%%%%% The output, coeff, produces a matrix with rows corresponding to each
%%%%% of the variables, and with columns corresponding to each of the
%%%%% principal components
%%%%% For example, if you have a data array with 770 spines, observed over
%%%%% ~3sec of the behavior (90frames if imaging at 30Hz), the input matrix
%%%%% should be 90x770. The output, coeff, would be 770x(NumberofPCs)

animalnumber = length(trialdata.TrialAverageByAnimal{1});

coeffs = repmat({cell(1,animalnumber)},1,14);
scores = repmat({cell(1,animalnumber)},1,14);
latent = repmat({cell(1,animalnumber)},1,14);
tsquared = repmat({cell(1,animalnumber)},1,14);
explained = repmat({cell(1,animalnumber)},1,14);
Dcoeffs = repmat({cell(1,animalnumber)},1,14);
Dscores = repmat({cell(1,animalnumber)},1,14);
Dlatent = repmat({cell(1,animalnumber)},1,14);
Dtsquared = repmat({cell(1,animalnumber)},1,14);
Dexplained = repmat({cell(1,animalnumber)},1,14);

sessionstouse = [1,2,3,6,7,8,11,12,13];

start = find(~isnan(nanmean(trialdata.TrialAverageByAnimal{1}{1}(:,:),1)), 1, 'first');
finish = find(~isnan(nanmean(trialdata.TrialAverageByAnimal{1}{1}(:,:),1)), 1, 'last');

for session = sessionstouse %%% Change based on the sessions you wish to use
    for animal = 1:animalnumber
        if ~isempty(trialdata.TrialAverageByAnimal{session}{animal})
%             spinestouse = features.StatSpinesbyAnimal{sessions}{animal};
%             spinestouse = features.ClusteredSpinesbyAnimal{sessions}{animal};
            spinestouse = 1:size(trialdata.TrialAverageByAnimal{session}{animal},1);
            PCAdata = trialdata.TrialAverageByAnimal{session}{animal}(spinestouse,:);
            PCAdata = PCAdata(:,start:finish);
            anyact = ~any(isnan(PCAdata'));
            PCAdata = PCAdata(anyact,:);
            [coeffs{session}{animal}, scores{session}{animal}, latent{session}{animal},tsquared{session}{animal}, explained{session}{animal}] = pca(PCAdata');
            coeffs{session}{animal} = abs(coeffs{session}{animal});
            scores{session}{animal} = abs(scores{session}{animal});
        end
        DendPCAdata = trialdata.TrialDendriteAverageByAnimal{session}{animal};
%         DendPCAdata(isnan(DendPCAdata(:,start:finish)))=0;
        if size(DendPCAdata,1) > 1
            [Dcoeffs{session}{animal}, Dscores{session}{animal}, Dlatent{session}{animal},Dtsquared{session}{animal}, Dexplained{session}{animal}] = pca(DendPCAdata);
        else
            Dexplained{animal}{session} = nan(2,1);
        end
    end
end

ExplByPC1 = nan(animalnumber, 14);
ExplByPC2 = nan(animalnumber, 14);
ExplByPC3 = nan(animalnumber, 14);
DendriteExplByPC1 = nan(animalnumber, 14);
DendriteExplByPC2 = nan(animalnumber, 14);
DendriteExplByPC3 = nan(animalnumber, 14);

for animal = 1:animalnumber
    for j = 1:14
        if ~isempty(explained{j}{animal})
            ExplByPC1(animal,j) = explained{j}{animal}(1,1);
            if length(explained{j}{animal})>1
                ExplByPC2(animal,j) = explained{j}{animal}(2,1);
                if length(explained{j}{animal})>2
                    ExplByPC3(animal,j) = explained{j}{animal}(3,1);
                end
            end
        end
        if ~isempty(Dexplained{j}{animal})
            DendriteExplByPC1(animal,j) = Dexplained{j}{animal}(1,1);
            if length(Dexplained{j}{animal})>1
                DendriteExplByPC2(animal,j) = Dexplained{j}{animal}(2,1);
                if length(Dexplained{j}{animal})>2
                    DendriteExplByPC3(animal,j) = Dexplained{j}{animal}(3,1);
                else
                end
            else
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Figures %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scrsz = get(0, 'ScreenSize');
windowwidth = scrsz(3)/2;
windowheight = scrsz(4)/2;

    %%%%%%%%%%%%%%%%%%%%%%
    %%Color Information%%%
    %%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    pink = [0.9 0.6 0.6];       lpurple  = [0.7 0.15 1];
    red = [0.85 0.11 0.14];     black = [0.1 0.1 0.15];
    dred = [0.6 0 0];           dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 
    
%% Figure 1: Variance explained by first three PCs

stattype = 'parametric';

figure('Position', [10, scrsz(4)/2.5,windowwidth,windowheight]); 
subplot(2,3,1);
plot(ExplByPC1')
flex_plot(1:14, ExplByPC1,stattype, 'k', 2);
xlabel('Session')
ylabel('Variance Explained')
title('Variance Explained by PC1')
ylim([0 100])

subplot(2,3,2); plot(ExplByPC2')
flex_plot(1:14, ExplByPC2,stattype, 'k', 2);
xlabel('Session')
ylabel('Variance Explained')
title('Variance Explained by PC2')
ylim([0 100])

subplot(2,3,3); plot(ExplByPC3')
flex_plot(1:14, ExplByPC3,stattype, 'k',2);
xlabel('Session')
ylabel('Variance Explained')
title('Variance Explained by PC3')
ylim([0 100])

subplot(2,3,4);
plot(DendriteExplByPC1')
flex_plot(1:14, DendriteExplByPC1,stattype, 'k', 2);
xlabel('Session')
ylabel('Variance Explained')
title('Dend. Variance Explained by PC1')
ylim([0 100])

subplot(2,3,5); plot(DendriteExplByPC2')
flex_plot(1:14, DendriteExplByPC2,stattype, 'k', 2);
xlabel('Session')
ylabel('Variance Explained')
title('Dend. Variance Explained by PC2')
ylim([0 100])

subplot(2,3,6); plot(DendriteExplByPC3')
flex_plot(1:14, DendriteExplByPC3,stattype, 'k',2);
xlabel('Session')
ylabel('Variance Explained')
title('Dend. Variance Explained by PC3')
ylim([0 100])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Figure 2: Coefficients for clustered vs. non-clustered spines


ClusteredSpinesPC1Coefficients = cell(1,14);
NonClusteredSpinePC1Coefficients = cell(1,14);
ClusteredSpinesPC2Coefficients = cell(1,14);
NonClusteredSpinePC2Coefficients = cell(1,14);
for session = sessionstouse
    for animal = 1:animalnumber
        if ~isempty(coeffs{session}{animal})
            try
                ClusteredSpinesPC1Coefficients{session} = [ClusteredSpinesPC1Coefficients{session}; coeffs{session}{animal}(features.ClusteredSpinesbyAnimal{session}{animal})];
                NonClusteredSpinePC1Coefficients{session} = [NonClusteredSpinePC1Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.ClusteredSpinesbyAnimal{session}{animal}))')];
                ClusteredSpinesPC2Coefficients{session} = [ClusteredSpinesPC2Coefficients{session}; coeffs{session}{animal}(features.ClusteredSpinesbyAnimal{session}{animal},2)];
                NonClusteredSpinePC2Coefficients{session} = [NonClusteredSpinePC2Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.ClusteredSpinesbyAnimal{session}{animal}))',2)];
            catch
                ClusteredSpinesPC1Coefficients{session} = [ClusteredSpinesPC1Coefficients{session}; NaN];
                NonClusteredSpinePC1Coefficients{session} = [NonClusteredSpinePC1Coefficients{session}; NaN];
                ClusteredSpinesPC2Coefficients{session} = [ClusteredSpinesPC2Coefficients{session}; NaN];
                NonClusteredSpinePC2Coefficients{session} = [NonClusteredSpinePC2Coefficients{session}; NaN];
            end
        end
    end
end


figure('Position',[windowwidth, scrsz(4)/2.5, windowwidth, windowheight]); 
left = subplot(2,2,1);
a = flex_plot(1:14, ClusteredSpinesPC1Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonClusteredSpinePC1Coefficients, stattype, 'r', 2);
legend([a,b], 'Clustered Spines', 'Nonclustered Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC1')
right = subplot(2,2,2);
a = flex_plot(1:14, ClusteredSpinesPC2Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonClusteredSpinePC2Coefficients, stattype, 'r', 2);
legend([a,b], 'Clustered Spines', 'Nonclustered Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC2')
linkaxes([left,right], 'xy')

NewSpinesPC1Coefficients = cell(1,14);
NonNewSpinePC1Coefficients = cell(1,14);
NewSpinesPC2Coefficients = cell(1,14);
NonNewSpinePC2Coefficients = cell(1,14);
for session = sessionstouse
    for animal = 1:animalnumber
        if ~isempty(coeffs{session}{animal})
            try
                NewSpinesPC1Coefficients{session} = [NewSpinesPC1Coefficients{session}; coeffs{session}{animal}(features.NewSpinesbyAnimal{session}{animal})];
                NonNewSpinePC1Coefficients{session} = [NonNewSpinePC1Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.NewSpinesbyAnimal{session}{animal}))')];
                NewSpinesPC2Coefficients{session} = [NewSpinesPC2Coefficients{session}; coeffs{session}{animal}(features.NewSpinesbyAnimal{session}{animal},2)];
                NonNewSpinePC2Coefficients{session} = [NonNewSpinePC2Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.NewSpinesbyAnimal{session}{animal}))',2)];
            catch
                NewSpinesPC1Coefficients{session} = [NewSpinesPC1Coefficients{session}; NaN];
                NonNewSpinePC1Coefficients{session} = [NonNewSpinePC1Coefficients{session}; NaN];
                NewSpinesPC2Coefficients{session} = [NewSpinesPC2Coefficients{session}; NaN];
                NonNewSpinePC2Coefficients{session} = [NonNewSpinePC2Coefficients{session}; NaN];
            end
        end
    end
end

left = subplot(2,2,3);
a = flex_plot(1:14, NewSpinesPC1Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonNewSpinePC1Coefficients, stattype, 'r', 2);
legend([a,b], 'New Spines', 'NonNew Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC1')
right = subplot(2,2,4);
a = flex_plot(1:14, NewSpinesPC2Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonNewSpinePC2Coefficients, stattype, 'r', 2);
legend([a,b], 'New Spines', 'NonNew Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC2')
linkaxes([left,right], 'xy')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Figure 3: Coefficients for Task-related Spines

StatSpinesPC1Coefficients = cell(1,14);
NonStatSpinePC1Coefficients = cell(1,14);
StatSpinesPC2Coefficients = cell(1,14);
NonStatSpinePC2Coefficients = cell(1,14);

for session = sessionstouse
    for animal = 1:animalnumber
        if ~isempty(coeffs{session}{animal})
            try
                StatSpinesPC1Coefficients{session} = [StatSpinesPC1Coefficients{session}; coeffs{session}{animal}(features.StatSpinesbyAnimal{session}{animal})];
                NonStatSpinePC1Coefficients{session} = [NonStatSpinePC1Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.StatSpinesbyAnimal{session}{animal}))')];
                StatSpinesPC2Coefficients{session} = [StatSpinesPC2Coefficients{session}; coeffs{session}{animal}(features.StatSpinesbyAnimal{session}{animal},2)];
                NonStatSpinePC2Coefficients{session} = [NonStatSpinePC2Coefficients{session}; coeffs{session}{animal}(find(~ismember([1:size(coeffs{session}{animal},1)], features.StatSpinesbyAnimal{session}{animal}))',2)];
            catch
                StatSpinesPC1Coefficients{session} = [StatSpinesPC1Coefficients{session}; NaN];
                NonStatSpinePC1Coefficients{session} = [NonStatSpinePC1Coefficients{session}; NaN];
                StatSpinesPC2Coefficients{session} = [StatSpinesPC2Coefficients{session}; NaN];
                NonStatSpinePC2Coefficients{session} = [NonStatSpinePC2Coefficients{session}; NaN];
            end
        end
    end
end

figure('Position', [10, 50,windowwidth,windowheight]); 
left = subplot(1,2,1);
a = flex_plot(1:14, StatSpinesPC1Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonStatSpinePC1Coefficients, stattype, 'r', 2);
legend([a,b], 'Stat Spines', 'NonStat Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC1')
right = subplot(1,2,2);
a = flex_plot(1:14, StatSpinesPC2Coefficients,stattype, 'k', 2);
b = flex_plot(1:14, NonStatSpinePC2Coefficients, stattype, 'r', 2);
legend([a,b], 'Stat Spines', 'NonStat Spines')
xlabel('Session')
ylabel('Mean Coefficients')
title('Coeff. for PC2')
linkaxes([left,right], 'xy')

%% Figure 4: Biplot of all loadings and scores

figure('Position',[windowwidth, 50, windowwidth,windowheight]); 
PCAdata = cell2mat(trialdata.TrialAverageAll(1:3)');
PCAdata = PCAdata(:,start:finish);
anyact = ~any(isnan(PCAdata'));
PCAdata = PCAdata(anyact,:);
[coeffs, scores, latent,tsquared, explained] = pca(PCAdata'); 
PCAdataEarly = PCAdata;

PCAdata = cell2mat(trialdata.TrialAverageAll(11:13)');
PCAdata = PCAdata(:,start:finish);
PCAdata(isnan(PCAdata)) = 0;
[coeffslate, scoreslate, latentlate,tsquaredlate, explainedlate] = pca(PCAdata'); 
PCAdataLate = PCAdata;

left = subplot(2,2,1); biplot(coeffs(:,1:2), 'scores', scores(:,1:2));
right = subplot(2,2,2); biplot(coeffslate(:,1:2), 'scores', scoreslate(:,1:2));
linkaxes([left,right], 'xy')

PCAdata = cell2mat(trialdata.TrialDendriteAverageAll(1:3)');
PCAdata = PCAdata(:,start:finish);
anyact = ~any(isnan(PCAdata'));
PCAdata = PCAdata(anyact,:);
[Dcoeffs, Dscores, Dlatent,Dtsquared, Dexplained] = pca(PCAdata');
PCAdata = cell2mat(trialdata.TrialDendriteAverageAll(11:13)');
PCAdata = PCAdata(:,start:finish);
PCAdata(isnan(PCAdata)) = 0;
[Dcoeffslate, Dscoreslate, Dlatentlate,Dtsquaredlate, Dexplainedlate] = pca(PCAdata');

left = subplot(2,2,3); biplot(Dcoeffs(:,1:2), 'scores', Dscores(:,1:2));
right = subplot(2,2,4); biplot(Dcoeffslate(:,1:2), 'scores', Dscoreslate(:,1:2));
linkaxes([left,right], 'xy')

AllPCAData = [PCAdataEarly;PCAdataLate];
EarlySpines = length(PCAdataEarly);
LateSpines = length(PCAdataLate);


%% Figure 5: Activity Propagation through PCs during movement

figure('Position', [(windowwidth)-windowwidth/2, (windowheight)-windowheight/2, windowwidth, windowheight])
centermovement = features.CenterMovement;
timeXlength = ceil((features.StartWindow+features.StopWindow+1)/10)*10; %%% 


subplot(2,2,1)
early = plot(scores(:,1), 'Color', black, 'Linewidth', 2);
hold on; late = plot(scoreslate(:,1), 'Color', blue, 'Linewidth', 2);
title('Spine activity propagation through PC1')
actualXscale = [0:10:timeXlength];
relabeledXscale = [-features.StartWindow:10:timeXlength-features.StartWindow];
set(gca, 'XTick', actualXscale , 'XTickLabel', mat2cell(num2str(relabeledXscale'), ones(length(actualXscale),1),3))
designatedmovcenter = features.StartWindow;
medmovduration = nanmedian([horzcat(features.MovementLengthDistribution{1}{:}),horzcat(features.MovementLengthDistribution{2}{:}),horzcat(features.MovementLengthDistribution{3}{:})])+designatedmovcenter;
plotlims = get(gca, 'YLim');
plot(designatedmovcenter*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', lgreen)
plot(medmovduration*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', red)
plot(actualXscale, zeros(1,length(actualXscale)), '--k')
legend([early,late], {'Early', 'Late'}, 'Location', 'northwest')
xlabel('Frames relative to movement')
ylabel('PC score')

subplot(2,2,2)
early = plot(scores(:,2), 'Color', black, 'Linewidth', 2);
hold on; late = plot(scoreslate(:,2),'Color', blue, 'Linewidth', 2);
title('Spine activity propagation through PC2')
set(gca, 'XTick', [180:20:300], 'XTickLabel', mat2cell(num2str([-40:20:100]'), ones(8,1),3))
latemedmovduration = nanmedian([horzcat(features.MovementLengthDistribution{11}{:}),horzcat(features.MovementLengthDistribution{12}{:}),horzcat(features.MovementLengthDistribution{13}{:})])+designatedmovcenter;
plotlims = get(gca, 'YLim');
plot(designatedmovcenter*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', lgreen)
plot(latemedmovduration*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', red)
plot(actualXscale, zeros(1,length(actualXscale)), '--k')
legend([early,late], {'Early', 'Late'}, 'Location', 'northwest')
xlabel('Frames relative to movement')
ylabel('PC score')

subplot(2,2,3)
early = plot(Dscores(:,1), 'Color', black, 'Linewidth', 2);
hold on; late = plot(Dscoreslate(:,1), 'Color', blue, 'Linewidth', 2);
title('Dendrite activity propagation through PC1')
set(gca, 'XTick', [180:20:300], 'XTickLabel', mat2cell(num2str([-40:20:100]'), ones(8,1),3))
plotlims = get(gca, 'YLim');
plot(designatedmovcenter*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', lgreen)
plot(medmovduration*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', red)
plot(actualXscale, zeros(1,length(actualXscale)), '--k')
legend([early,late], {'Early', 'Late'}, 'Location', 'northwest')
xlabel('Frames relative to movement')
ylabel('PC score')

subplot(2,2,4)
early = plot(Dscores(:,2), 'Color', black, 'Linewidth', 2);
hold on; late = plot(Dscoreslate(:,2), 'Color', blue, 'Linewidth', 2);
title('Dendrite activity propagation through PC2')
set(gca, 'XTick', [180:20:300], 'XTickLabel', mat2cell(num2str([-40:20:100]'), ones(8,1),3))
plotlims = get(gca, 'YLim');
plot(designatedmovcenter*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', lgreen)
plot(latemedmovduration*ones(1,length([plotlims(1):1:plotlims(2)])), plotlims(1):1:plotlims(2), '--', 'Color', red)
plot(actualXscale, zeros(1,length(actualXscale)), '--k')
legend([early,late], {'Early', 'Late'}, 'Location', 'northwest')
xlabel('Frames relative to movement')
ylabel('PC score')

% for i = 1:29
%     subplot(3,2,1); title('Session 1')
%     try
%     biplot(coeffs{1}{i}(:,1:2), 'scores', scores{1}{i}(:,1:2))
%     end
%     subplot(3,2,2); title('Session 2')
%     try
%     biplot(coeffs{11}{i}(:,1:2), 'scores', scores{11}{i}(:,1:2))
%     end
%     subplot(3,2,3); title('Session 3')
%     try
%     biplot(coeffs{2}{i}(:,1:2), 'scores', scores{2}{i}(:,1:2))
%     end
%     subplot(3,2,4); title('Session 4')
%     try
%     biplot(coeffs{12}{i}(:,1:2), 'scores', scores{12}{i}(:,1:2))
%     end
%     subplot(3,2,5); title('Session 5')
%     try
%     biplot(coeffs{3}{i}(:,1:2), 'scores', scores{3}{i}(:,1:2))
%     end
%     subplot(3,2,6); title('Session 3')
%     try
%     biplot(coeffs{13}{i}(:,1:2), 'scores', scores{13}{i}(:,1:2))
%     end
%     pause
% end
end