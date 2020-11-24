# RapidOPF - Extension to Optimal Power Flow

<!--!!! warning "Extension to optimal power flow = work in progress"
    __The documentation and code is currently being written.
    It's work in progress.__-->

This section deals with the extension of the rapidPF project to distributed optimal power flow problems.

## OPF Problem Formulation
An optimal power flow problem usually consists of a central objective function $f$ representing some sort of cost that needs to be minimized. The solution is constraint by physical properties of the system, i.e. the power flow equations still need to be satisfied as well as physical constraints of the sytem. The latter one can be thought of in all kind of details, however most opf solvers only take into account the maximum of possible real power generation of each generator.

In a nutshell, a distributed optimal power flow problem is of the form
$$
\begin{aligned}
\min_{x_1, \cdots, x_N} & \sum_{i = 1}^N f_i(x_i), \\
 \text{ s. t. } &  \sum_{i = 1}^{N} A_i x_i = 0, \\
& \quad \ \ g_i(x_i) = 0 \quad \quad \text{ for }i = 1 ,\cdots, N\\
& \quad \ \ h_i(x_i) \leq 0 \quad \quad \text{ for }i = 1 ,\cdots, N
\end{aligned}
$$
with
* $N \ \ :$ number of subsystem 
* $N_{g_i}:$ number of equality constraints in subsystem $i$
* $N_{h_i}:$ number of inequality constraints in subsystem $i$
* $x_i \ \ :$ objective variable of subsystem $i$ 
* $x = (x_1, \cdots, x_n):$ objective variable of global system

## Subsumption in RapidPf
As rapidOPF is an extension to rapidPF both version share the same basis of code. Roughly speaking, the code of rapidPF consists out of four main parts, namely 
1.  Generaton of the case file of the merged system
2.  Splitting of the merged casefile into subcasefiles
3.  Setting up the distributed power flow problem for ALADIN
4.  Solving the distribted problem with ALADIN

Steps 1. and 2. almost do not change at all despited for extending the merged and splitting casefiles by the field 'gencost'. 

The main changes happen during step 3. and 4. as the cost functions, power balance equations and line flow limits are not hard coded as it is done in rapidPF but are calculated by using the internal opf functions from MATPOWER.

## Extensions to Code
New files:

* [$\texttt{prepare\_case\_file.m}$](#preparation-of-splitted-casefile)
* [$\texttt{build\_local\_state.m}$](#local-decision-variable)
* $\texttt{build\_local\_dims.m}$
* $\texttt{build\_local\_cost\_functon.m}$
* $\texttt{build\_local\_equalities.m}$
* $\texttt{build\_local\_inequalities.m}$
* $\texttt{build\_local\_lagrangian\_function.m}$ 
* $\texttt{build\_local\_initial\_condition.m}$
* $\texttt{build\_local\_bounds.m}$



## Preparation of splitted Casefile
## Local Decision Variable
Each system has a local decision variable. We need the following values:
* $N_b$ number of buses in splitted system
* $N_{b-core}$ number of core-buses in splitted system
* $N_{b-copy}$ number of copy-busus in splitted system
* $N_{g-core}$ number of core-generators in spliited system 
  
Then $x_i$ writes as 
$$x_i = (\theta_i^{core}, \theta_i^{copy}, Vm_i^{core}, Vm_i^{copy}, Pg_i^{core}, Qg_i^{core})^\top$$
with 
* $\theta_i^{core}$  voltage angles at the core buses with $| \theta_i^{core} | = N_{b-core}$
* $\theta_i^{copy}$  voltage angles at the copy buses with $| \theta_i^{copy} | = N_{b-copy}$
* $Vm_i^{core}$ voltage magnitudes at the core buses with $|Vm_i^{core}| =  N_{b-core}$
* $Vm_i^{copy}$ voltage magnitudes at the copy buses with $|Vm_i^{copy}| =  N_{b-copy}$
* $Pg_i^{core}$ active powers at all generators placed at the core nodes with $|Pg_i^{core}| =  N_{g-core}$
* $Qg_i^{core}$ reactive powers at all generators placed at the core nodes with $|Qg_i^{core}| =  N_{g-core}$ 

Thus the total dimension of $x_i$ is
$$\begin{aligned} 
\text{dim}(x_i) & = 2\cdot N_{b-core} + 2\cdot N_{b-copy} + 2\cdot N_{g-core} \\ & = 2\cdot N_b + 2 \cdot N_{g-core}
\end{aligned}
$$   
