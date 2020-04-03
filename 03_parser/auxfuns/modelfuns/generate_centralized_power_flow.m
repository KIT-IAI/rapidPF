function problem = generate_centralized_power_flow(mpc, names)
% generate_centralized_power_flow
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
    Ybus = makeYbus(mpc);
    Nbus = size(Ybus, 1);
    
    Vang = sym(strcat('Vang_'), [Nbus 1], 'real');
    Vmag = sym(strcat('Vmag_'), [Nbus 1], 'real');
    Pnet = sym(strcat('Pnet_'), [Nbus 1], 'real');
    Qnet = sym(strcat('Qnet_'), [Nbus 1], 'real');
    state = stack_state(Vang, Vmag, Pnet, Qnet);
    
    [pf_p, pf_q]  = create_power_flow_equations(Vang, Vmag, Pnet, Qnet, Ybus);
    bus_specifications = create_bus_specifications(Vang, Vmag, Pnet, Qnet, mpc);
    
    equalities = [pf_p; pf_q; bus_specifications];
    
    % initial condition
    [Vang0, Vmag0, Pnet0, Qnet0] = create_initial_condition(mpc);
    x0 = stack_state(Vang0, Vmag0, Pnet0, Qnet0);
    
    % verification
    verify_power_flow_equations(mpc);
    verify_bus_specifications(mpc);
    
    % generate output
    problem.ffi = @(x)0*sum(x);
    problem.ggi = equalities;
    problem.hhi = @(x)[];

    problem.xx  = state;
    problem.xx0 = x0;
end





