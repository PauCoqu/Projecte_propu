function f = fuel_air_ratio(Tt3, Tt4, cp_a, cp_f, eta_b, h_PR)
    
    % We do energy conservation al combustor:
    % eta_b*f*h_PR = (1+f)*cp_f*Tt4 - cp_a*Tt3
    
    % aillant:
    f = (cp_f*Tt4 - cp_a*Tt3)/(eta_b*h_PR - cp_f*Tt4);
end