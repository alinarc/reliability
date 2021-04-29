function Xbar = get_expected_output(X, P)
% This function returns the mean (expected value) of the distribution [X,P]

Xbar = sum(X .* P);

end