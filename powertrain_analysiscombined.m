%% Combined Powertrain Analysis Plots
% Motor -> Chain/Sprocket -> Gearbox -> Output Shaft -> Tyre

clear; clc; close all;

%% ---- Motor Data ----
P_motor_rated = 5;        % kW
T_motor_peak  = 90;       % Nm
T_motor_rated = 15.5;     % Nm
N_motor_max   = 4300;     % RPM
N_motor_rated = 4200;     % RPM
I_max         = 180;      % A
I_cont        = 80;       % A

Kt = T_motor_rated / I_cont;   % Nm/A

%% ---- Transmission Data ----
Z_motor = 15;             % motor sprocket teeth
Z_GB    = 14;             % gearbox sprocket teeth

R_chain = Z_GB / Z_motor;
R_GB    = 9;
R_total = R_chain * R_GB;

eta_combined = 0.775;     % overall mechanical efficiency

%% ---- Tyre / Vehicle Data ----
R_tyre = 0.3048;          % m
M      = 320;              % kg

%% ---- Motor Speed Sweep ----
N_motor = 0:10:N_motor_max;

%% ---- Tyre Speed ----
N_tyre = N_motor / R_total;

%% ---- Vehicle Speed ----
V = (N_tyre * 2*pi*R_tyre / 60) * 3.6;

%% ---- Motor Torque vs Speed ----
N_break = (P_motor_rated*1000*60) / ...
          (2*pi*T_motor_rated);

T_motor = zeros(size(N_motor));

for k = 1:length(N_motor)

    if N_motor(k) <= N_break
        T_motor(k) = T_motor_rated;

    else
        omega = N_motor(k) * 2*pi/60;
        T_motor(k) = (P_motor_rated*1000) / omega;

    end

end

%% ---- Tyre Torque ----
T_tyre = T_motor * R_total * eta_combined;

%% ---- Tractive Force ----
F_tractive = T_tyre / R_tyre;

%% ---- Motor Power ----
omega_motor = N_motor * 2*pi/60;

P_motor = (T_motor .* omega_motor) / 1000;   % kW

%% ---- Motor Current ----
I_motor = T_motor / Kt;

%% =========================================================
% COMBINED FIGURE 1
% Motor Speed -> Tyre Speed + Vehicle Speed
% =========================================================

figure;

yyaxis left
plot(N_motor, N_tyre, 'LineWidth', 2);
ylabel('Tyre Speed (RPM)');

yyaxis right
plot(N_motor, V, 'LineWidth', 2);
ylabel('Vehicle Speed (km/h)');

xlabel('Motor Speed (RPM)');
title('Combined Figure 1: Motor Speed, Tyre Speed and Vehicle Speed');
grid on;

legend('Tyre Speed', 'Vehicle Speed', 'Location', 'northwest');


%% =========================================================
% COMBINED FIGURE 2
% Vehicle Speed -> Tyre Torque + Tractive Force
% =========================================================

figure;

yyaxis left
plot(V, T_tyre, 'LineWidth', 2);
ylabel('Tyre Torque (Nm)');

yyaxis right
plot(V, F_tractive, 'LineWidth', 2);
ylabel('Tractive Force (N)');

xlabel('Vehicle Speed (km/h)');
title('Combined Figure 2: Tyre Torque and Tractive Force');
grid on;

legend('Tyre Torque', 'Tractive Force', 'Location', 'northeast');


%% =========================================================
% COMBINED FIGURE 3
% Vehicle Speed -> Motor Current + Motor Power
% =========================================================

figure;

yyaxis left
plot(V, I_motor, 'LineWidth', 2);
ylabel('Motor Current (A)');

yyaxis right
plot(V, P_motor, 'LineWidth', 2);
ylabel('Motor Power (kW)');

xlabel('Vehicle Speed (km/h)');
title('Combined Figure 3: Motor Current and Motor Power');
grid on;

legend('Motor Current', 'Motor Power', 'Location', 'northeast');


%% ---- Display Important Values ----

fprintf('\n===== POWERTRAIN SUMMARY =====\n');
fprintf('Chain Ratio       = %.4f\n', R_chain);
fprintf('Gearbox Ratio     = %.2f\n', R_GB);
fprintf('Total Ratio       = %.4f\n', R_total);
fprintf('Maximum Tyre RPM  = %.2f RPM\n', max(N_tyre));
fprintf('Maximum Speed     = %.2f km/h\n', max(V));
fprintf('Maximum Tyre Torque = %.2f Nm\n', max(T_tyre));
fprintf('Maximum Tractive Force = %.2f N\n', max(F_tractive));