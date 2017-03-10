function [F,F_SQ] = SQFunctionNormalised( lambda_in, pcl, rest_lambda )
    if nargin > 2 && ~isempty(rest_lambda)
        lambda_ = zeros(1,15);
        lambda_(rest_lambda(1,:)) = rest_lambda(2,:);
        lambda_(~ismember(1:15,rest_lambda(1,:))) = lambda_in;
        lambda = lambda_;  
    else
        lambda=lambda_in;
    end
    F_SQ = SQFunction( lambda, pcl );
    F = sqrt(lambda(1)*lambda(2)*lambda(3))*(F_SQ.^lambda(4) - 1);
end