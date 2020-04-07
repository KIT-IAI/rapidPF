mpc = ext2int(loadcase('case30'));
mpc.(names.regions.global) = 1:30;
mpc.(names.copy_buses.local) = [];
[cost, ineq, eq, x0, pf, bus_specifications, Jac] = generate_local_power_flow_problem(mpc, names, 'not_required');
%%
x = x0;
tol = 1e-10;
i = 0;

while norm(eq(x)) > tol && i < 10
    x = x - Jac(x) \ eq(x);
    norm(eq(x))
    i = i + 1;
end