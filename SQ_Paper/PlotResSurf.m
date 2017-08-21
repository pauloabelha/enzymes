function PlotResSurf( axes_limits, axes_labels, X, Y, Z, FONT_SIZE )
    [mgx, mgy] = meshgrid(X,Y);
    figure;
    axes = gca;
    axes.XLim = axes_limits(1:2);
    res_surface = surf(mgx,mgy,Z);
    xlhand = get(gca,'xlabel');
    set(xlhand,'string',axes_labels{1},'fontsize',FONT_SIZE);
    ylhand = get(gca,'ylabel');
    set(ylhand,'string',axes_labels{2},'fontsize',FONT_SIZE); 
    axes.YLim = axes_limits(3:4);
    zlhand = get(gca,'zlabel');
    set(zlhand,'string',axes_labels{3},'fontsize',FONT_SIZE); 
    res_surface.EdgeColor = 'none';
    axes.ZLim = axes_limits(5:6);
    set(gcf,'color','w');
end

