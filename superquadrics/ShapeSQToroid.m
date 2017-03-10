% by Paulo Abelha (p.abelha@abdn.ac.uk) 
%
% shapeSQ  - builds superquadratic shape and calculates normal vectors and 
% Gaussian curvatures for all points of superquadric (SQ) surface 
%
% The function uses parametric equations of SQ with parameters nu and 
% omega, which are spherical coordinates of each points of SQ 
%
% Usage: [x,y,z,UnitNormalX,UnitNormalY,UnitNormalZ,c,x4d] = shapeSQ(a)
%
% Where:   a           - SQ parameters (a1-a3, eps1, eps2);
%
% Returns: x,y,z       - coordinates of points;
%          UnitNormalX - x-coordinate of unit normal vector 
%          c           - Gaussian curvature of superquadratic shape 
%
% Returns: x2d      - coordinates of an object in world coordinate system
%          A        - transformation matrix 
%          x4d      - coordinates of an object in object coordinate system
%
% See also: RecoveryFunctionSQ

% Inspired by 
% Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function [pcl]=ShapeSQToroid(lambda, n_points)
    %get lambda params
    a1=lambda(1);a2=lambda(2);a3=lambda(3);a4=lambda(4);epsilon_1=lambda(5);epsilon_2=lambda(6);Kx=lambda(10);Ky=lambda(11);
    % spherical coordinates nu and omega
    nu = -pi:pi/((n_points-1)/2):pi;   omega = -pi:pi/((n_points-1)/2):pi;  
    % Calculation of components of SQ parametric equations SQ 
    CosNu = sign(cos(nu)).*(abs(cos(nu)).^epsilon_1);
    SinNu = sign(sin(nu)).*abs(sin(nu)).^epsilon_1;
    CosOmega = sign(cos(omega)).*abs(cos(omega)).^epsilon_2;    
    SinOmega = sign(sin(omega)).*abs(sin(omega)).^epsilon_2;
    %get points
    x = a1.*CosOmega'*(a4+CosNu);
    y = a2.*SinOmega'*(a4+CosNu);
    z = a3.*ones(1,length(nu))'*SinNu;
    pcl = [x(:) y(:) z(:)];
    
    % tapering (direct transformation)
    f_x_ofz = ((Kx.*pcl(:,3))/a3) + 1; 
    pcl(:,1) = pcl(:,1).*f_x_ofz;
    f_y_ofz = ((Ky.*pcl(:,3))/a3) + 1;
    pcl(:,2) = pcl(:,2).*f_y_ofz;
    
    T = [[eul2rotm_(lambda(7:9),'ZYZ') lambda(end-2:end)']; [0 0 0 1]];
    pcl = [pcl ones(length(pcl),1)];
    pcl = (T*pcl')';
    pcl = pcl(:,1:3);
end