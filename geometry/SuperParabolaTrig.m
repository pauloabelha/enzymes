function [ Y ] = SuperParabolaTrig( p, gamma, plot_fig )
    
    tan_eps = .1;

    if ~exist('plot_fig','var')
        plot_fig = 0;
    end

    nu = (-pi/2+tan_eps):.1:(pi/2-tan_eps);
    
%     X = cos(nu).^.5;
%     Y = sin(nu);
    
    X = ((2*p).^(1-(2/gamma)))*(tan(nu).^2);
    Y = tan(nu).^gamma;
    
    if plot_fig
        plot(X,Y); axis equal;
    end


end

