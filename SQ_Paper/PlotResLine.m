function PlotResLine( axes_limits, axes_labels, X, Y, FONT_SIZE )
    figure;
    axes = gca;
    plot(X,Y);
    axes.XLim = axes_limits(1:2);
    xlhand = get(gca,'xlabel');
    set(xlhand,'string',axes_labels{1},'fontsize',FONT_SIZE);
    axes.YLim = axes_limits(3:4);
    ylhand = get(gca,'ylabel');
    set(ylhand,'string',axes_labels{2},'fontsize',FONT_SIZE);
end

