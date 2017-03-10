function [lambda_lower,lambda_upper,lambda_default] = SQ2lambdas( SQ_scale_shape, boundary_perc )
    lambda_lower = [0.01,0.01,0.01,1,1,0,0,0];
    lambda_upper = [0.1,0.1,0.1,2,2,pi,pi,pi];
    lambda_default = [0.005,0.005,0.005,1,1,0,0,0];
%     lambda_fixed = ones(2,5);
%     lambda_fixed(1,1:5) = 1:5;
%     lambda_fixed(2,1:5) = SQ_scale_shape(1:5);
    lambda_lower(1:5) = lambda_fixed(2,1:5).*(1-boundary_perc);
    lambda_upper(1:5) = lambda_fixed(2,1:5).*(1+boundary_perc);
end

