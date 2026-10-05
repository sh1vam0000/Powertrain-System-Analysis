%% Powertrain System Analysis - eBAJA
% Motor -> Chain/Sprocket -> Gearbox -> Output Shaft -> Tyre
clear; clc; close all;

%% ---- Motor Data ----
P_motor_rated  = 5;        % kW, rated power
T_motor_peak   = 90;      % Nm, peak torque
T_motor_rated  = 15.5;    % Nm, rated torque
N_motor_max    = 4300;    % RPM, max speed
N_motor_rated  = 4200;    % RPM, rated speed
I_max          = 180;     % A, max current
I_cont         = 80;      % A, rated/continuous current
Kt             = T_motor_rated / I_cont;   % Nm/A, torque constant (derived from rated point)
eta_motor      = 0.97;    % motor efficiency

%% ---- Transmission Data ----
Z_motor   = 15;           % motor-side sprocket teeth
Z_GB      = 14;           % gearbox-side sprocket teeth
R_chain   = Z_GB / Z_motor;   % chain reduction ratio
R_GB      = 9;                % gearbox reduction ratio
R_total   = R_chain * R_GB;   % total reduction ratio

eta_combined = 0.775;     % assumed overall mech. efficiency (chain+GB+shaft), midpoint of 75-80%

%% ---- Tyre / Vehicle Data ----
R_tyre = 0.3048;   % m, tyre rolling radius (24 in dia / 2)
M      = 320;      % kg, vehicle mass with driver
W_d    = 0.55 * M * 9.81;   % N, driven-wheel normal load (55% rear bias assumption)
mu     = 0.7;       % tyre-road friction coefficient (assumed, terrain not specified)

%% ---- Display parameters for sanity check ----
fprintf('R_chain = %.4f\n', R_chain);
fprintf('R_total = %.4f\n', R_total);
fprintf('Kt = %.4f Nm/A\n', Kt);
fprintf('W_d = %.2f N\n', W_d);

%% ---- Graph 1: Motor Torque vs Motor Current (two-segment model) ----
% Segment 1: 0 to I_cont -> linear using Kt (matches rated point exactly)
% Segment 2: I_cont to I_max -> linear interpolation up to peak torque
% Reason: real PMSM motors are linear near rated point, then the
% torque-current curve bends approaching peak torque (field weakening /
% saturation). This two-segment model respects both datasheet points
% without needing a full non-linear curve fit. Declared as an assumption.

I_seg1 = 0:1:I_cont;                    % 0 to 80 A
T_seg1 = Kt * I_seg1;                   % linear, using Kt

I_seg2 = I_cont:1:I_max;                % 80 to 180 A
T_seg2 = interp1([I_cont, I_max], [T_motor_rated, T_motor_peak], I_seg2);
                                         % straight line from (80,15.5) to (180,90)

I_sweep = [I_seg1, I_seg2(2:end)];      % combine, avoid duplicating 80A point
T_motor_sweep = [T_seg1, T_seg2(2:end)];

figure;
plot(I_sweep, T_motor_sweep, 'b-', 'LineWidth', 2);
xlabel('Motor Current (A)');
ylabel('Motor Torque (Nm)');
title('Graph 1: Motor Torque vs Motor Current (two-segment model)');
grid on;






%% ---- Graph 2: Tyre Torque vs Motor Current ----
T_tyre_sweep = T_motor_sweep * R_chain * R_GB * eta_combined;
% Note: R_chain here is 0.933 (slight overdrive), R_GB is 9 (main reduction),
% eta_combined (0.775) lumps chain+gearbox+shaft losses together per our assumption

figure;
plot(I_sweep, T_tyre_sweep, 'r-', 'LineWidth', 2);
xlabel('Motor Current (A)');
ylabel('Tyre Torque (Nm)');
title('Graph 2: Tyre Torque vs Motor Current');
grid on;




%% ---- Graph 3: Motor Speed vs Tyre Speed ----
N_motor_sweep = 0:10:N_motor_max;         % motor RPM sweep, 0 to 4300 in steps of 10
N_tyre_sweep = N_motor_sweep / R_total;   % tyre RPM (shaft = 1:1, so tyre = gearbox output)

figure;
plot(N_motor_sweep, N_tyre_sweep, 'g-', 'LineWidth', 2);
xlabel('Motor Speed (RPM)');
ylabel('Tyre Speed (RPM)');
title('Graph 3: Motor Speed vs Tyre Speed');
grid on;




%% ---- Graph 4: Motor Speed vs Vehicle Speed ----
V_sweep = (N_tyre_sweep * 2 * pi * R_tyre / 60) * 3.6;   % km/h

figure;
plot(N_motor_sweep, V_sweep, 'm-', 'LineWidth', 2);
xlabel('Motor Speed (RPM)');
ylabel('Vehicle Speed (km/h)');
title('Graph 4: Motor Speed vs Vehicle Speed');
grid on;



%% ---- Graph 5: Tyre Torque vs Vehicle Speed ----
% Assume motor delivers rated torque up to rated speed, then torque drops
% to maintain constant power (P_rated) beyond rated speed - typical PMSM behavior
%% ---- Corrected motor torque-vs-speed model (power-consistent) ----
N_break = (P_motor_rated*1000*60) / (2*pi*T_motor_rated);  % RPM where P first hits rated power

T_motor_vs_speed = zeros(size(N_motor_sweep));
for k = 1:length(N_motor_sweep)
    if N_motor_sweep(k) <= N_break
        T_motor_vs_speed(k) = T_motor_rated;
    else
        omega = N_motor_sweep(k) * 2*pi/60;
        T_motor_vs_speed(k) = (P_motor_rated*1000) / omega;
    end
end

T_tyre_vs_speed = T_motor_vs_speed * R_chain * R_GB * eta_combined;

figure;
plot(V_sweep, T_tyre_vs_speed, 'c-', 'LineWidth', 2);
xlabel('Vehicle Speed (km/h)');
ylabel('Tyre Torque (Nm)');
title('Graph 5: Tyre Torque vs Vehicle Speed');
grid on;







%% ---- Graph 6: Motor Power vs Motor Speed ----
omega_sweep = N_motor_sweep * 2*pi/60;              % rad/s
P_motor_sweep = (T_motor_vs_speed .* omega_sweep) / 1000;   % kW

figure;
plot(N_motor_sweep, P_motor_sweep, 'y-', 'LineWidth', 2);
xlabel('Motor Speed (RPM)');
ylabel('Motor Power (kW)');
title('Graph 6: Motor Power vs Motor Speed');
grid on;
yline(P_motor_rated, 'r--', 'Rated Power Limit');
%% ---- Corrected motor torque-vs-speed model (power-consistent) ----
N_break = (P_motor_rated*1000*60) / (2*pi*T_motor_rated);  % RPM where P first hits rated power
% Note: N_break (~3080 RPM) differs from datasheet's stated N_motor_rated (4200 RPM)
% because T_rated x N_rated in the datasheet doesn't exactly equal P_rated.
% We use N_break to keep torque/speed/power mutually consistent (Section 4.9 requirement).




%% ---- Graph 7: Tractive Force vs Vehicle Speed ----
F_tractive_sweep = T_tyre_vs_speed / R_tyre;   % N

figure;
plot(V_sweep, F_tractive_sweep, 'Color', [1 0.5 0], 'LineWidth', 2);   % orange line
xlabel('Vehicle Speed (km/h)');
ylabel('Tractive Force (N)');
title('Graph 7: Tractive Force vs Vehicle Speed');
grid on;






%% ---- Graph 8: Motor Current vs Vehicle Speed ----
I_vs_speed = T_motor_vs_speed / Kt;   % Motor current (A)

figure;
plot(V_sweep, I_vs_speed, 'b-', 'LineWidth', 2);
xlabel('Vehicle Speed (km/h)');
ylabel('Motor Current (A)');
title('Graph 8: Motor Current vs Vehicle Speed');
grid on;