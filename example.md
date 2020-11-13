# Example
This is a beginning-to-end-example about how to solve distributed power flow with [the Aladin toolbox](https://github.com/alexe15/ALADIN.m).
[Click here](#entire-code) to see the plain code.

## Setup
Starting from the home directory of the package, let's make a tabula rasa and switch to the use case folder

```matlab
clear all; close all; clc;
cd('00_use-case')
```

If not done already, add the source files to the path

```matlab
addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));
```

We would like the following fields to be merged from the case files

```matlab
fields_to_merge = {'bus', 'gen', 'branch'};
```

## Specify inputs

We first generate a name struct that acts as a de-facto global variable for naming structs.

```matlab
names = generate_name_struct();
```

Next, we specify the master and worker systems by loading their case files.

```matlab
mpc_master  = loadcase('case14');
mpc_workers = { loadcase('case30'); loadcase('case9')  };
```

Additionally, we need to specify *who* is connected to *whom*.
These connections are specified in a connection array:

```matlab
connection_array = [ 2 1  1 2;
                     2 3  2 3; 
                     2 3 13 1; ];
```

The first row reads: system 2 is connected to system 1, specifically the first bus of system 2 is connected to the second bus of system 1.
Likewise, the second row reads: system 2 is connected to system 3, specifically the second bus of system 2 is connected to the third bus of system 3.

However, we need not just to specify *who* is connected to *whom*, but also *how*.
Hence, we model a connecting transformer.

```matlab
trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;
```

Finally, we can call [`build_connection_table`](mfiles/01_generator/build_connection_table.md).

```matlab
conn = build_connection_table(connection_array, trafo_params);
```

## Problem formulation
Having done the setup, we are now ready to use the three main blocks: the case file generator, the case file splitter, and the case file parser:


### Case file generator
Calling the case file generator means to specify the master and the workers together with the connection table, and what fields shall be merged.
The most convenient way is to call [`run_case_file_generator`](mfiles/01_generator/run_case_file_generator.md)

```matlab
mpc_merge = run_case_file_generator(mpc_master, mpc_workers, conn, fields_to_merge, names);
```

The output is a case file that has a lot of extra information.

### Case file splitter

The output of the case file generator is the input to the case file splitter, together with connection information.
We call [`run_case_file_splitter`](mfiles/02_splitter/run_case_file_splitter.md)

```matlab
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
```

The output is, again, a case file that has a lot of extra information.

### Case file parser

Finally, the case file parser takes the output from the splitter, and generates a problem formulation, using [`generate_distributed_problem_for_aladin`](mfiles/03_parser/generate_distributed_problem_for_aladin.md).
Note that we can need to specify whether we create a `feasibility` or a `least-squares` problem formulation.

```matlab
problem = generate_distributed_problem_for_aladin(mpc_split, names, 'least-squares');
```

The problem formulation is a struct that contains all relevant equations.

Finally, we need to add a numerical solver (`fmincon`, `fminunc`, `worhp`, `Casadi+Ipopt`)

```matlab
% add a solver
problem.solver = 'fmincon';
```

## Problem solution

Having created a valid problem formulation, we rely on the [Aladin toolbox](https://github.com/alexe15/ALADIN.m) to solve the problem.
Aladin requires a set of parameters (using the default values is also possible, and usually a good idea).
We use the function [`solve_distributed_problem_with_aladin`](mfiles/03_parser/solve_distributed_problem_with_aladin.md)

```matlab
opts = struct('maxiter',50, 'solveQP','MA57');
opts.reg ='false';
opts.rho0= 1e2;

[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);
```

The function returns four outputs: `xsol_aladin` and `xsol_stack_aladin` are both cells with as many entries as there are regions.
In each entry, the state of region $i$ is stored: in `xsol_aladin` it is a matrix form with as many rows as there are buses in the region, and the four columns being the voltage angle, the voltage magnitude, the net active power, and the net reactive power; in `xsol_stack_aladin`, each entry is the vertically stacked equivalent of `xsol_aladin`.
The third output, `mpc_sol_aladin`, is a valid case file that can be used for further inspection.
The fourth output contains logging information from the Aladin toolbox.

## Comparison

How do we know that the solution we computed is actually correct?
For that purpose, there is a validation function such as [`validate_distributed_problem_formulation`](mfiles/03_parser/validate_distributed_problem_formulation.md).
Simply put, the function uses `matpower` to validate that the generated problem formulation stored in `problem` is correct.

```matlab
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);
```

The outputs have the same format as the first two outputs (`xsol_aladin` & `xsol_stack_aladin`) from the [problem solution](#problem-solution).
To compare the results we call [`compare_results`](mfiles/03_parser/compare_results.md), which generates a humand-readable `table` output.

```matlab
comparison_aladin = compare_results(xval, xsol_aladin)
```

## Post-processing

There is a handy function for post-processing,
This function provides a graphical impression of the overall constraint violations for both the power flow equations and the consensus violations.

```matlab
compare_constraints_violation(problem, logg);
```

For this example the violation of the power flow equations, the bus specifications, and the consensus constraints are shown below per Aladin iteration.

![Simulation results for example](figs/example-results.png)

## Entire code

```matlab
clear all; close all; clc;

addpath(genpath('../01_generator/'));
addpath(genpath('../02_splitter/'));
addpath(genpath('../03_parser/'));

names = generate_name_struct();
%% setup
fields_to_merge = {'bus', 'gen', 'branch'};
mpc_master  = loadcase('case14');
mpc_workers = { loadcase('case30')
             loadcase('case9')  };

connection_array = [2 1 1 2;
                    2 3 2 3; 
                    2 3 13 1;
                    ];

trafo_params.r = 0;
trafo_params.x = 0.00623;
trafo_params.b = 0;
trafo_params.ratio = 0.985;
trafo_params.angle = 0;

conn = build_connection_table(connection_array, trafo_params);

%% main
% case-file-generator
mpc_merge = run_case_file_generator(mpc_master, mpc_workers, conn, fields_to_merge, names);
% case-file-splitter
mpc_split = run_case_file_splitter(mpc_merge, conn, names);
% generate problem formulation for aladin
problem = generate_distributed_problem_for_aladin(mpc_split, names, 'least-squares');
% add a solver
problem.solver = 'fmincon';
% validate problem formulation
[xval, xval_stacked] = validate_distributed_problem_formulation(problem, mpc_split, names);

opts = struct('maxiter',50, 'solveQP','MA57');
opts.reg ='false';
opts.rho0= 1e2;

[xsol_aladin, xsol_stack_aladin, mpc_sol_aladin, logg] = solve_distributed_problem_with_aladin(mpc_split, problem, names, opts);

comparison_aladin = compare_results(xval, xsol_aladin)
compare_constraints_violation(problem, logg);
```
