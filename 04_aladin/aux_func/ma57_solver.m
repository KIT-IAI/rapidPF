function x = ma57_solver(A,b)
    [L, D, P] = ldl(A);
    x         = P*(L'\(D\(L\(P'*b))));
end