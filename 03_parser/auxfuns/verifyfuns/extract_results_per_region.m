function [x, x_stacked] = extract_results_per_region(mpc, names)
% extract_results_per_region
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
    opt = mpoption;
    opt.verbose = 0;
    opt.out.all = 0;
    [res, flag] = runpf(mpc, opt);
    if ~flag
        error('current merged casefile is infeasible')
    end
    [vang, vmag, pnet, qnet] = extract_results(res);
    regions = mpc.(names.regions.global);
    N_regions = numel(regions);
    
    [x, x_stacked] = deal(cell(N_regions, 1));
    
    for i = 1:N_regions
        buses = regions{i};
        x{i} = [vang(buses), vmag(buses), pnet(buses), qnet(buses)];
        x_stacked{i} = stack_state(vang(buses), vmag(buses), pnet(buses), qnet(buses));
    end
end