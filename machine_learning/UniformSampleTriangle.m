function [ sampled_points ] = UniformSampleTriangle( p, q, r, n_samples, plot_fig )

%     if ~exist('uniform','var')
        uniform = 1;
%     end
    
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    
    c = r - q;
    
    x = rand(n_samples,1);
    c_rescaled = bsxfun(@times,c,repmat(x,1,size(c,2)));
    s = c_rescaled + repmat(q,size(x,1),1);
    d = s - repmat(p,size(x,1),1);
    
    y = rand(n_samples,1);
    if uniform
        % draw form the cdf of Y which is cdf(y) = y^2
        y = sqrt(y);
    end
    d_rescaled = bsxfun(@times,d,repmat(y,1,size(y,2)));
    sampled_points = d_rescaled + repmat(p,size(y,1),1);
    if plot_fig
        scatter3(sampled_points(:,1),sampled_points(:,2),sampled_points(:,3),'.k'); axis equal
    end
end

