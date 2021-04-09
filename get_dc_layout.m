function [nModPar, kWhPack_actual] = get_dc_layout(kWhModule, nModSer, kWhPack_desired)

nModPar = floor(kWhPack_desired/(kWhModule*nModSer));
kWhPack_actual = kWhModule * nModSer * nModPar;

end
