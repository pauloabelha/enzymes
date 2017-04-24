function GeneratePCLsWPToolsForSim( simulation_folder, ptools, task, P_orig, ptool_maps, completing, DEBUG_MODE, tool_debug_folder, tool_debug_suffix )  
    if ~exist('DEBUG_MODE','var')
        DEBUG_MODE = 0;
    end
    if ~exist('tool_debug_folder','var')
        tool_debug_folder = '';
    end
    if ~exist('tool_debug_suffix','var')
        tool_debug_suffix = '';
    end
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
    n_ptools = size(ptools,1);
    if completing
       ptool_folders = FindAllFolders( ['~/.gazebo/gazebo_models/' task '/' simulation_folder] ); 
    end
    for i=1:n_ptools
        ptool_already_processed = 0;
        for j=1:numel(ptool_folders)
            split_folder_name = strsplit(ptool_folders{j},'/');
            if strcmp(split_folder_name{1}(end),num2str(i))
                ptool_already_processed = 1;
                break;
            end
        end
        if ptool_already_processed
            disp([simulation_folder ptool_folders{j} ': Ptool already processed']);
            continue;
        end
        disp(i);
        % rotate ptools for task
        % rotate given pcl if it exists         
         
        [SQ_grasp,SQ_action] = AlignPToolWithPCL( ptools(i,:), P_orig, ptool_maps(i,:) );            
        [ transf_list ] = GetTrasnfsSQsTask( SQ_grasp, SQ_action, task, SQ_grasp(end-2:end) );
        P = Apply3DTransfPCL(P_orig,transf_list);      
        SQs = {SQ_grasp,SQ_action};
        SQs = ApplyTransfSQs(SQs,transf_list);
    
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
        if DEBUG_MODE
            if isempty(tool_debug_folder)
                tool_name = ['tool_' task '/'];
            else
                tool_name = [tool_debug_folder 'ptool_' tool_debug_suffix '/'];
            end
        else
            tool_name = ['ptool',num2str(i),'/'];
        end
        CreateGazeboModelFolderStructure(simulation_folder, tool_name, elbow_pos, tool_relative_pos, tool_rot, action_tracker_pos, P, ptools(i,:), inertial(1:3), inertial(4:6), task, WRITE_INERTIA,SIMPLIFY_MESH);
    end
end

