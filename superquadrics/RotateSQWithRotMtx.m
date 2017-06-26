%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Rotate an SQ (change its ZYZ Euler angles) given a rotation matrix
%
% Inputs:
%   SQ - a superquadric
%   rot_mtx - a 3x3 rotation matrix
% Outputs:
%   SQ - the rotated superquadric
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ SQ ] = RotateSQWithRotMtx( SQ, rot_mtx )
    %% sanity checks
    CheckNumericArraySize(rot_mtx,[3 3]);
    if size(SQ,2) ~= 15 && size(SQ,2) ~= 16
        error('Superquadric param vector size should be 15 or 16 (for toroids)');
    end
    % THIS CHECK IS NOT MADE ANYMORE SINCE BENDING LOST ITS ANGLE PARAM
    % (ABELHA - 12/06/2017)
    % check if rot_mtx is an improper rotation - if so, invert bending
    if det(rot_mtx) > -1.01 && det(rot_mtx) < -0.99 
        SQ(8) = SQ(8) + pi;
    end
    SQ(6:8) = rotm2eul_(rot_mtx*GetEulRotMtx(SQ(6:8)),'ZYZ');    
end

