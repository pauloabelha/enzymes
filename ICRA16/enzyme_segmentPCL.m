function [ pcls ] = enzyme_segmentPCL(parallel,orig_pcl,pcls,scale_mtx,n_seeds,loose_SQs,min_n_points_seg,sorting_mode,gamma1,gamma2,min_score,display_mode)
    disp('Looking for possible new segmentations...');
    init_best_score = Inf;
    init_best_rank = Inf;
    best_ranks(1) = init_best_score;
    best_scores(1) = init_best_rank;
    for i=1:size(loose_SQs,1)    
        for part=1:size(loose_SQs,2) 
            if ~isempty(loose_SQs{i,part})
                radius_seed_planting = loose_SQs{i,part}(7); 
                seeds = getSeedPointsCodelet(orig_pcl,-1,radius_seed_planting,n_seeds);
                %sample scale
                scale_option = randsample(sampleScalePart( scale_mtx, 1 ),1);
                scale = scale_mtx{scale_option,1}(2:4);
                shape = loose_SQs{1,1}(4:5); 
                [partLambdas,partFinalScores] = PartFinder2(parallel, orig_pcl, seeds, [scale, shape], 0, sorting_mode, gamma1,gamma2, display_mode );
                ixs_less_min_score = partFinalScores(:,end)<repmat(min_score, size(seeds,1), 1);
                if ~isempty(partFinalScores(ixs_less_min_score)) && partFinalScores(1,end) < best_scores(1)                     
                    best_SQs = partLambdas(ixs_less_min_score,:);
                    best_ranks = partFinalScores(ixs_less_min_score,1:4);
                    best_scores = partFinalScores(ixs_less_min_score,end);
                end       
            end         
            
        end
    end 
    similar_segm_mode_found = 0;
    for i=1:size(best_SQs,1)
        similar_segm_mode_found = ThereIsSimilarSegmentationMode(orig_pcl,pcls,best_SQs(i,:),gamma2);
        if ~similar_segm_mode_found
            break;
        end
    end
    if similar_segm_mode_found
        disp('No new segmentation done.');
    else
        [pcl_SQ, pcl_out1, pcl_out2] = splitPclFromSQ(orig_pcl,best_SQs(i,:),gamma2);
        pcls = InitializeSegmentationModePCL( min_n_points_seg, pcls, {pcl_SQ, pcl_out1, pcl_out2}, 2, best_SQs(i,:), best_ranks(i,:), best_scores(i), init_best_rank, init_best_score );
        disp('New segmentation done.');
    end
end

