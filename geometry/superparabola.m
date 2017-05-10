% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, us ] = superparabola( a, b, eps1, plot_fig, not_unif )
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('not_unif','var')
        not_unif = 0;
    end
    N = 10^2;
    us = 0:1/N:1;    
    if ~not_unif
        us = unif_sample_u(b, eps1, N);       
    end  
    X = a*us; 
    X = [X -X];
    Y = b*((us.^2).^(1/eps1));
    Y = [Y Y];
    pcl = [X' Y'];
    if plot_fig
       scatter(X,Y,1); axis equal; 
    end
end

function us = unif_sample_u(b, eps1, N)
    max_iter = 10^6;
    D = 0.001;
    us = zeros(1,N);
    us(1) = 0;
    i = 1;
    while (us(i) < 1)
        if i > max_iter
            error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        us(i+1) = us(i) + update_u(b, eps1, us(i), D);    
        i = i +1;
    end   
end

% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u based on the combinations of models in the paper
function [ u_next ] = update_u( b, eps1, u_prev, D )
    u_next = ((D*eps1)/(2*b)) * 1/sqrt( (4*b^2*(u_prev^((4/eps1) - 2)) ) + 1);
%     u_next = ((D*eps1)/(2*b)) * 1/sqrt((u_prev^((2/eps1) - 1)) + 1);
end

