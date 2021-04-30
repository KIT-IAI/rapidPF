mpc = loadcase('case3_personalized');
results_pf = runpf('case3_personalized');
results_opf = runopf('case3_personalized');

[f, df, d2f] = opf_costfcn(results_opf.x, results_opf.om);
[h, g, dh, dg] = opf_consfcn(results_opf.x, results_opf.om);


%%%%%%%%%%%%%%

mpc = loadcase('case5');
results_pf = runpf('case5');
results_opf = runopf('case5');

[f, df, d2f] = opf_costfcn(results_opf.x, results_opf.om);
[g, h, dg, dh] = opf_consfcn(results_opf.x, results_opf.om);

%%%%%%%%%%%%%%%

%% setup
names                = generate_name_struct();
mpc.fields_to_merge = {'bus', 'gen', 'branch', 'gencost'};

mpc_temp = loadcase('case5');

mpc.trans = mpc_temp;
mpc.dist = { mpc_temp};

mpc.connection_array = [ 1 2 1 5];


% connected a from generator to a to generator with much higher Pmax 
%% 

% [mpc_trans,mpc_dist] = gen_shift_key(mpc, gsk); % P = P * 0.2
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

split_file_1  = mpc_split.split_case_files{1, 1};
split_file_2 = mpc_split.split_case_files{2, 1};

problem = generate_distributed_opf_for_aladin(mpc_split, names, 'feasibility');

mpopt = mpoption('out.lim.all', 2, 'opf.return_raw_der', 1);
result_opf = runopf(mpc_merge, mpopt);
[f, df, d2f] = opf_costfcn(result_opf.x, results_simple.om);
[h, g, dh, dg] = opf_consfcn(results_opf.x, results_simple.om);

x = result_opf.x;
x1 = vertcat(x(1:5), x(10), x(11:15), x(20), x(21:25), x(30:34));
x2 = vertcat(x(1), x(6:10), x(11), x(16:20), x(26:29), x(35:38));

fx1 = problem.locFuns.ffi{1}(x1);
fx2 = problem.locFuns.ffi{2}(x2);

diff_f = result_opf.f - (fx1 + fx2);

gx1 = problem.locFuns.ggi{1}(x1);
gx2 = problem.locFuns.ggi{2}(x2);

mpopt = mpoption('out.lim.all', 2, 'opf.return_raw_der', 1);
results_simple = runopf('case5', mpopt);

[f, df, d2f] = opf_costfcn(results_simple.x, results_simple.om);
[h, g, dh, dg] = opf_consfcn(results_simple.x, results_simple.om);
