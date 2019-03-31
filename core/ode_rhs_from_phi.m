% ODE RHS for SBL Phi
function dy = ode_rhs_from_phi(t,y,input,Phi,w,p)

%if ~isempty(input)
ext_aTc  = input(1);
ext_IPTG = input(2);
%end

state_num = size(w,2);
dy = zeros(state_num,1);

for state = 1: state_num
    dy_tmp = 0;
    non_zero = find(abs(w{state}) > 0)';
    
    dy_tmp = dy_tmp + cell2mat(cellfun(@(f) f(y',p),Phi{state}(non_zero),'UniformOutput',false))*w{state}(non_zero);
    if isnan(dy_tmp)
        fprintf('state: %d, dy_tmp: %g\n',state,dy_tmp);
        error('NaN')
    end
    
    dy(state,1) = dy_tmp;
end
% 
% IPTG inducer import
dy(3,1) = p.kin_IPTG * (ext_IPTG - y(3));
% aTc  inducer import
dy(4,1) = p.kin_aTc  * (ext_aTc  - y(4));
end