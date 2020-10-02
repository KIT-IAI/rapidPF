function problem = generate_distributed_problem(mpc, names, problem_type)
% generate_distributed_problem
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
    % extract Data from casefile
    [N_regions, N_buses_in_regions, N_copy_buses_in_regions, ~] = get_relevant_information(mpc, names);
    [costs, inequalities, equalities, states, xx0, pfs, bus_specs, Jacs, grads, Hessians, dims] = deal(cell(N_regions,1));
    connection_table = mpc.(names.consensus);
    % set up the Ai's
    consensus_matrices = create_consensus_matrices(connection_table, N_buses_in_regions, N_copy_buses_in_regions);
    % create local power flow problems
    fprintf('\n\n');
    for i = 1:N_regions
        fprintf('Creating power flow problem for system %i...', i);
        [cost, inequality, equality, x0, pf, bus_spec, Jac, grad, Hessian, state, dim] = generate_local_power_flow_problem(mpc.(names.split){i}, names, num2str(i), problem_type);
        [costs{i}, inequalities{i}, equalities{i}, xx0{i}, pfs{i}, bus_specs{i}, states{i}, Jacs{i}, grads{i}, Hessians{i}, dims{i}] = deal(cost, inequality, equality, x0, pf, bus_spec, state, Jac, grad, Hessian, dim);
        fprintf('done.\n')
    end
    %% generate output
    problem.locFuns.ffi = costs;
    problem.locFuns.ggi = equalities;
    problem.locFuns.hhi = inequalities;
    
    problem.locFuns.dims = dims;
    
    problem.sens.gg = grads;
    problem.sens.JJac = Jacs;
    problem.sens.HH = Hessians;

    problem.zz0 = xx0;
    problem.AA  = consensus_matrices;
    
    problem.pf = pfs;
    problem.bus_specs = bus_specs;
    problem.state = states;
end
    


