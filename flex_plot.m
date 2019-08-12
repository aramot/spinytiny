function [line_handle] = flex_plot(x,y, stattype, colorS, linewidth)

%%% Data should be ordered as: rows = observations to be summarized
%%% columns = unique sample sets over some dependent variable, e.g. time
% 
% if ~(exist('x', 'var'))
%     x = 1:size(y,2);
% end
% if ~(exist('stattype', 'var'))
%     stattype = 'Parametric';
% end
% if ~(exist('colorS', 'var'))
%     colorS = 'k';
% end
% if ~(exist('linewidth', 'var'))
%     linewidth = 2;
% end

hold on;
if strcmpi(stattype, 'parametric')
    if iscell(y)
        line_handle = plot(x,cell2mat(cellfun(@nanmean, y, 'uni', false)),'color', colorS, 'Linewidth', linewidth);
        for i = 1:length(y)
            SEM = nanstd(y{i})/sqrt(sum(~isnan(y{i})));
            line([x(i),x(i)], [nanmean(y{i})-SEM, nanmean(y{i})+SEM], 'linewidth', 0.5, 'color', colorS);
        end
    else
        if size(y,1) == length(x) && size(y,2) ~= length(x)
            repeatedmeasures_dim = 1;
            sample_dim = 2;
        elseif size(y,2) == length(x) && size(y,1) ~= length(x)
            repeatedmeasures_dim = 2;
            sample_dim = 1;
        else
            sample_dim = 1;
        end
        line_handle = plot(x,nanmean(y,sample_dim), 'color', colorS, 'Linewidth', linewidth);
        for i = 1:size(y,2)
            SEM = nanstd(y(:,i))/sqrt(sum(~isnan(y(:,i))));
            line([x(i),x(i)], [nanmean(y(:,i))-SEM, nanmean(y(:,i))+SEM], 'linewidth', 0.5, 'color', colorS);
        end
        xlim([x(1)-1,x(end)+1])
        %%% Automatically perform regression-based statistics
        
        X = repmat(x,size(y,sample_dim),1);
        y = y(find(~isnan(y)));
        X = X(find(~isnan(y)));
        [~,p] = corrcoef(y,X);
        if length(p)>1
            if p(1,2) < 0.05
                ydata = get(line_handle, 'YData');
                text(x(end)+1, ydata(find(~isnan(ydata), 1,'last')), '*', 'color', colorS, 'Fontsize', 16)
                text(x(end)+1.1, ydata(find(~isnan(ydata), 1,'last')), ['p = ', num2str(p(1,2))], 'color', colorS, 'Fontsize', 6)
            else
                ydata = get(line_handle, 'YData');
                if any(~isnan(ydata))
                    text(x(end)+1, ydata(find(~isnan(ydata), 1,'last')), ['p = ', num2str(p(1,2))], 'color', colorS, 'Fontsize', 6)
                end
            end
        end
    end
elseif strcmpi(stattype, 'nonparametric')
    bootstrpnum = 1000;
    if iscell(y)
        line_handle = plot(x,cell2mat(cellfun(@nanmedian, y, 'uni', false)), 'color', colorS, 'Linewidth', linewidth);
        for i = 1:length(y)
%             Y = prctile(y{i},[25 75]);
            if sum(~isnan(y{i})) >1
                Y = bootci(bootstrpnum, {@median, y{i}(~isnan(y{i}))}, 'alpha', 0.05);   %%% Bootstrap confidence intervals using the median
                line([x(i),x(i)], [Y(1), Y(2)], 'linewidth', 0.5, 'color', colorS);
            else
            end
        end
    else
        line_handle = plot(x,nanmedian(y,1), 'color', colorS, 'Linewidth', linewidth);
        for i = 1:size(y,2)
%             Y = prctile(y(:,i),[25 75]);
            if sum(~isnan(y(:,i)))>1
                Y = bootci(bootstrpnum, {@median, y(~isnan(y(:,i)),i)}, 'alpha', 0.05);     %%% Bootstrap confidence intervals using the median
                line([x(i),x(i)], [Y(1), Y(2)], 'linewidth', 0.5, 'color', colorS);
            end
        end
    end
    xlim([x(1)-1,x(end)+1])
end