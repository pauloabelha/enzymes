function [ SQs, model, pcl_wout_action ] = ModifyActionPart( pcl_wout_action, model,SQs,new_model_vec )
    %% change the angle Z (alpha)
    if abs(new_model_vec(8) - model.angle_z) > 0.01
%         angleZ = -(new_model_vec(8) - model.angle_z);
%         Ry=[cos(angleZ),0,sin(angleZ);0,1,0;-sin(angleZ),0,cos(angleZ)];
%         vec_z = ApplyTransformations( model.action.vec , {'normal_rot',Ry} );
%         SQ_action(6:8) = rotm2eul_(vrrotvec2mat(vrrotvec([0;0;1],vec_z))); 
        center_action = [0 0 0]; % faster than modify everything following
        Ry=GetRotMtx(new_model_vec(8) - model.angle_z,'y');
        pcl_wout_action = pcl_wout_action*Ry; % as if center_action = [0 0 0]
        model.grasp.SQ(end-2:end) = bsxfun(@plus, bsxfun(@minus,model.grasp.SQ(end-2:end),center_action)*Ry , center_action);
        model.action.SQ(end-2:end) = bsxfun(@plus, bsxfun(@minus,model.action.SQ(end-2:end),center_action)*Ry , center_action);
        model.grasp.vec = bsxfun(@plus, bsxfun(@minus,model.grasp.vec,center_action)*Ry , center_action);
        model.action.vec = bsxfun(@plus, bsxfun(@minus,model.action.vec,center_action)*Ry , center_action);
        model.vec_centers = bsxfun(@plus, bsxfun(@minus,model.vec_centers,center_action)*Ry , center_action);
        model.action.contact_point = bsxfun(@plus, bsxfun(@minus,model.action.contact_point,center_action)*Ry , center_action); % Useless
        % update SQs
        SQs_ = SQs;
        for j=1:size(SQs,2)
            if j ~= model.action.ix
                SQs{j}(6:8) = rotm2eul_(Ry'*eul2rotm_(SQs{j}(6:8),'ZYZ'),'ZYZ');
                SQs{j}(end-2:end) = SQs{j}(end-2:end)*Ry; 
            end
        end
        SQs{model.action.ix}(end-2:end) = model.action.SQ(end-2:end);        
    end    
    SQ_action = SQs{model.action.ix};
    
    %% change the angle between centers (beta)
    if abs(new_model_vec(9) - model.angle_centers) > 0.01
        angleCenterDiff = -(new_model_vec(9) - model.angle_centers);
        Ry=[cos(angleCenterDiff),0,sin(angleCenterDiff);0,1,0;-sin(angleCenterDiff),0,cos(angleCenterDiff)];
        vec_centers = ApplyTransformations( model.vec_centers, {'normal_rot',Ry} );
        SQ_action(end-2:end) = vec_centers + model.grasp.SQ(end-2:end);
    end
    
    %% change the distance between centers
    if abs(new_model_vec(10) - model.dist_centers) > 0.01 
        dist_prop =  new_model_vec(10)/model.dist_centers;
        SQ_action(end-2:end) = (model.vec_centers*dist_prop) + model.grasp.SQ(end-2:end); 
    end
    
    %% change scale, shape and tapering
    SQ_action(1:5) = new_model_vec(1:5);
    SQ_action(9:10) = new_model_vec(6:7); 
    SQs{model.action.ix} = SQ_action;
   
end

