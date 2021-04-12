function [nModPar, kWhPack_actual] = get_dc_layout(kWhModule, nModSer, kWhPack_desired)

    nModPar = round(kWhPack_desired/(kWhModule*nModSer)); 
    
kWhPack_actual = kWhModule * nModSer * nModPar;

end
