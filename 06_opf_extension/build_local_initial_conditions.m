function x0 = build_local_initial_conditions(om)
% BUILD_LOACL_INITIAL_CONDITION
%
%   `x0 = build_local_initial_conditions(om)`
%
%   _extracts initial condition for x from MATPOWER_
%
%   INPUT:
%   - $\texttt{om}$ optimization model of reduced splitted case file
%
%  OUTPUT:
%  - $\texttt{x0}$ initial condition for objective variable $x$ of model $\texttt{om}$ of subsystem $i$    
x0 = om.params_var();
end