function bool = verify_function(mpc, fun, msg)
% verify_function
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
    %% suppress matpower output
    opt = mpoption;
    opt.verbose = 0;
    opt.out.all = 0;
    %% compare matpower solution to custom-built functions
    result = runpf(mpc, opt);
    [vang, vmag, pnet, qnet] = extract_results(result);
    
    comparison = fun(vang, vmag, pnet, qnet);
    sat = norm(comparison, Inf);
    
    tol = 1e-8;
    bool = get_info(sat, tol, msg);
end

function bool = get_info(sat, tol, msg)
    if  sat <= tol
%             warning('%s are satisfied (%e <= tol = %e)', msg, sat, tol)
            bool = true;
        else
            warning('%s are not satisfied (%e > tol = %e)', msg, sat, tol)
            bool = false;
    end
end    