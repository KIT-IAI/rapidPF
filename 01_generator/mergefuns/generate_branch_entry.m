function entry = generate_branch_entry(from_bus, to_bus, r, x, b, ratio, angle)
% generate_branch_entry
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
    [F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, ...
        RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
        ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
    
    entry = zeros(1,13);
    entry(F_BUS) = from_bus;
    entry(T_BUS) = to_bus;
    entry(BR_R) = r;
    entry(BR_X) = x;
    entry(BR_B) = b;
    entry(TAP) = ratio;
    entry(SHIFT) = angle;
    entry(BR_STATUS) = 1;
end