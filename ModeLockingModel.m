scrsz = get(0, 'Screensize');
figure('Position', [scrsz(1)+scrsz(3)/10, scrsz(2)+scrsz(4)/10, scrsz(3)-scrsz(3)/5, scrsz(4)-scrsz(4)/5]); 
ax1 = subplot(1,2,1); hold on; 
ylim([-1 1]); 
xlim([-2*pi, 2*pi])
set(gca, 'XTick', [-2*pi, 0, 2*pi]);
set(gca, 'XTickLabel', [{'Mirror 1'}, {'TiSaph'}, {'Mirror 2'}]')
set(gca, 'YTick', [])

ax2 = subplot(1,2,2);  ylim([-1.1 1.1]); hold on;

x =-2*pi:0.001:2*pi;
xlim([-2*pi, 2*pi])
set(gca, 'XTick', [-2*pi, 0, 2*pi]);
set(gca, 'XTickLabel', [{'Mirror 1'}, {'TiSaph'}, {'Mirror 2'}]')
set(gca, 'YTick', [])


for i = 1:0.5:1000
    
axes(ax1); cla;

for j = 1:8
    if any(mod(j,2)) %%% if the counter is odd
        data(j,:) = cos(0.25*j*i)*cos(0.25*j*x);
    else
        data(j,:) = sin(0.25*j*i)*sin(0.25*j*x);
    end
end

plot(x,data');
% plot(cosdata', data'); 

allwaves = sum(data,1);
allwaves = allwaves./max(abs(allwaves));

%%% Plot electric field at modes
modecenters = [-3*pi/2 -pi -3*pi/4 -pi/2 -pi/4 0 pi/4 pi/2  3*pi/4 pi 3*pi/2];
mode_unit = ceil(length(allwaves)/length(modecenters));
mode_address = (modecenters+2*pi)/(4*pi).*length(allwaves);
plot(modecenters, allwaves(round(mode_address)), 'ok', 'markerfacecolor', 'k', 'linewidth', 2)

axes(ax2); cla
% plot(cosdata,allwaves)
plot(x,allwaves)
pause(0.1)
end