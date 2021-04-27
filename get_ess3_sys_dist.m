function [X, P] = get_ess3_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rcon)
% The purpose of this function is to compute and return the distribution X,
% P for ESS layout #3: conventional pack with DC-DC converter. Note
% that the only difference between this layout and layout #2 is there is no
% inverter: layout #3 is DC-coupled.

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);
[Xpack, Ppack] = n_same_system_parallel(nModPar, Xstring, Pstring);

Pcon = [1-Rcon Rcon];
Xcon = [0 kWhPack];
[X, P] = diff_systems_series(Xpack, Ppack, Xcon, Pcon);
end