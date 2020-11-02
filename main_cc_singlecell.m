clear; close all; clc;

addpath(genpath(fullfile('.', '/'))); % load all in the current folder
load('synthetic.mat');
% f: soc -> vocv lookup generation
lookup.SoC = linspace(0, 1, 1000);
lookup.Vocv = SocToVocv(lookup.SoC);

% START EXPERIMENTAL SETTING ZONE
bool_bias_vector = [1,1,1,1]; % boolean to activate bias, respectively [Igain, Ioffset, Vgain, Voffset]
% END EXPERIMENTAL SETTING ZONE

I = I.data;
V = V.data;
SoC = SoC.data;

[I, V, ~] = add_bias(I, V, lookup, bool_bias_vector, 0);

SoC_est = cc_estimate_soc(I, 0.55, dt, battery_capacity)';

% initialize figure
f = figure('Name', 'VDB-SE', 'units', 'normalized', 'outerposition', [0.05 0.05 0.90 0.90]);
ax_soc = axes(f);
hold(ax_soc, 'on');
set(ax_soc, 'FontSize', 24);
xlim(ax_soc, [0 time]);
ylabel(ax_soc, 'SoC(t)');
xlabel(ax_soc, 't [sec]');
ylim(ax_soc, [0 1]);


% plot real soc and estimated one
plot(ax_soc, 1:1:time-1, SoC(1:1:time-1), 'LineWidth', 1, 'LineStyle', '-');
plot(ax_soc, 1:1:time-1, SoC_est(1:1:time-1), 'LineWidth', 1, 'LineStyle', '-');
legend(ax_soc, 'Real SoC', 'VDB-SE SoC');
legend('Location','southeast')

% soc mean error
soc_mean_error = mean(abs(SoC_est-SoC));
fprintf('Error: ');
disp(soc_mean_error);

% soc error vector
f = figure();
VBDSE_soc_error_vector = zeros(time,1);
for ii = 1:time
    VBDSE_soc_error_vector(ii,1) = abs(SoC_est(ii)-SoC(ii,1));
end
plot(1:500:time-2,VBDSE_soc_error_vector(1:500:time-2));