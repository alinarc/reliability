% ----------------------------------------------------------------------
% This script computes the available capacity probability mass functions
% (PMFs) for 5 pre-determined ESS layouts:
%   1. Conventional pack, AC-coupled, isolation via LF xfmr
%   2. Conventional pack, AC-coupled, isolation via HF xfmr in DC-DC
%   3. Conventional pack, DC-coupled
%   4. Modular pack, AC-coupled
%   5. Modular pack, DC-coupled
% The probability distributions for each [X, P] represent the possible
% available capacity states X (in kWh) and the probabilities P of the system to
% be in those states.
%
% All of this is based on component failure rates (failures/10^6 hrs), which are computed in
% 'failure_rates_computed.xlsx' based on the guidelines in the 217Plus
% handbook.

% All five system layouts are considered with passive balancing (PB) and active
% balancing, both with converters based on half bridges (HB) and full
% bridges (FB).
% ----------------------------------------------------------------------

close all
clear

%% Script setup
% System specs: desired module, pack, capacity and voltage. Considering
% that module Ah are limited to AhBal and cell voltage is vCell, develop
% battery pack layouts using get_conventional_layout and get_modular_layout
% for the two battery pack types.
% Note: the module is The same for both battery pack types.

kWhModule_desired = 3.5;
vModule_desired = 50;
kWhPack_desired = 500;
vPack_desired_AC = 1000;
vCell = [2.5 3.65];
AhBal = 100;

[nBlockSer, kWhModule, nModSer_conv, nModPar_conv, kWhPack_conv] = get_conventional_layout(vCell, ...
    AhBal, kWhModule_desired, kWhPack_desired, vModule_desired, vPack_desired_AC);

nModSer_mod1 = 1; % A variable that can be explored for the modular battery is the number of modules in series with each converter
[nModPar_mod1, kWhPack_mod1] = get_modular_layout(kWhModule, nModSer_mod1, kWhPack_desired);

% Read component failure rates from Excel file, save as struct
L = readcell('failure_rates_computed.xlsx', 'Sheet', 'Value summary');
L = cell2struct(L(:,2), L(:,1), 1);

scale = 1e6;
opHrs = 5*8000; % Based on 1C discharge, C/4 charge, 8000 cycles in lifetime
D = 0.5; % overall system duty cycle
calHrs = opHrs/D; 

% Compute failure rate of DC-DC converter, both for balancing and for power
% conversion
nCapDC = 2; % number of capacitors in DC-DC converter
nDiodeDC = 8;
nMosfetDC = 8;
nInductorDC = 1;
nXfmrDC = 1;

lambdaDC = nCapDC*L.lambdaC + nDiodeDC*L.lambdaDiode_Schottky + nMosfetDC*L.lambdaMosfet + ...
    nInductorDC*L.lambdaL + nXfmrDC*L.lambdaXfmr_RF;
lambdaDC_bal = nCapDC*L.lambdaC_bal + nDiodeDC*L.lambdaDiode_bal + nMosfetDC*L.lambdaMosfet_bal + ...
    nInductorDC*L.lambdaL_bal + nXfmrDC*L.lambdaXfmr_RF_bal;
lambdaDC_half_bridge = nCapDC*L.lambdaC_bal + nDiodeDC/2*L.lambdaDiode_bal + nMosfetDC/2*L.lambdaMosfet_bal + ...
    nInductorDC*L.lambdaL_bal + nXfmrDC*L.lambdaXfmr_RF_bal;

Rcon = exp(-lambdaDC/scale*calHrs); % reliability estimate for DC-DC onverter at time 'lifetime'
Rab_hb = exp(-lambdaDC_half_bridge/scale*calHrs);
Rab_fb = exp(-lambdaDC_bal/scale*calHrs);

% Compute failure rate of inverter
nCapAC = 5; % number of capacitors in DC-AC inverter
nDiodeAC = 6;
nIgbtAC = 6;
nInductorAC = 6;
nResistorAC = 6;

lambdaAC = nCapAC*L.lambdaC + nDiodeAC*L.lambdaDiode_Schottky + nIgbtAC*L.lambdaIgbt + ...
    nInductorAC*L.lambdaL + nResistorAC*L.lambdaR;
Rinv = exp(-lambdaAC/scale*calHrs); % reliability estimate for DC-AC onverter at time 'lifetime'
Rxfmr = exp(-L.lambdaXfmr_power_3p/scale*calHrs);

% Compute failure rate of passive balancing circuit
nCapPB = 1; % number of capacitors in passive balancing system
nDiodePB = 1;
nMosfetPB = 1;
nResistorPB = 3;

lambdaPB = nCapPB*L.lambdaC_bal + nDiodePB*L.lambdaDiode_bal + nMosfetPB*L.lambdaMosfet_bal + ...
    nResistorPB*L.lambdaR;

Rpb = exp(-lambdaPB/scale*calHrs);

% %% Evaluate all 5 systems with passive balancing circuits, generate plot comparing the PMFs
% 
% [X1_PB, P1_PB] = get_ess1_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rpb, Rinv, Rxfmr);
% 
% [X2_PB, P2_PB] = get_ess2_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rpb, Rinv, Rcon);
% 
% [X3_PB, P3_PB] = get_ess3_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rpb, Rcon);
% 
% [X4_PB, P4_PB] = get_ess4_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rpb, Rcon, Rinv);
% 
% [X5_PB, P5_PB] = get_ess5_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rpb, Rcon);
% 
% X_PB = {X1_PB; X2_PB; X3_PB; X4_PB; X5_PB};
% P_PB = {P1_PB; P2_PB; P3_PB; P4_PB; P5_PB};
% 
% [mus_PB, sigmas_PB] = get_dist_params(X_PB, P_PB);
% 
% f1 = make_5_bar_chart(X_PB, P_PB, mus_PB, 1);
% 
% %% Explore same 5 layouts with active balancing, half bridge circuits
% [X1_HB, P1_HB] = get_ess1_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_hb, Rinv, Rxfmr);
% 
% [X2_HB, P2_HB] = get_ess2_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_hb, Rinv, Rcon);
% 
% [X3_HB, P3_HB] = get_ess3_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_hb, Rcon);
% 
% [X4_HB, P4_HB] = get_ess4_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rab_hb, Rcon, Rinv);
% 
% [X5_HB, P5_HB] = get_ess5_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rab_hb, Rcon);
% 
% X_HB = {X1_HB; X2_HB; X3_HB; X4_HB; X5_HB};
% P_HB = {P1_HB; P2_HB; P3_HB; P4_HB; P5_HB};
% 
% [mus_HB, sigmas_HB] = get_dist_params(X_HB, P_HB);
% 
% f2 = make_5_bar_chart(X_HB, P_HB, mus_HB, 2);
% 
% %% Explore same 5 layouts with active balancing, full bridge circuits
% [X1_FB, P1_FB] = get_ess1_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_fb, Rinv, Rxfmr);
% 
% [X2_FB, P2_FB] = get_ess2_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_fb, Rinv, Rcon);
% 
% [X3_FB, P3_FB] = get_ess3_sys_dist(kWhModule, kWhPack_conv, nBlockSer, nModSer_conv, ...
%     nModPar_conv, Rab_fb, Rcon);
% 
% [X4_FB, P4_FB] = get_ess4_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rab_fb, Rcon, Rinv);
% 
% [X5_FB, P5_FB] = get_ess5_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, nModSer_mod1, ...
%     nModPar_mod1, Rab_fb, Rcon);
% 
% X_FB = {X1_FB; X2_FB; X3_FB; X4_FB; X5_FB};
% P_FB = {P1_FB; P2_FB; P3_FB; P4_FB; P5_FB};
% 
% [mus_FB, sigmas_FB] = get_dist_params(X_FB, P_FB);
% 
% f3 = make_5_bar_chart(X_FB, P_FB, mus_FB, 3);
% 
% %% Compare all cases (5 layouts, 3 balancing types) in a plot with mean and std dev of PMFs
% mus = [mus_PB, mus_HB, mus_FB];
% sigmas = [sigmas_PB, sigmas_HB, sigmas_FB]; 
% 
% f4 = make_summary_plot(mus, sigmas, 1);
% 
%% Explore impact of cell chemistry
vCell = [2.5 3.65; 1.5 2.9; 1.2 2.5];
X_cc = cell(5,3,3);
P_cc = cell(5,3,3);

mus_cc = zeros(5,3,3);
sigmas_cc = zeros(5,3,3);

bal = [Rpb; Rab_hb; Rab_fb];

for j = 1:3
    Rbal = bal(j);

for i = 1:3
    [nBlockSer, kWhModule, nModSer_conv, nModPar_conv, kWhPack_conv] = ...
        get_conventional_layout(vCell(i,:), AhBal, kWhModule_desired, ...
        kWhPack_desired, vModule_desired, vPack_desired_AC);
    [nModPar_mod1, kWhPack_mod1] = get_modular_layout(kWhModule, nModSer_mod1, kWhPack_desired);
    
    [X_cc{1,i,j}, P_cc{1,i,j}] = get_ess1_sys_dist(kWhModule, kWhPack_conv, nBlockSer, ...
        nModSer_conv, nModPar_conv, Rbal, Rinv, Rxfmr);
    [X_cc{2, i,j}, P_cc{2,i,j}] = get_ess2_sys_dist(kWhModule, kWhPack_conv, nBlockSer, ...
        nModSer_conv, nModPar_conv, Rbal, Rinv, Rcon);
    [X_cc{3, i,j}, P_cc{3,i,j}] = get_ess3_sys_dist(kWhModule, kWhPack_conv, nBlockSer, ...
        nModSer_conv, nModPar_conv, Rbal, Rcon);
    [X_cc{4, i,j}, P_cc{4,i,j}] = get_ess4_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, ...
        nModSer_mod1, nModPar_mod1, Rbal, Rcon, Rinv);
    [X_cc{5, i,j}, P_cc{5,i,j}] = get_ess5_sys_dist(kWhModule, kWhPack_mod1, nBlockSer, ...
        nModSer_mod1, nModPar_mod1, Rbal, Rcon);
    
    [mus_cc(:,i,j), sigmas_cc(:,i,j)] = get_dist_params(X_cc(:,i,j), P_cc(:,i,j));
end

 make_summary_plot(mus_cc(:,:,j), sigmas_cc(:,:,j), 2, j);
end