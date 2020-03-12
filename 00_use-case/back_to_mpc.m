% numerical solution back to matpower case file
function mpc = back_to_mpc(mpc_split, xsol, et, iter, alg)
% INPUT
% mpc_split -- matpower case file (distributed)
% xsol      -- numercal solution
% et        -- elapsed time
% iter      -- iterations
% alg       -- name of algorithm
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;

    baseMVA        =  mpc_split.baseMVA;
    bus0           =  mpc_split.bus;
    gen0           =  mpc_split.gen;
    branch0        =  mpc_split.branch;
    [Ybus, Yf, Yt] =  makeYbus(baseMVA, bus0, branch0);
    V              =  get_voltage(xsol);
    ref            =  find(bus0(:, BUS_TYPE) == 3);
    [bus, gen, branch] = pfsoln(baseMVA, bus0, gen0, branch0, Ybus, Yf, Yt, V, ref);
    mpc.bus        =  bus;
    mpc.gen        =  gen;
    mpc.branch     =  branch;
    mpc.baseMVA    =  baseMVA;
    mpc.success    =  true;     % Optimal Solution Found
    mpc.et         =  et;       % elapsed time in seconds
    mpc.iterations =  iter;
    str            =  join(['\n' ,alg, ' Algorithm converged in %d iterations']);
    fprintf(str, iter);
    printpf(mpc);
end

function V = get_voltage(x)
    x_full = vertcat(x{:});
    ang = x_full(:, 1);
    mag = x_full(:, 2);
    V = mag .* exp(1j * ang);
end