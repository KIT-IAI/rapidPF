## Sensitivities

This section shows how the power flow sensitivities can be used.

All gradient-based optimization methods require sensitivities.
By *sensitivities* we mean one (or all) of the following:

    - gradients,
    - Jacobians, and/or
    - Hessians.

Broadly speaking, there are three ways to obtain sensitivities:

    - symbolically,
    - numerically,
    - by automatic differentiation,

with each method having its own pros and cons.
The case file parser does not just provide the mathematical [problem formulation](problem-formulation.md) in terms of function handles, but also sensitivities.

## Computation

!!! note "Naming for sensitivities"
    The naming of the sensitivities is inspired by the naming conventions from [Aladin](https://github.com/alexe15/ALADIN.m/)

Letting `problem` be the output of the case file parser, you find it has an entry `sens`

```matlab
>> problem.sens

ans = 

  struct with fields:

      gg: {3×1 cell}
    JJac: {3×1 cell}
      HH: {3×1 cell}
```

which has again three entries.
The following tables gives some background information.

| Entry | Meaning | Definition | Exact
| --- | --- | --- | --- |
| `gg` | Gradient of each local cost function ([see Algorithm 1 here](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8450020)) | $\nabla f_i(x_i)$ (zero for power flow problems)| Yes |
| `JJac` | Jacobian of each local power flow problem | $J_{g_i}(x_i, z_i)$ where $g_i(x_i, z_i) = \begin{bmatrix} g^{\text{pf}}_i( x_i, z_i ) \\ g^{\text{bus}}_i ( x_i )) \end{bmatrix}$ | Yes |
| `HH` | Hessian of each local problem for Aladin problem formulation ([see Algorithm 1 here](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=8450020))| $\nabla^2 B_i$ with $B_i = f_i(x_i) + \kappa_i^\top g_i(x_i, z_i)$, where $\kappa_i$ are the Lagrange multipliers w.r.t. the equality constraints $g_i$ | No |

The Hessian is computed numerically using central differences per default.

These sensitivities should be supplied to numerical solvers to increase both accuracy and speed.

!!! note "Where sensitivities are computed"
    The sensitivities are computed in the file `generate_local_power_flow_problem.m`.

## Example

Suppose we are interested in *power flow* for a single-region problem, i.e. a traditional non-distributed setup.
Then, we know that we can just apply Newton's method, for which we need both the equality constraints that specify the power flow problem, and its Jacobian.
So, purely for cross validation, let's solve a power flow problem using the information the case file splitter provides.

```matlab
mpc = ext2int(loadcase('case30'));
mpc.(names.regions.global) = 1:30;
mpc.(names.copy_buses.local) = [];
[cost, ineq, eq, x0, pf, bus_specifications, Jac] = generate_local_power_flow_problem(mpc, names, 'not_required');
```

Lines 2 and 3 are needed purely for code convention routines: they introduce a sense of global numbering, and specify *no* neighors.
The last line calls the case file parser which returns the Jacobian.
Running a prototypical Newton scheme is then straightforward

```matlab
x = x0;
tol = 1e-10;
i = 0;

while norm(eq(x)) > tol && i < 10
    x = x - myjac(x) \ eq(x);
    norm(eq(x))
    i = i + 1;
end
```
Letting this run in a file `test_jacobian.m`, we get the following output.

```matlab
>> test_jacobian

ans =

    0.0335


ans =

   1.1689e-04


ans =

   1.6313e-09


ans =

   2.1533e-14
```






