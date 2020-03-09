function info = generate_merge_info_from_table(i, pars, tab, fields_to_merge)
    rows = find(tab.from_sys == i | tab.to_sys == i);
    info = generate_merge_info(tab.from_bus(rows), tab.to_bus(rows), pars, fields_to_merge); 
end