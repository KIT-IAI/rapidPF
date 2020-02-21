% create a framework for a new casefile, I.e. mpc:
% 1. transmit only the necessary fields from TS to mpc 
% 2. create 'regions' field for mpc
function mpc = create_skeleton_mpc(mpc_trans, field_names)
% INPUT:
% mpc_trans  -- casefile for TS
% field_name -- name for necessary fields
    global NAME_FOR_REGION_FIELD NAME_FOR_CONNECTIONS_FIELD NAME_FOR_CONNECTIONS_GLOBAL_FIELD
    fprintf('Generating skeleton case file...')
    mpc.version = '2';
    mpc.baseMVA = mpc_trans.baseMVA;
    for i = 1:numel(field_names)
        field_name = char(field_names(i));
        mpc.(field_name) = mpc_trans.(field_name);
    end
    mpc.(NAME_FOR_REGION_FIELD) = { [1:get_number_of_buses(mpc_trans)] };
    mpc.(NAME_FOR_CONNECTIONS_FIELD) = { };
    mpc.(NAME_FOR_CONNECTIONS_GLOBAL_FIELD) = { };
    fprintf('done.\n')
end