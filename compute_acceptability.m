function A = compute_acceptability(X, P, w)

%P(X<w) = 0;
%A = sum(P)*100;
A = sum(P(X>=w))*100;
