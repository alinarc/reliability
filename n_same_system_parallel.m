function [X, P] = n_same_system_parallel(n, x, p)
% the limit for n here is about 20 or it freaks out
X = zeros(n,size(x,2));
P = zeros(size(X));

for i = 1:n
    X(i,:) = x;
    P(i,:) = p;
end

for i = 1:n-1
    if i==1
        tempX = combvec(X(i,:), X(i+1,:));
        tempP = combvec(P(i,:), P(i+1,:));
    else
        tempX = combvec(tempX, X(i+1,:));
        tempP = combvec(tempP, P(i+1,:));
    end
end
X = sum(tempX,1);
P = prod(tempP,1);
