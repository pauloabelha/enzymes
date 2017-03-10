function rank_matrix = GetRankingMtx( matrix )
    rank_matrix = zeros(size(matrix));
    unique_matrix = unique(matrix);
    for i=1:size(matrix,1)
        for j=1:size(matrix,2)
            n_elems_bigger_than_curr = 0;
            for i2=1:size(unique_matrix,1)
                for j2=1:size(unique_matrix,2)
                    if matrix(i,j) > unique_matrix(i2,j2)
                        n_elems_bigger_than_curr=n_elems_bigger_than_curr+1;
                    end
                end                
            end
            rank_matrix(i,j) = n_elems_bigger_than_curr+1;
        end       
    end
end


