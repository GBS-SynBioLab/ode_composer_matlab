%% ZAT ICL July 2019 

read_config.states = 3;
read_config.inputs = 2;
read_config.noise  = 4;

dir_name ='data';
file_name = 'sbl_input_file_Exp1.csv';



input_data = datareader_for_SBL(dir_name,file_name,read_config);

%%
state_num = size(input_data.states,2);

% measurement data

% add measurement noise
input_data.states = input_data.states + input_data.noise;

% differeniate the signal
for k = 1:state_num
    y_tmp = input_data.states(:,k);
    f = fit(input_data.tspan,y_tmp,'smoothingspline','SmoothingParam',0.00001);
    dydt(:,k) = differentiate(f,input_data.tspan);
    figure()
    plot(f,input_data.tspan,input_data.states(:,k))
end
sbl_params.y{1} = dydt(:,1);

% generating the dictionary functions
Phi{1} = @(x,u) ones(size(x,1),1);
Phi{2} = @(x,u) x(:,1);
Phi{3} = @(x,u) u(:,1);
P = hill_dict_generator();
Phi = {Phi{:} P{:}};

x = [input_data.states input_data.inputs];
Phi_val = cell(state_num,1);

for state = 1:state_num
    Phi_val{state} = cell2mat(cellfun(@(f) f(x(:,1),x(:,2)),Phi,'UniformOutput',false));
end
%%
model.t{1} = input_data.tspan;
model.x0_vec(1,:) = input_data.states(1,:);
sbl_params.A{1} = Phi_val{1};
sbl_params.name  = 'Cit_SBL';
sbl_params.state_names = {'Cit_foldedP'};
sbl_params.experiment_num = 1;
sbl_params.std = 0.01;%mean(input_data.noise);
% config.nonneg
config = [];
config.max_iter = 10;
config.mode = 'SMV'; 

% use this if you have YALMIP and GUROBI configured
fit_res_MIP = vec_sbl(sbl_params,config);
% otherwise
% load('sbl_output_for_mip');

%%
zero_th = 1e-4;
disp_plot =1;
fit_res_MIP  = calc_zero_th(fit_res_MIP,zero_th,disp_plot);
signal_fit_error = fit_report(fit_res_MIP,disp_plot);
% remove the constant term
fit_res_MIP.sbl_param{1}(1) = 0;
