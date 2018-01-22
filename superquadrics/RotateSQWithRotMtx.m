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
    if ~exist('pca_apply','var')
        pca_apply = 0;
    end
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
    vec = [0;0;1];
    a = GetEulRotMtx(SQ(6:8))*vec;
    disp(['Before:' char(9) num2str(a')]);
    SQ(6:8) = rotm2eul_(GetEulRotMtx(SQ(6:8)),'ZYZ');  
    b = GetEulRotMtx(SQ(6:8))*vec; 
    disp(['After:' char(9) num2str(b')]);
    disp(['Dist:' char(9) num2str((a-b)')]);
    disp(char(9));
end

