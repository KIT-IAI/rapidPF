% error when the bus type is neither PQ nor PV
function check_bus_type(bus_type)
    if length(bus_type) ~= length('pq') || length(bus_type) ~= length('pv')
        error('Unknown bus type `%s`', bus_type);
    end
end