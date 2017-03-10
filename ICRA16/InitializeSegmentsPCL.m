function [ pcls ] = InitializeSegmentsPCL( pcls, n_parts, seg1, seg2, seg3, init_best_rank, init_best_score  )
    if isempty(pcls)
        pcls = InitializeSegmentPCL( pcls, 1, [seg1 seg2 seg3], 2,  init_best_score, init_best_rank );
        pcls{1,1,1,1} = seg1;
        pcls{1,1,1,2} = SQ;
        pcls{1,1,1,3} = score;
        pcls{1,1,1,4} = rank;
        pcls{1,2,2,1} = seg2;
        pcls{1,2,2,2} = [];
        pcls{1,2,2,3} = init_best_score;   
        pcls{1,2,2,4} = init_best_rank;
        if ~isempty(seg3)
            for i=1:n_parts
                pcls{1,3,i,1} = seg3;
                pcls{1,3,i,2} = [];
                pcls{1,3,i,3} = initial_best_score;   
                pcls{1,3,i,4} = init_best_rank; 
            end
        end
    else
        
    end

end

