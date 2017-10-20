% get the rotation matrix for Euler angles (default is 'ZYZ')
function [ rot_mtx ] = GetEulRotMtx( angles, axis )
    if ~exist('angles','var')
        error('Please define the required angles as first param');
    end
    CheckNumericArraySize(angles,[1 3]);
    if ~exist('axis','var')
        axis = {'z','y','z'};
    end
    if ~iscell(axis) || numel(axis) ~= 3 || ~ischar(axis{1}) || ~ischar(axis{2}) || ~ischar(axis{3})
       error('Please define a cell array with three chars for the three required Euler angle axis as second param');        
    end
    rot_mtx = eye(3);
    for i=1:3
        ix=4-i;
        rot_mtx = rot_mtx*GetRotMtx(angles(ix),axis{ix});
    end
end

