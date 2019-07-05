function [outputFile] = DendriteSubtraction(File, Router)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Color Information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
    gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
    yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
    lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
    lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
    magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
    pink = [0.9 0.6 0.6];       lpurple  = [0.7 0.15 1];
    red = [0.85 0.11 0.14];     black = [0 0 0];
    dred = [0.6 0 0];          dorange = [0.8 0.3 0.03];
    bgreen = [0 0.6 0.7];
    colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown};
    rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DendNum = File.NumberofDendrites;
numberofSpines = File.NumberofSpines;

% experimenter = regexp(File, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}', 'match');
% experimenter = experimenter{1};
% Date = regexp(File, '\d{6}', 'match');
% Date = Date{1};

cd 'E:\ActivitySummary'

% files = dir(cd);
% check = 0;
% for i = 1:length(files)
%     if ~isempty(regexp(files(i).name,'_001_001_summed_50_Analyzed_ByNathan')) || ~isempty(regexp(files(i).name,'_001_001_summed_50Analyzed_ByNathan'))
%         load(files(i).name)
%         check = 1;
%     end
% end
% if ~check   %%% If no files were found using the above criteria
%     for i = 1:length(files)
%         if ~isempty(regexp(files(i).name, '001_001_summed_50_Analyzed'))
%             load(files(i).name)
%         else
%         end
%     end
% else
% end
% 
% try
%     eval(['File =' folder, '_', Date, '_001_001_summed_50_Analyzed;'])
% catch
%     temp = who(['*', experimenter, '*']);
%     eval(['File =', temp{1}, ';']);
% end

% filename = regexp(File.Filename, '.tif', 'split');
% filename = filename{1};
% File.Filename = [folder, '_', Date(3:end), '_001_001_summed_50_Analyzed'];
% 
% analyzed = File;
% Scrsz = get(0, 'Screensize');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Dendrite Subtraction (comment out if unwanted) %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
%%% Perform fitting
%%%%%%%%%%%%%%%%%%%

useoldAlphas = 0;

if strcmpi(Router, 'Initial')
    for i = 1:DendNum
        dendDataforfit = File.Processed_Dendrite_dFoF(i,:);
        dendDataforfit(dendDataforfit<=0) = nan;
        for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
            spineDataforfit = File.Processed_dFoF(j,:);
            if sum(isnan(spineDataforfit)) == length(spineDataforfit)
                alpha{i}(1:2,j) = zeros(2,1);
            else
                alpha{i}(1:2,j) = robustfit(dendDataforfit,spineDataforfit);
            end
        end
    end
else
    if useoldAlphas && isfield(File, 'Alphas')
        alpha = File.Alphas;
    else
        for i = 1:DendNum
            dendDataforfit = File.Processed_Dendrite_dFoF(i,:);
            dendDataforfit(dendDataforfit<=0) = nan;
            for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
                spineDataforfit = File.Processed_dFoF(j,:);
                if ~any(~isnan(spineDataforfit))
                    alpha{i}(1:2,j) = nan(2,1);
                    continue
                end
                alpha{i}(1:2,j) = robustfit(dendDataforfit,spineDataforfit);
            end
        end
    end
end

File.Alphas = alpha; 

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Perform subtraction
%%%%%%%%%%%%%%%%%%%%%%%%

UseMinAlpha = 0;
File.UsedMinAlpha = UseMinAlpha;

MinAlpha = 0.5;
File.MinAlpha = MinAlpha;

for i = 1:DendNum
    for j = File.SpineDendriteGrouping{i}(1):File.SpineDendriteGrouping{i}(end)
        %%%% First, check for potential problems in the data
        %%% Step 1: No data (usually an eliminated/not-yet-existing
        %%% spine
        if ~any(File.Processed_dFoF(j,:))
            File.Processed_dFoF_DendriteSubtracted(j,:) = nan(1,length(File.Processed_dFoF(j,:)));
            continue
        end
        %%% Step 2: Check criteria for alpha values
        if alpha{i}(2,j) <= 0 %%% Indicates a bad fit, which often reflects that the spine might not actually be part of the dendrite
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp(['Spine ', num2str(j), ' was not fit properly'])
            if isfield(File, 'QuestionableSpines')
                File.QuestionableSpines = [File.QuestionableSpines, j];
            else
                File.QuestionableSpines = j;
            end
            %%% CHOOSE HOW TO HANDLE THESE DATA!!! 
            %%% If the dendrite is active AND the fit is bad, then this
            %%% probably means the spine should not be considered. If,
            %%% however, the dendrite is NOT active, then this should
            %%% be kept, as an active spine on a silent dendrite MIGHT
            %%% also lead to this...
            if sum(logical(diff([Inf, File.Dendrite_Binarized(i,:), Inf])>0)) < 5
                disp(['Spine ', num2str(j), 'is assumed to be on a silent dendrite... check this!'])
                File.Processed_dFoF_DendriteSubtracted(j,:) = File.Processed_dFoF(j,:);
            else
                File.Processed_dFoF_DendriteSubtracted(j,:) = nan(1,length(File.Processed_dFoF(j,:)));
            end
            continue
        end
        %%% Step 3: Dictate what Alpha value to use
        if UseMinAlpha
            if alpha{i}(2,j) < MinAlpha
                alphatouse = MinAlpha;
                betatouse = alpha{i}(1,j);
            else
                alphatouse = alpha{i}(2,j);
                betatouse = alpha{i}(1,j);
            end
        else
            alphatouse = alpha{i}(2,j);
        end
        if isnan(alphatouse)
            File.Processed_dFoF_DendriteSubtracted(j,:) = nan(1,length(File.Processed_dFoF(j,:)));
            continue
        end
        %%% Step 4: perform subtraction
        betatouse = alpha{i}(1,j);
        denddatatouse = File.Processed_Dendrite_dFoF(i,:); denddatatouse(denddatatouse<0) = 0;  %%% Negative dendrite values should not be used, as they would ADD to the signal
        %%% SIGNAL BEING SUBTRACTED %%%
        signaltosubtract = (alphatouse*denddatatouse);
        %%% ACTUAL SUBTRACTION
        File.Processed_dFoF_DendriteSubtracted(j,:) = File.Processed_dFoF(j,:)-(signaltosubtract);   %%% Subtract all individual points  %             processed_dFoF_Dendsubtracted(j,:) = processed_dFoF(j,:)-(alpha{i}(2,counter)*floored_Dend(i,:));%.*Dglobal(i,:);           %%% Use Dglobal to only subtract times when the ENTIRE dendrite is active
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Binarize Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[square_Ds,floored_Dsubtracted,trueeventcount_Dsubtracted, ~, ~] =  DetectEvents2(File.Processed_dFoF_DendriteSubtracted, 2);

for i = 1:numberofSpines
    frequency_Dsubtracted(i,1) = (nnz(diff(trueeventcount_Dsubtracted(i,:)>0.5)>0)/((length(File.Time)/30.49)/60))';
end

File.Floored_DendriteSubtracted = floored_Dsubtracted;
File.ActivityMap_DendriteSubtracted = trueeventcount_Dsubtracted;
% File.MeanEventAmp = amp;

File.Frequency_DendriteSubtracted = frequency_Dsubtracted;
File.SynapseOnlyBinarized_DendriteSubtracted = square_Ds;

outputFile = File;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot random spine from results;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(Router, 'Redo')

        SpineNo = randi(length(File.deltaF));
        DendriteChoice =  find(~cell2mat(cellfun(@(x) isempty(find(x == SpineNo,1)), File.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located

        figure('Position', get(0,'Screensize')); 
        h1 = subplot(2,3,1:3);
        plot(File.Fluorescence_Measurement{SpineNo}, 'k')
        
        
        filename = regexp(File.Filename, '[A-Z]{2,3}0+\d+_\d{3,6}', 'match');
        filename = filename{1};
        session = File.Session;
        
        
        title(['Comparison of traces for spine no. ', num2str(SpineNo), ' from ', filename, ' (Session ', num2str(session), ')'], 'Interpreter', 'none', 'Fontsize', 10)

        h2 = subplot(2,3,4:6);
        plot(File.Processed_dFoF(SpineNo, :), 'k');
        hold on;
        plot(File.Processed_Dendrite_dFoF(DendriteChoice, :)/5-2, 'b', 'Linewidth', 2)
        plot(File.SynapseOnlyBinarized(SpineNo,:), 'r', 'Linewidth', 2)
        plot(File.Dendrite_Binarized(DendriteChoice, :)/2-2, 'm', 'Linewidth', 2)
        plot(File.Processed_dFoF_DendriteSubtracted(SpineNo,:), 'Color', [0.6 0.6 0.6], 'Linewidth', 2)
        plot(File.SynapseOnlyBinarized_DendriteSubtracted(SpineNo, :)/2, 'g', 'Linewidth', 2)
        if UseMinAlpha
            title(['Processed data using calc alpha of ', num2str(alpha{DendriteChoice}(2,find(File.SpineDendriteGrouping{DendriteChoice}==SpineNo))), ' and a min \alpha of ', num2str(MinAlpha)])
        else
            title(['Processed data using calc alpha of ', num2str(alpha{DendriteChoice}(2,find(File.SpineDendriteGrouping{DendriteChoice}==SpineNo))), ' and no min \alpha'])
        end
        linkaxes([h1,h2], 'x')

        legend({'Processed Spine Trace', 'Processed Dend Trace', 'Binarized Spine', 'Binarized Dend', 'Dend-subtracted spine trace', 'Binarized dend-sub'})

        experimenter = regexp(File.Filename, '[A-Z]{2,3}', 'match');
        experimenter = experimenter{1};
        folder = regexp(File.Filename, [experimenter, '0{1,3}\d+'], 'match');
        folder = folder{1};
else
end

end

