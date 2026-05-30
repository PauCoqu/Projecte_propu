clear; clc;

%% ================================================================
%  BASELINE INPUT DATA
% ================================================================

inp.M0 = 0.79;
inp.T0 = 216.65;
inp.p0 = 0.19e5;

inp.Tref = 300;
inp.pref = 1e5;

inp.mdot_core = 28.14;
inp.mdot_sec  = 309.50;
inp.mdot0     = 337.64;

inp.alpha = 11;

inp.pi_d   = 0.96;
inp.pi_fan = 1.5;
inp.pi_LPC = 3.03;
inp.pi_HPC = 6.6;
inp.pi_b   = 0.95;

inp.OPR = inp.pi_fan*inp.pi_LPC*inp.pi_HPC;

inp.eta_fan = 0.85;
inp.eta_LPC = 0.85;
inp.eta_HPC = 0.85;

inp.eta_HPT = 0.83;
inp.eta_LPT = 0.85;

inp.eta_m = 0.995;

inp.eta_n_p = 0.90;
inp.eta_n_s = 0.91;

inp.eta_b = 1.0;

inp.gamma_a = 1.4;
inp.cp_a = 1004.5;
inp.R_a = 287;

inp.gamma_f = 1.3;
inp.cp_f = 1239;
inp.R_f = inp.cp_f*(inp.gamma_f - 1)/inp.gamma_f;

inp.Tt4 = 1800;
inp.h_PR = 42.5e6;

out_base = turbofan_cycle(inp); % Aquesta funct corre el codi sencer. Bàsicament el que estem fent és fer una funció amb el codi que 
% resolia totes les thermodynamic variables, performance analysis etc per a
% poder iterar per a poder resoldre els scenarios que proposa l'enunciat.

disp(out_base.results);
disp(out_base.performance_table);


%% ================================================================
%  SCENARIO 1: mdot_core and eta_HPC constant, pi_LPC and pi_HPC variable
% ================================================================

pi_LPC_vec = linspace(2.0, 4.0, 9);
pi_HPC_vec = linspace(4.0, 9.0, 11);

n_cases = length(pi_LPC_vec)*length(pi_HPC_vec);

Case = zeros(n_cases,1);
pi_LPC_col = zeros(n_cases,1);
pi_HPC_col = zeros(n_cases,1);
OPR_col = zeros(n_cases,1);
Thrust_col = zeros(n_cases,1);
TSFC_col = zeros(n_cases,1);
Isp_col = zeros(n_cases,1);
etaP_col = zeros(n_cases,1);
etaT_col = zeros(n_cases,1);
etaO_col = zeros(n_cases,1);
f_col = zeros(n_cases,1);
M19_col = zeros(n_cases,1);
M9_col = zeros(n_cases,1);
ChokedSec_col = zeros(n_cases,1);
ChokedPrim_col = zeros(n_cases,1);

case_id = 0;

for i = 1:length(pi_LPC_vec)

    for j = 1:length(pi_HPC_vec)

        case_id = case_id + 1;

        inp_i = inp;

        inp_i.pi_LPC = pi_LPC_vec(i);
        inp_i.pi_HPC = pi_HPC_vec(j);

        out_i = turbofan_cycle(inp_i);

        Case(case_id) = case_id;
        pi_LPC_col(case_id) = inp_i.pi_LPC;
        pi_HPC_col(case_id) = inp_i.pi_HPC;
        OPR_col(case_id) = out_i.OPR;

        Thrust_col(case_id) = out_i.Thrust_kN;
        TSFC_col(case_id) = out_i.TSFC_mg;
        Isp_col(case_id) = out_i.Isp;

        etaP_col(case_id) = out_i.eta_P*100;
        etaT_col(case_id) = out_i.eta_T*100;
        etaO_col(case_id) = out_i.eta_O*100;

        f_col(case_id) = out_i.f;
        M19_col(case_id) = out_i.M_19;
        M9_col(case_id) = out_i.M_9;

        ChokedSec_col(case_id) = out_i.choked_sec;
        ChokedPrim_col(case_id) = out_i.choked_prim;

    end

end

scenario1_table = table( ...
    Case, ...
    pi_LPC_col, ...
    pi_HPC_col, ...
    OPR_col, ...
    Thrust_col, ...
    TSFC_col, ...
    Isp_col, ...
    etaP_col, ...
    etaT_col, ...
    etaO_col, ...
    f_col, ...
    M19_col, ...
    M9_col, ...
    ChokedSec_col, ...
    ChokedPrim_col, ...
    'VariableNames', { ...
    'Case', ...
    'pi_LPC', ...
    'pi_HPC', ...
    'OPR', ...
    'Thrust_kN', ...
    'TSFC_mg_s_N', ...
    'Isp_s', ...
    'eta_P_percent', ...
    'eta_T_percent', ...
    'eta_O_percent', ...
    'f', ...
    'M19', ...
    'M9', ...
    'Choked_secondary', ...
    'Choked_primary'});

disp(' ');
disp('================ SCENARIO 1 RESULTS ================');
disp(scenario1_table);



%% ================================================================
%  BEST CASES
% ================================================================

[~, idx_max_thrust] = max(scenario1_table.Thrust_kN);
best_thrust_case = scenario1_table(idx_max_thrust, :);

[~, idx_min_TSFC] = min(scenario1_table.TSFC_mg_s_N);
best_TSFC_case = scenario1_table(idx_min_TSFC, :);

disp(' ');
disp('================ BEST CASE BY MAXIMUM THRUST ================');
disp(best_thrust_case);

disp(' ');
disp('================ BEST CASE BY MINIMUM TSFC ================');
disp(best_TSFC_case);
