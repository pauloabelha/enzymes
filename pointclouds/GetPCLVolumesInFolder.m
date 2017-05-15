function [ vols, bound_boxes, pcl_ranges ] = GetPCLVolumesInFolder( root_folder, exts )
    if ~exist('exts','var')
        exts = {'ply'};
    end
    pcl_filenames = FindAllFilesOfType(exts, root_folder);
    % max bounding box volume
    vols = zeros(numel(pcl_filenames),1);
    bound_boxes = zeros(numel(pcl_filenames),3);
    pcl_ranges = zeros(numel(pcl_filenames),3);
    parfor i=1:numel(pcl_filenames)
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        [ vols(i), bound_boxes(i,:), pcl_ranges(i,:) ] = PCLBoundingBoxVolume( P.v );
    end
end

