% By Paulo Abelha (p.abelha at abdn ac uk )
% based on [PiluFisher95] Pilu, Maurizio, and Robert B. Fisher. “Equal-distance sampling of superellipse models.” DAI RESEARCH PAPER (1995)
% 
% Recursive implementation of the angle sampling equation
% Iterations will stop in case of too many calls (wrong parametrization may lead to infinite regression).
function [ thetas, theta_increasing, safe_rec ] = UniformSQAngleSampling( safe_rec, thetas, theta_increasing, a, b, epsilon, theta, D_  )
    if safe_rec > 10^5;
        error('Recursion went too deep for sampling angles (> 10^5).');
    end
    if (theta <= -eps(1))
        return;
    else
        % if theta got close enough to pi/2 start decreasing it down to 0        
        if (theta > pi/2 - eps(1))
          theta = max(pi/2 - theta, 0);
          theta_increasing = -1;
        end             
        % update angle
        thetas(end+1) = theta + theta_increasing*UpdateTheta(a, b, epsilon, theta, D_);
        % assign to array of sampled angles
        [ thetas, theta_increasing, safe_rec ] = UniformSQAngleSampling( safe_rec+1, thetas, theta_increasing, a, b, epsilon, thetas(end), D_ );     
    end  
end