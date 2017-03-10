function [ Y ] = FittingScoreFunction( X )
%     Y = zeros(size(X,1),1);
%     Y(X<=0.1) = 1;
    Y = X;
end

