% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update u based on the combinations of models in the paper
function [ theta_next ] = update_theta( a1, a2, eps1, theta_prev, D )
    theta_eps = 1e-2;
    if theta_prev <= theta_eps
        % equation (8)
        theta_next = power(abs((D/a2)+power(theta_prev,eps1)),1/eps1)-theta_prev;
%         ns(1) = ns(1) + 1;
    else
        if pi/2 - theta_prev < theta_eps
            % equation (9)
            theta_next = power((D/a1)+power(pi/2-theta_prev,eps1),1/eps1)-(pi/2-theta_prev);      
%             ns(2) = ns(2) + 1;
        else
%             ns(3) = ns(3) + 1;
            % equation (5)
            theta_next = (D / eps1) * cos (theta_prev) * sin (theta_prev) * sqrt (1/ (a1^2  * power(cos(theta_prev), 2*eps1) * power(sin(theta_prev), 4.) + a2^2 * power(sin(theta_prev), 2*eps1) * power(cos(theta_prev), 4.)));
        end
    end
end