function [lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers] = ...
                sortLambdasByV(sorted_rank_V_ixs,lambda_o_initial,lambda_o_final,lambda_lowers,lambda_uppers)
    aux = zeros(size(lambda_o_initial));
    aux2 = zeros(size(lambda_o_final));
    aux3 = zeros(size(lambda_lowers));
    aux4 = zeros(size(lambda_uppers));
    for i=1:length(sorted_rank_V_ixs)        
        aux(i,:) = lambda_o_initial(sorted_rank_V_ixs(i),:);
        aux2(i,:) = lambda_o_final(sorted_rank_V_ixs(i),:);
        aux3(i,:) = lambda_lowers(sorted_rank_V_ixs(i),:);
        aux4(i,:) = lambda_uppers(sorted_rank_V_ixs(i),:);
    end      
    lambda_o_initial = aux;
    lambda_o_final = aux2;
    lambda_lowers = aux3;
    lambda_uppers = aux4;
end

