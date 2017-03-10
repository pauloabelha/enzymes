function [ n_cp_pcls ] = CopySegmentationsWithNSegms( root_folder, n_segms )
    segm_folder = [num2str(n_segms) '_segms/'];
    system(['mkdir ' root_folder segm_folder]);
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    tot_toc = 0;
    n_cp_pcls = 0;
    for i=1:size(pcl_filenames,2)
        tic;
        ix = strfind(pcl_filenames{i},'out')+4;
        n_segms_pcl = str2double(pcl_filenames{i}(ix));
        if n_segms_pcl == n_segms
            command = ['cp ' root_folder pcl_filenames{i} ' ' root_folder segm_folder pcl_filenames{i}];
            system(command);
            n_cp_pcls = n_cp_pcls + 1;
        end
        DisplayEstimatedTimeOfLoop(tot_toc,i,size(pcl_filenames,2));
    end

end

