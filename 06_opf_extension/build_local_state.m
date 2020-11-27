function state = build_local_state(mpc, names, postfix)
% BUILD_LOCAL_STATE
%
%   `state = build_local_state(mpc, names, postfix)`
%
%   _returns symbolic representation of optimization variable_
%
%   # Formate
% Input:
%
%   - $\texttt{mpc}$ splitted casefile
%   - $\texttt{names}$ specific names of mpc struct fields
%   - $\texttt{copy}$ either $\texttt{core}$ or $\texttt{copy}$
% Output
%   - $\texttŧ{state}$ symbolic state
%
% Final formate:
% state = (Vang; Vm; Pg; Qg) (column vector) with 
% - Vang = (Vang_1; ... ; Vang_{#Nbuses})
% - Vm = (Vm_1; ... ; Vm_{#Nbuses})
% - Pg = (Pg_1; ... ; Pg_{#switched_on_generators})
% - Qg = (Qg_1; ... ; Qg_{#switched_on_generators})

    assert (size(mpc.gen, 1) == size(mpc.gen(:, 8) == 1, 1), ...
        'mpc file in build_local_state should only contain generators that are switched on');
    
    Ngen_on = size(mpc.gen, 1);
    Ncopy = numel(mpc.(names.copy_buses.local));
    Ncore = size(mpc.bus, 1) - Ncopy;
    [Vang_core, Vmag_core, Pg, Qg] = create_state_mp(postfix, Ncore, Ngen_on);
    [Vang_copy, Vmag_copy, ~, ~] = create_state_mp(strcat(postfix, '_copy'), Ncopy, 0);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    
    state = stack_state(Vang, Vmag, Pg, Qg);
end