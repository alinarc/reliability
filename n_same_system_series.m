function [X, P] = n_same_system_series(n, x1, p1)
X = zeros(n, size(x1,2));
P = zeros(size(X));

for i = 1:n
    X(i,:) = x1;
    P(i,:) = p1;
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
X = min(tempX, [], 1);
P = prod(tempP,1);

    