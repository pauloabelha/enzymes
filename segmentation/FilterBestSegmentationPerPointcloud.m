function FilterBestSegmentationPerPointcloud( root_folder, segm_folder, fit_threshold, pcl_filename_to_start )    
    system(['mkdir ' root_folder segm_folder]);
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    tot_toc = 0;
    i=1;
    if ~strcmp(pcl_filename_to_start,'')
        for j=1:size(pcl_filenames,2)
            i=i+1;
            if strcmp(pcl_filenames{j},pcl_filename_to_start)
                break;
            end
        end
    end
    while i<=size(pcl_filenames,2)         
        tic
        best_tot_error = 1e10;
        best_pcl_name = '';
        prev_pcl_shortname = GetPCLShortName(pcl_filenames{i});
        disp(['Processing pointcloud (shortname): ' prev_pcl_shortname]);
        while i<=size(pcl_filenames,2) && strcmp(GetPCLShortName(pcl_filenames{i}),prev_pcl_shortname)
            disp(['    Processing segm option: ' pcl_filenames{i}]);
            P = ReadPointCloud([root_folder pcl_filenames{i} ]);
            [ ~, ~, ~, SEGM_ERRORS, ~, ~, ~ ] = FitAndCheckSwissCheeseSegmentation( P, fit_threshold);
            curr_tot_error = sum(SEGM_ERRORS); 
            if curr_tot_error < best_tot_error
                best_tot_error = curr_tot_error;
                best_pcl_name = pcl_filenames{i};
            end
           prev_pcl_shortname = GetPCLShortName(pcl_filenames{i}); 
           i=i+1;
        end
        disp(['Copying best pointcloud: ' best_pcl_name]);
        system(['cp ' root_folder best_pcl_name ' ' root_folder segm_folder]);
        perc_completed = ceil((i/size(pcl_filenames,2))*100);
        tot_toc = tot_toc+toc;
        avg_toc = tot_toc/i;
        estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
        disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') '    ' num2str(perc_completed) ' %']);
    end
end

