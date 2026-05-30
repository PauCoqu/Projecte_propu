function pt_out = turbine_Pout(pt_in, Tt_in, Tt_out, gamma, eta_t)
    % Turbine outlet total pressure from turbine efficiency.

    Tt_out_s = Tt_in - (Tt_in - Tt_out)/eta_t;
    pt_out = pt_in*(Tt_out_s/Tt_in)^(gamma/(gamma - 1));
end