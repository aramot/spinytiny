function plotspineanddenddata(varargin)


if isempty(varargin)
    cd('E:\ActivitySummary');

    files = dir('E:\ActivitySummary');
    
    firstfileofint = 4;
    
    good = 0;
    
    while ~good
        randnum = round(firstfileofint + (length(files)-firstfileofint).*rand(1,1)); %%% Choose (number of files of directory) random files from the list of current files to analyze
        
        if isempty(strfind(files(randnum).name, 'PolySummary'))
            good = 1;
                currentfile = load(files(randnum).name);
                File = eval(['currentfile.' files(randnum).name(1:end-4)]);
        end
    end
            
        SpineNo = randi(length(File.deltaF));
        DendriteChoice =  find(~cell2mat(cellfun(@(x) isempty(find(x == SpineNo,1)), File.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located

        figure; 
        h1 = subplot(2,3,1:3);
        plot(File.Fluorescence_Measurement{SpineNo}, 'k')
        
        filename = regexp(File.Filename, '[A-Z]{2,3}0+\d+_\d{4,6}', 'match');
        filename = filename{1};
        session = File.Session;
        title(['Comparison of traces for spine no. ', num2str(SpineNo), ' from ', filename, ' (Session ', num2str(session), ')'], 'Interpreter', 'none')
        
        h2 = subplot(2,3,4:6);
        plot(File.Processed_dFoF(SpineNo, :), 'k');
        hold on;
        plot(File.Processed_Dendrite_dFoF(DendriteChoice, :)/5-2, 'b', 'Linewidth', 2)
        plot(File.SynapseOnlyBinarized(SpineNo,:), 'r', 'Linewidth', 2)
        plot(File.Dendrite_Binarized(DendriteChoice, :)/2-2, 'm', 'Linewidth', 2)
        plot(File.Processed_dFoF_DendriteSubtracted(SpineNo,:), 'Color', [0.6 0.6 0.6], 'Linewidth', 2)
        plot(File.SynapseOnlyBinarized_DendriteSubtracted(SpineNo, :)/2, 'g', 'Linewidth', 2)
        plot(1:length(File.Processed_dFoF_DendriteSubtracted(SpineNo,:)), File.SpineThreshold(SpineNo)*ones(1,length(File.Processed_dFoF_DendriteSubtracted(SpineNo,:))), '--r')
        linkaxes([h1,h2], 'x')

        legend({'Processed Spine Trace', 'Processed Dend Trace', 'Binarized Spine', 'Binarized Dend', 'Dend-subtracted spine trace', 'Binarized dend-sub'})


        
        if isfield(File, 'MinAlpha')
            MinAlpha = File.MinAlpha;
        else
            MinAlpha = 0;
        end
        
        if isfield(File, 'Alphas')
            alpha = cell2mat(File.Alphas);
        else
            alpha = zeros(2,File.NumberofSpines);
        end
        title(['Processed data using calc alpha of ', num2str(alpha(2,SpineNo)), ' and a min alpha of ', num2str(MinAlpha)])

            
else
    cd('E:\ActivitySummary');
    if length(dbstack)==1
        if length(varargin)>1
            File = varargin{1};
            SpineNo = varargin{2};
        else
            File = varargin;
            SpineNo = randi(length(File.deltaF));
        end
    else
        filechoice = varargin{1}{randi([1 length(varargin{1})], 1)};
        filesearch = fastdir('E:\ActivitySummary', filechoice, {'Poly', 'ZSeries'});
        randdate = randi([1 length(filesearch)]);
        load(filesearch{randdate});
        eval(['File = ', filesearch{randdate}(1:end-4), ';']);
        SpineNo = randi(length(File.deltaF));
    end
    
    DendriteChoice =  find(~cell2mat(cellfun(@(x) isempty(find(x == SpineNo,1)), File.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located

    figure; 
    
    h1 = subplot(2,3,1:3);
    plot(File.Fluorescence_Measurement{SpineNo}, 'k')
        filename = regexp(File.Filename, '[A-Z]{2,3}0+\d+_\d{4,6}', 'match');
        filename = filename{1};
        session = File.Session;
    title(['Comparison of traces for spine no. ', num2str(SpineNo), ' from ', filename, ' (Session ', num2str(session), ')'], 'Interpreter', 'none')

    h2 = subplot(2,3,4:6);
    hold on;
    p3 = plot(File.SynapseOnlyBinarized(SpineNo,:), 'r', 'Linewidth', 2);
    p4 = plot(File.Dendrite_Binarized(DendriteChoice, :)/2-1, 'm', 'Linewidth', 2);
    p5 = plot(File.Processed_dFoF_DendriteSubtracted(SpineNo,:), 'Color', [0.6 0.6 0.6], 'Linewidth', 2);
    p6 = plot(File.SynapseOnlyBinarized_DendriteSubtracted(SpineNo, :)/2, 'g', 'Linewidth', 2);
    p1 = plot(File.Processed_dFoF(SpineNo, :), 'k');
    p2 = plot(File.Processed_Dendrite_dFoF(DendriteChoice, :)/5-2, 'b', 'Linewidth', 2);
    linkaxes([h1,h2], 'x')


    legend([p1,p2,p3,p4,p5,p6],{'Processed Spine Trace', 'Processed Dend Trace', 'Binarized Spine', 'Binarized Dend', 'Dend-subtracted spine trace', 'Binarized dend-sub'})

    title(['Comparison of traces for spine no. ', num2str(SpineNo)])
end
