function generate_opf_for_aladin(mpc, names)


[N_regions, N_buses_in_regions, N_copy_buses_in_regions, ~] = get_relevant_information(mpc_split, names);
    connection_table = mpc.(names.consensus);

consensus_matrices = create_consensus_matrices(connection_table, N_buses_in_regions, N_copy_buses_in_regions);

for i = 1;
bus_data_idx    =   {}
baseMVA         =   mpc.baseMVA;              % 功率缩放
genNodes        =   mpc.gen(:,1);             % 发电机的bus
genCost         =   mpc.gencost(:,5:end);     % objective coefficients

Pgmin           =   mpc.gen(:,10)/baseMVA;
Qgmin           =   mpc.gen(:,5)/baseMVA;
Pgmax           =   mpc.gen(:,9)/baseMVA;
Qgmax           =   mpc.gen(:,4)/baseMVA;

Pd              =   mpc.bus(:,3)/baseMVA;   
Qd              =   mpc.bus(:,4)/baseMVA;  

end
