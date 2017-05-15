% get triangle area from three 3D points (using cross product)
% by Paulo Abelha
function [ A ] = Area3DTriang( points )
    vec1 = points(3,:) - points(1,:);
    vec2 = points(3,:) - points(2,:);
    A = norm(cross(vec1,vec2))/2;
end

