function F = RecoveryFunctionSQ2(lambda, XYZ)
    % tapering in x (inverse transformation)
    f_x_ofz = ((lambda(9)*XYZ(:,3))/lambda(3)) + 1; 
    f_y_ofz = ((lambda(10)*XYZ(:,3))/lambda(3)) + 1;
    
    %rotation and translation
    nx = cos(lambda(6))*cos(lambda(7))*cos(lambda(8))-(sin(lambda(6))*sin(lambda(8)));
    ny = sin(lambda(6))*cos(lambda(7))*cos(lambda(8))+cos(lambda(6))*sin(lambda(8));
    nz = -(sin(lambda(7))*cos(lambda(8)));
    ox = -(cos(lambda(6))*cos(lambda(7))*sin(lambda(8)))-(sin(lambda(6))*cos(lambda(8)));
    oy = -(sin(lambda(6))*cos(lambda(7))*sin(lambda(8)))+cos(lambda(6))*cos(lambda(8));
    oz = sin(lambda(7))*sin(lambda(8));
    ax = cos(lambda(6))*sin(lambda(7));
    ay = sin(lambda(6))*sin(lambda(7));
    az = cos(lambda(7));   
    
    %taper
    XYZ(:,1) = XYZ(:,1).*f_x_ofz;
    XYZ(:,2) = XYZ(:,2).*f_y_ofz;
    
    %rotate and translate
    X = (nx*XYZ(:,1)+ny*XYZ(:,2)+nz*XYZ(:,3)-lambda(end-2)*nx-lambda(end-1)*ny-lambda(end)*nz)/lambda(1);
    Y = (ox*XYZ(:,1)+oy*XYZ(:,2)+oz*XYZ(:,3)-lambda(end-2)*ox-lambda(end-1)*oy-lambda(end)*oz)/lambda(2);   
    Z = (ax*XYZ(:,1)+ay*XYZ(:,2)+az*XYZ(:,3)-lambda(end-2)*ax-lambda(end-1)*ay-lambda(end)*az)/lambda(3); 

    F = (X.^(2/lambda(5))+Y.^(2/lambda(5))).^(lambda(5)/lambda(4))+Z.^(2/lambda(4));                
    F = sqrt(lambda(1)*lambda(2)*lambda(3))*((F.^lambda(4)) - 1);
end