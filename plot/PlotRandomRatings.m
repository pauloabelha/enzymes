function [ output_args ] = PlotRandomRatings( mu, sigma, xticks_, xlims, line_tichkness, axis_font_size, vert_bars_values, vert_bars_colours, background_color )
    figure;
    % set X ticks
    xticks(xticks_)
    whitebg(1, background_color);    

    x = xlims(1):1e-3:xlims(2);
    y1 = pdf('normal', x, mu, sigma);
    y1 = y1/max(y1);
    plot(x, y1);
    hold on;   
    
    % set axis label font size
    set(gca, 'FontSize', axis_font_size)
    for i=1:size(vert_bars_values,2)
        plot([vert_bars_values(i) vert_bars_values(i)],[0 1]);
    end
    
    % set line thickness
    Fig1Ax1 = get(1, 'Children');
    Fig1Ax1Line1 = get(Fig1Ax1, 'Children');
    for i=1:numel(Fig1Ax1Line1)
        j = (numel(Fig1Ax1Line1) - i) + 1;
        set(Fig1Ax1Line1(i), 'LineWidth', line_tichkness(j));
        set(Fig1Ax1Line1(i), 'Color', vert_bars_colours{j});
    end
    
    ax = gca;
    
    hold off;
end

