function nonneg = generateNonNegConstraints(sbl_data,sbl_config,monomes)

if isfield(sbl_config,'selected_states')
    state_num = size(sbl_config.selected_states,2);
    selected_states = sbl_config.selected_states;
else
    state_num = size(sbl_config.y{1},2);
    selected_states = 1:state_num;
end

% TODO consider preselected dictionary functions
% if isfield(fit_res,'selected_dict')
%     selected_dict = fit_res.selected_dict;
% else
%     for exp_idx = 1:fit_res.experiment_num
%     selected_dict{exp_idx} = 1:size(fit_res.A{exp_idx},2);
%     end
% end
selected_dict = 1:size(sbl_data.A{1},2);
param_num = size(selected_dict,2);
state_num = size(selected_states,2);

%% compute nonnegative constraint indices
for k=1:state_num
    state = selected_states(k);
    state_monome = find(cell2mat(cellfun(@(x) any(find(x==state)),monomes,'UniformOutput',0)));
    nonneg{k} = setdiff(1:param_num,state_monome);
    if ~isempty(selected_dict)
        if ~iscell(selected_dict)
            selected_dict = repmat({selected_dict},1,state_num);
        end
        nonneg{k} = intersect(selected_dict{k},nonneg{k});
    end
end


end