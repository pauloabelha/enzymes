function [lambda_o_initial,lambda_o_final] = ...
                sortLambdasByV2(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final)
    aux = zeros(size(lambda_o_initial));
    aux2 = zeros(size(lambda_o_initial));
    for i=1:length(sorted_rank_V_ixs)        
        aux(i,:) = lambda_o_initial(sorted_rank_V_ixs(i),:);
        aux2(i,:) = lambda_o_final(sorted_rank_V_ixs(i),:);
    end      
    lambda_o_initial = aux;
    lambda_o_final = aux2;
end

