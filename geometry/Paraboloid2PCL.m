function [pcl, omegas] = Paraboloid2PCL(lambda, n_points, plot_fig)
    N_ANGLES = 1e3; 
    if ~exist('n_points','var')
        n_points = 1e4;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    
    omegas = -pi:(2*pi/N_ANGLES):pi;    
    u = 0:(1/N_ANGLES):1;
    u=u';
    % sample form the inverse of the superparaboloid to get to uniform
    k = sqrt(lambda(4));
    u=u.^(k*(1/lambda(4)));
    X = lambda(1)*(u.^lambda(4))*cos(omegas);
    Y = lambda(2)*(u.^lambda(4))*sin(omegas);
    Z = 2*lambda(3)*(u - ones(1,size(u,1)));
    
    pcl = [X(:) Y(:) Z(:)];
    pcl = pcl(randsample(1:size(pcl,1),n_points),:);
    rot_mtx = GetEulRotMtx(lambda(6:8));
    % adjust for 0 being at the minimum Z
    pcl(:,3) = pcl(:,3) + lambda(3);
    T = [[rot_mtx lambda(end-2:end)']; lambda(end-2:end) 1];
    pcl = [T*[pcl'; ones(1,size(pcl,1))]]';
    pcl = pcl(:,1:3);
    if plot_fig
        scatter3(pcl(:,1),pcl(:,2),pcl(:,3),'.b'); axis equal
    end
end
    


   