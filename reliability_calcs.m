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

energyModule = 3500;
% Consider sub-system 1: module with 14 passive balancing systems in series 
x1 = [0 energyModule];
p1 = [1-Rpb Rpb];
n = 14;


[X1, P1] = n_same_system_series(n,x1,p1);
[X1, P1] = combine_like_terms(X1, P1)

% Consider sub-system 2: module with 14 PB systems in series with DC-DC
% converter
x2 =  [0 energyModule];
p2 = [1-Rdc Rdc];
[X2, P2] = diff_systems_series(X1, P1, x2, p2);
[X2, P2] = combine_like_terms(X2, P2);

% Consider sub-system 3: 117 modules (with converters) connected in parallel
[X3, P3] = n_same_system_parallel(20, X2, P2);
[X3, P3] = combine_like_terms(X3, P3)
[X4, P4] = n_same_system_parallel(5, X3, P3);
[X4, P4] = combine_like_terms(X4, P4)