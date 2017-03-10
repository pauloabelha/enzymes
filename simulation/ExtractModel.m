% Returns a model from a set of SQs and a grasp and actionpoints from a
% robot demonstration of how to use a tool.
%The chosen model will have the SQs whose central points are closest to the
%grasp and action points
function [ model ] = ExtractModel( SQs, grasp_point,action_point)
    %extract central SQs points
    min_grasp_dist = 1e10;
    min_action_dist = 1e10;
    for i=1:size(SQs,2)
        orig_central_point = SQs{i}(end-2:end);
        grasp_dist = pdist([orig_central_point;grasp_point]);
        if grasp_dist < min_grasp_dist
            min_grasp_dist = grasp_dist;
            model.grasp.ix = i;
            model.grasp.SQ = SQs{i};
            model.grasp.SQ(end-2:end) = orig_central_point;
            model.grasp.vec = (eul2rotm_(model.grasp.SQ(6:8),'ZYZ')*[0;0;1])';
            model.grasp.vec = model.grasp.vec/norm(model.grasp.vec);
        end
        action_dist = pdist([orig_central_point;action_point]);
        if action_dist < min_action_dist            
            min_action_dist = action_dist;
            model.action.ix = i;
            model.action.SQ = SQs{i};
            model.action.SQ(end-2:end) = orig_central_point;
            model.action.vec = (eul2rotm_(model.action.SQ(6:8),'ZYZ')*[0;0;1])';
            model.action.vec = model.action.vec/norm(model.action.vec);
        end
    end
    model.dist_centers = pdist([model.grasp.SQ(end-2:end);model.action.SQ(end-2:end)]); % d
    
    %get difference in angle
    model.angle_z = subspace(model.grasp.vec',model.action.vec'); % Alpha
    
    if model.dist_centers < 0.001
        model.angle_centers = 0;
        model.vec_centers = [0;0;0];
    else
        vec_centers = (model.action.SQ(end-2:end)- model.grasp.SQ(end-2:end));
        model.vec_centers = vec_centers;
        vec_centers = vec_centers/norm(vec_centers);
        model.angle_centers = subspace(model.grasp.vec',vec_centers'); % Beta
    end   
     
    model.grasp.type = 'superellipsoid';
    model.action.type = 'superellipsoid';
end

