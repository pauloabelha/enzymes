% Gets a pcl ready for simulation given a task
function [ P, pTool_new, folder_path ] = PclToSim( P, pcl_shortname, pTool_struct, transf_list, pcl_root_folder, root_path, task_name  )
%     % sanity check for the size of pTool
%     if ~(size(pTool,2) == 18 || size(pTool,2) == 24)
%         error('The pTool vector should have either 18 or 24 elements');
%     end
    
    MIN_INERTIA = 0.000001;

    if ~isfield(P,'f') || isempty(P.f)
        if isempty(findstr('out',pcl_shortname))
            if ~isempty(findstr('.',pcl_shortname))
                pcl_shortname=pcl_shortname(1:findstr('.',pcl_shortname)-1); 
            end
        else
            pcl_shortname=pcl_shortname(1:findstr('out',pcl_shortname)-2);
        end
        warning(['Pcl ' pcl_shortname ' has no faces. Will attempt to search for its original pcl (' pcl_shortname '.ply) with faces under root path ' pcl_root_folder]);
        pcl_filenames = FindAllFilesOfType( {'ply'},pcl_root_folder);
        orig_pcl_with_faces_found = 0;
        for i=1:size(pcl_filenames,2)
            if ~isempty(findstr(pcl_shortname,pcl_filenames{i}))
                P_orig = ReadPointCloud([pcl_root_folder pcl_filenames{i}]);
                if isfield(P_orig,'f') && ~isempty(P_orig.f)
                    orig_pcl_with_faces_found = 1;
                    disp(['We''re lucky! Original pcl with faces was found at found ' pcl_root_folder pcl_filenames{i}]);
                    P.f = P_orig.f;
                    if sum(min(P.f)) > 2
                        P.f = P.f - 1;
                    end
                    break;
                end
            end
        end
        if ~orig_pcl_with_faces_found
            warning(['Could not find the original pcl with faces in ' pcl_root_folder]);
        end
    end
    
    %% rotate SQs
    [SQs,~] = rotateSQs(pTool_struct.SQs,pTool_struct.grasp.ix,pTool_struct.action.ix,task_name);
    P = Apply3DTransfPCL(P,transf_list);
    
    %P = DownsamplePCL(P,max(10000,round(size(P.v,1)/2)),1);
    
    %% evaluate the positioning function for the given task
    pTool = getVector(pTool_struct);
    [ task_params, positioning_function ] = TaskPositioningParams( task_name );    
    [elbow_pos, tool_relative_pos] = feval(positioning_function, pTool, task_params);
    if strcmp(task_name,'lifting_pancake')
        rot_mtx = GetRotMtx(pi/20,'y');
        P_rot = Apply3DTransfPCL({P},{rot_mtx});
        pancake_bottom_center = task_params{1};
        diff = pancake_bottom_center(3) - (min(P_rot.v(:,3))+elbow_pos(3));
        if diff >= 0
            P_rot.v(:,3) = P_rot.v(:,3) + diff + 0.001; 
        end
        P = P_rot;
        pTool_params.orig_pcl = P;
    end
    
    
    
    %% Params storage used to create Gazebo files
    %% Moment of inertia, Center of mass and Mass
    %  The inertia is re-written as a diag matrix because we will use
    %  functions already working for another part of the project
    %  (writeSdfFileHammer), which takes a matrix of inertia as parameter.
    pTool_params.mass = pTool(18);      
    if size(pTool,2) == 18
        [ pTool_params.inertia,pTool_params.center_mass ] = CalcCompositeMomentInertia( SQs, pTool_params.mass);              
        pTool_new = [pTool pTool_params.center_mass pTool_params.inertia(1,1) pTool_params.inertia(2,2) pTool_params.inertia(3,3)];    
    else
        if size(pTool,2) == 24
            pTool_params.center_mass = [pTool(19) pTool(20) pTool(21)];
            pTool_params.inertia = diag([pTool(22) pTool(23) pTool(24)]);            
            pTool_new = pTool;
        end
    end
    
    write_intertia = 1;
    if min(pTool_params.inertia) < MIN_INERTIA
        write_intertia = 0;
    end    
    
    pTool_params.elbow_pos = elbow_pos;
    pTool_params.tool_pos = tool_relative_pos;
    
    
    pTool_params.PPTool = getPFromPToolVec(pTool, task_name, 0, 0);
    if strcmp(task_name,'lifting_pancake')
        rot_mtx = GetRotMtx(pi/30,'y');
        P_rot = Apply3DTransfPCL({pTool_params.PPTool},{rot_mtx});
        pancake_bottom_center = task_params{1};
        diff = pancake_bottom_center(3) - (min(P_rot.v(:,3))+elbow_pos(3));
        if diff >= 0
            P_rot.v(:,3) = P_rot.v(:,3) + diff + 0.001; 
        end
        pTool_params.PPTool = P_rot;
    end
    
    %% Write files & folder
    % create a new folder for the current model
    gazebo_folder_name = [pTool_struct.name '/'];
    folder_path = CreateGazeboModelFolderStructure(root_path, gazebo_folder_name, task_name, pTool_params, '~/enzymes/simulation/', write_intertia);
end


