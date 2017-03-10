% RecoveryFunctionSQ - assigns the superquadric inside-outside function, 
%  which should be minimized by nonlinear least-square fitting function
%
% Usage:   F = RecoveryFunctionSQ(x, XYZ, param)
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
% Returns: F - superquadric (SQ) inside-outside function, using SQ 
%               implicit equation in world coordinate system (with Euler
%               angles and SQ center coordinate)
%
% Please refer to page 25 of the the book below for the function
% See also: lsqnonlin, SolverRecoverySQ, ransacSQB
%
% Extra-info: Jaklic Ales, Leonardis Ales, Solina Franc. Segmentation and 
% Recovery of Superquadrics. // Computational imaging and vision. Kluwer, 
% Dordrecht, 2000. Chapter #2.

% Copyright (c) 2010-2013 Ilya Afanasyev
% Mechatronics dep., DIMS, Trento University
% Marie Curie-COFUND, FP7/EU: Trentino postdoc program 
% http://www.unitn.it/en/dims/7241/mechatronics

function F = RecoveryFunctionSQ(lambda_f, lambda_o, XYZ)
    lambda = get_lambda_from_fixed_and_open(lambda_f,lambda_o,15);
    F = SQFunction(lambda,XYZ);    
end