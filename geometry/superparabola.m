% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, us ] = superparabola( a, b, eps1, D, plot_fig, not_unif )
    if ~exist('D','var') || D < 0
        D = ((a*b))/200; %0.0005;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('not_unif','var')
        not_unif = 0;
    end
    N = 10^2;
    us = 0:1/N:1;    
    if ~not_unif
        us = unif_sample_u(b, eps1, D);       
    end  
    X = a*us; 
    X = [fliplr(-X(2:end)) X];
    Y = b*((us.^2).^(1/eps1));
    Y = [fliplr(Y(2:end)) Y];
    pcl = [X' Y'];
    if plot_fig
       scatter(X,Y,1); axis equal; 
    end
end

function us = unif_sample_u(b, eps1, D)
    max_iter = 10^6;
    us(1) = 0;
    i = 1;
    while 1
        if i > max_iter
            error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        next_u = us(end) + update_u(b, eps1, us(end), D);
        if next_u > 1
            break;
        end
        us(end+1) = next_u;    
        i = i +1;
    end   
end

% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u based on the combinations of models in the paper
function [ u_next ] = update_u( b, eps1, u_prev, D )
    u_next = D / ( sqrt( ((4*b^2)/eps1^2)*u_prev^((4/eps1)-2) + 1 ) );
end

