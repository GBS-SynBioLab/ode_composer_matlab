%% SBL-AMIGO interface 
% generate model equations in char
% ZAT, ICL march 2019
function [model_char, state_names, param_vec, param_names, obs_names, obs] = generate_model_char(fit_res,Phi)

% converting dictionary function to model string
dict_str  = cellfun(@(x) replace(func2str(x),{'@(x,u)ones(size(x,1),1)','@(x,u)'},{'1',''}),Phi,'UniformOutput',false)';
dict_str  = cellfun(@(x) regexprep(x,{'x\(:,(\d)\)','u\(:,(\d)\)'},{'x$1','u$1'}),dict_str,'UniformOutput',false);


% adding parameters
stat_num = size(fit_res.state_name,2);
% the model equations are stored here as a cell array
model_char = {};
% the parameteres of the model are stored here as a vector
param_vec = [];
param_names = {};
state_names = {};
obs_names = {};
obs = {};
oaram_str = 'p%d_%d';

for k=1:stat_num
    state_names{k} = sprintf('x%d',k);
    obs_names{k} = sprintf('obs_x%d',k);
    obs{k} = sprintf('obs_x%d=x%d',k,k);
    idx = fit_res.non_zero_dict{k};
    
    rhs_str = sprintf('dx%d=',k);
    param_vec = [param_vec fit_res.sbl_param{k}(idx)'];
    first = true;
    for z = idx
        if ~first
            plus = '+';
        else
            plus = '';
            first = false;
        end
        
        param_names{end+1} = sprintf(oaram_str,k,z);
        rhs_str = [rhs_str plus sprintf([oaram_str '*%s'],k,z,dict_str{z})];
    end
    % collect RHS string in a cell array
    model_char{end+1} = rhs_str;
    
end
% convert the cell array to character array
model_char = char(model_char);
state_names = char(state_names);
param_names = char(param_names);
obs_names = char(obs_names);
obs = char(obs);
end
