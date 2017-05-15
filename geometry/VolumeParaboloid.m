function [ V ] = VolumeParaboloid( lambda )
    thickness = 0.005;
    V = SurfaceAreaParaboloid(lambda)*thickness;
end

