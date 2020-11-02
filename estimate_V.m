function V_hat = estimate_V( ...
    i_batch, vocv_batch, i_tau, v_tau, vocv_tau, dt, Rs, Rp, C, scale_factors)

    %   estimate_V
    %       INPUT:
    %           i_batch: array of Current measurements
    %           vocv_batch: array of Vocv hypothesis
    %           i_tau: current value at time tau
    %           v_tau: voltage value at time tau
    %           vocv_tau: vocv hypothesis at time tau
    %           dt: sampling interval
    %           Rs: Rs value
    %           Rp: Rp value
    %           C: C value
    %           scale_factors: vector of scale factors for [Rs, Rp, C]
    %       OUTPUT:
    %           V_hat: supposition of voltage value given current input, 
    %               voltage initial value and equivalent model parameters

    assert(length(vocv_batch) == length(i_batch)); % check time series length
    
    % rescale for optimization reasons
    Rs = Rs * scale_factors(1);
    Rp = Rp * scale_factors(2);
    C = C * scale_factors(3);
    
    v_batch(1) = v_tau; % voltage initialization at measured value
    vocv_batch = [vocv_tau; vocv_batch];
    i_batch = [i_tau; i_batch];
    
    % propagation a sample at a time
    for ii = 2:length(i_batch)
        v_batch(ii) = ( ...
            ( 1/dt ) * v_batch(ii-1) + ...
            ( (1/dt) + (1/(C*Rp)) ) * vocv_batch(ii) - ...
            ( 1/dt ) * vocv_batch(ii-1) - ...
            ( (Rs/dt) + (1/C) + (Rs/(Rp*C)) ) * i_batch(ii) + ...
            ( Rs/dt ) * i_batch(ii-1)   ) ...
            / ((1./dt)+(1/(C.*Rp)));
    end

    V_hat = v_batch(2:length(i_batch));
    
end