function [mus, sigmas] = get_dist_params(X, P)

if iscell(X)
    mus = zeros(size(X));
    sigmas = zeros(size(X));

    for i = 1:size(X)
        Xi = X{i};
        Pi = P{i};
        mus(i) = get_expected_output(Xi, Pi);
        sigmas(i) = std(Xi,Pi);
    end
else 
    mus = get_expected_output(X, P);
    sigmas = std(X, P);
end