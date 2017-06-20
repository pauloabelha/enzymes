% By Paulo Abelha
%
% Uniformly samples a superellipsoid
% This function will approximate "thin" superellipsoids to be 2D)
% A thin SQ is defined in terms of metric units (m)
% A SQ is thin if its smallest scale over largest is smaller than 0.1 
% Inputs:
%   lambda: 1x5 array with the parameters [a1,a2,a3,eps1,eps2]
%   plot_fig: whether to plot
%
% Outputs:
%   pcl: Nx3 array with the uniform point cloud
%   etas: the u parameters for the superparabola
%   omegas: the omega parameters for the superellipse
function [ pcl, normals, etas, omegas ] = superellipsoid( lambda, in_max_n_pts, plot_fig, colour )    
    %% min proportion for considering a SQ thin
    MIN_PROP_THIN_SQ = 0.05;
    %% max number of points for pcl
    MAX_N_PTS = 1e7;
    %% max number of cross sampling of angles (etas x omegas) - for memory issues
    MAX_N_CROSS_ANGLES = MAX_N_PTS/2;
    %% check params
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('colour','var')
        colour = '.k';
    end
    %% check whether to plot
    if ~exist('in_max_n_pts','var')
        in_max_n_pts = Inf;
    end
    %% deal with thin SQs
    [scale_sort, scale_sort_ixs] = sort(lambda(1:3),'ascend');
    prop_thin = scale_sort(1)/scale_sort(3);
    if prop_thin <= MIN_PROP_THIN_SQ
        [pcl, normals, vol_mult] = Get2DSuperellipsoid(lambda, scale_sort,scale_sort_ixs);        
    else
        % deal with SQs with a scale number less than 1
        % this is too deal with arbitrarly small SQs and 
        % still being able to sample
        vol_mult = 1;
        if any(lambda(1:3) < 1)
            vol_mult = 1/min(lambda(1:3));
            lambda(1:3) = lambda(1:3)*vol_mult;
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
        n_cross_angles = size(etas,2) * size(omegas,2);
        if n_cross_angles > MAX_N_CROSS_ANGLES
            error(['Too many (' num2str(n_cross_angles) ') angles were sampled. maximum is ' num2str(MAX_N_CROSS_ANGLES) ' angles were sampled. Aborting due to possible freezing due to lack of RAM. Check SQ scale param']);
        end
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
    end
    %% deal with low cubic vol SQs
    pcl = pcl./vol_mult;
    %% get final points and normals    
    MAX_N_PTS = min(MAX_N_PTS,in_max_n_pts);
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

function [final_pcl, final_normals, vol_mult] = Get2DSuperellipsoid(lambda, scale_sort, scale_sort_ixs)
    % decide on which eps for the 2D sq
    eps = 1;
    if scale_sort_ixs(1) == 3
        eps = lambda(5);
    end
    % deal with SQs with a scale number less than 1
    % this is too deal with arbitrarly small SQs and 
    % still being able to sample
    vol_mult = 1;
    if any(scale_sort(2:3) < 1)
        vol_mult = 1/min(scale_sort(2:3));
        scale_sort(2:3) = scale_sort(2:3)*vol_mult;
        lambda(1:3) = lambda(1:3)*vol_mult;
    end 
    a=lambda(1:3);
    a(a>min(a))
    pcl = superellipse( a(1), a(2), eps);        
    ixs = randsample(1:size(pcl,1),min(1000,size(pcl,1)));
    pcl = pcl(ixs,:);
    n_iter = floor(max(scale_sort(2:3))/0.001);
    n_pts = size(pcl,1);
    final_pcl = zeros(n_pts+n_pts*n_iter,2);
    final_pcl(1:n_pts,:) = pcl;
    for i=2:n_iter+1
        multiplier = 1-(i/n_iter);
        pcl_to_add = pcl*multiplier;
        beg = ((i-1)*n_pts)+1;
        final_pcl(beg:(beg-1)+size(pcl_to_add,1),:) = pcl_to_add;
    end
    final_pcl = [final_pcl zeros(size(final_pcl,1),1)];
    final_normals = repmat([0 0 -1],size(final_pcl,1),1); 
    final_pcl = [final_pcl; final_pcl+scale_sort(1)];
    final_normals = [final_normals; repmat([0 0 1],size(final_pcl,1),1)];
    % translate and rotate points
    % get a previous rotation to apply because sampling is done in the XY plane
    rot_prev = eye(3);
    if scale_sort_ixs(1) == 1
        rot_prev1 = GetRotMtx(pi/2,2);
        rot_prev = GetRotMtx(pi/2,1)*rot_prev1;
    end
    if scale_sort_ixs(1) == 2
        rot_prev = GetRotMtx(pi/2,1);
    end
    rot_SQ = GetEulRotMtx(lambda(6:8));
    final_pcl = RotateAndTranslatePoints( final_pcl, rot_SQ*rot_prev, lambda(end-2:end)' );    
    % translate and rotate points
    final_normals = RotateAndTranslatePoints( final_normals, rot_SQ, zeros(3,1) );
end

