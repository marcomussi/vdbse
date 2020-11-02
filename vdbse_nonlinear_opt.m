function [Rs, Rp, C, SoC_tau] = vdbse_nonlinear_opt( i_batch, v_batch, ...
        battery_capacity, dt, algorithm, number_restarts, lookup, scale_factors, seed)
    
    %   vdbse_nonlinear_opt estimate values of equivalent model parameters
    %       INPUT:
    %           i_batch: array of Current measurements
    %           v_batch: array of Voltage measurements
    %           battery_capacity: maximum capacity the battery can reach
    %           dt: sampling interval
    %           algorithm: algorithm to perform fmincon
    %           number_restarts: number of restarts to avoid local minima
    %           lookup: SoC Vocv lookup table
    %           scale_factors: vector of scale factors for [Rs, Rp, C]
    %           seed: random initial seed
    %       OUTPUT:
    %           Rs, Rp, C and the initial SoC SoC_tau

    assert(length(v_batch) == length(i_batch));
    
    time = length(v_batch);
    in(1:time,1) = v_batch(1:time);
    in(1:time,2) = i_batch(1:time);
    in(:,3) = - cumsum(i_batch) * (dt ./ battery_capacity); % CC variations
    
    % closure of the loss function
    to_min = @(x)vdbse_loss_function(x, in, dt, lookup, scale_factors);
    
    % optimizer options
    minOptions = optimoptions('fmincon', 'Display', 'iter-detailed', ...
        'Algorithm', algorithm, 'OptimalityTolerance', 1e-50, ...
        'StepTolerance', 1e-50, 'MaxFunctionEvaluations', 5e3, 'MaxIterations', 5e3);
    
    lb = [0.01, 0.01, 0.01, 0.01]; % parameters lowerbound [Rs, Rp, C, SoC_tau]
    ub = [1000, 1000, 1000, 1]; % parameters upperbound [Rs, Rp, C, SoC_tau]
    
    rng(seed, 'philox'); % set random seed
    randmatrix = rand(number_restarts,length(ub));
    for jj = 1:length(ub) % generate random initial vectors and adapt to upper and lower bound
       randmatrix(:,jj) = randmatrix(:,jj).*(ub(jj)-lb(jj))+lb(jj);  
    end
    
    for jj = 1:number_restarts % for each random initial vector
        try
            % call to optimizer
            [x(jj,:), fval(jj)] = fmincon(to_min, randmatrix(jj,:)', ...
                [], [], [], [], lb, ub, [], minOptions);
        catch
            % manage errors in optimization procedure
            fval(jj) = 1e9;
        end
    end
    
    % select value corresponding to best loss function value
    [~, idx] = min(fval);
    Rs = x(idx,1);
    Rp = x(idx,2);
    C = x(idx,3);
    SoC_tau = x(idx,4);
    
end