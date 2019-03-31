function simulateSBLresults(Y,M,Phi,fit_results)

%% zero out constants
for k=1:size(fit_results.selected_states,2)
     fit_results.sbl_param{k}(1) = 0;
end
state_num = size(fit_results.selected_states,2);

experiment_num = 3;
x0_maxValue    = 50;

%% generate set of initial condiations
x0_vec = zeros(experiment_num,size(Y,1));
x0_vec(:,1) = lhsu(1,10,experiment_num);
x0_vec(:,2:end) = lhsu(zeros(size(Y,1)-1,1),repmat(x0_maxValue,size(Y,1)-1,1),experiment_num);

t_span = 0:0.1:10;

x_sbl_sum = [];
x_sbl_sint_sum = [];
x_sbl_diff_sum = [];
x_orig_sum  = [];
input = [];

ode_solver_opts= [];

%% run ODE solver
for z = 1:experiment_num
    [t_orig,x_orig] = CRN_Simulate_M(M,Y,t_span,x0_vec(z,:));
    x_orig_sum = [ x_orig_sum; x_orig];
   
    for k = 1:size(fit_results,2)
    try
        [t_sbl,x_sbl]   = ode15s(@ode_rhs_from_MAK_phi,t_span,x0_vec(z,:),ode_solver_opts,Phi,fit_results.sbl_param);
        x_sbl_sum   = [ x_sbl_sum;   x_sbl];
    catch ME
        disp('reconstracted Ode integration failed');
    end
    
    end 
end

%% generate report
for k = 1:state_num
    figure('Name',sprintf('ODE simulation x_%d',k))
    plot(x_orig_sum(:,k),'LineWidth',1.5)
    hold on
    plot(x_sbl_sum(:,k),'LineWidth',1.5)
    %         traj_diff(k) = norm(x_orig_sum(:,k) - x_sbl_sum(:,k))/size(x_sbl_sum,1);
    %         title(sprintf('||x_{orig} - x_{sbl}||_2= %g',traj_diff(k)))
    legend(sprintf('%s_{orig}',fit_results.state_name{k}),sprintf('%s_{sbl}',fit_results.state_name{k}),'Location','Best')
    xlabel('Time [min]')
end




