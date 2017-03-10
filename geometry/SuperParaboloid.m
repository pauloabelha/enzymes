function [ parab ] = SuperParaboloid( params, plot_fig )
    
    a = params(1);
    b = params(2);
    c = params(3);
    p = params(4);    
    
    pos = params(end-2:end)';

    p = round(p);

    if ~exist('plot_fig','var')
        plot_fig = 0;
    end

    X = -.1:.005:.1;
    Y = X;
    [X,Y] = meshgrid(X,Y);    
    
    Z = c.* ((X./a).^(2*p) + (Y./b).^(2*p));
    Z_out = Z(:);
    cap_value = c*(1/(a^(2*p)*b^(2*p)));
    if c < 0
        paraboloid_ixs = Z_out>=cap_value;
    else
        paraboloid_ixs = Z_out<=cap_value;
    end
    Z_out = Z_out(paraboloid_ixs);
    X_out = X(paraboloid_ixs);
    Y_out = Y(paraboloid_ixs);
    parab = [X_out Y_out Z_out];
    T = [[eye(3) pos]; 0 0 0 1];
    parab= [T*[parab'; ones(1,size(parab,1))]]';
    parab = parab(:,1:3);
    
    if plot_fig
        if c < 0
            Z(Z<cap_value) = NaN;
        else
            Z(Z>cap_value) = NaN;
        end
        figure('name',[num2str(a) '-' num2str(b) '-' num2str(c) '-' num2str(p)]);
        size_X = size(X);
        pcl = [X(:) Y(:) Z(:)];
        pcl= [T*[pcl'; ones(1,size(pcl,1))]]';
        pcl = pcl(:,1:3);
        X = reshape(pcl(:,1),size_X);
        Y = reshape(pcl(:,2),size_X);
        Z = reshape(pcl(:,3),size_X);
        f = surf(X,Y,Z);
        axis equal;
        set(f,'edgecolor','none')
    end    

end

