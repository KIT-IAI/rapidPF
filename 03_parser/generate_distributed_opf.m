function problem = generate_distributed_opf(mpc, names, ~)
% generate_distributed_opf
%
%   `problem = generate_distributed_opf(mpc, names, ~)`
%
%   _extracts the information from the splitted case files to run a distributed optimization with ALADIN_
%
%   INPUT:
%         - $\texttt{mpc}$ struct with splitted case files
%         - $\texttt{names}$ struct containing the names of the fields of
%         $\texttt{mpc}
%  Output:
%         - $\texttt{problem}$ struct with the following fields
%              - $\texttt{locFuns}$ struct with fields of cells for local costs,
%              equality constraints, inequality constraints and dimensions
%              - $\texttt{sens}$ struct with fields of cells for gradient of costs,
%              jacobian of equality and inequality and the Hessian of the
%              Lagrangian
%              - $\texttt{zz0}$ cell of initial conditions
%              - $\texttt{AA}$ cell of consensus matrices
%              - $\texttt{state}$ cell that contans the local states
%              - $\texttt{llbx}$ cell that contains the local lower bounds
%              - $\texttt{uubx}$ cell that cotains the local upper bounds


% extract Data from casefile
    [N_regions, N_buses_in_regions, N_copy_buses_in_regions, ~] = get_relevant_information(mpc, names);
    [costs,  inequalities, equalities, xx0, grads, Jacs, Hessians, states, dims, lbs, ubs] = deal(cell(N_regions,1));
    connection_table = mpc.(names.consensus);
    % set up the Ai's

    % create local power flow problems
    fprintf('\n\n');
    for i = 1:N_regions
        fprintf('Creating power flow problem for system %i...', i);
        [cost, inequality, equality, x0, grad, eq_jac, ineq_jac, Hessian, state, dim, lb, ub] = build_local_opf(mpc.(names.split){i}, names, num2str(i));
        % combine Jacobians of inequalities and equalities in single Jacobian
        Jac = @(x)[eq_jac(x), ineq_jac(x)]';
        [costs{i},  inequalities{i}, equalities{i}, xx0{i}, grads{i}, Jacs{i}, Hessians{i}, states{i}, dims{i}, lbs{i}, ubs{i}] = deal(cost, inequality, equality, x0, grad, Jac, Hessian, state, dim, lb, ub);
        fprintf('done.\n')
    end
    
    N_generators_in_regions = struct_for_N_generators(dims);
    consensus_matrices = create_consensus_matrices_opf(connection_table, N_buses_in_regions, N_generators_in_regions);
    %% generate output for Aladin
    problem.locFuns.ffi = costs;
    problem.locFuns.ggi = equalities;
    problem.locFuns.hhi = inequalities;
    
    problem.locFuns.dims = dims;
    
    problem.sens.gg = grads;
    problem.sens.JJac = Jacs;
    problem.sens.HH = Hessians;

    problem.zz0 = xx0;
    problem.AA  = consensus_matrices;
    
    problem.state = states;
    
    problem.llbx = lbs;
    problem.uubx = ubs;
end

function N_generators = struct_for_N_generators(dims)
    n = numel(dims);
    N_generators = zeros(n, 1);
    for i = 1:n
        N_generators(i) = dims{i}.n.gen;
    end
end
    


