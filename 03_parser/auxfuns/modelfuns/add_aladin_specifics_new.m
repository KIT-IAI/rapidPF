function problem = add_aladin_specifics_new(problem, mpc, names)
% add_aladin_specifics
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
    [N_regions, ~, N_copy_buses_in_regions, N_core_buses_in_regions] = get_relevant_information(mpc, names);
    consensus_matrices = problem.AA;
    % ALADIN parameters
    [Sigma, lb, ub] = deal(cell(N_regions,1));
    for i = 1:N_regions
        N_core = N_core_buses_in_regions(i);
        N_copy = N_copy_buses_in_regions(i);
        Sigma_i = build_Sigma_per_region(N_core, N_copy);
        [lb_temp, ub_temp] = build_bounds_per_region(N_core, N_copy);
        
        % get only the part for variables
        entries = problem.entries{i}.variable.stack;
        lb_temp = lb_temp(entries);
        ub_temp = ub_temp(entries);
        [lb{i}, ub{i}] = deal(lb_temp, ub_temp);
        Sigma{i} = Sigma_i(entries, entries);
    end
    
    Ncons   = size(consensus_matrices{1},1);
    lam0    = 0.01*ones(Ncons,1);
    %% generate output according to Aladin problem specifications
    problem.llbx = lb;
    problem.uubx = ub;
    problem.opts.Sig = Sigma;
    problem.lam0 = lam0;
    % problem.b = zeros(size(lam0));
end

function Sigma = build_Sigma_per_region(N_core, N_copy)
    ang = 100;
    mag = 100;
    p = 1;
    q = 1;

    Sigma_core = build_Sigma(N_core, [ang; mag; p; q]);
    Sigma_copy = build_Sigma(N_copy, [ang; mag]);
    Sigma = blkdiag(Sigma_core, Sigma_copy);
end

function Sigma = build_Sigma(Nbus, weights)
    Sigma_diag_entries = kron(weights, ones(Nbus, 1));
    Nw = numel(weights);
    Sigma = speye(Nw*Nbus);
    Sigma(1:1+Nw*Nbus:(Nw*Nbus)^2) = Sigma_diag_entries;
end

function [lb, ub] = build_bounds_per_region(N_core, N_copy)
%     ang_lb = -pi/4;
%     ang_ub = pi/4;
%     mag_lb = 0.5;
%     mag_ub = 1.5;
%     p_lb = -10;
%     p_ub = 10;
%     q_lb = -10;
%     q_ub = 10;



    ang_lb = -10;
    ang_ub = 10; 
    mag_lb = 0.1;
    mag_ub = 10; 
    p_lb = -100; 
    p_ub = 100;  
    q_lb = -100; 
    q_ub = 100;  
    
    [lb, ub] = build_bounds(N_core, N_copy, [ang_lb; mag_lb; p_lb; q_lb], [ang_ub; mag_ub; p_ub; q_ub]);
end

function [lb, ub] = build_bounds(Ncore, Ncopy, lb_vec, ub_vec)
    lb = build_bounds_aux(Ncore, Ncopy, lb_vec);
    ub = build_bounds_aux(Ncore, Ncopy, ub_vec);
end

function bounds = build_bounds_aux(Ncore, Ncopy, vec)
    ang = vec(1);
    mag = vec(2);
    p = vec(3);
    q = vec(4);
    
    bounds = [ kron([ang; mag], ones(Ncore + Ncopy, 1));
               kron([p; q], ones(Ncore, 1)) ];
end
