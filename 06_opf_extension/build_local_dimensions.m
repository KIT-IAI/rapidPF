function dims = build_local_dimensions(mpc_opf, eq, ineq)
    % this file assumes that all generators at the copy busses have been turned off
    % i.e. prepare_case_file() was called already!
    Nbus = size(mpc_opf.bus, 1);
    Ngen = size(mpc_opf.gen, 1);
    dims.state = 2 * (Nbus + Ngen);
    dims.eq = 2 * Nbus;
    dims.n.bus = Nbus;
    dims.n.gen = Ngen;
    %% ToDo!
    % verification missing!!!
    x = rand(dims.state, 1);
    dims.ineq = numel(ineq(x));
    dims.eq = numel(eq(x));
end