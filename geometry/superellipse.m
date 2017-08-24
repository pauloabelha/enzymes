% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, thetas ] = superellipse( a, b, eps1, D, plot_fig )
    if ~exist('D','var') || D < 0     
        D = ((max(a/b,b/a)))/100; %0.0005;
    end
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    rot = eye(2);
    if a > b
        aux=a;
        a=b;
        b=aux;
        rot = Get2DRotMtx(pi/2);
    end
    [thetas, thetas1, thetas2] = unif_sample_theta(a, b, eps1, D);
    thetas(thetas>pi/2) = pi/2;
    thetas(thetas<0) = 0;
    thetas=thetas';
    X = a*signedpow(cos(thetas),eps1);
    Y = b*signedpow(sin(thetas),eps1);
    pcl = [[X; -X; X; -X] [Y; Y; -Y; -Y]];
    pcl=pcl*rot;
    if plot_fig
       scatter(pcl(:,1),pcl(:,2),1); axis equal; 
    end
end



