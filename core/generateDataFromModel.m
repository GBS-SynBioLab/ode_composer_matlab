function model = generateDataFromModel(model)
%
%
%
% sampling time
% model.h  = [];%0.01;
% simulation time points
% model.t_span   = 0:model.h:10;
%
% % variance of the additive white Guassian noise
% model.variance = 0.2;

if ~isfield(model,'h')
    model.h = [];
end

% TODO down samping
model.sample_num = 0;

model.state_num = size(model.Y,1);

% generate set of initial condiations
x0_vec = zeros(model.experiment_num,model.state_num);
x0_vec(:,1) = lhsu(1,10,model.experiment_num);
x0_vec(:,2:end) = lhsu(zeros(model.state_num-1,1),repmat(model.x0_maxValue,model.state_num-1,1),model.experiment_num);

y = {};
dydt = {};
sim_mode ='ode45';

if isfield(model,'t_span')
    t_vec = model.t_span;
else
    assert(isfield(model,'t_f'))
    t_vec = [0 model.t_f];
end

for exp_idx=1:size(x0_vec,1)
    % solve the ODE
    [y_tmp,dydt_tmp_45,t_span] = generate_MAK_data(model.Y,model.M,t_vec,model.h,x0_vec(exp_idx,:),sim_mode);
    
    % TODO down sampling
    if model.sample_num > 0
        sample_idx     = sort(round(lhsu(2,size(y_tmp,1),model.sample_num)));
        if sample_idx(1) ~= 1
            sample_idx(1) = 1;
        end
        y_tmp = y_tmp(sample_idx,:);
        t{exp_idx,:} = t_span(sample_idx);
    else
        t{exp_idx,:} = t_span;
    end
    
    % calculate noise
    avg_signal = y_tmp(1,:);
    std_value(exp_idx,:) = avg_signal./model.SNR;
    noise = +randn(size(y_tmp,1),model.state_num).*repmat(std_value(exp_idx,:),size(y_tmp,1),1);
    y{exp_idx} = y_tmp+noise;
    
    % calculate derivate
    if ~isfield(model,'derivative') || strcmp(model.derivative,'ode_RHS')
        dydt{exp_idx} = dydt_tmp_45+noise;
    else
        for state =1:model.state_num
            dydt{exp_idx}(:,state) = diff(y{exp_idx}(:,state))./diff(t{exp_idx});
        end
    end
end

%% generate output structure
model.variance = std_value;
model.y = y;
model.dydt = dydt;
model.t = t;
model.x0_vec = x0_vec;

