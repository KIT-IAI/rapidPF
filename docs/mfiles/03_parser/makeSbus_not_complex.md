# makeSbus_not_complex
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

##  This is originally part of matpower!!!
MAKESBUS   Builds the vector of complex bus power injections.
SBUS = MAKESBUS(BASEMVA, BUS, GEN)
SBUS = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM)
SBUS = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM, SG)
returns the vector of complex bus power injections, that is, generation
minus load. Power is expressed in per unit. If the MPOPT and VM arguments
are present it evaluates any ZIP loads based on the provided voltage
magnitude vector. If VM is empty, it assumes nominal voltage. If SG is
provided, it is a complex ng x 1 vector of generator power injections in
p.u., and overrides the PG and QG columns in GEN, using GEN only for
connectivity information.

[SBUS, DSBUS_DVM] = MAKESBUS(BASEMVA, BUS, GEN, MPOPT, VM)
With two output arguments, it computes the partial derivative of the
bus injections with respect to voltage magnitude, leaving the first
return value SBUS empty. If VM is empty, it assumes no voltage dependence
and returns a sparse zero matrix.

See also MAKEYBUS.
MATPOWER
Copyright (c) 1996-2016, Power Systems Engineering Research Center (PSERC)
by Ray Zimmerman, PSERC Cornell

This file is part of MATPOWER.
Covered by the 3-clause BSD License (see LICENSE file for details).
See https://matpower.org for more info.

