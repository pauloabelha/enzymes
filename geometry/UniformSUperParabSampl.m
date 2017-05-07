function [ output_args ] = UniformSUperParabSampl( lambda )
    D_theta = 0.001;
    % get omegas
    thetas = zeros(1,10^4);
    theta_increasing = 1;
    ix_eta = 1;
    while (thetas(ix_eta) > -eps(1))
        if ix_eta > max_iter
            disp(['Angle eta sampling reach the maximum number of iterations ' num2str(max_iter)]);
            error(num2str(SQ));
        end
        % if theta got close enough to pi/2 start decreasing it down to 0        
        if (thetas(ix_eta)  > pi/2 - eps(1))
          thetas(ix_eta)  = max(pi/2 - thetas(ix_eta) , 0);
          theta_increasing = -1;
        end             
        % update angle
        thetas(ix_eta+1) = thetas(ix_eta) + theta_increasing*UpdateTheta(a1, a2, 1, 0, 1, thetas(ix_eta), D_theta);    
        ix_eta = ix_eta +1;
    end
    etas = thetas(1:ix_eta-1); 

end

