% SBL AMICI interface
% ZAT ICL June 2019

% select model to export
fit_res = fit_res_diff;

%% state variables
state_num = size(fit_res.state_name,2);
states_names = {};
param_str = 'p%d_%d';
param_names =  {};

% converting dictionary function to model string
dict_str  = cellfun(@(x) replace(func2str(x),{'@(x)','@(x,p)ones(size(x,1),1)'},{'','1'}),Phi,'UniformOutput',false)';
dict_str  = cellfun(@(x) regexprep(x,'x\(:,(\d)\)','x$1'),dict_str,'UniformOutput',false);


rhs_states = {};
for k=1:state_num
    state_names{k} = sprintf('x%d',k);
    idx = fit_res.non_zero_dict{k};
    rhs_str = '';
    for z = idx
        param_names{end+1} = sprintf(param_str,k,z);
        rhs_str = [ rhs_str '+' sprintf([param_str '*%s'],k,z,dict_str{z})];
    end
    % collect RHS string in a cell array
    rhs_states{k} = rhs_str;
end

model_name = sprintf('SBL_%s',fit_res.name);
%%
s = [sprintf('function [model] = %s()',model_name) '\n'];

% setting up the model struct
s = strcat(s,"model.param = 'lin';\r\n");
s = strcat(s,'model.debug = false;\n');
s = strcat(s,'model.forward = true;\n');
s = strcat(s,'model.adjoint = true;\n\n');


s = strcat(s,['syms ' strjoin(state_names) '\n\n']);


s = strcat(s,['model.sym.x = [' strjoin(state_names) '];\n\n']);

s = strcat(s,['syms ' strjoin(param_names) '\n\n']);


s = strcat(s,['model.sym.p = [' strjoin(param_names) '];\n\n']);

for k=1:state_num
    s = strcat(s,[sprintf('model.sym.xdot(%d) = [%s',k,rhs_states{k}) '];\n']);
end


s = strcat(s,['model.sym.x0 = [' num2str(model.x0_vec(1,:)) '];\n\n']);

for k=1:state_num
    s = strcat(s,[sprintf('model.sym.y(%d) = [%s',k,state_names{k}) '];\n']);
end



fid = fopen(sprintf('%s.m',model_name),'w');

fprintf(fid,s);

fclose(fid);


