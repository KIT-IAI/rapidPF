function state = build_local_state(mpc, names, postfix)
    Ngen_on = size(mpc.gen, 1);
    Ncopy = numel(mpc.(names.copy_buses.local));
    Ncore = size(mpc.bus, 1) - Ncopy;
    [Vang_core, Vmag_core, Pg, Qg] = create_state_mp(postfix, Ncore, Ngen_on);
    [Vang_copy, Vmag_copy, ~, ~] = create_state_mp(strcat(postfix, '_copy'), Ncopy, 0);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    
    state = stack_state(Vang, Vmag, Pg, Qg);
end