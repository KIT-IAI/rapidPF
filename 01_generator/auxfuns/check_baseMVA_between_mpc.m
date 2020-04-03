% error when these two mpcs have different baseMVA value 
function check_baseMVA_between_mpc(mpc1, mpc2)
    assert(mpc1.baseMVA == mpc2.baseMVA, 'post_processing:baseMVA_inconsistent_between_mpc', 'Two case files have different baseMVAs.')
end