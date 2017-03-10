% modified by Paulo Abelha to return any shape and not just a cube (as in the original) 
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

% Copyright (c) 2010-2013 Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function [x,y,z,UnitNormalX,UnitNormalY,UnitNormalZ,c,x4d]=shapeSQ(a,size)
% spherical coordinates nu and omega
     nu = -pi/2:pi/(size-1):pi/2;   omega = -pi:pi/((size-1)/2):pi;  
% Calculation of components of SQ parametric equations SQ 
     CosOmegaSQ = sign(cos(omega)).*abs(cos(omega)).^a(5);
     SinNuSQ = sign(sin(nu)).*abs(sin(nu)).^a(4);
     SinOmegaSQ = sign(sin(omega)).*abs(sin(omega)).^a(5);
     CosNuSQ = sign(cos(nu)).*abs(cos(nu)).^a(4); 
% Calculation of coordinates of SQ;
            x = a(1).*CosOmegaSQ'*CosNuSQ;
            y = a(2).*SinOmegaSQ'*CosNuSQ;
            z = a(3).*ones(1,length(nu))'*SinNuSQ;
% Calculation of  Gaussian curvature of SQ;
     CosOmega = cos(omega);  SinNu = sin(nu);  
     SinOmega = sin(omega);  CosNu = cos(nu);  
        c(1:length(omega),1:length(nu))=NaN; UnitNormalX = c; UnitNormalY = c; UnitNormalZ = c;
        for i=1:length(nu);
            for k=1:length(omega);
                numerator = 361.*CosNu(i)^(18/5).*CosOmega(k)^(9/5).*SinNu(i)^(9/5).*SinOmega(k)^(9/5);
                deno = SinNu(i)^(19/5)+CosNu(i)^(19/5).*(SinOmega(k)^(19/5)+CosOmega(k)^(19/5));
                denominator = a(1)^2.*deno^2;
                % Unit normal vector
                UnitNormalX(k,i) = -sign(CosNu(i))*sign(CosOmega(k))*abs(CosNu(i)^(19/10).*CosOmega(k)^(19/10)/deno^(1/2)); 
                UnitNormalY(k,i) = -sign(CosNu(i))*sign(SinOmega(k))*abs(CosNu(i)^(19/10).*SinOmega(k)^(19/10)/deno^(1/2)); 
                UnitNormalZ(k,i) = -sign(SinNu(i))*abs(SinNu(i)^(19/10)/deno^(1/2));
                c(k,i) = abs(numerator/denominator);
                % c(k,i) = log10(abs(numerator/denominator));
            end
        end
     x4d = [x(:),y(:),z(:),UnitNormalX(:),UnitNormalY(:),UnitNormalZ(:),c(:)]';
end