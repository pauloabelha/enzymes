function [ SQs, SQs_errors, seeds_pcls] = GetSQsFromPToolProjection( ideal_ptool, P, n_seeds, verbose )   
    if ~exist('verbose','var')
        verbose = 0;
    end
    CheckIsPointCloudStruct(P);
    if verbose
        disp([char(9) 'Planting #' num2str(n_seeds) ' seeds on pcl...']);
    end
    n_seeds_radii = 5;
    seeds_radii = randi(150,1,n_seeds_radii)/1000;
    [ ~, seeds, seeds_pcls ] = PlantSeedsPCL( P, n_seeds, seeds_radii );
    if verbose
        disp([char(9) 'Fitting SQs to seed pcls...']);
    end
    [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_radii,seeds_pcls,verbose);
end

