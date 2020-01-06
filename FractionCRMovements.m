function FractionCRMovements(varargin)

h1 = waitbar(0, 'Initializing...');

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    datafolder = 'C:\Users\Komiyama\Desktop\Output Data';
    cd(datafolder)
end

ImagingFrequency = 30.49;

for animal = 1:length(varargin)
    waitbar(animal/length(varargin),h1, ['Animal ', num2str(animal), '/', num2str(length(varargin))])
    experimentname = varargin{animal};
    aligneddata = fastdir(datafolder, {experimentname, 'Aligned'});
    load(aligneddata{1})
    eval(['data = ', aligneddata{1}(1:end-4), ';'])
    sessionstouse = ~cellfun(@isempty, data);
    FractionCuedRewardedMovements{animal} = nan(length(sessionstouse),1);
    for s = find(sessionstouse)
        cuetrace = data{s}.Cue;
        frameslist = 1:length(cuetrace);
        binarizedlever = data{s}.Binarized_Lever;
        rewardperiods = data{s}.RewardDelivery;
                
        cue_ind = find(diff(cuetrace)>0); pre_cue_ind = cue_ind-round(ImagingFrequency*.1); pre_cue_ind(pre_cue_ind<1) = 1;
        boundC = find(diff([Inf; cuetrace'; Inf])~=0);
        cue_separated = mat2cell(cuetrace', diff(boundC));
        frames_cue_separated = mat2cell(frameslist', diff(boundC));
        framesduringcueperiods = frames_cue_separated(cellfun(@any, cue_separated));

        preCue = zeros(1,length(cuetrace)); preCue(cell2mat(arrayfun(@(x,y) x:y, pre_cue_ind, cue_ind, 'uni', false))) = 1;
        
        boundM = find(diff([Inf; binarizedlever; Inf])~=0);
        allperiodsM = mat2cell(binarizedlever, diff(boundM));
        
        rewstart = diff([rewardperiods;0]); rewstart(rewstart<0)= 0;
        rew_move_separated = mat2cell(rewstart, diff(boundM));
        rew_during_moveperiods = rew_move_separated(cellfun(@any, allperiodsM));
        IsMovementRewarded = cellfun(@any, rew_during_moveperiods);

        %==================================================================
        %%% Pre-trial movement filtering
        
        method = 1;
        
        if method == 1
            
            %%% Method 1: Excludes movements that overlap with pre-cue
            %%% periods, but does not abort that trial, allowing for
            %%% subsequent cued-rewarded movements to be considered 
            preCue_moveseparated = mat2cell(preCue', diff(boundM));
            preCue_moveseparated = preCue_moveseparated(cellfun(@any, allperiodsM));

            CueRewMovements = cellfun(@(x,y) any(x)&~any(y), rew_during_moveperiods, preCue_moveseparated);
            
        elseif method == 2
            
            %%% Method 2: Ignores entire trial if animal made pre-emptive
            %%% movement
            boundPC = find(diff([Inf; preCue'; Inf])~=0);
            allperiodsPC = mat2cell(preCue', diff(boundPC)); %%% Separate data based on pre-cue periods, which should be equal to the number of trials.
            TrialPCperiods = allperiodsPC(cellfun(@any, allperiodsPC));

            movement_sep_by_PCperiods = mat2cell(binarizedlever, diff(boundPC));
            movement_during_PCperiods = movement_sep_by_PCperiods(cellfun(@any, allperiodsPC));
            TrialswithPreTrialMovement = find(cellfun(@any, movement_during_PCperiods));

            %%% Find frames corresponding to each cue period/trial
            flaggedframes = cell2mat(framesduringcueperiods(TrialswithPreTrialMovement)); %%% Frames that occur during cue periods that were flagged (e.g. by movement occurring before the cue)

            frames_mov_separated = mat2cell(frameslist', diff(boundM));
            frames_during_movements = frames_mov_separated(cellfun(@any,allperiodsM)); 

            AcceptedTrials = find(cellfun(@(x,y) any(x)&~any(ismember(y,flaggedframes)), rew_during_moveperiods, frames_during_movements));
            CueRewMovements = length(AcceptedTrials);
        end
        %==================================================================
        
        numtrials = length(cue_ind);
        FractionCuedRewardedMovements{animal}(s,1) = sum(CueRewMovements)/numtrials;
    end
    clear data
end

close(h1)

binedges = [0:0.01:1];
WorkingFigure = findobj('Type', 'Figure', 'Name', 'Cued-Rewarded Histogram');
if ~isempty(WorkingFigure)
    figure(WorkingFigure)
    hold on; 
    histdata = cell2mat(FractionCuedRewardedMovements'); histdata = histdata(~isnan(histdata));
    histogram(histdata, 'BinEdges', binedges, 'normalization', 'probability')
else    
    figure('Name', 'Cued-Rewarded Histogram'); 
    histdata = cell2mat(FractionCuedRewardedMovements'); histdata = histdata(~isnan(histdata));
    histogram(histdata, 'BinEdges', binedges, 'normalization', 'probability')
    xlabel('Fraction of Trials with Cued-Rewarded Movements')
    ylabel('Probability')
end
