clear; close all; clc;

addpath(genpath(fullfile('.', '/'))); % load all in the current folder
load('real_cluster.mat');

scale_factors = [0.1, 0.1, 10]; % [Rs, Rp, C]

time_window = 0.40; % interval of soc range to define training interval amplitude
moving_step = 0.20; % soc range 
number_restart = 10; % number of restarts (to avoid local minima)
seed = 10; % default for all the experiments

% value initialization
SoC_est = -1 .* ones(time, 1);
Vocv_est = -1 .* ones(time, 1);

% initialize figure
f = figure('Name', 'VDB-SE', 'units', 'normalized', ...
    'outerposition', [0.05 0.05 0.90 0.90]);
ax_soc = axes(f);
hold(ax_soc, 'on');
set(ax_soc, 'FontSize', 24);
xlim(ax_soc, [0 time]);
ylabel(ax_soc, 'SoC(t)');
xlabel(ax_soc, 't [sec]');
ylim(ax_soc, [0 1]);

% select training time interval
iter_init = 1;
iter_end = iter_init;
min_SoC = 0;
max_SoC = 0;
actual_SoC = 0;
while max_SoC - min_SoC < time_window && iter_end < time - 1 
    actual_SoC = actual_SoC - (1/battery_capacity) * I(iter_end) * dt;
    iter_end = iter_end + 1; 
    max_SoC = max(max_SoC, actual_SoC);
    min_SoC = min(min_SoC, actual_SoC);
end
windows_amplitude = iter_end - iter_init;

% find parameters and initial SoC
[Rs_est, Rp_est, C_est, initialSoC_est] = vdbse_nonlinear_opt( ...
    I(iter_init:iter_end), V(iter_init:iter_end), ...
    battery_capacity, dt, 'interior-point', number_restart, ...
    lookup, scale_factors, seed);

% propagate soc in training interval
Vocv_est(iter_init:iter_end,1) = estimate_Vocv( I(iter_init:iter_end), ...
    V(iter_init:iter_end), I(1), V(1), ...
    interp1(lookup.SoC,lookup.Vocv,initialSoC_est,'spline'), ...
    dt, Rs_est, Rp_est, C_est, scale_factors);

while iter_end < time - 1

    % estimate when to move the sliding window
    iter_init = iter_end + 1;
    iter_end = iter_init;
    min_SoC = 0;
    max_SoC = 0;
    actual_SoC = 0;
    while max_SoC - min_SoC < moving_step && iter_end < time - 1 
        actual_SoC = actual_SoC - (1/battery_capacity) * I(iter_end) * dt;
        iter_end = iter_end + 1; 
        max_SoC = max(max_SoC, actual_SoC);
        min_SoC = min(min_SoC, actual_SoC);
    end

    % propagate Vocv and SoC with older param values
    Vocv_est(iter_init:iter_end,1) = estimate_Vocv( I(iter_init:iter_end), ...
        V(iter_init:iter_end), I(iter_init-1), V(iter_init-1), Vocv_est(iter_init-1), ...
        dt, Rs_est, Rp_est, C_est, scale_factors);

    % estimate new parameters
    [Rs_est, Rp_est, C_est, initialSoC_est] = vdbse_nonlinear_opt( ...
        I(iter_end-windows_amplitude:iter_end), V(iter_end-windows_amplitude:iter_end), ...
        battery_capacity, dt, 'interior-point', number_restart, lookup, scale_factors, seed);

end

% estimate SoC from given Vocv
SoC_est(1:time,1) = interp1(lookup.Vocv,lookup.SoC,Vocv_est(1:time,1),'spline');

% plot real soc and estimated one
plot(ax_soc, 2:50:time-1, SoC(2:50:time-1), 'LineWidth', 1, 'LineStyle', '-');
plot(ax_soc, 2:50:time-1, SoC_est(2:50:time-1,1), 'LineWidth', 1, 'LineStyle', '-');
legend(ax_soc, 'Real SoC', 'VDB-SE SoC');
legend('Location','southeast')

% soc mean error
soc_mean_error = mean(abs(SoC_est(1:time-1)-SoC(1:time-1)));
fprintf('Error: ');
disp(soc_mean_error);

% soc error vector
f = figure();
VBDSE_soc_error_vector = zeros(time,1);
for ii = 1:time
    VBDSE_soc_error_vector(ii,1) = abs(SoC_est(ii)-SoC(ii,1));
end
plot(2:50:time-2,VBDSE_soc_error_vector(2:50:time-2));