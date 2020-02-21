# January 15, 2020

**goal: Understand high-level idea and setup of morenet-project, and how to get there**

Objective: solve distributed power flow for coupled system of transmission system + distribution systems

## Modeling assumptions
- we connect each DS to a unique generator in the TS via a transformer
- if the TS has $N_{TS}$ nodes, and if each DS_i has $N_{DS, i}$ nodes for $i = 1, \dots, d$, then the overall system is going to have $N_{TS} + N_{DS_1} + \dots + N_{DS, d}$ nodes
- if the TS has $M_{TS}$ branches, and if each DS_i has $M_{DS, i}$ branches for $i = 1, \dots, d$, then the overall system is going to have $M_{TS} + M_{DS, 1} + \dots + M_{DS, d} + d$ branches


- [ ] [check transformer modeling in matpower](https://matpower.org/docs/MATPOWER-manual.pdf)
- [x] [check out this visualizer](https://immersive.erc.monash.edu/STAC/)

## Implementation

- currently, we focus on modeling and generating reference solutions
- desired:
```matlab
mpc_TS = loadcase('casefile_transmission_system')
mpc_DS_1 = loadcase(casefile_distribution_system_1)
...
mpc_DS_n = loadcase(casefile_distribution_system_n)
mpc = generate_case_file(mpc_TS, mpc_DS_1, ..., mpc_DS_n)

% then, the following creates our reference solution
res = runpf(mpc)
```
# January 17, 2020

## Code conventions
- **one function does one thing**
- minimize the number of function arguments, e.g. `foo(mystruct)` vs. `foo(a,b,c,d,e)`
- use *speaking* function names, e.g. `get_number_of_buses()` vs. `getNbus()`
- use lowercase with underscore as separation, e.g. `get_number_of_buses()` vs. `getNumberOfBuses()`
- ideally: add an *abstract* as a function header
```matlab
% Returns the number of buses in the case file mpc
function N = get_number_of_buses(mpc)
```

vs.

```matlab
function N = get_number_of_buses()
```
- in GitLab, whenever we add a new feature to the code, we use a separate branch
- one `m`-file per function


## Todos for Xinliang & Suggestion from Xinliang
- go through code and familiarize
- write *abstracts* for the functions
- add post-processing functions for the following:
    - number of lines is correct in `mpc_merge`
    - number of buses is correct in `mpc_merge`
    - each distribution system connects to a *unique* bus in transmission system
- Suggestion
    - the branch & bus check could be carried out at the end of merge_transmission_with_distribution, which means that the check would be carried out in each merging process. Thus it could be rewrite as follwing:
      - $N_{TS} + N_{DS} = N_{mpc}$
      - $M_{TS} + M_{DS} + 1 = M_{mpc}$
## Quetions & Bug report % Suggestion from Xinliang
- Questions
  - assumption(?): replaced generators in distribution would operate with maximal power
   - findfuns\replace_generator (41st - 42nd lines)
  - if dis_connection_bus is not ref in TS, would it work as PV after connection?
    - mergefuns\replace_slack_and_generators
    - in else case, both generators have been deleted
- Bug report
  - adjust voltage magnitude in Bus_Data after the relevent information deleted from GEN_Data
    - mergefuns\replace_generator (52nd line)
    - error test: trans_connection_bus = 2; dis_2_connection_bus =3;

# January 20, 2020

## Todos for Xinliang

- [x] add post-processing function to check the number of generators in `mpc_merge`.
    - If there are $N_{gen,TS}$ generators in transmission and $N_{gen,DS}$ generators in distribution, and if there are $N_{gen,DS,trasfo}$ generators connected to the bus, which is connected with transformer after merging, then the expected number of generators in `mpc_merge` is supposed to be:
      - $N_{gen,mpc} = N_{gen,TS} + N_{gen,DS} - N_{gen,DS,trasfo}$


# January 21, 2020

## Todos for Xinliang

##### Verification testing for errorfuns:

Idea is to create some (false) cases for example in [verification_test_for_errorfuns.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/verification_test_for_errorfuns.m), without modifying the codes in core functions.

  - [x] [check_baseMVA_between_mpc.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_baseMVA_between_mpc.m): Different baseMVA values between transmission and distribiution
    - Examples:
        1. `mpc_trans.baseMVA = 150;`      or
        2. `mpc_dist{1}.baseMVA = 120;`        

  - [x] [check_baseMVA_within_mpc.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_baseMVA_within_mpc.m): Different baseMVA in GEN_Data
    - Examples:
        1. `mpc_trans.gen(1,MBASE) = 120;` or
        2. `mpc_dist{1}.gen(1,MBASE) = 120;`

    - Problem: check function only carried out for the entry generators in distribution

    - Suggestion: global check

  - [x] [check_bus_type.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_bus_type.m): The new bus type after merging is incorrect

    - Question: no necessary? The error in current version won't happen in any cases.

  - [x] [check_connection.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_connection.m): Transformer is connected to a non-generator bus in transmission /  distribution
    - Examples:
      1. `trans_connection_buses = [ 4; 3 ];` or
      2. `dist_connection_buses = [4, 1];`

  - [x] [check_existence_of_field.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_existence_of_field.m) the relevent field doesn't exist
    - Examples:
      1. `mpc_trans = rmfield(mpc_trans, 'branch');` or
      2. `mpc_trans.branch = [];`
    - Problem:  [create_skeleton_mpc.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/verification_test_for_errorfuns.m#L72) is carried out before check function
    - Suggestion:
      1. global verification for data integrality at the beginning
      2. also check if the field is empty (?)

   - [x] [check_number_of_buses.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_number_of_branches.m), [check_number_of_branches.m]() and [check_number_of_generators.m]():  The number of buses / branches / generators in combined `mpc_merge` is not as expected.
     - Verfication testing not possible without codes modification in core functions.

   - [x] [check_out_of_sevice.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_out_of_service.m): generators out-of-serve when data in column 7th in GEN_Data <0
     - Examples:
       1. `mpc_trans.gen(1,GEN_STATUS)=-1;`
       2. `mpc_dist{1}.gen(2,GEN_STATUS)=-1;`
     - Question(?): only carried out for entry generators in distribiution
   - [x] [check_sizes_of_input.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_sizes_of_input.m): Dimensions of Input data are incompatible
     - Examples:
       1. `dist_connection_buses = [1];` or
       2. `trans_connection_buses = [1];`
       3. `mpc_dist = mpc_dist{1};`
   - [x] [check_unique_generators_connection.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_unique_generator_connection.m): check whether several distribution systems connected to a generator-bus in transmission system
     - Example: `trans_connection_buses = [2;2];`

   - [x] [check-voltage_magnitudes.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/verification_testing_for_errorfuns/fun/errorfuns/check_voltage_magnitudes.m)
     - Question: `range(mpc.gen(gen_entries, VG)) == 0 `?

##### Suggestion #####
  - create some global check m-files, `check_post_processing.m` and `check_data_integrality.m` for example, and add the error functions as sub-function in these m-files, in which the total number of m-files in \fun\errorfuns would be decreased.

**Anwer: yes, just call them `pre_processing()` and `post_processing`**

# January 24, 2020
## Todos for Xinliang
#### Pre-/Post-processing check
- Create 3 m-files:
  - [x] [global_check.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/global_check.m) for errorfuns, which should be carried out **once**
  - [x] [pre_processing.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/pre_processing.m) for errorfuns, which should be carried out **iteratively** *before* merge
  - [x] [post_processing.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/post_processing.m) for terrorfuns, which should be carried out **iteratively** *after* merge
- move the unused functions from `errorfuns` to `removed errorfuns`
- [ ] add function account for liear and quadratic cost functions [#7](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/issues/7)
#### new issues
- [check_baseMVA_within_mpc](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/pre_processing.m#L70) and [check_baseMVA_between_mpc](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/check_baseMVA_within_mpc.m#L12) share a same error message, is that OK? --> *YES*
- There are some check functions in ~~[post_processing.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/errorfuns/post_processing.m)~~ [`pre_processing`](../fun/errorfuns/pre_processing.m),  also be carried out in [replace_generator.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/pre_post_processing/fun/mergefuns/replace_generator.m#L36) after merge. It means that those check functions, `check_out_of_sevice` and `check_baseMVA_within_mpc` are called to check a same system **twice**, I.e after merge in **k** iteration and before processing in **k+1** iteration.
  - [x] move all check functions from [`replace_generator.m`](../fun/mergefuns/replace_generator.m#L36)
    - [check_power_generation_at_generators.m](../fun/terrorfuns/check_power_generation_at_generators.m) remain, waiting for modification in next step.
  - [x] make [`pre_processing.m`](../fun/errorfuns/post_processing.m) similar to [`post_processing`](../fun/errorfuns/post_processing.m) in terms of local functions
    - both become local functions in [merge_transmission_with_distribution.m](../fun/mergefuns/merge_transmission_with_distribution.m)
- [check_out_of_service(mpc_trans); check_out_of_service(mpc_dist)](../fun/../fun/mergefuns/merge_transmission_with_distribution.m#52) in `pre_processing` is equivalent to [check_out_of_sevice(mpc_merge)](../fun/../fun/mergefuns/merge_transmission_with_distribution.m#92) in `post_processing`
- [check_baseMVA_between_mpc(mpc_trans, mpc_dist)](../fun/../fun/mergefuns/merge_transmission_with_distribution.m#59) in `pre_processing` is equivalent to [check_baseMVA_within_mpc(mpc_merge)](../fun/../fun/mergefuns/merge_transmission_with_distribution.m#93) in `post_processing`
