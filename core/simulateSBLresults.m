function simulateSBLresults(Phi,fit_results,model)

%% zero out constants
% for k=1:size(fit_results.selected_states,2)
%      fit_results.sbl_param{k}(1) = 0;
% end
state_num = size(model.state_names,2);

experiment_num = 1;
x0_maxValue    = 50;

%% generate set of initial condiations
x0_vec = lhsu(zeros(state_num,1),repmat(x0_maxValue,state_num),experiment_num);

if isfield(model,'tspan')
    t_span = model.tspan{1};
else
    t_span = 0:0.1:50;
end

x_sbl_sum = [];
x_sbl_sint_sum = [];
x_sbl_diff_sum = [];
x_orig_sum  = [];
input = [];

ode_solver_opts= [];

%% run ODE solver
for z = 1:experiment_num
%     [t_orig,x_orig] = CRN_Simulate_M(M,Y,t_span,x0_vec(z,:));
%     x_orig_sum = [ x_orig_sum; x_orig];
   p =[];
    for k = 1:experiment_num
    %try
        [t_sbl,x_sbl]   = ode15s(@ode_rhs_from_phi,t_span,x0_vec(z,:),ode_solver_opts,Phi,fit_results,model);
        x_sbl_sum   = [ x_sbl_sum;   x_sbl];
    %catch ME
    %    disp('reconstracted ODE integration failed');
    %end
    
    end 
end

%% generate report
for k = 1:state_num
    figure('Name',sprintf('ODE simulation x_%d',k))
    %plot(x_orig_sum(:,k),'LineWidth',1.5)
    hold on
    plot(x_sbl_sum(:,k),'LineWidth',1.5)
    %         traj_diff(k) = norm(x_orig_sum(:,k) - x_sbl_sum(:,k))/size(x_sbl_sum,1);
    %         title(sprintf('||x_{orig} - x_{sbl}||_2= %g',traj_diff(k)))
    %legend(sprintf('%s_{orig}',model.state_names{k}),sprintf('%s_{sbl}',model.state_names{k}),'Location','Best')
    xlabel('Time [min]')
end




