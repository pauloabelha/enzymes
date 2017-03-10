function [ P,model,SQs ] = GetModelMesh( path,pcl_name,grasp_point,action_center_point,tool )
    % read pointcloud from file
    [P,segms] = ReadPointCloud(strcat(path,pcl_name),500);
    % rescale if hammer  
    if strcmp(tool,'hammer')
        [P.v,segms] = ToolScalling( P.v, 'hammer', segms );
    end  
    % get grasp and action point if they were not provided
    [ grasp_point, action_center_point] = GetGraspActionPoint( P.v, grasp_point, action_center_point );
    
    %% Perform a free fitting on each segment. if it fails, fit action again.
    % perform only normal fitting (no tapering, bending etc.) - [1 0 0 0 0]
    [SQs]=PCL2SQ(P.segms,4,0,0,[1 0 0 0 0]);
    
%     % extract a model from the fitted superquadric
%     [ model ] = ExtractModel( SQs, grasp_point,action_center_point, action_contact_point ); 
%     pcl_test = SQsToPCL(SQs,P.segms,1);
%     segm_action = P.segms{model.action.ix}.v;
%     
%     % ask if good
%     figure;
%     scatter3(pcl_test(:,1),pcl_test(:,2),pcl_test(:,3),1);
%     axis equal;
%     view([0 0]);
%     well_fitted = input('Is action SQ well generated? (y or n)', 's');
%     close;
%     
%     while ~strcmp(well_fitted,'y')
%         % Get new SQ fitted and replace it in SQs
%         [new_SQ_action]=PCL2SQ(segm_action,8,0,0,0,0);
%         SQs{model.action.ix} = new_SQ_action{1};
%         pcl_test = SQsToPCL(SQs,P.segms,1);
%         
%         % plot and ask if good again
%         figure;
%         scatter3(pcl_test(:,1),pcl_test(:,2),pcl_test(:,3),1);
%         axis equal;
%         view([0 0]);
%         well_fitted = input('Is action SQ well generated? (y or n)', 's');
%         close;
%     end
    
    % extract final model from the well fitted superquadric
    [ model ] = ExtractModel( SQs, grasp_point,action_center_point); 
    
    %% ensure grasp and action point are not the same
    while pdist([model.grasp.SQ(end-2:end);model.action.SQ(end-2:end)]) < 0.0001
        [ grasp_point, action_center_point ] = GetGraspActionPoint( pcl );
        [ model ] = ExtractModel( SQs, grasp_point,action_center_point ); 
    end
    
    %% get every SQ except the action one
    SQs_wout_action = {};
    for i=1:size(SQs,2)
        if i ~= model.action.ix
            SQs_wout_action{end+1} = SQs{i};
        end
    end
    
    [P.v,P.n,P.f]=SQsToPCL(SQs_wout_action,segms,1);
    
    %% 1st Rotation : align action zVector with X axis
    % Get rotation matrix between action part zVector and the x axis
    r = vrrotvec(model.action.vec,[1;0;0]);
    rm = vrrotvec2mat(r);
    % rotate the pcl so the action aligns with the x axis
    P.v = P.v*rm';
    % rotate grasp and action centers to follow pcl rotation
    model.grasp.SQ(end-2:end) = model.grasp.SQ(end-2:end)*rm';
    model.action.SQ(end-2:end) = model.action.SQ(end-2:end)*rm';
    model.grasp.vec = model.grasp.vec*rm';
    model.action.vec = model.action.vec*rm';
    model.vec_centers = model.vec_centers*rm';     
    % update SQs
    for i=1:size(SQs,2)
        SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
        SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';   
    end      
    
    
    % OLD VERSION - NOT WORKING ( rotates on several axis at the same time)
%     % Get the current zvector of grasp in the base (normalized)
%     centers_vec = model.action.SQ(end-2:end)-model.grasp.SQ(end-2:end);
%     centers_vec = centers_vec/norm(centers_vec);
%     % Get the vector we want (as if tool was in xz plan)
%     % Vector proj on x axis, norm : dist_centers*sin(90-alpha+beta)
%     % Vector proj on z axis, norm : dist_centers*cos(90-alpha+beta)
%     wanted_centers_vec = [model.dist_centers*sin(pi()/2-model.angle_z+model.angle_centers) ; 0 ; model.dist_centers*cos(pi()/2-model.angle_z+model.angle_centers)];
%     wanted_centers_vec = wanted_centers_vec/norm(wanted_centers_vec);

    %% Get the object in xz plan : Align tool grasp
    % Get the current vector Btween action and grasp centers, normalized,
    % proj on yz plan
    vec_centers = model.action.SQ(end-2:end)-model.grasp.SQ(end-2:end);
    vec_centers_yz = [0;vec_centers(2);vec_centers(3)];
    % get rotation matrix in order to put this vector in xz plan
    r = vrrotvec(vec_centers_yz,[0;0;1]);
    rm = vrrotvec2mat(r); 
    % Get the object in xz plan : Align tool grasp
    P.v = P.v*rm';
    model.grasp.SQ(end-2:end) = model.grasp.SQ(end-2:end)*rm';
    model.action.SQ(end-2:end) = model.action.SQ(end-2:end)*rm';
    model.action.vec = model.action.vec*rm';
    model.grasp.vec = model.grasp.vec*rm';
    model.vec_centers = model.vec_centers*rm';
    % update SQs
    for i=1:size(SQs,2)
        SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
        SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';   
    end  
    
         
    %% If the tool is reversed (in X), rotate it along the Z axis
    pcl_action = UniformSQSampling3D( SQs{model.action.ix}, 0, 2000 );
    pcl_full_tool = [P.v;pcl_action];
    figure;
    scatter3(pcl_full_tool(:,1),pcl_full_tool(:,2),pcl_full_tool(:,3),1);
    axis equal;
    view([0 0]);
    reverse_tool = input('Revert the tool? (y or n)','s');
    close;
    if strcmp(reverse_tool, 'y')
        Rz=GetRotMtx(pi,'z');       
        P.v = ApplyTransformations( P.v, {'normal',Rz} );
        model.grasp.SQ(end-2:end) = ApplyTransformations( model.grasp.SQ(end-2:end), {'normal',Rz} );
        model.action.SQ(end-2:end) = ApplyTransformations( model.action.SQ(end-2:end), {'normal',Rz} );
        model.grasp.vec = ApplyTransformations( model.grasp.vec, {'normal',Rz} );
        model.action.vec = ApplyTransformations( model.action.vec, {'normal',Rz} );
        model.vec_centers = ApplyTransformations( model.vec_centers, {'normal',Rz} );
        % update SQs
        for i=1:size(SQs,2)
            SQs{i}(6:8) = rotm2eul_(ApplyTransformations(eul2rotm_(SQs{i}(6:8),'ZYZ'),{'normal',Rz}),'ZYZ');
            SQs{i}(end-2:end) = ApplyTransformations(SQs{i}(end-2:end), {'normal',Rz} );  
        end
    end
    
    %%
%     
%     % get rotation matrix between the grasp vector and the Z axis       
%     r = vrrotvec(model.grasp.vec,[0;0;1]);
%     rm = vrrotvec2mat(r);    
%     % rotate the pcl so the grasp aligns with the Z axis
%     P.v = P.v*rm';
%     % rotate grasp and action centers to follow pcl rotation
%     model.grasp.SQ(end-2:end) = model.grasp.SQ(end-2:end)*rm';
%     model.action.SQ(end-2:end) = model.action.SQ(end-2:end)*rm';
%     model.grasp.vec = model.grasp.vec*rm';
%     model.action.vec = model.action.vec*rm';
%     model.vec_centers = model.vec_centers*rm';    
%     % update SQs
%     for i=1:size(SQs,2)
%         SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
%         SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';   
%     end    
%     % if the tool is upside down (in Z), rotate it along the Y axis
%     if model.action.SQ(end) < model.grasp.SQ(end)
%         Ry=GetRotMtx(pi,'y');       
%         P.v = ApplyTransformations( P.v, {'normal',Ry} );
%         model.grasp.SQ(end-2:end) = ApplyTransformations( model.grasp.SQ(end-2:end), {'normal',Ry} );
%         model.action.SQ(end-2:end) = ApplyTransformations( model.action.SQ(end-2:end), {'normal',Ry} );
%         model.grasp.vec = ApplyTransformations( model.grasp.vec, {'normal',Ry} );
%         model.action.vec = ApplyTransformations( model.action.vec, {'normal',Ry} );
%         model.vec_centers = ApplyTransformations( model.vec_centers, {'normal',Ry} );
%         % update SQs
%         for i=1:size(SQs,2)
%             SQs{i}(6:8) = rotm2eul_(ApplyTransformations(eul2rotm_(SQs{i}(6:8),'ZYZ'),{'normal',Ry}),'ZYZ');
%             SQs{i}(end-2:end) = ApplyTransformations(SQs{i}(end-2:end), {'normal',Ry} );  
%         end
%     end  
%     % get the action vector as going from the center of action to the
%     % projected point of the action center onto the Z axis (also grasp vector)
%     central_base_point_xy = [model.grasp.SQ(end-2) model.grasp.SQ(end-1) 0];
%     center_action_vec = model.action.SQ(end-2:end) - central_base_point_xy;
%     center_action_vec = [center_action_vec(1:2) 0];
%     model.action.vec = center_action_vec/norm(center_action_vec);    
%     % get rotation matrix to align action vector to the demonstration vector
%     r = vrrotvec(model.action.vec,demo_action_vec);
%     rm = vrrotvec2mat(r); 
%     % align action vector to the demonstration vecctor
%     P.v = P.v*rm';
%     model.grasp.SQ(end-2:end) = model.grasp.SQ(end-2:end)*rm';
%     model.action.SQ(end-2:end) = model.action.SQ(end-2:end)*rm';
%     model.action.vec = model.action.vec*rm';
%     model.grasp.vec = model.grasp.vec*rm';
%     model.vec_centers = model.vec_centers*rm';
%     % update SQs
%     for i=1:size(SQs,2)
%         SQs{i}(6:8) = rotm2eul_(rm*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
%         SQs{i}(end-2:end) = SQs{i}(end-2:end)*rm';   
%     end  

    %% Move tool base center (grasp center) to the origin in X,Y,Z
    center_base = model.grasp.SQ(end-2:end);
    P.v = P.v - repmat(center_base,size(P.v,1),1);   
    model.grasp.SQ(end-2:end) = model.grasp.SQ(end-2:end) - center_base;
    model.action.SQ(end-2:end) = model.action.SQ(end-2:end) - center_base;
    % update SQs
    for i=1:size(SQs,2)
        SQs{i}(end-2:end) = SQs{i}(end-2:end) - center_base; 
    end
    
    %% Calculate right position of contact point and its distance to the action center
    pcl_action = UniformSQSampling3D( SQs{model.action.ix}, 0, 500 );
    model.action.contact_point = [max(pcl_action(:,1)) 0 model.action.SQ(end)];
    model.action.contact_offset = model.action.contact_point(1)-model.action.SQ(end-2);
    
    %% Move tool up along Z axis so its base (minimum Z point) is on the origin
%     [~,min_z_ix] = min(P.v(:,3));
%     up_vec = P.v(min_z_ix,:);     
%     P.v(:,3) = P.v(:,3) - repmat(up_vec(3),size(P.v,1),1);   
%     model.grasp.SQ(end) = model.grasp.SQ(end) - up_vec(3);
%     model.action.SQ(end) = model.action.SQ(end) - up_vec(3);  
%     % update SQs
%     for i=1:size(SQs,2)
%         SQs{i}(end) = SQs{i}(end) - up_vec(3);  
%     end

    %% Update center position and Euler angles for the action part
	r = vrrotvec([0;0;1],model.action.vec);
    rm = vrrotvec2mat(r);
    P.u=[];
end