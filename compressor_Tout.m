function Tt_out = compressor_Tout(Tt_in, pi_c, gamma, eta_c)
    % Compressor/fan outlet total temperature:
    Tt_out = Tt_in*(1 + (pi_c^((gamma - 1)/gamma) - 1)/eta_c);
end