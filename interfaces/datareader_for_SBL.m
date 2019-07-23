%% ZAT ICL March 2019
function input_data = datareader_for_SBL(dir_name,file_name)


T = readtable([dir_name '/' file_name]);
% capitalize variable names 
T.Properties.VariableNames = upper(T.Properties.VariableNames);
input_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'TR_\w+'));
output_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'READOUT_\w+'));
time_idx_vec = ~cellfun(@isempty,regexp(T.Properties.VariableNames,'TIME'));
% TODO impement SMV vs MMV mode
exp_num = max(table2array(T(:,1)));

time_idx = find(time_idx_vec==1);
assert(numel(time_idx) == 1)

input_idx = find(input_idx_vec ==1);

output_idx = find(output_idx_vec ==1);
assert(numel(output_idx) >=1)

% 
% % TODO: detect NaN
% idx = find(any(isnan(M)'));
% if ~isempty(idx)
%     read_until = idx(1)-1;
%     warning('NaN detected during import, after NaN data is ignored!!!')
% else
%     read_until = size(M,1);
% end


% time vector
input_data.tspan = table2array(T(:,time_idx));
% inputs
if ~isempty(input_idx)
    input_data.inputs = table2array(T(:,input_idx));
else
    input_data.inputs = [];
end
% states
input_data.states = table2array(T(:,output_idx));


disp('import was successfull!')


