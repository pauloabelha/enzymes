function [ ix_seeds, seeds, seeds_pcls ] = PlantSeedsPCL( P, n_seeds, seed_radius, lower_bound_prop_scale, plot_fig )
    % default is not plotting
    MIN_SEED_PCL_SIZE = 100;
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    %% get seeds over target pcl
    ix_seeds = randi(size(P.v,1),n_seeds,1);
    seeds = P.v(ix_seeds,:);    
    %% get seed pcls
    seeds_pcls = cell(1,n_seeds);
    for i=1:n_seeds
        center = seeds(i,:);
        F = ((P.v(:,1)-center(1))/seed_radius).^2 + ((P.v(:,2)-center(2))/seed_radius).^2  + ((P.v(:,3)-center(3))/seed_radius).^2;
        ixs_seed_pcl = F<=1;
        seeds_pcls{i} = P.v(ixs_seed_pcl,:);
    end
    if plot_fig
        figure;
        scatter3(P.v(:,1),P.v(:,2),P.v(:,3),'.k');
        title(['Pcl with #' num2str(n_seeds) ' seeds']);
        axis equal;
        hold on;
        PlotPCLS(seeds_pcls(1:3));
        hold off;        
    end
end

