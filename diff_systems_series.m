function [X, P] = diff_systems_series(X1, P1, X2, P2)

    X = min(combvec(X1,X2),[],1);
    P = prod(combvec(P1,P2),1);
    
end