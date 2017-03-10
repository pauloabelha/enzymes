function [ R ] = GetRotMtx( theta, axis_rot )
    R = zeros(3,3,size(theta,1));
    if strcmp(axis_rot,'x') || axis_rot == 1
        R(1,1) = 1;
        R(2,2,:) = cos(theta);
        R(2,3,:) = -sin(theta);
        R(3,2,:) = sin(theta);
        R(3,3,:) = cos(theta);  
    elseif strcmp(axis_rot,'y') || axis_rot == 2
        R(2,2) = 1;
        R(1,1,:) = cos(theta);
        R(1,3,:) = sin(theta);
        R(3,1,:) = -sin(theta);
        R(3,3,:) = cos(theta); 
    elseif strcmp(axis_rot,'z') || axis_rot == 3
        R(1,1,:) = cos(theta);
        R(1,2,:) = -sin(theta);
        R(2,1,:) = sin(theta);
        R(2,2,:) = cos(theta);
        R(3,3,:) = 1;
    end    
end

