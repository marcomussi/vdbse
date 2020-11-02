function Vocv_hat = estimate_Vocv( ...
    i_batch, v_batch, i_tau, v_tau, vocv_tau, dt, Rs, Rp, C, scale_factors)

    %   estimate_Vocv
    %       INPUT:
    %           i_batch: array of Current measurements
    %           v_batch: array of Voltage measurements
    %           i_tau: current value at time tau
    %           v_tau: voltage value at time tau
    %           vocv_tau: vocv hypothesis at time tau
    %           dt: sampling interval
    %           Rs: Rs value
    %           Rp: Rp value
    %           C: C value
    %           scale_factors: vector of scale factors for [Rs, Rp, C]
    %       OUTPUT:
    %           Vocv_hat: supposition of voltage value given current input, 
    %               voltage initial value and equivalent model parameters

    assert(length(v_batch) == length(i_batch)) % check time series length
    
    % rescale for coherency w.r.t. previuos analisys
    Rs = Rs * scale_factors(1);
    Rp = Rp * scale_factors(2);
    C = C * scale_factors(3);
    
    vocv_batch(1) = vocv_tau; % initial SoC setting
    v_batch = [v_tau; v_batch];
    i_batch = [i_tau; i_batch];
    
    % propagation a sample at a time
    for ii = 2:length(i_batch)
        vocv_batch(ii) = ( ...
            ((1/dt)+(1/(C*Rp))).*v_batch(ii) ...
            - (v_batch(ii-1)./dt) ...
            + (vocv_batch(ii-1)./dt) ...
            + (((Rs./dt)+(1./C)+(Rs./(C.*Rp))).*i_batch(ii)) ...
            - ((Rs./dt).*i_batch(ii-1))    ) ...
            / ((1./dt)+(1/(C.*Rp)));
    end

    Vocv_hat = vocv_batch(2:length(i_batch));
    
end