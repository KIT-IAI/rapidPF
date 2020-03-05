## Code conventions
- one function does one single thing
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