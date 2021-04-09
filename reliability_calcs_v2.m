close all
clear

kWhModule_desired = 3.5;
vModule_desired = 50;
kWhPack_desired = 500;
vPack_desired_AC = 1000;
vCell = [2.5 3.65];
AhBal = 100;

[nBlockSer, kWhModule, nModSer_AC, nModPar_AC, kWhPack_AC] = get_ac_layout(vCell, ...
    AhBal, kWhModule_desired, kWhPack_desired, vModule_desired, vPack_desired_AC);


% Defining values failure rates of components, in failures per hour, based
% on MIL-HDBK-217Plus
scale = 1e6;
lambdaC = 0.001132136/scale;
lambdaDiode_Schottky = 0.004118174/scale;
lambdaDiode_Zener = 0.003242275/scale;
lambdaMosfet = 0.052231353/scale;
lambdaL= 6.17772e-06/scale;
lambdaXfmr = 0.074071302/scale;
lambdaIgbt = 0.015720489/scale;
lambdaR = 0.002599279/scale;

opHrs = 96000;
D = 0.5;
calHrs = opHrs/D; % estimated lifetime of system, based on quarterly report
balanceTime = 0.2*calHrs;

nCapDC = 2; % number of capacitors in DC-DC converter
nDiodeDC = 8;
nMosfetDC = 8;
nInductorDC = 1;
nXfmrDC = 1;

lambdaDC = nCapDC*lambdaC + nDiodeDC*lambdaDiode_Schottky + nMosfetDC*lambdaMosfet + ...
    nInductorDC*lambdaL + nXfmrDC*lambdaXfmr;
lambdaDC_half_bridge = nCapDC*lambdaC + nDiodeDC/2*lambdaDiode_Schottky + nMosfetDC/2*lambdaMosfet + ...
    nInductorDC*lambdaL + nXfmrDC*lambdaXfmr;
Rconv = exp(-lambdaDC*calHrs); % reliability estimate for DC-DC onverter at time 'lifetime'
Rab = exp(-lambdaDC_half_bridge*balanceTime);
%Rab = exp(-lambdaDC*balanceTime);  

nCapAC = 5; % number of capacitors in DC-AC inverter
nDiodeAC = 6;
nIgbtAC = 6;
nInductorAC = 6;
nResistorAC = 6;

lambdaAC = nCapAC*lambdaC + nDiodeAC*lambdaDiode_Schottky + nIgbtAC*lambdaIgbt + ...
    nInductorAC*lambdaL + nResistorAC*lambdaR;
Rinv = exp(-lambdaAC*calHrs); % reliability estimate for DC-AC onverter at time 'lifetime'

nCapPB = 1; % number of capacitors in passive balancing system
nDiodePB = 1;
nMosfetPB = 1;
nResistorPB = 3;

lambdaPB = nCapPB*lambdaC + nDiodePB*lambdaDiode_Zener + nMosfetPB*lambdaMosfet + ...
    nResistorPB*lambdaR;
Rpb = exp(-lambdaPB*balanceTime);

Ppb = [1-Rpb Rpb];
Pinv = [1-Rinv Rinv];
% kWhModule = 4300;
% nBlockSer = 14;
% nModSer_AC = 19;
% nModPar_AC = 6;
%% 1. First we will consider 4 layouts, all with passive balancing
% 1.a) AC layout
[XacPB, PacPB] = get_ac_sys_dist(kWhModule, kWhPack_AC, nBlockSer, nModSer_AC, nModPar_AC, Rpb, Rinv);
pause
% 1.b) DC layout with 1 module per DC-DC converter
nModSer_DC1 = 1;
%nModPar_DC1 = 116;
[nModPar_DC1, kWhPack_DC1] = get_dc_layout(kWhModule, nModSer_DC1, kWhPack_desired);
[XdcPB1, PdcPB1] = get_dc_sys_dist(kWhModule, kWhPack_DC1, nBlockSer, nModSer_DC1, nModPar_DC1, Rpb, Rconv, Rinv);

% 1.c) DC layout with 2 modules in series per DC-DC converter
nModSer_DC2 = 2;
[nModPar_DC2, kWhPack_DC2] = get_dc_layout(kWhModule, nModSer_DC2, kWhPack_desired);
[XdcPB2, PdcPB2] = get_dc_sys_dist(kWhModule, kWhPack_DC2, nBlockSer, nModSer_DC2, nModPar_DC2, Rpb, Rconv, Rinv);

% 1.d) DC layout with 3 modules in series per DC-DC converter
nModSer_DC3 = 3;
[nModPar_DC3, kWhPack_DC3] = get_dc_layout(kWhModule, nModSer_DC3, kWhPack_desired);
[XdcPB3, PdcPB3] = get_dc_sys_dist(kWhModule, kWhPack_DC3, nBlockSer, nModSer_DC3, nModPar_DC3, Rpb, Rconv, Rinv);

expectedOutputAC_PB = sum(XacPB .* PacPB);
expectedOutputDC_PB1 = sum(XdcPB1 .* PdcPB1);
expectedOutputDC_PB2 = sum(XdcPB2 .* PdcPB2);
expectedOutputDC_PB3 = sum(XdcPB3 .* PdcPB3);

f = figure;
f.Position = [1441 206 900 550];
%sgtitle('Available capacity PMFs for layouts with passive balancing')
subplot(2,2,1)
bar(XacPB, PacPB);
title('AC layout')
xline(expectedOutputAC_PB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputAC_PB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcPB1, PdcPB1);
title('DC layout, modules in 1S')
xline(expectedOutputDC_PB1, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB1),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcPB2, PdcPB2);
title('DC layout, modules in 2S')
xline(expectedOutputDC_PB2, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB2),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcPB3, PdcPB3);
title('DC layout, modules in 3S')
xline(expectedOutputDC_PB3, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB3),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with passive balancing')
saveas(f, 'PBhistos.png')

w = 400;
acceptabilityPB = [compute_acceptability(XacPB, PacPB, w); ...
    compute_acceptability(XdcPB1, PdcPB1, w); ...
    compute_acceptability(XdcPB2, PdcPB2, w); ...
    compute_acceptability(XdcPB3, PdcPB3, w)];

expectedOutputPB = [expectedOutputAC_PB; expectedOutputDC_PB1; expectedOutputDC_PB2; expectedOutputDC_PB3];
 kWhPack = [kWhPack_AC; kWhPack_DC1; kWhPack_DC2; kWhPack_DC3];
expectedOutputPB_pct = round(expectedOutputPB ./ kWhPack .* 100, 1);

title1 = "Table 1. Layout comparisons for passive balancing circuits";
Tpb = table(expectedOutputPB, expectedOutputPB_pct, acceptabilityPB);
Tpb.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", kWhPack(1)); ...
    sprintf("DC layout, 1S, %0.1f kWh", kWhPack(2)); ...
    sprintf("DC layout, 2S, %0.1f kWh", kWhPack(3)); ...
    sprintf("DC layout, 3S, %0.1f kWh", kWhPack(4))];
Tpb.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w)];
disp(title1)
disp(Tpb)

%% 2. Consider same 4 layouts, where each uses active balancing
% 2.a) AC layout
[XacAB, PacAB] = get_ac_sys_dist(kWhModule, kWhPack_AC, nBlockSer, nModSer_AC, nModPar_AC, Rab, Rinv);

% 2.b) DC layout, modules in 1S
[XdcAB1, PdcAB1] = get_dc_sys_dist(kWhModule, kWhPack_DC1, nBlockSer, nModSer_DC1, nModPar_DC1, Rab, Rconv, Rinv);

% 2.c) DC layout, modules in 2S
[XdcAB2, PdcAB2] = get_dc_sys_dist(kWhModule, kWhPack_DC2, nBlockSer, nModSer_DC2, nModPar_DC2, Rab, Rconv, Rinv);

% 2.d) DC layout, modules in 3S
[XdcAB3, PdcAB3] = get_dc_sys_dist(kWhModule, kWhPack_DC3, nBlockSer, nModSer_DC3, nModPar_DC3, Rab, Rconv, Rinv);

expectedOutputAC_AB = sum(XacAB .* PacAB);
expectedOutputDC_AB1 = sum(XdcAB1 .* PdcAB1);
expectedOutputDC_AB2 = sum(XdcAB2 .* PdcAB2);
expectedOutputDC_AB3 = sum(XdcAB3 .* PdcAB3);

f1 = figure;
f1.Position = [1441 206 900 550];
subplot(2,2,1)
bar(XacAB, PacAB);
title('AC layout')
xline(expectedOutputAC_AB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputAC_AB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcAB1, PdcAB1);
title('DC layout, modules in 1S')
xline(expectedOutputDC_AB1, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB1),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcAB2, PdcAB2);
title('DC layout, modules in 2S')
xline(expectedOutputDC_AB2, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB2),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcAB3, PdcAB3);
title('DC layout, modules in 3S')
xline(expectedOutputDC_AB3, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB3),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with active balancing, half bridges')
saveas(f1, 'ABhistos_HB.png')

w = 400;
acceptabilityAB = [compute_acceptability(XacAB, PacAB, w); ...
    compute_acceptability(XdcAB1, PdcAB1, w); ...
    compute_acceptability(XdcAB2, PdcAB2, w); ...  
    compute_acceptability(XdcAB3, PdcAB3, w)];

expectedOutputAB = [expectedOutputAC_AB; expectedOutputDC_AB1; expectedOutputDC_AB2; expectedOutputDC_AB3];
expectedOutputAB_pct = round(expectedOutputAB ./ kWhPack .* 100, 1);

title2 = "Table 2. Layout comparisons for active balancing circuits with half bridges";
%title3 = "Table 3. Layout comparisons for active balancing circuits with half-bridges";
Tab = table(expectedOutputAB./1000, expectedOutputAB_pct, acceptabilityAB);
Tab.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", kWhPack(1)); ...
    sprintf("DC layout, 1S, %0.1f kWh", kWhPack(2)); ...
    sprintf("DC layout, 2S, %0.1f kWh", kWhPack(3)); ...
    sprintf("DC layout, 3S, %0.1f kWh", kWhPack(4))];
Tab.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w)];
%disp(title3)
disp(title2)
disp(Tab)

