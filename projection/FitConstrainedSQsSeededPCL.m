function [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_radii,seeds_pcls,verbose)
    %% check verbose
    if ~exist('verbose','var')
       verbose = 0; 
    end
    %% fit a SQ to each seed pcl    
    DOWNSAMPLE = 250;
    parfor i=1:numel(seeds_pcls)
        seeds_pcls{i} = DownsamplePCL(seeds_pcls{i},DOWNSAMPLE);
    end
    SQs = cell(1,size(seeds_pcls,2));
    SQ_errors = zeros(1,size(seeds_pcls,2));
    Ps = cell(1,size(seeds_pcls,2));
    tot_toc = 0;
    for i=1:size(seeds_pcls,2)    
        if verbose
            tic;
        end
        [SQs{i}, ~, SQ_errors(i)] = PCL2SQ( seeds_pcls{i}, 1 );
        SQs{i} = SQs{i}{1};
        Ps{i}.v = seeds_pcls{i};
        if verbose
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(seeds_pcls,2),[char(9) 'Fitting SQs to seed pcls... ']);
        end
    end
    [SQs,SQs_errors] = GetRotationSQFits( SQs, Ps );    
end