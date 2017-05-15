% @params a list of parameters containing, for each parameter :
% .id the number of the parameter to change (ex : 8 for alpha, 9 for beta)
% .range the interval of the changing value to multiply by the loop number corresponding (ex : 1/5th of the initial value)
% .samples_nb the number of desired loops for a parameter (10 in most of the cases)
function [ list_model_vectors, list_model_names ] = cross_sampling( params, base_vec, list_model_vectors, list_model_names, current_loop_nb)
    for ix = 1:params{current_loop_nb}.samples_nb
        % we add an attribute to each param to save the current index value
        % this value is stocked to get the modified value of the param at the final call of the function
        params{current_loop_nb}.curr_ix = ix;
        if current_loop_nb ~= length(params)
            [list_model_vectors, list_model_names] =  cross_sampling(params, base_vec, list_model_vectors, list_model_names, current_loop_nb+1);
        else
            new_vec = base_vec;
            new_name = '';
            for i = 1:length(params)
                % modify the corresponding vec value for each param
                % formula ex with alpha in loop i : new_vec(8) = new_vec(8)*i/5
                new_vec(params{i}.id) = new_vec(params{i}.id)*params{i}.range*params{i}.curr_ix;
                new_name = strcat(new_name,'_',int2str(params{i}.curr_ix));
            end
            list_model_vectors{end+1} = new_vec;
            list_model_names{end+1} = new_name;
        end
    end
end

