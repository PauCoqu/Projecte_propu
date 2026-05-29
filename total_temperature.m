function Tt = total_temperature(T, M, gamma)
    % Total temperature from static temperature and Mach number:
    Tt = T*(1 + (gamma - 1)/2*M^2);
end