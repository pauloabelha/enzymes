function [folder_path] = CreateGazeboModelFolderStructure( simulation_folder, gazebo_folder_name, elbow_pos, tool_pos, tool_rot, action_tracker_pos, P,  ptool, center_mass, inertia, task, write_intertia, simplify_mesh)
    %% Gazebo model root folder
    GAZEBO_MODELS_ROOTPATH = '~/.gazebo/gazebo_models/';
    MESHLAB_SCRIPTS_PATH = '~/enzymes/scripts/';

    folder_path = [GAZEBO_MODELS_ROOTPATH task '/' simulation_folder gazebo_folder_name];
    
    mass = ptool(end);
    
    if ~exist(folder_path,'dir')
        mkdir(folder_path);
        fileattrib(folder_path,'+w','a');
    end
    
    writeModelConfig(folder_path);
    writeSdfFile( folder_path,...
                  task,...
                  elbow_pos,...
                  tool_pos,...
                  tool_rot,...
                  action_tracker_pos,...
                  center_mass,...
                  mass,...
                  inertia,...
                  write_intertia );
              
              
    % write the ptool and convert it to .dae          
    WritePly(P, [folder_path 'tool.ply']);    
    extra_command = '';
    if simplify_mesh
        extra_command = ['-s ' MESHLAB_SCRIPTS_PATH 'ClusteringDecimation.mlx'];
    end
    command = ['meshlabserver -i ' folder_path 'tool.ply' ' -o ' folder_path 'tool.dae ' extra_command];
    disp(command);
    system(command);
    %system(['rm ' folder_path 'tool.ply']);
    
    %delete(ply_full_name);
    fileattrib([folder_path '/*'],'+w','a');

end
