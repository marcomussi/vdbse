% this scripts evaluate the performance of VDB-SE on real cluster of
% batteries. Data are provided by RSE.

close all; clear; clc;

load('lookup_fieldexperiments.mat');
load('data_fieldexperiments.mat');

dt = 1;
time = 9599;
timewindow = 0.4; % interval of soc to consider in each estimation batch
moving_step = 0.2;
number_restart = 10; % number of restarts (to avoid local minima)
battery_capacity = 53.4 * 3600; % 53.4
% battery_capacity = 50 * 3600;
scale_factors = [0.1, 0.1, 10];

I = -I; % different measurement standard

SoC_VDBSE = estimate_soc_VDBSE(I, V, battery_capacity, dt, 0.4, 0.2, ...
                        number_restart, lookup, scale_factors, time, 0);    

% real soc estimation using Coulomb Counting 
SoC_CC = cc_SoC(I, 0.4266, dt, battery_capacity);

SoC_mean_error = sum(abs(SoC_VDBSE(2:time-1)'-SoC_CC(2:time-1)));

% FIGURES

interval = 100; % only for tikz contraints in paper

f = figure('Name', 'SoC', ...
    'units', 'normalized', 'outerposition', [0.02 0.003 0.96 0.96]);
ax_soc = axes(f);
hold(ax_soc, 'on');
set(ax_soc, 'FontSize', 24);
xlim(ax_soc, [0 time*dt]);
ylabel(ax_soc, 'SoC(t)');
xlabel(ax_soc, 't[s]');
ylim(ax_soc, [0 1]);
plot(ax_soc, (2:interval:time-1).*dt, SoC_CC(2:interval:time-1), ...
                'LineWidth', 1, 'LineStyle', '-');
plot(ax_soc, (2:interval:time-1).*dt, SoC_VDBSE(2:interval:time-1,1), ...
                'LineWidth', 1, 'LineStyle', '-');
legend(ax_soc, 'SoC', 'Estimated SoC');
legend('Location','southeast')

f_err = figure('Name', 'SoC error', ...
    'units', 'normalized', 'outerposition', [0.02 0.003 0.96 0.96]);
ax_err = axes(f_err);
hold(ax_err, 'on');
set(ax_err, 'FontSize', 24);
xlim(ax_err, [0 time*dt]);
ylim(ax_err, [0 0.1]);
ylabel(ax_err, 'SoC error');
xlabel(ax_err, 't[s]');
plot(ax_err, (2:interval:time-1).*dt, ...
            abs(SoC_VDBSE(2:interval:time-1)'-SoC_CC(2:interval:time-1)));
legend(ax_err,'Error')

err = mean(abs(SoC_VDBSE(2:time-1)'-SoC_CC(2:time-1)));