function ConvertPointClouds( root_folder, ext_in, ext_out, folders )
    if ~exist('folders','var')
        folders = {''};
    end
    if ~strcmp(root_folder(end),'/')
        error('Root folder should end with a slash');
    end
    initial_pcl_ix = 1;
    tot_toc = 0;
    for f=1:size(folders,2)
        pcl_filenames = FindAllFilesOfType( {ext_in},[root_folder folders{f}]);
        for i=initial_pcl_ix:size(pcl_filenames,1)
            tic;
            ConvertPointCloud([root_folder folders{f}], pcl_filenames{i}, ext_out);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
        end    
    end
end

