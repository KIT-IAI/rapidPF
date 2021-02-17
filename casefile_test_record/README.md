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
