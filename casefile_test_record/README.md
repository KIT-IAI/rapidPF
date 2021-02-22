### 12-02-2021

- GSK definition

  - GSK parameter d2scribes the percent of generation shifted from transmission system(s) to distribution system


- principle of selecting connection bus

  - transmission system

    - NOT slack bus

    - NOT gen-bus with high real power

      - normally, distribution systems do not connect to a generator directly

  - distribution system

    - NOT gen-bus with high real power

      - Otherwise might lead to *infeasibility*


- 53-bus system

  - in transmission region, slack bus cannot be selected as connection point

  - multiple connections between regions are possible

  - connection between 2 distribution is possible

  - max gsk of both case (53-I and 53-II) can reach 1

    - all generation in distributions are shifted to transmission

    - there is no significant different result between 2 test cases (computing time, iteration)


- 418-bus system

  - 5 test cases with 1, 3, 5, 8, 10 connections


- ALADIN-$/alpha$ issue

  - lack a terminate condition

  - based on CasADi, even using other solvers

### 15-02-2021

- 1654-bus system (1356+300)

  - 10 test cases with 1,3,5,8,10,12,16,20,25,30 connections


- Large-scale subsystem issue (Bus number > 1000)

  - for the subsystem, it takes too long to converge

  - 1654-30 case faces converge issues (ALADIN / solver)

    - problem fixed by releasing lower and upper boundary,i.e., `lb` and `ub` for active and reactive power.


- Issue with merging subsystems: how to merging them in a more `nature` way

### 16-02-2021

- 2708-bus system (1354X2)

  - When number of buses increases, convergence speed slow down near optimum. Some time singular warning occurs during QP-step.

    - Singular? Hessian regularization?

- 4662-bus systems

  - difference convergence rate (because of local solver?)

- post-dataprocessing

  - Region Topology with Power flow among them

  - active power of regions

### 17-02-2021

- 2708-bus system (1354X2)

  - 30 connection, 70% generation shifted to transmission

  - local solver too slow for large region (bus number in subsystem > 1000)

    - F-count increases dramatically at some iterations

    - info by fmincon: Feasible point with lower objective function value found.
>fmincon encountered a feasible point with a lower objective value than the final point. This includes the case where the final point is infeasible, in which case the final objective function value is not relevant. Feasible means that the maximum infeasibility is less than the ConstraintTolerance option.

        Link: https://de.mathworks.com/help/optim/ug/obtain-best-feasible-point.html

    - tuning the lower and the upper boundaries of active-/reactive power would improve convergence rate. Reason remains unknown.

- ALADIN idea:

  for larger cases, initial point of local step is the optimum. For these cases, no need to call solver at local step. As a result, it would save total computing time.

### 18-02-2021

- 4068-bus system (1354X3)

 - 70% with TSO-DSO conection, 80% with additional DSO-DSO connections


- 4668-bus system (1354X3+300X2)

### 19-02-2021

- 4662-bus system test

 - 50% active power in distribution can be shifted

 - new issue with 4662 case

  - compare the result with ref solution, error = 6.289

    - angle variables are not in [-pi, pi]

  - post-dataprocessing lacks the last iteration

### 22-02-2021

  - solve the issue, angle variables now lay in [-pi, pi]

  - ALADIN Toolbox does not compute consensus violation at last iteration

    - reason - violation = `0`, the value cannot be plotted by logplot.

    - solution - using `eps` to replace `0`

  - start running and recording all test case with different GSK parameter
