function [XYZ,normals] = getSQPlotMatrix(lambda,n_points,max_lambda_size)
     % RESULTS: lambda(6)-(8) x(1)-x(3) are Euler angles; x(4)-x(6) are SQ center coordinates
    angles = [lambda(6)*180/pi; lambda(7)*180/pi; lambda(8)*180/pi];   %  AZ; EL; PITCH
    position = [lambda(max_lambda_size-2); lambda(max_lambda_size-1); lambda(max_lambda_size)];  % center of SQ
    % Make sure data is in the correct range.
%     EL = round(10*(rem(rem(angles(2)+180,360)+360,360)-180))/10;    % Make sure -180 <= el <= 180
%     AZ = round(10*(rem(rem(angles(1)+180,360)+360,360)-180))/10;    % Make sure 0 <= az <= 360
%     PITCH = round(10*(rem(rem(angles(3)+180,360)+360,360)-180))/10; % Make sure 0 <= pitch <= 360
%         if  EL<-90;
%             EL = 180-abs(EL);
%         elseif EL>90;
%             EL = -180+EL;
%         end
%     ANG = [AZ;EL;PITCH;angles];

    % SQ surface
    [xSQ,ySQ,zSQ,UnitNormalX,UnitNormalY,UnitNormalZ,~,~]=shapeSQ(lambda(1:5),round(sqrt(n_points))); % building the cube in SQ coord. system
%     az = ANG(1); el = ANG(2); pitch = ANG(3);  % setting Euler angles
    [M,]=RotationSQC(xSQ,ySQ,zSQ,lambda(6:8),position,lambda(3),lambda(9),lambda(10),lambda(11),lambda(12));  % building the cube in world coord. system
    XYZ = M(1:3,:)';
    normals = [reshape(UnitNormalX,[],1) reshape(UnitNormalY,[],1) reshape(UnitNormalZ,[],1)];    
end