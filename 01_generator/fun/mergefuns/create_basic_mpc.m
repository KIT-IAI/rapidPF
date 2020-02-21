function mpc = merge_basic_mpc(mpc_trans)
    global NAME_FOR_REGION_FIELD
    basic_field_names = { 'version', 'baseMVA' };
    for i = 1:numel(basic_field_names)
        field_name = char(basic_field_names(i));
        mpc.(field_name) = mpc_trans.(field_name);
    end
    
    N_trans = length(mpc_trans.bus(:,1));
    mpc.(NAME_FOR_REGION_FIELD) = { 1:N_trans };
end