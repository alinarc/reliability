function [nBlockSer, kWhModule_actual, nModSer, nModPar, kWhPack_actual] = ...
    get_ac_layout(vCell, AhBal, kWhModule_desired, kWhPack_desired, vModule_desired, vPack_desired)

nBlockSer = ceil(vModule_desired/max(vCell));
kWhModule_actual = nBlockSer * mean(vCell) * AhBal/1000;

nModSer = floor(vPack_desired/(nBlockSer * max(vCell)));
nModPar = floor(kWhPack_desired/(nModSer*kWhModule_actual));
kWhPack_actual = kWhModule_actual * nModSer * nModPar;

end
