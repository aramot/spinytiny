function RedoLeverActivityDetection(varargin)

h1 = waitbar(0, 'Initializing...');

behdir = 'E:\Behavioral Data\All Summarized Behavior Files list';

totalfilestocover = 0;
for i = 1:length(varargin)
    files = fastdir(behdir, varargin{i});
    totalfilestocover = totalfilestocover+length(files);
end

filecount = 0;
for animal = 1:length(varargin)
    files = fastdir(behdir, varargin{animal}, {'Summarized'});
    cd(behdir)
    for f = 1:length(files)
        load(files{f})
        waitbar(filecount/totalfilestocover, h1, ['Animal ', varargin{animal}, ' file ', num2str(f) '/', num2str(length(files))])
        experiment_name = files{f}(1:end-4);
        eval(['BehData = ', experiment_name, ';'])
        xsg_data = BehData.xsg_data;
        [lever_active, lever_force_resample, lever_force_smooth, lever_velocity_envelope_smooth] = AP_parseLeverMovement_continuous(xsg_data);
        BehData.lever_active = lever_active;
        BehData.lever_force_resample = lever_force_resample;
        BehData.lever_force_smooth = lever_force_smooth;
        BehData.lever_velocity_envelope_smooth = lever_velocity_envelope_smooth;
        eval([experiment_name, ' = BehData;'])
        save(experiment_name, experiment_name);
        clear(files{f}(1:end-4))
        filecount = filecount+1;
    end
end

close(h1)

