function BinIterate(xdata,ydata)

%%% The following will group data into different bins of x data, then plot
%%% the p values (using non-parametric tests of selected bins) over many
%%% different bin sizes. The number of bins can be changed. The bins
%%% used for comparisons should be changed according to the hypothesis of
%%% the relationship (currently, assuming a monotonic increase/decrease,
%%% and so this compares the left-most bin and the right-most bin)

binattempts = [2:20];
count = 1;

for i = binattempts
    [Y, E] = discretize(xdata,i);
    binnedX = [];
    binnedY = [];
    for j = 1:length(E)-1
        binnedX(1,j) = nanmedian(xdata(Y==j));
        binnedY(1,j) = nanmedian(ydata(Y==j));
        if j == 1
            leftmostbin = ydata(Y==j);
        elseif j == length(E)-1
            rightmostbin = ydata(Y==j);
        else
        end
    end
    p(1,count) = ranksum(leftmostbin, rightmostbin);
    count = count+1;
end

figure; subplot(1,2,1)
plot(xdata, ydata, '.k', 'MarkerSize', 14)
X = [ones(length(xdata),1), xdata];
beta = X\ydata;
ycalc = X*beta;
hold on;
plot(xdata, ycalc, 'r')
xlabel(inputname(1))
ylabel(inputname(2))

subplot(1,2,2)
plot(binattempts, p)
hold on; 
plot(binattempts, 0.06*ones(1,length(binattempts)), '--r')
ylim([0 1.1])
xlabel('Number of bins')
ylabel('p value')

title([])