function [ list_model_vectors, list_model_names ] = SampleModelVectors(base_action_vector, sampling_option )

% list_model_names = {};
% list_model_vectors = {};

%%
% switch sampling_option
%     case 'star_sampling'
%         modified_var = 'scheibeX';
%         next_var = '';
%         new_model_name = '';
%         while ~strcmp(modified_var,'nothing')
%             for i=1:10
%                 new_model_vector = base_action_vector;
%                 switch modified_var
%                     case 'scheibeX'
%                         new_model_vector(1) = new_model_vector(1)*i/5;
%                         next_var = 'scheibeY';
%                     case 'scheibeY'
%                         new_model_vector(2) = new_model_vector(2)*i/5;
%                         next_var = 'nothing';
%                     case 'alpha' % angle_z
%                         new_model_vector(8) = new_model_vector(8)*i/5; % 0 to pi()
%                         next_var = 'beta';
%                     case 'beta' % angle_centers
%                         new_model_vector(9) = new_model_vector(9)*i/2;
%                         next_var = 'dist_centers';
%                     case 'dist_centers'
%                         new_model_vector(10) = new_model_vector(10)*i/5;
%                         next_var = 'mass';
%                     case 'mass'
%                         new_model_vector(11) = new_model_vector(11)*i/2;
%                         next_var = 'nothing';
%                     otherwise % break for loop. Should be useless
%                         break
%                 end
%                 list_model_vectors{end+1} = new_model_vector;
%                 new_model_name = strcat(modified_var,'_',int2str(i));
%                 list_model_names{end+1} = new_model_name;
%             end
%             modified_var = next_var;
%         end
%         
%     case 'cross_sampling'
        
%         k = {'scheibeX', 'scheibeY', 'alpha', 'beta'};
%         v = {1, 2, 8, 9};
%         range = {1/5, 1/5, 1/5, 1/2};
%         samples_nb = {10, 10, 10, 10};
%         ix = {};
%         params = containers.Map(k,v);
%         params_range = containers.Map(k,range);
%         params_curr_ix = containers.Map();
%         
        

        
        base_samples_nb = 10;
        
        % Name is used in star sampling
        % Range is only for cross sampling for now
        
        %% scheibe X
        scheibeX.name = 'scheibeX';
        scheibeX.id = 1;
        scheibeX.range = 1/5;
        scheibeX.rangeMin = 0.002;
        scheibeX.rangeMax = 0.15;
        scheibeX.samples_nb = base_samples_nb;
        
        %% scheibe Y
        scheibeY.name = 'scheibeY';
        scheibeY.id = 2;
        scheibeY.range = 1/5;
        scheibeY.rangeMin = 0.002;
        scheibeY.rangeMax = 0.15;
        scheibeY.samples_nb = base_samples_nb;
        
        %% scheibe Z
        scheibeZ.name = 'scheibeZ';
        scheibeZ.id = 3;
        scheibeZ.range = 1/5;
        scheibeZ.rangeMin = 0.002;
        scheibeZ.rangeMax = 0.15;
        scheibeZ.samples_nb = base_samples_nb;
        
        %% alpha
        alpha.name = 'alpha';
        alpha.id = 8;
        alpha.range = 1/5;
        alpha.rangeMin = 0;
        alpha.rangeMax = pi();
        alpha.samples_nb = base_samples_nb;
        
        %% beta
        beta.name = 'beta';
        beta.id = 9;
        beta.range = 1/2;
        beta.rangeMin = 0;
        beta.rangeMax = pi();
        beta.samples_nb = base_samples_nb;
        
        %% centers distance
        dist.name = 'dist';
        dist.id = 10;
        dist.range = 1/5;
        dist.rangeMin = 0.01;
        dist.rangeMax = 0.3;
        dist.samples_nb = base_samples_nb;
        
        %% mass
        mass.name = 'mass';
        mass.id = 11;
        mass.range = 1/5;
        mass.rangeMin = 0.005;
        mass.rangeMax = 2;
        mass.samples_nb = base_samples_nb;
        
        %% Modify this list to change the parameters taken in account for sampling
        params = { scheibeX, scheibeY, scheibeZ, alpha, beta, dist, mass};
        
        switch sampling_option
            case 'star_sampling'
                [list_model_vectors, list_model_names] = star_sampling(params, base_action_vector);
            case 'cross_sampling'
                list_model_names = {};
                list_model_vectors = {};
                current_loop_nb = 1;
                [list_model_vectors, list_model_names] = cross_sampling(params, base_action_vector, list_model_vectors, list_model_names, current_loop_nb);

            otherwise
                error('star_sampling or cross_sampling ? Please choose a correct option next time...');        
        end

end

