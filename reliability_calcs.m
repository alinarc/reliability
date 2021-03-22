% Defining values failure rates of components, in failures per hour, based
% on MIL-HDBK-217Plus
scale = 1e6;
lambdaC = 0.001579/scale;
lambdaDiode = 0.015662/scale;
lambdaMosfet = 0.075132/scale;
lambdaL= 0.00000517/scale;
lambdaXfmr = 0.075132/scale;
lambdaIgbt = 0.034227/scale;
lambdaR = 0.00264/scale;

lifetime = 96000; % estimated lifetime of system, based on quarterly report

nCapDC = 2; % number of capacitors in DC-DC converter
nDiodeDC = 8;
nMosfetDC = 8;
nInductorDC = 1;
nXfmrDC = 1;

lambdaDC = nCapDC*lambdaC + nDiodeDC*lambdaDiode + nMosfetDC*lambdaMosfet + ...
    nInductorDC*lambdaL + nXfmrDC*lambdaXfmr;
Rdc = exp(-lambdaDC*lifetime); % reliability estimate for DC-DC onverter at time 'lifetime'

nCapAC = 5; % number of capacitors in DC-AC inverter
nDiodeAC = 6;
nIgbtAC = 6;
nInductorAC = 6;
nResistorAC = 6;

lambdaAC = nCapAC*lambdaC + nDiodeAC*lambdaDiode + nIgbtAC*lambdaIgbt + ...
    nInductorAC*lambdaL + nResistorAC*lambdaR;
Rac = exp(-lambdaAC*lifetime); % reliability estimate for DC-AC onverter at time 'lifetime'

nCapPB = 1; % number of capacitors in passive balancing system
nDiodePB = 1;
nMosfetPB = 1;
nResistorPB = 3;

lambdaPB = nCapPB*lambdaC + nDiodePB*lambdaDiode + nMosfetPB*lambdaMosfet + ...
    nResistorPB*lambdaR;
Rpb = exp(-lambdaPB*lifetime);

energyModule = 4300;
% System 1: DC layout with passive balancing
% Consider sub-system 1: module with 14 passive balancing systems in series 
x1 = [0 energyModule];
p1 = [1-Rpb Rpb];
nBlockSer = 14;

[X1, P1] = n_same_system_series(nBlockSer,x1,p1);
[X1, P1] = combine_like_terms(X1, P1);

% Consider sub-system 2: module with 14 PB systems in series with DC-DC
% converter
x2 =  [0 energyModule];
p2 = [1-Rdc Rdc];
[X2, P2] = diff_systems_series(X1, P1, x2, p2);
[X2, P2] = combine_like_terms(X2, P2);

% Consider sub-system 3: 116 modules (with converters) connected in parallel
[X3, P3] = n_same_system_parallel(116, X2, P2);

% Consider sub-system 4: 1 inverter in series with sub-system 3
energyPack = 498800;
x4 = [0 energyPack];
p4 = [1-Rac Rac];
[X4, P4] = diff_systems_series(X3, P3, x4, p4);
[X4, P4] = combine_like_terms(X4, P4);

% System 2: AC layout with passive balancing system
% Consider sub-system 5: module with 14 passive balancing systems in
% series. We already computed this distribution above: X1, P1. 
% In the AC case, though, the loss of one module represents the loss of a
% whole series string of modules, so we modify the X1 values and keep the P1 
% values for use here:
nModSer = 19;
X5 = X1 .* nModSer;
P5 = P1;

% Consider sub-system 6: 19 modules connected in series
[X6, P6] = n_same_system_series(nModSer, X5, P5);
[X6, P6] = combine_like_terms(X6,P6)

% Consider sub-system 7: 6 of sub-system 6 connected in parallel
nModPar = 6;
[X7, P7] = n_same_system_parallel(nModPar, X6, P6);

% Consider sub-system 8: inverter connected in series with sub-system 7
x8 = [0 energyModule*nModSer*nModPar];
p8 = p4;
[X8, P8] = diff_systems_series(X7,P7, x8, p8);
[X8, P8] = combine_like_terms(X8, P8)

figure
bar(X8,P8)
xticklabels(X8/1000)
xlabel('System available capacity (kWh)')
title('Available capacity pmf for AC system')
saveas(gcf, 'AChisto.png')

figure
bar(X4,P4)
xticklabels(X4/100)
xlabel('System available capacity (kWh)')
title('Available capacity pmf for DC system')
saveas(gcf, 'DChisto.png')

w = 400000;
acceptabilityAC = compute_acceptability(X8, P8, w);
acceptabilityDC = compute_acceptability(X4, P4, w);

expectedOutputAC = sum(X8.*P8);
expectedOutputDC = sum(X4.*P4);
