% SBL Strike-Goldd interface
% ZAT ICL march 2019

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

%states
x = cell2sym(state_names);
% RHS
f = cell2sym(rhs_states');



%% observables
% all states are measured
h = x;

%% inputs
u = [];

%% parameters
p = cell2sym(param_names);

%% initial conditations
ics = [];
% false = unknown
known_ics = zeros(1,state_num);

%% save the model in a mat file
fileName = ['SBL_' fit_res.name '_strike_goldd.mat'];
save(fileName,'x','h','u','p','f','ics','known_ics');