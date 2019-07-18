%% ZAT ICL March 2019
function input_data = datareader_for_SBL(dir_name,file_name,read_config)


M = csvread([dir_name '/' file_name],1,0);

% detect NaN
idx = find(any(isnan(M)'));
if ~isempty(idx)
    read_until = idx(1)-1;
    warning('NaN detected during import, after NaN data is ignored!!!')
else
    read_until = size(M,1);
end


% time vector
input_data.tspan = M(1:read_until,1);
% inputs
if ~isempty(read_config.inputs)
    input_data.inputs = M(1:read_until,read_config.inputs);
else
    input_data.inputs = [];
end
% states
input_data.states = M(1:read_until,read_config.states);
%
input_data.noise = M(1:read_until,4);

disp('import was successfull!')


