function [ results, pcls ] = ProjectModel( model, task, n_projections, n_iters, pcls, plot, print_fid, print_console, euler_angles_pca_segm )
    results = cell(1,n_projections);
    for curr_proj=1:n_projections
        Print('Projection %d of %d\n',[curr_proj,n_projections],print_fid, print_console );
        Print('--------------------------------\n',[],print_fid,print_console);
        
        loose_SQs = {};
        scale_mtx = {};
        loose_SQs = enzymeModel_SQGenerator(model,loose_SQs);

        gamma1=0.2;
        gamma2=1;

        n_seeds = 20;
        n_iter = 1;
        parallel = 1;
        sorting_mode = 'density';
        n_fittings = 0;
        new_segm_found = true;
        while n_iter<=n_iters
            Print('Iteration #%d \n',[n_iter],print_fid, print_console );
            Print('--------------------------------\n',[],print_fid,print_console);
            %pcls = enzyme_segmentPCL(parallel,pcl,pcls,scale_mtx,n_seeds,loose_SQs,min_n_points_seg,sorting_mode,gamma1,gamma2,min_score_segm,'silent');
            %fit every loose_SQ to every pcl segment and keep the best ones
            [pcls,~,loose_SQs,n_fittings] = enzymeSQ_Fitter(parallel,pcls,scale_mtx,n_seeds,loose_SQs,sorting_mode,n_fittings,gamma1,gamma2,'verbose',print_fid, euler_angles_pca_segm);
            %check for scale expectations
            if new_segm_found
                scale_mtx = enzymeScale(scale_mtx,pcls,0); 
                new_segm_found= false;
            end
            %generate loose SQs
            loose_SQs = enzymeModel_SQGenerator(model,loose_SQs);            
            Print('Iteration #%d complete\n',n_iter,print_fid, print_console );
            if n_iter < n_iters
                Print('--------------------------------\n',[],print_fid,print_console);
            end
            n_iter=n_iter+1; 
        end       
        Print('Total #fittings: %d\n',n_fittings,print_fid, print_console ); 
        Print('--------------------------------\n',[],print_fid,print_console);
        if plot
            for i=1:size(pcls,2)
                figure;
                hold on
                grid off
                axis equal

                xlabel('x') % x-axis label
                ylabel('y') % y-axis label
                zlabel('z') % z-axis label
                PlotPCLSegments2( pcls{i}{2}, i );
            end
        end

        for part=1:2
            i=1;
            for mode=1:size(pcls,2)
                for segm=1:size(pcls{mode}{2},2)
                    if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                        [ M, I, S, Sc, SQ, ~ ] = RankSQ(pcls{mode}{2}{segm}{1}, pcls{mode}{2}{segm}{2}{part}{1}, gamma1, gamma2 );                
                        M_vec(i) = M;
                        I_vec(i) = I;
                        S_vec(i) = S;
                        Sc_vec(i) = Sc;
                        SQ_vec(i,:) = SQ;
                        i=i+1;
                    end            
                end
            end
            ranks{part} = {M_vec I_vec S_vec Sc_vec SQ_vec};
            clear M_vec;
            clear I_vec;
            clear S_vec;
            clear Sc_vec;
            clear SQ_vec;
        end          

        n_parts=2;
        fitting_ranked_scores = zeros(n_parts,size(ranks{part}{1},2));
        %get best fits
        for part=1:n_parts
            [final_score,SQs] = FinalSortRanksSQ( ranks{part}{1},ranks{part}{2},ranks{part}{3},ranks{part}{4},ranks{part}{5});
            fitting_ranked_scores(part,:) = final_score(:,1)';
            sorted_SQs{part} = SQs;
            best_SQs{part} = SQs(1,:);
        %   [best_SQ_mtx,~] = getSQPlotMatrix(SQs(1,:),4000,15);
        %     plot3(best_SQ_mtx(:,1),best_SQ_mtx(:,2),best_SQ_mtx(:,3),'.g'); 
        %     if size(SQs,1) > 1
        %         worst_SQs{part} = SQs(end,:);
        %         worst_SQ_mtx = getSQPlotMatrix(SQs(end,:),4000,15);
        %         plot3(worst_SQ_mtx(:,1),worst_SQ_mtx(:,2),worst_SQ_mtx(:,3),'.r');
        %         SQ_colours_ix=1;
        %         for i=2:size(SQs,1)-1
        %             SQ_mtx = getSQPlotMatrix(SQs(i,:),4000,15);
        %             plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),'.c');
        %             SQ_colours_ix=SQ_colours_ix+1;
        %         end
        %     end
        end
        
        task_functions = GetTaskFunctions(task);
        
        part_scores = getPartScores( task_functions, model, pcls, gamma1, gamma2 );
        
        [ mode_segm, chain_size_score, chain_prop_score, chain_fit_scores, chain_dist_scores, chain_angle_vec_parts_z_scores, chain_angle_center_parts_score ] = SumChainScores(model,2,pcls,task_functions);
        
        tot_scores_mtx = chain_size_score + chain_prop_score + chain_fit_scores + chain_dist_scores + chain_angle_vec_parts_z_scores + chain_angle_center_parts_score;
        
%         disp(chain_size_score);
%         disp(chain_prop_score);
%         disp(chain_fit_scores);
%         disp(chain_dist_scores);
%         disp(chain_angle_vec_parts_z_scores);
%         disp(chain_angle_center_parts_score);
        
        chain_size_scores_rank = GetRankingMtx( chain_size_score );
        chain_prop_scores_rank = GetRankingMtx( chain_prop_score );
        chain_fit_scores_rank = GetRankingMtx( chain_fit_scores );
        chain_dist_scores_rank = GetRankingMtx( chain_dist_scores );
        chain_angle_vec_parts_z_scores_rank = GetRankingMtx( chain_angle_vec_parts_z_scores );
        chain_angle_center_parts_score_rank = GetRankingMtx( chain_angle_center_parts_score );
        tot_rank_scores_mtx = chain_size_scores_rank + chain_prop_scores_rank + chain_fit_scores_rank + chain_dist_scores_rank + chain_angle_vec_parts_z_scores_rank + chain_angle_center_parts_score_rank;
        
%         disp('------------------------------');
%         disp(chain_size_scores_rank);
%         disp(chain_prop_scores_rank);
%         disp(chain_fit_scores_rank);
%         disp(chain_dist_scores_rank);
%         disp(chain_angle_vec_parts_z_scores_rank);
%         disp(chain_angle_center_parts_score_rank);
%         disp(tot_rank_scores_mtx);
        
        %get the best overall ranked chain which is inside relationships boundaries
        %(~= Inf)
        min_tot_rank_scores_mtx = Inf;
        for i=1:size(tot_rank_scores_mtx,1)
           for j=1:size(tot_rank_scores_mtx,2) 
                if i ~= j
                    if tot_rank_scores_mtx(i,j) <= min_tot_rank_scores_mtx && tot_scores_mtx(i,j) ~= Inf
                        min_tot_rank_scores_mtx = tot_rank_scores_mtx(i,j);
                    end
                end
           end   
        end

        n_mins=0;        
        for i=1:size(tot_rank_scores_mtx,1)
           for j=1:size(tot_rank_scores_mtx,2) 
                if tot_rank_scores_mtx(i,j) == min_tot_rank_scores_mtx
                    n_mins=n_mins+1;
                    ixs_min{n_mins}(1) = i;
                    ixs_min{n_mins}(2) = j;                    
                end
           end   
        end

        %if no valid chain was found
        if min_tot_rank_scores_mtx == Inf
            result.n_best_chains = 0;
            result.best_chain = {};
            result.error = 'No valid chain was found!';
            Print('%s\n',[result.error],print_fid, print_console ); 
            result.best_scores = {};
            result.best_part_scores = {};
        else            
            result.n_best_chains = n_mins;
            for curr_best=1:result.n_best_chains
                result.best_scores{curr_best} = [chain_size_score(ixs_min{curr_best}(1),ixs_min{curr_best}(2)) chain_prop_score(ixs_min{curr_best}(1),ixs_min{curr_best}(2)) chain_fit_scores(ixs_min{curr_best}(1),ixs_min{curr_best}(2)) chain_dist_scores(ixs_min{curr_best}(1),ixs_min{curr_best}(2))  chain_angle_vec_parts_z_scores(ixs_min{curr_best}(1),ixs_min{curr_best}(2))  chain_angle_center_parts_score(ixs_min{curr_best}(1),ixs_min{curr_best}(2))];
                for part=1:2
                    result.best_chains{curr_best}{part} = pcls{mode_segm{ixs_min{curr_best}(part)}(1)}{2}{mode_segm{ixs_min{curr_best}(part)}(2)}{2}{part}{1};
                    result.best_part_scores{curr_best}{part} = part_scores{part,mode_segm{ixs_min{curr_best}(part)}(2)};
                end                          
            end
            result.error = '';  
            
            colours = {'.c' '.b'};
            if plot
                for curr_best=1:result.n_best_chains
                    for part=1:2
                        [SQ_mtx,~] = getSQPlotMatrix(pcls{mode_segm{ixs_min{curr_best}(part)}(1)}{2}{mode_segm{ixs_min{curr_best}(part)}(2)}{2}{part}{1},4000,15);
                        plot3(SQ_mtx(:,1),SQ_mtx(:,2),SQ_mtx(:,3),colours{part}); 
                    end  
                end
            end
        end
        results{curr_proj} = result;
    end
end

