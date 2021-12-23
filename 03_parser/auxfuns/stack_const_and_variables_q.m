function [Vang, Vmag, Qnet] = stack_const_and_variables_q(state_var, state_const, entries)
    % stack variables and constants
    Vang = [state_var(entries.half.v_ang); state_const(entries.constant.v_ang_global)];
    Vmag = [state_var(entries.half.v_mag); state_const(entries.constant.v_mag_global)];
    Qnet = [state_var(entries.half.q_net); state_const(entries.constant.q_net_global)];
    
    % get the correct order 
    [~, v_ang_order] = sort([entries.variable.v_ang entries.constant.v_ang]);
    [~, v_mag_order] = sort([entries.variable.v_mag entries.constant.v_mag]);
    [~, q_net_order] = sort([entries.variable.q_net entries.constant.q_net]);
    
    % change to the correct order
    Vang = Vang(v_ang_order);
    Vmag = Vmag(v_mag_order);
    Qnet = Qnet(q_net_order);
end