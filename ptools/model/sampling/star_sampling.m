function [list_model_vectors, list_model_names] = star_sampling(params, base_vec)

% init params
list_model_names = {};
list_model_vectors = {};
new_model_vector = [];

for current=1:length(params)
    
    step = (params{current}.rangeMax-params{current}.rangeMin)/(params{current}.samples_nb-1); % samples_nb-1 to have samples_nb tools at the end (including min and max)
    
%    for i=params{current}.rangeMin:step:params{current}.rangeMax
    for i=0:params{current}.samples_nb-1
        
        % reset each time the loop begins
        new_model_vector = base_vec;
        
        new_model_vector(params{current}.id) = params{current}.rangeMin + i*step;
        list_model_vectors{end+1} = new_model_vector;
        
        new_model_name = strcat('_',params{current}.name,'_',int2str(i+1));
        list_model_names{end+1} = new_model_name;
    end
end