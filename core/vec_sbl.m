function fit_res = vec_sbl(sbl_params,config,model)
% vec_sbl - solves the parameter estimation with SBL
%
% fit_res = vec_sbl(sbl_params,config) gets a model in sbl_params struct and the
% algorithms behavior is configured by config struct

% 
if strcmpi(config.mode,'SMV')
    state_num = size(sbl_params.y{1},2);
    param_num = size(sbl_params.A{1},2);
    
    Dictionary = [];
    y = [];
    for exp_idx = 1:model.experiment_num
        % adjust size if needed
        if size(sbl_params.A{exp_idx},1) > size(sbl_params.y{exp_idx},1)
            size_diff = size(sbl_params.A{exp_idx},1)-size(sbl_params.y{exp_idx},1);
            assert(size_diff >= 0);
            offset = 1+size_diff;
            tmp_A = sbl_params.A{exp_idx}(offset:end,:);
        else 
            tmp_A = sbl_params.A{exp_idx};
        end
        Dictionary = [Dictionary; tmp_A];
        y = [y; sbl_params.y{exp_idx}];
    end
else
    error('not yet implemented')
end


lambda = mean(sbl_params.std,1);


RR = [];

if isfield(config,'selected_dict')
    if ~iscell(config.selected_dict)
        config.selected_dict = repmat({config.selected_dict},1,state_num);
    end
    for k=1:state_num
        config.exclude_param{k} = setdiff(1:param_num,config.selected_dict{k});
    end
end

max_iter = config.max_iter;
[data_num,dict_num]=size(Dictionary);

% initialisation of the variables
Z=ones(dict_num, max_iter,state_num);
Gamma=zeros(dict_num, max_iter,state_num);
Z_tmp=zeros(dict_num, max_iter,state_num);
w_estimate=cell(max_iter,1);

pre_W = [];
for iter=1:1:max_iter
    fprintf('iter num: %d\n',iter)
    yalmip('clear');
    W = sdpvar(param_num,state_num,1,'full');
    if isfield(config,'subconv')
        R = sdpvar(state_num,1,'full');
    end
    F = [];
    opts =[];
    %     if iter > 1
    %         assign(W,pre_W);
    %         opts = sdpsettings('usex0',1,'verbose', 2,'fmincon.max_iter',10000,'fmincon.MaxFunEvals',30000,'debug',1);
    %     else
    %opts=sdpsettings('verbose', 2,'fmincon.max_iter',10000,'fmincon.MaxFunEvals',30000);
    opts=sdpsettings('verbose', 0,'gurobi.IterationLimit',2000,'gurobi.TimeLimit',50);
    
    %     end
    
    if isfield(config,'nonneg') & ~isempty(config.nonneg)
        for k=1:state_num
            F = F + [W(config.nonneg{k},k) >= 0];
        end
    end
    if isfield(config,'exclude_param') & ~isempty(config.exclude_param)
        for k=1:state_num
            F = F + [W(config.exclude_param{k},k) == 0];
        end
    end
    if isfield(config,'subconv')
        F = F + [R >= 1e-5];
        F = F + [R'*W' <=0];
    end
    h = 0;
    for k=1:state_num
        residuals = y(:,k)-Dictionary*W(:,k);
        h = h + lambda(k)*norm( Z(:,iter,k).*W(:,k), 1 ) + 0.5*norm(residuals,2);
    end
    if isfield(config,'subconv')
        h = h + R;
    end
    tic;
    opt= optimize(F,h,opts)
    toc;
    W = double(W);
    pre_W = W;
    w_estimate{iter}= W;
    if isfield(config,'subconv')
        RR = double(R);
    end   
    for k=1:state_num
        Gamma(:,iter,k)=Z(:,iter,k).^-1.*abs(W(:,k));
        Dictionary0=lambda(k)*eye(data_num)+Dictionary*diag(Gamma(:,iter,k))*Dictionary';
        Z_temp(:, iter,k)=diag(Dictionary'*(Dictionary0\Dictionary));
        Z(:,iter+1,k)=abs(sqrt(Z_temp(:, iter,k)));
    end
end

%% Generating the fit results

for k=1:state_num
    w_est{k} = w_estimate{end}(:,k);
    gamma{k} = Gamma(:,end,k);
end

fit_res.A = sbl_params.A;
if isfield(config,'selected_dictionaries')
    fit_res.selected_dict = config.selected_dict;
end
if  isfield(config,'selected_states')
    fit_res.selected_states = config.selected_states;
end
fit_res.y = sbl_params.y;
fit_res.w_est = w_est;
fit_res.gamma = gamma;
fit_res.name = sbl_params.name;
fit_res.experiment_num = model.experiment_num;
fit_res.zero_dict = [];
fit_res.non_zero_dict = [];
fit_res.sbl_param = [];

disp('end')