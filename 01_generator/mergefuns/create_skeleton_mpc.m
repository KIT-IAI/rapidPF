% create a framework for a new casefile, I.e. mpc:
% 1. transmit only the necessary fields from TS to mpc 
% 2. create 'regions' field for mpc
function mpc = create_skeleton_mpc(data, field_names, names)
% INPUT:
% mpc_trans  -- casefile for TS
% field_name -- name for necessary fields
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