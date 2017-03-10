function [lambda_o,lambda_lower,lambda_upper] = ...
        get_lambda_o_from_f_and_default(lambda_f,lambda_default,lambda_lower_def,lambda_upper_def)
    if isempty(lambda_f)
        lambda_o = lambda_default;
        lambda_lower = lambda_lower_def;
        lambda_upper = lambda_upper_def;
    else
        lambda_o = zeros(1,length(lambda_default)-size(lambda_f,2));
        lambda_lower = zeros(size(lambda_o));
        lambda_upper = zeros(size(lambda_o));
        curr_param_index=1; curr_f_index=1;
        in_between_f_ix = 1;
        while curr_param_index <= length(lambda_default)
            if curr_f_index<=length(lambda_f)
                f_param_index = lambda_f(1,curr_f_index);
                %get all params before the first current fixed
                for in_between_indexes=curr_param_index:f_param_index-1
                    lambda_o(in_between_f_ix) = lambda_default(in_between_indexes);
                    lambda_lower(in_between_f_ix) = lambda_lower_def(in_between_indexes); 
                    lambda_upper(in_between_f_ix) = lambda_upper_def(in_between_indexes);
                    in_between_f_ix = in_between_f_ix + 1;
                end      
                curr_f_index=curr_f_index+1;
                curr_param_index=f_param_index+1;
            else
                lambda_o(in_between_f_ix) = lambda_default(f_param_index+1);
                lambda_lower(in_between_f_ix) = lambda_lower_def(f_param_index+1); 
                lambda_upper(in_between_f_ix) = lambda_upper_def(f_param_index+1);
                in_between_f_ix=in_between_f_ix+1;
                curr_param_index = curr_param_index+1;
                f_param_index=f_param_index+1;
            end
        end
    end
end