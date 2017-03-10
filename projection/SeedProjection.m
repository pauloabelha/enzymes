

function [ best_score, best_ptool, best_ptool_map, SQs, P ] = SeedProjection( ideal_ptool, P, tool_mass, task_name, task_function, task_function_params, use_segments, plot_fig )  
    % default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    % default is not using the segments
    if ~exist('use_segments','var')
        use_segments = 0;
    end
    % get the hyper params
    [ fs_fun, n_seeds, weights_ranked_voting, lower_bound_prop_scale ] = ProjectionHyperParams();
    if use_segments < 2
        % get SQs from planting seeds and fitting constrained by the ideal ptool scale
        [ SQs_proj, fit_scores_proj ] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, lower_bound_prop_scale );
    else
        SQs_proj = {};
        fit_scores_proj = [];
    end    
    %SQs_proj = {}; fit_scores_proj = [];
    % get SQs from free fitting ot the segments
    SQs_segments_orig = {};
    if use_segments > 0 && size(P.segms,2) >= 2
        [ SQs_segments_orig, ~, fit_scores_segms, ] = PCL2SQ( P, 1, 0, 0, [1 1 1 0 1] );
        rmv_empty = 1;
        [alt_SQs,alt_SQs_errors] = GetRotationSQFits( SQs_segments_orig, P.segms, 0.12, rmv_empty );
        SQs_segments = [SQs_segments_orig flatten_cell(alt_SQs)];        
        fit_scores_segms = [fit_scores_segms alt_SQs_errors(:)'];
    else
        if use_segments == 2 && size(P.segms,2) < 2
           error('The point cloud is not segmented and the projection is running with option 2 (using only segmentation)'); 
        else
            SQs_segments = {};
            fit_scores_segms = [];   
        end
    end
    SQs = [SQs_proj SQs_segments];    
    % get all possible ptools from the list of SQs
    [ptools, ptools_maps, usage_ixs] = ExtractPToolsListSQs( SQs, tool_mass );
    % get the fitting score for every ptool
    fit_scores = [fit_scores_proj fit_scores_segms]';
    fit_scores = feval(fs_fun, fit_scores);
    [ ptool_fit_scores_grasp, ptool_fit_scores_action ] = GetPToolFittingScore( ptools, fit_scores, usage_ixs );    
    % filter out ptool with bad fitting score 
%     ptool_fit_ixs = ptool_fit_scores <= max_ptool_fit_score;
%     ptools = ptools(ptool_fit_ixs,:);
%     while isempty(ptools)        
%         max_ptool_fit_score = max_ptool_fit_score + 0.1;
%         ptool_fit_ixs = ptool_fit_scores <= max_ptool_fit_score;
%         ptools = ptools_orig(ptool_fit_ixs,:);        
%     end
%     ptool_fit_scores_grasp = ptool_fit_scores_grasp(ptool_fit_ixs,:);
%     ptool_fit_scores_action = ptool_fit_scores_action(ptool_fit_ixs,:);
    
    % evalute the task function for very ptool
    ptools = ptools(:,1:21);
    [task_scores, task_scores_sds] = feval(task_function, task_function_params, ptools);
    % TODO: TEMPORARY - REMOVE!!
%     [~,best_options] = sort(task_scores,'descend');
%     best_ptool = ptools(best_options(1),:);
%     best_score = task_scores(best_options(1));
%     task_scores = 1./task_scores;
%     task_scores_sds = 1./task_scores_sds;    
    % perform a rank voting on fit and task scoresptool_fit_scores_action
    voting_matrix = [ptool_fit_scores_grasp ptool_fit_scores_action task_scores];    
    rank_voting_matrix = GetRankVector( voting_matrix, 0.001, weights_ranked_voting, {'ascend', 'ascend', 'descend'} );
%     rank_voting_matrix = bsxfun(@times,rank_voting_matrix,weights_ranked_voting(1:size(rank_voting_matrix,2)));
    % get the ptools ixs sorted by the rank voting
    [~,best_options] = sort(rank_voting_matrix,'ascend');
    % get the best ptool to return
    best_ptool = ptools(best_options(1),1:21);
    best_ptool_map = ptools_maps(best_options(1),:);
    best_score = task_scores(best_options(1));
    % plot the N best ptools  
    if plot_fig
        n_best_ptools = 3;
        for i=1:n_best_ptools
            [SQs, transf_lists] = rotateSQs(SQs,1,2,task_name);
            P = Apply3DTransfPCL(P,transf_lists);
            PlotPCLS(P,10000,1);
            PlotSQs({SQs{usage_ixs(best_options(i),1)} SQs{usage_ixs(best_options(i),2)}},1000);
            view([0 0]);
        end
    end
end