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
balanceTime = 0.2*opHrs;

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
Rab_hb = exp(-lambdaDC_half_bridge*balanceTime);
Rab_fb = exp(-lambdaDC*balanceTime);
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

%% 2. Consider same 4 layouts, where each uses active balancing with half bridges
% 2.a) AC layout
[XacAB_HB, PacAB_HB] = get_ac_sys_dist(kWhModule, kWhPack_AC, nBlockSer, nModSer_AC, nModPar_AC, Rab_hb, Rinv);

% 2.b) DC layout, modules in 1S
[XdcAB1_HB, PdcAB1_HB] = get_dc_sys_dist(kWhModule, kWhPack_DC1, nBlockSer, nModSer_DC1, nModPar_DC1, Rab_hb, Rconv, Rinv);

% 2.c) DC layout, modules in 2S
[XdcAB2_HB, PdcAB2_HB] = get_dc_sys_dist(kWhModule, kWhPack_DC2, nBlockSer, nModSer_DC2, nModPar_DC2, Rab_hb, Rconv, Rinv);

% 2.d) DC layout, modules in 3S
[XdcAB3_HB, PdcAB3_HB] = get_dc_sys_dist(kWhModule, kWhPack_DC3, nBlockSer, nModSer_DC3, nModPar_DC3, Rab_hb, Rconv, Rinv);

expectedOutputAC_AB_HB = sum(XacAB_HB .* PacAB_HB);
expectedOutputDC_AB1_HB = sum(XdcAB1_HB .* PdcAB1_HB);
expectedOutputDC_AB2_HB = sum(XdcAB2_HB .* PdcAB2_HB);
expectedOutputDC_AB3_HB = sum(XdcAB3_HB .* PdcAB3_HB);

f1 = figure;
f1.Position = [1441 206 900 550];
subplot(2,2,1)
bar(XacAB_HB, PacAB_HB);
title('AC layout')
xline(expectedOutputAC_AB_HB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputAC_AB_HB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcAB1_HB, PdcAB1_HB);
title('DC layout, modules in 1S')
xline(expectedOutputDC_AB1_HB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB1_HB),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcAB2_HB, PdcAB2_HB);
title('DC layout, modules in 2S')
xline(expectedOutputDC_AB2_HB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB2_HB),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcAB3_HB, PdcAB3_HB);
title('DC layout, modules in 3S')
xline(expectedOutputDC_AB3_HB, 'Color','#A2142F', 'Label',sprintf('μ = %0.2f kWh', expectedOutputDC_AB3_HB),'LineWidth', 1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with active balancing, half bridges')
saveas(f1, 'ABhistos_HB.png')

w = 400;
acceptabilityAB_HB = [compute_acceptability(XacAB_HB, PacAB_HB, w); ...
    compute_acceptability(XdcAB1_HB, PdcAB1_HB, w); ...
    compute_acceptability(XdcAB2_HB, PdcAB2_HB, w); ...  
    compute_acceptability(XdcAB3_HB, PdcAB3_HB, w)];

expectedOutputAB_HB = [expectedOutputAC_AB_HB; expectedOutputDC_AB1_HB; expectedOutputDC_AB2_HB; expectedOutputDC_AB3_HB];
expectedOutputAB_HB_pct = round(expectedOutputAB_HB ./ kWhPack .* 100, 1);

title2 = "Table 2. Layout comparisons for active balancing circuits with half bridges";
%title3 = "Table 3. Layout comparisons for active balancing circuits with half-bridges";
Tab = table(expectedOutputAB_HB, expectedOutputAB_HB_pct, acceptabilityAB_HB);
Tab.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", kWhPack(1)); ...
    sprintf("DC layout, 1S, %0.1f kWh", kWhPack(2)); ...
    sprintf("DC layout, 2S, %0.1f kWh", kWhPack(3)); ...
    sprintf("DC layout, 3S, %0.1f kWh", kWhPack(4))];
Tab.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w)];
%disp(title3)
disp(title2)
disp(Tab)

%% 3. Consider same 4 layouts, where each uses active balancing with full bridges
% 3.a) AC layout
[XacAB_FB, PacAB_FB] = get_ac_sys_dist(kWhModule, kWhPack_AC, nBlockSer, nModSer_AC, nModPar_AC, Rab_fb, Rinv);

% 3.b) DC layout, modules in 1S
[XdcAB1_FB, PdcAB1_FB] = get_dc_sys_dist(kWhModule, kWhPack_DC1, nBlockSer, nModSer_DC1, nModPar_DC1, Rab_fb, Rconv, Rinv);

% 3.c) DC layout, modules in 2S
[XdcAB2_FB, PdcAB2_FB] = get_dc_sys_dist(kWhModule, kWhPack_DC2, nBlockSer, nModSer_DC2, nModPar_DC2, Rab_fb, Rconv, Rinv);

% 3.d) DC layout, modules in 3S
[XdcAB3_FB, PdcAB3_FB] = get_dc_sys_dist(kWhModule, kWhPack_DC3, nBlockSer, nModSer_DC3, nModPar_DC3, Rab_fb, Rconv, Rinv);

expectedOutputAC_AB_FB = get_expected_output(XacAB_FB, PacAB_FB);
expectedOutputDC_AB1_FB = get_expected_output(XdcAB1_FB, PdcAB1_FB);
expectedOutputDC_AB2_FB = get_expected_output(XdcAB2_FB, PdcAB2_FB);
expectedOutputDC_AB3_FB = get_expected_output(XdcAB3_FB, PdcAB3_FB);

f2 = figure;
f2.Position = [1441 206 900 550];
subplot(2,2,1)
bar(XacAB_FB, PacAB_FB)
title('AC layout')
xline(expectedOutputAC_AB_FB, 'Color', '#A2142F', 'Label', sprintf('μ = %0.2f kWh', expectedOutputAC_AB_FB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,2)
bar(XdcAB1_FB, PdcAB1_FB)
title('DC layout, modules in 1S')
xline(expectedOutputDC_AB1_FB, 'Color', '#A2142F', 'Label', sprintf('μ = %0.2f kWh', expectedOutputDC_AB1_FB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,3)
bar(XdcAB2_FB, PdcAB2_FB)
title('DC layout, modules in 2S')
xline(expectedOutputDC_AB2_FB, 'Color', '#A2142F', 'Label', sprintf('μ = %0.2f kWh', expectedOutputDC_AB2_FB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')

subplot(2,2,4)
bar(XdcAB3_FB, PdcAB3_FB)
title('DC layout, modules in 3S')
xline(expectedOutputDC_AB3_FB, 'Color', '#A2142F', 'Label', sprintf('μ = %0.2f kWh', expectedOutputDC_AB3_FB),'LineWidth',1, 'LabelOrientation', 'horizontal','LabelHorizontalAlignment', 'center')
xlabel('System available capacity (kWh)')
sgtitle('Available capacity PMFs for layouts with active balancing, full bridges')
saveas(f2, 'ABhistos_FB.png')

acceptabilityAB_FB = [compute_acceptability(XacAB_FB, PacAB_FB, w); ...
    compute_acceptability(XdcAB1_FB, PdcAB1_FB, w); ...
    compute_acceptability(XdcAB2_FB, PdcAB2_FB, w); ...  
    compute_acceptability(XdcAB3_FB, PdcAB3_FB, w)];

expectedOutputAB_FB = [expectedOutputAC_AB_FB; expectedOutputDC_AB1_FB; expectedOutputDC_AB2_FB; expectedOutputDC_AB3_FB];
expectedOutputAB_FB_pct = round(expectedOutputAB_FB ./ kWhPack .* 100, 1);

title3 = "Table 3. Layout comparisons for active balancing circuits with full bridges";
Tab_fb = table(expectedOutputAB_FB, expectedOutputAB_FB_pct, acceptabilityAB_FB);
Tab_fb.Properties.RowNames = [sprintf("AC layout, %0.1f kWh", kWhPack(1)); ...
    sprintf("DC layout, 1S, %0.1f kWh", kWhPack(2)); ...
    sprintf("DC layout, 2S, %0.1f kWh", kWhPack(3)); ...
    sprintf("DC layout, 3S, %0.1f kWh", kWhPack(4))];
Tab_fb.Properties.VariableNames = ["Expected output (kWh, BOL)", "Expected output (% of max, BOL)", sprintf("Availability (%%), w = %0.0f kWh", w)];
disp(title3)
disp(Tab_fb)

% AC_dists = organize_dists(XacPB, PacPB, XacAB_HB, PacAB_HB, XacAB_FB, PacAB_FB);
% DC1_dists = organize_dists(XdcPB1, PdcPB1, XacAB1_HB, PacAB1_HB, XacAB1_FB, PacAB1_FB);
% DC2_dists = organize_dists(XdcPB2, PdcPB2, XacAB2_HB, PacAB2_HB, XacAB2_FB, PacAB2_FB);
% DC3_dists = organize_dists(XdcPB3, PdcPB3, XacAB3_HB, PacAB3_HB, XacAB3_FB, PacAB3_FB);

musAC = [expectedOutputAC_PB expectedOutputAC_AB_HB expectedOutputAC_AB_FB];
sigmasAC = [std(XacPB, PacPB) std(XacAB_HB, PacAB_HB) std(XacAB_FB, PacAB_FB)];

musDC1 = [expectedOutputDC_PB1 expectedOutputDC_AB1_HB expectedOutputDC_AB1_FB];
sigmasDC1 = [std(XdcPB1, PdcPB1) std(XdcAB1_HB, PdcAB1_HB) std(XdcAB1_FB, PdcAB1_FB)];

musDC2 = [expectedOutputDC_PB2 expectedOutputDC_AB2_HB expectedOutputDC_AB2_FB];
sigmasDC2 = [std(XdcPB2, PdcPB2) std(XdcAB2_HB, PdcAB2_HB) std(XdcAB2_FB, PdcAB2_FB)];

musDC3 = [expectedOutputDC_PB3 expectedOutputDC_AB3_HB expectedOutputDC_AB3_FB];
sigmasDC3 = [std(XdcPB3, PdcPB3) std(XdcAB3_HB, PdcAB3_HB) std(XdcAB3_FB, PdcAB3_FB)];


mus = [musAC; musDC1; musDC2; musDC3];
sigmas = [sigmasAC; sigmasDC1; sigmasDC2; sigmasDC3];

f3 = figure;
b = bar(mus);
hold on
[ngroups, nbars] = size(mus);
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

errorbar(x', mus, sigmas, 'k', 'linestyle', 'none')
set(gca, 'xticklabel', {'AC'; 'DC,1S'; 'DC,2S'; 'DC,3S'})
ylim([0 max(mus+sigmas,[],'all')+10]);
ylabel('Expected Output (kWh)')
legend('PB', 'AB-HB', 'AB-FB', 'Location', 'southoutside', 'orientation', 'horizontal')
saveas(f3, 'compare_all.png')
hold off

mus_pct = mus./kWhPack*100;

musAC_pct = mus_pct(1,:);
musDC1_pct = mus_pct(2,:);
musDC2_pct = mus_pct(3,:);
musDC3_pct = mus_pct(4,:);

accAC = [acceptabilityPB(1) acceptabilityAB_HB(1) acceptabilityAB_FB(1)];
accDC1 = [acceptabilityPB(2) acceptabilityAB_HB(2) acceptabilityAB_FB(2)];
accDC2 = [acceptabilityPB(3) acceptabilityAB_HB(3) acceptabilityAB_FB(3)];
accDC3 = [acceptabilityPB(4) acceptabilityAB_HB(4) acceptabilityAB_FB(4)];

f4 = figure;
markerSize = 10;
plot(accAC(1), musAC_pct(1), 'ro', 'MarkerSize', markerSize);
hold on
plot(accAC(2), musAC_pct(2), 'r+', 'MarkerSize', markerSize);
plot(accAC(3), musAC_pct(3), 'r*', 'MarkerSize', markerSize);

plot(accDC1(1), musDC1_pct(1), 'bo', 'MarkerSize', markerSize);
plot(accDC1(2), musDC1_pct(2), 'b+', 'MarkerSize', markerSize);
plot(accDC1(3), musDC1_pct(3), 'b*', 'MarkerSize', markerSize);

plot(accDC2(1), musDC2_pct(1), 'go', 'MarkerSize', markerSize);
plot(accDC2(2), musDC2_pct(2), 'g+', 'MarkerSize', markerSize);
plot(accDC2(3), musDC2_pct(3), 'g*', 'MarkerSize', markerSize);

plot(accDC3(1), musDC3_pct(1), 'co', 'MarkerSize', markerSize);
plot(accDC3(2), musDC3_pct(2), 'c+', 'MarkerSize', markerSize);
plot(accDC3(3), musDC3_pct(3), 'c*', 'MarkerSize', markerSize);

xlabel('Availability (%) w = 400 kWh')
ylabel('Expected output (% of initial capacity')
grid on

h = zeros(7, 1);
h(1) = plot(NaN,NaN,'ok');
h(2) = plot(NaN,NaN,'+k');
h(3) = plot(NaN,NaN,'*k');
h(4) = plot(NaN,NaN,'-r');
h(5) = plot(NaN,NaN,'-b');
h(6) = plot(NaN,NaN,'-g');
h(7) = plot(NaN,NaN,'-c');
legend(h, 'PB','AB-HB','AB-FB', 'AC', 'DC-1S', 'DC-2S', 'DC-3S', 'Location', 'southeast');
saveas(f4, 'compare-all2.png')