function valor = MFP(M, gamma)
    % We calculate the MFP
    valor= sqrt(gamma)*M*(1+ (gamma - 1)/2*M^2)^(-(gamma + 1)/(2*(gamma - 1)));
end