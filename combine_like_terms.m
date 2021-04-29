function [X, P] = combine_like_terms(Xn, Pn)
% This function compines redundant states in distribution [Xn, Pn]

X = unique(Xn);
P = zeros(size(X));
for i = 1:size(X,2)
    idx = find(Xn==X(i));
    for j = 1:size(idx,2)
        P(i) = P(i) + Pn(idx(j));
    end
end