% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. �Equal-distance sampling of superellipse models.� DAI RESEARCH PAPER (1995)
% 
% Update theta based on the combinations of models in the paper
function [ R ] = UpdateTheta( a, b, a4, tor, epsilon, theta, D_ )
    if theta <= 1e-2
        % equation (8)
        R = power(abs((D_/b)+power(theta,epsilon)),1/epsilon)-theta;
    else
        if (pi/2 - 1e-2) <= theta || theta >= (pi/2 + 1e-2)
            % equation (9)
            R = power((D_/a)+power(pi/2-theta,epsilon),1/epsilon)-(pi/2-theta);            
        else
            % equation (5)
            %R = D_ * 1/((a^2+b^2)*abs(epsilon)*sqrt(sin(theta)^(2*epsilon-2))*abs(cos(theta)));
            R = (D_ / (epsilon*(a4^tor))) * cos (theta) * sin (theta) * sqrt (1/ (a^2  * power(cos(theta), 2*epsilon) * power(sin(theta), 4.) + b^2 * power(sin(theta), 2*epsilon) * power(cos(theta), 4.)));
        end
    end
end