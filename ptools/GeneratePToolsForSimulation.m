% create one simulation-ready folder for each ptool for a given task
function GeneratePToolsForSimulation( simulation_folder, ptools, task, P_orig, ptool_maps )  
    % flag for whether to write inertia to Gazebo folder
    WRITE_INERTIA = 0;
    % flag whether to run cluster decimation and simplify the pcl mesh
    SIMPLIFY_MESH = 1;
    %% check ptool params
    % if ptools is a cell array, transform it to a N x 21 matrix
    if iscell(ptools)
       ptools = flatten_cell(ptools);
       new_ptools = zeros(numel(ptools),21);
       for i=1:numel(ptools)
           if numel(ptools{i}) ~= 21
               error(['One of the p-tools (#' num2str(i) ') is not a 1x21 array']);
           end
           new_ptools(i,:) = ptools{i};
       end   
       ptools = new_ptools;
    end 
    %% get Gazebo's param boundaries (e.g. min acceptable inertia and mass of objects)
   [ gazebo_params ] = GazeboParamsBoundaries();
    %% for each ptool: position, calculate inertia and write gazebo folder
%     exist_pcl = exist('P','var');
    MIN_INERTIA = gazebo_params.MIN_INERTIA;
    exist_pcl_orig = exist('P_orig','var');
    n_ptools = size(ptools,1);
    parfor i=1:n_ptools
        disp(i);
        % rotate ptools for task
        % rotate given pcl if it exists         
%         if exist_pcl_orig            
%             [SQ_grasp,SQ_action] = AlignPToolWithPCL( ptools(i,:), P_orig, ptool_maps(i,:) );            
%             [ transf_list ] = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task, SQ_grasp(end-2:end) );
%             P = Apply3DTransfPCL(P_orig,transf_list);      
%             SQs = {SQ_grasp,SQ_action};
%             SQs = ApplyTransfSQs(SQs,transf_list);
%         else
            P = PTool2PCL(ptools(i,:),task);
            [SQ_grasp,SQ_action] = GetPToolsSQs(ptools(i,:),task);   
            SQs = {SQ_grasp,SQ_action};
%         end       
        ptools(i,:) = CheckPToolMass(ptools(i,:));
        % position ptools for the task
        [ task_params, positioning_function ] = TaskPositioningParams( task );
        [elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos] = feval(positioning_function, ptools(i,:), task_params, P);        
        % rotate the MOI param
        % add inertial params 
        [ ~, ~, inertial ] = CalcCompositeMomentInertia(SQs,ptools(i,:));        
        disp(inertial);
        % check if ptool inertia is larger than minimum  
        if inertial(4) < MIN_INERTIA || inertial(5) < MIN_INERTIA || inertial(6) < MIN_INERTIA
            warning(['Calculated inertia for p-tool is smaller than ' num2str(MIN_INERTIA) ' Setting inertia to Gazebo minimum']); 
            for j=1:3
                inertial(3+j) = max(inertial(3+j),MIN_INERTIA);
            end
        end
        % write gazebo folder
        tool_name = ['ptool',num2str(i),'/'];
        %tool_name = ['tool_' task '/']
        CreateGazeboModelFolderStructure(simulation_folder, tool_name, elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos, P, ptools(i,:), inertial(1:3), inertial(4:6), task, WRITE_INERTIA,SIMPLIFY_MESH);
    end
end

function ptool = CheckPToolMass(ptool)
    MIN_MASS = 0.001;
    % check if ptool mass is larger than minimum   
    if ptool(21) < 0.001
       warning(['P-tool has mass ' num2str(ptool(21)) ' and minimum mass is ' num2str(MIN_MASS)]); 
       ptool(21) = MIN_MASS;
    end
end