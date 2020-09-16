function p = Chi2DiffProportions(x,y,seperator)

n1 = sum(x<seperator);
n2 = sum(y<seperator);
N1 = length(x);
N2 = length(y);
p0 = (n1+n2)/(N1+N2);
n10 = N1*p0;
n20 = N2*p0;
observed = [n1 N1-n1 n2 N2-n2];
expected = [n10 N1-n10 n20 N2-n20];
chi2stat = sum((observed-expected).^2./expected);
p = 1-chi2cdf(chi2stat,1);

%%% This version measures differences in fractions

% % Observed data
% n1 = 1; N1 = 13;
% n2 = 7; N2 = 13;
% x1 = [repmat('a',N1,1); repmat('b',N2,1)];
% x2 = [repmat(1,n1,1); repmat(2,N1-n1,1); repmat(1,n2,1); repmat(2,N2-n2,1)];
% [tbl,chi2stat,pval] = crosstab(x1,x2)
% 
