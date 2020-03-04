function [M_p, M_q] = build_pf_matrix(ang, Y)
    G = real(Y);
    B = imag(Y);
    [sin_diff, cos_diff] = build_angle_differences(ang);
    
    M_p = G.*cos_diff + B.*sin_diff;
    M_q = G.*sin_diff - B.*cos_diff;
end

function [sin_diff, cos_diff] = build_angle_differences(ang)
    diff = ang - ang';
    sin_diff = sin(diff);
    cos_diff = cos(diff);
end