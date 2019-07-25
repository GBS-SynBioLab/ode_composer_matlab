%% ZAT ICL March 2019
function input_data = datareader_for_SBL(dir_name,file_name,exp_idx)


T = readtable([dir_name '/' file_name]);
% capitalize variable names 
T.Properties.VariableNames = upper(T.Properties.VariableNames);
exp_id_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'^EXPERIMENT'));
input_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'^TR_\w+'));
output_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'^READOUT_\w+'));
time_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'^TIME'));
std_idx_vec  = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'^STD_\w+')); 



%% get names
token_input = regexp(T.Properties.VariableNames,'^TR_(\w+)','once','tokens');
input_data.input_names = [token_input{input_idx_vec}];

token_state = regexp(T.Properties.VariableNames,'^READOUT_(\w+)','once','tokens');
input_data.state_names = [token_state{output_idx_vec}];


%% finding the columns

time_idx = find(time_idx_vec==1);
assert(numel(time_idx) == 1)

input_idx = find(input_idx_vec ==1);

output_idx = find(output_idx_vec ==1);
assert(numel(output_idx) >=1)
input_data.state_num = numel(output_idx);

if sum(std_idx_vec>0)
std_idx = find(std_idx_vec ==1);
assert(numel(output_idx) == numel(std_idx))
end

exp_idx = find(exp_id_vec ==1);
assert(numel(exp_idx) == 1)

%% determining exp num


exp_ids = unique(sort(table2array(T(:,exp_idx))));

for k=1:size(exp_ids,1)
    exp_range = find(table2array(T(:,exp_idx)) == exp_ids(k));
% time vector
input_data.tspan{k} = table2array(T(exp_range,time_idx));
% inputs
if ~isempty(input_idx)
    % trimming non-zero values created during import
    tmp =table2array(T(exp_range,input_idx));
    tmp(tmp<=1e-6) = 0;
    input_data.inputs{k} = tmp;
else
    input_data.inputs{k} = [];
end
% states
input_data.states{k} = table2array(T(exp_range,output_idx));
% measurement noise
if ~isempty(std_idx)
    input_data.input_std{k} = table2array(T(exp_range,std_idx));
end

end

disp('import was successfull!')


