function [ pts, T ] = RotateAndTranslatePoints( pts, rot, vec )    
    T = [rot vec;0 0 0 1];
    pts = [pts ones(size(pts,1),1)];
    pts = T*pts';
    pts = pts(1:3,:)';
end

