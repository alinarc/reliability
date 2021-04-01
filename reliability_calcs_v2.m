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
lambdaDC_half_bridge = nCapDC*lambdaC + nDiodeDC/2*lambdaDiode_Schottky + nMosfetDC/2*lambdaMosfet + ...
    nInductorDC*lambdaL + nXfmrDC*lambdaXfmr;
Rconv = exp(-lambdaDC*lifetime); % reliability estimate for DC-DC onverter at time 'lifetime'
Rab = exp(-lambdaDC_half_bridge*balanceTime);
%Rab = exp(-lambdaDC*balanceTime);

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

Ppb = [1-Rpb Rpb];
Pinv = [1-Rinv Rinv];
energyModule = 4300;
nBlockSer = 14;
nModSer_AC = 19;
nModPar_AC = 6;
%% 1. First we will consider 4 layouts, all with passive balancing
% 1.a) AC layout
[XacPB, PacPB, energyPackAC] = get_ac_sys_dist(energyModule, nBlockSer, nModSer_AC, nModPar_AC, Rpb, Rinv);

% 1.b) DC layout with 1 module per DC-DC converter
nModSer_DC1 = 1;
nModPar_DC1 = 116;
[XdcPB1, PdcPB1, energyPackDC1] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC1, nModPar_DC1, Rpb, Rconv, Rinv);

% 1.c) DC layout with 2 modules in series per DC-DC converter
nModSer_DC2 = 2;
nModPar_DC2 = nModPar_DC1 / nModSer_DC2;
[XdcPB2, PdcPB2, energyPackDC2] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC2, nModPar_DC2, Rpb, Rconv, Rinv);

% 1.d) DC layout with 3 modules in series per DC-DC converter
nModSer_DC3 = 3;
nModPar_DC3 = ceil(nModPar_DC1 / nModSer_DC3);
[XdcPB3, PdcPB3, energyPackDC3] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC3, nModPar_DC3, Rpb, Rconv, Rinv);

expectedOutputAC_PB = sum(XacPB .* PacPB);
expectedOutputDC_PB1 = sum(XdcPB1 .* PdcPB1);
expectedOutputDC_PB2 = sum(XdcPB2 .* PdcPB2);
expectedOutputDC_PB3 = sum(XdcPB3 .* PdcPB3);

f = figure;
f.Position = [1441 206 900 550];
%sgtitle('Available capacity PMFs for layouts with passive balancing')
subplot(2,2,1)
bar(XacPB/1000, PacPB);
title('AC layout')
xline(expectedOutputAC_PB/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputAC_PB/1000),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcPB1/1000, PdcPB1);
title('DC layout, modules in 1S')
xline(expectedOutputDC_PB1/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB1/1000),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcPB2/1000, PdcPB2);
title('DC layout, modules in 2S')
xline(expectedOutputDC_PB2/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB2/1000),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcPB3/1000, PdcPB3);
title('DC layout, modules in 3S')
xline(expectedOutputDC_PB3/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_PB3/1000),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with passive balancing')
saveas(f, 'PBhistos.png')

w = 400000;
acceptabilityPB = [compute_acceptability(XacPB, PacPB, w); ...
    compute_acceptability(XdcPB1, PdcPB1, w); ...
    compute_acceptability(XdcPB2, PdcPB2, w); ...
    compute_acceptability(XdcPB3, PdcPB3, w)];

expectedOutputPB = [expectedOutputAC_PB; expectedOutputDC_PB1; expectedOutputDC_PB2; expectedOutputDC_PB3];
 energyPack = [energyPackAC; energyPackDC1; energyPackDC2; energyPackDC3];
expectedOutputPB_pct = round(expectedOutputPB ./ energyPack .* 100, 1);

title1 = "Table 1. Layout comparisons for passive balancing circuits";
Tpb = table(expectedOutputPB./1000, expectedOutputPB_pct, acceptabilityPB);
Tpb.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", energyPack(1)/1000); ...
    sprintf("DC layout, 1S, %0.1f kWh", energyPack(2)/1000); ...
    sprintf("DC layout, 2S, %0.1f kWh", energyPack(3)/1000); ...
    sprintf("DC layout, 3S, %0.1f kWh", energyPack(4)/1000)];
Tpb.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w/1000)];
disp(title1)
disp(Tpb)

%% 2. Consider same 4 layouts, where each uses active balancing
% 2.a) AC layout
[XacAB, PacAB, ~] = get_ac_sys_dist(energyModule, nBlockSer, nModSer_AC, nModPar_AC, Rab, Rinv);

% 2.b) DC layout, modules in 1S
[XdcAB1, PdcAB1, ~] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC1, nModPar_DC1, Rab, Rconv, Rinv);

% 2.c) DC layout, modules in 2S
[XdcAB2, PdcAB2, ~] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC2, nModPar_DC2, Rab, Rconv, Rinv);

% 2.d) DC layout, modules in 3S
[XdcAB3, PdcAB3, ~] = get_dc_sys_dist(energyModule, nBlockSer, nModSer_DC3, nModPar_DC3, Rab, Rconv, Rinv);

expectedOutputAC_AB = sum(XacAB .* PacAB);
expectedOutputDC_AB1 = sum(XdcAB1 .* PdcAB1);
expectedOutputDC_AB2 = sum(XdcAB2 .* PdcAB2);
expectedOutputDC_AB3 = sum(XdcAB3 .* PdcAB3);

f1 = figure;
f1.Position = [1441 206 900 550];
subplot(2,2,1)
bar(XacAB/1000, PacAB);
title('AC layout')
xline(expectedOutputAC_AB/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputAC_AB/1000),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcAB1/1000, PdcAB1);
title('DC layout, modules in 1S')
xline(expectedOutputDC_AB1/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB1/1000),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcAB2/1000, PdcAB2);
title('DC layout, modules in 2S')
xline(expectedOutputDC_AB2/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB2/1000),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcAB3/1000, PdcAB3);
title('DC layout, modules in 3S')
xline(expectedOutputDC_AB3/1000, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB3/1000),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with active balancing, half bridges')
saveas(f1, 'ABhistos_HB.png')

w = 400000;
acceptabilityAB = [compute_acceptability(XacAB, PacAB, w); ...
    compute_acceptability(XdcAB1, PdcAB1, w); ...
    compute_acceptability(XdcAB2, PdcAB2, w); ...  
    compute_acceptability(XdcAB3, PdcAB3, w)];

expectedOutputAB = [expectedOutputAC_AB; expectedOutputDC_AB1; expectedOutputDC_AB2; expectedOutputDC_AB3];
expectedOutputAB_pct = round(expectedOutputAB ./ energyPack .* 100, 1);

title2 = "Table 2. Layout comparisons for active balancing circuits with full bridges";
%title3 = "Table 3. Layout comparisons for active balancing circuits with half-bridges";
Tab = table(expectedOutputAB./1000, expectedOutputAB_pct, acceptabilityAB);
Tab.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", energyPack(1)/1000); ...
    sprintf("DC layout, 1S, %0.1f kWh", energyPack(2)/1000); ...
    sprintf("DC layout, 2S, %0.1f kWh", energyPack(3)/1000); ...
    sprintf("DC layout, 3S, %0.1f kWh", energyPack(4)/1000)];
Tab.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w/1000)];
%disp(title3)
disp(title2)
disp(Tab)

