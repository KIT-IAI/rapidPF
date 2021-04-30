function x_local = get_local_variable_from_global_objective_variable(x_global, i_subsystem, mpc_split, names)
% get local objective variable of subsystem i from global variable of
% merged system.

N_subsystems = length(mpc_split.regions);

assert(i_subsystem <= N_subsystems, 'index of subsystem is larger then total number of subsystem');

total_number_of_nodes   = length(horzcat(mpc_split.regions{:}));
total_number_of_gens    = 0;

for i = 1 : N_subsystems
    mpc_split.split_case_files{i, 1} = prepare_case_file(mpc_split.split_case_files{i, 1}, names);
    N_gens{i} = sum(mpc_split.split_case_files{i,1}.gen(:, 8));
    total_number_of_gens = total_number_of_gens + N_gens{i};
end

% initizalize raw vectors
theta_local             = zeros(1, length(mpc_split.connections_with_aux_nodes{i_subsystem}));
V_local                 = zeros(1, length(mpc_split.connections_with_aux_nodes{i_subsystem}));
Pg_local                = zeros(1, N_gens{i_subsystem});
Qg_local                = zeros(1, N_gens{i_subsystem});


nodes_before          = 0;
gens_before           = 0;
for i = 1 : i_subsystem - 1
    nodes_before = nodes_before + length(mpc_split.regions{i});
    gens_before  = gens_before + N_gens{i};
end

% get indices corresponding to theta
for i = 1 : length(mpc_split.regions{i_subsystem})
    theta_local(i) = x_global(i + nodes_before);
end

for i = 1 : length(mpc_split.copy_buses_global(i_subsystem))
    copy_buses = mpc_split.copy_buses_global(i_subsystem);
    theta_local(length(mpc_split.regions{i_subsystem}) + i) = x_global(copy_buses{1}(i));
end

% get indices corresponding to Vm
for i = 1 : length(mpc_split.regions{i_subsystem})
    V_local(i) = x_global(i + nodes_before + total_number_of_nodes);
end

for i = 1 : length(mpc_split.copy_buses_global(i_subsystem))
    copy_buses_global = mpc_split.copy_buses_global(i_subsystem);
    V_local(length(mpc_split.regions{i_subsystem}) + i) = x_global(copy_buses{1}(i) + total_number_of_nodes);
end


% get indices corresponding to Pg
for i = 1 : length(Pg_local)
    Pg_local(i) = x_global(i + gens_before + 2*total_number_of_nodes);
end

% get indices corresponding to Qg
for i = 1 : length(Qg_local)
   Qg_local(i) = x_global(i +  gens_before + total_number_of_gens + 2*total_number_of_nodes);
end

x_local = vertcat(theta_local', V_local', Pg_local', Qg_local');

end

