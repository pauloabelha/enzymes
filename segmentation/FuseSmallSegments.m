function P = FuseSmallSegments(P, verbose)
    if ~exist('verbose','var')
        verbose = 0;
    end
    % fuse small segments
    has_small_segm = false;
    Pu_set = unique(P.u);
    for j=1:numel(P.segms)
       if size(P.segms{j}.v,1)/size(P.v,1) < 0.05
           has_small_segm = true;
           small_segm_label = Pu_set(j);
           break;
       end
    end        
    while has_small_segm
        if has_small_segm
            P = FuseSegmIntoOthers( P, small_segm_label, verbose );
        end
        has_small_segm = false;
        Pu_set = unique(P.u);
        for j=1:numel(P.segms)
           if size(P.segms{j}.v,1)/size(P.v,1) < 0.075
               has_small_segm = true;
               small_segm_label = Pu_set(j);
               break;
           end
        end
    end
end