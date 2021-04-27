function [nModPar, kWhPack_actual] = get_modular_layout(kWhModule, nModSer, kWhPack_desired)

% Return details about the modular battery pack given desired module, pack
% characteristics. nModSer is fixed and taken as an input; nModPar is
% computed based on desired pack capacity.

nModPar = round(kWhPack_desired/(kWhModule*nModSer)); 
    
kWhPack_actual = kWhModule * nModSer * nModPar;

end
