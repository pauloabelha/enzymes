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
    seeds_pcls = {};
    for i=1:size(seeds,1)
        dist_seed = pdist2(seeds(i,:),P.v);
        prop_seed_radius = seed_radius*randi(lower_bound_prop_scale,1,1)/lower_bound_prop_scale;
        ixs_seed = dist_seed <= prop_seed_radius;
        if sum(ixs_seed) >= MIN_SEED_PCL_SIZE
            seeds_pcls{end+1} = P.v(ixs_seed,:);
        end
    end
    if plot_fig
        scatter3(P.v(:,1),P.v(:,2),P.v(:,3),'.k');
        P_dummy = P;
        axis equal;
        hold on;
        P.segms = {};
        for i=1:size(seeds_pcls,2)
            P.segms{end+1}.v = seeds_pcls{i};
            %scatter3(seeds_pcls{i}(:,1),seeds_pcls{i}(:,2),seeds_pcls{i}(:,3),'.y');
        end       
        PlotPCLSegments(P);
        hold off;        
    end
end

