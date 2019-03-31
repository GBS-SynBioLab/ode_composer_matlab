%% clean up
clear variables
clc
close all
%% load model
mak_network;

%% generate data from a MAK model
model.Y = Y;
model.M = M;
% maximum value of the initial conditions 
model.x0_maxValue = 50;
% number of experiments generated
model.experiment_num = 3;
% length of the simulation (sec)
model.t_f = 10;
% set the signal-to-noise ratio for each state variable
model.SNR = 100;

% generate the data
model = generateDataFromModel(model);

%% generate dictionary
polyorder = 2;
[A,Phi,Y_Dict,monomes] = generateMAKDictionary(model,polyorder);

%% build a linear regression struct, i.e. y = A*x
sbl_diff.A = A;
sbl_diff.y = model.dydt;
sbl_diff.name = 'diff';
sbl_diff.state_names = {'x1','x2','x3','x4','x5'};
sbl_diff.experiment_num = model.experiment_num;
sbl_diff.std = model.variance;

%% simulate ODEx and report them
[Morig,param_idx] = generateOrigParamMtx(M,Y,Y_Dict);
% TODO use only selected dictionaries
% sbl_config.selected_dict = 1:size(A{1},2);

% estimate only the selected states
sbl_config.selected_states = 1:size(model.y{1},2);

%% generate nonnegconstraints
param_num = size(A,2);
sbl_config.nonneg = generateNonNegConstraints(sbl_diff,sbl_config,monomes);

sbl_config.max_iter = 10;
sbl_config.mode = 'SMV';
%% run SBL
tic;
fit_res_diff = vec_sbl(sbl_diff,sbl_config);
toc;
%% reporting
% turn on/off plots
disp_plot = 0;

% use manual tresholding
zero_th = 1e-6;
% select non zero dictionaries
fit_res_diff = calc_zero_th(fit_res_diff,zero_th,disp_plot);
% report signal fit
signal_fit_error_diff = fit_report(fit_res_diff,disp_plot);

%% Print out models
% green - correct dict found (OK)
% red   - missing dict 
% black - false  dict 
printOutModel(fit_res_diff,Morig,Phi,[])

%% simulate the reconstructed ODE

simulateSBLresults(Y,M,Phi,fit_res_diff)