function [X, P] = diff_systems_parallel(X1, P1, X2, P2)
% Takes in two distributions [X1, P1] and [X2, P2] representing two
% different PE units or subsystems, returns the distribution that results
% from connecting them in parallel. I don't think this function is actually
% used yet but could be useful in the future.

X = sum(combvec(X1,X2),1);
P = prod(combvec(P1,P2),1);
[X, P] = combine_like_terms(X,P);

end