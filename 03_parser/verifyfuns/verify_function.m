function bool = verify_function(mpc, fun, msg)
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