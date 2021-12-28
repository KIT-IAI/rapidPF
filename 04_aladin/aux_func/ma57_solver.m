function x = ma57_solver(A,b)
%     [L, D, P] = ldl(A);
%     x         = P*(L'\(D\(L\(P'*b))));
%     x       = sparse(size(A,2),1);
%     [Lm, Dm, pm] = ldl(A, 'vector');
%     x(pm,:) = Lm'\(Dm\(Lm\(b(pm,:))));

%     [L, U, P] = lu(A);
%     x   = U\(L\(P*b));
% x = linsolve(A,b)
x = A\b;
end