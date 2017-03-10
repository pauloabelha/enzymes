function [lambda_o_final,final_rank_values] = PartFinder2(parallel, pcl, seeds, SQ, grow, sorting_mode, gamma1,gamma2, tapering,display_mode )
    %part_growth_factor (x y z)
    part_scale_shrink_factors = [1 1 1];
    part_scale_growth_factors = [3 3 3];
    
    %get initial orientation to aligned SQ z-axis qith with the pca-transformed
    %point cloud x-axis
    initial_orient = [randi([0,314],1,1)/100 randi([0,314],1,1)/100 randi([0,314],1,1)/100];
    
    if parallel
        [~,lambda_o_initial,lambda_o_final_b4_growth,~,~,final_rank_values_b4_growth,~] = ...
                        SearchBiegelbauerSQ2Parallel(pcl,seeds,SQ{1},SQ{2},SQ{3},SQ{4},tapering,0,sorting_mode,gamma1,gamma2,display_mode);        
    else
        [~,lambda_o_initial,lambda_o_final_b4_growth,~,~,final_rank_values_b4_growth,~] = ...
                        SearchBiegelbauerSQ2(pcl,seeds,SQ{1},SQ{2},SQ{3},SQ{4},0,0,sorting_mode,gamma1,gamma2,display_mode);
    end
    
    if grow
        [~,~,lambda_o_final,~,~,final_rank_values,~] = ...
            GrowSQs(pcl,seeds,lambda_o_initial,lambda_o_final_b4_growth,M_vec,final_rank_values_b4_growth(:,2),...
                    final_rank_values_b4_growth(:,3),Sc_vec,part_scale_shrink_factors,part_scale_growth_factors,0,0,display_mode);
    else
        lambda_o_final = lambda_o_final_b4_growth;
        final_rank_values = final_rank_values_b4_growth;
    end
end

