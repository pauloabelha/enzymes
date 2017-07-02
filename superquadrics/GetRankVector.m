% perform a rank voting over the columns of a matrix M
% rows are samples and columns are different variables
function [ rank_sum, min_ix ] = GetRankVector( M, eps, weights, sortings )
    if ~exist('weights','var')
        weights = ones(1,size(M,2));
    end
    if ~exist('sortings','var')
        sortings = cell(1,size(M,2));
        for j=1:size(M,2)
            sortings{j} = 'ascend';
        end
    end
    M_ranks = zeros(size(M));
    rank_sum = zeros(size(M,1),1);
    for j=1:size(M,2)
        [ ~,M_ranks(:,j) ] = SortKeepingEqualsIxs( M(:,j), eps, sortings{j} );
        rank_sum = rank_sum + (M_ranks(:,j)*weights(j));
    end
    [~,min_ix] = min(rank_sum);
end

