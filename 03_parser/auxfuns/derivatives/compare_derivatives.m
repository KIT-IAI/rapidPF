for i = 1:numel(sProb.zz0)
    x = sProb.zz0{i};

    grad = full(sProb.sens.gg{i}(x));
    jac = full(sProb.sens.JJac{i}(x));

    [ng, nx] = size(jac);
    kappa = rand(ng, 1);
    rho = 1;

    hess = full(sProb.sens.HH{i}(x, kappa, rho));

    mygrad = sProb.mysens.gg{i}(x);
    myjac = sProb.mysens.JJac{i}(x);
    myhess = sProb.mysens.HH{i}(x, kappa, rho);

    dgrad = norm(grad - mygrad);
    dJacobian = norm(jac - myjac);
    dHessian = norm(hess - myhess);
    table(i, dgrad, dJacobian, dHessian)
end

