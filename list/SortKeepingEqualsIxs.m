function [ V_sorted,V_rank_ixs ] = SortKeepingEqualsIxs( V, eps, sorting )
    if ~exist('sorting','var')
        sorting = 'ascend';
    end
    D = pdist2(V(:,1),V(:,1));
    [V_sorted,V_sorted_ixs] = sort(V,1,sorting); 
    [~,V_rank_ixs] = sort(V_sorted_ixs,1); 
    visited_ixs = zeros(1,size(D,1));
    for i=1:size(D,1)
        if visited_ixs(i)
            continue;
        end
        visited_ixs(i) = 1;
        for j=i+1:size(D,2)
            dist = D(i,j);
            if dist < eps || (isinf(V(i)) && isinf(V(j)))
               V_rank_ixs(j) = V_rank_ixs(i); 
            end
        end
    end
end

