% By Paulo Abelha
%
% Uniformly samples (fast) a superparaboloid
%
% Inputs:
%   lambda: 1x5 array with the parameters [a1,a2,a3,eps1,eps2]
%   plot_fig: whether to plot
%
% Outputs:
%   pcl: Nx3 array with the uniform point cloud
%   us: the u parameters for the superparabola
%   omegas: the omega parameters for the superellipse
function [ pcl, normals, us, omegas ] = fast_superparaboloid( lambda, D)
    %% max number of points for pcl
    MAX_N_PTS = 1e7;
    %% max number of cross sampling of angles (etas x omegas) - for memory issues
    MAX_N_CROSS_ANGLES = MAX_N_PTS/2;
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
    [ ~, us ] = superparabola( 1, a3, eps1/2, D);
    [ ~, omegas ] = superellipse( a1, a2, eps2, D);  
    omegas=omegas';
    n_cross_angles = size(us,1) * size(omegas,2);
    if n_cross_angles > MAX_N_CROSS_ANGLES
        error(['Too many (' num2str(n_cross_angles) ') angles were sampled. maximum is ' num2str(MAX_N_CROSS_ANGLES) ' angles were sampled. Aborting due to possible freezing due to lack of RAM. Check SQ scale param']);
    end
    %% downsample the us or omegas
    MAX_N_SAMPLES = 1e5;
    n_samples = min(max(numel(us),numel(omegas)),MAX_N_SAMPLES);
    us = us(randsample(numel(us),min(numel(us),n_samples)));
    omegas = omegas(randsample(numel(omegas),min(numel(omegas),n_samples)));
    %% get the points with the superparaboloid parametric equation
    X = a1*us*signedpow(cos(omegas),eps2);
    X = X(:);
    Y = a2*us*signedpow(sin(omegas),eps2);
    Y = Y(:);
    Z = 2*a3*((us.^2).^(1/eps1) - 1/2)*ones(1,size(omegas,2));
    Z = Z(:);
    a = (us*cos(omegas).^2); a = a(:);
    b = (us*sin(omegas).^2); b = b(:);
    c = (eps1/2)*((us.^((2/eps1)))*ones(1,size(omegas,2))); c = c(:);
    X = [X; -X; X; -X];
    Y = [Y; Y; -Y; -Y];
    Z = [Z; Z; Z; Z];
    pcl = [X Y Z];
    normals_x = (repmat(a,4,1)./X);
    normals_y = (repmat(b,4,1)./Y);
    normals_z = -(repmat(c,4,1)./Z);
    normals = normr([normals_x normals_y normals_z]);
    %% apply tapering
    if Kx || Ky
        % apply to points
        f_x_ofz = ((Kx.*Z)/a3) + 1; 
        X = X.*f_x_ofz;
        f_y_ofz = ((Ky.*Z)/a3) + 1;
        Y = Y.*f_y_ofz; 
        % apply to normals
        
    end    
    %% apply bending
    if k_bend
        % calculate first for eficiency
        calc1 = sqrt(k_bend^2 + Z.^2);
        % apply to points
        X = X + (k_bend + calc1);
        % apply to normals
        bend_j = -(Z./calc1);
        normals(:,3) = normals(:,3) + bend_j.*normals(:,1);
    end
end

