% combine the params for merging
function pars = generate_merge_info(trans_bus, dist_bus, trafo_params, fields_to_merge)
% INPUT to the function
% trans_connection bus -- bus number from transmission system to which the
% transformer is connected, must be between 1 and N_trans
% dist_connection bus -- bus number from distribution system to which the
% transformer is connected, must be between 1 and N_dist
% transfo_params -- transformer/line params
% field_to_merge -- necessary fields from casefile, to be modified in merging
    pars.transformer.transmission_bus = trans_bus;
    pars.transformer.distribution_bus = dist_bus;
    pars.transformer.params = trafo_params;
    pars.fields_to_merge = fields_to_merge;
end