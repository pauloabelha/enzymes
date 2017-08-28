function [ n_seeds, n_seeds_radii, weights ] = ProjectionHyperParams(  )
    % handle for fitting score function
%     fs_fun = @FittingScoreFunction;
    % number of seeds to plant in the pcl
    n_seeds = 10;
    % number of different radii for each seed sphere to cut ou tthe pcl
    n_seeds_radii = 5;
    % weight vector
    beg_weight = 0;
    step_weight = 0.01;
    mid_weight = 1;
    end_weight = mid_weight/step_weight;
    weights = [beg_weight:step_weight:(mid_weight-step_weight) mid_weight:mid_weight:end_weight]';
end

