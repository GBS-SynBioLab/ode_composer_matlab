function fit_res = calc_zero_th(fit_res,fix_zero_th,disp_plot)
% calc_zero_th - computes the zero threshold and the non_zero_dict for each state, additionally it shows the
% zero_th - residual error plot (if disp_plot = True)
% 
% 
mode = 'SMV';

if strcmpi(mode,'SMV')
    state_num = size(fit_res.y{1},2);
    param_num = size(fit_res.A{1},2);
    
    A = [];
    y = [];
    for exp_idx = 1:fit_res.experiment_num
        % adjust size if needed
        if size(fit_res.A{exp_idx},1) > size( fit_res.y{exp_idx},1)
            size_diff = size(fit_res.A{exp_idx},1)-size(fit_res.y{exp_idx},1);
            assert(size_diff >= 0);
            offset = 1+size_diff;
            tmp_A = fit_res.A{exp_idx}(offset:end,:);
        else 
            tmp_A = fit_res.A{exp_idx};
        end
        A = [A; tmp_A];
        y = [y; fit_res.y{exp_idx}];
    end
else
    error('not yet implemented')
end



if isfield(fit_res,'selected_states')
    state_num = size(fit_res.selected_states,2);
    selected_states = fit_res.selected_states;
else
    state_num = size(fit_res.y{1},2);
    selected_states = 1:state_num;
end

state_num = 1;
selected_states = 1:state_num;

% TODO consider preselected dictionary functions
% if isfield(fit_res,'selected_dict')
%     selected_dict = fit_res.selected_dict;
% else
%     for exp_idx = 1:fit_res.experiment_num
%     selected_dict{exp_idx} = 1:size(fit_res.A{exp_idx},2);
%     end
% end
selected_dict = 1:size(A,2);

if ~isempty(fix_zero_th)
    if length(fix_zero_th) ==1
        fix_zero_th = repmat(fix_zero_th,1,size(selected_states,2));
    end
end

% find cut-off threshold
zth_vec = logspace(-8,0,180);

fit_error_value = cell(state_num,1);
dict_num = cell(state_num,1);
for k = 1:state_num
    state = selected_states;
    
    for z = zth_vec
        if iscell(fit_res.w_est(k))
            w_val = fit_res.w_est{k};
        else
            w_val = fit_res.w_est{k}(:,end);
        end
        w_val(abs(w_val) < z) = 0;
        fit_error_value{k}(end+1) = norm(y(:,k) - A*w_val);
        dict_num{k}(end+1) = sum(abs(w_val) > 0);
    end
    
    % max peak in the diff vec is the change in error
    [~,ch_idx] = max(diff(fit_error_value{k}));
    ch_idx = ch_idx;
    zero_th(k) = zth_vec(ch_idx);
    sprintf('state: x_%d zero_th: %g dict_num: %d (%g%%)',state(k),zero_th(k),dict_num{k}(ch_idx),dict_num{k}(ch_idx)/size(A,2)*100)
    if disp_plot
        figure()
        title(sprintf('Zero threshold vs fit error and dict num for x_%d (%s)',state,fit_res.name))
        yyaxis left
        loglog(zth_vec,dict_num{k},'LineWidth',1.5);
        text(zero_th(k),dict_num{k}(ch_idx),['\leftarrow' sprintf('zeroth: %f',zero_th(k))])
        yyaxis right
        loglog(zth_vec,fit_error_value{k},'LineWidth',1.5)
        legend('Non zero param','Fit error','Location','Best')
        xlabel('Zero threshold')
        
        
    end
    % overwrite the computed thereshold with the externally provided one
    if ~isempty(fix_zero_th)
        zero_th = fix_zero_th;
    end
    sbl_param{k} = fit_res.w_est{k};
    zero = abs(sbl_param{k}) < zero_th(k);
    zero_dict{k} = find(zero);
    if sum(zero_dict{k}) == 0
        non_zero_dict{k} = selected_dict;
    else
        non_zero_dict{k} = setdiff(selected_dict,zero_dict{k});
    end
    sbl_param{k}(zero) = 0;
    
end % for each state

%% add fields to the report struct
fit_res.zero_dict = zero_dict;
fit_res.non_zero_dict = non_zero_dict;
fit_res.sbl_param = sbl_param;