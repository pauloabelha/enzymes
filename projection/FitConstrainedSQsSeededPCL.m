function [SQs,SQs_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls,scale)
    %% fit a SQ to each seed pcl    
    DOWNSAMPLE = 500;
    fit_constraints = cell(1,size(seeds_pcls,2));
    for i=1:size(seeds_pcls,2)
        fit_constraints{i}.min_scale = scale*0.2;
        fit_constraints{i}.initial_scale = scale;
        fit_constraints{i}.max_scale = scale;  
        fit_constraints{i}.min_pos = min(seeds_pcls{i});
        fit_constraints{i}.initial_pos = seeds(i,:);
        fit_constraints{i}.max_pos = max(seeds_pcls{i});
        seeds_pcls{i} = DownsamplePCL(seeds_pcls{i},DOWNSAMPLE);
    end
    SQs = cell(1,size(seeds_pcls,2));
    SQ_errors = zeros(1,size(seeds_pcls,2));
    Ps = cell(1,size(seeds_pcls,2));
    for i=1:size(seeds_pcls,2)       
        [SQs{i}, ~, SQ_errors(i)] = PCL2SQ( seeds_pcls{i}, 1 );
        SQs{i} = SQs{i}{1};
        Ps{i}.v = seeds_pcls{i};
    end
    [SQs,SQs_errors] = GetRotationSQFits( SQs, Ps );    
end