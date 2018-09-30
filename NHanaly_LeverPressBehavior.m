function a = NHanaly_LeverPressBehavior(Imaged)

%%% Provided that all behaviorally relevant files are IN THE SAME FOLDER,
%%% the following will analyze them all, and save the output

% [fname pname] = uigetfile;
% 
% cd(pname);
% 
% dispatcher_data = load([pname, fname]);

files = dir(cd);
pname = cd;

for i = 1:length(files)
    if ~isempty(strfind(files(i).name, 'data_@lever2p'))
        dispatcher_data = load(files(i).name);
        fname = files(i).name;
    end
end
    

xsg_data = AP_load_xsg_continuous(pname);

[lever_active, lever_force_resample, lever_force_smooth, lever_velocity_envelope_smooth] = AP_parseLeverMovement_continuous(xsg_data);

if Imaged
    [bhv_frames, imaged_trials, frame_times] = AP_dispatcher2frames_continuous([pname, filesep, fname],xsg_data);
else
    bhv_frames = [];
    imaged_trials = [];
    frame_times = [];
end
a.DispatcherData = dispatcher_data;
a.xsg_data = xsg_data;
a.lever_active = lever_active;
a.lever_force_resample = lever_force_resample;
a.lever_force_smooth = lever_force_smooth;
a.lever_velocity_envelope_smooth = lever_velocity_envelope_smooth;
a.Behavior_Frames = bhv_frames;
a.Imaged_Trials = imaged_trials;
a.Frame_Times = frame_times;

exp = regexp(fname, ['[ABCDEFGHIJKLMNOPQRSTUVWXYZ]{2}\d{3,4}'], 'match');
Date = regexp(fname, '\d{6}', 'match');
experiment_name = regexp(fname,[exp{1}, '_', Date{1}], 'match')
eval([experiment_name{1}, '_Behavior = a']);

save_name = [experiment_name{1}, '_Behavior'];
save(save_name, save_name);
try
    cd('C:\Users\Komiyama\Desktop\Behavioral Data\All Summarized Behavior Files list')
catch
    cd('C:\Users\komiyama\Desktop\Giulia\All Behavioral Data')
end
save(save_name, save_name);
cd(pname);

