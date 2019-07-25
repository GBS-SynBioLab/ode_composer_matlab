function Phi = build_toggle_switch_dict()
%dictionary mtx
Phi{1}{1}  = @(x,p) ones(size(x,1),1);
Phi{1}{2}  = @(x,p) x(:,1);
Phi{1}{3}  = @(x,p) x(:,2);
% Phi{1}{4}  = @(x,p) hill_func(x(:,2) .* hill_func(x(:,4),p.katc, p.naTc), p.k_t,p.nLacI);


Phi(2) = Phi(1);
% Phi{2}{4}  = @(x,p) hill_func(x(:,1) .* hill_func(x(:,3),p.kiptg,p.nIPTG),p.k_l,p.nTetR);


% for k = 1:2 % state
%     for a = 1:10:100 % slope
%         for b = 0:1:10 % intercept
%             for n = 1:3 % cooperativity
%                 Phi{1}{end+1}  = str2func(sprintf('@(x,p) hill_sweep(x(:,%d),x(:,%d),%d,%d,%d)',k,k+2,a,b,n)); %LacI x(1) + IPTG x(3), TetR(2) + aTc
%             end
%         end
%     end
% end
% % 
% for k = 1:2 % state
%     for a = 1:10:100 % slope
%         for b = 0:1:10 % intercept
%             for n = 1:3 % cooperativity
%                 Phi{2}{end+1}  = str2func(sprintf('@(x,p) hill_sweep(x(:,%d),x(:,%d),%d,%d,%d)',k,k+2,a,b,n)); %LacI x(1) + IPTG x(3), TetR(2) + aTc
%             end
%         end
%     end
% end


% % parameters
% % p.a0_LacI  = 97.26;
% % p.a0_TetR  = 32.52;
% p.k_l      = 31.9392;
% p.k_t      = 9.9995;
% p.katc     = 0.116531;
% p.kiptg    = 0.0906;
% p.naTc     = 1;
% p.nIPTG    = 1;
% p.nLacI    = 2;
% p.nTetR    = 2;
% p.deg_LacI = 0.0165;
% p.deg_TetR = 0.0165;
% 
% 
% dy(1,1) = p.a0_LacI * hill_func(y(2) * hill_func(y(4),p.katc,p.naTc),p.k_t,p.nLacI)   - p.deg_LacI*y(1);
% % TetR protein concentration
% dy(2,1) = p.a0_TetR * hill_func(y(1) * hill_func(y(3),p.kiptg,p.nIPTG),p.k_l,p.nTetR) - p.deg_TetR*y(2);
% 

% hill of hill: 1/(1+((x2/p_tetr)*(1/1+(x4/p_atc)^n_atc))^n_tetr)
for k = 1:2 % state
    for p_tetr = 1:1:20 
        for p_atc = 0.1:1:10 
            for n_atc = 1:2 
                for n_tetr = 1:2
                Phi{1}{end+1}  = str2func(sprintf('@(x,p) 1./(1+((x(:,%d)./%g).*(1./(1+(x(:,%d)./%g).^%d))).^%d)',k,p_tetr,k+2,p_atc,n_atc,n_tetr)); %LacI x(1) + IPTG x(3), TetR(2) + aTc
                end
            end
        end
    end
end
% 
for k = 1:2 % state
    for p_tetr = 1:10:100 
        for p_atc = 0.1:1:10 
            for n_atc = 1:2 
                for n_tetr = 1:2
                Phi{2}{end+1}  = str2func(sprintf('@(x,p) 1./(1+((x(:,%d)./%g).*(1./(1+(x(:,%d)./%g).^%d))).^%d)',k,p_tetr,k+2,p_atc,n_atc,n_tetr)); %LacI x(1) + IPTG x(3), TetR(2) + aTc
                end
            end
        end
    end
end