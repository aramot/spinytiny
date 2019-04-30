function RedoAnalysis(varargin)

usersearch = 'Nathan';  %%% Change this to search for analyzed files from a different user!
imagedsensor = 'GluSnFR';

if isempty(varargin)
    if ispc
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
                SummarizeCaData(usersearch,[mouse, '_', date], 'ImagingSensor', imagedsensor,'currentsession',current_session, 'showFig', false);
                clear(files(i).name(1:end-4))
                close all
            end
        end
    elseif isunix
        foldertouse = '/usr/local/lab/People/Nathan/Data';
        cd(foldertouse)
        load('CurrentFilesList')
        files = CurrentFilesList;
        for i = 1:length(files)
            if ~isempty(strfind(files{i}{1},'Summary')) 
                mouse = regexp(files{i}{1}, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
                mouse = mouse{1};
                date = regexp(files{i}{1}, '_[0-9]{4,6}_', 'match');
                date = date{1}(2:end-1);
                cd(foldertouse)
                currentsession = files{i}{2};
                SummarizeCaData(usersearch,[mouse, '_', date], 'ImagingSensor', imagedsensor,'currentsession',current_session, 'showFig', false);
            end
        end

    end
else
%     foldertouse = 'E:\ActivitySummary';
%     cd(foldertouse)
%     files = dir(cd);
%     for i = 1:length(files)
%         if ~isempty(strfind(files(i).name,'Summary')) && isempty(strfind(files(i).name, 'Poly')) && isempty(strfind(files(i).name, 'ZSeries'))
%             if cell2mat(cellfun(@(x) strfind(files(i).name, x),varargin, 'uni', false))
%                 mouse = regexp(files(i).name, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
%                 mouse = mouse{1};
%                 date = regexp(files(i).name, '_\d+_', 'match');
%                 date = date{1}(2:end-1);
%                 cd(foldertouse)
%                 load(files(i).name);
%                 eval(['current_session = ', mouse, '_', date, '_Summary.Session;'])
%                 SummarizeCaData(usersearch,[mouse, '_', date], 'ImagingSensor', imagedsensor,'currentsession',current_session, 'showFig', false);
% %                     File = eval(files(i).name(1:end-4));
% %                     SummarizeCaData(usersearch,File, current_session, 0);
%                 clear(files(i).name(1:end-4))
%                 close all
%             end
%         end
%     end
    foldertouse = 'E:\ActivitySummary';
    cd(foldertouse)
    for i = 1:length(varargin)
        files = fastdir(cd, varargin{i}, {'ZSeries', 'Poly'});
        for f = 1:length(files)
            load(files{f})
            fname = files{f}(1:end-4);
            userinitials = regexp(fname, '[A-Z]{2,3}', 'match'); userinitials = userinitials{1};
            switch userinitials
                case 'NH'
                    usersearch = 'Nathan';
                case 'ZL'
                    usersearch = 'Zhongmin';
                case 'PY'
                    usersearch = 'Pantong';
            end
            eval(['current_session = ', fname, '.Session;'])
            clear(fname)
            stoppoint = strfind(fname, '_Summary');
            callfile = fname(1:stoppoint-1);
            SummarizeCaData(callfile, 'Experimenter', usersearch, 'ImagingSensor', imagedsensor,'currentsession',current_session, 'showFig', false);
        end
    end
end
        
        