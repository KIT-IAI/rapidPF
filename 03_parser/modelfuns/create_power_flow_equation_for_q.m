function fun = create_power_flow_equation_for_q(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
% create_power_flow_equation_for_q
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
    if nargin == 5
        check_dimension(Vang, Vmag, Pnet, Qnet);        
        relevant_buses = 1:numel(Vang);
    end

    assert(numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses), 'inconsistent dimensions')
    [~, M_q] = build_pf_matrix(Vang, Y);
    Q = Vmag .* (M_q * Vmag);
    fun = Q(relevant_buses) - Qnet;
end



