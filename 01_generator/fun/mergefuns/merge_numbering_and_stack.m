% start number shifting and field adding
function mpc_trans = merge_numbering_and_stack(mpc_trans, mpc_dist, fields_to_merge)
% INPUT
% mpc_trans       -- transmission casefile
% mpc_dist        -- distribution casefile
% fields_to_merge -- bus, branch, gen
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
