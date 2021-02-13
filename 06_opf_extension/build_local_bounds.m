function [lb, ub] = build_local_bounds(om)
% BUILD_LOACL_BOUNDS
%
%   `[lb, ub] = build_local_bounds(om)`
%
%   _extracts local bounds for x from MATPOWER_
%
%   INPUT:
%   - $\texttt{om}$ optimization model of reduced splitted case file
%
%  OUTPUT:
%  - $\texttt{[lb, ub]}$ lower and upper bond for objective variable $x$ of model $\texttt{om}$ of subsystem $i$    
    [~, lb, ub] = om.params_var();
end