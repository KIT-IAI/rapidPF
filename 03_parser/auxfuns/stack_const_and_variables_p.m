function [Vang, Vmag, Pnet] = stack_const_and_variables_p(state_var, state_const, entries)
    % stack variables and constants
    Vang = [state_var(entries.half.v_ang); state_const(entries.constant.v_ang_global)];
    Vmag = [state_var(entries.half.v_mag); state_const(entries.constant.v_mag_global)];
    Pnet = [state_var(entries.half.p_net); state_const(entries.constant.p_net_global)];
    
    % get the correct order 
    [~, v_ang_order] = sort([entries.variable.v_ang entries.constant.v_ang]);
    [~, v_mag_order] = sort([entries.variable.v_mag entries.constant.v_mag]);
    [~, p_net_order] = sort([entries.variable.p_net entries.constant.p_net]);
    
    % change to the correct order
    Vang = Vang(v_ang_order);
    Vmag = Vmag(v_mag_order);
    Pnet = Pnet(p_net_order);
end