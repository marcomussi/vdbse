function [SoC_array] = cc_estimate_soc(i_batch, init_SoC, dt, q)
    
    % cc_estimate_soc estimate the SoC using Coulomb Counting method
    %   INPUT:
    %       i_batch: array of current measures
    %       init_SoC: the initial value of the SoC
    %       dt: sampling time
    %       q: capacity of the battery at moment t   
    %   OUTPUT:
    %       SoC_array: vector of SoC values
    
    aux = init_SoC;
    
    for ii = 1:length(i_batch)
        
        aux = aux - (1/q)*i_batch(ii)*dt;
        SoC_array(ii) = aux;
    
    end
    
end

