function [ best_score, best_ptool, best_ptool_map] = ProjectionSimple( P, tool_mass, TaskFunctionGPR, gpr )
    [ ptools, ptools_map ] = ExtractPToolRawPCL( P, tool_mass );
    task_scores = feval(TaskFunctionGPR, gpr, ptools);
    [~,best_ixs] = sort(task_scores,'descend');
    best_score = task_scores(best_ixs(1));
    best_ptool = ptools(best_ixs(1),:);
    best_ptool_map = ptools_map(best_ixs(1),:);
end

