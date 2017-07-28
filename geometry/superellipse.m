% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, thetas ] = superellipse( a, b, eps1, D, plot_fig, not_unif )
    if ~exist('D','var') || D < 0
        D = ((a*b))/100; %0.0005;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    if ~exist('not_unif','var')
        not_unif = 0;
    end
    N = 10^5;
    if not_unif
        thetas = -pi:1/N:pi;
        X = a*signedpow(cos(thetas),eps1);
        Y = b*signedpow(sin(thetas),eps1);
    else
        thetas = unif_sample_theta(a, b, eps1, D);
        thetas(thetas>pi/2) = pi/2;
        thetas(thetas<0) = 0;
        X = a*signedpow(cos(thetas),eps1);
        Y = b*signedpow(sin(thetas),eps1);
        X = [X -X X -X];        
        Y = [Y Y -Y -Y];
    end    
    pcl = [X' Y'];
    if plot_fig
       scatter(X,Y,1); axis equal; 
    end
end



