function [ SQs, SQs_errors, seeds_pcls] = GetSQsFromPToolProjection( P, n_seeds, n_seeds_radii, add_segms, verbose )   
    if ~exist('verbose','var')
        verbose = 0;
    end
    CheckIsPointCloudStruct(P);
    if verbose
        disp([char(9) 'Planting ' num2str(n_seeds) ' seeds, with ' num2str(n_seeds_radii) ' different radii on pcl...']);
    end
    seeds_radii = randi(150,1,n_seeds_radii)/1000;
    [ ~, ~, seeds_pcls ] = PlantSeedsPCL( P, n_seeds, seeds_radii );    
    if add_segms
        segm_pcls = cell(1,size(P.segms,2));
        parfor i=1:size(P.segms,2)
            segm_pcls{i} = P.segms{i}.v;
        end
        seeds_pcls = [seeds_pcls segm_pcls];
    end    
    [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds_pcls,verbose);
end

