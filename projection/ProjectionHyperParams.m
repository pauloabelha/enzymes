function [ fs_fun, n_seeds, weights_ranked_voting, lower_bound_prop_scale, max_ptool_fit_score ] = ProjectionHyperParams(  )
    % handle for fitting score function
    fs_fun = @FittingScoreFunction;
    % number of seeds to plant in the pcl
    n_seeds = 5;
    % weights for grasping, action and task function
    weights_ranked_voting = [1 1];
    % lower bound proportion on seed pcl radius
    lower_bound_prop_scale = 3;
    max_ptool_fit_score = 2;
end

