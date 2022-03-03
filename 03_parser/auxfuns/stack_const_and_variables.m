function [Vang, Vmag, Pnet, Qnet] = stack_const_and_variables(state_var, state_const, entries)
    % stack variables and constants
    Vang = [state_var(entries.half.v_ang); state_const(entries.constant.v_ang_global)];
    Vmag = [state_var(entries.half.v_mag); state_const(entries.constant.v_mag_global)];
    Pnet = [state_var(entries.half.p_net); state_const(entries.constant.p_net_global)];
    Qnet = [state_var(entries.half.q_net); state_const(entries.constant.q_net_global)];

    % change to the correct order
    Vang = Vang(entries.back_to_state.va_order);
    Vmag = Vmag(entries.back_to_state.vm_order);
    Pnet = Pnet(entries.back_to_state.p_order);
    Qnet = Qnet(entries.back_to_state.q_order);
end