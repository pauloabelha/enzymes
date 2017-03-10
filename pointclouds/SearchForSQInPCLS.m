function [ out_mode, out_segm, out_part ] = SearchForSQInPCLS( pcls, part, position )    
    out_mode = 0;
    out_segm = 0;
    out_part = 0;
    min_dist = Inf;
    mode=1;
    if part <= 0
                init_part=1;
                final_part=size(pcls{mode}{2}{segm}{2},2);
            else
                init_part=part;
                final_part=init_part;
            end
    while mode<=size(pcls,2)
        segm=1;
        while segm<=size(pcls{mode}{2},2)            
            for curr_part=init_part:final_part
                curr_dist = pdist([pcls{mode}{2}{segm}{2}{curr_part}{1}(9:11); position]);
                if curr_dist < min_dist
                    min_dist = curr_dist;
                    out_mode = mode;
                    out_segm = segm;
                    out_part = curr_part;
                end       
            end
            segm=segm+1;
        end
        mode=mode+1;
    end
end

