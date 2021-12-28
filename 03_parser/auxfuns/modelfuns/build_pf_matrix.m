function [M_p, M_q] = build_pf_matrix(ang, Y)
% build_pf_matrix
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
    G = real(Y);
    B = imag(Y);
    [row,col] = find(Y);
    [sin_diff, cos_diff] = build_angle_differences(ang,row,col);
    
    M_p = G.*cos_diff + B.*sin_diff;
    M_q = G.*sin_diff - B.*cos_diff;
end

function [sin_diff, cos_diff] = build_angle_differences(ang,row,col)
%     diff = ang - ang';
    Nx   = numel(ang);
%     ANG  = repmat(ang, 1, numel(ang));
%     sparse
    
    diff = ang(row) - ang(col);
%     diff(k) = ANG(k) - ANG'(k);
    
    sin_diff = sparse(row,col,sin(diff),Nx,Nx);
    cos_diff = sparse(row,col,cos(diff),Nx,Nx);
end