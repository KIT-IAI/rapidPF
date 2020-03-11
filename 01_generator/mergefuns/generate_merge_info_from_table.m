function info = generate_merge_info_from_table(i, tab, fields_to_merge)
    rows = find((tab.from_sys == i & tab.to_sys == 1) | (tab.to_sys == i & tab.from_sys == 1));
    info = generate_merge_info(tab.from_bus(rows), tab.to_bus(rows), tab.trafo_pars(rows), fields_to_merge); 
end