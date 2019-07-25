function signal_fit_error = fit_report(fit_res,disp_plot)
% fit_report - shows the signal fit with the selected dictionaries for each
% state

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
    state_num = size(fit_res.y,2);
    selected_states = 1:state_num;
end

state_num = 1;
selected_states = 1:state_num;
sbl_param = cell(1,state_num);
for k = 1:state_num
    state = selected_states(k);
    signal_fit_error(k) = norm(y(:,k) - A*fit_res.sbl_param{k})/size(y,1);
    if disp_plot
        figure('Name',sprintf('Signal Fit - state: %d (%s)',state,fit_res.name))
        % upper subplot
        subplot(2,1,1)
        plot(y(:,k),'LineWidth',2)
        hold on
        plot(A*fit_res.sbl_param{k},'LineWidth',2)
        legend(sprintf('%s_{orig}',fit_res.name),sprintf('%s_{sbl} fit',fit_res.name),'Location','Best')
        xlabel('Sample Num')
        non_zero = size(fit_res.non_zero_dict{k},2);
        title(sprintf('State: %d Dict Num: %d, selected: %d (%g%%)',state,size(A,2),non_zero,non_zero/size(A,2)*100))
        % lower subplot
        subplot(2,1,2)
        plot(y(:,k) - A*fit_res.sbl_param{k},'r','LineWidth',2)
        title(sprintf('||y_{orig} - y_{sbl}||_2 = %g',signal_fit_error(k)))
        legend('Residual error','Location','Best')
        xlabel('Sample Num')
    end
end
end