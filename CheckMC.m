function tdata = CheckMC(animalname, date)

mouse_names = fastdir('Z:\People\Nathan\Data\',animalname);
for i_mouse = 1:length(mouse_names)
    current_mouse = mouse_names{i_mouse};
%     date_strs = fastdir(fullfile('Z:\People\Nathan\Data\',current_mouse),'^\d{6}$');
        date_str = date;
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
        catch e
            disp(e)
        end
        tdata = t_all;
end