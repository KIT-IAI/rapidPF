function problem = generate_distributed_problem_for_aladin(mpc, names)
    problem = generate_distributed_problem(mpc, names);
    problem = add_aladin_specifics(problem, mpc, names);
end