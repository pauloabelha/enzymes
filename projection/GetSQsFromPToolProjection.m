function [ SQs, SQs_errors, seeds_pcls] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, verbose )   
    if ~exist('verbose','var')
        verbose = 0;
    end
    CheckIsPointCloudStruct(P);
    if verbose
        disp([char(9) 'Planting #' num2str(n_seeds) ' seeds on pcl...']);
    end
    [ ~, seeds, seeds_pcls_grasp ] = PlantSeedsPCL( P, n_seeds, max(ideal_ptool(1:3)) );
    if verbose
        disp([char(9) 'Fitting SQs to seed pcls...']);
    end
    [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls_grasp,ideal_ptool(1:3));
end

