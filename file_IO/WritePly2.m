function WritePly(pcl,complete_filepath)



%   reads data from Kinect Fusion PLY file.
%
%   M is an N x 3 matrix of points from the point cloud
%
%   Copyright (c) 2014 Paulo Abelha, adapted from:
%       Copyright (c) 2003 Gabriel Peyré 'read_ply.m'

fid = fopen(complete_filepath,'w+');
if fid == -1
    msg = strcat('Could not open the file in the path: ',filename);
    error(msg);
end

fprintf(fid,'ply');
fprintf(fid,'\n');
fprintf(fid,'format ascii 1.0');
fprintf(fid,'\n');
fprintf(fid,'element vertex');
fprintf(fid,' ');
fprintf(fid,int2str(size(pcl,1)));
fprintf(fid,'\n');
fprintf(fid,'property float x');
fprintf(fid,'\n');
fprintf(fid,'property float y');
fprintf(fid,'\n');
fprintf(fid,'property float z');
fprintf(fid,'\n');
fprintf(fid,'end_header');
fprintf(fid,'\n');

dlmwrite(complete_filepath,pcl,'delimiter',' ','-append');

fclose(fid);
end