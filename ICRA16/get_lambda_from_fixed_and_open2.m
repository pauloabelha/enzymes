function lambda = get_lambda_from_fixed_and_open(lambda_f,lambda_o, position)
    lambda_o(length(lambda_o)-2) = position(1);
    lambda_o(length(lambda_o)-1) = position(2);
    lambda_o(length(lambda_o)) = position(3);
    if isempty(lambda_f)
        lambda = lambda_o;
    else
        lambda = zeros(1,11);
        curr_param_index=1; curr_f_index=1;
        in_between_f_ix = 1;
        while curr_param_index <= 11
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
    lambda(6:8) = [0 0 0];
end
