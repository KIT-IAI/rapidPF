mpc = loadcase('case3_personalized');
results_pf = runpf('case3_personalized');
results_opf = runopf('case3_personalized');

[f, df, d2f] = opf_costfcn(results_opf.x, results_opf.om);
[h, g, dh, dg] = opf_consfcn(results_opf.x, results_opf.om);

names                = generate_name_struct();
mpc.fields_to_merge = {'bus', 'gen', 'branch', 'gencost'};

mpc_temp = loadcase('case3_personalized');
mpc.trans = mpc_temp;
mpc.dist = { mpc_temp;};

mpc.connection_array = [ 1 2 3 3];

fields_to_merge      = mpc.fields_to_merge;
connection_array     = mpc.connection_array;


trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

conn = build_connection_table(connection_array, trafo_params);
Nconnections = height(conn);

%% main
% case-file-generator
mpc_merge = run_case_file_generator(mpc.trans, mpc.dist, conn, fields_to_merge, names);
mpc_split = run_case_file_splitter(mpc_merge, conn, names);

