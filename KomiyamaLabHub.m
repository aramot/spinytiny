function varargout = KomiyamaLabHub(varargin)
% KOMIYAMALABHUB MATLAB code for KomiyamaLabHub.fig
%      KOMIYAMALABHUB, by itself, creates a new KOMIYAMALABHUB or raises the existing
%      singleton*.
%
%      H = KOMIYAMALABHUB returns the handle to a new KOMIYAMALABHUB or the handle to
%      the existing singleton*.
%
%      KOMIYAMALABHUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KOMIYAMALABHUB.M with the given input arguments.
%
%      KOMIYAMALABHUB('Property','Value',...) creates a new KOMIYAMALABHUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KomiyamaLabHub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KomiyamaLabHub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KomiyamaLabHub

% Last Modified by GUIDE v2.5 02-Aug-2019 19:29:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KomiyamaLabHub_OpeningFcn, ...
                   'gui_OutputFcn',  @KomiyamaLabHub_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before KomiyamaLabHub is made visible.
function KomiyamaLabHub_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KomiyamaLabHub (see VARARGIN)

% Choose default command line output for KomiyamaLabHub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KomiyamaLabHub wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.AnalyzeActivity_ToggleButton, 'Value', 0);
set(handles.AnalyzeBehavior_ToggleButton, 'Value', 0);
set(handles.Timecourse_PushButton, 'Enable', 'off');
set(handles.ClusteringAverage_PushButton, 'Enable', 'off');
set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
set(handles.AlignActivty_PushButton, 'Enable', 'off');
set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');

%%%%%%%%%%%%%%%%%%%%%% Mouse Rollover Text %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% setappdata(gcf, 'Folder', 'C:\Users\Komiyama\Desktop\ActivitySummary_UsingRawData');

Scrsz = get(0, 'Screensize');
    d = dialog('Position', [(Scrsz(3)/2)-125 Scrsz(4)/2-75 250 150], 'Name', 'User');
    txt = uicontrol('Parent', d, 'Style', 'text', 'Position', [10 100 230 30], 'String', 'Select User:');
    btn1 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [35 30 50 25], 'String', 'Nathan', 'Callback', @UserName);
    btn2 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [85.5 30 70 25], 'String', 'Zhongmin', 'Callback', @UserName);
    btn3 = uicontrol('Parent', d, 'Style', 'pushbutton', 'Position', [156 30 50 25], 'String', 'Giulia', 'Callback', @UserName);
    uiwait(d)
    choice = get(d, 'UserData');
    set(handles.figure1, 'UserData', choice);
    delete(d);
    
global gui_KomiyamaLabHub
gui_KomiyamaLabHub.figure.handles = handles;

    
function UserName(hObject, eventdata, ~)

button = get(hObject);

choice = button.String;

sourcewindow = button.Parent;

set(sourcewindow, 'UserData', choice);

uiresume



% --- Outputs from this function are returned to the command line.
function varargout = KomiyamaLabHub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in AnimalName_ListBox.
function AnimalName_ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to AnimalName_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AnimalName_ListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AnimalName_ListBox


% --- Executes during object creation, after setting all properties.
function AnimalName_ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnimalName_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AnalyzeActivity_ToggleButton.
function AnalyzeActivity_ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeActivity_ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnalyzeActivity_ToggleButton

Activity = get(handles.AnalyzeActivity_ToggleButton, 'Value');
Behavior = get(handles.AnalyzeBehavior_ToggleButton, 'Value');

if Activity == 1 && Behavior == 0
    set(handles.Timecourse_PushButton, 'Enable', 'on');
    set(handles.Clustering_PushButton, 'Enable', 'on');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'on');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
elseif Activity == 0 && Behavior == 1
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'off');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'off');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'on');
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
elseif Activity == 1 && Behavior == 1
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'on');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'on');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
    set(handles.AlignActivty_PushButton, 'Enable', 'on');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'on');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'on');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'on');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'on');
    set(handles.Prediction_PushButton, 'Enable', 'on');
    set(handles.PCA_PushButton, 'Enable', 'on');
    set(handles.SpineVolume_PushButton, 'Enable', 'on');
elseif Activity == 0 && Behavior == 0
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'off');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'off');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
end


% --- Executes on button press in AnalyzeBehavior_ToggleButton.
function AnalyzeBehavior_ToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeBehavior_ToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnalyzeBehavior_ToggleButton

Activity = get(handles.AnalyzeActivity_ToggleButton, 'Value');
Behavior = get(handles.AnalyzeBehavior_ToggleButton, 'Value');

if Activity == 1 && Behavior == 0
    set(handles.Timecourse_PushButton, 'Enable', 'on');
    set(handles.Clustering_PushButton, 'Enable', 'on');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'on');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
elseif Activity == 0 && Behavior == 1
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'off');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'off');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'on');   
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
elseif Activity == 1 && Behavior == 1
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'on');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'on');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');
    set(handles.AlignActivty_PushButton, 'Enable', 'on');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'on');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'on');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'on')
    set(handles.FitwithMLR_CheckBox, 'Enable', 'on');
    set(handles.Prediction_PushButton, 'Enable', 'on');
    set(handles.PCA_PushButton, 'Enable', 'on');
    set(handles.SpineVolume_PushButton, 'Enable', 'on');
elseif Activity == 0 && Behavior == 0
    set(handles.Timecourse_PushButton, 'Enable', 'off');
    set(handles.Clustering_PushButton, 'Enable', 'off');
    set(handles.ClusteringAverage_PushButton, 'Enable', 'off');
    set(handles.BehaviorTimecourse_PushButton, 'Enable', 'off');  
    set(handles.AlignActivty_PushButton, 'Enable', 'off');
    set(handles.NewSpineAveraging_PushButton, 'Enable', 'off');
    set(handles.NewSpineAnalysis_PushButton, 'Enable', 'off');
    set(handles.TrialActivityAnalysis_PushButton, 'Enable', 'off');
    set(handles.FitwithMLR_CheckBox, 'Enable', 'off');
    set(handles.Prediction_PushButton, 'Enable', 'off');
    set(handles.PCA_PushButton, 'Enable', 'off');
    set(handles.SpineVolume_PushButton, 'Enable', 'off');
end


function Session_EditableText_Callback(hObject, eventdata, handles)
% hObject    handle to Session_EditableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Session_EditableText as text
%        str2double(get(hObject,'String')) returns contents of Session_EditableText as a double


% --- Executes during object creation, after setting all properties.
function Session_EditableText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Session_EditableText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Timecourse_PushButton.
function Timecourse_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to Timecourse_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
% datafolder = getappdata(KomiyamaLabHub, 'Folder');
datafolder = 'E:\ActivitySummary';

cd(datafolder)
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['TimecourseSummary(', filestoanalyze, ');']);



% --- Executes on button press in ClusteringAverage_PushButton.
function ClusteringAverage_PushButton_Callback(~, ~, handles)
% hObject    handle to ClusteringAverage_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
list = get(handles.AnimalName_ListBox, 'String');
h1 = waitbar(0, 'Initializing...');
Activity = get(handles.AnalyzeActivity_ToggleButton, 'Value');
Behavior = get(handles.AnalyzeBehavior_ToggleButton, 'Value');
% datafolder = getappdata(KomiyamaLabHub, 'Folder');
datafolder = 'E:\ActivitySummary';

if Activity == 1 && Behavior == 0
    filestoanalyze = [];
    animal = list(listpos);
    folder = dir('C:\Users\Komiyama\Desktop\Output Data');
    cd('C:\Users\Komiyama\Desktop\Output Data');    
    source = 'multiple';
    for i = 1:length(folder)
        ismatch = strfind(folder(i).name, '_ClusteringProfile');
        if isempty(ismatch)
            continue
        else
            ismatch2 = strncmp(folder(i).name, animal, 5);
        end
        if sum(ismatch2) ~=0
            load(folder(i).name)
            if isempty(filestoanalyze)
                filestoanalyze = folder(i).name(1:end-4);
            else
                filestoanalyze = [filestoanalyze, ',', folder(i).name(1:end-4)];
            end
        end
        waitbar(i/length(folder), h1, 'Looking for files')
    end
    eval(['NHanalyClusteringAnalysis(', filestoanalyze,',source);']);
    close(h1)          
elseif Activity == 1 && Behavior == 1
    filestoanalyze = [];
    cd('C:\Users\Komiyama\Desktop\Output Data');
    animals = list(listpos);
    allcorrfiles = fastdir(cd, '_SpineCorrelationTimecourse');
    for i = 1:length(allcorrfiles)
        ismatch = strncmp(allcorrfiles{i}, animals, 5);
        if sum(ismatch) ~=0
            load(allcorrfiles{i})
%                 currentanimal = regexp(folder(i).name, '[A-Z]{2,3}0+\d+', 'match');
%                 currentanimal = currentanimal{1};
%                 [usesessions] = blacklist(currentanimal);
%                 eval([folder(i).name(1:end-4), ' = structfun(@(x) x([', num2str(usesessions), ']), ', folder(i).name(1:end-4), ', ''uni'', false)'])
            filestoanalyze = [filestoanalyze, ',', allcorrfiles{i}(1:end-4)];
        end
        waitbar(i/length(allcorrfiles), h1, 'Looking for files')
    end
    filestoanalyze = filestoanalyze(2:end);
    close(h1)
    eval(['ClusterBehaviorCorrelationsAverage(', filestoanalyze, ');']);
end


% --- Executes on button press in Clustering_PushButton.
function Clustering_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to Clustering_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
list = get(handles.AnimalName_ListBox, 'String');
Activity = get(handles.AnalyzeActivity_ToggleButton, 'Value');
Behavior = get(handles.AnalyzeBehavior_ToggleButton, 'Value');
% datafolder = getappdata(KomiyamaLabHub, 'Folder');
datafolder = 'E:\ActivitySummary';

if Activity && ~Behavior 
    h1 = waitbar(0, 'Initializing...');
    folder = dir(datafolder);
    cd(datafolder);
    filestoanalyze = [];
        source = 'single';
        animal = list{listpos};
        for i = 1:length(folder)
            ismatch = strfind(folder(i).name, animal);
            wrongfile = strfind(folder(i).name, 'Poly');
            if ~isempty(ismatch) && isempty(wrongfile)
                load(folder(i).name)
                filestoanalyze = [filestoanalyze, ',', folder(i).name(1:end-4)];
            end
            waitbar(i/length(folder), h1, 'Looking for files...')
        end
        filestoanalyze = filestoanalyze(2:end);
        eval([animal, '_ClusteringProfile = NHanalyClusteringAnalysis(', filestoanalyze, ',source);']);
        cd('C:\Users\Komiyama\Desktop\Output Data');    
        close(h1)
        fname = [animal, '_ClusteringProfile'];
        save(fname, fname);         
elseif Activity && Behavior
    for L = 1:length(listpos)
        filestoanalyze = [];
        count = 1;
        cd(datafolder);
        h1 = waitbar(0, 'Initializing...');
        selection = list{listpos(L)}; animal = regexp(selection, '[\r\f\n]', 'split'); animal = animal{1};
        targetfiles = fastdir(cd, animal, {'Poly', 'ZSeries'});
        for i = 1:length(targetfiles)
            load(targetfiles{i})
            eval(['filesesh = ', targetfiles{i}(1:end-4), '.Session;']);
            usesessions = blacklist(animal);
            if ~ismember(filesesh,usesessions)
                clear(targetfiles{i}(1:end-4))
                waitbar(i/length(targetfiles), h1, 'Looking for files')
                continue
            end
%             filestoanalyze = [filestoanalyze, ',', targetfiles{i}(1:end-4)];
            filestoanalyze{count} = targetfiles{i};
            waitbar(i/length(targetfiles), h1, 'Looking for files')
            clear(targetfiles{i}(1:end-4))
            count = count+1;
        end
        cd('C:\Users\Komiyama\Desktop\Output Data');
        targetCorrfiles = fastdir(cd, [animal, '_Correlations']);
        load(targetCorrfiles{1}(1:end-4))
        eval(['Correlationsfile = ', targetCorrfiles{1}(1:end-4), ';']);
        targetStatfiles = fastdir(cd, [animal, '_StatClassified']);
        load(targetStatfiles{1})
        eval(['StatClassifiedfile = ', targetStatfiles{1}(1:end-4), ';']);

%         filestoanalyze = filestoanalyze(2:end);
        close(h1);
%         eval(['ClusterBehaviorCorrelations(', ...
%             Correlationsfile, ',', ...
%             StatClassifiedfile ',', ...
%             filestoanalyze, ');'])
        ClusterBehaviorCorrelations(Correlationsfile, StatClassifiedfile,...
            filestoanalyze);
        toclear = who('-regexp', animal);
        cellfun(@clear, toclear)
    end
end


% --- Executes on button press in BehaviorTimecourse_PushButton.
function BehaviorTimecourse_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to BehaviorTimecourse_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
list = get(handles.AnimalName_ListBox, 'String');
h1 = waitbar(0, 'Initializing...');
user = get(handles.figure1, 'UserData');
scrsz = get(0, 'ScreenSize');



if length(listpos) ==1
    global LeverTracePlots
    LeverTracePlots.figure = figure('Position', scrsz);
    
        Trials = nan(1,14);
        Rewards = nan(1,14);
        MovingAtTrialStartFaults = nan(1,14);
        ReactionTime = nan(1,14);
        MovementAverages = nan(1,14);
        CuetoReward = nan(1,14);
        MoveDurationBeforeIgnoredTrials = nan(1,14);
        NumberofMovementsDuringITIPreIgnoredTrials = nan(1,14);
        FractionITISpentMovingPreIgnoredTrials = nan(1,14);
        NumberofMovementsDuringITIPreRewardedTrials = nan(1,14);
        FractionITISpentMovingPreRewardedTrials = nan(1,14);

    try
        behaviordir = 'E:\Behavioral Data\All Summarized Behavior Files list';
        activitydir = 'E:\ActivitySummary';
        folder = dir(behaviordir);
        cd(behaviordir);
    catch
        [fname pname] = uigetfile();
        behaviordir = pname;
        folder = dir(pname(1:end-1));
        cd(pname);
    end
    filetoanalyze = [];
    animal = list{listpos};
    %%%%%
    useoldsessions = 0;
    %%%%%
    if useoldsessions
        cd('C:\Users\Komiyama\Desktop\Output Data')
        load([animal, '_SummarizedBehavior'])
        eval(['sessions =', animal, '_SummarizedBehavior.UsedSessions'])
        cd(behaviordir);
    else
        sessions = 1:14;
    end
    sessioncounter = 0;
    behfiles = fastdir(behaviordir, animal, 'Summarized');
    actfiles = fastdir(activitydir, animal, {'ZSeries', 'Poly'});
%     actual_sessions = [];
    if length(sessions)~=length(behfiles)
        sessions = [];
        for bf = 1:length(behfiles)
            currentdate{bf} = regexp(behfiles{bf}, '[0-9]{6}', 'match');
            iscorrespactfile = find(~cellfun(@isempty, (cellfun(@(x) strfind(x,currentdate{bf}{1}), actfiles, 'uni', false))));
            if ~isempty(iscorrespactfile)
                matchedactfile = actfiles(iscorrespactfile);
                z = matfile([activitydir, '\', matchedactfile{1}]);
                fullstruct = eval(['z.', matchedactfile{1}(1:end-4), ';']);
                sessions = [sessions, fullstruct.Session];
                clear z;
                clear fullstruct;
            else
                if ~isempty(sessions)
                    sessions = [sessions, sessions(end)+split(caldiff([datetime(currentdate{bf-1}{1}, 'InputFormat', 'yyMMdd'), datetime(currentdate{bf}{1}, 'InputFormat', 'yyMMdd')]), 'days')]; %%% Find the calendar difference between two sessions (found by using currentdate function with input format known to register strings as dates) then split the answer into numeric values of days
                else
                    sessions = 1;
                end
            end
        end
        if length(unique(sessions))~=length(sessions)
            [~, ind] = unique(sessions);
            temp_session = sessions(ind);
            prob = find(diff([temp_session])>1);
            temp_session = [temp_session(1:prob),NaN, temp_session(prob+1:end)];
            temp_session = fillmissing(temp_session, 'linear');
            sessions = temp_session;
        end
    end
    for i = 1:length(behfiles)
        load(behfiles{i})
        date = regexp(behfiles{i}, '\d{6}\w*_Behavior', 'match');
        wrkspc = who;
        filetoanalyze = wrkspc{~cellfun(@isempty, regexp(who, date))};
        sessioncounter = sessioncounter +1;
%             actual_sessions = [actual_sessions; folder(i).Session];
        LeverTracePlots.CurrentAxes = subplot(2,length(sessions),length(sessions)+sessioncounter); hold on;

        eval(['Behavior = NHanalySummarizeBehavior(', filetoanalyze, ',[', num2str(sessions(i)), ']);']);
        
        MovementMat{sessions(i)} = Behavior.MovementMat;
                
        Trials(1,sessions(i)) = Behavior.Trials;
        Rewards(1,sessions(i)) = Behavior.rewards./Behavior.Trials*100;
        MovingAtTrialStartFaults(1,sessions(i)) = Behavior.MovingAtTrialStartFaults/Behavior.Trials*100;
        ReactionTime(1,sessions(i)) = Behavior.AveRxnTime;
        MovementAverages = Behavior.MovementAve;
        UsedSessions = sessions;
        CuetoReward(1,sessions(i)) = Behavior.AveCueToRew;
        MoveDurationBeforeIgnoredTrials(1,sessions(i)) = nanmedian(Behavior.MoveDurationBeforeIgnoredTrials);
        NumberofMovementsDuringITIPreIgnoredTrials(1,sessions(i)) = nanmedian(Behavior.NumberofMovementsDuringITIPreIgnoredTrials);
        FractionITISpentMovingPreIgnoredTrials(1,sessions(i)) = nanmedian(Behavior.FractionITISpentMovingPreIgnoredTrials);
        NumberofMovementsDuringITIPreRewardedTrials(1,sessions(i)) = nanmedian(Behavior.NumberofMovementsDuringITIPreRewardedTrials);
        FractionITISpentMovingPreRewardedTrials(1,sessions(i)) = nanmedian(Behavior.FractionITISpentMovingPreRewardedTrials);

          
        wrkspc = who;
        clear(wrkspc{~cellfun(@isempty, regexp(who, date))});
        waitbar(i/length(behfiles), h1, 'Looking for files...')
    end
    close(h1)
    
    subplot(2,length(sessions),1:round(length(sessions)/4))
    plot(1:14, Rewards(1:14),'-k', 'Linewidth', 2)
    title('Correct Trials')
    xlabel('Session')
    ylabel('Rewards')
    
    subplot(2,length(sessions),round(length(sessions)/4)+1:round(length(sessions)/2))
    plot(1:14, ReactionTime(1:14), 'k', 'Linewidth', 2); hold on;
    plot(1:14, CuetoReward(1:14), 'r', 'Linewidth',2);
    title('Reaction Time')
    xlabel('Session')
    legend({'Cue to movement', 'Cue to reward'})
    
    for i = sessions
        reducedMovementMat = MovementMat{i}(any(~isnan(MovementMat{i}),2),:);
        [coeffs{i}, scores{i}, ~, ~, explained{i}] = pca(reducedMovementMat');
    end

    [r_lever] = SummarizeLeverPressCorrelations(MovementMat, sessions);
    
    valid_pca_sessions = find(~cellfun(@isempty, explained));
    plot(sessions(ismember(sessions, valid_pca_sessions)), cellfun(@(x) x(1)./100, explained(valid_pca_sessions)), 'r', 'linewidth', 2)
    
    subplot(2,2,2); plot(MoveDurationBeforeIgnoredTrials);
    xlabel('Session')
    ylabel('Duration of Movement Before Ignored Trials')
    
    subplot(2,2,3); plot(NumberofMovementsDuringITIPreIgnoredTrials, 'r', 'Linewidth', 2)
    hold on; plot(NumberofMovementsDuringITIPreRewardedTrials, 'b', 'Linewidth', 2)
    xlabel('Session')
    ylabel('Number of Movements During ITI')
    
    subplot(2,2,4); plot(FractionITISpentMovingPreIgnoredTrials, 'r', 'Linewidth', 2)
    hold on; plot(FractionITISpentMovingPreRewardedTrials, 'b', 'Linewidth', 2)
    xlabel('Session')
    ylabel('Fraction of ITI Spent Moving')
    
    a.rewards = Rewards;
    a.MovementMat = MovementMat;
    a.ReactionTime = ReactionTime;
    a.MovingAtTrialStartFaults = MovingAtTrialStartFaults;
    a.MovementAverages = MovementAverages;
    a.MovementCorrelation = r_lever;
    a.PCA_Coefficients = coeffs;
    a.PCA_Scores = scores;
    a.PCA_VarianceExplained = explained;
    a.UsedSessions = UsedSessions;
    a.CuetoReward = CuetoReward;
    a.MoveDurationBeforeIgnoredTrials = MoveDurationBeforeIgnoredTrials;
    a.NumberofMovementsDuringITIPreIgnoredTrials = NumberofMovementsDuringITIPreIgnoredTrials;
    a.FractionITISpentMovingPreIgnoredTrials =FractionITISpentMovingPreIgnoredTrials;
    a.NumberofMovementsDuringITIPreRewardedTrials = NumberofMovementsDuringITIPreRewardedTrials;
    a.FractionITISpentMovingPreRewardedTrials =FractionITISpentMovingPreRewardedTrials;
    
    eval([animal, '_SummarizedBehavior = a']);
    targetsavedir = 'C:\Users\Komiyama\Desktop\Output Data';
    cd(targetsavedir);
    save([animal, '_SummarizedBehavior'], [animal, '_SummarizedBehavior']);

else
    if strcmpi(user, 'Nathan')
        folder = dir('C:\Users\Komiyama\Desktop\Output Data');
        cd('C:\Users\Komiyama\Desktop\Output Data');
    elseif strcmpi(user, 'Giulia')
        folder = dir('C:\Users\komiyama\Desktop\Giulia\All Behavioral Data');
        cd('C:\Users\komiyama\Desktop\Giulia\All Behavioral Data');
    end
    filetoanalyze = [];
    animal = list(listpos);
    for i = 1:length(folder)
        rightanimal = regexp(folder(i).name, animal);
        rightfile = strfind(folder(i).name, 'Summarized');
        if sum(cell2mat(rightanimal)) ~= 0 && ~isempty(rightfile)
            load(folder(i).name)
%             filestoanalyze = [filestoanalyze, ',', folder(i).name(1:end-4)];
            nameerror = regexp(folder(i).name, '\d'); % if the initials of the user are more than two letters, the save name excludes one; account for this by finding when the first digit character occurs (e.g. position 3 vs. 2 for GLB001 vs. NH001)
            if nameerror(1) > 2
                user = regexp(folder(i).name, '[A-Z]{2,3}', 'match'); user = user{1};
                animalnum = regexp(folder(i).name, '0{1,3}[A-Z,0-9]*', 'match'); animalnum = animalnum{1};
                wrkspc = who;
                combos = nchoosek(user,2);  %%% Cycle through all combinations of the intitials to find the closest match
                for n = 1:size(combos,1)
                    successfullyloaded = [];
                    options{n} = [combos(n,1:2), animalnum, '_SummarizedBehavior'];
                    if sum(~cellfun(@isempty, regexp(who,options{n})))
                        filetoanalyze = [filetoanalyze, ',', wrkspc{~cellfun(@isempty, regexp(who,options{n}))}];
                        successfullyloaded = wrkspc{~cellfun(@isempty, regexp(who,options{n}))};
                    else
                    end
                end
%                 if isempty(successfullyloaded)
%                 end
            else
                filetoanalyze = [filetoanalyze, ',', folder(i).name(1:end-4)];
            end

        end
        waitbar(i/length(folder), h1, 'Looking for files')
    end
    close(h1)
    startpoint = regexp(filetoanalyze, '\w'); startpoint = startpoint(1);
    filetoanalyze = filetoanalyze(startpoint:end);
    eval(['AverageBehavior(', filetoanalyze, ')']);
end


% --- Executes on button press in AlignActivty_PushButton.
function AlignActivty_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to AlignActivty_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global LeverTracePlots

listpos = get(handles.AnimalName_ListBox, 'Value');
list = get(handles.AnimalName_ListBox, 'String');
h1 = waitbar(0, 'Initializing...');

Behavior = cell(14,1);
Activity = cell(14,1);

Beh_folder = dir('E:\Behavioral Data\All Summarized Behavior Files list');
% storeddata = getappdata(KomiyamaLabHub);
% datafolder = storeddata.Folder;
datafolder = 'E:\ActivitySummary';
Act_folder = dir(datafolder);
Output_folder = dir('C:\Users\Komiyama\Desktop\Output Data');
MLRopt = get(handles.FitwithMLR_CheckBox, 'value');

scsz = get(0, 'ScreenSize');


if length(listpos) == 1
    animal = list{listpos};
    LeverTracePlots.figure = figure('Position', scsz);
    for i = 1:length(Act_folder)
        cd(datafolder);
        ismatch = strfind(Act_folder(i).name, animal);
        wrongfile = strfind(Act_folder(i).name, 'Poly');
        wrongfile2 = strfind(Act_folder(i).name, 'ZSeries');
        if ~isempty(ismatch) && isempty(wrongfile) && isempty(wrongfile2)
            load(Act_folder(i).name)
            eval(['currentsession = ', Act_folder(i).name(1:end-4), '.Session;'])
            Activity{currentsession} = Act_folder(i).name(1:end-4);
            cd('E:\Behavioral Data\All Summarized Behavior Files list');
            for j = 1:length(Beh_folder)
                areboth = strncmp(Beh_folder(j).name, Activity(currentsession), 12);    %%% Match the behavior file with the name of the activity file
                if areboth
                    load(Beh_folder(j).name)
                    Behavior{currentsession} = Beh_folder(j).name(1:end-4);
                end
            end
            if ~isempty(Activity{currentsession}) && ~isempty(Behavior{currentsession})
                eval(['[',...
                    animal, '_Aligned{', num2str(currentsession), '},', ...
                    animal, '_Correlations{', num2str(currentsession), '},', ...
                    animal, '_StatClassified{', num2str(currentsession), '},', ...
                    animal, '_TrialInformation{', num2str(currentsession), '},',...
                    animal, '_PredictionModel{', num2str(currentsession), ...
                    '}] = NHanalyAlignBehavior(', Activity{currentsession},',', Behavior{currentsession}, ');'])
                clear(Activity{currentsession})
                clear(Behavior{currentsession})
            elseif ~isempty(Activity{currentsession}) && isempty(Behavior{currentsession})
                clear(Activity{currentsession})
            elseif isempty(Activity{currentsession}) && ~isempty(Behavior{currentsession})
                clear(Behavior{currentsession})
            else
            end
        end
        waitbar(i/(length(Act_folder)), h1, 'Finding and aligning files...')
    end
    fnameAligned = [animal, '_Aligned'];
    fnameCorrelations = [animal, '_Correlations'];
    fnameStatClass = [animal, '_StatClassified'];
    fnameTrial = [animal, '_TrialInformation'];
    fnamePrediction = [animal, '_PredictionModel'];
    
    cd('C:\Users\Komiyama\Desktop\Output Data');
    
    save(fnameAligned, fnameAligned);
    save(fnameCorrelations, fnameCorrelations);
    save(fnameStatClass, fnameStatClass);
    save(fnameTrial, fnameTrial, '-v7.3');
    if MLRopt
        save(fnamePrediction, fnamePrediction);
    else
    end
    toclear = who(['*', animal, '*']);
    for c = 1:length(toclear)
        clear(toclear{c})
    end
    disp(['Animal ', animal, ' alignment complete'])
else
    animals = list(listpos);
    count = 0;
    for f = 1:length(listpos)
    LeverTracePlots.figure = figure('Position', scsz);
        for i = 1:length(Act_folder)
            animal = animals{f};
            LeverTracePlots.figure.Name = animal;
            ismatch = strfind(Act_folder(i).name, animal);
            wrongfile = strfind(Act_folder(i).name, 'Poly');
            wrongfile2 = strfind(Act_folder(i).name, 'ZSeries');
            if ~isempty(ismatch) && isempty(wrongfile) && isempty(wrongfile2)
                cd('E:\ActivitySummary');
                load(Act_folder(i).name)
                eval(['currentsession = ', Act_folder(i).name(1:end-4), '.Session;'])
                Activity{currentsession} = Act_folder(i).name(1:end-4);
                cd('E:\Behavioral Data\All Summarized Behavior Files list');
                for j = 1:length(Beh_folder)
                    areboth = strncmp(Beh_folder(j).name, Activity(currentsession), 12);
                    if areboth
                        load(Beh_folder(j).name)
                        Behavior{currentsession} = Beh_folder(j).name(1:end-4);
                    end
                end
                if ~isempty(Activity{currentsession}) && ~isempty(Behavior{currentsession})
                    eval(['[', ...
                        animal, '_Aligned{', num2str(currentsession), '},', ...
                        animal, '_Correlations{', num2str(currentsession), '},', ...
                        animal, '_StatClassified{', num2str(currentsession), '},', ...
                        animal, '_TrialInformation{', num2str(currentsession), '},',...
                        animal, '_PredictionModel{', num2str(currentsession), ...
                        '}] = NHanalyAlignBehavior(', Activity{currentsession},',', Behavior{currentsession}, ');'])
                    clear(Activity{currentsession})
                    clear(Behavior{currentsession})
                elseif ~isempty(Activity{currentsession}) && isempty(Behavior{currentsession})
                    clear(Activity{currentsession})
                elseif isempty(Activity{currentsession}) && ~isempty(Behavior{currentsession})
                    clear(Behavior{currentsession})
                else
                end
            end
            count = count+1;
            waitbar(count/(length(Act_folder)*length(listpos)), h1, 'Finding and aligning files...')
        end
        fnameAligned = [animal, '_Aligned'];
        fnameCorrelations = [animal, '_Correlations'];
        fnameStatClass = [animal, '_StatClassified'];
        fnameTrial = [animal, '_TrialInformation'];
        fnamePrediction = [animal, '_PredictionModel'];
        
        cd('C:\Users\Komiyama\Desktop\Output Data');

        save(fnameAligned, fnameAligned);
        save(fnameCorrelations, fnameCorrelations);
        save(fnameStatClass, fnameStatClass);
        save(fnameTrial, fnameTrial, '-v7.3');
        if MLRopt
            save(fnamePrediction, fnamePrediction);
        end

        toclear = who('-regexp', animal);
        cellfun(@clear, toclear)
        disp(['Animal ', animal, ' alignment complete'])
        close(LeverTracePlots.figure)
    end
    close(h1)
end

% for i = 1:14
%     if ~isempty(Activity{i}) && ~ isempty(Behavior{i})
%         eval([animal, '_ActBehCorrelations{', num2str(i), '} = NHanalyAlignBehavior(', Activity{i},',', Behavior{i}, ');'])
%     end
%     waitbar((length(Act_folder)+length(Beh_folder)+i)/(length(Act_folder)+length(Beh_folder)+14), h1, ['Aligning activity and behavior of session', num2str(i)])
% end


% --------------------------------------------------------------------
function OpenCode_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to OpenCode_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ActivityCode_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ActivityCode_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function BehaviorCode_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to BehaviorCode_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ActivityBehavior_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ActivityBehavior_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Alignment_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to Alignment_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pname = 'Z:\People\Nathan\Matlab\';
fname = 'KomiyamaLabHub.m';

matlab.desktop.editor.openAndGoToFunction([pname, fname], 'AlignActivty_PushButton_Callback')

edit NHanalyAlignBehavior

% --------------------------------------------------------------------
function ActivityBehaviorClustering_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ActivityBehaviorClustering_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pname = 'Z:\People\Nathan\Matlab\';
fname = 'KomiyamaLabHub.m';

matlab.desktop.editor.openAndGoToFunction([pname, fname], 'Clustering_PushButton_Callback')

edit ClusterBehaviorCorrelations


% --------------------------------------------------------------------
function BehaviorTimecourse_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to BehaviorTimecourse_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pname = 'Z:\People\Nathan\Matlab\';
fname = 'KomiyamaLabHub.m';

matlab.desktop.editor.openAndGoToFunction([pname, fname], 'Behavior_PushButton_Callback')

edit NHanalySummarizeBehavior

% --------------------------------------------------------------------
function ActivityTimecourse_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ActivityTimecourse_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pname = 'Z:\People\Nathan\Matlab\';
fname = 'KomiyamaLabHub.m';

matlab.desktop.editor.openAndGoToFunction([pname, fname], 'Timecourse_PushButton_Callback')

edit SummarizeActivity

% --------------------------------------------------------------------
function ActivityClustering_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ActivityClustering_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pname = 'Z:\People\Nathan\Matlab\';
fname = 'KomiyamaLabHub.m';

matlab.desktop.editor.openAndGoToFunction([pname, fname], 'Clustering_PushButton_Callback')

edit NHanalyClusteringAnalysis.m


% --------------------------------------------------------------------
function Diagnostics_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to Diagnostics_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SpineDendOverlap_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to SpineDendOverlap_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CalcSpineDendOverlap;


% --------------------------------------------------------------------
function SpineDendFitting_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to SpineDendFitting_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PlotRandomSpineDendFits;


% --------------------------------------------------------------------
function InspectRandomTraces_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to InspectRandomTraces_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index = handles.AnimalName_ListBox.Value;

if ~isempty(index)
    animals = handles.AnimalName_ListBox.String(index);
    plotspineanddenddata(animals);
else
    plotspineanddenddata;
end



% --- Executes on button press in DendSubtracted_CheckBox.
function DendSubtracted_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to DendSubtracted_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DendSubtracted_CheckBox

set(handles.DendExcluded_CheckBox, 'value', 0);


% --- Executes on button press in DendExcluded_CheckBox.
function DendExcluded_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to DendExcluded_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DendExcluded_CheckBox

set(handles.DendSubtracted_CheckBox, 'value', 0);


% --------------------------------------------------------------------
function Redo_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to Redo_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function AllAnalysis_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to AllAnalysis_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['RedoAnalysis(', filestoanalyze, ')']);

% --------------------------------------------------------------------
function DendSub_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to DendSub_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['RedoSubtraction(', filestoanalyze, ')']);

% --------------------------------------------------------------------
function CorrShuff_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to CorrShuff_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ShuffleSpines;


% --- Executes on button press in NewSpineAveraging_PushButton.
function NewSpineAveraging_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to NewSpineAveraging_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['NewSpineAveraging(', filestoanalyze, ')']);


% --- Executes on button press in Prediction_PushButton.
function Prediction_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to Prediction_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['AveragePrediction(', filestoanalyze, ')']);


% --- Executes on button press in UnselectAll_PushButton.
function UnselectAll_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to UnselectAll_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.AnimalName_ListBox.Value = [];


% --- Executes on button press in NewSpineAnalysis_PushButton.
function NewSpineAnalysis_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to NewSpineAnalysis_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

sensor = inputdlg('Enter Sensor', '', 1,{'GCaMP'});

eval(['NewSpineAnalysis(', filestoanalyze,',', '''', sensor{1}, ''')']);



% --- Executes on button press in TrialActivityAnalysis_PushButton.
function TrialActivityAnalysis_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to TrialActivityAnalysis_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);


eval(['TrialActivityAnalysis(', filestoanalyze, ')']);


% --- Executes on button press in PCA_PushButton.
function PCA_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to PCA_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% Note: This code can only be run after first running
%%% TrialActivityAnalysis, the outputs of this function serving as the
%%% inputs to the current

cd('C:\Users\Komiyama\Desktop\Output Data')

sensorused = inputdlg('Enter Sensor', '', 1,{'GCaMP'});
sensorused = sensorused{1};

datafile = fastdir(cd, [sensorused, '_TrialDataSummary']);
load(datafile{1})

featuresfile = fastdir(cd, [sensorused, '_TrialFeatures']);
load(featuresfile{1})

TrialActivityPCA(TrialDataSummary, TrialFeatures);




% --- Executes on button press in FitwithMLR_CheckBox.
function FitwithMLR_CheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to FitwithMLR_CheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FitwithMLR_CheckBox


% --------------------------------------------------------------------
function Thresholding_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to Thresholding_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['ReDoThresholding(', filestoanalyze, ')']);


% --------------------------------------------------------------------
function HistogramofAlphas_Callback(hObject, eventdata, handles)
% hObject    handle to HistogramofAlphas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['AlphaHistogram(', filestoanalyze, ')']);



% --- Executes on button press in SpineVolume_PushButton.
function SpineVolume_PushButton_Callback(hObject, eventdata, handles)
% hObject    handle to SpineVolume_PushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['SpineVolumeSummary(', filestoanalyze, ')']);


% --------------------------------------------------------------------
function ThreshMethods_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to ThreshMethods_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listpos = get(handles.AnimalName_ListBox, 'Value');
fulllist = get(handles.AnimalName_ListBox, 'String');
animals = fulllist(listpos);
filestoanalyze = [];
for i = 1:length(animals)
    filestoanalyze =[filestoanalyze, ',''',animals{i}, ''''];
end
filestoanalyze =  filestoanalyze(2:end);

eval(['ThresholdMethodsSummary(', filestoanalyze, ')']);
