function SoC = estimate_soc_VDBSE(I, V, battery_capacity, dt, ...
    SoCtimewindow, moving_step, restarts, lookup, scale_factors, time, verbose)

    %   estimate_soc_VDBSE estimates the SoC value SoC(t) for each t
    %
    %   INPUT:
    %       I: array of Current measurements
    %       V: array of Voltage measurements
    %       battery_capacity: nominal battery capacity 
    %               (not used in the estimation)
    %       dt: sampling interval
    %       SoCtimewindow: amplitude of the SoC variation required to
    %               select the data batch for estimation
    %       moving_step: SoC variation which trigger the new model
    %               estimation
    %       restarts: number of restarts to avoid local minima
    %       lookup: lookup table
    %       scale_factors: array [Rs_scale Rp_scale C_scale] scale factors
    %       time: total time
    %       verbose: verbose integer (1->True, 0->False)
    %
    %   OUTPUT:
    %       SoC(t)
    
    iter_end = 0;
    iter_init = iter_end + 1;
    min_SoC = 0;
    max_SoC = 0;
    iter_end = iter_init;
    actual_SoC = 0;
    time = length(I);

    while max_SoC - min_SoC < SoCtimewindow && iter_end < time - 1 
        actual_SoC = actual_SoC - (1/battery_capacity) * I(iter_end) * dt;
        iter_end = iter_end + 1; 
        max_SoC = max(max_SoC, actual_SoC);
        min_SoC = min(min_SoC, actual_SoC);
    end
    windows_amplitude = iter_end - iter_init;
    
    % first estimation phase 
    [Rs_est, Rp_est, C_est, SoC_tau_est, ~] = ...
                    estimate_all_params(I(iter_init:iter_end), V(iter_init:iter_end), ...
                    dt, 'interior-point', restarts, lookup, scale_factors, verbose);
    % first prediction phase            
    Vocv_est(iter_init:iter_end,1) = estimate_Vocv(I(iter_init:iter_end), ...
                    V(iter_init:iter_end), I(iter_init), V(iter_init), ...
                    get_Vocv(SoC_tau_est,lookup), dt, Rs_est, Rp_est, C_est, 1, 1, 1);
    
    % from now on, the values of the Vocv(t) (and, by conseguence, the SoC(t)) 
    % are estimated usign the last model available            
    while iter_end < time

        iter_init = iter_end + 1;
        min_SoC = 0;
        max_SoC = 0;
        iter_end = iter_init;
        actual_SoC = 0;

        while max_SoC - min_SoC < moving_step && iter_end < time - 1 
            actual_SoC = actual_SoC - (1/battery_capacity) * I(iter_end) * dt;
            iter_end = iter_end + 1; 
            max_SoC = max(max_SoC, actual_SoC);
            min_SoC = min(min_SoC, actual_SoC);
        end
        
        % Vocv is estimated using the old model until the new one is
        % available
        Vocv_est(iter_init:iter_end,1) = estimate_Vocv(I(iter_init:iter_end), ...
                        V(iter_init:iter_end), I(iter_init-1), V(iter_init-1), ...
                        Vocv_est(iter_init-1,1), dt, Rs_est, Rp_est, C_est, 1, 1, 1);
        
        % a new model is now estimated, it will be used in the next 
        % iteration of the for loop            
        [Rs_est, Rp_est, C_est, ~, ~] = estimate_all_params( ...
                    I(iter_end-windows_amplitude:iter_end), V(iter_end-windows_amplitude:iter_end), ...
                    dt, 'interior-point', restarts, lookup, scale_factors, verbose);

    end
    
    % estimate the value of the SoC(t) starting from the Vocv(t)
    SoC = interp1(lookup.Vocv, lookup.SoC, Vocv_est(1:time,1), 'spline');
    
end