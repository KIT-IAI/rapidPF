% error when required field does not exist in casefile
function check_existence_of_field(mpc, field_name)
    assert(isfield(mpc, field_name), 'post_processing:check_existence_of_field', 'The field `%s` does not exist for struct %s', field_name, get_name_of_variable(mpc))
end