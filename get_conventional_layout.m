function [nBlockSer, kWhModule_actual, nModSer, nModPar, kWhPack_actual] = ...
    get_conventional_layout(vCell, AhBal, kWhModule_desired, kWhPack_desired, vModule_desired, vPack_desired)

% Return details about the conventional battery pack given desired module,
% pack characteristics. nBlockSer is the number of 100Ah-blocks in series
% within a module, while nModSer and nModPar give the arrangements of
% modules in a pack.


nBlockSer = ceil(vModule_desired/max(vCell));
kWhModule_actual = nBlockSer * mean(vCell) * AhBal/1000;

nModSer = floor(vPack_desired/(nBlockSer * max(vCell)));
nModPar = floor(kWhPack_desired/(nModSer*kWhModule_actual));
kWhPack_actual = kWhModule_actual * nModSer * nModPar;

end
