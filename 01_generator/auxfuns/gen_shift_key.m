function [trans, dist] = gen_shift_key(mpc, decreased_region,alpha)


    trans  = mpc.trans;
    dist   = mpc.dist;
    N_dist = numel(dist);
    shift_power = 0;
%     for i = 1:N_dist
%         sys = dist{i};
%         [sys.gen, shift_p_i] = decrease_dist_gen(sys.gen, alpha);
%         dist{i} = sys;
%         shift_power = shift_power + shift_p_i;        
%     end
    if alpha ~= 0
    sys = dist{decreased_region};
    [sys.gen, shift_p_i] = decrease_dist_gen(sys.gen, alpha);
    dist{decreased_region} = sys;
    shift_power = shift_power + shift_p_i;    

    trans.gen = increase_trans_gen(trans.gen, shift_power);
    end
end

function [gen, shift_power] = decrease_dist_gen(gen, alpha)
    shift_power = sum(gen(:,2))*alpha;
    gen(:,2)    = gen(:,2)*(1-alpha);
end

function gen = increase_trans_gen(gen, shift_power)
    trans_gen_power = sum(gen(:,2));
    ratio           = (trans_gen_power + shift_power)/trans_gen_power;
    gen(:,2)        = gen(:,2)*ratio;
    gen(:,9)        = gen(:,9)*ratio;
end