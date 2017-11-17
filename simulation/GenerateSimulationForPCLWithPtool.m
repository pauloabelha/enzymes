function [ simulation_folder ] = GenerateSimulationForPCLWithPtool( P, ptool, ptool_map, task, tool_name )
    % flag for whether to write inertia to Gazebo folder
    WRITE_INERTIA = 0;
    % flag whether to run cluster decimation and simplify the pcl mesh
    SIMPLIFY_MESH = 1;
    
    [SQ_grasp,SQ_action] = AlignPToolWithPCL( ptool, P, ptool_map );            
    [ transf_list ] = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task, SQ_grasp(end-2:end) );
    P = Apply3DTransfPCL(P,transf_list);      
    SQs = {SQ_grasp,SQ_action};
    SQs = ApplyTransfSQs(SQs,transf_list);
    
    [ task_params, positioning_function ] = TaskPositioningParams( task );
    [elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos] = feval(positioning_function, ptool, task_params, P);
    [ ~, ~, inertial ] = CalcCompositeMomentInertia(SQs, ptool);
    simulation_folder = '';
    CreateGazeboModelFolderStructure(simulation_folder, tool_name, elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos, P, ptool, inertial(1:3), inertial(4:6), task, WRITE_INERTIA,SIMPLIFY_MESH);
end

