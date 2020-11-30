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
* [$\texttt{create\_state\_mp.m}$](#local-decision-variable)
* [$\texttt{build\_local\_dimensions.m}$](#dimensions-check-up)
* [$\texttt{build\_local\_cost\_function.m}$](#local-cost-function)
* [$\texttt{build\_local\_constraint\_function}$](#local-equality-and-inequality-constraints)
* [$\texttt{build\_local\_equalities.m}$](#local-equality-and-inequality-constraints)
* [$\texttt{build\_local\_inequalities.m}$](#local-equality-and-inequality-constraints)
* $\texttt{build\_local\_lagrangian\_function.m}$ 
* $\texttt{build\_local\_initial\_condition.m}$
* $\texttt{build\_local\_bounds.m}$
* $\texttt{create\_consensus\_matrices\_opf.m}$


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

### Corresponding function:
- [$\texttt{prepare\_case\_file.m}$](#textttprepare_case_filem)


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

### Corresponding functions
- [$\texttt{build\_local\_state.m}$](#textttbuild_local_statem)
- [$\texttt{create\_state\_mp.m}$](#textttcreate_state_mpm)

## Local cost function
To calculate the cost function for rapidOPF, the MATPOWER function [$\texttt{opf\_costfcn.m}$](https://matpower.org/docs/ref/matpower5.0/opf_costfcn.html). The call of $\texttt{opf\_costfcn(x,om)}$ returns
- the evaluation of the cost function $f$ at $x$ ( dimension $1 \times 1$)
- the evaluation of the gradient $\nabla f$ of $f$ at $x$ (dimension $\text{length}(x)\times 1$) and 
- the evaluation of the hessian matrix $\nabla^2 f$ of $f$ at $x$ (dimension $\text{length}(x) \times \text{length}(x)$)
 
with respect to the structure of $x$ illustrated above.

The results are one to one used by rapidOPF

### Corresponding function
- [$\texttt{build\_local\_cost\_function.m}$](#textttbuild_local_cost_functionm)


## Local equality and inequality constraints
To calculate the local equality and inequality constraints for rapidOPF, the MATPOWER function [$\texttt{opf\_consfcn.m}$](https://matpower.org/docs/ref/matpower5.0/opf_consfcn.html) is used. We recall the output formate of $\texttt{opf\_consfcn(x, om, Ybus, Yf(il,:), Yt(il,:), mpopt, il)}$: 
- $\texttt{h(x)}$ inequality constraints at $x$ of dim Nineq $\times 1$
- $\texttt{g(x)}$ equality constraints at $x$ of dim Neq $\times 1$
- $\texttt{dh(x)}$ transposed of the jacobian of $h$ at $x$ of dimension dim Nx $\times$ dim Nineq, i.e. 
$$
\left[ \begin{array}{ccc}
\frac{\partial h_1}{\partial x_1} & \cdots & \frac{\partial h_{ng}}{\partial x_{1}} \\ \vdots & \ddots & \vdots \\ 
\frac{\partial h_{1}}{\partial x_{nx}} & \cdots & \frac{\partial h_{ng}}{\partial x_{nx}}
\end{array}\right] 
$$
- $\texttt{dg(x)}$ transposed of jacobian of $g$ at $x$ of dimension dim Nx $\times$ dim Neq, i.e.
$$
\left[ \begin{array}{ccc}
\frac{\partial g_1}{\partial x_1} & \cdots & \frac{\partial g_{ng}}{\partial x_{1}} \\ \vdots & \ddots & \vdots \\ 
\frac{\partial g_{1}}{\partial x_{nx}} & \cdots & \frac{\partial g_{ng}}{\partial x_{nx}}
\end{array}\right] 
$$

The function handles $h, dh$ are taken as they are. For $g$, the entries of the copy buses are deleted, for $dg$, the columns corresponding to the derivatives of the power flow corresponding to the copy buses are deleted

### Corresponding functions
- [$\texttt{build\_local\_constraint\_function.m}$](#textttbuild_local_constraint_functionm)
- [$\texttt{build\_local\_equalities.m}$](#textttbuild_local_equalitiesm)
- [$\texttt{build\_local\_inequalities.m}$](#textttbuild_local_inequalitiesm)

## Consensus Matrices
As consensus matrices we call the matrices that guarantee that the voltage angles and voltage magnitudes at the copy nodes correspond to the voltage angles and magnitudes at the corresponding core nodes in their core system. Therefore, the numbers of connections between all systems are needed. The local matrices are of dimension 
$$
4*N_{connection-buses} \times \text{dim}(x_i)
$$
To fill the consensus matrix, for each system information is needed about the the indices of the local core nodes and the local copy nodes. They are given in the form of a connection table- it consists of four columns that are filled for each connection the another system for each system:
 - $\texttt{orig\_system}$ global index of core system system
 - $\texttt{copy\_system}$ global index of copy system 
 - $\texttt{orig\_bus\_loacl}$ local node index of core node that is connected to another copy node
 - $\texttt{copy\_bus\_local}$ local node index of copy node connected to the core node from column 3
Recall that 
$$
4*N_{connection-buses} \times \text{dim}(x_i) = 2 * size(connection\_table, 1)
$$
To enforce consensus, for each row $i$ of the connection table two entries are generated: 
- $A_{core}(i, core\_bus\_local) = 1$
- $A_{copy}(i, copy\_bus\_local) = -1$

We notice, that we need such a matrix not only for voltage angles but also one such matrix for voltage magnitudes, where the core_bus_entry and the copy_bus_entry need to be shifted to the column corresponding to the voltage entry of the optimization variable.

## Dimensions check up
For clarity, the dimensions of the outputs are summarized

- The dimension of the optimization vector is given by
$$\begin{aligned} 
\text{dim}(x_i) & = 2\cdot N_{busses-core} + 2\cdot N_{busses-copy} + 2\cdot N_{g-core} \\ & = 2\cdot N_{buses} + 2 \cdot N_{g-core}
\end{aligned}
$$

- The number of equality constraints is equal to 
$$\text{dim}(eq) = 2 * (N_{buses} - N_{buses-copy}) = 2*(N_{buses-core})$$, i.e. we have two equations for each core node

- The number of inequality constraints is equal to the number of non-zero entries of $\texttt{RATE\_A}$ in the branch specifications of the splitted opf case file

- The local cost functions are scalar valued, the gradients are of dimension $\texttt{length}(x) \times 1$, its Hessian is of dimension $\texttt{length}(x) \times \texttt{length}(x)$ 


## Detailed documentation of new functions

### [$\texttt{prepare\_case\_file.m}$](#preparation-of-splitted-casefile)

`[mpc_opf, om, copy_buses_local, mpopt] = prepare_case_file(mpc, names)`

_Function to prepare the rapidPF splitted casefiles for OPF. Generators at the copy nodes are switched off and gen entries and gencost entries are deleted from the $\texttt{mpc\_opf}$ file._
Input:
* $\texttt{mpc}$ - splitted rapidPF case file
* $\texttt{names}$ - struct that contains the names of the mpc file
  
Output:
* $\texttt{mpc\_opf}$ - prepared splitted rapiOPF casefile
* $\texttt{om}$ - MATPOWER optimization model of $\texttt{mpc\_opf}$ that is needed to obtain the optimization functions
* $\texttt{copy\_buses\_local}$ - vector of local copy buses
* $\texttt{mpopt}$ - standard MATPOWER opf options

Tests: 
* added sample test to 05_UI_test
* added assert to check whether there are still gen entries left in local $\texttt{mpc\_opf}$ case file.

### [$\texttt{build\_local\_state.m}$](#local-decision-variable)
`state = build_local_state(mpc, names, postfix)`

_Function to build symbolic representation of optimization variable_

Input:
 - $\texttt{mpc}$ splitted casefile
 - $\texttt{names}$ specific names of mpc struct fields
 - $\texttt{postfix}$ number of local system
  
 Output
   - $\texttt{state}$ symbolic state

 Final formate:
 $\texttt{state = (Vang; Vm; Pg; Qg)}$ (column vector) with 
 - $\texttt{Vang = [Vang\_postfix\_1; ... ; Vang\_postfix\_{\#Ncorebuses}; Vang\_postfix\_copy\_1; ... ; Vang\_postfix\_{\#Ncopybuses}]}$
 - $\texttt{Vm = [Vm\_postfix\_1; ... ; Vm\_postfix\_{\#Ncorebuses}; Vm\_copy\_postfix\_1; ... ; Vm\_postfix\_{\#Ncopybuses}]}$
 - $\texttt{Pg = [Pg\_postfix\_1; ... ; Pg\_postfix\_{\#switched-on-generators}]}$
 - $\texttt{Qg = [Qg\_postfix\_1; ... ; Qg\_postfix\_{\#switched-on-generators}]}$

### [$\texttt{create\_state\_mp.m}$](#local-decision-variable)
`[vang, vmag, pg, qg] = create\_state\_mp(postfix, Nbus, Ngen)`
 
_Subfunction of $\texttt{build\_local\_state.m}$_

Input:
 - $\texttt{postfix}$ number of local system the 
 - $\texttt{Nbus}$ number of buses
 - $\texttt{Ngen}$ umber of generators

Output:
 - $\texttt{[vang, vmag, pg, qg]}$ with 
   - $\texttt{vang = [vang\_postfix\_1; ... ; vang\_postfix\_Nbus]}$
   - $\texttt{vm = [vm\_postfix\_1; ... ; vm\_postfix\_Nbus]}$
   - $\texttt{Pg = [Pg\_postfix\_1; ... ; Pg\_postfix\_Ngen]}$
   - $\texttt{Qg = [Qg\_postfix\_1; ... ; Qg\_postfix\_Ngen]}$


### [$\texttt{build\_local\_cost\_function.m}$](#local-decision-variable)
`[cost, grad, hess] = build_local_cost_function(om)`

_Function to extract opf cost function from MATPOWER to be usable in rapidOPF_

Input: 
- $\texttt{om}$ MATPOWER optimization model

Output:
 - function handles for 
   - $\texttt{cost}$ optimization cost function 
   - $\texttt{grad}$ gradient of cost function
   - $\texttt{hess}$ hessian of cost function

### [$\texttt{build\_local\_constraint\_function.m}$](#local-equality-and-inequality-constraints)
`[constraint_function, Lxx] = build_local_constraint_function(mpc_opf, om, mpopt)`

  _returns the local constraint functions and the Lagrangian of the original problem_ 

 Input:
  - $\texttt{mpc\_opf}$ splitted and cleaned opf file
  - $\texttt{om}$ MATPOWER optimization model of $\texttt{mpc\_opf}$
  - $\texttt{mpopt}$ MATPOWER standard options
 Output: 
  - $\texttt{constraint\_functions}$ function handle for constraints and there derivatives
  - $\texttt{Lxx}$ Lagrangian function of MATPOWER for entire system including deleted equality constraints
  
### [$\texttt{build\_local\_equalities.m}$](#local-equality-and-inequality-constraints)
`[eq, eq_jac] = build_local_equalities(constraint_function, local_buses_to_remove)`

   _Extracts the relevant power flow equation for the core buses. Power flow equations of the copy buses are removed_

Input:
  - $\texttt{constraint\_function}$ vector with function handles for constraints
  - $\texttt{local\_buses\_to\_remove}$ indices of buses that were copied from neighbour system

Output:
  - $\texttt{eq}$ relevant equality constraints for 
  - $\texttt{eq\_jac}$ relevant entries of jacobian matrix

### [$\texttt{build\_local\_inequalities.m}$](#local-equality-and-inequality-constraints)

`[ineq, ineq_jac] = build_local_equalities(constraint_function, local_buses_to_remove)`

   _Extracts the relevant power flow equation for the core buses. Power flow equations of the copy buses are removed_

Input:
  - $\texttt{constraint\_function}$ vector with function handles for constraints
  - $\texttt{local\_buses\_to\_remove}$ indices of buses that were copied from neighbour system

Output:
  - $\texttt{ineq}$ relevant inequality constraints for 
  - $\texttt{ineq\_jac}$ relevant entries of jacobian matrix

### [$\texttt{build\_local\_dimensions.m}$](#dimensions-check-up)

   `dims = build_local_dimensions(mpc_opf, eq, ineq, local_buses_to_remove)`

   _creates a field of dimensions as how they should look like and uses it for testing_

   INPUT:  
   - $\texttt{mpc\_opf}$ splitted case files
   - $\texttt{eq}$ power flow equations for core nodes plus their jacbian'
   - $\texttt{ineq}$ flow limits inequality constraints plus their jacobian'
   - $\texttt{local\_buses\_to\_remove}$ copy nodes
  
   OUTPUT: 
   - $\texttt{dims}$ struct containing dimensions


### [$\texttt{create\_consensus\_matrices.m}$](#consensus-matrices)

   `A = create_consensus_matrices_opf(tab, number_of_buses_in_region, number_of_generators_in_region)`

   _creates optimal power flow consensus matrix for distributed optization_

   INPUT:
   - $\texttt{tab}$ connection table
   - $\texttt{number\_of\_buses\_in\_region}$
   - $\texttt{number\_of\_generators\_in\_region}$

  OUTPUT:
  - $\texttt{A}$ cell with consensus matrices
