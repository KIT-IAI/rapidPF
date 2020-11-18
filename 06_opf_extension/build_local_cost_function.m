function [cost, grad, eq, eq_jac, ineq, ineq_jac, Lxx, state] = build_local_cost_function(mpc, names, postfix)
 [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

    
    mpc = ext2int(mpc);
    copy_buses_local = mpc.(names.copy_buses.local);
    N_copy = numel(copy_buses_local);
    copy_bus_types = get_bus_types(mpc.bus, copy_buses_local);
    
    % turn off generators at copy nodes
    for i = 1:length(copy_bus_types)
        if copy_bus_types(i) == 2 || copy_bus_types(i) == 3
            % get correct generator row in mpc.gen field 
            gen_entry = find_generator_gen_entry(mpc, copy_buses_local(i));
            % turn off corresponding generator
            mpc.gen(gen_entry, GEN_STATUS) = 0;
        end
    end
    
    % we changed the case file after it was switched to internal indexing
    % we need to account for that
    mpc.order.state = 'e';
    
    % 2. generate cost function with opf_costfcn
    [mpc_opf, mpopt] = opf_args(mpc); % only respect most simple opf formulation so far
    mpc_opf = ext2int(mpc_opf);
    om = opf_setup(mpc_opf, mpopt);
    
    f = @(x)opf_costfcn(x, om);
    cost = @(x)get_cost(x, f);
    grad = @(x)get_cost_gradient(x, f);
%     hess = @(x)get_cost_hess(x, f);
    
    [Ybus, Yf, Yt] = makeYbus(mpc_opf);
    il = find(mpc_opf.branch(:, 6) ~= 0 & mpc_opf.branch(:, 6) < 1e10);
    
    % equality constraints
    gh_fcn = @(x)opf_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
    eq = @(x)get_eq_cons(x, gh_fcn, copy_buses_local);
    eq_jac = @(x)get_eq_cons_jacobian(x, gh_fcn);
    
    % inequality constraints
    ineq = @(x)get_ineq_cons(x, gh_fcn);
    ineq_jac = @(x)get_ineq_cons_jacobian(x, gh_fcn);
    
    % Hessian of Lagrangian
    Lxx = @(x, lambda, cost_mult)opf_hessfcn(x, lambda, cost_mult, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
    
    buses_core = mpc.(names.regions.global);
    N_core = numel(buses_core);
    
    Ngen_on = sum(mpc.gen(:, GEN_STATUS));
    [Vang_core, Vmag_core, Pg, Qg] = create_state_mp(postfix, N_core, Ngen_on);
    [Vang_copy, Vmag_copy, ~, ~] = create_state_mp(strcat(postfix, '_copy'), N_copy, 0);
    
    Vang = [Vang_core; Vang_copy];
    Vmag = [Vmag_core; Vmag_copy];
    
    state = stack_state(Vang, Vmag, Pg, Qg);
end

function types = get_bus_types(bus, buses)
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
        VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
    types = bus(buses, BUS_TYPE);
end

%% cost function
function f = get_cost(x, f_fcn)
    [f,~] = f_fcn(x);
end

function df = get_cost_gradient(x, f_fcn)
    [~, df] = f_fcn(x);
end

function d2f = get_cost_hess(x, f_fcn)
    [~,~,d2f] = f_fcn(x);
end
%% equalities
function g = get_eq_cons(x, gh_fcn, local_buses_to_remove)
    [~,g,~,~] = gh_fcn(x);
    % remove power flow equations for all copy buses
    inds = [local_buses_to_remove; 2 * local_buses_to_remove]
    g(inds) = [];
end

function dg = get_eq_cons_jacobian(x, gh_fcn)
    [~,~,~,dg] = gh_fcn(x);
end
%% inequalities
function h = get_ineq_cons(x, gh_fcn)
    [h,~,~,~] = gh_fcn(x);
end

function dh = get_ineq_cons_jacobian(x, gh_fcn)
    [~,~,dh,~] = gh_fcn(x);
end
