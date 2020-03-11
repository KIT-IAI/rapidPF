function tab = update_connections(tab, i, Nshift)
    assert(i > 1, 'cannot update the master system.');
    
    to_be_deleted = [];
    
    for k = 1:height(tab)
        row = tab(k, :);
        from_sys = row.from_sys;
        to_sys = row.to_sys;
        assert(from_sys < to_sys, 'inconsistent ordering');
        
        if from_sys == 1 && to_sys == i
            to_be_deleted = [to_be_deleted; k];
        elseif from_sys == i
            tab.from_bus(k) = tab.from_bus(k) + Nshift;
            tab.from_sys(k) = 1;
        end
    end
    
    tab(to_be_deleted, :) = [];
end