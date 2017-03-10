function [ output_args ] = PclsToSim( root_folder, pcl_folder, output_folder, pcl_faces_path, task_name, task_pos_function  )
    
[ pTools, ~, transfs_lists, ~ ] = ...
    getPToolsFromFolder( [root_folder pcl_folder], task_name, 1.5 );
Pcls2Sim( pTools, transfs_lists, [root_folder pcl_folder], pcl_faces_path, [root_folder output_folder], task_name, task_pos_function  )

end

