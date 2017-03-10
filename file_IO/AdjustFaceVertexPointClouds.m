function AdjustFaceVertexPointClouds( root_folder, extensions )
    if ~exist('extension','var')
        extensions = {'ply'};
    end
     pcl_filenames = FindAllFilesOfType(extensions,root_folder);
     tot_toc = 0;
     for i=1:size(pcl_filenames,2)
        tic
        disp(['Processing point cloud ' pcl_filenames{i} '...']);
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        if sum(min(P.f)) >= 3
            disp(['Adjusting faces for point cloud ' pcl_filenames{i} '...']);
            P.f = P.f - 1;
            WritePly(P,[root_folder pcl_filenames{i}]);
            disp(['Faces adjusted for point cloud ' pcl_filenames{i}]);
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
     end
end

