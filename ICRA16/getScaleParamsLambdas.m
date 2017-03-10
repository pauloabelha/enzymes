function scale_params = getScaleParamsLambdas(lambda_f, default_lambda_o)
    if isempty(lambda_f)
        scale_params = default_lambda_o(1:3);
    else
        scale_params = zeros(1,3);
        curr_param_index=1; curr_f_index=1;
        in_between_f_ix = 1;
        while curr_param_index <= 13
            if curr_f_index<=length(lambda_f)
                f_param_index = lambda_f(1,curr_f_index);
                if f_param_index >= 1 && f_param_index <= 3
                    scale_params(f_param_index) = lambda_f(2,curr_f_index);
                end
                %get all params before the first current fixed
                for in_between_indexes=curr_param_index:f_param_index-1
                    if in_between_indexes >= 1 && in_between_indexes <= 3
                        scale_params(in_between_indexes) = default_lambda_o(in_between_f_ix);
                        in_between_f_ix = in_between_f_ix + 1;
                    end                    
                end      
                curr_f_index=curr_f_index+1;
                curr_param_index=f_param_index+1;
            else
                if f_param_index+1 >= 1 && f_param_index+1 <= 3
                    scale_params(f_param_index+1) = default_lambda_o(in_between_f_ix);                    
                    in_between_f_ix=in_between_f_ix+1;
                end    
                f_param_index=f_param_index+1;
                curr_param_index = curr_param_index+1;                
            end
        end
    end
end