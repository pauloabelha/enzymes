function [ ptool ] = GetPToolFromIx( ptools, ix )
    all_ptools = concatcellarrayofmatrices(ptools,'col');
    curr_ix = 1;
    for i=1:numel(ptools)
        ptools_row = ptools{i};
        for j=1:size(ptools_row,1)
            if curr_ix == ix
                ptool = ptools{i}(j,:);
                break; 
            end
            curr_ix = curr_ix + 1;
       end
    end
end

