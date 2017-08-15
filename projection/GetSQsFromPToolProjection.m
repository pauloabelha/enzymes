function [ SQs, SQs_errors, seeds_pcls] = GetSQsFromPToolProjection( P, n_seeds, n_seeds_radii, verbose )   
    if ~exist('verbose','var')
        verbose = 0;
    end
    CheckIsPointCloudStruct(P);
    if verbose
        disp([char(9) 'Planting #' num2str(n_seeds) ' seeds on pcl...']);
    end
    seeds_radii = randi(150,1,n_seeds_radii)/1000;
    [ ~, seeds, seeds_pcls ] = PlantSeedsPCL( P, n_seeds, seeds_radii );
    [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_radii,seeds_pcls,verbose);
end

