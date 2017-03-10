    %Given a seed and a probability distribution over SQs, returns a fitted SQ
%pcl is a point cloud
%seed is a point in pcl (may be empty, in which case select random seed)
function [pcls, seeds_all,loose_SQs,n_fittings] = enzymeSQ_Fitter(parallel,pcls,scale_mtx,n_seeds,loose_SQs,sorting_mode,n_fittings,gamma1,gamma2,display_mode,print_fid,euler_angles_pca_segm)
    if strcmp(display_mode,'verbose')
        print_console = 1;
    else
        print_console = 0;
    end
    seeds_all = {};
    if ~isempty(pcls)
        for i=1:size(loose_SQs,1)    
            for SQ_part=1:size(loose_SQs,2) 
                fprintf('Part #%d \n',SQ_part);
                if ~isempty(loose_SQs{i,SQ_part})             
                    for mode=1:size(pcls,2)
                        segm = 1;
                        while segm<=size(pcls{mode}{2},2)                            
                            if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                                Print('Mode #%d/Segment #%d \n\n',[mode,segm], print_fid, print_console );
                                %radius_seed_planting = loose_SQs{i,SQ_part}(7); 
                                seeds = getSeedPointsCodelet(pcls{mode}{2}{segm}{1},-1,-1,n_seeds);
                                %sample scale                      
                                %scale = scale_mtx{scale_option,SQ_part}(2:4);
                                [scale, scale_option, scale_free] = changeSQScale(loose_SQs{i,SQ_part}{1},pcls{mode}{2}{segm}{1});
                                if scale_option == 1 && scale_free ~= 1
                                    scale = loose_SQs{i,SQ_part}{1}(2,1:3);  
                                end   
                                SQ_to_fit = loose_SQs{i,SQ_part};
                                SQ_to_fit{2}(1:3) = scale;
                                SQ_to_fit{2}(6:8) = euler_angles_pca_segm(segm,:);
                                SQ_to_fit{3}(1:3) = scale*0.8;
                                SQ_to_fit{4}(1:3) = scale*1.2;
                                if scale_option == 2 && ~scale_free
                                    SQ_to_fit{1} = SQ_to_fit{1}(:,4:end);
                                end
%                                 SQ_to_fit{1}(2,1:3) = scale*0.8;
                                SQ_to_fit{3}(end-2:end) = min(pcls{mode}{2}{segm}{1});
                                SQ_to_fit{4}(end-2:end) = max(pcls{mode}{2}{segm}{1});
                                tic
                                [partLambdas,partFinalScores] = PartFinder2( parallel, pcls{mode}{2}{segm}{1}, seeds, SQ_to_fit, 0, sorting_mode,gamma1,gamma2, SQ_to_fit{5},'silent' );
                                toc
                                n_fittings=n_fittings+1;
                                Print( 'Fitting #%d\n', [n_fittings], print_fid, print_console );
                                if scale_free == 0
                                    if scale_option == 1
                                        Print( 'Scale fixed determined by part (%d): [%.4f %.4f %.4f]\n', [scale_option,scale(1),scale(2),scale(3)], print_fid, print_console );
                                    else
                                        Print( 'Scale free with initial value determined by segment (%d): [%.4f %.4f %.4f]\n', [scale_option,scale(1),scale(2),scale(3)], print_fid, print_console );
                                    end
                                else
                                    Print('Scale free with initial value determined by segment (%d): [%.4f %.4f %.4f]\n',[scale_option,scale(1),scale(2),scale(3)],print_fid,print_console);
                                end
                                if size(pcls{mode}{2}{segm}{2},2) >= SQ_part
                                    rank_fit = 0;
                                    rank_curr_best = 0;
                                    for curr_rank=1:4
                                        if i==3
                                            if pcls{mode}{2}{segm}{2}{SQ_part}{2}(curr_rank) < partFinalScores(1,curr_rank)
                                                rank_curr_best = rank_curr_best + 1;
                                            end                                        
                                            if pcls{mode}{2}{segm}{2}{SQ_part}{2}(curr_rank) > partFinalScores(1,curr_rank)
                                                rank_fit = rank_fit + 1;
                                            end
                                        else
                                            if pcls{mode}{2}{segm}{2}{SQ_part}{2}(curr_rank) < partFinalScores(1,curr_rank)
                                                rank_fit = rank_fit + 1;
                                            end                                        
                                            if pcls{mode}{2}{segm}{2}{SQ_part}{2}(curr_rank) > partFinalScores(1,curr_rank)
                                                rank_curr_best = rank_curr_best + 1;
                                            end
                                        end
                                    end
                                    Print('Rank sums: fitting (%d) current best (%d)\n',[rank_fit,rank_curr_best],print_fid,print_console);
                                    fit_score = partFinalScores(1,1);
                                    pcl_fit_score = pcls{mode}{2}{segm}{2}{SQ_part}{2}(1);
                                    if (fit_score/pcl_fit_score <= 10 ) && (rank_fit < rank_curr_best) || (rank_fit == rank_curr_best && partFinalScores(1,end) < pcls{mode}{2}{segm}{2}{SQ_part}{2}(end))
                                    %if partFinalScores(1,1) < pcls{mode}{2}{segm}{2}{SQ_part}{2}(1)
                                            Print('New best fit\n',[],print_fid,print_console);
                                            Print('Fitted superquadric: [%.4f %.4f %.4f %.2f %.2f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f]\n',[partLambdas(1,1),partLambdas(1,2),partLambdas(1,3),partLambdas(1,4),partLambdas(1,5),partLambdas(1,6),partLambdas(1,7),partLambdas(1,8),partLambdas(1,9),partLambdas(1,10),partLambdas(1,11),partLambdas(1,12),partLambdas(1,13),partLambdas(1,14),partLambdas(1,15)],print_fid,print_console);
                                            Print('Rank sum fitted: (%d) [M, I, S  Sc]:       [%.e %.4f %.4f %.4f]\n',[rank_fit,partFinalScores(1,1),partFinalScores(1,2),partFinalScores(1,3),partFinalScores(1,4)],print_fid,print_console);
                                        if isempty(pcls{mode}{2}{segm}{2}{SQ_part}{1})
                                            Print('Rank sum current best (%d) [M, I, S  Sc]:  [%.e %.4f %.4f %.4f]\n',[rank_curr_best,Inf,Inf,Inf,Inf],print_fid,print_console);
                                        else
                                            Print('Rank sum current best (%d)  [M, I, S  Sc]: [%.e %.4f %.4f %.4f]\n',[rank_curr_best,pcls{mode}{2}{segm}{2}{SQ_part}{2}(1),pcls{mode}{2}{segm}{2}{SQ_part}{2}(2),pcls{mode}{2}{segm}{2}{SQ_part}{2}(3),pcls{mode}{2}{segm}{2}{SQ_part}{2}(4)],print_fid,print_console);
                                        end
                                        pcls{mode}{2}{segm}{2}{SQ_part}{1} = partLambdas(1,:);
                                        pcls{mode}{2}{segm}{2}{SQ_part}{2} = partFinalScores(1,:);
                                    else
                                        SQ_temp = pcls{mode}{2}{segm}{2}{SQ_part}{1};
                                        Print('Current best kept\n',[],print_fid,print_console);
                                        Print('Current best fitted superquadric: [%.4f %.4f %.4f %.2f %.2f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f]\n',[SQ_temp(1),SQ_temp(2),SQ_temp(3),SQ_temp(4),SQ_temp(5),SQ_temp(6),SQ_temp(7),SQ_temp(8),SQ_temp(9),SQ_temp(10),SQ_temp(11),SQ_temp(12),SQ_temp(13),SQ_temp(14),SQ_temp(15)],print_fid,print_console);
                                    end
                                end  
                                Print('\n',[],print_fid,print_console);
                            end 
                            segm=segm+1;
                        end
                    end          
                end
            end    
        end
    end
    loose_SQs = {};
end

