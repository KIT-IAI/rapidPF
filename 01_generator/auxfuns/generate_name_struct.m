function names = generate_name_struct()
% generate_name_struct
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
    names.regions.global = 'regions';
    names.regions.global_with_copies = 'connections_with_aux_nodes';
    names.regions.local = 'regions_local';
    names.regions.local_with_copies = 'regions_local_with_copies';
    names.copy_buses.local = 'copy_buses_local';
    names.copy_buses.global = 'copy_buses_global';
    names.connections.local = 'connections_global';
    names.connections.global = 'connections';
    names.split = 'split_case_files';
    names.consensus = 'consensus';
end