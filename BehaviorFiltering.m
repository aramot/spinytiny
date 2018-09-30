myfiles = fastdir(cd, ['NH\w+SummarizedBehavior']);
for i = 1:length(myfiles)
load(myfiles{i})
eval(['corrdata = ', myfiles{i}(1:end-4), '.MovementCorrelation']);
y = diag(corrdata);
y = y(logical(~isnan(y)));
x = 1:length(logical(~isnan(y)));
X = [ones(length(x),1),x'];
fline = X\y;
ycalc = X*fline;
figure; plot(y, 'k')
hold on; plot(x,ycalc, '--r')
text(x(end),ycalc(end),num2str(fline(2)))
xlim([1,x(end)+2])
title(myfiles{i}(1:5))
clear(myfiles{i})
end