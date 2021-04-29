function [X, P] = diff_systems_series(X1, P1, X2, P2)
% Takes in two distributions [X1, P1] and [X2, P2] representing two
% different PE units or subsystems, returns the distribution that results
% from connecting them in series.
    X = min(combvec(X1,X2),[],1);
    P = prod(combvec(P1,P2),1);
    [X, P] = combine_like_terms(X,P);
end