function [xsol, xsol_stacked, mpc_sol] = solve_distributed_problem_centralized(mpc, problem, names, problem_type)
% solve_distributed_problem_centralized
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
    sizes = cellfun(@(x)numel(x), problem.zz0);
    x0 = vertcat(problem.zz0{:});
    totTimer   = tic;
    if strcmp(problem_type, 'feasibility')
        [xsol,~,~,OUTPUT] = fsolve(@(x)build_con(x, problem, sizes), x0);
    else
        error('Currently, only the feasibility problem can be solved centrally.');
    end
    elapsed_time  =  toc(totTimer);
    % deal solution back
    [xsol, xsol_stacked] = deal_solution(xsol, mpc, names);
    
    % numerical solution bapwdck to matpower casefile
    iter          =  OUTPUT.iterations; % number of iteration
    alg           =  OUTPUT.algorithm;
    mpc_sol       =  back_to_mpc(mpc, xsol, elapsed_time, iter, alg);
end

function eq = build_con(x, problem, buses)
    x_split = split_vector(x, buses);
    n = numel(buses);
    eq_temp = cell(n, 1);
    consensus = zeros(size(problem.AA{1}, 1), 1);
    for i = 1:n
        g = problem.locFuns.ggi{i};
        eq_temp{i} = g(x_split{i});
        consensus = consensus + problem.AA{i} * x_split{i};
    end
    eq = [ cell2mat(eq_temp); consensus ];
end

function y = split_vector(x, buses)
    n = numel(buses);
    ncum = [0; cumsum(buses)];
    y = cell(n, 1);
    for i = 1:n
        y{i} = x(ncum(i) + (1:buses(i)));
    end
end


