function [ SQs, SQs_errors, seeds_pcls,SQs_orig] = GetSQsFromPToolProjection( P, n_seeds, n_seeds_radii, add_segms, only_segms, verbose, parallel )   
    if ~exist('verbose','var')
        verbose = 0;
    end
    CheckIsPointCloudStruct(P);
    if verbose
        disp([char(9) 'Planting ' num2str(n_seeds) ' seeds, with ' num2str(n_seeds_radii) ' different radii on pcl...']);
    end
    if add_segms || only_segms
        segm_pcls = cell(1,size(P.segms,2));
        if parallel
            parfor i=1:size(P.segms,2)
                segm_pcls{i} = P.segms{i}.v;
            end
        else
            % deal with pcls with only one segm (e.g. bowl)
            if numel(P.segms) == 1
                P.segms{end+1} = P.segms{end};
            end
            for i=1:size(P.segms,2)
                segm_pcls{i} = P.segms{i}.v;
            end
        end
    end
    if only_segms
        seeds_pcls = segm_pcls;
    else
        seeds_radii = randi(150,1,n_seeds_radii)/1000;
        [ ~, ~, seeds_pcls ] = PlantSeedsPCL( P, n_seeds, seeds_radii );
        seeds_pcls = [seeds_pcls segm_pcls];
    end
    [SQs,SQs_errors,seeds_pcls,SQs_orig] = FitConstrainedSQsSeededPCL(seeds_pcls,verbose,parallel);
end

