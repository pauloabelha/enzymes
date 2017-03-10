function [  segms ] = findSegmentsForChain( n_segms, n_parts, parent_chain, part, ixs, segms )
    if part == n_parts+1
        equal=1;
        for i=1:size(parent_chain,1)
            if ixs(i) ~= parent_chain(i)
                equal=0;
                break;
            end
        end
        if equal
            segms = parent_chain;
        end
    else  
        for segment=1:n_segms
            parent_chain(part) = segment;   
            [segms] = findSegmentsForChain(n_segms, n_parts, parent_chain, part+1, ixs, segms);             
        end
    end
end


