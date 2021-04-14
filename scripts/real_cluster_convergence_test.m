% this script evaluates the convergenxe of the algorithm in case of data
% stream interruptions

close all; clear; clc;

load('data_fieldexperiments.mat');
load('lookup_fieldexperiments.mat');

dt = 1;
I = -I; % different measurement standard
time = 9599;
SoCtimewindow = 0.4;
moving_step = 0.2;
restarts = 10; 
battery_capacity = 53.4 * 3600;

iter_end = 0;
iter_init = iter_end + 1;
min_SoC = 0;
max_SoC = 0;
iter_end = iter_init;
actual_SoC = 0;

while max_SoC - min_SoC < SoCtimewindow && iter_end < time - 1 
    actual_SoC = actual_SoC - (1/battery_capacity) * I(iter_end) * dt;
    iter_end = iter_end + 1; 
    max_SoC = max(max_SoC, actual_SoC);
    min_SoC = min(min_SoC, actual_SoC);
end
% only one estimation
[Rs_est, Rp_est, C_est, ~, ~] = estimate_all_params(I(iter_init:iter_end), ...
            V(iter_init:iter_end), dt, 'interior-point', restarts, lookup, [0.1, 0.1, 10], 0);

% suppose a data stream fault that is recovered at t=6000, now a convergence test 
% is performed at different last soc values with the last model estimated         
initial_Div_values = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
init_div_test = 6000;

for ii = 1:length(initial_Div_values)
    Vocv_est(:,ii) = estimate_Vocv(I, V, I(1), V(1), ...
                get_Vocv(initial_Div_values(ii),lookup), dt, Rs_est, Rp_est, C_est, 1, 1, 1);
    Vocv_est(init_div_test:time,ii) = estimate_Vocv(I(init_div_test:time), V(init_div_test:time), ...
                I(init_div_test-1), V(init_div_test-1), ...
                get_Vocv(initial_Div_values(ii),lookup), dt, Rs_est, Rp_est, C_est, 1, 1, 1);        
    SoC_est(:,ii) = interp1(lookup.Vocv,lookup.SoC, Vocv_est(:,ii), 'spline');
end

% real SoC estimation using Coulomb Counting
SoC_CC = cc_SoC(I, 0.4266, dt, battery_capacity);

% FIGURES

interval = 100; % only for tikz contraints in paper

f = figure('Name', 'Selection part', ...
    'units', 'normalized', 'outerposition', [0.02 0.003 0.96 0.96]);
ax_soc = axes(f);
hold(ax_soc, 'on');
set(ax_soc, 'FontSize', 24);
xlim(ax_soc, [init_div_test init_div_test+1200]);
legend('Location', 'southeast');
ylabel(ax_soc, 'SoC(t)');
xlabel(ax_soc, 't[s]');
ylim(ax_soc, [0 1]);
for ii = 1:length(initial_Div_values)
    plot(ax_soc, (2:interval:time-1).*dt, SoC_est(2:interval:time-1,ii), 'LineWidth', 1, 'LineStyle', '-');
end
plot(ax_soc, (2:interval:time-1).*dt, SoC_CC(2:interval:time-1), 'LineWidth', 1, 'LineStyle', '-');
legend(ax_soc, '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1', 'Real SoC');


f_err = figure('Name', 'SoC_error', ...
    'units', 'normalized', 'outerposition', [0.02 0.003 0.96 0.96]);
ax_err = axes(f_err);
hold(ax_err, 'on');
set(ax_err, 'FontSize', 24);
xlim(ax_err, [init_div_test init_div_test+1200]);
legend('Location', 'northeast');
ylabel(ax_err, 'SoC error');
xlabel(ax_err, 't[s]');
for ii = 1:length(initial_Div_values)
    plot(ax_err, (2:interval:time-1).*dt, abs(SoC_est(2:interval:time-1,ii)'-SoC_CC(2:interval:time-1)));
end
legend(ax_err, '0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1');