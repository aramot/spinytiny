function RedoAnalysis(varargin)

imagedsensor = 'GCaMP';

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
        
        