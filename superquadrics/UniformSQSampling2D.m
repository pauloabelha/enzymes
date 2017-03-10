% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
function [ final_pcl, thetas ] = UniformSQSampling2D( SQ, D_theta, plot )
    if ~exist('plot','var')
        plot=0;
    end
    % get SQ params
    a1 = SQ(1);
    a2 = SQ(2);
    e1 = SQ(3);    
    % sample thetas
    %thetas = UniformSQAngleSampling( [], 1, a1, a2, e1, 0, D_, 0 );
    max_iter = 10^4;
    thetas = zeros(1,10^4);
    theta_increasing = 1;
    ix_theta = 1;
    while (thetas(ix_theta) > -eps(1))
        if ix_theta > max_iter
            disp(['Angle theta sampling reach the maximum number of iterations ' num2str(max_iter)]);
            error(num2str(SQ));
        end
        % if theta got close enough to pi/2 start decreasing it down to 0        
        if (thetas(ix_theta)  > pi/2 - eps(1))
          thetas(ix_theta)  = max(pi/2 - thetas(ix_theta) , 0);
          theta_increasing = -1;
        end             
        % update angle
        thetas(ix_theta+1) = thetas(ix_theta) + theta_increasing*UpdateTheta(a1, a2, 0, 0, e1, thetas(ix_theta), D_theta);   
        ix_theta = ix_theta +1;
    end
    thetas = thetas(1:ix_theta-1);  
    % get size of sampled angles as variable for effiency
    size_thetas = size(thetas,2);
    % initialize final pcl
    final_pcl = zeros(size_thetas*4,2);
    ix=0;
    for i=-1:2:1
        for j=-1:2:1
            x = a1.*i*signedpow(cos(j*thetas),e1);
            y = a2.*i*signedpow(sin(j*thetas),e1); 
            final_pcl((ix*size_thetas)+1:((ix+1)*size_thetas),:) = [x' y'];
            ix=ix+1;
        end
    end
    % plot if required
    if plot
        figure; scatter(final_pcl(:,1),final_pcl(:,2),10,'.k'); axis equal
    end   
end

