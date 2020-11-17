function hessian_cost = create_hessian_for_cost_p(Pnet, gencosts)
% creates exact hessian matrix of cost function for polynomial cost model 2 


hessian_dimension = length(Pnet);
hessian_cost = sym(zeros(hessian_dimension, hessian_dimension));

N_coefficients = gencosts{:, 4};
for i = 1 : size(gencosts, 1)
    if N_coefficients > 2
        for j = 1 : N_coefficients - 2
       hessian_cost{i, i} = hessian_cost + ...
           gencosts{i, 4 + j}* ... 
           (N_coefficients - j)*(N_coefficients - j - 1)* ...
           Pnet(i)^{N_coefficients - j - 2};
        end
    end
end


end