function [ SQ, SQ_scheibe_best, SQ_pcl, SQ_cheibe_pcl ] = FitContainer( pcl, n_seeds )   
    SetUpFigure();
    PlotPCLS({pcl});
    pcl = DownsamplePCL( pcl, 2000 );
%     [ SQ, ~, ~, SQ_pcl, SQ_pca ] = PCL2SQ( pcl, n_seeds, 0, 0, 1, 1, 1 );
    PCA = pca(pcl);
    pcl = pcl*PCA;
    opt_options = optimset('Display','off','TolX',1e-10,'TolFun',1e-10,'MaxIter',1000,'MaxFunEvals',200); 
    [SQ,~,~] = FitSQtoPCL_normal(pcl,1,opt_options);
    [SQ,~,~] = FitSQtoPCL_Toroid(pcl,1,opt_options,SQ);
    % plot it    
    SQ_pcl = UniformSQSampling3D( SQ, 0, 22500 );
    SQ_pcl = SQ_pcl/PCA;
    plot3(SQ_pcl(:,1),SQ_pcl(:,2),SQ_pcl(:,3),'.g'); axis equal;
%     pcl = pcl*SQ_pca{1};
%     SQ = SQ{1};
    SQ(4) = 1/(SQ(4)+1);
    central_point = SQ(end-2:end);
    z_angle_vec = eul2rotm_(SQ(7:9),'ZYZ')*[0;0;1];
    %scale vector to the Z size of the SQ (for both directions)
    z_euler_vec_up = z_angle_vec.*SQ(3);
    %translate vectors to center of SQ to get initial point in the container's bottom (or top)
    central_bottom_point = central_point + z_euler_vec_up';
    central_top_point = central_point - z_euler_vec_up';    
    % create scheiben to put at bottom and top of the toroid (closing the container)    
    SQ_disc = [SQ(1:3) SQ(5:end)];
    SQ_disc(1:2) = SQ(1:2)*(1/SQ(4));
    SQ_disc(3) = 0.005;
    % get bottom scheibe
    SQ_disc_bottom = SQ_disc;
    SQ_disc_bottom(end-2:end) = central_bottom_point;
    % calculate function for bottom disc   
%     F_scheibe_bottom = SQFunctionNormalised( SQ_disc_bottom, pcl );
    SQ_cheibe_pcl = UniformSQSampling3D(SQ_disc_bottom,0,2000);
    E=pdist2(SQ_cheibe_pcl,DownsamplePCL( pcl, 2000 ));
    F_scheibe_bottom = sum(min(E,[],2).^2)/2000;    
    % get top scheibe
    SQ_disc_top = SQ_disc;
    SQ_disc_top(end-2:end) = central_top_point;
    % calculate function for top scheibe  
%     F_scheibe_top = SQFunctionNormalised( SQ_disc_top, pcl );
    SQ_cheibe_pcl = UniformSQSampling3D(SQ_disc_top,0,2000);
    E=pdist2(SQ_cheibe_pcl,DownsamplePCL( pcl, 2000 ));
    F_scheibe_top = sum(min(E,[],2).^2)/2000;    
    % choose best scheibe
    if F_scheibe_bottom <= F_scheibe_top
        SQ_scheibe_best = SQ_disc_bottom;
    else
        SQ_scheibe_best = SQ_disc_top;
    end
    % plot it    
    SQ_cheibe_pcl = UniformSQSampling3D( SQ_scheibe_best, 0, 22500 );
    SQ_cheibe_pcl = SQ_cheibe_pcl/PCA;
    plot3(SQ_cheibe_pcl(:,1),SQ_cheibe_pcl(:,2),SQ_cheibe_pcl(:,3),'.g'); axis equal;
end

