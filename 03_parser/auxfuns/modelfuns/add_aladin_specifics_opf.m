function problem = add_aladin_specifics_opf(problem, mpc, names)
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
    [N_regions, N_buses_in_regions, N_copy_buses_in_regions, N_core_buses_in_regions] = get_relevant_information(mpc, names);
    consensus_matrices = problem.AA;
    % ALADIN parameters
    Sigma = deal(cell(N_regions,1));
    for i = 1:N_regions
        N_core = N_core_buses_in_regions(i);
        N_copy = N_copy_buses_in_regions(i);
        Sigma{i} = build_Sigma_per_region(N_core, N_copy);
    end
    
    Ncons   = size(consensus_matrices{1},1);
    lam0    = 0.01*ones(Ncons,1);
    %% generate output according to Aladin problem specifications
    problem.opts.Sig = Sigma;
    problem.lam0 = lam0;
    problem.b = zeros(size(lam0));
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