% hill dict (IPTG^h1 /(Km1^h1 + IPTG^h1))
function Phi = hill_dict_generator()
Phi = {};
for k = 1:1 % state
    for Km = 0:1:10 % intercept
        for h1 = 1:3 % cooperativity
            Phi{end+1}  = str2func(sprintf('@(x,u) (u(:,1).^%d ./(%d^%d + u(:,1).^%d))',h1,Km,h1,h1));
        end
    end
end

end
