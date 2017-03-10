function [lambda_o,lambda_lower,lambda_upper] = addPositionsToLambdas(pcl,seed_point,lambda_o,lambda_lower,lambda_upper)  
    lambda_o(length(lambda_o)-2) = seed_point(1);
    lambda_o(length(lambda_o)-1) = seed_point(1,2);
    lambda_o(length(lambda_o)) = seed_point(3);
    lambda_lower(length(lambda_lower)-2) = min(pcl(:,1));
    lambda_lower(length(lambda_lower)-1) = min(pcl(:,2));
    lambda_lower(length(lambda_lower)) = min(pcl(:,3));
    lambda_upper(length(lambda_upper)-2) = max(pcl(:,1));
    lambda_upper(length(lambda_upper)-1) = max(pcl(:,2));
    lambda_upper(length(lambda_upper)) = max(pcl(:,3));  
end