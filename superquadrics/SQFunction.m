function F = SQFunction( lambda_in, pcl, rest_lambda )
    if nargin > 2 ~isempty(rest_lambda)
        lambda_ = zeros(1,15);
        lambda_(rest_lambda(1,:)) = rest_lambda(2,:);
        lambda_(~ismember(1:15,rest_lambda(1,:))) = lambda_in;
        lambda = lambda_;  
    else
        lambda=lambda_in;
    end
    % tapering in x (inverse transformation)
    f_x_ofz = ((lambda(9)*pcl(:,3))/lambda(3)) + 1;
    f_x_ofz(f_x_ofz == 0) = 1;
    f_y_ofz = ((lambda(10)*pcl(:,3))/lambda(3)) + 1;
    f_y_ofz(f_y_ofz == 0) = 1;
    pcl(:,1) = pcl(:,1).*f_x_ofz;
    pcl(:,2) = pcl(:,2).*f_y_ofz;   
    % bending (inv transf)
    k_bend = lambda(11);
    alpha = lambda(12); 
    if k_bend  
        pcl(:,1) = pcl(:,1) - (k_bend - sqrt(k_bend^2 - pcl(:,3).^2));
%         beta = atan(pcl(:,2)./pcl(:,1));
%         r = sqrt((pcl(:,1).^2)+(pcl(:,2).^2)).*cos(alpha - beta);
%         gamma = pcl(:,3)/k_bend;
%         R = (1/k_bend)-(((1/k_bend)-r).*cos(gamma));
%         pcl(:,1) = pcl(:,1) + (R - r)*cos(alpha);
%         pcl(:,2) = pcl(:,2) + (R - r)*sin(alpha);
%         pcl(:,3) = ((1/k_bend)-r).*sin(gamma);
%         Beta = atan(pcl(:,2)./pcl(:,1));
%         R = sqrt((pcl(:,1).^2)+(pcl(:,2).^2)).*cos(alpha - Beta);
%         gamma = atan(pcl(:,3)./((1/k_bend)-R));
%         r = (1/k_bend)-sqrt((pcl(:,3).^2)+(((1/k_bend)-R).^2));
%         pcl(:,1) = pcl(:,1) - (R - r)*cos(alpha);
%         pcl(:,2) = pcl(:,2) - (R - r)*sin(alpha);
%         pcl(:,3) = gamma./k_bend;  
    end    
    % rotation and translation
    nx = cos(lambda(6))*cos(lambda(7))*cos(lambda(8))-(sin(lambda(6))*sin(lambda(8)));
    ny = sin(lambda(6))*cos(lambda(7))*cos(lambda(8))+cos(lambda(6))*sin(lambda(8));
    nz = -(sin(lambda(7))*cos(lambda(8)));
    ox = -(cos(lambda(6))*cos(lambda(7))*sin(lambda(8)))-(sin(lambda(6))*cos(lambda(8)));
    oy = -(sin(lambda(6))*cos(lambda(7))*sin(lambda(8)))+cos(lambda(6))*cos(lambda(8));
    oz = sin(lambda(7))*sin(lambda(8));
    ax = cos(lambda(6))*sin(lambda(7));
    ay = sin(lambda(6))*sin(lambda(7));
    az = cos(lambda(7));   
    X = (nx*pcl(:,1)+ny*pcl(:,2)+nz*pcl(:,3)-lambda(end-2)*nx-lambda(end-1)*ny-lambda(end)*nz);
    Y = (ox*pcl(:,1)+oy*pcl(:,2)+oz*pcl(:,3)-lambda(end-2)*ox-lambda(end-1)*oy-lambda(end)*oz);
    Z = (ax*pcl(:,1)+ay*pcl(:,2)+az*pcl(:,3)-lambda(end-2)*ax-lambda(end-1)*ay-lambda(end)*az);
    % scaling
    X = X./lambda(1);
    Y = Y./lambda(2);
    Z = Z./lambda(3);    
    %F = (((((X.^2).^(1/lambda(5)))+((Y.^2).^(1/lambda(5)))).^2).^(lambda(5)/(2*lambda(4))))+((Z.^2).^(1/lambda(4)));
    F = (abs(X.^(2/lambda(5)))+abs(Y.^(2/lambda(5)))).^(lambda(5)/lambda(4))+(abs(Z.^(2/lambda(4))));
    
end