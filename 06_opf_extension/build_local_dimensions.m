function dims = build_local_dimensions(mpc_opf, ineq)
    Nbus = size(mpc_opf.bus, 1);
    Ngen = size(mpc_opf.gen, 1);
    dims.state = 2 * (Nbus + Ngen);
    dims.eq = 2 * Nbus;
    %% ToDo!
    % verification missing!!!
    x = rand(dims.state, 1);
    dims.ineq = numel(ineq(x));
end