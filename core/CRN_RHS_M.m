function dx=CRN_RHS_M(T,X,M,Y)
%dx=CRN_RHS(T,X,Y,Ak)
%This function gives the right hand side of the ODEs associated to the CRN realization (Y,Ak) at the point X in the state space. The T argument is not used, it is there for syntactical reasons.

if size(X,1) > 1
dx = M*CRN_MonomialPower_vec(X,Y);
else
dx = M*CRN_MonomialPower_vec(X',Y);
dx = dx';
end