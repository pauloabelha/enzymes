function M = kinectply2points(filename)

%   reads data from Kinect Fusion PLY file.
%
%   M is an N x 3 matrix of points from the point cloud
%
%   Copyright (c) 2014 Paulo Abelha, adapted from:
%       Copyright (c) 2003 Gabriel Peyré 'read_ply.m'

M = [];

fid = fopen(filename);
if fid == -1
    msg = strcat('Could not find a *.ply point cloud in: ',filename);
    error(msg);
end
tline = fgetl(fid);

n_points = 0;
i = 1;
while ischar(tline)   
    if length(tline) > 15 && strcmp(tline(1:14),'element vertex')
        n_points = str2num(tline(16:length(tline)));
    end    
    if strcmp(tline,'end_header')
        start_points = i + 1;
        break;
    end    
    tline = fgetl(fid);
    i = i + 1;
end
fclose(fid);

M = dlmread(filename, ' ', [start_points 0 n_points 2]);
end