function [X, P] = diff_systems_parallel(X1, P1, X2, P2)

X = sum(combvec(X1,X2),1);
P = prod(combvec(P1,P2),1);
[X, P] = combine_like_terms(X,P);
end