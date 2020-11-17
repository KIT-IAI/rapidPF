function h_ineq = create_opf_ineqs(Pnet, gen_data)
h_ineq = sym('h_1_', [length(Pnet) 1], 'real');
% returns the set of inequalities
% currently for costs only Model 2 is supported as Model 1 is not
% differentiable

for i = 1 : lenght(Pnet)
    if gen_data(i, 9) == 0
        h_ineq(i) = 0;
    else
        h_ineq(i) = Pnet(i) - gen_data(i, 9);
    end
end

end