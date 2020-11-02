function [I, V, lookup] = add_bias(I, V, lookup, bool_bias_vector, bool_vocv_soc_bias)
    
    %   add_bias
    %       INPUT:
    %           I: current without bias
    %           V: voltage without bias
    %           bool_bias_vector: boolean to activate bias, respectively [Igain, Ioffset, Vgain, Voffset]
    %           bool_vocv_soc_bias: boolean to apply bias to f:soc->vocv
    %       OUTPUT:
    %           I: current with bias
    %           V: voltage with bias
    
    % Current
    if bool_bias_vector(1) == 1
        I = I ./ 1.01; % I gain
    end
    I = I - (0.05 * bool_bias_vector(2)); % I offset
    
    % Voltage
    if bool_bias_vector(3) == 1
        V = V .* 1.001; % V gain
        if bool_vocv_soc_bias == 1
            lookup.Vocv = lookup.Vocv .* 1.001;
        end
    end
    V = V + (0.005 * bool_bias_vector(4)); % V offset
    lookup.Vocv = lookup.Vocv + (0.005 * bool_bias_vector(4) * bool_vocv_soc_bias);
    
end