% hill sweep wrapper to avoid numerical issues (e.g. divion by zero)
function y = hill_sweep(state_1,state_2,a,b,n)


if state_1 == 0
    % to avoid division by zero
    y = 1;
else
    denom = (1 + ( state_1./(a.*state_2+b) ).^n);
    if denom == 0
        y = 1;
    else
        y = 1 ./ denom;
    end
end

if abs(y) < eps
    y = 0;
end

end