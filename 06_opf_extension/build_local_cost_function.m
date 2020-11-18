function [cost, grad, hess, eq, eq_jac, ineq, ineq_jac] = build_local_cost_function(mpc, names)
 [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
            MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
            QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;

    copy_buses_local = mpc.(names.copy_buses.local);    
    copy_bus_types = get_bus_types(mpc.bus, copy_buses_local);
    
    for i = 1:length(copy_bus_types)
        if copy_bus_types(i) == 2 || copy_bus_types(i) == 3
            % get correct generator row in mpc.gen field 
            gen_entry = find_generator_gen_entry(mpc, copy_buses_local(i));
            % turn off corresponding generator
            mpc.gen(gen_entry, GEN_STATUS) = 0;
        end
    end
    
    % 2. generate cost function with opf_costfcn
    [mpc_opf, mpopt] = opf_args(mpc); % only respect most simple opf formulation so far
    mpc_opf = ext2int(mpc_opf, mpopt);
    om = opf_setup(mpc_opf, mpopt);
    
    f = @(x)opf_costfcn(x, om);
    cost = @(x)get_cost(x, f);
    grad = @(x)get_cost_gradient(x, f);
    hess = @(x)get_cost_hess(x, f);
    
    
    [Ybus, Yf, Yt] = makeYbus(mpc_opf);
    il = find(mpc_opf.branch(:, 6) ~= 0 & mpc_opf.branch(:, 6) < 1e10);
    
    %% WARNING!!!!!!!!
    % We need to delete the power flow equations for the copy buses!!!!!!!
    %%
    
    % equality constraints
    gh_fcn = @(x)opf_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il);
    eq = @(x)get_eq_cons(x, gh_fcn);
    eq_jac = @(x)get_eq_cons_jacobian(x, gh_fcn);
    
    % inequality constraints
    ineq = @(x)get_ineq_cons(x, gh_fcn);
    ineq_jac = @(x)get_ineq_cons_jacobian(x, gh_fcn);
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
function g = get_eq_cons(x, gh_fcn)
    [~,g,~,~] = gh_fcn(x);
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
