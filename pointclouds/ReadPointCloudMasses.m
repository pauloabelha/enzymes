function [ pcl_filenames, pcl_masses ] = ReadPointCloudMasses( root_folder )

    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );

    load([root_folder 'groundtruth.mat']);    
    if exist('table_gt','var')
        groundtruth=table_gt;
    end
    % find task index
    task_ix = 0;

    pcl_masses = [];
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)  
        tic;
        pcl_shortname = GetPCLShortName( pcl_filenames{i} );
        for j=1:size(groundtruth.tool,1)
            found_gt_pcl = 0;
            if isempty(strfind(groundtruth.tool{j},'.ply'))
                pcl_shortname_gt = groundtruth.tool{j};
            else
                pcl_shortname_gt = groundtruth.tool{j}(1:strfind(groundtruth.tool{j},'.ply')-1);
            end
            if strcmp(pcl_shortname,pcl_shortname_gt)
                ix_categ_scores_gt=ix_categ_scores_gt+1;
                found_gt_pcl = 1;
                categ_scores_gt(ix_categ_scores_gt) = groundtruth{j,task_ix};
                pcl_masses(end+1) = groundtruth.mass(j);
                break
            end  
        end
        if ~found_gt_pcl
           error(['Could not find groundtruth for ' pcl_shortname ' in the file ' root_folder 'groundtruth.csv']); 
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
    end
end

