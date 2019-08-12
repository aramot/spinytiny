function ReDoThresholding(varargin)


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
            eval(['File = ', mouse, '_', date, '_Summary;'])
            MoveThreshold(usersearch,[mouse, '_', date]);
            clear(files(i).name(1:end-4))
            close all
        end
    end
else
    foldertouse = 'E:\ActivitySummary';
    cd(foldertouse)
    for i = 1:length(varargin)
        files = fastdir(cd, varargin{i}, {'ZSeries', 'Poly'});
        for f = 1:length(files)
            load(files{f})
            fname = files{f}(1:end-4);
            eval(['File = MoveThreshold(', fname, ');'])
            eval([fname, ' = File;'])
            disp([fname, ' Threshold Shifted Successfully'])
            save(fname, fname)
            clear(fname)
        end
    end
end
        
        