function [sq_pcl] = SQ2Pcl_Archimedes( lambda, add_noise, type )
    %define boundary params for SQ inside-outside function
    %gamma1 for inside and gamma2 for outside
    gamma1 = 0.1;
    gamma2 = 0.1;
    
    min_n_points=1000000;
    taper_bound = ((abs(lambda(9))+abs(lambda(10)))/2)+1;
    n_grid_points = 2*min_n_points;
    if lambda(4) > 1
        n_grid_points = n_grid_points*lambda(4);
    end
    if lambda(5) > 1
        n_grid_points = n_grid_points*lambda(5);
    end
    taperx_mult = (abs(lambda(9))+1);
    tapery_mult = (abs(lambda(10))+1);
    n_grid_points = n_grid_points*taperx_mult*tapery_mult;

    
    n_grid_points = n_grid_points/max(1,((lambda(1)*lambda(2)*lambda(3))^0.8));

    point_spacing = (2*min(lambda(1:3)))/(-1+nthroot(n_grid_points,3));                  

    %create 3D bounding box grid

    [grid_x,grid_y,grid_z] = meshgrid(-(lambda(1)*taper_bound):point_spacing:(lambda(1)*taper_bound),-(lambda(2)*taper_bound):point_spacing:(lambda(2)*taper_bound),-(lambda(3)*taper_bound):point_spacing:(lambda(3)*taper_bound));
    grid = [grid_x(:) grid_y(:) grid_z(:)];

    %add nosie to the grid
    if add_noise
        rand_noise_grid = (rand(size(grid))-0.5)*point_spacing;
    else
        rand_noise_grid = zeros(size(grid));
    end
    grid = grid + rand_noise_grid;

    %generate transf matrix (rotation and translation)
    %grid is going to be rotated and translated to construct
    %a bounding box around the SQ
    if strcmp(type,'superellipsoid')
        R = eul2rotm_(lambda(6:8),'ZYZ');
    else if strcmp(type,'toroid')
            R = eul2rotm_(lambda(7:9),'ZYZ');
        end
    end    
    T = [R lambda(end-2:end)';0 0 0 1];
    %rotate and translate grid
    grid = [grid ones(size(grid,1),1)];
    grid = (T*grid')';
    grid = grid(:,1:3);

    %get the SQ function value for each grid point
    if strcmp(type,'superellipsoid')
        F = SQFunctionWoutNormalizingParams( lambda, grid );
    else if strcmp(type,'toroid')
            F = SQToroidFunctionWoutNormalizingParams( lambda, grid );
        end
    end
    %get SQ pcl as all grid points inside the boundary
    sq_pcl = grid(F >= (1-gamma1) & F < (1+gamma2),:);
end



% function [sq_pcl,sizes] = SQ2Pcl_Archimedes( lambda, add_noise, min_n_points, type )
%     %define boundary params for SQ inside-outside function
%     %gamma1 for inside and gamma2 for outside
%     gamma1 = 0.2;
%     gamma2 = 0.2;
%         
%     orig_lambda = lambda;
%     
%     max_v = -1;
%     min_v = 1e10;
%     min_ixs = [0 0 0 0];
%     max_ixs = [0 0 0 0];
%     k = 0; l = 0;
%     
%     tic
%     ix_sizes = 1;
%     for i=0.1:1:2.1
%         for j=0.1:1:2.1
%             for k=-1:1:1
%                 for l=-1:1:1
%                     lambda(4:5) = [i j];
%                     lambda(9:10) = [k l];
%                     taper_bound = ((abs(lambda(9))+abs(lambda(10)))/2)+1;
%                     n_grid_points = 5*min_n_points;
%                     if lambda(4) > 1
%                         n_grid_points = n_grid_points*lambda(4);
%                     end
%                     if lambda(5) > 1
%                         n_grid_points = n_grid_points*lambda(5);
%                     end
%                     taperx_mult = (abs(lambda(9))+1);
%                     tapery_mult = (abs(lambda(10))+1);
%                     n_grid_points = n_grid_points*taperx_mult*tapery_mult;
%                     
% %                     prop_1 = max(lambda(1)/lambda(2),lambda(2)/lambda(1));
% %                     prop_2 = max(lambda(1)/lambda(3),lambda(3)/lambda(1));
% %                     prop_3 = max(lambda(2)/lambda(3),lambda(3)/lambda(2));
% %                     
% %                     max_prop = max([prop_1 prop_2 prop_3])'
%                     
%                     n_grid_points = n_grid_points/((lambda(1)*lambda(2)*lambda(3))^0.85);
%                     
%                     point_spacing = (2*min(lambda(1:3)))/(-1+nthroot(n_grid_points,3));                  
% 
%                     %create 3D bounding box grid
%                     
%                     [grid_x,grid_y,grid_z] = meshgrid(-(lambda(1)*taper_bound):point_spacing:(lambda(1)*taper_bound),-(lambda(2)*taper_bound):point_spacing:(lambda(2)*taper_bound),-(lambda(3)*taper_bound):point_spacing:(lambda(3)*taper_bound));
%                     grid = [grid_x(:) grid_y(:) grid_z(:)];
% 
%                     %add nosie to the grid
%                     if add_noise
%                         rand_noise_grid = (rand(size(grid))-0.5)*point_spacing;
%                     else
%                         rand_noise_grid = zeros(size(grid));
%                     end
%                     grid = grid + rand_noise_grid;
% 
%                     %generate transf matrix (rotation and translation)
%                     %grid is going to be rotated and translated to construct
%                     %a bounding box around the SQ
%                     if strcmp(type,'superellipsoid')
%                         R = eul2rotm_(lambda(6:8),'ZYZ');
%                     else if strcmp(type,'toroid')
%                             R = eul2rotm_(lambda(7:9),'ZYZ');
%                         end
%                     end    
%                     T = [R lambda(end-2:end)';0 0 0 1];
%                     %rotate and translate grid
%                     grid = [grid ones(size(grid,1),1)];
%                     grid = (T*grid')';
%                     grid = grid(:,1:3);
%                     
%                     %get the SQ function value for each grid point
%                     if strcmp(type,'superellipsoid')
%                         F = SQFunctionWoutNormalizingParams( lambda, grid );
%                     else if strcmp(type,'toroid')
%                             F = SQToroidFunctionWoutNormalizingParams( lambda, grid );
%                         end
%                     end
%                     %get SQ pcl as all grid points inside the boundary
%                     sq_pcl = grid(F >= (1-gamma1) & F < (1+gamma2),:);
%                     n_ = size(sq_pcl,1);
%                     sizes(ix_sizes) = n_;
%                     ix_sizes=ix_sizes+1;
%                     if n_ > max_v
%                         max_v = n_;
%                         max_ixs = [i j k l];
%                     end
%                     if n_ < min_v
%                         min_v = n_;
%                         min_ixs = [i j k l];
%                     end
%                end
%             end
%         end
%     end
%     toc
%     disp([min_v max_v]);
%     disp([min_ixs; max_ixs]);    
% end