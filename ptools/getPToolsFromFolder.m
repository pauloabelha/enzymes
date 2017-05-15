function [ pTools, pTools_vecs, transfs_lists, pcl_filenames ] = getPToolsFromFolder( root_folder, task_name, fit_threshold, get_alt_SQ_Fits, pcl_name_to_start )
    if ~exist('get_alt_SQ_Fits','var')
        get_alt_SQ_Fits=0;
    end
    % get the filename for every */pcd file in root_folder
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    pTools = {};
    pTools_vecs = [];
    transfs_lists = {};
    % for each pcd, write the pToolVec to the same file
    fileName = strcat(root_folder, 'pTools.txt'); 
    % read file with groundtruth for every tool
    table_gt = readtable([root_folder 'groundtruth.csv']);
    table_gt_cols = table_gt.Properties.VariableNames;
    for j=1:size(table_gt_cols,2)
        if strcmp(task_name,table_gt_cols{j})
            task_ix=j;
            break;
        end
    end
    initial_pcl_ix = 1;
    if exist('pcl_name_to_start','var')  
        initial_pcl_ix = 0;
        for i=1:size(pcl_filenames,2)
           if strcmp(pcl_name_to_start,pcl_filenames{i})
               initial_pcl_ix= i+1;
               break;
           end    
        end
        if initial_pcl_ix == 0
            error(['Could not find pcl name to start: ' pcl_name_to_start]);
        end
    end    
    tot_toc = 0;
    for i=initial_pcl_ix:size(pcl_filenames,2)
        tic
        pcl_shortname = GetPCLShortName(pcl_filenames{i});
        if ~isempty(pcl_shortname)
            tool_mass = 0;
            for j=1:size(table_gt.mass,1)
                if isempty(findstr('.ply',table_gt.tool{j,:}))
                    tool_name = table_gt.tool{j};
                else
                	tool_name=table_gt.tool{j}(1:findstr('.ply',table_gt.tool{j,:})-1);
                end
                if strcmp(pcl_shortname,tool_name)
                    tool_mass=table_gt.mass(j);
                    break;
                end
            end
            if tool_mass <= 0
                error('Could not find the pointcloud mass in the mass folder; writing pcl mass as -1');
            end            
            try
                [pTools{end+1}, pTools_vec, transfs_lists{end+1}] = getPToolsFromPcl(root_folder,pcl_filenames{i},tool_mass,table_gt_cols{task_ix},fit_threshold,pcl_filenames{i}(1:end-4),get_alt_SQ_Fits);
                curr_n_extracted_ptools = size(pTools_vec,1);
                pTools_vecs = [pTools_vecs; pTools_vec];
                dlmwrite(fileName, pTools_vec, 'delimiter', '\t','-append');
                disp(['Wrote ' num2str(size(pTools_vecs,1)) ' pTools in total']);
                disp(['     ' num2str(curr_n_extracted_ptools) ' for ' pcl_filenames{i} ' ' num2str(tool_mass) ' ' num2str(floor((i/size(pcl_filenames,2)*100))) '% ' num2str(i) '/' num2str(size(pcl_filenames,2)) ' pointclouds']);
            catch ME
                disp(ME.message);
                warning([ME.identifier '. Could not extract pTools from ' pcl_filenames{i}]);
            end
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
            
        end
    end
    fileattrib(fileName,'+w','a'); 
    save([root_folder 'extracted_pTools.mat']);
end

