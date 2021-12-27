function entries = build_entries_for_problem(n_core, n_copy, mpc, local_bus_to_remove, state_dimension)  
    
    if nargin == 4
        local_bus_to_remove = [];
    end
    
    if strcmp(state_dimension,'full')  % use all the state as variables
        entries_const = build_entries(n_core, n_copy, false);
        entries_pf = build_entries(n_core, n_copy, true);
        
        entries.const = entries_const;
        entries.pf = entries_pf;
        
    elseif strcmp(state_dimension,'half')  % use half of the state as variables
         %% get entries of ref, pv, pq buses
        mpopt = mpoption;
        mpc = ext2int(mpc, mpopt);
        [~, bus, gen] = deal(mpc.baseMVA, mpc.bus, mpc.gen);

        [ref, pv, pq] = bustypes_ref(bus, gen);

        % remove copy buses
        if ~isempty(local_bus_to_remove)
            [ref, pv, pq] = remove_bus(local_bus_to_remove, ref, pv, pq);
        end

        % create a aux list 
        n_bus = n_core + n_copy;

        bus_entries = (1: n_bus);
        core_entries = (1: n_core);

        % get the corresponding entries
        v_ang_const = ref;
        v_mag_const = setdiff(core_entries, pq);
        p_net_const = setdiff(core_entries, ref);
        q_net_const = pq';

        v_ang = setdiff(bus_entries, ref);
        v_mag = setdiff(setdiff(bus_entries, ref), pv);
        p_net = ref;
        q_net = setdiff(core_entries, pq);

        %% set to the structure
        % entries of constants
        entries.constant.ref = ref;
        entries.constant.pv = pv;
        entries.constant.pq = pq;

        entries.constant.v_ang = v_ang_const;
        entries.constant.v_mag = v_mag_const;
        entries.constant.p_net = p_net_const;
        entries.constant.q_net = q_net_const;

        entries.constant.v_ang_global = v_ang_const;
        entries.constant.v_mag_global = v_mag_const+n_bus;
        entries.constant.p_net_global = p_net_const+2*n_bus;
        entries.constant.q_net_global = q_net_const+2*n_bus+n_core;
        entries.constant.stack = [v_ang_const  v_mag_const+n_bus  p_net_const+2*n_bus  q_net_const+2*n_bus+n_core];

        % entries of variables
        entries.variable.v_ang = v_ang;
        entries.variable.v_mag = v_mag;
        entries.variable.p_net = p_net;
        entries.variable.q_net = q_net;
        entries.variable.stack = [v_ang   v_mag+n_bus   p_net+2*n_bus   q_net+2*n_bus+n_core];

        % entries of all states
        entries.v_ang = (1: n_bus);
        entries.v_mag = entries.v_ang + n_bus;
        entries.p_net = (1: n_core) + 2*n_bus;
        entries.q_net = entries.p_net + n_core;

        %% get entries of different types of variables in half state
        n_vang_var = numel(entries.variable.v_ang);
        n_vmag_var = numel(entries.variable.v_mag);
        n_pnet_var = numel(entries.variable.p_net);
        n_qnet_var = numel(entries.variable.q_net);

        entries_vang_half = (1:n_vang_var);
        entries_vmag_half = (1:n_vmag_var) + n_vang_var;
        entries_pnet_half = (1:n_pnet_var) + n_vang_var + n_vmag_var;
        entries_qnet_half = (1:n_qnet_var) + n_vang_var + n_vmag_var + n_pnet_var;

        % set to structure
        % entries of variables in half state
        entries.half.v_ang = entries_vang_half;
        entries.half.v_mag = entries_vmag_half;
        entries.half.p_net = entries_pnet_half;
        entries.half.q_net = entries_qnet_half;

        %% create entries for stack constant and variables
        % get the correct order 
        [~, v_ang_order] = sort([v_ang v_ang_const]);
        [~, v_mag_order] = sort([v_mag v_mag_const]);
        [~, p_net_order] = sort([p_net p_net_const]);
        [~, q_net_order] = sort([q_net q_net_const]);

        % set to structure
        entries.back_to_state.va_order = v_ang_order;
        entries.back_to_state.vm_order = v_mag_order;
        entries.back_to_state.p_order = p_net_order;
        entries.back_to_state.q_order = q_net_order;
        
        %% create entries of each part from full state
        entries_const = build_entries(n_core, n_copy, false);
        entries_pf = build_entries(n_core, n_copy, true);
        
        entries.const = entries_const;
        entries.pf = entries_pf;
    end
end

%% local functions
function [ref, pv, pq] = remove_bus(bus, ref, pv, pq)
    ref = setdiff(ref, bus);
    pv = setdiff(pv, bus);
    pq = setdiff(pq, bus);
end

%% build local entries for full state case
function entries = build_entries(N_core, N_copy, with_core)
    if with_core
        N = N_copy;
    else
        N = 0;
    end
        
    entries = cell(4, 1);
    dummy = { 1:N+N_core, 1:N+N_core, 1:N_core, 1:N_core };
    nums = kron([N_core + N_copy; N_core], ones(2, 1));
    nums_cum = [0 ; cumsum(nums)];
    for i = 1:4
        entries{i} = dummy{i} + nums_cum(i);
    end
end



