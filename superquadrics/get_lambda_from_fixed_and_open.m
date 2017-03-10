function lambda = get_lambda_from_fixed_and_open(lambda_f,lambda_o,max_lambda_size)
    if isempty(lambda_f)
        lambda = lambda_o;
    else
        lambda = zeros(1,max_lambda_size);
        curr_param_index=1; curr_f_index=1;
        in_between_f_ix = 1;
        while curr_param_index <= max_lambda_size
            if curr_f_index<=length(lambda_f)
                f_param_index = lambda_f(1,curr_f_index);
                lambda(f_param_index) = lambda_f(2,curr_f_index);
                %get all params before the first current fixed
                for in_between_indexes=curr_param_index:f_param_index-1
                    lambda(in_between_indexes) = lambda_o(in_between_f_ix);
                    in_between_f_ix = in_between_f_ix + 1;
                end      
                curr_f_index=curr_f_index+1;
                curr_param_index=f_param_index+1;
            else
                lambda(f_param_index+1) = lambda_o(in_between_f_ix);
                in_between_f_ix=in_between_f_ix+1;
                curr_param_index = curr_param_index+1;
                f_param_index=f_param_index+1;
            end
        end
    end
end
