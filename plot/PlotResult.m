function [ output_args ] = PlotResult( result, pcl_rootpath, plot_clustered, colours_parts, colour_pcls, downsample )   
    disp(result.pcl);
    if plot_clustered
        if size(result.clustered_projections,2) == 0
           error('There are no valid clustered projections to plot. Check if there are no best chains for this result.'); 
        end
        for i=1:1%size(result.clustered_projections,2)            
            figure;
            hold on
            grid off
            axis equal

            xlabel('x') % x-axis label
            ylabel('y') % y-axis label
            zlabel('z') % z-axis label
            
            min_prop_segm_size = 20;
            [P, segms_read] = ReadPointCloud(strcat([pcl_rootpath '\' result.pcl '.pcd']),500);
            segms = {};
            ix_new_segms=1;
            for j=1:size(segms_read,2)
                if size(segms_read{j}.v,1) >= size(P.v,1)/min_prop_segm_size
                    segms{ix_new_segms} = segms_read{j}.v;
                    ixs_downsample = randsample(1:size(segms{ix_new_segms},1),min(downsample,size(segms{ix_new_segms},1)));
                    segms{ix_new_segms} = (segms{ix_new_segms}(ixs_downsample,:));
                    ix_new_segms=ix_new_segms+1;
                end
            end
            PlotPCLSegments( segms, -1, colour_pcls );
            if nargin<4
                colours_parts = {'.b' '.k'};
            end
            for part=1:size(result.clustered_projections{i}.part_fits,2)                    
                [SQ_mtx,~] = getSQPlotMatrix(result.clustered_projections{i}.part_fits{part},4000,15);
                plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),colours_parts{part}); 
            end           
        end
    else
        at_least_one_valid_proj = 0;
        for curr_proj=1:result.n_proj
            figure;
            hold on
            grid off
            axis equal

            xlabel('x') % x-axis label
            ylabel('y') % y-axis label
            zlabel('z') % z-axis label

            min_prop_segm_size = 20;
            [P, segms_read] = ReadPointCloud(strcat([pcl_rootpath result.pcl '.pcd']),100);
            segms = {};
            ix_new_segms=1;
            for i=1:size(segms_read,2)
                if size(segms_read{i}.v,1) >= size(P.v,1)/min_prop_segm_size
                    segms{ix_new_segms} = segms_read{i}.v;
                    ix_new_segms=ix_new_segms+1;
                end
            end
            PlotPCLSegments( segms, 1 );

            projection = result.projections{curr_proj};
            colours = {{'.c' '.b'} {'g' 'y'} {'w' 'k'}};
            if projection.n_best_chains == 0
                fprintf('There are no valid best chains for projection %d\n',curr_proj);
            else
                at_least_one_valid_proj = 1;
                for curr_best_chain=1:projection.n_best_chains
                    best_chain = projection.best_chains{curr_best_chain};            
                    for part=1:best_chain.n_parts
                        [SQ_mtx,~] = getSQPlotMatrix(best_chain.part_fits{part},4000,15);
                        plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),colours{curr_best_chain}{part}); 
                    end 
                end        
            end
        end
        if ~at_least_one_valid_proj
            error('There are no valid projections to plot. Check if there are no best chains for this result.'); 
        end
    end
end

