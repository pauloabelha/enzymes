function F = SQFunctionWoutNormalizingParams( lambda, XYZ )    
    % tapering in x (inverse transformation)
    lambda(1:2) = lambda(1:2)./(abs(lambda(9:10))+1);
    f_x_ofz = ((lambda(9)*XYZ(:,3))/lambda(3)) + 1; 
    f_y_ofz = ((lambda(10)*XYZ(:,3))/lambda(3)) + 1;
    XYZ(:,1) = XYZ(:,1)./f_x_ofz;
    XYZ(:,2) = XYZ(:,2)./f_y_ofz;
    
    % bending (inv transf)
    k = lambda(11);
    alpha = lambda(12);
%     Beta = atan(XYZ(2,:)./XYZ(1,:));
%     R = sqrt((XYZ(1,:).^2)+(XYZ(2,:).^2)).*cos(alpha - Beta);
%     gamma = atan(XYZ(3,:)./((1/k)-R));
%     r = (1/k)-sqrt((XYZ(3,:).^2)+(((1/k)-R).^2));
%     x_bending_factor = (R - r)*cos(alpha);
%     y_bending_factor = (R - r)*sin(alpha);
%     z_bent = gamma./k;
%     XYZ(1,:) = XYZ(1,:) - x_bending_factor;
%     XYZ(2,:) = XYZ(2,:) - y_bending_factor;
%     XYZ(3,:) = z_bent;    
    if k>0.01
        beta = atan(XYZ(2,:)./XYZ(1,:));
        r = sqrt((XYZ(1,:).^2)+(XYZ(2,:).^2)).*cos(alpha - beta);
        one_over_k = repmat(1/k,size(r));
        gamma = XYZ(3,:).*one_over_k;
        R = one_over_k-((one_over_k-r).*cos(gamma));    
        x_bending_factor = (R - r)*cos(alpha);
        y_bending_factor = (R - r)*sin(alpha);
        z_bent = (one_over_k-r).*sin(gamma);
        XYZ(1,:) = XYZ(1,:) + x_bending_factor;
        XYZ(2,:) = XYZ(2,:) + y_bending_factor;
        XYZ(3,:) = z_bent;
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
    X = (nx*XYZ(:,1)+ny*XYZ(:,2)+nz*XYZ(:,3)-lambda(end-2)*nx-lambda(end-1)*ny-lambda(end)*nz);
    Y = (ox*XYZ(:,1)+oy*XYZ(:,2)+oz*XYZ(:,3)-lambda(end-2)*ox-lambda(end-1)*oy-lambda(end)*oz);
    Z = (ax*XYZ(:,1)+ay*XYZ(:,2)+az*XYZ(:,3)-lambda(end-2)*ax-lambda(end-1)*ay-lambda(end)*az);
    
    % scaling
    X = X./lambda(1);
    Y = Y./lambda(2);
    Z = Z./lambda(3);

    F = (abs(X.^(2/lambda(5)))+abs(Y.^(2/lambda(5)))).^(lambda(5)/lambda(4))+(abs(Z.^(2/lambda(4))));     
    F = F.^lambda(4);
end