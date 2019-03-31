function [tout,yout] = CRN_Simulate_M(M,Y,t_vec,x0)
%[tout,yout] = CRN_Simulate(Y,Ak,t0,tf,x0)
%This function simulates the dynamics of a given CRN
%INPUTS:	
%		Y, Ak: CRN realization to be simulated
%		t0: initial time
%		tf: final time
%		x0: initial condition vector
%OUTPUTS:	
%		tout: time vector
%		yout: computed concentrations
%REMARK: the numerical method can be selected through CRN_options(3)
global CRN_options
if (size(CRN_options,1)>0) %if there are any options defined
  sim_meth=CRN_options(3);
else
  sim_meth=1; %select default simulation method
end

%tic
% if (sim_meth==0)
  [tout,yout]=ode15s(@(t,y) CRN_RHS_M(t,y, M,Y), t_vec, x0);
% else
%   [tout,yout]=ode15s(@(t,y) CRN_RHS_M(t,y, M,Y), t_vec, x0);
% end
%toc
