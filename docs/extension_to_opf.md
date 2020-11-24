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

The main changes happen during step 3. and 4. as the cost functions, power balance equations and line flow limits are not hard coded as it is done in rapidPF but are calculated by using the internal opf functions from [MATPOWER](https://matpower.org/docs/manual.pdf).

## Extensions to existing Code
New files:

* $\texttt{generate\_distributed\_opf.m}$
* $\texttt{create\_consensus\_matrices\_opf.m}$
* $\texttt{build\_local\_opf.m}$
* [$\texttt{prepare\_case\_file.m}$](#textttprepare_case_filem)
* [$\texttt{build\_local\_state.m}$](#local-decision-variable)
* $\texttt{create\_state\_mp}$
* $\texttt{build\_local\_dims.m}$
* $\texttt{build\_local\_cost\_functon.m}$
* $\texttt{build\_local\_equalities.m}$
* $\texttt{build\_local\_inequalities.m}$
* $\texttt{build\_local\_lagrangian\_function.m}$ 
* $\texttt{build\_local\_initial\_condition.m}$
* $\texttt{build\_local\_bounds.m}$


## Preparation of splitted Casefile
The RapidPF splitted casefiles consist of the following fields:
*  $\texttt{baseMVA}$
*  $\texttt{bus}$
*  $\texttt{gen}$
*  $\texttt{branch}$
*  $\texttt{regions}$
*  $\texttt{connections\_with\_aux\_nodes}$
*  $\texttt{copy\_bues\_global}$
*  $\texttt{copy\_buses\_local}$

Additionally to these fields, the field - if existing in the original case file -
* $\texttt{gencost}$
  
is transferred by an extension located in the file $\texttt{split\_case\_file.m}$. The field contains costs for any generator that occurs in the field $\texttt{gen}$.

To use the functions provided by [MATPOWER](https://matpower.org/docs/manual.pdf) we need to know its structure of its objective variables. MATPOWER's optimization vector $x$ for the standard AC OPF proble consists of the $n_b \times 1$ vectors of voltage angles $\Theta$ and magnitudes $V_m$ and the $n_g \times 1$ vectors of generator real and reactive injections $P_g$ and $Q_g$, i.e. 
$$x = \left[ \begin{array}{c}
\Theta \\ V_m \\ P_g \\Q_g
\end{array}\right] $$
Here, $n_b$ corresponds to the number of buses in the system and $n_g$ corresponds to the number of generators in the system.

At this point we need to be careful as the fields $\texttt{gen}$ and $\texttt{gencost}$ also do contain the generators at the copy nodes that shall not have any impact on the local objectives. Switching them of in the casefile as it is done in the function $\texttt{prepare\_case\_file}$ leads them in MATPOWER to be treated as non existing, thus giving us the wanted effect. 

### $\texttt{prepare\_case\_file.m}$
Function to prepare the rapidPF splitted case for OPF. Generators at the copy nodes are switched off and gen entries and gencost entries are deleted from the $\texttt{mpc\_opf}$ file.
Input:
* $\texttt{mpc}$ - splitted rapidPF case file
* $\texttt{names}$ - struct that contains the names of the mpc file
  
Output:
* $\texttt{mpc\_opf}$ - splitted rapidOPF case file
* $\texttt{om}$ - MATPOWER optimization model of $\texttt{mpc\_opf}$ that is needed to obtain the optimization functions
* $\texttt{mpc\_opf}$ - prepared rapiOPF casefile
* $\texttt{copy\_buses\_local}$ - vector of local copy buses
* $\texttt{mpopt}$ - standard MATPOWER opf options

Tests: 
* added sample test to 05_UI_test
* added assert to check whether there are still gen entries left in local $\texttt{mpc\_opf}$ case file.

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
