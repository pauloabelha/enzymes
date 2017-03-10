function [fit_scores] = flatten_SQ_scores(SQs_grasp_scores,SQs_action_scores)
    fit_scores = zeros(numel(SQs_grasp_scores)*numel(SQs_action_scores),1);
    ix = 0;
    for i=1:numel(SQs_grasp_scores)
        for j=1:numel(SQs_action_scores)
            ix = ix + 1;
            fit_scores(ix) = SQs_grasp_scores(i) + SQs_action_scores(j);
        end
    end
end
