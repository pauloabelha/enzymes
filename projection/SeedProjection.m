

function [ best_scores, best_categ_scores, best_ptools, best_ptool_maps, SQs, P ] = SeedProjection( P, tool_mass, task_name, task_function, task_function_params, n_seeds, add_segms, only_segms, verbose, plot_fig, iter )  
    %% default is not verbose
    if ~exist('verbose','var')
        verbose = 0;
    end 
    %% default is not plotting
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end 
    %% get the hyper params
    [ n_seeds_hyper, n_seeds_radii, weights ] = ProjectionHyperParams();
    n_weights = size(weights,1);
    if ~exist('n_seeds','var') || n_seeds < 1
        n_seeds = n_seeds_hyper;
    end
    %% get SQs from planting seeds and fitting constrained by the ideal ptool scale
    [ SQs_proj, fit_scores_proj ] = GetSQsFromPToolProjection( P, n_seeds, n_seeds_radii, add_segms, only_segms, verbose );
    if verbose 
        n_valid_SQs = sum(~cellfun(@isempty,SQs_proj(:)));
        disp([char(9) 'Extracting p-tools from the ' num2str(n_valid_SQs) ' valid SQs (fitted with good rotations)']);
    end 
    [ ptools_proj, ptools_map_proj, ptools_errors_proj] = ExtractPToolsAltSQs(SQs_proj, tool_mass, fit_scores_proj);  
    % any ptool with some error in its fitting score receives max (worse)
    % minimum fit score will never be 0
    % So, inverse of niminimum will never be Inf
    ptools_errors_proj(ptools_errors_proj==0) = max(ptools_errors_proj);
    %% avaliate GP
    if verbose 
        disp([char(9) 'Evaluating task function on ' num2str(size(ptools_proj,1)) ' p-tools...']);
    end
    task_scores = feval(task_function, task_function_params, ptools_proj);   
    %% get weight voting
    % get voting matrix (higher the value the better)
    voting_matrix = [1./ptools_errors_proj; task_scores'];     
    if verbose 
        disp([char(9) 'Calculating rank voting for ' num2str(n_weights) ' different weight values...']);
    end        
    voting_matrix_normalised = NormaliseData(voting_matrix')';
    %% get ranking for fit score
    [~,fit_score_sort_ix] = sort(voting_matrix_normalised(1,:)+randi(10,1,size(voting_matrix_normalised(1,:),1))/10^6,'ascend');
    rank_fit_score = fit_score_sort_ix;
    for i=1:numel(rank_fit_score)
        rank_fit_score(fit_score_sort_ix(i)) = i;
    end
    %% get ranking for task score
    [~,task_score_sort_ix] = sort(voting_matrix_normalised(2,:)+randi(10,1,size(voting_matrix_normalised(2,:),1))/10^6,'ascend');
    rank_task_score = rank_fit_score;
    for i=1:numel(rank_task_score)
        rank_task_score(task_score_sort_ix(i)) = i;
    end
    %% get max ranked vote element
    rank_sum = rank_fit_score + rank_task_score;
    [~,best_elem_ix] = max(rank_sum);
    % outer product of weights with task scores normalised in the matrix
%     a = weights * voting_matrix_normalised(2,:);
%     final_mtx = a + repmat(voting_matrix_normalised(1,:),200,1);   
    a = weights * rank_task_score;
    final_mtx = a + repmat(rank_fit_score,n_weights,1);   
    [~,best_ixs] = max(final_mtx,[],2);
    % get the best ptool to return
    best_ptools = ptools_proj(best_ixs,:);
    best_ptool_maps = ptools_map_proj(best_ixs,:);
    best_fit_scores = ptools_errors_proj(best_ixs);
    best_scores = task_scores(best_ixs);
    best_categ_scores = TaskCategorisation(best_scores,task_name);
    if verbose 
        disp([char(9) 'Variance of best category scores:' char(9) num2str(var(best_categ_scores))]);
    end  
    best_ix = floor(n_weights/2)+1;
    best_score = best_scores(best_ix);
    best_fit_score = best_fit_scores(best_ix);
%     IX=1; GenerateSimulationForPCLWithPtool( P, best_ptools(IX,:), best_ptool_maps(IX,:), task_name, ['good_' num2str(tool_mass) '/'] );
%     IX=200; GenerateSimulationForPCLWithPtool( P, best_ptools(IX,:), best_ptool_maps(IX,:), task_name, ['bad_' num2str(tool_mass) '/'] );
    if verbose 
        disp([char(9) 'Best p-tool found (task score; fit score)' char(9) num2str(best_score) char(9) num2str(best_fit_score)]);   
    end
    if plot_fig
        figure;
        Q = RotatePCLsWithPtoolsForTask(P,best_ptools(101,:), best_ptool_maps(101,:),task_name);
        Q=Q{1};
        PlotPCLSegments(Q); hold on;
        PlotPtools(best_ptools(101,:),task_name,0,{'c', 'k'}); hold off;
    end
end