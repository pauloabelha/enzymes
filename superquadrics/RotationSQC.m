% RotationSQC  - builds transformation matrix and calculates coordinates
%   of 3D object in world coordinate system, using Euler rotation and
%   translation to assigned target point of coordinate center
%
% This function is mostly used for representation of an object in 3D space
%
% Usage:   [x2d,A,x4d]=RotationSQC(x,y,z,az,el,pitch,target)
%
% Where:   x,y,z       - coordinates of points;
%          az,el,pitch - Euler angles
%          target      - coordinates of an object center
%
% Returns: x2d      - coordinates of an object in world coordinate system
%          A        - transformation matrix 
%          x4d      - coordinates of an object in object coordinate system
%
% See also: viewmtx, viewmtxSQC_Euler

% Copyright (c) 2010-2013 Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function [x2d,A,x4d]=RotationSQC(x,y,z,angles,target,a_3,K_x,K_y,k,alpha)
% The function rotate Superquadrics in 3D
% call the function from MATLAB command window: [x2d]=RotationSQ(x,y,z,az,el,target);

% delete NaN elements from consideration
 s=0;
 x4d1 = [x(:),y(:),z(:)]'; 
 amountNaN=sum(isnan(x4d1(3,:)));
 x4d(1:3,1:length(x4d1)-amountNaN)=0;
 for m1=1:length(x4d1);
                if isnan(x4d1(3,m1))==0; 
                    s=s+1;
                    x4d(:,s)=x4d1(:,m1); 
                end
 end
% Creating 3D cloud of points from the known matrix of 3D object
x4d = [x4d;ones(1,length(x4d))];

% tapering (direct transformation)
f_x_ofz = ((K_x.*x4d(3,:))/a_3) + 1;
f_x_ofz(f_x_ofz == 0) = sign(K_x);   
x4d(1,:) = x4d(1,:).*f_x_ofz;
f_y_ofz = ((K_y.*x4d(3,:))/a_3) + 1;
f_y_ofz(f_y_ofz == 0) = sign(K_x);
x4d(2,:) = x4d(2,:).*f_y_ofz;

%bending (inverse transformation)
x_bending_factor = 0;
y_bending_factor = 0;
z_bent = x4d(3,:);
if k>1e-5
%     beta = atan(x4d(2,:)./x4d(1,:));
%     r = sqrt((x4d(1,:).^2)+(x4d(2,:).^2)).*cos(alpha - beta);
%     one_over_k = repmat(1/k,size(r));
%     gamma = x4d(3,:).*one_over_k;
%     R = one_over_k-((one_over_k-r).*cos(gamma));    
%     x_bending_factor = (R - r)*cos(alpha);
%     y_bending_factor = (R - r)*sin(alpha);
%     z_bent = (one_over_k-r).*sin(gamma);

    Beta = atan(x4d(2,:)./x4d(1,:));
    R = sqrt((x4d(1,:).^2)+(x4d(2,:).^2)).*cos(alpha - Beta);
    gamma = atan(x4d(3,:)./((1/k)-R));
    r = (1/k)-sqrt((x4d(3,:).^2)+(((1/k)-R).^2));
    x_bending_factor = -(R - r)*cos(alpha);
    y_bending_factor = -(R - r)*sin(alpha);
    z_bent = gamma./k;
end
x4d(1,:) = x4d(1,:) + x_bending_factor;
x4d(2,:) = x4d(2,:) + y_bending_factor;
x4d(3,:) = z_bent;

T = [[eul2rotm_(angles,'ZYZ') [target]]; [0 0 0 1]];
x2d = T*x4d;
end