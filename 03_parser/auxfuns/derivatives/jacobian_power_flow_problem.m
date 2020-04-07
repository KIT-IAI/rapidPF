function J = jacobian_power_flow_problem(va, vm, p, q, mpc)
    if nargin == 2
        assert(isstruct(vm), 'no case file provided');
        mpc = vm;
        [va, vm, p, q] = unstack_state(va);
    end

    J_pf = jacobian_power_flow(va, vm, p, q, mpc);
    J_bus = jacobian_bus_specifications(mpc);
    J = [J_pf; J_bus];
    
    n = 4*get_number_of_buses(mpc);
    has_correct_size(J, n*n);
    assert( sum(size(J) == [n, n]) == 2, 'inconsistent dimensions' )
end