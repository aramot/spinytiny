mkdir output
mouse_names = fastdir('Z:\People\Nathan\Data\','^NH');
for i_mouse = 1:length(mouse_names)
    current_mouse = mouse_names{i_mouse};
    date_strs = fastdir(fullfile('Z:\People\Nathan\Data\',current_mouse),'^\d{6}$');
    for i_date = 1:length(date_strs)
        date_str = date_strs{i_date};
        ffn = fullfile('Z:\People\Nathan\Data', current_mouse, date_str);
        disp(ffn);
        if(~exist(ffn,'dir'))
             disp('not found')
             continue;
        end
        fn_output = [current_mouse '_' date_str '.fig'];
        ffn_output = fullfile('output',fn_output);
        if(exist(ffn_output,'file'))
            disp('already processed');
            continue;
        end
        try
            [~,ffns_summary]=fastdir(ffn,'_summary\.mat');
            load(ffns_summary{1},'method');
            disp(method);
            [~,ffns_avg]=fastdir(fullfile(ffn,'target'),'_AVG\.tif');
            im = imread(ffns_avg{1});
            t_all = cell(length(ffns_summary),1);
            for i_file =1:length(ffns_summary)
                load(ffns_summary{i_file},'t')
                t_all{i_file} = t;
            end
            t_all = cell2mat(t_all);
            figure('name',ffn,'position',[-1884 50 1789 671]);
            subplot(1,5,[1 2])
            imagesc(im,[30 250]);
            colormap gray;
            box off;
            axis off;
            title([current_mouse ' ' date_str])
            subplot(2,5,3);
            plot(t_all(:,1));
            box off;
            ylim([-128 128])
            ylabel('dx');
            subplot(2,5,8);
            plot(t_all(:,2));
            box off;
            ylim([-128 128])
            ylabel('dy');
            subplot(1,5,[4 5]);
            plot(t_all(:,1),t_all(:,2),'.');
            xlabel('dx');
            ylabel('dy');
            box off
            ylim([-128 128])
            xlim([-128 128])
            title(method);
    %     break;
            savefig(ffn_output);
            close(gcf);
        catch e
            disp(e)
        end
    end
end