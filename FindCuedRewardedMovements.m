function [Bounds,CMovements, CRMovements] = FindCuedRewardedMovements(PreCueTolerance, cuetrace, binarizedlever, reward)

frameslist = 1:length(cuetrace);

%%% Separate the data into cue periods and define a pre-cue window
cue_ind = find(diff(cuetrace)>0); pre_cue_ind = cue_ind-PreCueTolerance; pre_cue_ind(pre_cue_ind<1) = 1;
boundC = find(diff([Inf; cuetrace'; Inf])~=0);
cue_separated = mat2cell(cuetrace', diff(boundC));
preCue = zeros(1,length(cuetrace)); preCue(cell2mat(arrayfun(@(x,y) x:y, pre_cue_ind, cue_ind, 'uni', false))) = 1;

%%% Separate the data into movement periods
boundM = find(diff([Inf; binarizedlever; Inf])~=0);
allperiodsM = mat2cell(binarizedlever, diff(boundM));
framesMseparated = mat2cell(frameslist', diff(boundM));

%%% Find all CUED movements
cuetrace_sep_by_movements = mat2cell(cuetrace', diff(boundM));
cued_movement_addresses = cellfun(@(x,y) any(x)&any(y)&~any(diff(y)>0), allperiodsM, cuetrace_sep_by_movements);    %%% Find the movements (any(allperiodsM)) which has a cue signal (any(cuetrace_sep_by_movements)), excluding those that the cue signal turns on during the movement (any(diff(cuetraec_sep_by_movements)>0))
cuedmovementframes = framesMseparated(cued_movement_addresses);

CMovements = zeros(1,length(cuetrace));
CMovements(cell2mat(cuedmovementframes)) = 1;
CMovements = CMovements';

% Find reward start signals
rewstart = diff([reward;0]); rewstart(rewstart<0)= 0;
rew_move_separated = mat2cell(rewstart, diff(boundM));
rew_during_moveperiods = rew_move_separated(cellfun(@any, allperiodsM));

%==================================================================
    %%% Pre-trial movement filtering 
    
    %%% Method 1: Don't exclude any movements
    
    AcceptedCRTrials = find(cellfun(@(x) any(x), rew_during_moveperiods));
    CewRewMovements = length(AcceptedCRTrials);

    %%% Method 2: Excludes movements that overlap with pre-cue
    %%% periods, but does not abort that trial, allowing for
    %%% subsequent cued-rewarded movements to be considered 
    
    preCueTrace_sep_by_movements = mat2cell(preCue', diff(boundM));
    preCueTrace_sep_by_movements = preCueTrace_sep_by_movements(cellfun(@any, allperiodsM));

    %%% Cued Movements
    
    
    %%% Cued Rewarded Movements

    AcceptedCRTrials = find(cellfun(@(x,y) any(x), rew_during_moveperiods));
    CewRewMovements = length(AcceptedCRTrials);


    %%% Method 2: Ignores entire trial if animal made pre-emptive
    %%% movement
% 
%     AcceptedCRTrials = find(cellfun(@(x,y) any(x)&~any(y), rew_during_moveperiods, preCueTrace_sep_by_movements));
%     CewRewMovements = length(AcceptedCRTrials);


%==========================================================================

frames_mov_separated = mat2cell(frameslist', diff(boundM));
frames_during_movements = frames_mov_separated(cellfun(@any,allperiodsM)); 

%%% Cued Movements
boundstouse = find(diff([Inf; CMovements; Inf]) ~=0);
allperiodblocks = mat2cell(binarizedlever, diff(boundstouse));
newperiodblocks = mat2cell(CMovements, diff(boundstouse));
targetperiods = allperiodblocks(cell2mat(cellfun(@any, newperiodblocks, 'uni', false)));

frames_newperiods_separated = mat2cell(frameslist', diff(boundstouse));
targetframes = frames_newperiods_separated(cell2mat(cellfun(@any, newperiodblocks, 'uni', false)));

Bounds.BoundsofCMovements = boundstouse;
Bounds.AllPeriodsSeparatedbyCMovements = newperiodblocks;
Bounds.PeriodswithCMovements = targetperiods;
Bounds.FramesDuringCMovments = targetframes;

%%% Cued Rewarded Movements
newmovementtrace = zeros(1,length(binarizedlever));
newmovementtrace(cell2mat(frames_during_movements(AcceptedCRTrials))) = 1;
CRMovements = newmovementtrace';

boundstouse = find(diff([Inf; newmovementtrace'; Inf])~=0);
allperiodblocks = mat2cell(binarizedlever, diff(boundstouse));
newperiodblocks = mat2cell(newmovementtrace', diff(boundstouse));
targetperiods = allperiodblocks(cell2mat(cellfun(@any, newperiodblocks, 'uni', false)));

frames_newperiods_separated = mat2cell(frameslist', diff(boundstouse));
targetframes = frames_newperiods_separated(cell2mat(cellfun(@any, newperiodblocks, 'uni', false)));

Bounds.BoundsofCRMovements = boundstouse;
Bounds.AllPeriodsSeparatedbyCRMovements = newperiodblocks;
Bounds.PeriodswithCRMovements = targetperiods;
Bounds.FramesDuringCRMovements = targetframes;




