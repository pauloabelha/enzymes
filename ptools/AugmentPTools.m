%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% By Paulo Abelha (p.abelha@abdn.ac.uk)
%
% Inputs:
%   ptools - N * 24 matrix of p-tools
%   n_sampled_ptools - desired number of new p-tools to sample
% Outputs:
%   sampled_ptools - N * 24 matrix with the new p-tools
%   
% This function will augment an existing list of p-tools by
% first fitting a GMM onto each set of params and then sampling 
% a desired number of p-tools from it
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ sampled_ptools, sampled_ptools_AIC, sampled_ptools_BIC, gmm, gmm_AIC, gmm_BIC ] = Augmentptools( ptools, n_sampled_ptools, correlated, output_path )
    if ~exist('correlated','var')
        correlated = 1;
    end
    ptools = PTool2Matrix( ptools );
    if correlated
        [~, gmm, gmm_AIC, gmm_BIC] = sample_ptool(ptools,n_sampled_ptools);
    else
        sampled_scale_grasp = sample_ptool(ptools(:,1:3),n_sampled_ptools);    
        sampled_shape_grasp = sample_ptool(ptools(:,4:5),n_sampled_ptools);    
        sampled_tapering_grasp = sample_ptool(ptools(:,6:7),n_sampled_ptools);    

        sampled_scale_action = sample_ptool(ptools(:,8:10),n_sampled_ptools);    
        sampled_shape_action = sample_ptool(ptools(:,11:12),n_sampled_ptools);    
        sampled_tapering_action = sample_ptool(ptools(:,13:14),n_sampled_ptools);

        ptools(:,15:16) = ptools(:,15:16) + 2*pi;
        sampled_orientation = sample_ptool(ptools(:,15:16),n_sampled_ptools);
        sampled_orientation = sampled_orientation - 2*pi;
        sampled_distance = sample_ptool(ptools(:,17),n_sampled_ptools);
        sampled_mass = sample_ptool(ptools(:,18),n_sampled_ptools);

        sampled_ptools =    [   sampled_scale_grasp sampled_shape_grasp sampled_tapering_grasp...
                                sampled_scale_action sampled_shape_action sampled_tapering_action...
                                sampled_orientation sampled_distance sampled_mass
                            ];
    end
    
    sampled_ptools = get_sampled_ptools(gmm,ptools,n_sampled_ptools);
    sampled_ptools_AIC = get_sampled_ptools(gmm_AIC,ptools,n_sampled_ptools);
    sampled_ptools_BIC = get_sampled_ptools(gmm_BIC,ptools,n_sampled_ptools);    
    
    try
        if exist('output_path','var')
            if correlated
                save([output_path 'sampled_ptools_correlated.mat'],'sampled_ptools');
            else
                save([output_path 'sampled_ptools_uncorrelated.mat'],'sampled_ptools'); 
            end
        end
    catch
        warning(['Could not write sampeld ptools to file ' output_path]);
        return;
    end
    
end

function [ptool_proj, gmm, gmm_AIC, gmm_BIC] = sample_ptool(X,n,plot_fig)
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    % check if X has too many 0s (more than half), return a vector of 0s
    if size(X(sum(X,2)==0),1)/size(X,1) > 0.5
        ptool_proj = zeros(n,size(X,2));
        return;
    end
    X_orig = X;
    X_size_factor = 1;
%     while min(mean(X)) < 100
%        X_size_factor=X_size_factor*10;
%        X=X_orig*X_size_factor; 
%     end
    [gmm,gmm_AIC,gmm_BIC] = FitAndChooseGaussianMixtureModel( X, plot_fig ); 
    ptool_proj = gmm.random(n)/X_size_factor;
end

function sampled_ptools = get_sampled_ptools(gmm,ptools,n_sampled_ptools)
    

    n_dims_ptools = size(ptools,2);
    
    mins = zeros(1,n_dims_ptools);
    mins(1:3) = 0.0001;
    mins(4:5) = 0.1;
    mins(6:7) = -1;
    mins(8:10) = 0.0001;
    mins(11:12) = 0.1;
    mins(13:14) = -1;
    mins(15:17) = -1;
    mins(18) = 0;
    mins(19:21) = -pi;
    mins(22) = 0.001;
    mins(23) = 0.001;
    
    maxs = zeros(1,n_dims_ptools);
    maxs(1:3) = 0.5;
    maxs(4:5) = 2;
    maxs(6:7) = 1;
    maxs(8:10) = 0.25;
    maxs(11:12) = 2;
    maxs(13:14) = 1;
    maxs(15:17) = 1;
    maxs(18) = pi;
    maxs(19:21) = pi;
    maxs(22) = 0.5;
    maxs(23) = 1;  
    
%     mins = min(ptools);
%     maxs = max(ptools);
    
    FINAL_SIZE = n_sampled_ptools;
    SIZE_SAMPLE = n_sampled_ptools;
        
    final_sampled_ptools = [];
    safe_iter_max = 1e6;
    n_iter = 0;
    
%     final_sampled_ptools = gmm.random(SIZE_SAMPLE);
    
    while size(final_sampled_ptools,1) < FINAL_SIZE
        n_iter = n_iter + 1;
        if n_iter > safe_iter_max
            error('Reached maximum number of iterations');
        end
        sampled_ptools = gmm.random(SIZE_SAMPLE);
        ixs = true(SIZE_SAMPLE,1);
        for j=1:n_dims_ptools
            ixs = ixs & sampled_ptools(:,j) >= mins(j) & sampled_ptools(:,j) <= maxs(j);
        end
        final_sampled_ptools = [final_sampled_ptools; sampled_ptools(ixs,:)];
        disp(['Searching for samples within bounds: ' num2str(round(100*size(final_sampled_ptools,1)/FINAL_SIZE)) ' %']);
    end     
    
    sampled_ptools = final_sampled_ptools(1:FINAL_SIZE,:);
end

