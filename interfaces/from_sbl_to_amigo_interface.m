%% SBL-AMIGO interface
% ZAT, ICL march 2019

clear inputs
% select model to export
fit_res = fit_res_diff;


%=======================
% PATHS RELATED DATA   %
%=======================
name = sprintf('SBL_%s',[fit_res_diff.name]);
inputs.pathd.results_folder = name; % Folder to keep results (in Results) for a given problem
inputs.pathd.short_name = name;     % To identify figures and reports for a given problem
inputs.pathd.runident='run_1';      % [] Identifier required in order not to overwrite previous results


%=======================
% MODEL RELATED DATA   %
%=======================

% the model will be converted to a C file for faster simulations
inputs.model.input_model_type = 'charmodelM';
% allow custom state and parameter names
inputs.model.names_type = 'custom';
% number of states equals the number of measurement vectors (i.e. all states are measured)
inputs.model.n_st = size(model.state_names,2);
% total number of parameters is given by the non zero dictionaries
sum_par = 0;
for k=1:size(fit_res,2)
    sum_par = sum_par + size([fit_res(k).non_zero_dict{:}],2);
end
inputs.model.n_par = sum_par;
% TODO: compute it automatically
inputs.model.n_stimulus = size(model.input{1},2);

inputs.model.stimulus_names = char(model.input_names);
% how model names will be named
[model_char, st_names, param_vec, param_names, obs_names, obs] = generate_model_char(fit_res,Phi,model);

inputs.model.eqns = model_char;
inputs.model.st_names = st_names;

inputs.model.par = param_vec;
inputs.model.par_names = param_names;

%===================================
% EXPERIMENTAL SCHEME RELATED DATA %
%===================================

%Number of experiments
inputs.exps.n_exp = fit_res.experiment_num;

for exp_idx=1:inputs.exps.n_exp
    % exp duration
    exp_dur = input_data.tspan{exp_idx}(end); %model.tspan{exp_idx}(end);
    %Initial conditions for each experiment
    if isfield(model,'x0_vec')
    inputs.exps.exp_y0{exp_idx} = model.x0_vec(exp_idx,:);
    else
    inputs.exps.exp_y0{exp_idx} = input_data.inputs{exp_idx}(1,:);
    end
    %Experiments duration
    inputs.exps.t_f{exp_idx} = exp_dur;
    inputs.exps.n_obs{exp_idx} = inputs.model.n_st;     % Number of observed quantities per experiment
    
    inputs.exps.n_s{exp_idx} = size(input_data.tspan{exp_idx},1);%size(model.t{exp_idx},1);                               % Number of sampling times
    inputs.exps.t_s{exp_idx} = input_data.tspan{exp_idx}';                         % [] Sampling times, by default equidistant
    
    assert(size(inputs.exps.t_s{exp_idx},2) > size(inputs.exps.t_s{exp_idx},1))
    assert(inputs.exps.t_f{exp_idx} == inputs.exps.t_s{exp_idx}(end))
    assert(inputs.exps.n_s{exp_idx} == size(inputs.exps.t_s{exp_idx},2))
    
    
    inputs.exps.u_interp{exp_idx} = 'step';
    inputs.exps.t_con{exp_idx} = input_data.tspan{exp_idx}';
    inputs.exps.n_steps{exp_idx} = length(input_data.tspan{exp_idx})-1;
    inputs.exps.u{exp_idx} = input_data.inputs{exp_idx}';
    inputs.exps.data_type = 'real';
    inputs.exps.noise_type = 'homo'; 
    inputs.exps.exp_data{exp_idx} = input_data.states{exp_idx};
    inputs.exps.error_data{exp_idx} = input_data.input_std{exp_idx};
    
    
    % need for the obs function generation
    inputs.exps.obs_names{exp_idx}=obs_names;      % Name of the observed quantities per experiment
    inputs.exps.obs{exp_idx}=obs;                  % Observation function

end


%==================================


clc
%% run test simulations

 AMIGO_Prep(inputs);
%% 
  AMIGO_SModel(inputs)






