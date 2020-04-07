function entries = entries_to_delete(buses, n)
    entries = union(buses, buses + n);
end