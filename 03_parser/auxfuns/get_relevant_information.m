function [N_regions, N_buses_in_regions, N_copy_buses_in_regions, N_core_buses_in_regions] = get_relevant_information(mpc, names)
% get_relevant_information
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
    N_regions = numel(mpc.(names.regions.global));
    N_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global_with_copies));
    N_copy_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.copy_buses.global));
    N_core_buses_in_regions = cellfun(@(x)numel(x), mpc.(names.regions.global));
end