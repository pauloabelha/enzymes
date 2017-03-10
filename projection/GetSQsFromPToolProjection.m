function [ SQs, fit_scores, seeds_pcls, usage_ixs] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, lower_bound_prop_scale )   
    CheckIsPointCloudStruct(P);
    [ ~, seeds, seeds_pcls_grasp ] = PlantSeedsPCL( P, n_seeds, max(ideal_ptool(1:3)), lower_bound_prop_scale );
    [SQs_grasp,SQs_grasp_errors,seeds_pcls_grasp] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls_grasp,ideal_ptool(1:3));
    [ ~, seeds, seeds_pcls_action ] = PlantSeedsPCL( P, n_seeds, max(ideal_ptool(8:10)), lower_bound_prop_scale );
    [SQs_action,SQs_action_errors,seeds_pcls_action] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls_action,ideal_ptool(8:10));
    SQs = [SQs_grasp SQs_action];
    usage_ixs = ones(1,size(SQs,2));
    usage_ixs(n_seeds+1:end) = 2;
    fit_scores = [SQs_grasp_errors SQs_action_errors];
    seeds_pcls = [seeds_pcls_grasp seeds_pcls_action];
end

