function [vang, vmag, pg, qg] = create_state_mp(postfix, Nbus, Ngen)
% create_state
%
%   `[vang, vmag, pg, qg] = create_state_mp(postfix, Nbus, Ngen)`
%
%   _gives an abstract representation of the optimization variable used in MATPOWER_
%
%   Input
%   - $\ŧexttt{postfix}$ either $\textt{core}$ or $\texttt{copy}$ postfix
%   for symbolic variable
%   - $\texttt{Nbus}$ number of $\texttt{postfix}$ - buses in splitted
%   system
%   - $\texttt{Ngen}$ number of generators in splitted system
%  
%   Output
%   - $\texttt{[vang, vm, Pq, Qg]}$ symbolic voltage entries for Nbus bus entries
%   and real and reactive power entries for Ngen generators

    vang = sym(strcat('Va_', postfix, '_'), [Nbus 1], 'real');
    vmag = sym(strcat('Vm_', postfix, '_'), [Nbus 1], 'real');
    pg = sym(strcat('Pg_', postfix, '_'), [Ngen 1], 'real');
    qg = sym(strcat('Qg_', postfix, '_'), [Ngen 1], 'real');
end