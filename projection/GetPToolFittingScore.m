function [ ptool_fit_scores_grasp, ptool_fit_scores_action ] = GetPToolFittingScore( ptools, fit_scores, usage_ixs )
    ptool_fit_scores_grasp = zeros(size(ptools,1),1);
    ptool_fit_scores_action = zeros(size(ptools,1),1);
    parfor i=1:size(usage_ixs,1)
        ptool_fit_scores_grasp(i) = fit_scores(usage_ixs(i,1));
        ptool_fit_scores_action(i) = fit_scores(usage_ixs(i,2));        
    end

end

