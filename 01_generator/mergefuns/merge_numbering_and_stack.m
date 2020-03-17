function mpc_trans = merge_numbering_and_stack(mpc_trans, mpc_dist, fields_to_merge)
% merge_numbering_and_stack
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
    N_trans = get_number_of_buses(mpc_trans);
    % shift DS bus numbers by N_trans
    mpc_dist = shift_numbering(mpc_dist, N_trans);
    
    % stack fields from transmission system and distribution system
    for i=1:numel(fields_to_merge)
        field_name = char(fields_to_merge(i));
        mpc_trans.(field_name) = [ mpc_trans.(field_name);
                             mpc_dist.(field_name)  ];
    end
    
end
