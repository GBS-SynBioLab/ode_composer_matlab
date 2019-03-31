function printOutModel(fit_res,Morig,Phi,print_state)
state_num = size(fit_res.selected_states,2);

for k=1:state_num
    if ~isempty(print_state) && print_state ~= k
        continue
    end
    state = fit_res.selected_states(k);
    fprintf('state: %s\n',fit_res.state_name{state})
    
    orig = abs(Morig(state,:)) > 0;
    est  = (abs(fit_res.sbl_param{k}) > 0)';
    
    % correct base functions
    correct_ones = orig & est;
    green = find(correct_ones);
    
    % false positive
    false_pos = ~orig & est;
    black = find(false_pos);
    % false negative
    false_neg = orig & ~est;
    red = find(false_neg);
    
    for zz=1:size(fit_res.sbl_param{k},1)
        if correct_ones(zz)
            str = [strrep(func2str(Phi{zz}),'@(x)','') ' '  num2str(fit_res.sbl_param{k}(zz)) '  o:' num2str(Morig(state,zz))];
            cprintf([0.1 0.5 0.1],[' ' str '\n']);
        elseif false_pos(zz)
            str = [strrep(func2str(Phi{zz}),'@(x)','') ' '  num2str(fit_res.sbl_param{k}(zz)) '  o:' num2str(Morig(state,zz))];
            cprintf('text',[' ' str '\n']);
        elseif false_neg(zz)
            str = [strrep(func2str(Phi{zz}),'@(x)','') ' '  num2str(fit_res.sbl_param{k}(zz)) '  o:' num2str(Morig(state,zz))];
            cprintf('red',[' ' str '\n']);
        end
    end
    fprintf('----------------\n')
end