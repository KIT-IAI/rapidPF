t=0;
for i = 1:20
[xsol, xsol_stacked,logg] = solve_rapidPF_aladin(problem, mpc_split, option, names);
t = t+logg.computing_time;
end
t = t/20