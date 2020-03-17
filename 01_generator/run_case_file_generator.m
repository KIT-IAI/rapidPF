function mpc = run_case_file_generator(mpc_master, mpc_slaves, connection_table, fields_to_merge, names)
% run_case_file_generator
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
    mpc = create_skeleton_mpc({mpc_master}, fields_to_merge, names);
    tab = connection_table;
    Ncount = get_number_of_buses(mpc_master);
    for i = 1:numel(mpc_slaves)
        fprintf('\nMerging slave system #%i\n', i);
        merge_info = generate_merge_info_from_table(i+1, tab, fields_to_merge);
        mpc = merge_systems(mpc, mpc_slaves{i}, merge_info, names);

        tab = update_connections(tab, i+1, Ncount);
        Ncount = Ncount + get_number_of_buses(mpc_slaves{i});
    end

    savecase('mpc_merge.m', mpc)
end