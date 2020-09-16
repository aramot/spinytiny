function fitobject = QuickExpFit(x,y,fittype)

y = y(~isnan(x));
x = x(~isnan(x));
x = x(~isnan(y));
y = y(~isnan(y));

cutoff = 39;

y = y(x<cutoff);
x = x(x<cutoff);

x = reshape(x,numel(x),1);
y = reshape(y,numel(y),1);

fitobject = fit(x,y,fittype);

figure; subplot(1,2,1); 
plot(x,y, '.k', 'markersize', 14)
hold on; fitline = plot(fitobject);

% normfactor = max(fitline.YData); 
% normdata = fitline.YData/normfactor;

normdata = zscore(y);
normfit = zscore(fitline.YData);

subplot(1,2,2)
plot(x, normdata, '.k', 'markersize', 14); hold on; 
plot(fitline.XData,normfit, 'linewidth',2)
