function J = jacobian_bus_specifications(mpc, buses_to_ignore)
    mpc = ext2int(mpc);
    if nargin == 1
        buses_to_ignore = [];
    end
    [PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;


    n = get_number_of_buses(mpc);
    ncopy = numel(buses_to_ignore);
    ncore = n - ncopy;
    
    bus_numbers = setdiff(mpc.bus(:, BUS_I), buses_to_ignore);
    
    
    bus_types = mpc.bus(bus_numbers, BUS_TYPE);
    assert(max(bus_numbers) <= n, 'no valid 1:N indexing');
    
    J = cell(ncore, 1);
    J(:) = { sparse(2, 4*n) };
    
    for i = 1:ncore
        switch bus_types(i)
            case REF
                J_bus = jacobian_slack;
            case PV
                J_bus = jacobian_pv;
            case PQ
                J_bus = jacobian_pq;
        end
        e = sparse(1, n);
        e(i) = 1;
        J{i} = kron(J_bus, e);
    end
    J = cell2mat(J);
    % remove columns corresponding to copy node entries for P and Q
    J = remove_copy_entries_for_P_and_Q(J, ncore, ncopy);
end

function J = remove_copy_entries_for_P_and_Q(J, ncore, ncopy)
    cols = [3; 4]*ncore + [2; 3]*ncopy + (1:ncopy);
    J(:, cols) = [];
end

function J = jacobian_slack()
    cols = [1, 2];
    J = build_J(cols);
end

function J = jacobian_pv()
    cols = [3, 2];
    J = build_J(cols);
end

function J = jacobian_pq()
    cols = [3, 4];
    J = build_J(cols);
end

function J = build_J(cols)
    assert(numel(cols) == 2);
    J = sparse(2, 4);
    J(1, cols(1)) = 1;
    J(2, cols(2)) = 1;
end


