function [X, P] = get_dc_sys_dist(kWhModule, kWhPack, nBlockSer, ...
    nModSer, nModPar, Rbal, Rconv, Rinv)

%energyPack = energyModule * nModSer * nModPar;

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 kWhModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);

Pconv = [1-Rconv Rconv];
Xconv = nModSer * [0 kWhModule];
[Xpod, Ppod] = diff_systems_series(Xstring, Pstring, Xconv, Pconv);

[Xpack, Ppack] = n_same_system_parallel(nModPar, Xpod, Ppod);

Pinv = [1-Rinv Rinv];
Xinv = [0 kWhPack];

[X, P] = diff_systems_series(Xpack, Ppack, Xinv, Pinv);

end