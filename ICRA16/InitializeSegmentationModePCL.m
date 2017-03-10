%pcls has: modes of segmenting
%mode has: SQ that split it up and a segment
%segment has: the pcl segment and part fittings
%part fitting has: a SQ, its rank and its score
function [ pcls ] = InitializeSegmentationModePCL( min_n_points_seg, pcls, segs, n_parts, SQ, rank, init_best_rank )
    pcls{end+1}{1} = SQ;
    part=1;
    ix_seg=0;
    for seg=1:size(segs,2)
        if length(segs{seg}.v) > min_n_points_seg
            ix_seg=ix_seg+1;
            pcls{end}{2}{ix_seg}{1} = segs{seg}.v;
            while part<=n_parts
                if part==1                    
                    pcls{end}{2}{ix_seg}{2}{part}{1} = SQ;
                    pcls{end}{2}{ix_seg}{2}{part}{2} = rank;
                else
                    pcls{end}{2}{ix_seg}{2}{part}{1} = [];
                    pcls{end}{2}{ix_seg}{2}{part}{2} = init_best_rank;
                end
                part=part+1;
            end
            part=1;            
        end
    end
end

