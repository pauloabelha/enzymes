function [ F ] = SuperParaboloidFunction2( params, pcl )
    a = params(1);
    b = params(2);
    c = params(3);
    q = params(4); 
    r = q;

    n_angles = size(pcl,1);

    omega = -pi:(1/n_angles):pi;
    omega = omega(randi(size(omega,2),1,n_angles));
    omega = sort(omega);
    
    u = 0:(1/n_angles):c;
    u = u(randi(size(u,2),1,n_angles));
    u = sort(u)';
    X = a*(u/c).^q*cos(omega);
    Y = b*(u/c).^r*sin(omega);
    Z = u*ones(1,size(u,1)).^q;
    
    paraboloid_pcl = [X(:) Y(:) Z(:)];    
    paraboloid_pcl = paraboloid_pcl(randi(size(paraboloid_pcl,1),size(paraboloid_pcl,1),1),:);
    ixs = randsample(1:size(pcl,1),size(pcl,1));
    paraboloid_pcl = paraboloid_pcl(ixs,:);
    [ ~, ~, ~, ~, ~, F  ] = FitErrorBtwPointClouds(paraboloid_pcl,pcl);
    %disp([params mean(F)]);
end
