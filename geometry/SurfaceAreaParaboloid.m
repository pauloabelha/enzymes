% http://mathworld.wolfram.com/Paraboloid.html
% approximating paraboloid as superparaboloid for surface area calc
% by Paulo Abelha
function [ S ] = SurfaceAreaParaboloid( lambda )
    a = max(lambda(1:2));
    h = lambda(3);
    S = ((pi*a)/(6*h^2))*( ( (a^2+4*h^2)^(3/2) ) - a^3);
end

