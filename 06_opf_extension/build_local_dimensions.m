function dims = build_local_dimensions(mpc_opf, eq, ineq, local_buses_to_remove)
% DIMS 
%
%   `dims = build_local_dimensions(mpc_opf, eq, ineq, local_buses_to_remove)`
%
%   _creates a field of dimensions as how they should look like and use it for testing_
%
%   INPUT:  - mpc_opf splitted case files
%           - eq power flow equations for core nodes plus their jacbian'
%           - ineq flow limits inequality constraints plus their jacobian'
%           - local_buses_to_remove copy nodes
%   OUTPUT: - dims struct containing dimensions
    
    Nbus = size(mpc_opf.bus, 1);
    Ngen = size(mpc_opf.gen, 1);
    dims.state = 2 * (Nbus + Ngen);
    dims.eq = 2 * (Nbus - length(local_buses_to_remove));
    
    il = find(mpc_opf.branch(:, 6) ~= 0 & mpc_opf.branch(:, 6) < 1e10);
    dims.ineq = 2 * length(il); % one inequality for each from and to bus
        
    dims.n.bus = Nbus;
    dims.n.gen = Ngen;
    %% Test dimensions
    x = rand(dims.state, 1);
 %   assert (dims.ineq == numel(ineq(x)), 'Error during dimension check of number of inequality constraints'); 
    assert (dims.eq == numel(eq(x)), 'Error during dimension check of number of equality constraints');
end