% RotationSQC  - builds transformation matrix, using Euler rotation and
% translation to assigned target point of object coordinate center
%
% This function is mostly used for representation of an object in 3D space
%
% Usage:   [a,T,O1]=viewmtxSQC_Euler(az,el,pitch,target)
%
% Where:   az,el,pitch - Euler angles
%          target      - coordinates of an object center
%
% Returns: a        - transformation matrix
%          T        - rotaion matrix 
%          O1       - matrix of translation
%
% See also: viewmtx, RotationSQC

% Copyright (c) 2010-2013 Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function [a,T,O1]=viewmtxSQC_Euler(az,el,pitch,target)

error(nargchk(2,4,nargin,'struct'));
% Make sure data is in the correct range.
% el = round(10*(rem(rem(el+180,360)+360,360)-180))/10; % Make sure -180 <= el <= 180
% az = round(10*(rem(rem(az+180,360)+360,360)-180))/10; % Make sure 0 <= az <= 360
% pitch = round(10*(rem(rem(pitch+180,360)+360,360)-180))/10; % Make sure 0 <= pitch <= 360
%     if  el<-90;
%         el = 180-abs(el);
%     elseif el>90;
%         el = -180+el;
%     end
% 
% % Convert from degrees to radians.
% az = az*pi/180;
% el = el*pi/180;
% pitch = pitch*pi/180;
% 
% % Rotation matrix is formed by composing three rotations:
% %   1) Rotate about the z axis, AZ radians
% ToZ = [ cos(az)   -sin(az)   0      0;
%         sin(az)    cos(az)   0      0;
%         0          0         1      0;
%         0          0         0      1 ];
% %   2) Rotate about the x axis, EL radians
% ToY = [ cos(el)   0          sin(el)   0
%         0         1          0         0
%        -sin(el)   0          cos(el)   0
%         0         0          0         1 ];
% %   2) Rotate about the new z axis, PITCH radians
% ToZ_new = [ cos(pitch)  -sin(pitch)   0            0
%             sin(pitch)   cos(pitch)   0            0
%             0            0            1            0
%             0            0            0            1 ];
% Rotaion matrix
%T=ToZ*ToY*ToZ_new;
%new rotation bugless by Paulo Abelha
T=zeros(4,4);
T(end,end) = 1;
T(1:3,1:3) = eul2rotm_([az el pitch],'ZYZ');
% Transformation to move origin of object coordinate system to TARGET
O1 = [eye(4,3),[target;1]];
% Form total transformation matrix
a=O1*T;