function [SQ,F,E,E_pcl_SQ, E_SQ_pcl ] = FitSQtoPCL_Bending(pcl,pcl_scale,ix,opt_options,fitting_modes) 
    SQ = zeros(15,1); F = Inf; E = Inf; E_PROP = Inf; E_pcl_SQ = Inf; E_SQ_pcl= Inf;
    MIN_PCL_SCALE = 1e-7;
    if fitting_modes(3) == 1
        safe_iter = 1;
        x_center_bound_factor = .1;
        x = zeros(1,15);
        %fit N superquadrics to the pcl in parallel    
        % get initial center
        pcl_center_x = [];
        while isempty(pcl_center_x)
            x_center_bound = x_center_bound_factor * abs(max(pcl(:,1))-min(pcl(:,1)));
            center_x=min(pcl(:,1))+abs(max(pcl(:,1))-min(pcl(:,1)))/2;
            pcl_center_x=pcl(pcl(:,1)>center_x-x_center_bound & pcl(:,1)<center_x+x_center_bound,:);
            safe_iter=safe_iter+1;
            if safe_iter > 10
                error('SQ Fitting: Bending. Could not define a center for the point cloud when Fitting with Bending');
            end
            x_center_bound_factor = x_center_bound_factor * 2;
        end
        pcl_center_x=pcl(pcl(:,1)>center_x-x_center_bound & pcl(:,1)<center_x+x_center_bound,:);
        center_y=min(pcl_center_x(:,2))+abs(max(pcl_center_x(:,2))-min(pcl_center_x(:,2)))/2;
        center_z=min(pcl_center_x(:,3))+abs(max(pcl_center_x(:,3))-min(pcl_center_x(:,3)))/2;
        x(end-2:end) = [center_x center_y center_z];
        % get scale
        x(2) = abs(max(pcl_center_x(:,2))-min(pcl_center_x(:,2)))/2;
        x(1) = abs(max(pcl_center_x(:,3))-min(pcl_center_x(:,3)))/2;
        x(3) = abs(max(pcl(:,1))-min(pcl(:,1)))/2;     
        % get initial shape
        x(4:5) = [.1 1];
        % get intiial Euler angles considering PCA
        scale_options = {[pi -pi/2 0], [0 pi/2 0], [pi -pi/2 0], [pi -pi/2 0]};
        x(6:8) = scale_options{mod(ix,4)+1};
        % get random initial bending
        x(11) = (randi(30)/100)+0.05;
        x(3) = x(3).*(1+x(11));
        % get initial bending plane according to PCA
        bend_options =  [0 pi/2 pi 3*pi/4];
        x(12) = bend_options(mod(ix,4)+1);        
        % set inital lambda
        initial_lambda = x;
        pcl_scale = calculatePCLSegScale(pcl);
        if min(pcl_scale) < MIN_PCL_SCALE            
            warning(['SQ Fitting: Bending. Point cloud has one or more dimensions that are too small: ' num2str(pcl_scale)]);
            return;
        end
        lower_lambda = [x(1:3)*0.9 .1 .1 -pi -pi -pi 0 0 .1 0 min(pcl)];
        upper_lambda = [x(1:3)*1.2 1  1  pi pi pi 0 0 pi 0.3 max(pcl)];
        [~, initial_error ] = RankSQ(pcl, initial_lambda );
        [SQ,~,~,~,~] = lsqnonlin(@(x) SQFunction(x, pcl), initial_lambda, lower_lambda,upper_lambda, opt_options);
        [~, E ] = RankSQ(pcl, SQ );
        if initial_error < E
            SQ = initial_lambda;
        end
        [~, E,E_pcl_SQ, E_SQ_pcl ] = RankSQ(pcl, SQ );
    end
end