function [trans, dist] = gen_shift_key(mpc, alpha)


    trans  = mpc.trans;
    dist   = mpc.dist;
    N_dist = numel(dist);
    shift_power = 0;
    for i = 1:N_dist
        sys = dist{i};
        [sys.gen, shift_p_i] = decrease_dist_gen(sys.gen, alpha);
        dist{i} = sys;
        shift_power = shift_power + shift_p_i;        
    end
    
    trans.gen = increase_trans_gen(trans.gen, shift_power);
end

function [gen, shift_power] = decrease_dist_gen(gen, alpha)
    shift_power = sum(gen(:,2))*(1-alpha);
    gen(:,2)    = gen(:,2)*alpha;
end

function gen = increase_trans_gen(gen, shift_power)
    trans_gen_power = sum(gen(:,2));
    ratio           = (trans_gen_power + shift_power)/trans_gen_power;
    gen(:,2)        = gen(:,2)*ratio;
end