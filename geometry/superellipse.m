% By Paulo Abelha
% returns or plots a superellipse
function [ pcl, thetas ] = superellipse( a, b, eps1, D, plot_fig, not_unif )
    if ~exist('D','var')
        D = 0.0005;
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

function thetas = unif_sample_theta(a, b, eps1, D)
    max_iter = 10^6;
    thetas(1) = 0;
    i = 0;
    while (thetas(end) < pi/2)
        if i > max_iter
            error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        theta_next = update_theta(a, b, eps1, thetas(end), D, 1);
        new_theta = thetas(end) + theta_next;
        thetas(end+1) = new_theta;
        i = i +1;
    end
%     thetas = [thetas pi/2-fliplr(thetas)];
    thetas(end+1) = pi/2;
    while (thetas(end) > 0)
        if i > max_iter
            error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
        end
        thetas(end+1) = thetas(end) - update_theta(a, b, eps1, thetas(end), D, 0);    
        i = i +1;
    end 
end

% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u based on the combinations of models in the paper
function [ theta_next ] = update_theta( a, b, eps1, theta_prev, D, increasing )
    theta_eps = 1e-2;
    if theta_prev <= theta_eps
        % equation (8)
        theta_next = power(abs((D/b)+power(theta_prev,eps1)),1/eps1)-theta_prev;
%         ns(1) = ns(1) + 1;
    else
        if abs(theta_prev-pi/2) < theta_eps
            % equation (9)
            theta_next = power((D/a)+power(pi/2-theta_prev,eps1),1/eps1)-(pi/2-theta_prev);      
%             ns(2) = ns(2) + 1;
        else
%             ns(3) = ns(3) + 1;
            % equation (5)
            theta_next = (D / eps1) * cos (theta_prev) * sin (theta_prev) * sqrt (1/ (a^2  * power(cos(theta_prev), 2*eps1) * power(sin(theta_prev), 4.) + b^2 * power(sin(theta_prev), 2*eps1) * power(cos(theta_prev), 4.)));
        end
    end
end

% function thetas = unif_sample_theta(a, b, eps1, D)
%     max_iter = 1e6;
%     theta_increasing = 1;
%     thetas = 0;
%     ix_eta = 1;
%     ns = [0 0 0];
%     while (thetas(end) > -eps(1))
%         if ix_eta > max_iter
%             error(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
%         end
%         % if theta got close enough to pi/2 start decreasing it down to 0        
%         if thetas(end)  > pi/2 - 10*eps
%           thetas(end)  = max(pi/2 - thetas(end) , 0);
%           theta_increasing = -1;
%         end             
%         % update angle
%         [theta_next, ns] = update_theta(a, b, eps1, thetas(end), D, ns);
%         thetas(end+1) = thetas(end) + theta_increasing*theta_next;    
%         ix_eta = ix_eta +1;
%     end   
% end
% 
% % By Paulo Abelha (p.abelha at abdn ac uk )
% % based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% % 
% % Update theta based on the combinations of models in the paper
% function [ R, ns ] = update_theta( a, b, epsilon, theta, D, ns )
%     theta_eps = 1e-1;
%     if theta <= theta_eps
%         % equation (8)
%         R = power(abs((D/b)+power(theta,epsilon)),1/epsilon)-theta;
%         ns(1) = ns(1) + 1;
%     else
%         if (pi/2 - theta_eps) <= theta || theta >= (pi/2 + theta_eps)
%             % equation (9)
%             R = power((D/a)+power(pi/2-theta,epsilon),1/epsilon)-(pi/2-theta);      
%             ns(2) = ns(2) + 1;
%         else
%             ns(3) = ns(3) + 1;
%             % equation (5)
%             R = D / sqrt( (a^2*epsilon^2*sin(theta)^2*cos(theta)^(2*epsilon-2)) +  (b^2*epsilon^2*cos(theta)^2*sin(theta)^(2*epsilon-2)) );
% %             R = (D / epsilon) * cos (theta) * sin (theta) * sqrt (1/ (a^2  * power(cos(theta), 2*epsilon) * power(sin(theta), 4.) + b^2 * power(sin(theta), 2*epsilon) * power(cos(theta), 4.)));
%         end
%     end
% end

