% ODE RHS for SBL Phi
function dy = ode_rhs_from_phi(t,y,Phi,fit_results,model)

[~,idx] = min(abs(model.tspan{1}-t));



% if ~isempty(input)
%     ext_aTc  = input(1);
%     ext_IPTG = input(2);
% else
%     ext_aTc = 0;
%     ext_IPTG  =0;
% end

u = model.input{1}(idx,:);

y_ext = [y;u'];

state_num =  size(model.state_names,2);

dy = zeros(state_num,1);

for state = 1: state_num
    dy_tmp = 0;
    w = fit_results(state).sbl_param;
    non_zero = fit_results(state).non_zero_dict{1};
    
    dy_tmp = dy_tmp + cell2mat(cellfun(@(f) f(y_ext'),Phi{state}(non_zero),'UniformOutput',false))*w{1}(non_zero);
    if isnan(dy_tmp)
        fprintf('state: %d, dy_tmp: %g\n',state,dy_tmp);
        error('NaN')
    end
    
    dy(state,1) = dy_tmp;
end
% 
% % IPTG inducer import
% dy(3,1) = p.kin_IPTG * (ext_IPTG - y(3));
% % aTc  inducer import
% dy(4,1) = p.kin_aTc  * (ext_aTc  - y(4));
% end