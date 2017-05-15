function [ output_args ] = PlotPlaneEquation( A, B, C, D )
    [x, y] = meshgrid(0:0.01:0.5); 
    Zv = @(x,y) (-A*x -B*y - D)/C;
    mesh(x,y,Zv(x,y));
    axis equal;
end

