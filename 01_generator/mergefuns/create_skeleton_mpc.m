function mpc = create_skeleton_mpc(data, field_names, names)
% create_skeleton_mpc
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
    if iscell(data)
        mpc_in = data{1};
    elseif istable(data)
        mpc_in = data.mpc{1};
    end
    
    NAME_FOR_REGION_FIELD = names.regions.global;
    NAME_FOR_CONNECTIONS_FIELD = names.connections.global;
    NAME_FOR_CONNECTIONS_GLOBAL_FIELD = names.connections.local;
    NAME_FOR_REGION_LOCAL_FIELD = names.regions.local;
    
    fprintf('Generating skeleton case file...')
    mpc.version = '2';
    mpc.baseMVA = mpc_in.baseMVA;
    for i = 1:numel(field_names)
        field_name = char(field_names(i));
        mpc.(field_name) = mpc_in.(field_name);
    end
    mpc.(NAME_FOR_REGION_FIELD) = { [1:get_number_of_buses(mpc_in)] };
    mpc.(NAME_FOR_REGION_LOCAL_FIELD) = { [1:get_number_of_buses(mpc_in)] };
    mpc.(NAME_FOR_CONNECTIONS_FIELD) = { };
    mpc.(NAME_FOR_CONNECTIONS_GLOBAL_FIELD) = { };
    fprintf('done.\n')
end