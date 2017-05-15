function [ pcl_filenames ] = ReadAndWritePCLSInFolder( root_folder )
    pcl_filenames = FindAllFilesOfType({'ply'},root_folder);
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)
        tic
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        WritePly(P,[root_folder pcl_filenames{i}]);
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));        
    end

end

