function [TrialDataSummary, TrialFeatures] = TrialActivityAnalysis(varargin)

global gui_KomiyamaLabHub


if get(gui_KomiyamaLabHub.figure.handles.DendExcluded_CheckBox, 'Value')
    AnalysisType = 'Exclude';
elseif get(gui_KomiyamaLabHub.figure.handles.DendSubtracted_CheckBox, 'Value')
    AnalysisType = 'Subtract';
end

animalnumber = length(varargin);

sessionClusteredSpines = cell(1,14); %%% highly correlated movement-related spines for each session
sessionStatSpines = cell(1,14);
sessionNewSpines = cell(1,14);
sessionStatDends = cell(1,14);
numspines = zeros(length(varargin),14);
numdends = zeros(1,length(varargin),14);
trialaverage = cell(1,14);
trialaveragebyanimal = cell(1,14);
trialdendriteaverage = cell(1,14);
trialdendriteaveragebyanimal = cell(1,14);
failuretrialaverage = cell(1,14);
failuretrialaveragebyanimal = cell(1,14);
MovementLengthDistribution = repmat({cell(1,animalnumber)},1,14);

startwindow = 15;   %%% Time (in frames) to subtract from the initiation of movement for inspection of beginning of trace
stopwindow = 60;    %%% Time (in frames) to add to the initiation of movement for inspection of end of trace

centermovement = 120;   %%% Trials are of different lengths, so to compare them with a chosen t = 0, you must chose a value about which to center them (cannot actually be zero in an array with indices of positive, real values)
                        %%% Note: the entire movement period is assumed to
                        %%% be fewer than 2*(centermovement) frames. If you
                        %%% increase the start or stop window above, you
                        %%% might also have to increase centermovement
                                               
foldertouse = 'C:\Users\Komiyama\Desktop\Output Data';
cd(foldertouse)
files = dir(cd);
h1 = waitbar(0, 'Collecting trial information');

%%% Variables for selection... Search for each and replace all when
%%% changing!

%%% Trial activity being used: trialdendsubactivity
%%% Statistical classification of spines of interest:
%%% DendSubMovementSpLiberal


for sample = 1:animalnumber
    count = 1;
    found = 0;
    waitbar(sample/animalnumber, h1, ['Collecting trial information for ', varargin{sample}]);
    while found<4 %%% If you add features to be found, make sure to change this value (should match the number of "or" clauses below
        if count>length(files)
            continue
        end
        if ~isempty(strfind(files(count).name, [varargin{sample}, '_TrialInformation'])) || ~isempty(strfind(files(count).name, [varargin{sample}, '_SpineCorrelationTimecourse'])) || ~isempty(strfind(files(count).name, [varargin{sample}, '_StatClassified'])) || ~isempty(strfind(files(count).name, [varargin{sample}, '_SpineDynamicsSummary']))
            found = found+1;
            load(files(count).name);
        end
        count = count+1;
    end
    eval(['clusteredspines = ', varargin{sample}, '_SpineCorrelationTimecourse.ClusteredSpines;'])
%     eval(['clusteredspines = ', varargin{sample}, '_SpineCorrelationTimecourse.ClusteredSpines;'])
    ClusteredSpinesAll = clusteredspines;
    clear([varargin{sample}, '_SpineCorrelationTimecourse'])
    eval(['spinestatclass = ', varargin{sample}, '_StatClassified;']);
    clear([varargin{sample}, '_StatClassified'])
    alignedtomovement = cell(1,14);
    alignedtofailure = cell(1,14);
    dendritealignedtomovement = cell(1,14);
    eval(['currentfile = ', varargin{sample}, '_TrialInformation;'])
    if ~isempty(who('-regexp', '_SpineDynamicsSummary'))
        UseLongitudinalInfo = 1;
        eval(['spinedynamicssummary = ', varargin{sample}, '_SpineDynamicsSummary;'])
        clear([varargin{sample}, '_SpineDynamicsSummary'])
    else
        UseLongitudinalInfo = 0;
    end
    for session = 1:length(currentfile)
        statspines{session} = [];
        statdends{session} = [];
        NewSpines{session} = [];
        locator = 0;
        if session>14
            continue
        end
        if ~isempty(currentfile{session})
            if length(currentfile{session})<20
                continue
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Select the statistical class of spines to be displayed
                %%%% beside the activity map
                
                switch AnalysisType
                    case 'Exclude'
                        statspines{session} = find(spinestatclass{session}.MovementSpines);
        %               statspines{session} = find(spinestatclass{session}.PreSuccessSpines);
                    case 'Subtract'
                        statspines{session} = find(spinestatclass{session}.DendSub_MovementSpines);
                end
                statdends{session} = find(spinestatclass{session}.MovementDends);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if UseLongitudinalInfo
                    fieldfind = logical(cell2mat(cellfun(@(x) ismember(session,x), spinedynamicssummary.SessionsbyField, 'uni', false)));
                    if any(fieldfind)
                        NewSpines{session} = find(spinedynamicssummary.NewSpines{fieldfind});
                    else
                        continue
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                trialscounted = find(~cell2mat(cellfun(@isempty, currentfile{session}, 'uni', false)));
                numspines(sample, session) = size(currentfile{session}{trialscounted(1)}.trialactivity,1);        %%% Usually can count on data at session 20 (random, and can be changed according to need)
                numdends(sample, session) = size(currentfile{session}{trialscounted(1)}.DendriteActivity,1);
                ClusteredSpinesByAnimal{session}{sample} = cell2mat(ClusteredSpinesAll{session}');
                StatSpinesByAnimal{session}{sample} = statspines{session};
                NewSpinesByAnimal{session}{sample} = NewSpines{session};
                if sample > 1
                    ClusteredSpinesAll{session} = cell2mat(ClusteredSpinesAll{session}') + sum(numspines(1,session):numspines(sample-1,session));
                    statspines{session} = statspines{session} + sum(numspines(1,session):numspines(sample-1,session));
                else
                    ClusteredSpinesAll{session} = cell2mat(ClusteredSpinesAll{session}');
                end
                alignedtomovement{1,session} = nan(numspines(sample,session),2*centermovement,length(currentfile{session}));
                dendritealignedtomovement{1,session} = nan(numdends(sample,session),2*centermovement,length(currentfile{session}));
                for trial = trialscounted(1):trialscounted(end)
                    if ~isempty(currentfile{session}{trial})
                        result = currentfile{session}{trial}.Result;
                        if strcmpi(result, 'Reward')
                            CueStart = currentfile{session}{trial}.CueStart;
                            if CueStart ==0
                                CueStart = 1;
                            end
                            MovementStart = currentfile{session}{trial}.MovementStart; % + currentfile{session}{trial}.TrialStart;   %%% The new method of behavior/imaging alignment subtracts the trial start each time to get relative frames; this will be redone in the future, so you will need to remove the addition
                            
                            %%% Select when to end the inspection period %%
%                             MovementEnd = currentfile{session}{trial}.MovementEnd;
                            MovementEnd = MovementStart+stopwindow;                           
                            MovementLengthDistribution{session}{sample}(trial) = currentfile{session}{trial}.MovementEnd-MovementStart;
                            %%%
                            
                            if MovementEnd > size(currentfile{session}{trial}.trialdendsubactivity,2)
                                MovementEnd = size(currentfile{session}{trial}.trialdendsubactivity,2);
                            end
                            if isempty(MovementEnd)
                                MovementEnd = currentfile{session}{trial}.CueEnd+currentfile{session}{trial}.TrialStart;
                            end
                            if isempty(MovementStart) || MovementStart > 1000 || MovementEnd > 1000
                                continue
                            end
                            %%%
                            ChosenStart = MovementStart-startwindow; %%% Value given in frames; subtract "start window" to define pre-movement period
                            %%%
                            if ChosenStart<=0
                                ChosenStart = 1;
                            end
                            switch AnalysisType
                                case 'Exclude'
                                    alignedtomovement{1,session}(1:numspines(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial) =  zscore(currentfile{session}{trial}.trialactivity(1:numspines(sample,session), ChosenStart:MovementEnd),[],2);
                                case 'Subtract'
                                    alignedtomovement{1,session}(1:numspines(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial) =  zscore(currentfile{session}{trial}.trialdendsubactivity(1:numspines(sample,session), ChosenStart:MovementEnd),[],2);
                            end
                            dendritealignedtomovement{1,session}(1:numdends(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial) =  zscore(currentfile{session}{trial}.DendriteActivity(1:numdends(sample,session), ChosenStart:MovementEnd),[],2);
                            if any(alignedtomovement{1,session}(1:numspines(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial)<0)
                                k = 'hey stop here there are sometimes errors';
                            end
%                             figure; imagesc(currentfile{session}{trial}.trialdendsubactivity(1:numspines(sample,session), ChosenStart:MovementEnd))
%                         elseif strcmpi(result, 'Punish')
%                             TrialStart = currentfile{session}{trial}.TrialStart;
%                             if TrialStart ==0
%                                 TrialStart = 1;
%                             end
%                             TrialEnd = currentfile{session}{trial}.ResultEnd;
%                             %%%
%                             InspectionStart = round((TrialEnd-TrialStart)/2);
%                             InspectionEnd = InspectionStart+stopwindow;
%                             %%%
%                             ChosenStart = InspectionStart-startwindow; %%% Value given in frames; subtract "start window" to define pre-movement period
%                             %%%
%                             if ChosenStart<=0
%                                 ChosenStart = 1;
%                             end
%                             alignedtofailure{1,session}(1:numspines(sample,session),ChosenStart-InspectionStart+centermovement:InspectionEnd-InspectionStart+centermovement,trial) =  zscore(currentfile{session}{trial}.synapseonlyactivity(1:numspines(sample,session), ChosenStart:InspectionEnd));
%                             if any(alignedtofailure{1,session}(1:numspines(sample,session),ChosenStart-InspectionStart+centermovement:InspectionEnd-InspectionStart+centermovement,trial)<0)
%                                 k = 1;
%                             end
                        end
                    end            
                end
                MovementLengthDistribution{session}{sample}(MovementLengthDistribution{session}{sample}==0) = nan;
            end
        end
        sessionClusteredSpines{1,session} = [sessionClusteredSpines{1,session}; ClusteredSpinesAll{session}];
        trialaverage{1,session} = [trialaverage{1,session}; nanmean(alignedtomovement{1,session},3)];
        trialaveragebyanimal{session}{sample} = nanmean(alignedtomovement{1,session},3);
        sessionStatSpines{1,session} = [sessionStatSpines{1,session}; statspines{session}];
        sessionStatDends{1,session} = [sessionStatDends{1,session}; statdends{session}];
        trialdendriteaverage{1,session} = [trialdendriteaverage{1,session}; nanmean(dendritealignedtomovement{1,session},3)];
        trialdendriteaveragebyanimal{1,session}{sample} = nanmean(dendritealignedtomovement{1,session},3);
%         failuretrialaverage{1,session} = [failuretrialaverage{1,session}; nanmean(alignedtofailure{1,session},3)];
%         failuretrialaveragebyanimal{1,session} = nanmean(alignedtofailure{1,session},3);
        if UseLongitudinalInfo
            sessionNewSpines{1,session} = [sessionNewSpines{1,session}; NewSpines{session}];
        end
    end
    clear([varargin{sample}, '_TrialInformation'])
end

TrialFeatures.ClusteredSpines = sessionClusteredSpines;
TrialFeatures.ClusteredSpinesbyAnimal = ClusteredSpinesByAnimal;
TrialFeatures.StatSpinesbyAnimal = StatSpinesByAnimal;
TrialFeatures.NewSpines = sessionNewSpines;
TrialFeatures.NewSpinesbyAnimal = NewSpinesByAnimal;
TrialDataSummary.TrialAverageAll = trialaverage;
TrialDataSummary.TrialAverageByAnimal = trialaveragebyanimal;
TrialDataSummary.TrialDendriteAverageAll = trialdendriteaverage;
TrialDataSummary.TrialDendriteAverageByAnimal = trialdendriteaveragebyanimal;
TrialFeatures.MovementLengthDistribution = MovementLengthDistribution;

save('TrialDataSummary', 'TrialDataSummary')
save('TrialFeatures', 'TrialFeatures')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scrsz = get(0,'ScreenSize');
figure('Position', scrsz);
close(h1)

% cspinestimingERROR = nan(1,14);
% allspinestimingERROR = nan(1,14);
ispinestiming = cell(1,14);
allspinestiming = cell(1,14);
idendstiming = cell(1,14);
alldendstiming = cell(1,14);


for i = 1:14
    subplot(2,7,i); 
    if ~isempty(trialaverage{1,i})
        [val, ind] = nanmax(trialaverage{1,i},[],2);
        trialaverage{1,i}(trialaverage{1,i}>30) = 30;
        trialaverage{1,i}(trialaverage{1,i}<0) = 0;
        trialnormalized = trialaverage{1,i}./repmat(val,1,size(trialaverage{1,i},2));
%         trialzscored = trialaverage{1,i}-repmat(nanmean(trialaverage{1,i},2),1,size(trialaverage{1,i},2))./repmat(nanstd(trialaverage{1,i},0,2),1,size(trialaverage{1,i},2));
        trialzscored = zscore(trialaverage{1,i},[], 2);
        [valsort, indsort] = sort(ind);
%         imagesc(trialzscored(indsort,:)); hold on; drawnow;
        imagesc(trialnormalized(indsort,:)); hold on; drawnow
        plot(centermovement*ones(size(trialaverage{1,i},1)), 1:size(trialaverage{1,i},1),':r')
        xlabel('Time (s)');
        valsort(valsort ==1) = nan;     %%% for many spines whose activity is nonexistent, the sorting/max algorithms return "1"; this messes up the median values and is not correct
        allspinestiming{i} = (valsort-centermovement)/30;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%^
        %%% Pick the type of spine you want to label 
%         spinesofinterest = sessionStatSpines{i};
%         spinesofinterest = sessionClusteredSpines{i};
        spinesofinterest = sessionNewSpines{i};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        ispines = ismember(indsort, spinesofinterest);
        ispinesloc = find(ispines);
        ispinestiming{i} = (valsort(ispinesloc)-centermovement)/30;    %%% Subtract zero point and convert to seconds
        arrows = repmat('-->', length(ispinesloc),1);
        %%% Label all spines of interest with an arrow, but make exceptions
        %%% for the first and last spines, for ease of reading
        if isempty(find(ispinesloc==1)) && isempty(find(ispinesloc==size(trialaverage{1,i},1)))
            set(gca, 'YTick', [1;ispinesloc; size(trialaverage{1,i},1)])
            set(gca, 'YTickLabel', {'1', arrows, num2str(size(trialaverage{1,i},1))});
        elseif ~isempty(find(ispinesloc==1)) && isempty(find(ispinesloc==size(trialaverage{1,i},1)))
            set(gca, 'YTick', [ispinesloc; size(trialaverage{1,i},1)]);
            set(gca, 'YTickLabel', {arrows, num2str(size(trialaverage{1,i},1))});
        elseif isempty(find(ispinesloc==1)) && ~isempty(find(ispinesloc==size(trialaverage{1,i},1)))
            set(gca, 'YTick', [1;ispinesloc]);
            set(gca, 'YTickLabel', {'1', arrows(1:end-1,:), ['-->', num2str(size(trialaverage{1,i},1))]});
        end    
        ylim([0 size(trialaverage{1,i},1)])
%         xlim([centermovement/2, centermovement*2])
        set(gca, 'XTick', [(centermovement)/2 centermovement centermovement+(centermovement/2), centermovement*2])
        set(gca, 'XTickLabel', {num2str(((centermovement/2)-centermovement)/30), '0', num2str((centermovement/2)/30), num2str(centermovement/30)})
    end
end

considersessions = ones(1,14); 
considersessions([4,9,14]) = 0; considersessions = logical(considersessions);
sessions = 1:14; sessions = sessions(:,considersessions);

figure; flex_plot(sessions,ispinestiming(:,considersessions),'parametric','k',2); hold on;
flex_plot(sessions, allspinestiming(:,considersessions), 'parametric', 'r', 2);
xlim([0 15])
xlabel('Session')
ylabel('Time relative to movement (s)')
set(gca, 'XTick', 0:15)

scrsz = get(0,'ScreenSize');
figure('Position', scrsz);

for i = 1:14
    subplot(2,7,i); 
    if ~isempty(trialdendriteaverage{1,i})
        [val, ind] = nanmax(trialdendriteaverage{1,i},[],2);
        trialdendriteaverage{1,i}(trialdendriteaverage{1,i}>30) = 30;
        trialdendriteaverage{1,i}(trialdendriteaverage{1,i}<0) = 0;
        trialnormalized = trialdendriteaverage{1,i}./repmat(val,1,size(trialdendriteaverage{1,i},2));
        [valsort, indsort] = sort(ind);
%         imagesc(trialzscored(indsort,:)); hold on; drawnow;
        imagesc(trialnormalized(indsort,:)); hold on; drawnow
        plot(centermovement*ones(size(trialdendriteaverage{1,i},1)), 1:size(trialdendriteaverage{1,i},1),':r')
        xlabel('Time (s)');
        valsort(valsort ==1) = nan;     %%% for many spines whose activity is nonexistent, the sorting/max algorithms return "1"; this messes up the median values and is not correct
        alldendstiming{i} = (valsort-centermovement)/30;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%^
        %%% Pick the type of spine you want to label 
        dendsofinterest = sessionStatDends{i};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        idends = ismember(indsort, dendsofinterest);
        idendsloc = find(idends);
        idendstiming{i} = (valsort(idendsloc)-centermovement)/30;    %%% Subtract zero point and convert to seconds
        arrows = repmat('-->', length(idendsloc),1);
        %%% Label all spines of interest with an arrow, but make exceptions
        %%% for the first and last spines, for ease of reading
        if ~isempty(idendsloc)
            if isempty(find(idendsloc==1)) && isempty(find(idendsloc==size(trialdendriteaverage{1,i},1)))
                set(gca, 'YTick', [1;idendsloc; size(trialdendriteaverage{1,i},1)])
                set(gca, 'YTickLabel', {'1', arrows, num2str(size(trialdendriteaverage{1,i},1))});
            elseif ~isempty(find(idendsloc==1)) && isempty(find(idendsloc==size(trialdendriteaverage{1,i},1)))
                set(gca, 'YTick', [idendsloc; size(trialdendriteaverage{1,i},1)]);
                set(gca, 'YTickLabel', {arrows, num2str(size(trialdendriteaverage{1,i},1))});
            elseif isempty(find(idendsloc==1)) && ~isempty(find(idendsloc==size(trialdendriteaverage{1,i},1)))
                set(gca, 'YTick', [1;idendsloc]);
                set(gca, 'YTickLabel', {'1', arrows(1:end-1,:), ['-->', num2str(size(trialdendriteaverage{1,i},1))]});
            end
        else
        end
        ylim([0 size(trialdendriteaverage{1,i},1)])
%         xlim([centermovement/2, centermovement*2])
        set(gca, 'XTick', [(centermovement)/2 centermovement centermovement+(centermovement/2), centermovement*2])
        set(gca, 'XTickLabel', {num2str(((centermovement/2)-centermovement)/30), '0', num2str((centermovement/2)/30), num2str(centermovement/30)})
    end
end

figure; flex_plot(1:14,idendstiming,'parametric','k',2); hold on;
flex_plot(1:14, alldendstiming, 'parametric', 'r', 2);
xlim([0 15])
xlabel('Session')
ylabel('Time relative to movement (s)')
set(gca, 'XTick', 0:15)