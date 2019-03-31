function out = CRN_MonomialPower_vec (x,Y)
%out = CRN_MonomialPower (x,p)
%This function computes the value of a monomial x^p.
%INPUT:
%        x: (n x 1) dimensional independent variable value
%        p: (n x 1) dimensional exponent vector
%OUTPUT:
%        out: value of x^p

out = prod(repmat(x,1,size(Y,2)).^Y)';
