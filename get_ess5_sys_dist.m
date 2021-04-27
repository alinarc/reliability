function [X, P] = get_ess5_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rconv)
% The purpose of this function is to return the distribution X,P for the DC
% layout: DC pack, no inverter

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);

Pconv = [1-Rconv Rconv];
Xconv = nModSer * [0 kWhModule];
[Xpod, Ppod] = diff_systems_series(Xstring, Pstring, Xconv, Pconv);

[Xpack, Ppack] = n_same_system_parallel(nModPar, Xpod, Ppod);

X = Xpack;
P = Ppack;

end