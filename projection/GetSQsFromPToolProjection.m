function [ SQs, SQs_errors, seeds_pcls] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, lower_bound_prop_scale )   
    CheckIsPointCloudStruct(P);
    [ ~, seeds, seeds_pcls_grasp ] = PlantSeedsPCL( P, n_seeds, max(ideal_ptool(1:3)), lower_bound_prop_scale );
    [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls_grasp,ideal_ptool(1:3));
end

