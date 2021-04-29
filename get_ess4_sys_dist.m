function [X, P] = get_ess4_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rcon, Rinv)
% The purpose of this function is to return the distribution X,P for ESS 
% layout #3: modular pack + inverter

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);

Pcon = [1-Rcon Rcon];
Xcon = nModSer * [0 kWhModule];
[Xpod, Ppod] = diff_systems_series(Xstring, Pstring, Xcon, Pcon);

[Xpack, Ppack] = n_same_system_parallel(nModPar, Xpod, Ppod);

Pinv = [1-Rinv Rinv];
Xinv = [0 kWhPack];

[X, P] = diff_systems_series(Xpack, Ppack, Xinv, Pinv);

end