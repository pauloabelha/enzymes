function [ n_good_segmentations ] = CopyGoodSegmentations( root_folder )
    segm_errors = dlmread([root_folder 'segm_errors.txt']);
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    if size(segm_errors,1) ~= size(pcl_filenames,2)
        error(['The file with the segmentation errors does not have the same numebr of entries as the number of pointclouds in ' root_folder]);
    end    
    n_good_segmentations = zeros(1,10);
    tot_toc = 0;
    segm_folder_prefix = 'good_segmentations_';
    for it=1:10
        fit_threshold = it/1e4;
        segm_folder = [segm_folder_prefix num2str(it) '/'];
        system(['mkdir ' root_folder segm_folder]);
        for i=1:size(segm_errors,1)
            tic
            is_every_segm_good = 1;
            for j=1:size(segm_errors(i,:),2)
               if segm_errors(i,j) > fit_threshold
                   is_every_segm_good = 0;
                   break;
               end
            end
            if is_every_segm_good
                n_good_segmentations(it) = n_good_segmentations(it) + 1;
                command = ['cp ' root_folder  pcl_filenames{i} ' ' root_folder segm_folder pcl_filenames{i}];
                system(command);
            end        
            perc_completed = ceil((i/size(pcl_filenames,2))*100);
            tot_toc = tot_toc+toc;
            avg_toc = tot_toc/i;
            estimated_time_hours = (avg_toc*(size(pcl_filenames,2)-i))/(24*60*60);
            disp(['Estimated time to finish (HH:MM:SS): ' datestr(estimated_time_hours, 'HH:MM:SS') '    ' num2str(perc_completed) ' %']);
        end
    end
end

