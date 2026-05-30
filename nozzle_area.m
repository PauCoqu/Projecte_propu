function A = nozzle_area(mdot, Tt, pt, M, gamma, R)
    % Nozzle area from the MFP
    A = mdot*sqrt(R*Tt)/(pt*MFP(M, gamma));
end