%  SolverRecoverySQ  - solves nonlinear 3D data-fitting problem by
%  calculating position and orientation of superquadrics (SQ) in 3D space 
%  (with Euler angles and SQ centre coordinates) from 3D experimental data
%
% Usage:   [ANG,position,x,resnorm,residual,exitflag,output] =
%                                   SolverRecoverySQ(P_data,a,target)
%
% Where:   lambda - variables, which should be found:
%               lambda(1)-(3) - Scale (a1-a3)
%               lambda(4)-(5) - Shape (epsilon1 and 2)
%               lambda(6)-(8) - Euler angles (phi, theta, psi in ZYZ)
%                   NOTE: the ZYZ angles are inverted
%                   Rotation goes psi, theta, phi
%               lambda(9)-(10) - z-axis Tapering params (K_x,K_y)
%               lambda(11)-(13) - position in space (px,py,pz)
%
% Returns: x      - variables, which are results of optimization: x(1)-x(3)
%                   are Euler angles in ZYZ rotation system; x(4)-x(6) are
%                   x,y,z-coordinates of SQ center in world coord. system
%          resnorm,residual,exitflag,output - outputs of lsqnonlin 
%                   function (which minimize the difference between 3D 
%                   experimantal data and calculated SQ)
%
% See also: lsqnonlin, RecoveryFunctionSQ, ransacSQB

% Copyright (c) 2010-2013 Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function [x,resnorm,residual,exitflag,output] = SolverRecoverySQ(pcl,seed_point,seed_point_lower,seed_point_upper,lambda_f,lambda_o,lambda_lower,lambda_upper,tapering,bending)

%SQ = FitSQtoPCL(pcl,16);
%SQ = [SQ(1:8) 0 0 0 0 SQ(9:11)];

lambda_lower(end-2:end) = seed_point_lower;
lambda_upper(end-2:end) = seed_point_upper;
lambda_o(end-2:end) = seed_point;
options = optimset('Display','off','TolX',1e-20,'TolFun',1e-9,'MaxIter',1000,'MaxFunEvals',1000);
if tapering && bending
    [x,resnorm,residual,exitflag,output] = lsqnonlin(@(x) RecoveryFunctionSQWithTaperingAndBending(lambda_f, x, pcl), lambda_o, lambda_lower,lambda_upper, options);
elseif tapering
    [x,resnorm,residual,exitflag,output] = lsqnonlin(@(x) RecoveryFunctionSQWithTapering(lambda_f, x, pcl), lambda_o, lambda_lower,lambda_upper, options);
elseif bending
    [x,resnorm,residual,exitflag,output] = lsqnonlin(@(x) RecoveryFunctionSQWithBending(lambda_f, x, pcl), lambda_o, lambda_lower,lambda_upper, options);
else
    [x,resnorm,residual,exitflag,output] = lsqnonlin(@(x) RecoveryFunctionSQ(lambda_f, x, pcl), lambda_o, lambda_lower,lambda_upper, options);
end
end