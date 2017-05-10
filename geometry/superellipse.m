% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, thetas ] = superellipse( a, b, eps1, plot_fig, not_unif )
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
        thetas = unif_sample_theta(a, b, eps1, N);
        X = zeros(1,size(thetas,2)*4);
        Y = X;
        ix = 1;
        i=1;
        for i=-1:2:1
            for j=-1:2:1
                X(ix:ix+size(thetas,2)-1) = i*a*signedpow(cos(j*thetas),eps1);
                Y(ix:ix+size(thetas,2)-1) = i*b*signedpow(sin(j*thetas),eps1);
                ix=ix+size(thetas,2);
            end
        end
    end
    
    pcl = [X' Y'];
    if plot_fig
       scatter(X,Y,1); axis equal; 
    end
end

function thetas = unif_sample_theta(a, b, eps1, N)
    max_iter = 10^6;
    D = 0.002;
    thetas = zeros(1,N);
    theta_increasing = 1;
    ix_eta = 1;
    while (thetas(ix_eta) > -eps(1))
        if ix_eta > max_iter
            error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        % if theta got close enough to pi/2 start decreasing it down to 0        
        if (thetas(ix_eta)  > pi/2 - eps(1))
          thetas(ix_eta)  = max(pi/2 - thetas(ix_eta) , 0);
          theta_increasing = -1;
        end             
        % update angle
        thetas(ix_eta+1) = thetas(ix_eta) + theta_increasing*update_theta(a, b, eps1, thetas(ix_eta), D);    
        ix_eta = ix_eta +1;
    end   
end

% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update theta based on the combinations of models in the paper
function [ R ] = update_theta( a, b, epsilon, theta, D )
    theta_eps = 1e-1;
    if theta <= theta_eps
        % equation (8)
        R = power(abs((D/b)+power(theta,epsilon)),1/epsilon)-theta;
    else
        if (pi/2 - theta_eps) <= theta || theta >= (pi/2 + theta_eps)
            % equation (9)
            R = power((D/a)+power(pi/2-theta,epsilon),1/epsilon)-(pi/2-theta);            
        else
            % equation (5)
            %R = D_ * 1/((a^2+b^2)*abs(epsilon)*sqrt(sin(theta)^(2*epsilon-2))*abs(cos(theta)));
            R = (D / epsilon) * cos (theta) * sin (theta) * sqrt (1/ (a^2  * power(cos(theta), 2*epsilon) * power(sin(theta), 4.) + b^2 * power(sin(theta), 2*epsilon) * power(cos(theta), 4.)));
        end
    end
end

