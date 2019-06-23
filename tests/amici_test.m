clear variables
clc
close all

load data_for_amici_test.mat

from_SBL_to_Amici_interface

state_num = size(fit_res.state_name,2);

p_vec = {};
for k = 1:state_num
p_vec(:,k) = {fit_res.sbl_param{k}(fit_res.non_zero_dict{k})};
end

p = vertcat(p_vec{:});

t = linspace(0,10,100);

amiwrap('SBL_diff','SBL_diff','')

sol = simulate_SBL_diff(t,p,[],[],[]);

plot(sol.x)