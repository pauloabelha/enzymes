function [ grasp_point, action_point ] = GetGraspActionPoint( pcl, grasp_point, action_point)
    if nargin<3 || isempty(grasp_point) || isempty(action_point)
        orig_pcl = pcl;    
        orig_pcl = DownsamplePCL( orig_pcl, 5000 );
        pca_orig_pcl = pca(orig_pcl);
        orig_pcl_pca = orig_pcl*pca_orig_pcl;
        figure;
        scatter3(orig_pcl_pca(:,1),orig_pcl_pca(:,2),orig_pcl_pca(:,3),1);
        axis equal;
        view([0 90]);
        disp('Please click on the Grasp Point, the Action Point and the Contact Point\n');
        M = ginput(2);        
        grasp_point = [M(1,1:2) 0];
        action_point = [M(2,1:2) 0];
        close;
        
        figure;
        scatter3(orig_pcl_pca(:,1),orig_pcl_pca(:,2),orig_pcl_pca(:,3),1);
        axis equal;
        view([0 0]);
        usr_input = input('Please write the Z for the Grasp Point\n','s');
        grasp_point(3) = str2double(usr_input);
        usr_input = input('Please write the Z for the Action Point\n','s');
        action_point(3) = str2double(usr_input);
        close;
        
        grasp_point = grasp_point/pca_orig_pcl;
        action_point = action_point/pca_orig_pcl; 
    end    
end

