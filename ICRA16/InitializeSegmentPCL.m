function [ pcls ] = InitializeSegmentationModePCL( pcls, mode, segs, SQs,  init_best_score, init_best_rank )
    for seg=1:size(segs,1)
        for part=1:SQs
            pcls{mode,seg,part,1} = segs(seg);
            pcls{mode,seg,part,1} = [];
            pcls{mode,seg,part,1} = init_best_score;   
            pcls{mode,seg,part,1} = init_best_rank; 
        end
    end
end

