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
    
    
    
%     for j=1:size(M,2)        
%         for i=1:size(M,1)
%             for k=i+1:size(M,1)
%                 if abs(M(i,j) - M(k,j)) < eps
%                     max_rank = min(M_tot_rank_ixs(i,j),M_tot_rank_ixs(k,j));
%                     M_tot_rank_ixs(k,j) = min(M_tot_rank_ixs(i,j),M_tot_rank_ixs(k,j));
%                     for l=1:size(M,1)
%                         if M_tot_rank_ixs(l,j) == max_rank
%                             M_tot_rank_ixs(l,j) = M_tot_rank_ixs(k,j);                      
%                         end
%                     end
%                 end
%             end
%         end
%     end
%     
%     aux = zeros(size(M_tot_rank_ixs));    
%     for j=1:size(M_tot_rank_ixs,2)  
%         unique_ranks = unique(M_tot_rank_ixs(:,j))';
%         for i=1:size(M_tot_rank_ixs,1)
%             for u=1:size(unique_ranks,2)            
%                 if M_tot_rank_ixs(i,j) == unique_ranks(u)
%                     aux(i,j) = u;
%                 end
%             end
%         end
%     end
%     M_tot_rank_ixs = aux;
end

