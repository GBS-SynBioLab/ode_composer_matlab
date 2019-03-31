function [Dic,Phi,Y_Dict, monome] = generateMAKDictionary(model,polyorder)

yin = model.y;
state_num = model.state_num;
exp_num = model.experiment_num;

for exp_idx = 1:size(yin,2)
    % each experiment can have different length
    y = yin{exp_idx};
    n = size(y,1);
    % yout = zeros(n,1+nVars+(nVars*(nVars+1)/2)+(nVars*(nVars+1)*(nVars+2)/(2*3))+11);
    
    % poly order 0
    Dic{exp_idx}(:,1) = ones(n,1);
    % Phi and monomes are the same for all experiments, so it will be filled in the last
    % round
    Phi = {};
    monome = {};
    Phi{1} = @(x,p) ones(size(x,1),1);
    monome{1} = 0; % numerical composition of the monomes for nonneg constraints.
    Y_Dict = zeros(state_num,1);
    % poly order 1
    for z=1:state_num
        Dic{exp_idx}(:,end+1) = y(:,z);
        Phi{end+1} = str2func(sprintf('@(x) x(:,%d)',z));
        monome{end+1} = z;
        Y_Dict(:,end+1) = double(1:state_num == z)';
    end
    
    if(polyorder>=2)
        % poly order 2
        for z=1:state_num
            for q=z:state_num
                Dic{exp_idx}(:,end+1) = y(:,z).*y(:,q);
                Phi{end+1} = str2func(sprintf('@(x) x(:,%d)*x(:,%d)',z,q));
                monome{end+1} = [z q];
                Y_Dict(:,end+1) = double(1:state_num == z)' + double(1:state_num == q)';
            end
        end
    end
    
    if(polyorder>=3)
        % poly order 3
        for z=1:state_num
            for q=z:state_num
                for k=q:state_num
                    Dic{exp_idx}(:,end+1) = y(:,z).*y(:,q).*y(:,k);
                    Phi{end+1} = str2func(sprintf('@(x) x(:,%d)*x(:,%d)*x(:,%d)',z,q,k));
                    monome{end+1} = [z q k];
                    Y_Dict(:,end+1) = double(1:state_num == z)' + double(1:state_num == q)' + double(1:state_num == k)';
                end
            end
        end
    end
    
    if(polyorder>=4)
        % poly order 4
        for z=1:state_num
            for q=z:state_num
                for k=q:state_num
                    for l=k:state_num
                        Dic{exp_idx}(:,end+1) = y(:,z).*y(:,q).*y(:,k).*y(:,l);
                        Phi{end+1} = str2func(sprintf('@(x) x(:,%d)*x(:,%d)*x(:,%d)*x(:,%d)',z,q,k,l));
                        monome{end+1} = [z q k l];
                        Y_Dict(:,end+1) = double(1:state_num == z)' + double(1:state_num == q)' + double(1:state_num == k)' + double(1:state_num == l)';
                    end
                end
            end
        end
    end
    
    if(polyorder>=5)
        % poly order 5
        for z=1:state_num
            for q=z:state_num
                for k=q:state_num
                    for l=k:state_num
                        for m=l:state_num
                            Dic{exp_idx}(:,end+1) = y(:,z).*y(:,q).*y(:,k).*y(:,l).*y(:,m);
                            Phi{end+1} = str2func(sprintf('@(x) x(:,%d)*x(:,%d)*x(:,%d)*x(:,%d)*x(:,%d)',z,q,k,l,m));
                            monome{end+1} = [z q k l m];
                            Y_Dict(:,end+1) = double(1:state_num == z)' + double(1:state_num == q)' + double(1:state_num == k)' + double(1:state_num == l)' + double(1:state_num == m)';
                        end
                    end
                end
            end
        end
    end
    
    
end