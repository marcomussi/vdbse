function [I, V, lookup] = apply_biases(I_input, V_input, I_offset, I_gain, V_offset, V_gain, lookup_input, apply_to_vocvsoc)

    I = I_input .* I_gain + I_offset;
    V = V_input .* V_gain + V_offset;
    lookup = lookup_input;
    
    if apply_to_vocvsoc == 1
        lookup.Vocv = lookup.Vocv .* V_gain + V_offset;
    end
    
end