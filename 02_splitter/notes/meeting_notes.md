# January 31, 2020
- began with the most relevant file from a power-systems perspective: splitting the branch to include auxiliary nodes
- currently, the line shunts are just halved, which we know to be incorrect
- we checked numerically that everything is fine in case the line shunt is zero --> that's good!
- perhaps we can split the branch into an ideal transformer + regular transmission line; this only works, though, if there is a transformer!
- next steps:
  - modeling of splitting the branch
  - wrapper code
  - pre- and postprocessing to check/verify the number of buses, lines, etc...