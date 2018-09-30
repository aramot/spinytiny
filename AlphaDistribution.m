function AlphaDistribution(varargin)

Alphas = cell(1,14);

if isempty(varargin)
    foldertouse = 'E:\ActivitySummary';
    cd(foldertouse)
    files = dir(cd);
    for i = 1:length(files)
        if ~isempty(strfind(files(i).name,'Summary')) && isempty(strfind(files(i).name, 'Poly'))
            mouse = regexp(files(i).name, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
            mouse = mouse{1};
            date = regexp(files(i).name, '_\d+_', 'match');
            date = date{1}(2:end-1);
            cd(foldertouse)
            load(files(i).name);
            eval(['current_session = ', mouse, '_', date, '_Summary.Session;'])
            eval(['Alphas{current_session} = [Alphas{current_session}, ', mouse, '_', date, '_Summary.Alphas];'])
            clear(files(i).name(1:end-4))
        end
    end
else
    foldertouse = 'E:\ActivitySummary';
    cd(foldertouse)
    files = dir(cd);
    for i = 1:length(files)
        if ~isempty(strfind(files(i).name,'Summary')) && isempty(strfind(files(i).name, 'Poly')) 
            if cell2mat(cellfun(@(x) strfind(files(i).name, x),varargin, 'uni', false))
                mouse = regexp(files(i).name, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
                mouse = mouse{1};
                date = regexp(files(i).name, '_\d+_', 'match');
                date = date{1}(2:end-1);
                cd(foldertouse)
                load(files(i).name);
                eval(['current_session = ', mouse, '_', date, '_Summary.Session;'])
                eval(['currentalphas = cell2mat(', mouse, '_', date, '_Summary.Alphas);'])
                eval(['Alphas{current_session} = [Alphas{current_session}, currentalphas(2,:)];'])
                clear(files(i).name(1:end-4))
            end
        end
    end
end

figure; hist(cell2mat(Alphas), round(length(cell2mat(Alphas))/5)); 
xlabel('Alpha Value', 'Fontsize', 14)
ylabel('Count', 'Fontsize', 14)

save('AlphaDistribution', 'Alphas');

