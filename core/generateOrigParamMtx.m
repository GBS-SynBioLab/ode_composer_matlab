function [Morig,param_idx] = generateOrigParamMtx(M,Y,Y_Dict)
param_idx = [];
Morig = zeros(size(Y_Dict,1),size(Y_Dict,2));
for k =1:size(Y,2)
    [m_val,idx] = max(sum(Y_Dict == Y(:,k)));
    assert(m_val == size(Y,1))
    param_idx(end+1) = idx;
    if ~isempty(idx)
        Morig(:,idx) = M(:,k);
    else
        warning('complex not found')
    end
end


end