function [trialaverage] = TrialActivityAnalysis(varargin)

trialaverage = cell(1,14);
sessionHCMRS = cell(1,14); %%% highly correlated movement-related spines for each session
sessionStatSpines = cell(1,14);
numspines = zeros(length(varargin),14);
startwindow = 60;   %%% Time (in frames) to subtract from the initiation of movement for inspection of beginning of trace
stopwindow = 60;    %%% Time (in frames) to add to the initiation of movement for inspection of end of trace

centermovement = 180;    %%% Trials are of different lengths, so to compare them with a chosen t = 0, you must chose a value about which to center them (cannot actually be zero in an array with indices of positive, real values)
                        %%% Note: the entire movement period is assumed to
                        %%% be fewer than 2*(centermovement) frames. If you
                        %%% increase the start or stop window above, you
                        %%% might also have to increase centermovement
                        
foldertouse = 'C:\Users\Komiyama\Desktop\Output Data';
cd(foldertouse)
files = dir(cd);
h1 = waitbar(0, 'Collecting trial information');


for sample = 1:length(varargin)
    count = 1;
    found = 0;
    waitbar(sample/length(varargin), h1, ['Collecting trial information for ', varargin{sample}]);
    while found<3 %%% If you add features to be found, make sure to change this value (should match the number of "or" clauses below
        if ~isempty(strfind(files(count).name, [varargin{sample}, '_TrialInformation'])) || ~isempty(strfind(files(count).name, [varargin{sample}, '_SpineCorrelationTimecourse'])) || ~isempty(strfind(files(count).name, [varargin{sample}, '_StatClassified']))
            found = found+1;
            load(files(count).name);
        end
        count = count+1;
    end
    eval(['clusteredspines = ', varargin{sample}, '_SpineCorrelationTimecourse.HighlyCorrelatedMovementRelatedSpines;'])
    clear([varargin{sample}, '_SpineCorrelationTimecourse'])
    eval(['spinestatclass = ', varargin{sample}, '_StatClassified;']);
    clear([varargin{sample}, '_StatClassified'])
    alignedtomovement = cell(1,14);
    eval(['currentfile = ', varargin{sample}, '_TrialInformation;'])
    for session = 1:length(currentfile)
        statspines{session} = [];
        locator = 0;
        if ~isempty(currentfile{session})
            if length(currentfile{session})<20
                continue
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% Select the statistical class of spines to be displayed
                %%%% beside the activity map
                
                statspines{session} = find(spinestatclass{session}.MovementSpLiberal);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                trialscounted = find(~cell2mat(cellfun(@isempty, currentfile{session}, 'uni', false)));
                numspines(sample, session) = size(currentfile{session}{trialscounted(1)}.trialactivity,1);        %%% Usually can count on data at session 20 (random, and can be changed according to need)
                if sample > 1
                    clusteredspines{session} = clusteredspines{session} + sum(numspines(1,session):numspines(sample-1,session));
                    statspines{session} = statspines{session} + sum(numspines(1,session):numspines(sample-1,session));
                end
                alignedtomovement{1,session} = nan(numspines(sample,session),2*centermovement,length(currentfile{session}));
                for trial = trialscounted(1):trialscounted(end)
                    if ~isempty(currentfile{session}{trial})
                        result = currentfile{session}{trial}.Result;
                        if strcmpi(result, 'Reward')
                            CueStart = currentfile{session}{trial}.CueStart;
                            if CueStart ==0
                                CueStart = 1;
                            end
                            MovementStart = currentfile{session}{trial}.MovementStart + currentfile{session}{trial}.TrialStart;   %%% The new method of behavior/imaging alignment subtracts the trial start each time to get relative frames; this will be redone in the future, so you will need to remove the addition
                            
                            %%% Select when to end the inspection period %%
%                             MovementEnd = currentfile{session}{trial}.MovementEnd;
                            MovementEnd = MovementStart+stopwindow;
                            %%%
                            
                            if MovementEnd > size(currentfile{session}{trial}.trialactivity,2)
                                MovementEnd = size(currentfile{session}{trial}.trialactivity,2);
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
                            alignedtomovement{1,session}(1:numspines(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial) =  currentfile{session}{trial}.trialactivity(1:numspines(sample,session), ChosenStart:MovementEnd);
                            if any(alignedtomovement{1,session}(1:numspines(sample,session),ChosenStart-MovementStart+centermovement:MovementEnd-MovementStart+centermovement,trial)<0)
                                k = 1;
                            end
%                             figure; imagesc(currentfile{session}{trial}.trialactivity(1:numspines(sample,session), ChosenStart:MovementEnd))
                        end
                    end            
                end
            end
        end
        sessionHCMRS{1,session} = [sessionHCMRS{1,session}; clusteredspines{session}];
        trialaverage{1,session} = [trialaverage{1,session}; nanmedian(alignedtomovement{1,session},3)];
        sessionStatSpines{1,session} = [sessionStatSpines{1,session}; statspines{session}];
    end
    clear([varargin{sample}, '_TrialInformation'])
end

scrsz = get(0,'ScreenSize');
figure('Position', scrsz);
close(h1)

% cspinestimingERROR = nan(1,14);
% allspinestimingERROR = nan(1,14);
ispinestiming = cell(1,14);
allspinestiming = cell(1,14);

for i = 1:14
    subplot(2,7,i); 
    if ~isempty(trialaverage{1,i})
        [val, ind] = nanmax(trialaverage{1,i},[],2);
        trialaverage{1,i}(trialaverage{1,i}>30) = 30;
        trialaverage{1,i}(trialaverage{1,i}<0) = 0;
        trialnormalized = trialaverage{1,i}./repmat(val,1,size(trialaverage{1,i},2));
        trialzscored = trialaverage{1,i}-repmat(nanmean(trialaverage{1,i},2),1,size(trialaverage{1,i},2))./repmat(nanstd(trialaverage{1,i},0,2),1,size(trialaverage{1,i},2));
        [valsort, indsort] = sort(ind);
        imagesc(trialnormalized(indsort,:)); hold on; drawnow
        plot(centermovement*ones(size(trialaverage{1,i},1)), 1:size(trialaverage{1,i},1),':r')
        xlabel('Time (s)');
        valsort(valsort ==1) = nan;     %%% for many spines whose activity is nonexistent, the sorting/max algorithms return "1"; this messes up the median values and is not correct
        allspinestiming{i} = (valsort-centermovement)/30;
        %%% Pick the type of spine you want to label 
        spinesofinterest = sessionStatSpines{i};
        ispines = ismember(indsort, spinesofinterest);
        ispinesloc = find(ispines);
        ispinestiming{i} = (valsort(ispinesloc)-centermovement)/30;    %%% Subtract zero point and convert to seconds
        arrows = repmat('-->', length(ispinesloc),1);
        %%% Label all clustered spines with an arrow, but make exceptions
        %%% for the first and last spines, for ease of reading
        if isempty(find(ispinesloc==1)) && isempty(find(ispinesloc==size(trialaverage{1,i},1)))
            set(gca, 'YTick', [1;ispinesloc; size(trialaverage{1,i},1)])
            set(gca, 'YTickLabel', {'1', arrows, num2str(size(trialaverage{1,i},1))});
        elseif ~isempty(find(ispinesloc==1)) && isempty(find(ispinesloc==size(trialaverage{1,i},1)));
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

figure; flex_plot(1:14,ispinestiming,'parametric','k',2); hold on;
flex_plot(1:14, allspinestiming, 'parametric', 'r', 2);
xlim([0 15])
xlabel('Session')
ylabel('Time relative to movement (s)')
set(gca, 'XTick', 0:15)