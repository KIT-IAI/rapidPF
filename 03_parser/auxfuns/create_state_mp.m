function [vang, vmag, pg, qg] = create_state_mp(postfix, Nbus, Ngen)
% create_state
%
%   `copy the declaration of the function in here (leave the ticks unchanged)`
%
%   _describe what the function does in the following line_
%
%   # Markdown formatting is supported
%   Equations are possible to, e.g $a^2 + b^2 = c^2$.
%   So are lists:
%   - item 1
%   - item 2
%   ```matlab
%   function y = square(x)
%       x^2
%   end
%   ```
%   See also: [run_case_file_splitter](run_case_file_splitter.md)
    vang = sym(strcat('Va_', postfix, '_'), [Nbus 1], 'real');
    vmag = sym(strcat('Vm_', postfix, '_'), [Nbus 1], 'real');
    pg = sym(strcat('Pg_', postfix, '_'), [Ngen 1], 'real');
    qg = sym(strcat('Qg_', postfix, '_'), [Ngen 1], 'real');
end