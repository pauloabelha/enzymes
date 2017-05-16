% By Paulo Abelha
%
% Uniformly samples a superparaboloid
%
% Inputs:
%   lambda: 1x5 array with the parameters [a1,a2,a3,eps1,eps2]
%   plot_fig: whether to plot
%
% Outputs:
%   pcl: Nx3 array with the uniform point cloud
%   us: the u parameters for the superparabola
%   omegas: the omega parameters for the superellipse
function [ pcl, normals, us, omegas ] = superparaboloid( lambda, plot_fig, colour )
    %% check whether to plot
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    %% check plot colour (default is black)
    if ~exist('colour','var')
        colour = '.k';
    end
    %% get parameters
    a1 = lambda(1);
    a2 = lambda(2);
    a3 = lambda(3);
    eps1 = lambda(4);
    eps2 = lambda(5);
    Kx = lambda(9);
    Ky = lambda(10);
    %% uniformly sample a superparabola and a superellipse
    % arclength constant
    D = 0.005;
    [ ~, us ] = superparabola( 1, a3, eps1, D);
    [ ~, omegas ] = superellipse( a1, a2, eps2, D);  
    %% downsample the us or omegas
    MAX_N_SAMPLES = 1e5;
    n_samples = min(max(numel(us),numel(omegas)),MAX_N_SAMPLES);
    us = us(randsample(numel(us),min(numel(us),n_samples)));
    omegas = omegas(randsample(numel(omegas),min(numel(omegas),n_samples)));
    %% get the points with the superparaboloid parametric equation
    X = a1*us'*signedpow(cos(omegas),eps2);
    X = X(:);
    Y = a2*us'*signedpow(sin(omegas),eps2);
    Y = Y(:);
    Z = 2*a3*((us.^2).^(1/eps1) - 1/2)'*ones(1,size(omegas,2));
    Z = Z(:);
    a = (us'*cos(omegas).^2); a = a(:);
    b = (us'*sin(omegas).^2); b = b(:);
    c = (eps1/2)*((us.^((2/eps1)))'*ones(1,size(omegas,2))); c = c(:);
    normals_x = (1./X).*a;
    normals_y = (1./Y).*b;
    normals_z = -(1./Z).*c;
    normals_x = [normals_x(:); normals_x(:); -normals_x(:); -normals_x(:);];
    normals_y = [normals_y(:); -normals_y(:); normals_y(:); -normals_y(:);];
    normals_z = [normals_z(:); normals_z(:); normals_z(:); normals_z(:);];
    normals = normr([normals_x normals_y normals_z]);
    X = [X(:); -X(:); X(:); -X(:);];
    Y = [Y(:); Y(:); -Y(:); -Y(:)];
    Z = [Z(:); Z(:); Z(:); Z(:)];
    % apply tapering
    if Kx || Ky
        f_x_ofz = ((Kx.*Z)/a3) + 1; 
        X = X.*f_x_ofz;
        f_y_ofz = ((Ky.*Z)/a3) + 1;
        Y = Y.*f_y_ofz; 
    end    
    %% get the pcl
    pcl = [X(:) Y(:) Z(:)];
    clear X; clear Y; clear Z;    
    MAX_N_PTS = 1e6;
    ixs = randsample(1:size(pcl,1),min(size(pcl,1),MAX_N_PTS));
    pcl = pcl(ixs,:);  
    normals = normals(ixs,:);
    %% get transformations
    rot_mtx = GetEulRotMtx(lambda(6:8));    
    T = [[rot_mtx lambda(end-2:end)']; lambda(end-2:end) 1];
    %% transform points and normals
    pcl = [T*[pcl'; ones(1,size(pcl,1))]]';
    pcl = pcl(:,1:3);
    normals = normals*rot_mtx;
    %% plot
    if plot_fig        
        scatter3(pcl(:,1),pcl(:,2),pcl(:,3),10,colour); axis equal;   
    end
end

