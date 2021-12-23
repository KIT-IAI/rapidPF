function [Va, Vm, P, Q] = back_to_whole_state(state_var, state_0, entries)
    Va(entries.variable.v_ang) = state_var(entries.half.v_ang);
    Va(entries.constant.v_ang) = state_0(entries.constant.v_ang_global);
    
    Vm(entries.variable.v_mag) = state_var(entries.half.v_mag);
    Vm(entries.constant.v_mag) = state_0(entries.constant.v_mag_global);
    
    P(entries.variable.p_net) = state_var(entries.half.p_net);
    P(entries.constant.p_net) = state_0(entries.constant.p_net_global);
    
    Q(entries.variable.q_net) = state_var(entries.half.q_net);
    Q(entries.constant.q_net) = state_0(entries.constant.q_net_global);
end