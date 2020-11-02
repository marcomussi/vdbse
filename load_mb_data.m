clear; close all; clc;

addpath(genpath(fullfile('.', '/'))); % load all in the current folder
load('synthetic.mat');
% f: soc -> vocv lookup generation
lookup.SoC = linspace(0, 1, 1000);
lookup.Vocv = SocToVocv(lookup.SoC);

% START EXPERIMENTAL SETTING ZONE
bool_bias_vector = [1,1,1,1]; % boolean to activate bias, respectively [Igain, Ioffset, Vgain, Voffset]
bool_vocv_soc_bias = 1; % boolean, 1 if bias is applied also to f:soc->vocv, 0 otherwise
% END EXPERIMENTAL SETTING ZONE

[I.data, V.data, ~] = add_bias(I.data, V.data, lookup, bool_bias_vector, bool_vocv_soc_bias);
bool_vocv_soc_bias = timeseries(bool_vocv_soc_bias);