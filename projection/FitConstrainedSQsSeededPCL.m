function [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds_pcls,verbose)
    %% check verbose
    if ~exist('verbose','var')
       verbose = 0; 
    end
    %% fit a SQ to each seed pcl    
    DOWNSAMPLE = 200;
    parfor i=1:numel(seeds_pcls)
        seeds_pcls{i} = DownsamplePCL(seeds_pcls{i},DOWNSAMPLE);
    end
    SQs = cell(1,size(seeds_pcls,2));
    SQ_errors = zeros(1,size(seeds_pcls,2));
    Ps = cell(1,size(seeds_pcls,2));
    tot_toc = 0;
    if verbose
       disp([char(9) 'Fitting SQs to ' num2str(size(seeds_pcls,2)) ' seeded pcls... ']);
    end
    for i=1:size(seeds_pcls,2)    
        if verbose
            tic;
        end
        [SQs{i}, ~, SQ_errors(i)] = PCL2SQ( seeds_pcls{i}, 1 );
        SQs{i} = SQs{i}{1};
        Ps{i} = PointCloud(seeds_pcls{i});
     
%         if verbose
%             tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(seeds_pcls,2),[char(9) 'Fitting SQs to ' num2str(size(seeds_pcls,2)) ' seeded pcls... ']);
%         end
    end
    if verbose
        disp([char(9)  'Getting rotation options for ' num2str(size(seeds_pcls,2)  ) ' SQs...']);
    end
    [SQs,SQs_errors] = GetRotationSQFits( SQs, Ps );    
end