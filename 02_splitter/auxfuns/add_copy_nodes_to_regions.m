function mpc = add_copy_nodes_to_regions(mpc, names)
% add_copy_nodes_to_regions
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

    regions = mpc.(names.regions.global);
    copy_nodes = mpc.(names.copy_buses.global);
    
    assert(numel(regions) == numel(copy_nodes), 'inconsistent dimensions.')
    Nregions = numel(regions);
    
    regions_with_copy_nodes = cell(Nregions, 1);
    for i = 1:Nregions
        regions_with_copy_nodes{i} = [regions{i} sort(copy_nodes{i})'];
    end
    mpc.(names.regions.global_with_copies) = regions_with_copy_nodes;
end