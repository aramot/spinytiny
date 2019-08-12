function J = computeCostMulti(X, y, theta)
%COMPUTECOSTMULTI Compute cost for linear regression with multiple variables
%   J = COMPUTECOSTMULTI(X, y, theta) computes the cost of using theta as the
%   parameter for linear regression to fit the data points in X and y

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta
%               You should set J to the cost.

for i = 1:m
    for k = 1:size(X,2)
        h(k) = (theta(k)*X(i,k));       %%% Hypothesis for each theta
    end
    h_theta = sum(h);                   %%% Total hypothesis for theta
    J(i) = (h_theta-y(i,1))^2;
end

J = (1/(2*m))*sum(J);                   %%% Cost function


% =========================================================================

end
