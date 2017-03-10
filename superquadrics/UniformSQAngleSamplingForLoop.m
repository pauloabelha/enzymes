% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. “Equal-distance sampling of superellipse models.” DAI RESEARCH PAPER (1995)
% 
% Recursive implementation of the angle sampling equation
% Iterations will stop in case of too many calls (wrong parametrization may lead to infinite regression).
function [ thetas ] = UniformSQAngleSamplingForLoop( thetas, theta_increasing, a, b, epsilon, theta, D_  )
    while (theta > -eps(1))
        % if theta got close enough to pi/2 start decreasing it down to 0        
        if (theta > pi/2 - eps(1))
          theta = max(pi/2 - theta, 0);
          theta_increasing = -1;
        end             
        % update angle
        theta = UpdateTheta(a, b, epsilon, thetas(end), D_);
        thetas(end+1) = thetas(end) + theta_increasing*theta;
    end
end