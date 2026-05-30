function pt = total_pressure(p, M, gamma)
    % Total pressure from static pressure and Mach number:
    pt = p*(1 + (gamma - 1)/2*M^2)^(gamma/(gamma - 1));
end