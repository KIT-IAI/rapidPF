function [vang, vmag, pnet, qnet] = create_initial_condition(mpc, copy_buses)
    if nargin == 1
        copy_buses = [];
    end
    [vang, vmag, pnet, qnet] = extract_results(mpc);
    
    if ~isempty(copy_buses)
        pnet(copy_buses) = [];
        qnet(copy_buses) = [];
    end
end