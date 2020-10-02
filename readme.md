[![pipeline status](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/morenet/badges/master/pipeline.svg)](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/morenet/commits/master)
[![documentation](https://img.shields.io/badge/docs-stable-blue)](http://iai-webserv.iai.kit.edu/morenet/)


# Morenet - Documentation

[__The official documentation can be found here.__](http://iai-webserv.iai.kit.edu/morenet/)


# Status quo

With the recent [release](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/morenet/-/tags/v0.0.3) we have taken a significant leap: it is now possible to solve a distributed power flow problem with Aladin but *without* Casadi.
To do that, we had to create a [separate branch](https://github.com/alexe15/ALADIN.m/tree/abstractify) in the Aladin repository that works independently of Casadi.
So what can we do now currently?

   - Documentation
      - There is a [documentation](http://iai-webserv.iai.kit.edu/morenet/) available.
      - To build the documentation locally [mkdocs](https://mkdocs.org/) needs to be installed. (#19)
   - Problem formulation
      - No symbolic problem formulation. #10
      - The systems can be connected arbitrarily. There is one exception: multiple connections between identical buses are not supported. (#6, #9, #12, #13)
      - No HVDC lines are supported. (#17)
   - Algorithms
      - Aladin
         - Casadi + Ipopt work out of the box
         - fmincon + user-provided sensitivities work; switch to [separate branch](https://github.com/alexe15/ALADIN.m/tree/abstractify) in the Aladin repository (#21)
      - ADMM
         - Investigated thoroughly by @uthgg with not-so-positive outcome, see #16.
         - In short, ADMM converges quickly to the vicinity of *some* local minimum, and then takes a long time to converge. Additionally, the convergence is not to the *correct* minimizer.
         - Hence, __ADMM will not receive any further focus.__
   - Problem formulation, see [this report](/docs/morenet_report_xinliang.pdf) for further details.
      - Feasibility problem
        - currently CasADi, fmincon andd WORHP work fine in feasibility problem, Ipopt still need to be tested
        - all three solvers only work properly with small-to-medium size problem. When problem size becomes increasely large, it would results in a convergence problem.
        - using limit-memory BFGS to approximate Hessian       
      - Least-squares problem
        - fmincon, fminunc, WORHP work fine in least-squares problem. CasADi facing problem when implemented in least-squares problem, see #33.
        - fmincon and WORHP are able to handle large-scale problem, i.e. with 4k+ nodes. Computing time of fminunc increases dramatically, when the nodes number of local regions reach 1k.
        - using Jacobian to approximate Hessian in least-squares forumlation, see [#26](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/morenet/-/issues/26#note_1196) here. It is much faster that limit-memory BFGS and finite-difference.


![](Alg_tree.jpg)


# Next steps
   - Documentation
      - Continue to fill.
   - Problem solution
      - Play with different test systems and characterized convergence properties.
      - [Interface ipopt directly from Matlab](https://projects.coin-or.org/Ipopt/wiki/MatlabInterface) to have another solver to test against. Hopefully, this is faster than fmincon.
      - Clarify requirements from Transnet together with @jochen.bammert.
