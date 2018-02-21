function [transf_points] = TransformPoints(transf, points)
    points = transf*[points ones(size(points,1),1)]';
    transf_points = points(1:3,:)';
end

