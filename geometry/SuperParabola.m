function [ Y ] = SuperParabola( X, a, b, p, plot_fig )
    
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    
    Y = b.*((X/a).^2 ).^p;
    
    if plot_fig
        plot(X,Y); axis equal;
    end

end

