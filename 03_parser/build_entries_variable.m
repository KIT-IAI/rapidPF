function entries = build_entries_variable(n_core, n_copy, mpc, local_bus_to_remove)  
    
    if nargin == 5
        local_bus_to_remove = [];
    end
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
    v_ang_known = ref;
    v_mag_known = setdiff(core_entries, pq);
    p_net_known = setdiff(core_entries, ref);
    q_net_known = pq';
    
    v_ang = setdiff(bus_entries, ref);
    v_mag = setdiff(setdiff(bus_entries, ref), pv);
    p_net = ref;
    q_net = setdiff(core_entries, pq);
    
    % set to the structure
    % entries of constants
    entries.constant.ref = ref;
    entries.constant.pv = pv;
    entries.constant.pq = pq;
    
    entries.constant.v_ang = v_ang_known;
    entries.constant.v_mag = v_mag_known;
    entries.constant.p_net = p_net_known;
    entries.constant.q_net = q_net_known;
    
    entries.constant.v_ang_global = v_ang_known;
    entries.constant.v_mag_global = v_mag_known+n_bus;
    entries.constant.p_net_global = p_net_known+2*n_bus;
    entries.constant.q_net_global = q_net_known+2*n_bus+n_core;
    entries.constant.stack = [v_ang_known  v_mag_known+n_bus  p_net_known+2*n_bus  q_net_known+2*n_bus+n_core];
    
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
end

%% local functions
function [ref, pv, pq] = remove_bus(bus, ref, pv, pq)
    ref = setdiff(ref, bus);
    pv = setdiff(pv, bus);
    pq = setdiff(pq, bus);
end



