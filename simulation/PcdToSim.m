% transform a pcl into a simulation-ready version while modifying the action segment
function [ P_orig,model_orig,SQs_orig ] = PcdToSim( path,pcl_name,tool,grasp_point,action_center_point, nailBox_height, targetDist, arm_length, tool_mass )
    %try to open the Inputs file
    fid=fopen('~/.gazebo/models/hammering_training/Inputs.txt','w+');
    if fid < 0
        error('Could not open filepath');
    end

    [ P_orig,model_orig,SQs_orig ] = GetModelMesh( path,pcl_name,grasp_point,action_center_point,tool );
    % change model relationships, getting a new action part
    
    
    %get a list of new model vectors and their names
    %loop through every new model vector and create folder and files
    %according to its name in the corresponding list of names
    SQs = SQs_orig;
    model = model_orig;
    base_action_vector = [SQs{model.action.ix}(1:5) SQs{model.action.ix}(9:10) model.angle_z model.angle_centers model.dist_centers tool_mass];
    
    %% Sampling all vectors in order to create desired models 
    %  (modify wanted new action vectors for new tools inside SampleModelVectors)
    [list_model_vectors, list_model_names] = SampleModelVectors(base_action_vector,'star_sampling');
    
%     grasp_pcl = UniformSQSampling3D( SQs{model.grasp.ix}, 0, 250 );
%     grasp_faces = delaunay(grasp_pcl(:,1),grasp_pcl(:,2),grasp_pcl(:,3));
%     grasp_faces = grasp_faces-1;
%     P.f = grasp_faces;
%     P.v = grasp_pcl;
    
    parfor ix = 1:length(list_model_names)
        tic;
        
        %% Reset and set variables for the new model
        P = P_orig;
        model = model_orig;
        SQs = SQs_orig;
        new_model_vector = list_model_vectors{ix};
        new_model_name = list_model_names{ix};
        
        [ SQs, model, P.v ] = ModifyActionPart( P.v, model,SQs,new_model_vector );
        
        %% add the action part to the mesh
        action_pcl = UniformSQSampling3D( SQs{model.action.ix}, 0, 500 );        
        
        %% Delaunay triangulation to create mesh faces
        action_faces = delaunay(action_pcl(:,1),action_pcl(:,2),action_pcl(:,3));
        action_faces = action_faces - 1;
        %             P.f = [P.f; action_faces+size(P.v,1)];
        %             P.v = [P.v; action_pcl];       

        P.f = [P.f ; action_faces+size(P.v,1)];
        P.v = [P.v ; action_pcl];        
        
        
        %% Get proj coord for center of action in tool's base
        % proj_center_action = [model.grasp.SQ(end-2:end-1) model.action.SQ(end)];
        
        %% Tool's centre of rotation position in z.
        
        % Tool main dimensions offset
        % Formula : dist_centersOfMass * sin(90deg - alpha + beta)
        impact_offset = new_model_vector(10)*sin(pi()/2-new_model_vector(8)+new_model_vector(9));
        
        % Distance from the center of action to the contact point
        action_contact_offset = model.action.contact_offset;
        
        % fix rotation to 90deg (arm aligned with z) :
        % ---> no need for z additional offset.
        
        % For rotation around the base of the tools grasp :
        % + grasp_centerOfMass_zPos*sin(90deg-alpha)
        %impact_offset = impact_offset + model.grasp.SQ(end)*sin(pi()/2-new_model_vector(8));
        
        
        rotation_point_zPos = nailBox_height + impact_offset + action_contact_offset;
        
        %% Pose offset value in X;
        % necessary for the right distance between the tool (with its box) and the target.
        % Get the distance to the nail of centre of rotation : its absolute position on x axis
        
        % Formula : dist_centersOfMass * cos(90deg - alpha + beta)
        toolDist = new_model_vector(10)*cos(pi()/2-new_model_vector(8)+new_model_vector(9));
        
        % Fix rotation to 90deg (arm aligned with z) :
        toolDist = toolDist + arm_length;
        
        % For rotation around the base of the tools grasp :
        % + grasp_centerOfMass_zPos*cos(90deg-alpha)
        %toolDist = toolDist + model.grasp.SQ(end)*cos(pi()/2-new_model_vector(8));
        
        pose_X_offset = targetDist  - toolDist;
        
        %% Tool pos relative to rotation centre pos
        tool_pos = [0 0 arm_length];
        
        %% Params storage used to create Gazebo files
        %% Moment of inertia, Center of mass and Mass
        % according to predefined density of material.
        % (default is 1: 'water')
        model_params = struct();
        model_params.mass = new_model_vector(11);
        [ inertia, center_mass ] = CalcCompositeMomentInertia(SQs,model_params.mass);
        model_params.inertia = inertia;
        model_params.center_mass = center_mass;    
        model_params.pose_X_offset = pose_X_offset;
        model_params.rotation_point_zPos = rotation_point_zPos;
        model_params.tool_pos = tool_pos;
        model_params.P = P;
        
%         %% Normals for the pcl
%         %P.n = Get_Normals(P.v);
%         P.n = [];
%         %% Write files & folder
%         % write pcl+faces to file, adding '_model' to the name of the new pcl
%         plyFilePath  = strcat(path,pcl_name(1:end-4),'_model',new_model_name,'.ply'); % full path to the new points cloud file
%         P.v = [0 0 0];
%         P.f = [3 0 0 0];
%         WritePly(P,plyFilePath);
        
        % write model vector and inertia to input txt file
%         fprintf(fid,num2str(new_model_vector));
%         fprintf(fid,' ');
%         fprintf(fid,num2str(inertia(1,1)));
%         fprintf(fid,' ');
%         fprintf(fid,num2str(inertia(2,2)));
%         fprintf(fid,' ');
%         fprintf(fid,num2str(inertia(3,3)));
%         fprintf(fid,' ');
%         fprintf(fid,'\n');
        
        %% Write files & folder
        % create a new folder for the current model, and give the root path
        % for this folder
        root_path = '~/.gazebo/models/hammering_data/';
        gazebo_folder_name = strcat('hammer_training',new_model_name,'/');

        % create a new folder for the current model
        CreateGazeboModelFolderStructure(root_path, gazebo_folder_name, model_params);
        disp(toc);
    end
end
