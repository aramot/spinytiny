function QuickLinearFit(x,y,sp)


x = x(~isnan(y));
y = y(~isnan(y));

X = [ones(length(x),1),x];
b = X\y;

yCalc = X*b;

if nargin<3
    figure
else
    subplot(1,2,sp)
end
plot(x,y, '.k', 'Markersize', 14)
hold on; plot(x,yCalc, 'r', 'Linewidth', 2)

[r,p] = corrcoef(x,y);

if p(1,2)<0.05
    text(max(x), max(sort(yCalc)), {['*, r = ', num2str(r(1,2))], ['p = ' num2str(p(1,2))]}, 'Fontsize', 12)
else
    text(max(x), max(sort(yCalc)), {['ns, r = ', num2str(r(1,2))], ['p = ' num2str(p(1,2))]}, 'Fontsize', 12)
end

xlim([min(x), max(x)+1])