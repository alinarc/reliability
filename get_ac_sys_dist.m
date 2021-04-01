function [X, P, energyPack] = get_ac_sys_dist(energyModule, nBlockSer, ...
    nModSer, nModPar, Rbal, Rinv)
    
energyPack = energyModule * nModSer * nModPar;

Pbal = [1-Rbal Rbal];
Xbal = nModSer * [0 energyModule];

[Xmod, Pmod] = n_same_system_series(nBlockSer, Xbal, Pbal);
[Xstring, Pstring] = n_same_system_series(nModSer, Xmod, Pmod);
[Xpack, Ppack] = n_same_system_parallel(nModPar, Xstring, Pstring);

Pinv = [1-Rinv Rinv];
Xinv = [0 energyPack];
[X, P] = diff_systems_series(Xinv, Pinv, Xpack, Ppack);

end