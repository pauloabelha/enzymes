% Transform a pTool vector into a simulation-ready version for a given task 
% task regards orienting (angles of SQs) the tool for a given task
% positioning_function regards positioning in spcae (it doesn't change the orientation)

function [ P, folder_path, SQs ] = pToolVec2Sim( root_path, suffix_name, ptool, task_name )

    MIN_INERTIA = 0.00001;
    MIN_MASS = 0.01;

% CREATE A FUNCTION [x_offset, z_offset, tool_pos] = getToolPosition(task, ....allparamsneeded....)

    % sanity check for the size of pTool_vec
    if size(ptool,2) ~= 23
        error('The pTool vector should have 23 dimensions');
    end
    
    %% evaluate the positioning function for the given task
    [ task_params, positioning_function ] = TaskPositioningParams( task_name );
    [P,SQs] = getPFromPToolVec(ptool, task_name, 1000);
    if strcmp(task_name,'rolling_dough')
        grasp_above_action = 0;
        if SQs{1}(end-1) > SQs{2}(end-1)
            grasp_above_action = 1;
        end
        task_params = {task_params, grasp_above_action};
        task_params = flatten_cell(task_params);
    end
    [elbow_pos, tool_relative_pos] = feval(positioning_function, ptool, SQs, task_params);
    
    if strcmp(task_name,'lifting_pancake')
        rot_mtx = GetRotMtx(pi/30,'y');
        P_rot = Apply3DTransfPCL({P},{rot_mtx});
        pancake_bottom_center = task_params{1};
        diff = pancake_bottom_center(3) - (min(P_rot.v(:,3))+elbow_pos(3));
        if diff >= 0
            P_rot.v(:,3) = P_rot.v(:,3) + diff + 0.001; 
        end
        P = P_rot;
    end
    
    pTool_params.mass = ptool(23);    
    pTool_params.mass = max(pTool_params.mass,MIN_MASS);
    
    %% Params storage used to create Gazebo files
    %% Moment of inertia, Center of mass and Mass
    %  The inertia is re-written as a diag matrix because we will use
    %  functions already working for another part of the project
    %  (writeSdfFileHammer), which takes a matrix of inertia as parameter.
    ptool_inertia  = AddInertialToPtools(ptool,task_name);
    
    pTool_params.center_mass = ptool_inertia(end-5:end-3);
    pTool_params.inertia = ptool_inertia(end-2:end);    
    
    pTool_params.inertia = max(pTool_params.inertia,MIN_INERTIA);
    
    write_intertia = 1;
%     if pTool_params.inertia(1) < MIN_INERTIA && pTool_params.inertia(2) < MIN_INERTIA && pTool_params.inertia(3) < MIN_INERTIA
%         write_intertia = 0;
%     end 
    
    pTool_params.elbow_pos = elbow_pos;
    pTool_params.tool_pos = tool_relative_pos;
    pTool_params.PPTool = P;
    pTool_params.orig_pcl = [];
    
    %% Write files & folder
    % create a new folder for the current model
    gazebo_folder_name = strcat('pTool',suffix_name,'/');
    folder_path = CreateGazeboModelFolderStructure(root_path, gazebo_folder_name, task_name, pTool_params,'~/enzymes/simulation/',write_intertia);
end
