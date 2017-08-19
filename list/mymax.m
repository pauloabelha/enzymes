function [ max_values, max_ixs, max_ixs_equal, max_ixs_equal_cell ] = mymax( M, dim )
    if ~exist('dim','var')
        [ max_values, max_ixs ] = max(M);
    else
        [ max_values, max_ixs ] = max(M,[],dim);        
        if dim == 1
            max_ixs_equal = zeros(size(M,2),size(M,1));
            for i=1:size(M,2)
                M_vec_dim = M(:,i);
                max_ixs_equal(i,:) = M_vec_dim==max_values(i);
            end           
        else
            max_ixs_equal = zeros(size(M,1),size(M,2));
            max_ixs_equal_cell = cell(1,size(M,1));
            for i=1:size(M,1)
                M_vec_dim = M(i,:);
                aux = 1:size(M,2);
                max_ixs_equal(i,:) = M_vec_dim==max_values(i);
                max_ixs_equal_cell{i} = aux(M_vec_dim==max_values(i));
            end 
        end
        
    end
end

