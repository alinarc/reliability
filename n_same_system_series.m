function [X, P] = n_same_system_series(n, x1, p1)
% This function takes in a probability distribution [x, p] for a PE unit
% and returns the resultant distribution [X, P] for n of those PE units
% connected in series.

if n==1
    X = x1;
    P = p1;
else
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
     tempX = min(tempX,[],1);
     tempP = prod(tempP, 1);
     [tempX, tempP] = combine_like_terms(tempX,tempP);
    end
    X = tempX;
    P = tempP;
end
end

    