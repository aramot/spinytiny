function RedoAnalysis(varargin)

sensor = inputdlg('Enter Sensor', '', 1,{'GCaMP'});

imagedsensor = sensor{1};

foldertouse = 'E:\ActivitySummary';
for i = 1:length(varargin)
    animaltime = tic;
    files = fastdir(foldertouse, varargin{i}, {'ZSeries', 'Poly'});
    for f = 1:length(files)
        filetime = tic;
        cd(foldertouse)
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
        SummarizeCaData(callfile, 'Experimenter', usersearch, 'ImagingSensor', imagedsensor,'currentsession',current_session, 'showFig', false, 'Router', 'Redo');
        toc(filetime)
    end
    toc(animaltime);
end
        
        