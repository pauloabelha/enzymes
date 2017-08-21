function [ R ] = Get2DRotMtx( theta )
    R = eye(2);
    R(1,1) = cos(theta);
    R(1,2) = -sin(theta);
    R(2,1) = sin(theta);
    R(2,2) = cos(theta);
end
