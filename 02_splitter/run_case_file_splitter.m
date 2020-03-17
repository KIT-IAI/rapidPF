function mpc_out = run_case_file_splitter(mpc_in, connection_table, names)
% run_case_file_splitter
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

    mpc_out = add_copy_nodes(mpc_in, connection_table, names);
    mpc_out = add_copy_nodes_to_regions(mpc_out, names);
    mpc_out = split_and_makeYbus(mpc_out, names);
    mpc_out = add_consensus_information(mpc_out, connection_table, names);
    
    savecase('mpc_merge_split.m', mpc_out);
end