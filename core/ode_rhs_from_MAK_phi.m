% ODE RHS for SBL Phi
function dy = ode_rhs_from_MAK_phi(t,y,Phi,w)


state_num = size(w,2);
dy = zeros(state_num,1);

for state = 1: state_num
    non_zero = find(abs(w{state}) > 0)';
    
    dy(state,1) = cell2mat(cellfun(@(f) f(y'),Phi(non_zero),'UniformOutput',false))*w{state}(non_zero);
    if isnan(dy(state,1))
        fprintf('state: %d, dy_tmp: %g\n',state,dy(state,1));
        error('NaN')
    end
end


end