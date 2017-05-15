function [ output_args ] = CopyBestPtools( best_ptools_ixs, root_folder, calib_folder, dest_folder )
    system(['rm -r ' root_folder dest_folder]);
    system(['mkdir ' root_folder dest_folder]);
    folders = FindAllFolders( [root_folder calib_folder] );    
    tot_toc = 0;
    for i=1:numel(folders)
        tic;
        copy_command = 'cp -r ';
        copy_command = [copy_command root_folder calib_folder folders{i} 'ptool' num2str(best_ptools_ixs(i)) ' '];
        copy_command = [copy_command root_folder dest_folder folders{i} 'ptool' num2str(best_ptools_ixs(i))];
        system(['mkdir ' root_folder dest_folder folders{i}]);
        system(copy_command);
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(folders),'Copying best tools: ');
    end
end
