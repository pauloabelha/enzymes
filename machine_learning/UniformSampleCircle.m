function [ sampled_points ] = UniformSampleCircle( p, r, n_samples, uniform )

    if ~exist('uniform','var')
        uniform = 1;
    end
    
    p = [p 0];
    
    q = [r; 0; 0];
    
    a = 0;
    b = 2*pi;
    x = (b-a).*rand(n_samples,1) + a;
    
    rs = zeros(n_samples,3);
    Rzs = GetRotMtx(x,'z');
    for i=1:size(Rzs,3)
        rs(i,:) = Rzs(:,:,i)*q;
        rs(i,:) = rs(i,:)/norm(rs(i,:));
    end
    
    ss = rs + repmat(p,n_samples,1);
    
    y = rand(n_samples,1);
    if uniform
        % draw form the cdf of Y which is cdf(y) = y^2
        y = sqrt(y);
    end
    
    sampled_points = ss .* repmat(y,1,3);
    scatter(sampled_points(:,1),sampled_points(:,2),'.k');
    axis equal;
end

