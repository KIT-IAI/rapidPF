% check in interface, before the loop begin
function global_check(mpc_dist,trans_connection_buses,dist_connection_buses,trafo_params_array)
% INPUT
% mpc_dist -- case-file of distribution
% trans_connection_buses -- bus numbers for connection in transmission
% dist_connection_buses -- bus numbers for connection in distribution
% trasfo_params_array -- parameters of transformer
    check_sizes_of_input(mpc_dist, trans_connection_buses, dist_connection_buses, trafo_params_array);
    check_unique_generator_connection(trans_connection_buses);
end

% check the dimensions of case-file of distributions,
% connection in transmission,  connection in distribution and parameters of transformer
function bool = check_sizes_of_input(mpc_dist, trans_buses, dist_buses, trafo_params)
    numels = [  numel(mpc_dist);
                numel(trans_buses);
                numel(dist_buses);
                numel(trafo_params)];

    if numel(unique(numels)) == 1
        % everything is fine
        bool = true;
    else
        bool = false;
        error('Incompatible numbers of elements in input data.');
    end
end

% Ensure that each distribution system is connected to a UNIQUE generator
% in the transmission system
function bool = check_unique_generator_connection(transmission_bus_connection_array)

    if numel(transmission_bus_connection_array) == numel(unique(transmission_bus_connection_array))
        % everything is fine
        bool = true;
    else
        % trying to connect several systems to the same transmission system
        % bus
        bool = false;
        error('Trying to connect several systems to the same bus in transmission system.')
    end
        
end