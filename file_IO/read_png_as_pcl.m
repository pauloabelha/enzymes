function [ P ] = read_png_as_pcl( filepath )
    rgbd = double(imread(filepath));
    [ X, Y ] = GetPermGrid( size(rgbd,1), size(rgbd,2) );
    P = PointCloud([X Y rgbd(:)] );
end

