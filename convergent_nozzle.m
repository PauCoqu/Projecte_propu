function [T_exit, p_exit, v_exit, M_exit, choked] = convergent_nozzle(Tt_in, pt_in, p_amb, gamma, cp, R, eta_n)

    p_crit = pt_in * (1 - (1/eta_n)*(gamma - 1)/(gamma + 1))^(gamma/(gamma - 1));

    if p_amb <= p_crit     % If ambient pressure is below this critical pressure, the nozzle is choked and the exit Mach number is M = 1.

        % La nozzle is chocked
        choked = true;
        M_exit = 1;

        T_exit = Tt_in/(1 + (gamma - 1)/2*M_exit^2);

        % P statica is P critica
        p_exit = p_crit;

        v_exit = M_exit*sqrt(gamma*R*T_exit);

    else     % If ambient pressure is above the critical pressure, the nozzle is unchoked and expands to ambient pressure.

        % La nozzle no chocked
        choked = false;

        % S'adapta a la p ambient
        p_exit = p_amb;

        T_exit_ideal = Tt_in*(p_exit/pt_in)^((gamma - 1)/gamma);
        T_exit = Tt_in - eta_n*(Tt_in - T_exit_ideal);

        v_exit = sqrt(2*cp*(Tt_in - T_exit));

        M_exit = v_exit/sqrt(gamma*R*T_exit); %Mach
    end
end