function [y, y_stacked] = validate_distributed_problem_formulation(problem, mpc, names)
% validate_distributed_problem_formulation
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
    [y, y_stacked] = extract_results_per_region_with_copies(mpc, names);
    N_regions = numel(y);
    region = (1:N_regions)';
    state_dimension = problem.state_dimension;
    
    if strcmp(state_dimension,'half')   % use half state as variables
        for i = 1:N_regions
            y_stacked{i} = y_stacked{i}(problem.entries{i}.variable.stack);
        end
    end
    %% check equations
    % power flow equations
    pf_residual = cell2mat(arrayfun(@(i)norm(problem.pf{i}(y_stacked{i}), Inf), 1:N_regions, 'UniformOutput', false))';
    % bus specifications
    if strcmp(state_dimension,'full')   % use half state as variables
        bus_residual = cell2mat(arrayfun(@(i)norm(problem.bus_specs{i}(y_stacked{i}), Inf), 1:N_regions, 'UniformOutput', false))';
    end
    % consensus
    con_residual = build_consensus_constraints(problem, y_stacked);
    %% show tables
    fprintf('\n\n\n--------------------------------------------');
    fprintf('\nValidating distributed problem formulation\n')
    if strcmp(state_dimension,'full')   % use half state as variables
        tab_pf = table(region, pf_residual, bus_residual);
        tab_pf.Properties.VariableNames = {'Region', 'Power flow residuals', 'Bus specification residuals'};

    elseif strcmp(state_dimension,'half')   % use half state as variables, exclude bus_specification part
        tab_pf = table(region, pf_residual);
        tab_pf.Properties.VariableNames = {'Region', 'Power flow residuals'};
    end
    
    tab_pf
    
    tab_consensus = table(con_residual);
    tab_consensus.Properties.VariableNames = {'Consensus residuals'};
    tab_consensus
    fprintf('--------------------------------------------\n\n\n');
    
    %% output
    [y, y_stacked] = extract_results_per_region(mpc, names);
end