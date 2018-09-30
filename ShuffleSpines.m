function ShuffleSpines(varargin)


foldertouse = 'C:\Users\Komiyama\Desktop\Output Data';
cd(foldertouse)
files = dir(cd);
for i = 1:length(files)
    if ~isempty(strfind(files(i).name,'_Correlations'))
        if cell2mat(cellfun(@(x) strfind(files(i).name, x),varargin, 'uni', false))
            mouse = regexp(files(i).name, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
            mouse = mouse{1};
            date = regexp(files(i).name, '_\d+_', 'match');
            date = date{1}(2:end-1);
            load(files(i).name);
            eval(['current_session = ', mouse, '_', date, '_Summary.Session;'])
            eval(['corrdata = ', mouse, '_', date, '_Summary;'])
        end
    end
    if ~isempty(strfind(files(i).name,'_StatClassified'))
        if cell2mat(cellfun(@(x) strfind(files(i).name, x),varargin, 'uni', false))
            mouse = regexp(files(i).name, '[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d+[^_]', 'match');
            mouse = mouse{1};
            date = regexp(files(i).name, '_\d+_', 'match');
            date = date{1}(2:end-1);
            load(files(i).name);
            eval(['current_session = ', mouse, '_', date, '_Summary.Session;'])
            eval(['statdata = ', mouse, '_', date, '_Summary;'])
        end
    end
end


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
            if ~isempty(statdata{current_session})
                behavior = corrdata{current_session}.BinarizedBehavior;
                shuffledspineID = randperm(length(corrdata{current_session}.SpineDuringMovePeriods));
                movspines = find(statdata{currentsession}.MovementSpines);
            end
            clear(files(i).name(1:end-4))
        end
    end
end

        
        