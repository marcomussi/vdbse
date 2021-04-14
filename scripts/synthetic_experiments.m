% this script generares the results of the latex table of the syntethic experiments

close all; clear; clc

directory = 'data/power_profile_tests';
files_and_folders = dir(directory);
files = files_and_folders(~([files_and_folders.isdir]));

errors = [[0, 1, 0, 1, 0]; [0.05, 1.01, 0.005, 1.001, 0]; [0.05, 1.01, 0.005, 1.001, 1]];
interval = 1000;

for ii = 1:length(files)
    
    for err_i = 1:3
        
        SocToVocv = @(x)((3.43 + 0.68*x - 0.68*(x.^2) + 0.81*(x.^3) - 0.31*exp(-46*x))); 
        lookup.SoC = linspace(0, 1, 100);
        lookup.Vocv = SocToVocv(lookup.SoC);
        load(files(ii).name);
        I_real = timeseries(I);
        [I, V, lookup] = apply_biases(I, V, errors(err_i,1), errors(err_i,2), errors(err_i,3), ...
                        errors(err_i,4), lookup, errors(err_i,5));
        
        SoC_CC = cc_SoC(I, 0.55, dt, battery_capacity)';
        fprintf(' & %.4f', mean(abs(SoC_CC(1:time)-SoC(1:time))));
                    
        
        SoC_VDBSE = estimate_soc_VDBSE(I, V, battery_capacity, dt, 0.4, 0.2, 3, lookup, [1e-3,1e-3,1e3], time, 0);
        fprintf(' & %.4f', mean(abs(SoC_VDBSE(1:time)-SoC(1:time))));

        I = timeseries(I);
        V = timeseries(V);
        temperature = timeseries(temperature);
        apply_to_vocvsoc = errors(err_i,5);
        offset_v = timeseries(apply_to_vocvsoc * errors(err_i,3));
        if apply_to_vocvsoc == 1
            gain_v = timeseries(errors(err_i,4));
        else
            gain_v = timeseries(1);
        end
        out = sim('utils/SoC_modelbased.mdl', time);
        err_SoC_MB = modelbased.SoC.data - modelbased.SoCReale.data;
        
        fprintf(' & %.4f', mean(abs(err_SoC_MB)));
        
        err_SoC_MB = abs(err_SoC_MB);
        err_SoC_VDBSE = abs(SoC_VDBSE(1:time) - SoC(1:time));
        err_SoC_CC = abs(SoC_CC(1:time) - SoC(1:time));
        
    end
    
    fprintf(' \\\\ \n');
    
end
