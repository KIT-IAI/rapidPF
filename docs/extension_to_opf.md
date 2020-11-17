# Extension to Optimal Power Flow

!!! warning "Extension to optimal power flow = work in progress"
    __The documentation and code is currently being written.
    It's work in progress.__

This section deals with the extension of the morenet code to distributed optimal power flow problems.

## OPF Problem Formulation

An optimal power flow problem usually consists of a central objective function $f$ representing some sort of cost that needs to be minimized. The solution is constraint by physical properties of the system, i.e. the power flow equations still need to be satisfied as well as physical constraints of the sytem. The latter one can be thought of in all kind of details, however most opf solvers only take into account the maximum of possible real power generation of each generator.

In a nutshell, a distributed optimal power flow problem is of the form

\begin{align}
\min_{x_i, i = 1, \cdots, N} & f_i(x_i), \\
\text{ s. t. } \sum_{i = 1}^{n} A_i x_i &= 0, \\
g_i & = 0,
h_i & \leq 0
\end{align}
$$

where $N$ is the number of subsystems, $x_i \in R^{N_i}$ represent the generated power in each of the $N_i$ generators of subsystem $i$, $g_i$ are the power flow equations of each subsystem and the $h_i$ represent the physical constraints of the system. 


## Extensions to Code
A new Folder 06/opf_extension was created\
One can find several files in there. 

Firstly, in solve_MATPOWER_opf_with_ALADIN.m a few examples are given to see how to get costfunction + derivatives from MATPOWER in a form that is compatible to ALADIN

In the file opf_testfile.m, the opf solution should run, once it's ready

For opf functions, the following functions with self explanatory names were created:

create_hessian_for_cost_p.m

create_opf_cost_functions_for_p.m

create_opf_cost_gradient_for_p.m

create_opf_ineqs.m

Changes were also made to split_case_file.m -> splitted the generator costs in the same manner as generators were splitted

