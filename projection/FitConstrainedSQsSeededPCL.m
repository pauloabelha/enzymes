function [SQs,SQ_errors,seeds_pcls] = FitConstrainedSQsSeededPCL(seeds,seeds_pcls,scale)
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
        P_.v = seeds_pcls{i};
        P_ = DownsamplePCL(P_,DOWNSAMPLE);
        seeds_pcls{i} = P_.v;
    end
    SQs = cell(1,size(seeds_pcls,2));
    SQ_errors = zeros(1,size(seeds_pcls,2));
    Ps = cell(1,size(seeds_pcls,2));
    for i=1:size(seeds_pcls,2)       
        [SQs{i},SQ_errors(i)] = FitSQtoPCL(seeds_pcls{i},4,0,[1 0 0 0 1],fit_constraints{i});
        Ps{i}.v = seeds_pcls{i};
    end
    rmv_empty = 1;
    [alt_SQs,alt_SQs_errors] = GetRotationSQFits( SQs, Ps, 0.12, rmv_empty );    
    SQs = [SQs alt_SQs]; 
    SQ_errors = [SQ_errors alt_SQs_errors];
end