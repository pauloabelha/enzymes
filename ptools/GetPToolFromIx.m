function [ ptool, found_i, found_j ] = GetPToolFromIx( ptools, ix )
    found_i = -1;
    found_j = -1;
    curr_ix = 1;
    for i=1:numel(ptools)
        ptools_row = ptools{i};
        for j=1:size(ptools_row,1)
            if curr_ix == ix
                ptool = ptools{i}(j,:);
                found_i = i;
                found_j = j;
                break; 
            end
            curr_ix = curr_ix + 1;
        end
       if found_i > 0 && found_j > 0
           break;
       end
    end
end

