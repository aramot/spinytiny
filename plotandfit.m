function plotandfit(x,y)


%%%%%%%%%%%%%%%%%%%%%%
%%Color Information%%%
%%%%%%%%%%%%%%%%%%%%%%

lgray = [0.50 0.51 0.52];   brown = [0.28 0.22 0.14];
gray = [0.50 0.51 0.52];    lbrown = [0.59 0.45 0.28];
yellow = [1.00 0.76 0.05];  orange = [0.95 0.40 0.13];
lgreen = [0.55 0.78 0.25];  green = [0.00 0.43 0.23];
lblue = [0.00 0.68 0.94];   blue = [0.00 0.33 0.65];
magenta = [0.93 0.22 0.55]; purple = [0.57 0.15 0.56];
red = [0.93 0.11 0.14];     black = [0 0 0];
colorj = {red,lblue,green,lgreen,gray,brown,yellow,blue,purple,magenta,orange,brown,lbrown};


axes(gca); hold on;

y = y(~isnan(x));
x = x(~isnan(x));


%%%%%%%%%%%%%%%%%%%%%
usenonzeroonly = 0;
uselog = 0;
%%%%%%%%%%%%%%%%%%%%%

if usenonzeroonly
    x = x(y~=0);
    y = y(y~=0);
    fitlinecolor = green;
    dotcolor = lblue;
else
    fitlinecolor = 'r';
    dotcolor = 'k';
end
if uselog
    y = log(y);
    fitlinecolor = purple;
    dotcolor = orange;
end

plot(x,y, '.','Color', dotcolor, 'MarkerSize', 14)

X = [ones(length(x),1), reshape(x,numel(x),1)];

betas = X\reshape(y,numel(y),1);

ycalc = X*betas;

plot(x,ycalc, 'Color', fitlinecolor)

[~,p] = corrcoef(x,y);
text(max(x) + (0.05*max(x)), ycalc(end), ['p = ', num2str(p(1,2))], 'Fontsize', 8)

if p<0.05
    text(max(x) + (0.05*max(x)), ycalc(end), '*', 'Fontsize', 14)
    drawnow
end