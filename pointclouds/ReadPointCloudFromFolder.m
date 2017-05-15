function [ P ] = ReadPointCloudFromFolder( root_folder, ix, exts )
    if ~exist('exts','var')
        exts = {'ply'};
    end
    pcl_filenames = FindAllFilesOfType(exts, root_folder);
    P = ReadPointCloud([root_folder pcl_filenames{ix}]);
end

