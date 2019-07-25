%% SBL-AMIGO interface
% generate model equations in char
% ZAT, ICL march 2019
function [model_char, state_names, param_vec, param_names, obs_names, obs] = generate_model_char(fit_res,Phi,model)


% adding parameters
stat_num = size(model.state_names,2);
% the model equations are stored here as a cell array
model_char = {};
% the parameteres of the model are stored here as a vector
param_vec = [];
param_names = {};
state_names = {};
obs_names = {};
obs = {};
param_str = 'p%d_%d';

for k=1:stat_num
    
    % converting dictionary function to model string
    dict_str  = cellfun(@(x) replace(func2str(x),{'@(x,p)ones(size(x,1),1)','@(x,u)ones(size(x,1),1)','@(x,u)','@(x,p)','@(x)'},{'1','1','','',''}),Phi{k},'UniformOutput',false)';
    dict_str  = cellfun(@(x) regexprep(x,{'x\(:,(\d)\)','u\(:,(\d)\)'},{'x$1','u$1'}),dict_str,'UniformOutput',false);
    
    if isempty(model.state_names)
        state_names{k} = sprintf('x%d',k);
        obs_names{k} = sprintf('obs_x%d',k);
        obs{k} = sprintf('obs_x%d=x%d',k,k);
        rhs_str = sprintf('dx%d=',k);
    else
        state_names{k} = sprintf('%s',model.state_names{k});
        obs_names{k} = sprintf('obs_%s',model.state_names{k});
        obs{k} = sprintf('obs_%s=%s',model.state_names{k},model.state_names{k});
        
        rhs_str = sprintf('d%s=',model.state_names{k});
        % replace the variable names in the equations as well
        for z=1:stat_num    
            dict_str = strrep(dict_str,sprintf('x%d',z),model.state_names{z});
            dict_str = strrep(dict_str,sprintf('x%d',z+2),model.input_names{z});
        end
    end
    
    
    idx = fit_res(k).non_zero_dict{1};
    
    param_vec = [param_vec fit_res(k).sbl_param{1}(idx)'];
    first = true;
    for z = idx
        if ~first
            plus = '+';
        else
            plus = '';
            first = false;
        end
        
        param_names{end+1} = sprintf(param_str,k,z);
        rhs_str = [rhs_str plus sprintf([param_str '*%s'],k,z,dict_str{z})];
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
