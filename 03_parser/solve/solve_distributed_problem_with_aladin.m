function [xoptAL, loggAL] = solve_distributed_problem_with_aladin(mpc, dOPF, opts)
    global NAME_FOR_REGION_FIELD
    NsubSys = numel(mpc.(NAME_FOR_REGION_FIELD));
    % convert symbolic variables to functions
    [ffifun, hhifun, ggifun] = deal(cell(NsubSys, 1));
    
    for i=1:NsubSys
        [ffifun{i},hhifun{i},ggifun{i}] = deal( @(x)0*sum(x), @(x)[], matlabFunction(dOPF.ggi{i},'Vars',{dOPF.xx{i}}));
    end    

    A       = [dOPF.AA{:}];
    Ncons   = size(A,1);
    lam0    = 0.01*ones(Ncons,1);

    [xoptAL, loggAL] = run_ALADIN(ffifun,ggifun,hhifun,dOPF.AA,dOPF.xx0,lam0,dOPF.lbx,dOPF.ubx,dOPF.Sig,opts);
end

function f = create_empty_function_handle(N)
    f = repelem({@(x)[]}, N, 1);
end