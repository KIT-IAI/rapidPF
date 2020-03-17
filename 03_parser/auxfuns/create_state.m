function [vang, vmag, pnet, qnet] = create_state(postfix, N)
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
    vang = sym(strcat('Va_', postfix, '_'), [N 1], 'real');
    vmag = sym(strcat('Vm_', postfix, '_'), [N 1], 'real');
    pnet = sym(strcat('P_', postfix, '_'), [N 1], 'real');
    qnet = sym(strcat('Q_', postfix, '_'), [N 1], 'real');
end