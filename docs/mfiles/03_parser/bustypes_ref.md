# add_consensus_information
`copy the declaration of the function in here (leave the ticks unchanged)`

_describe what the function does in the following line_

##  Markdown formatting is supported
Equations are possible to, e.g $a^2 + b^2 = c^2$.
So are lists:

+   item 1
    
+   item 2
    
```matlab
function y = square(x)

        x^2
end
```
See also: [run_case_file_splitter](run_case_file_splitter.md)

##  This is originally part of Matpower!!!!
BUSTYPES   Builds index lists for each type of bus (REF, PV, PQ).
[REF, PV, PQ] = BUSTYPES(BUS, GEN)
Generators with "out-of-service" status are treated as PQ buses with
zero generation (regardless of Pg/Qg values in gen). Expects BUS and
GEN have been converted to use internal consecutive bus numbering.

MODIFICATION:
If there is no reference bus in the system, then an empty array is returned for REF.

MATPOWER
Copyright (c) 1996-2016, Power Systems Engineering Research Center (PSERC)
by Ray Zimmerman, PSERC Cornell

This file is part of MATPOWER.
Covered by the 3-clause BSD License (see LICENSE file for details).
See https://matpower.org for more info.

