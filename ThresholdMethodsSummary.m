function ThresholdMethodsSummary(varargin)

h1 = waitbar(0, 'Initializing...');

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    activitydir = 'E:\ActivitySummary';
    cd(activitydir)
end

MethodsList = cell(1,length(varargin));

for animal = 1:length(varargin)
    waitbar(animal/length(varargin),h1, ['Animal ', num2str(animal), '/', num2str(length(varargin))])
    experimentname = varargin{animal}; 

    activitydata = fastdir(activitydir, {experimentname, 'Summary'}, {'Poly', 'ZSeries', 'Axon'});
    for act = 1:length(activitydata)
        load(activitydata{act})
        eval(['method = ', activitydata{act}(1:end-4), '.ThresholdMethod;'])
        clear(activitydata{act}(1:end-4))
        MethodsList{animal} = [MethodsList{animal}; method];
    end
end

MethodsListAll = cell2mat(MethodsList');

MethodOneCount = sum(MethodsListAll==1);
MethodTwoCount = sum(MethodsListAll==2);
MethodThreeCount = sum(MethodsListAll==3);

disp(['Method one comprises ', num2str(MethodOneCount/length(MethodsListAll)), ' of the data'])
disp(['Method two comprises ', num2str(MethodTwoCount/length(MethodsListAll)), ' of the data'])
disp(['Method three comprises ', num2str(MethodThreeCount/length(MethodsListAll)), ' of the data'])

close(h1)

