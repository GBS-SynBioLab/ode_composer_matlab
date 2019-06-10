%% SBL-AMIGO interface
% ZAT, ICL march 2019

clear inputs
% select model to export
fit_res = fit_res_diff;


%=======================
% PATHS RELATED DATA   %
%=======================
name = sprintf('SBL_%s',fit_res.name);
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
inputs.model.n_st = size(fit_res.state_name,2);
% total number of parameters is given by the non zero dictionaries
inputs.model.n_par = size([fit_res.non_zero_dict{:}],2);
% TODO: compute it automatically
inputs.model.n_stimulus = 0;
%inputs.model.stimulus_names = 'u1';
% how model names will be named
[model_char, st_names, param_vec, param_names, obs_names, obs] = generate_model_char(fit_res,Phi);

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
    exp_dur = model.t{exp_idx}(end);
    %Initial conditions for each experiment
    inputs.exps.exp_y0{exp_idx} = model.x0_vec(exp_idx,:);
    %Experiments duration
    inputs.exps.t_f{exp_idx} = exp_dur;
    inputs.exps.n_obs{exp_idx} = size(fit_res.y,2);     % Number of observed quantities per experiment
    
    inputs.exps.n_s{exp_idx} = size(model.t{exp_idx},1);                               % Number of sampling times
    inputs.exps.t_s{exp_idx} = model.t{exp_idx}';                         % [] Sampling times, by default equidistant
    assert(size(inputs.exps.t_s{exp_idx},2) > size(inputs.exps.t_s{exp_idx},1))
    assert(inputs.exps.t_f{exp_idx} == inputs.exps.t_s{exp_idx}(end))
    assert(inputs.exps.n_s{exp_idx} == size(inputs.exps.t_s{exp_idx},2))
    
    % Values of the inputs
%     inputs.exps.u_interp{exp_idx} = 'linear';
%     inputs.exps.u{exp_idx} = input_data.inputs';
    
    % need for the obs function generation
    inputs.exps.obs_names{exp_idx}=obs_names;      % Name of the observed quantities per experiment
    inputs.exps.obs{exp_idx}=obs;                  % Observation function

end


%==================================


% % Stimuli definition for experiment 1:
% inputs.exps.u_interp{1} = 'sustained';
% % OPTIONS:u_interp: 'sustained' |'step'|'linear'(default)|'pulse-up'|'pulse-down'
% % Input swithching times: Initial and final time
% inputs.exps.t_con{1} = [0 exp_dur];
% % Values of the inputs
% inputs.exps.u{1} = [1];

clc
%% run test simulations

 AMIGO_Prep(inputs);
%% 
%  AMIGO_SModel(inputs)






