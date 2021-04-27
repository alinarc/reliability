function [X, P] = get_ess2_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rinv, Rcon)
% The purpose of this function is to compute and return the distribution X,
% P for AC layout #2: conventional pack, DC-DC converter, inverter. Note
% that the only difference between this layout and layout #1 is we have a
% DC-DC converter here instead of a transformer

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);
[Xpack, Ppack] = n_same_system_parallel(nModPar, Xstring, Pstring);

Pcon = [1-Rcon Rcon];
Xcon = [0 kWhPack];
[X, P] = diff_systems_series(Xpack, Ppack, Xcon, Pcon);

Pinv = [1-Rinv Rinv];
Xinv = [0 kWhPack];
[X, P] = diff_systems_series(X, P, Xinv, Pinv);
end