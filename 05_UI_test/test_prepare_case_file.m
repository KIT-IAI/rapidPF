function test_prepare_case_file
%TEST_PREPARE_CASE_FILE tests prepare_case_file.m

%% load test case file
mpc_test = loadcase('case5');
mpc_test.copy_buses_local = [1;3];

%% generators the should be switched of
names.copy_buses.local = 'copy_buses_local';

mpc_test_prepared = prepare_case_file(mpc_test, names);
assert(size(mpc_test_prepared.gen, 1) == 2, 'Too many or too less gen entries were deleted');
assert(size(mpc_test_prepared.gencost, 1) == 2, 'Too many or too less gencost entries were deleted');


end

