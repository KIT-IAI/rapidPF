function fun = create_power_flow_equation(Vang, Vmag, Pnet, Qnet, Y, relevant_buses)
% create_power_flow_equation_for_p
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
% 
%    
%     assert(numel(Vang) == numel(Vmag), 'inconsistent dimensions for voltages')
%     assert(numel(Pnet) == numel(Qnet), 'inconsistent dimensions for powers');
%     
%     assert(numel(Pnet) == numel(relevant_buses) && numel(Qnet) == numel(relevant_buses), 'inconsistent dimensions')
    if isnumeric(Vang)
        [M_p, M_q] = build_pf_matrix(Vang, Y);
    else
        [M_p, M_q] = build_pf_matrix_casadi(Vang, Y);
    end
    P = Vmag .* (M_p * Vmag);
    Q = Vmag .* (M_q * Vmag);
    fun = vertcat(P(relevant_buses) - Pnet, Q(relevant_buses) - Qnet);
end

