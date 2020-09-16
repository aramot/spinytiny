function ActivityPeriodsSummary(binary, raw, color)

binary = reshape(binary,1,length(binary));
frames = 1:length(binary);

ActBound = find(diff([~binary(1), binary, ~binary(end)]~=0));

AllPeriodsSeparated = mat2cell(binary', diff(ActBound));
FramesSeparated = mat2cell(frames', diff(ActBound));

ActPeriods = AllPeriodsSeparated(cell2mat(cellfun(@any, AllPeriodsSeparated, 'uni', false)));
FramesDuringActPeriods = FramesSeparated(cell2mat(cellfun(@any, AllPeriodsSeparated, 'uni', false)));

maxActDuration = max(cellfun(@length, ActPeriods));

PreActWindow = 45;
PostActWindow = 45;

ExpandedWindows = cellfun(@(x) x(1)-PreActWindow:x(1)+PostActWindow,FramesDuringActPeriods, 'uni', false);

if size(raw,1)>1
    count = 1;
    for i = 1:size(raw,1)
        for j = 1:length(ExpandedWindows)
            try
                TempActivity(j,:) = raw(i,ExpandedWindows{j});
            end
        end
        Activity(i,:) = nanmean(TempActivity,1);
    end
else
    for i = 1:length(ExpandedWindows)
        try
            Activity(i,:) = raw(ExpandedWindows{i});
        end
    end
end

Activity = Activity; %-Activity(:,1);
MeanActivity = nanmean(Activity,1);
ActivitySEM = nanstd(Activity,[],1)/sqrt(size(Activity,1));

% ExistingFigure = findobj('Type', 'figure', 'Name', 'ActFigure');
% if ~isempty(ExistingFigure)
%     ActFigure = ExistingFigure; hold on;
% else
%     ActFigure = figure('Name', 'ActFigure'); 
% end

figure; 

lgray = [0.50 0.51 0.52];       brown = [0.28 0.22 0.14];
gray = [0.50 0.51 0.52];        lbrown = [0.59 0.45 0.28];
yellow = [1.00 0.76 0.05];      orange = [0.95 0.40 0.13];
lgreen = [0.45 0.8 0.35];       green = [0.00 0.43 0.23];
lblue = [0.30 0.65 0.94];       blue = [0.00 0.33 0.65];
magenta = [0.93 0.22 0.55];     purple = [0.57 0.15 0.56];
pink = [0.9 0.6 0.6];           lpurple  = [0.7 0.15 1];
red = [0.85 0.11 0.14];         black = [0.1 0.1 0.15];
dred = [0.6 0 0];               dorange = [0.8 0.3 0.03];
bgreen = [0 0.6 0.7];
colorj = {red,lblue,green,lgreen,gray, lgray,brown,yellow,blue,purple,lpurple,magenta,pink,orange,brown,lbrown, black};
rnbo = {dred, red, dorange, orange, yellow, lgreen, green, bgreen, blue, lblue, purple, magenta, lpurple, pink}; 

% plot(Activity', 'color', lgray); 
% hold on; 
% plot(PreActWindow*ones(10,1), linspace(min(Activity(:)),max(Activity(:)),10), '--k')

eval(['patchcolor = ' color, ';'])

plot(MeanActivity, 'color', patchcolor); hold on;
plot(PreActWindow*ones(10,1), linspace(min(MeanActivity(:)),max(MeanActivity(:)),10), '--k')
 
x_vector = [1:length(MeanActivity)', fliplr(1:length(MeanActivity)')];
patch = fill(x_vector, [MeanActivity+ActivitySEM,fliplr(MeanActivity-ActivitySEM)], patchcolor);
set(patch, 'FaceAlpha', 0.5);
uistack(patch, 'bottom')


