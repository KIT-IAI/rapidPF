function mpc = add_region_information(mpc, N_currently, N_to_add, names)
% add_region_information
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
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_REGION_LOCAL_FIELD = names.regions.local;
    
    N_regions = length(mpc.(NAME_FOR_REGION_FIELD));
    mpc.(NAME_FOR_REGION_FIELD){N_regions + 1} = (1:N_to_add) + N_currently;
    mpc.(NAME_FOR_REGION_LOCAL_FIELD){N_regions + 1} = 1:N_to_add;
end