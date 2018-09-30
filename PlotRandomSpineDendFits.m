cd('E:\ActivitySummary');

files = dir('E:\ActivitySummary');

firstfileofint = 4;

randnum = round(firstfileofint + (length(files)-firstfileofint).*rand(2*length(files),1));
% randnum = randnum(logical(~mod(randnum,2))); 

Data = cell(2,1);
numsamples = 100;

counter = 1;
scroll = 1;
scrsz = get(0, 'ScreenSize');
figure('Position', scrsz);

spinewithdendcounter = zeros(numsamples,1);

method = 'old';
show = 'comparison';

switch method
    case 'old'
        while counter <= numsamples
            if isempty(strfind(files(randnum(scroll)).name, 'PolySummary'))
                currentfile = load(files(randnum(scroll)).name);
                currentstruct = eval(['currentfile.' files(randnum(scroll)).name(1:end-4)]);
                subplot(round(sqrt(numsamples)),round(sqrt(numsamples)),counter)
                randspine = randi(length(currentstruct.Fluorescence_Measurement));
                ParentDendrite =  find(~cell2mat(cellfun(@(x) isempty(find(x == randspine,1)), currentstruct.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located
                try
                    spineDataforfit = currentstruct.Processed_dFoF(randspine, :);
                    Data{counter}.SpineData = spineDataforfit;
                    dendDataforfit = currentstruct.Processed_Dendrite_dFoF(ParentDendrite,:);
                    
                            bound = find(diff([Inf; currentstruct.Dendrite_Binarized(ParentDendrite,:)'; Inf]) ~=0);
                            split = mat2cell(currentstruct.Dendrite_Binarized(ParentDendrite,:)', diff(bound));
                                spine_with_dend = mat2cell(currentstruct.SynapseOnlyBinarized_DendriteSubtracted(randspine,:)', diff(bound));
                                
                                Dend_events = 0;
                                spinewithdendcounter = 0;
                                for k = 1:length(split)
                                    if sum(split{k}) %%% If the dendrite is active
                                        Dend_events = Dend_events+1;
                                        if sum(spine_with_dend{k})  
                                            spinewithdendcounter = spinewithdendcounter+1;
                                        end
                                    end
                                end
                                
                                fractionoverlap = spinewithdendcounter/Dend_events*100;
                    
                    Data{counter}.DendData = dendDataforfit;
%                     alpha(1:2) = robustfit(dendDataforfit,spineDataforfit);
                    alphapos = find(currentstruct.SpineDendriteGrouping{find(~cell2mat(cellfun(@(x) isempty(find(x == randspine,1)), currentstruct.SpineDendriteGrouping, 'Uni', false)))}==randspine);
                    alpha(1:2) = currentstruct.Alphas{ParentDendrite}(1:2,alphapos);
                    plot(dendDataforfit, spineDataforfit, 'ok'); hold on;
                    plot(min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit), alpha(2).*[min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit)], 'r', 'Linewidth', 2)
                    if isfield(currentstruct, 'MinAlpha')
                        minalpha = currentstruct.MinAlpha;
                    else
                        minalpha = 1;
                    end
                    plot(min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit), minalpha*(min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit)), 'b', 'linewidth', 2)
                    title([files(randnum(scroll)).name(1:12), ',' 'sp', num2str(randspine)], 'Interpreter', 'none', 'FontSize', 8)
                    text(min(dendDataforfit)-4, -max(spineDataforfit)/2, [num2str(round(fractionoverlap)), '%O\L'], 'FontSize', 8, 'Color', 'r', 'Interpreter', 'none')

                catch
                    clear currentfile
                    clear currentstruct
                    scroll = scroll+1;
                    continue
                end
                drawnow
                clear currentfile
                clear currentstruct
                counter = counter+1;
                scroll = scroll+1;
            else
                scroll = scroll+1;
            end
        end
    case 'new'
        while counter <= numsamples
            if isempty(strfind(files(randnum(scroll)).name, 'PolySummary'))
                currentfile = load(files(randnum(scroll)).name);
                currentstruct = eval(['currentfile.' files(randnum(scroll)).name(1:end-4)]);
                subplot(round(sqrt(numsamples)),round(sqrt(numsamples)),counter)
                randspine = randi(length(currentstruct.Fluorescence_Measurement));
                ParentDendrite =  find(~cell2mat(cellfun(@(x) isempty(find(x == randspine,1)), currentstruct.SpineDendriteGrouping, 'Uni', false))); %% Get the dendrite on which the chosen spine is located
                try
                    spineDataforfit = currentstruct.Processed_dFoF(randspine, :);
                    Data{counter}.SpineData = spineDataforfit;
                    dendDataforfit = currentstruct.Processed_Dendrite_dFoF(ParentDendrite,:);
                    Data{counter}.DendData = dendDataforfit;
                    alpha(1:2) = robustfit(dendDataforfit,spineDataforfit);
                    msgid = [];
                    [warnmsg, msgid] = lastwarn;
                    if strcmpi(msgid, 'stats:statrobustfit:IterationLimit')
                        iter = 'limitreached';
                    else
                        iter = [];
                    end
                    plot(dendDataforfit, spineDataforfit, 'ok'); hold on;
                    plot(min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit), alpha(2).*[min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit)], 'r', 'Linewidth', 2)
                    switch iter
                        case 'limitreached'
                            text(min(dendDataforfit)-2, max(spineDataforfit), '*', 'Color', 'r');
                        otherwise
                    end
                    switch show
                        case 'comparison'
%                             spineDataforfit2 = currentstruct.Fluorescence_Measurement{randspine};
%                             dendDataforfit2 = currentstruct.Compiled_Dendrite_Fluorescence_Measurement(ParentDendrite, :);
                            spineDataforfit2 = currentstruct.Processed_dFoF(randspine,:);
                            dendDataforfit2 = currentstruct.Processed_Dendrite_dFoF(ParentDendrite,:);
                            
                            bound = find(diff([Inf; currentstruct.Dendrite_Binarized(ParentDendrite,:)'; Inf]) ~=0);
                            split = mat2cell(currentstruct.Dendrite_Binarized(ParentDendrite,:)', diff(bound));
                                spine_with_dend = mat2cell(currentstruct.SynapseOnlyBinarized_DendriteSubtracted(randspine,:)', diff(bound));
                                
                                Dend_events = 0;
                                spinewithdendcounter = 0;
                                for k = 1:length(split)
                                    if sum(split{k}) %%% If the dendrite is active
                                        Dend_events = Dend_events+1;
                                        if sum(spine_with_dend{k})  
                                            spinewithdendcounter = spinewithdendcounter+1;
                                        end
                                    end
                                end
                                
                                fractionoverlap = spinewithdendcounter/Dend_events*100;
                                
                                %%% Downsample baseline;
                                dwnsmpfact = 100;
                                floored_Dend = dendDataforfit2.*currentstruct.Dendrite_Binarized(ParentDendrite,:);
                                floored_Dend(floored_Dend==0) = nan;
                                D_baseline = dendDataforfit2(isnan(floored_Dend));
                                D_signal = dendDataforfit2(~isnan(floored_Dend));
                                S_baseline = spineDataforfit2(isnan(floored_Dend));
                                S_signal = spineDataforfit2(~isnan(floored_Dend));
                                D_baseline = D_baseline(1:dwnsmpfact:end);
                                S_baseline = S_baseline(1:dwnsmpfact:end);
                                dendDataforfit2 = [D_baseline, D_signal];
                                spineDataforfit2 = [S_baseline, S_signal];
                            
                            alpha2(1:2) = robustfit(dendDataforfit2,spineDataforfit2);
                                msgid = [];
                                [warnmsg, msgid] = lastwarn;
                                if strcmpi(msgid, 'stats:statrobustfit:IterationLimit')
                                    iter = 'limitreached';
                                else
                                    iter = [];
                                end
                                switch iter
                                    case 'limitreached'
                                        text(min(dendDataforfit)-2, max(spineDataforfit)/2, '*', 'Color', 'b');
                                    otherwise
                                end
                            plot(min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit), alpha2(2).*[min(dendDataforfit):max(dendDataforfit)/100:max(dendDataforfit)], 'b', 'Linewidth', 2)
                            title([files(randnum(scroll)).name(1:12), ',' 'sp', num2str(randspine)], 'Interpreter', 'none', 'FontSize', 8)
                            text(min(dendDataforfit)-4, -max(spineDataforfit)/2, [num2str(round(fractionoverlap)), '%O\L'], 'FontSize', 8, 'Color', 'r', 'Interpreter', 'none')
                        otherwise
                    end
                catch
                    clear currentfile
                    clear currentstruct
                    scroll = scroll+1;
                    counter = counter+1;
                    continue
                end
                drawnow
                clear currentfile
                clear currentstruct
                counter = counter+1;
                scroll = scroll+1;
            else
                scroll = scroll+1;
            end
        end
end