

function [ best_score, best_ptool, best_ptool_map, SQs, P ] = SeedProjection( ideal_ptool, P, tool_mass, task_name, task_function, task_function_params, use_segments, plot_fig )  
    %% default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    %% get the hyper params
    [ fs_fun, n_seeds, weights_ranked_voting, lower_bound_prop_scale ] = ProjectionHyperParams();
    %% get SQs from planting seeds and fitting constrained by the ideal ptool scale
    [ SQs_proj, fit_scores_proj ] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, lower_bound_prop_scale );
    [ ptools_proj, ptools_map_proj, ptools_errors_proj] = ExtractPToolsAltSQs(SQs_proj, tool_mass, fit_scores_proj);  
    %% avaliate GP
    [task_scores, task_scores_sds] = feval(task_function, task_function_params, ptools_proj);
    
    voting_matrix = [ptools_errors_proj' task_scores];    
    rank_voting_matrix = GetRankVector( voting_matrix, 0.001, weights_ranked_voting, {'ascend', 'descend'} );
%     rank_voting_matrix = bsxfun(@times,rank_voting_matrix,weights_ranked_voting(1:size(rank_voting_matrix,2)));
    % get the ptools ixs sorted by the rank voting
    [~,best_options] = sort(rank_voting_matrix,'ascend');
    % get the best ptool to return
    best_ptool = ptools_proj(best_options(1),:);
    best_ptool_map = ptools_map_proj(best_options(1),:);
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