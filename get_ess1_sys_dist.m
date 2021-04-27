function [X, P] = get_ess1_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rinv, Rxfmr)
% The purpose of this function is to compute and return the distribution X,
% P for AC layout #1: conventional pack, inverter, power (LF) xfmr

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);
[Xpack, Ppack] = n_same_system_parallel(nModPar, Xstring, Pstring);

Pinv = [1-Rinv Rinv];
Xinv = [0 kWhPack];
[X, P] = diff_systems_series(Xinv, Pinv, Xpack, Ppack);

Pxfmr = [1-Rxfmr Rxfmr];
Xxfmr = [0 kWhPack];

[X, P] = diff_systems_series(X, P, Xxfmr, Pxfmr);

end