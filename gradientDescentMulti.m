function [theta, J_history, y_norm] = gradientDescentMulti(X, y, theta, alpha, num_iters)
%GRADIENTDESCENTMULTI Performs gradient descent to learn theta
%   theta = GRADIENTDESCENTMULTI(x, y, theta, alpha, num_iters) updates theta by
%   taking num_iters gradient steps with learning rate alpha

% Initialize some useful values
m = length(y); % number of training examples
J_history = zeros(num_iters, 1);

for iter = 1:num_iters

    % ====================== YOUR CODE HERE ======================
    % Instructions: Perform a single gradient step on the parameter vector
    %               theta. 
    %
    % Hint: While debugging, it can be useful to print out the values
    %       of the cost function (computeCostMulti) and gradient here.
    %

y_norm = (y(:,1)-mean(y))./std(y);

for i = 1:m                     %%% For each observation, find the difference between the model's prediction and the actual value (the 'cost')
    for k = 1:size(X,2)
        h(k) = theta(k)*X(i,k);  %%% The 'hypothesized' portion of each feature (following the equation h0(x) = theta0*x0 + theta1*x1... theta_n *x_n)
    end
    h_theta = sum(h);            %%% The sum of each feature (representing the total hypothesis, following the equation h0(x) = theta0 + theta1*x1... theta_n *x_n)
    for k = 1:size(X,2)
        theta_j(i,k) = (h_theta - y_norm(i))*X(i,k); %%%partial derivative of J(theta_0...theta_n)
    end
end

for i = 1:size(X,2)
    theta(i) = theta(i)- (alpha/m)*sum(theta_j(:,i));
end


    % ============================================================

    % Save the cost J in every iteration    
    J_history(iter) = computeCostMulti(X, y, theta);

end



