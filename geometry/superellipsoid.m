% By Paulo Abelha
%
% Uniformly samples a superellipsoid
%
% Inputs:
%   lambda: 1x5 array with the parameters [a1,a2,a3,eps1,eps2]
%   plot_fig: whether to plot
%
% Outputs:
%   pcl: Nx3 array with the uniform point cloud
%   etas: the u parameters for the superparabola
%   omegas: the omega parameters for the superellipse
function [ pcl, normals, etas, omegas ] = superellipsoid( lambda, plot_fig, colour )
    %% max number of points for pcl
    MAX_N_PTS = 1e7;
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
    k_bend = lambda(11);
    %% uniformly sample a superparabola and a superellipse
    % arclength constant
    [ ~, etas ] = superellipse( 1, a3, eps1);
    [ ~, omegas ] = superellipse( a1, a2, eps2); 
    %% downsample the etas or omegas
%     MAX_N_SAMPLES = 1e5;
%     n_samples = min(max(numel(etas),numel(omegas)),MAX_N_SAMPLES);
%     etas = etas(randsample(numel(etas),min(numel(etas),n_samples)));
%     omegas = omegas(randsample(numel(omegas),min(numel(omegas),n_samples)));
    %% get the points with the superparaboloid parametric equation
    pcl = [];
    normals = [];
    for i=-1:2:1
        for j=-1:2:1
            for k=-1:2:1
                % get permutated sampled angles
                cos_j_omegas = cos(j*omegas);
                sin_j_omegas = sin(j*omegas);
                cos_k_etas = cos(k*etas);
                sin_k_etas = sin(k*etas);
                %% get points
                X = a1*i*signedpow(cos_j_omegas,eps2)'*signedpow(cos_k_etas,eps1); X=X(:);
                Y = a2*i*signedpow(sin_j_omegas,eps2)'*signedpow(cos_k_etas,eps1); Y=Y(:);             
                Z = a3*i*ones(size(omegas,2),1)*signedpow(sin_k_etas,eps1); Z=Z(:);
                % apply tapering
                if Kx || Ky
                    f_x_ofz = ((Kx.*Z)/a3) + 1; 
                    X = X.*f_x_ofz;
                    f_y_ofz = ((Ky.*Z)/a3) + 1;
                    Y = Y.*f_y_ofz; 
                end
                % apply bending
                if k_bend
                    X = X + (k_bend + sqrt(k_bend^2 + Z.^2));
                end
                pcl = [pcl; [X Y Z]];
                % get normals
                nx = (cos_j_omegas.^2)'*cos_k_etas.^2; nx = nx(:);
                ny = (sin_j_omegas.^2)'*cos_k_etas.^2; ny = ny(:);
                nz = ones(size(omegas,2),1)*sin_k_etas.^2; nz = nz(:);
                normals = [normals; [1./X.*nx 1./Y.*ny 1./Z.*nz]];
            end
        end
    end   
    %% get final points and normals    
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

