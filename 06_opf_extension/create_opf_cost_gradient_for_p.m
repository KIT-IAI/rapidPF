function gradient_costs = create_opf_cost_gradient_for_p(Pnet, gencost)

N_generators = size(gencost, 1);
gradient_costs = sym('grad_cost_1_', [N_generators 1], 'real');


for i = 1 : N_generators
    n_cost_coefficients = gencost(i, 4);
    gradient_costs(i) = sym(zeros(1,1));
    assert(gencost(i, 1)==2, 'Only polynomial costs are supported!')
    for j = 1 : n_cost_coefficients - 1
        % calculate derivative from cost fun
        gradient_costs(i) = gradient_costs(i) + ...
            gencost(i, 4 + j)*(n_cost_coefficients - j)* ...
            Pnet(i)^(n_cost_coefficients - j - 1);
    end
end
end

