function [ similar ] = ThereIsSimilarSegmentationMode( orig_pcl, pcls, SQ, gamma2 )
    disp('Current best fitted SQ being used to search for similar segmentations:');
    disp(SQ);
    epsilon = 0.001;
    perc = 0.8;
    [pcl_SQ, ~, ~] = splitPclFromSQ(orig_pcl,SQ,gamma2);
    [pcl_SQ_sorted,pcl_SQ_sorted_values] = SortPclDistOrig( pcl_SQ );
    pcl_SQ_sorted_w_dist = [pcl_SQ_sorted pcl_SQ_sorted_values];
    similar = 0;
    n_segms=0;
    for mode=2:size(pcls,2)
        for segm=1:size(pcls{mode}{2},2)
            n_segms=n_segms+1;
            fprintf('Segment #%d:\nProcessing...\n',n_segms);
            length_pcl_SQ = size(pcl_SQ,1);
            length_segm = size(pcls{mode}{2}{segm}{1},1);
            if min(length_pcl_SQ,length_segm) >= perc*max(length_pcl_SQ,length_segm)
                [segm_sorted,segm_sorted_values] = SortPclDistOrig( pcls{mode}{2}{segm}{1} );
                segm_sorted_w_dist = [segm_sorted segm_sorted_values];
                n_similar_points = 0;                 
                ix_pcl_SQ=1;        
                ix_segm=1;            
                while ix_pcl_SQ < length_pcl_SQ && ix_segm < length_segm
                    if pdist([pcl_SQ_sorted_w_dist(ix_pcl_SQ,1:3);segm_sorted_w_dist(ix_segm,1:3)]) < epsilon
                        n_similar_points=n_similar_points+1;
                        ix_pcl_SQ = min(ix_pcl_SQ+1,length_pcl_SQ);
                        ix_segm = min(ix_segm+1,length_segm);
                    else
                        if pcl_SQ_sorted_w_dist(ix_pcl_SQ,4) <= segm_sorted_w_dist(ix_segm,4)
                            ix_pcl_SQ = min(ix_pcl_SQ+1,length_pcl_SQ);
                        else
                            ix_segm = min(ix_segm+1,length_segm);
                        end
                    end                  
                end
                if n_similar_points >= perc*max(length_pcl_SQ,length_segm)
                    similar = 1;
                    fprintf('There is already a similar segmentation in segment #%d.\n',n_segms);
                    return;
                end
            end
            fprintf('Processed.\n',n_segms);
        end
    end
%     epsilon_scale = 0.01;
%     epsilon_shape = 0.1;
%     epsilon_angle1 = (1/6)*pi;
%     epsilon_angle2 = (5/6)*pi;
%     epsilon_angle3 = (7/6)*pi;
%     epsilon_angle4 = (11/6)*pi;
%     epsilon_dist = 0.1;
%     answer = false;
%     for mode=2:size(pcls,2)
%         answer = true;
%         for i=1:11
%             curr_dist = pdist([pcls{mode}{1}(i); SQ(i)]);
%             %checking for scale similarity
%             if i<= 3 && curr_dist < epsilon_scale
%                 answer = true;
%                 break;
%             end
%             %checking for shape similarity
%             if i > 3 && i<= 5 && curr_dist < epsilon_shape
%                 answer = true;
%                 break;
%             end
%             %checking for angle similarity
%             if i > 5 && i<= 8
%                 if  (curr_dist < epsilon_angle1 || curr_dist > epsilon_angle2) ...
%                     && (curr_dist < epsilon_angle3 || curr_dist > epsilon_angle4) 
%                         answer = true;
%                         break;
%                 end
%             end
%             if i > 8 && i<= 11 && curr_dist >= epsilon_dist
%                 answer = false;
%                 break;
%             end
%         end
%         if answer == false
%             break
%         end
%     end
end

