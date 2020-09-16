function [rval,pval] = QuickLinearFit(x,y,sp)

% x(y==Inf) = nan;
% y(y==Inf) = nan;

x = x(~isnan(y));
y = y(~isnan(y));

y = y(~isnan(x));
x = x(~isnan(x));

x = reshape(x,length(x),1);
y = reshape(y,length(y),1);

X = [ones(length(x),1),x];
b = X\y

yCalc = X*b;

if nargin<3
    figure
else
    subplot(1,3,sp)
end

var1 = inputname(1);
var2 = inputname(2);
    
plot(x,y, '.k', 'Markersize', 14)
hold on; plot(x,yCalc, 'r', 'Linewidth', 2)

[r,p] = corrcoef([x,y]);
rval = r(1,2);
pval = p(1,2);

if pval<0.05
    text(max(x), max(sort(yCalc)), {['*, r = ', num2str(r(1,2))], ['p = ' num2str(p(1,2))]}, 'Fontsize', 12)
else
    text(max(x), max(sort(yCalc)), {['ns, r = ', num2str(r(1,2))], ['p = ' num2str(p(1,2))]}, 'Fontsize', 12)
end


xlim([min(x), max(x)+max(x)/5])

xlabel(var1)
ylabel(var2)