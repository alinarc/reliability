close all
clear

% Defining values failure rates of components, in failures per hour, based
% on MIL-HDBK-217Plus
scale = 1e6;
lambdaC = 0.001579/scale;
lambdaDiode_Schottky = 0.001965/scale;
lambdaDiode_Zener = 0.003966/scale;
lambdaMosfet = 0.01784/scale;
lambdaL= 0.00000517/scale;
lambdaXfmr = 0.075132/scale;
lambdaIgbt = 0.015855/scale;
lambdaR = 0.00264/scale;

lifetime = 96000; % estimated lifetime of system, based on quarterly report
balanceTime = 0.2*lifetime;

nCapDC = 2; % number of capacitors in DC-DC converter
nDiodeDC = 8;
nMosfetDC = 8;
nInductorDC = 1;
nXfmrDC = 1;

lambdaDC = nCapDC*lambdaC + nDiodeDC*lambdaDiode_Schottky + nMosfetDC*lambdaMosfet + ...
    nInductorDC*lambdaL + nXfmrDC*lambdaXfmr;
Rconv = exp(-lambdaDC*lifetime); % reliability estimate for DC-DC onverter at time 'lifetime'

nCapAC = 5; % number of capacitors in DC-AC inverter
nDiodeAC = 6;
nIgbtAC = 6;
nInductorAC = 6;
nResistorAC = 6;

lambdaAC = nCapAC*lambdaC + nDiodeAC*lambdaDiode_Schottky + nIgbtAC*lambdaIgbt + ...
    nInductorAC*lambdaL + nResistorAC*lambdaR;
Rinv = exp(-lambdaAC*lifetime); % reliability estimate for DC-AC onverter at time 'lifetime'

nCapPB = 1; % number of capacitors in passive balancing system
nDiodePB = 1;
nMosfetPB = 1;
nResistorPB = 3;

lambdaPB = nCapPB*lambdaC + nDiodePB*lambdaDiode_Zener + nMosfetPB*lambdaMosfet + ...
    nResistorPB*lambdaR;
Rpb = exp(-lambdaPB*balanceTime);

energyModule = 4300;
%% System 1: AC layout with passive balancing 
% Consider subsystem 1.1: module with 14 passive balancing systems in
% series.
% In the AC case, the loss of any one balancing circuit represents the loss of a
% whole series string of modules.
nBlockSer = 14;
nModSer_AC = 19;
Xpb_AC = nModSer_AC .* [0 energyModule]; % [Xpb_AC, Ppb] represents the distribution for one passive balancing circuit
Ppb = [1-Rpb Rpb];

% Subsystem 1.1: Module. 14 PB circuits in series
[Xmod_AC, Pmod] = n_same_system_series(nBlockSer, Xpb_AC, Ppb);

% Sub-system 1.2: String. 19 modules connected in series
[Xstring_AC, Pstring_AC] = n_same_system_series(nModSer_AC, Xmod_AC, Pmod);

% Subsystem 1.3: Pack. 6 strings connected in parallel
nModPar_AC = 6;
[Xpack_AC, Ppack_AC] = n_same_system_parallel(nModPar_AC, Xstring_AC, Pstring_AC);

% System 1: System. Inverter connected in series with pack
Xinv_AC = [0 energyModule*nModSer_AC*nModPar_AC]; % [Xinv_AC, Pinv] represents the distribution for one inverter
Pinv = [1-Rinv Rinv];
[Xsys_AC, Psys_AC] = diff_systems_series(Xpack_AC, Ppack_AC, Xinv_AC, Pinv);

%% System 2: DC layout with passive balancing, 1 module per DC-DC converter
% Consider subsystem 2.1: Module. 14 passive balancing circuits connected in series. 

% To start, we need the distribution for one PB circuit. We computed that
% above, but in this case the failure of one PB circuit only results in the
% failure of one module, not a string of modules. So, we modify the Xpb 
% values from System 1 and keep the Ppb values.
Xpb_DC = [0 energyModule];

[Xmod_DC, Pmod] = n_same_system_series(nBlockSer, Xpb_DC, Ppb);

% Subsystem 2.2: Pod. Module in series with DC-DC converter
Xconv =  [0 energyModule]; % [Xconv, Pconv] represents the probabilty distribution for one DC-DC converter
Pconv = [1-Rconv Rconv];
[Xpod, Ppod] = diff_systems_series(Xmod_DC, Pmod, Xconv, Pconv);

% Subsystem 2.3: Pack. 116 Pods connected in parallel
nModPar_DC = 116;
[Xpack_DC, Ppack_DC] = n_same_system_parallel(nModPar_DC, Xpod, Ppod);

% System 2: System. 1 inverter in series with Pack
Xinv_DC = [0 nModPar_DC*energyModule];
[Xsys_DC, Psys_DC] = diff_systems_series(Xpack_DC, Ppack_DC, Xinv_DC, Pinv);

%% System 3: DC layout with active balancing
Rab = exp(-lambdaDC*balanceTime); % reliability of active balance system at 
%   time 'lifetime,' assuming balancing circuits operate 20% of the time

% Consider subsystem 3.1: Module. nBlockSer active balancing circuits connected
% in series
Xab = [0 energyModule]; % [Xab, Pab] represents the probability distribution of one active balancing circuit (DC-DC converter)
Pab = [1-Rab Rab];
[Xmod_DC_AB, Pmod_DC_AB] = n_same_system_series(nBlockSer, Xab, Pab);

% Subsystem 3.2: Pod. Module in series with DC-DC converter
[Xpod_AB, Ppod_AB] = diff_systems_series(Xmod_DC_AB, Pmod_DC_AB, Xconv, Pconv);

% Subsystem 3.3: Pack. 116 Pods connected in parallel
[Xpack_DC_AB, Ppack_DC_AB] = n_same_system_parallel(nModPar_DC, Xpod_AB, Ppod_AB);

% System 3: System. Pack in series with inverter
[Xsys_DC_AB, Psys_DC_AB] = diff_systems_series(Xpack_DC_AB, Ppack_DC_AB, Xinv_DC, Pinv);

%% System 4: DC layout with passive balancing, 2 modules in series connected to each converter
% Now we consider 2 modules connected in series to each DC-DC converter.

% Similar to in System 2, the first building block here will be the module,
% made up of 14 PB circuits in series
% We've already computed this subsystem distribution (Xmod_DC, Pmod), but now the
% loss of any one module circuit results in the loss of 2 modules. So, we keep
% the Pmod values and scale the Xmod_DC values by 2.
nModSer_DC2S = 2;
% Subsystem 4.1: Module. 14 PB circuits in series
Xmod_DC2S = nModSer_DC2S * Xmod_DC;

% Subsystem 4.2: String. 2 modules connected in series
[Xstring_DC2S, Pstring_DC2S] = n_same_system_series(nModSer_DC2S, Xmod_DC2S, Pmod);

% Subsystem 4.3: Pod. String connected in series with DC-DC converter.
% Again we scale the X values for the DC-DC converter, because the failure
% of one DC-DC results in the failure of nModSer_DC modules
Xconv_DC2S = nModSer_DC2S * Xconv;
[Xpod_DC2S, Ppod_DC2S] = diff_systems_series(Xstring_DC2S, Pstring_DC2S, Xconv_DC2S, Pconv)

% Subsystem 4.4: Pack. 58 Strings connected in series
nModPar_DC2S = nModPar_DC / nModSer_DC2S;
[Xpack_DC2S, Ppack_DC2] = n_same_system_parallel(nModPar_DC2S, Xpod_DC2S, Ppod_DC2S);

% System 4: System. Pack in series with inverter
[Xsys_DC2S, Psys_DC2S] = diff_systems_series(Xpack_DC2S, Ppack_DC2, Xinv_DC, Pinv);

%% System 5. DC layout with passive balancing, 3 modules in series connected to each converter
nModSer_DC3S = 3;
% Subsystem 5.1: Module. 14 PB circuits in series
Xmod_DC3S = nModSer_DC3S * Xmod_DC;

% Subsystem 5.2: String. 3 modules in series
[Xstring_DC3S, Pstring_DC3S] = n_same_system_series(nModSer_DC3S, Xmod_DC3S, Pmod);

% Subsystem 5.3: Pod. String in series with DC-DC converter
Xconv_DC3S = nModSer_DC3S * Xconv;
[Xpod_DC3S, Ppod_DC3S] = diff_systems_series(Xstring_DC3S, Pstring_DC3S, Xconv_DC3S, Pconv);

% Subsystem 5.4: Pack. 38 3S pods in parallel, plus one 2S pod
nModPar_DC3S = floor(nModPar_DC/nModSer_DC3S);
[Xpack_DC3S, Ppack_DC3S] = n_same_system_parallel(nModPar_DC3S, Xpod_DC3S, Ppod_DC3S);
size(Xpack_DC3S)
[Xpack_DC3S, Ppack_DC3S] = diff_systems_parallel(Xpack_DC3S, Ppack_DC3S, Xpod_DC2S, Ppod_DC2S);
%pause
% System 5: System. Pack in series with inverter
[Xsys_DC3S, Psys_DC3S] = diff_systems_series(Xpack_DC3S, Ppack_DC3S, Xinv_DC, Pinv);

%% Figures
expectedOutputAC = sum(Xsys_AC.*Psys_AC);
expectedOutputDC_PB = sum(Xsys_DC.*Psys_DC);
expectedOutputDC_AB = sum(Xsys_DC_AB.*Psys_DC_AB);
expectedOutputDC_2S = sum(Xsys_DC2S.*Psys_DC2S); 
expectedOutputDC_3S = sum(Xsys_DC3S.*Psys_DC3S);

figure
bar(Xsys_AC/1000, Psys_AC)
xline(expectedOutputAC/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh',expectedOutputAC/1000), 'FontSize', 14,'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xticks(Xsys_AC/1000)
% xticklabels(Xsys_AC/1000)
xlabel('System available capacity (kWh)')
title('Figure 1. Available capacity pmf for AC system with PB')
saveas(gcf, 'AChisto_PB.png')
pause

figure
bar(Xsys_DC/1000,Psys_DC)
%xticklabels(X4/100)
xline(expectedOutputDC_PB/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh',expectedOutputDC_PB/1000), 'FontSize', 14, 'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
title('Figure 2. Available capacity pmf for DC system with PB and dedicated DC-DC per module')
saveas(gcf, 'DChisto_PB_dedicated_converter.png')

figure
bar(Xsys_DC_AB/1000, Psys_DC_AB)
xline(expectedOutputDC_AB/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh',expectedOutputDC_AB/1000), 'FontSize', 14, 'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
title('Figure 3. Available capacity pmf for DC system with AB and dedicated DC-DC per module')
saveas(gcf, 'DChisto_AB_dedicated_converter.png')

figure
bar(Xsys_DC2S/1000, Psys_DC2S)
xline(expectedOutputDC_2S/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh',expectedOutputDC_2S/1000), 'FontSize', 14, 'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
title('Figure 4. Available capacity pmf for DC system with PB and 2 modules in series with each DC-DC')
saveas(gcf, 'DChisto_PB_2modules.png')
pause

figure
bar(Xsys_DC3S/1000, Psys_DC3S)
xline(expectedOutputDC_3S/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh',expectedOutputDC_3S/1000), 'FontSize', 14, 'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
title('Figure 5. Available capacity pmf for DC system with PB and 3 modules in series with each DC-DC')
saveas(gcf, 'DChisto_PB_3modules.png')

w = 400000;
Whmax_AC = energyModule * nModSer_AC * nModPar_AC
Whmax_DC = energyModule * nModPar_DC
Whmax_DC2S = energyModule * nModSer_DC2S * nModPar_DC2S
Whmax_DC3S = energyModule * (nModSer_DC3S*nModPar_DC3S + nModSer_DC2S)

acceptabilityAC = compute_acceptability(Xsys_AC, Psys_AC, w);
acceptabilityDC_PB = compute_acceptability(Xsys_DC, Psys_DC, w);
acceptabilityDC_AB = compute_acceptability(Xsys_DC_AB, Psys_DC_AB, w);
acceptabilityDC2S = compute_acceptability(Xsys_DC2S, Psys_DC2S, w);
acceptabilityDC3S = compute_acceptability(Xsys_DC3S, Psys_DC3S, w);

% expectedOutputAC = sum(Xsys_AC.*Psys_AC);
% expectedOutputDC_PB = sum(Xsys_DC.*Psys_DC);
% expectedOutputDC_AB = sum(Xsys_DC_AB.*Psys_DC_AB);
% expectedOutputDC_2S = sum(Xsys_DC2S.*Psys_DC2S); 
% expectedOutputDC_3S = sum(Xsys_DC3S.*Psys_DC3S);

acceptability = [acceptabilityAC; acceptabilityDC_PB; acceptabilityDC_AB; acceptabilityDC2S; acceptabilityDC3S];
expectedOutput = [expectedOutputAC; expectedOutputDC_PB; expectedOutputDC_AB; expectedOutputDC_2S; expectedOutputDC_3S];

Whmax = [Whmax_AC; Whmax_DC; Whmax_DC; Whmax_DC2S; Whmax_DC3S];
expectedOutput_pct = round(expectedOutput ./ Whmax .* 100,1);

T1 = table(expectedOutput/1000, expectedOutput_pct, acceptability);
T1.Properties.RowNames = [sprintf("AC system, PB, %0.1f kWh", Whmax_AC/1000), ...
    sprintf("DC system, PB, %0.1f kWh", Whmax_DC/1000), ...
    sprintf("DC system, AB, %0.1f kWh", Whmax_DC/1000), ...
    sprintf("DC system, 2S, %0.1f kWh", Whmax_DC2S/1000), ...
    sprintf("DC system, 3S, %0.1f kWh", Whmax_DC3S/1000)];
T1.Properties.VariableNames = ["Expected output (kWh)", "Expected output (% of max)" "Availability (%)"];
disp(T1)