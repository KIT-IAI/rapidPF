function [pf_problem_eval, consensus_eval, x_ref] = verify_centralized_problem(mpc, problem)
% verify_centralized_problem
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
    import casadi.*
    Nregions = numel(problem.AA);
    [pf_problem, pf_problem_eval, pf_eval] = deal(cell(Nregions, 1));
    pf_problems_symbolic = problem.ggi;
    state = problem.xx;
    
    res = runpf(mpc);
    [x_ref, x_ref_stacked] = extract_results_per_region(res);
    for i = 1:Nregions
        pf_problem{i} = matlabFunction(pf_problems_symbolic{i}, 'Vars', {state{i}});
        pf_problem_eval{i} = pf_problem{i}(x_ref_stacked{i});
        
        [ang, mag, p, q] = unstack_state(x_ref{i});
        pf_eval{i} = create_power_flow_equations(ang, mag, p, q, mpc.Y{i});
    end    
    
    problem.pf_problem = pf_problem;
    % add consensus constraints
    consensus_eval = build_consensus_constraints(problem, cat(1, x_ref_stacked{:}));
end


