function [grasp_SQ,action_SQ] = PlotModel( model, color_1, color_2, path_in )
    path = 0;
    if nargin > 3
        path = path_in;
    end

    figure;
    hold on
    grid off
    axis equal

    xlabel('x') % x-axis label
    ylabel('y') % y-axis label
    zlabel('z') % z-axis label
    
    [parts, angles, distances, ~] = SHAPEparam(model);
    
    [lambda_f,lambda_lower_def,lambda_upper_def,lambda_default,~] = SQparam(parts{1},0,0);
    [lambda_o,~,~] = get_lambda_o_from_f_and_default(lambda_f,lambda_default,lambda_lower_def,lambda_upper_def); 
    grasp_SQ = get_lambda_from_fixed_and_open(lambda_f,lambda_o,15);
    grasp_pcl = UniformSQSampling3D(grasp_SQ,0,4000);
    scatter3(grasp_pcl(:,1),grasp_pcl(:,2),grasp_pcl(:,3),'.b');
    
    [lambda_f,lambda_lower_def,lambda_upper_def,lambda_default,~] = SQparam(parts{2},0,0);
    [lambda_o,~,~] = get_lambda_o_from_f_and_default(lambda_f,lambda_default,lambda_lower_def,lambda_upper_def); 
    action_SQ = get_lambda_from_fixed_and_open(lambda_f,lambda_o,15);
    action_SQ(7) = angles{1}{1};
    action_SQ(end-2:end) = eul2rotm_([0 angles{1}{4} 0],'ZYZ')*[0;0;distances{1}{1}];
    action_pcl = UniformSQSampling3D(action_SQ,0,4000);
    scatter3(action_pcl(:,1),action_pcl(:,2),action_pcl(:,3),'.k');
    
    if ischar(path)
        n_points_part = 100000;
        n_points = n_points_part*2;
        [ pcl,normals,~ ] = SQsToPCL( {grasp_SQ, action_SQ},0,1,n_points_part);
        P.v = pcl;
        P.n = normals;
        P.f = [];
        P.u = zeros(n_points,1);
        P.u(n_points_part+1:end) = ones(n_points_part,1);
        P.c = zeros(size(P.u,1),3);
        P.c(1:n_points_part,:) = repmat(color_1,n_points_part,1);
        P.c(n_points_part+1:end,:) = repmat(color_2,n_points_part,1);
        WritePly(P,strcat(path,model,'.ply'));    
    end
end

