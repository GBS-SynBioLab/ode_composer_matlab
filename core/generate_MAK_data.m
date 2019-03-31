function [x,dxdt,t_out] = generate_MAK_data(Y,M,Tf,h,x0,mode)

if strcmpi(mode,'euler')
    x(1,:) = x0;
    
    for k = 2:Tf
        % euler step
        x(k,:) = x(k-1,:) + h.* CRN_RHS_M([],x(k-1,:), M,Y);
        dxdt(k,:) = (x(k,:) - x(k-1,:))/h;
    end
elseif strcmpi(mode,'ode45')
    
    [t_out,x] = CRN_Simulate_M(M,Y,Tf,x0);
    
    for z=1:size(x,1)
        %TODO: support vector data
        dxdt(z,:) = CRN_RHS_M([],x(z,:), M,Y);
    end
end
