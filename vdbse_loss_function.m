function l = vdbse_loss_function(x, u, dt, lookup, scale_factors)
    
    % Discrete Evolution of V_hat given initial situation, supposed
    % parameters and current timeseries
    % State vector: x = [ Rs Rp C SoC(tau)]
    % Input vector: u = [ V(t) I(t) SoC_variation(t) ]
    % Sampling interval: dt
    % Lookup table SoC Vocv: lookup -> lookup.SoC and lookup.Vocv
    % Scale factors vector: scale_factors -> for Rs, Rp and C (taken in this order)
    
    SoC2Vocv = @(x)(interp1(lookup.SoC, lookup.Vocv, x, 'spline'));
    
    soc = x(4) + u(:,3); % x(4) is the supposed initial SoC value, this value
                         % is propagated through Coulomb Counting
    vocv = SoC2Vocv(soc); % vocv associated to soc
    
    % propagate voltage estimation over all time interval
    V_hat = estimate_V( u(2:end,2), vocv(2:end), ...
        u(1,2), u(1,1), vocv(1), dt, x(1), x(2), x(3), scale_factors);
    
    % the loss value is the sum forall t of the differences (absolute) between the
    % measured voltage values and the estimated ones (V_hat)
    l = sum(abs(V_hat'-u(2:end,1))); 
    
end