% convert a ptool to a pcl
function [ P_out, transf_lists ] = PTool2PCL( ptools, task )
    % define resolution of each segment (grasp and action)
    N_POINTS = 5000;
    % if a task is given, rotate the pcl at the end
    if ~exist('task','var')
        task = '';
    end;    
    P_out = [];
    if size(ptools,1) > 1
        P_out = cell(1,size(ptools,1));
    end        
    transf_lists = cell(1,size(ptools,1));
    for i=1:size(ptools,1)
        ptool = ptools(i,:);        
        % get grasp and action SQs
        [ SQ_grasp, SQ_action ] = GetPToolsSQs( ptool );
        % if paraboloid
        if ptools(i,8) < 0
            [grasp_pcl, grasp_faces] = ParaboloidFaces(SQ_grasp, N_POINTS);
            rev_grasp_faces = [grasp_faces(:,3) grasp_faces(:,2) grasp_faces(:,1)];
            grasp_faces = [grasp_faces; rev_grasp_faces];
            grasp_normals = [];
        else        
            P = SQ2PCL(SQ_grasp,N_POINTS);
            grasp_pcl = P.v;
            grasp_normals = P.n;
            grasp_faces = convhull(grasp_pcl);
        end
        % if paraboloid
        if ptools(i,17) < 0
            [action_pcl, action_faces] = ParaboloidFaces(SQ_action,N_POINTS);
            rev_action_faces = [action_faces(:,3) action_faces(:,2) action_faces(:,1)];
            action_faces = [action_faces; rev_action_faces];
            action_normals = [];
        else            
            % if bent, calculate convhull before bending
            if SQ_action(11) > 0
                SQ_action_non_bent = SQ_action;
                SQ_action_non_bent(11) = 0;
                P = SQ2PCL(SQ_action_non_bent,N_POINTS);
                action_pcl = P.v;
                action_faces = convhull(action_pcl);
                action_pcl(:,1) = action_pcl(:,1) + (SQ_action(11) - sqrt(SQ_action(11)^2 + action_pcl(:,3).^2));
                action_normals = P.n;
                P.v = action_pcl; P.n = action_normals; P.f = action_faces - 1;
            else
                P = SQ2PCL(SQ_action,N_POINTS);
                action_pcl = P.v;
                action_normals = P.n;
                action_faces = convhull(action_pcl);
            end
        end
        pcl = [grasp_pcl; action_pcl];
        if isempty(grasp_normals) || isempty(grasp_normals)
            normals = [];
        else
            normals = [grasp_normals; action_normals];
        end
        % create segments
        grasp_segm.v = grasp_pcl;
        grasp_segm.n = grasp_normals;
        action_segm.v = action_pcl;
        action_segm.n = action_normals;
        % create segmentation indexes for grasping and action
        U = zeros(size(pcl,1),1);
        U(N_POINTS+1:end) = 1;    
        F = [grasp_faces; action_faces+size(grasp_pcl,1)];
        F = F - 1;
        % create point cloud
        P = PointCloud(pcl,normals,F,U,[],{grasp_segm,action_segm});
        % add colour to segments
        P = AddColourToSegms(P);
        % get the task's transformations
        transf_lists{i} = PtoolsTaskTranfs( ptool, task );
        % apply transformations to the ptool pcl
        if ~isempty(transf_lists{i})
            P = Apply3DTransfPCL({P},transf_lists{i});
        end
        %% remove very long faces
%         MAX_LONG_FACE = 0.05;
%         P.f = P.f + 1;
%         V_faces = [P.v(P.f(:,1),:) P.v(P.f(:,2),:) P.v(P.f(:,3),:)];
%         L = zeros(size(V_faces,1),3);
%         L(:,1) = sqrt(sum(abs(V_faces(:,4:6)-V_faces(:,1:3)).^2,2)) <= MAX_LONG_FACE;
%         L(:,2) = sqrt(sum(abs(V_faces(:,7:9)-V_faces(:,1:3)).^2,2)) <= MAX_LONG_FACE;
%         L(:,3) = sqrt(sum(abs(V_faces(:,7:9)-V_faces(:,4:6)).^2,2)) <= MAX_LONG_FACE;
%         valid_faces_ixs = sum(L,2) >= 2;
%         P.f = P.f(valid_faces_ixs,:);
%         P.f = P.f - 1;
        if size(ptools,1) > 1
            P_out{i} = P;
        else
            P_out = P;
        end        
    end
end










