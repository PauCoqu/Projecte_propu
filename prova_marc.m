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



%% ================================================================
%  SCENARIO 2: mdot_core AND eta_HPC follow the HPC operating line
%  (Fig. 1 — blue line, red dot = design point)
% ================================================================

% ----------------------------------------------------------------
% Operating-line data, read from Figure 1
% ----------------------------------------------------------------
opline_pi_HPC    = [2.0,  3.0,  4.0,  5.0,  6.0,  6.6];   
opline_mdot_corr = [6.0,  9.0,  12.5, 15.5, 18.5, 20.0];  % [kg/s]
opline_eta_HPC   = [0.71, 0.79, 0.83, 0.85, 0.85, 0.848];  

% Sweep vectors (same pi_LPC range as S1; pi_HPC limited to the map)
pi_LPC_vec2 = linspace(2.0, 4.0, 9);
pi_HPC_vec2 = linspace(min(opline_pi_HPC), max(opline_pi_HPC), 11);

n_cases2 = length(pi_LPC_vec2) * length(pi_HPC_vec2);

% Pre-allocate (same columns as Scenario 1, plus mdot_core & eta_HPC)
Case2         = zeros(n_cases2,1);
pi_LPC_col2   = zeros(n_cases2,1);
pi_HPC_col2   = zeros(n_cases2,1);
OPR_col2      = zeros(n_cases2,1);
mdot_core_col2= zeros(n_cases2,1);
eta_HPC_col2  = zeros(n_cases2,1);
Thrust_col2   = zeros(n_cases2,1);
TSFC_col2     = zeros(n_cases2,1);
Isp_col2      = zeros(n_cases2,1);
etaP_col2     = zeros(n_cases2,1);
etaT_col2     = zeros(n_cases2,1);
etaO_col2     = zeros(n_cases2,1);
f_col2        = zeros(n_cases2,1);
M19_col2      = zeros(n_cases2,1);
M9_col2       = zeros(n_cases2,1);
ChokedSec_col2  = zeros(n_cases2,1);
ChokedPrim_col2 = zeros(n_cases2,1);

% ----------------------------------------------------------------
% Flight-condition stagnation properties (fixed across all cases)
% ----------------------------------------------------------------
gamma = inp.gamma_a;
M0    = inp.M0;
T0    = inp.T0;
p0    = inp.p0;
Tref  = inp.Tref;
pref  = inp.pref;

Tt0 = T0 * (1 + (gamma-1)/2 * M0^2);
pt0 = p0 * (Tt0/T0)^(gamma/(gamma-1));

case_id2 = 0;

for i = 1:length(pi_LPC_vec2)
    for j = 1:length(pi_HPC_vec2)

        case_id2 = case_id2 + 1;

        pi_LPC_i = pi_LPC_vec2(i);
        pi_HPC_j = pi_HPC_vec2(j);

        % ---- Step 1: operating-line interpolation ---------------
        mdot_corr_j = interp1(opline_pi_HPC, opline_mdot_corr, pi_HPC_j, 'linear');
        eta_HPC_j   = interp1(opline_pi_HPC, opline_eta_HPC,   pi_HPC_j, 'linear');

        % ---- Step 2: HPC-inlet total conditions -----------------
        % Intake (adiabatic, pressure loss pi_d)
        pt_d = pt0 * inp.pi_d;
        Tt_d = Tt0;

        % Fan (core stream)
        tau_fan = inp.pi_fan^((gamma-1)/gamma);
        Tt_fan  = Tt_d * (1 + (tau_fan - 1) / inp.eta_fan);
        pt_fan  = pt_d * inp.pi_fan;

        % LPC (booster) — varies with pi_LPC_i
        tau_LPC = pi_LPC_i^((gamma-1)/gamma);
        Tt_HPC_in = Tt_fan * (1 + (tau_LPC - 1) / inp.eta_LPC);
        pt_HPC_in = pt_fan * pi_LPC_i;

        % ---- Step 3: corrected → actual mass flow ---------------
        % mdot_corr = mdot_core * sqrt(Tt_HPC_in/Tref) / (pt_HPC_in/pref)
        mdot_core_j = mdot_corr_j * (pt_HPC_in/pref) / sqrt(Tt_HPC_in/Tref);
        mdot_sec_j  = inp.alpha * mdot_core_j;   % constant bypass ratio
        mdot0_j     = mdot_core_j + mdot_sec_j;

        % ---- Step 4: build input and run cycle ------------------
        inp_i           = inp;
        inp_i.pi_LPC    = pi_LPC_i;
        inp_i.pi_HPC    = pi_HPC_j;
        inp_i.eta_HPC   = eta_HPC_j;
        inp_i.mdot_core = mdot_core_j;
        inp_i.mdot_sec  = mdot_sec_j;
        inp_i.mdot0     = mdot0_j;

        out_i = turbofan_cycle(inp_i);

        % ---- Store results --------------------------------------
        Case2(case_id2)           = case_id2;
        pi_LPC_col2(case_id2)     = pi_LPC_i;
        pi_HPC_col2(case_id2)     = pi_HPC_j;
        OPR_col2(case_id2)        = out_i.OPR;
        mdot_core_col2(case_id2)  = mdot_core_j;
        eta_HPC_col2(case_id2)    = eta_HPC_j;
        Thrust_col2(case_id2)     = out_i.Thrust_kN;
        TSFC_col2(case_id2)       = out_i.TSFC_mg;
        Isp_col2(case_id2)        = out_i.Isp;
        etaP_col2(case_id2)       = out_i.eta_P*100;
        etaT_col2(case_id2)       = out_i.eta_T*100;
        etaO_col2(case_id2)       = out_i.eta_O*100;
        f_col2(case_id2)          = out_i.f;
        M19_col2(case_id2)        = out_i.M_19;
        M9_col2(case_id2)         = out_i.M_9;
        ChokedSec_col2(case_id2)  = out_i.choked_sec;
        ChokedPrim_col2(case_id2) = out_i.choked_prim;

    end
end

scenario2_table = table( ...
    Case2, pi_LPC_col2, pi_HPC_col2, OPR_col2, ...
    mdot_core_col2, eta_HPC_col2, ...
    Thrust_col2, TSFC_col2, Isp_col2, ...
    etaP_col2, etaT_col2, etaO_col2, ...
    f_col2, M19_col2, M9_col2, ChokedSec_col2, ChokedPrim_col2, ...
    'VariableNames', { ...
    'Case','pi_LPC','pi_HPC','OPR', ...
    'mdot_core_kg_s','eta_HPC', ...
    'Thrust_kN','TSFC_mg_s_N','Isp_s', ...
    'eta_P_percent','eta_T_percent','eta_O_percent', ...
    'f','M19','M9','Choked_secondary','Choked_primary'});

disp(' ');
disp('================ SCENARIO 2 RESULTS ================');
disp(scenario2_table);

%% ================================================================
%  BEST CASES — SCENARIO 2
% ================================================================
[~, idx2_T]    = max(scenario2_table.Thrust_kN);
[~, idx2_TSFC] = min(scenario2_table.TSFC_mg_s_N);

disp(' ');
disp('================ BEST CASE S2 — MAX THRUST ================');
disp(scenario2_table(idx2_T, :));

disp(' ');
disp('================ BEST CASE S2 — MIN TSFC ================');
disp(scenario2_table(idx2_TSFC, :));

%% ================================================================
%  HEATMAPS — SCENARIO 1
% ================================================================

n_LPC1 = length(pi_LPC_vec);
n_HPC1 = length(pi_HPC_vec);

% {data column, subplot title, colormap}
plots1 = { ...
    Thrust_col, 'Thrust (kN)',    'hot';    ...
    TSFC_col,   'TSFC (mg/s/N)', 'cool';   ...
    etaP_col,   '\eta_P (%)',    'parula'; ...
    etaT_col,   '\eta_T (%)',    'parula'; ...
    etaO_col,   '\eta_O (%)',    'parula'; ...
    f_col,      'f  (fuel/air)', 'jet'   };

fig1 = figure('Name','Scenario 1 — Heatmaps', ...
              'NumberTitle','off','Position',[50 50 1400 800]);

for k = 1:6
    col_vec = plots1{k,1};
    lbl     = plots1{k,2};
    cm      = plots1{k,3};

    % Outer loop = pi_LPC (i), inner = pi_HPC (j)
    % reshape gives (n_HPC x n_LPC), transpose to (n_LPC x n_HPC)
    Z = reshape(col_vec, n_HPC1, n_LPC1)';

    ax = subplot(2,3,k);
    imagesc(pi_HPC_vec, pi_LPC_vec, Z);
    set(ax,'YDir','normal');          % y-axis increases upward
    colormap(ax, cm);
    cb = colorbar(ax);
    cb.Label.String = lbl;

    hold(ax,'on');
    % White star = design point
    plot(ax, inp.pi_HPC, inp.pi_LPC, 'wp', ...
         'MarkerSize',14, 'MarkerFaceColor','w', 'LineWidth',1.5);
    hold(ax,'off');

    xlabel(ax,'\pi_{HPC}');
    ylabel(ax,'\pi_{LPC}');
    title(ax, lbl);
end

sgtitle(fig1, 'Scenario 1 — \dot{m}_{core} & \eta_{HPC} constant', ...
        'FontSize',14,'FontWeight','bold');


%% ================================================================
%  HEATMAPS — SCENARIO 2
% ================================================================

n_LPC2 = length(pi_LPC_vec2);
n_HPC2 = length(pi_HPC_vec2);

plots2 = { ...
    Thrust_col2, 'Thrust (kN)',    'hot';    ...
    TSFC_col2,   'TSFC (mg/s/N)', 'cool';   ...
    etaP_col2,   '\eta_P (%)',    'parula'; ...
    etaT_col2,   '\eta_T (%)',    'parula'; ...
    etaO_col2,   '\eta_O (%)',    'parula'; ...
    f_col2,      'f  (fuel/air)', 'jet'   };

fig2 = figure('Name','Scenario 2 — Heatmaps', ...
              'NumberTitle','off','Position',[100 100 1400 800]);

for k = 1:6
    col_vec = plots2{k,1};
    lbl     = plots2{k,2};
    cm      = plots2{k,3};

    Z = reshape(col_vec, n_HPC2, n_LPC2)';

    ax = subplot(2,3,k);
    imagesc(pi_HPC_vec2, pi_LPC_vec2, Z);
    set(ax,'YDir','normal');
    colormap(ax, cm);
    cb = colorbar(ax);
    cb.Label.String = lbl;

    hold(ax,'on');
    plot(ax, inp.pi_HPC, inp.pi_LPC, 'wp', ...
         'MarkerSize',14, 'MarkerFaceColor','w', 'LineWidth',1.5);
    hold(ax,'off');

    xlabel(ax,'\pi_{HPC}');
    ylabel(ax,'\pi_{LPC}');
    title(ax, lbl);
end

sgtitle(fig2, 'Scenario 2 — \dot{m}_{core} & \eta_{HPC} from operating line', ...
        'FontSize',14,'FontWeight','bold');