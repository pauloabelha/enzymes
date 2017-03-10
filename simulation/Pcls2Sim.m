function [ output_args ] = Pcls2Sim( pTools, transfs_lists, root_folder, pcl_root_folder, sim_root_folder, task_name, task_pos_function  )
      %prev_pTool_name = pTools{1}.name;
      for i=1:size(pTools,2)    
        for j=1:size(pTools{i},2)
            %strcmp(pTools{i}.name,prev_pTool_name)
            pTool_name = pTools{i}{j}.name;
            pcl_shortname=pTool_name(1:findstr('_option',pTool_name)-1); 
            pcl_filename = [pcl_shortname '.ply'];
            P = ReadPointCloud([root_folder pcl_filename]);
            PclToSim( P, pcl_shortname, pTools{i}{j}, transfs_lists{i}{j}, pcl_root_folder, sim_root_folder, task_name, task_pos_function  );
        end
      end

end

