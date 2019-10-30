function BehaviorFiltering(varargin)

if strcmpi(getenv('computername'), 'Nathan-Lab-PC')
    behaviorfolder = 'C:\Users\Komiyama\Desktop\Output Data';
    cd(behaviorfolder)
end

for animal = 1:length(varargin)
    experimentname = varargin{animal};
    behaviordata = fastdir(behaviorfolder, {experimentname, 'SummarizedBehavior'});
    for i = 1:length(behaviordata)
        load(behaviordata{i})
        eval(['corrdata = ', behaviordata{i}(1:end-4), '.MovementCorrelation;']);
        y = diag(corrdata);
        y = y(logical(~isnan(y)));
        x = 1:length(logical(~isnan(y)));
        X = [ones(length(x),1),x'];
        fline = X\y;
        ycalc = X*fline;
        figure; plot(y, 'k')
        hold on; plot(x,ycalc, '--r')
        xpos = x(end); ypos = ycalc(end);
        text(xpos,ypos,num2str(fline(2)), 'Color', 'r')
        xlim([1,x(end)+2])
        y = diag(corrdata,1);
        y = y(logical(~isnan(y)));
        x = 2:length(logical(~isnan(y)))+1;
        X = [ones(length(x),1),x'];
        fline = X\y;
        ycalc = X*fline;
        plot(x,y, 'color', [0.51 0.5 0.52])
        plot(x,ycalc, '--g')
        text(xpos,ypos-0.05,num2str(fline(2)), 'Color', 'g')
        title(behaviordata{i}(1:5))
        clear(behaviordata{i})
    end
end