function [ output_args ] = WriteRawScores( root_path, filename, results )
    filepath = strcat([root_path filename]);
    final_results_fid = fopen(filepath,'w+');
    if final_results_fid == -1
        error(strcat(['Could not open' final_results_filepath]));
    end
    
    WriteRawScoresHeader( final_results_fid, results );

    for ix_res=1:size(results,2)
        rep_values = zeros(size(results{ix_res}.clustered_projections,2),1);
        for ix_cluster=1:size(results{ix_res}.clustered_projections,2)
            rep_values(ix_cluster) = results{ix_res}.clustered_projections{ix_cluster}.n_rep;
        end         
        [rep_values_sorted,rep_values_sorted_ixs] = sort(rep_values,'descend');        
        %[~,rep_values_sorted_ixs] = sort(rep_values_sorted_ixs);
        
        prev_rep_value=rep_values_sorted(1);
        for ix_cluster=1:size(results{ix_res}.clustered_projections,2)
            if rep_values_sorted(ix_cluster)==prev_rep_value
                fprintf(final_results_fid,'%s\t',results{ix_res}.pcl);                
                for ix_part=1:2
                    fprintf(final_results_fid,'%f\t%f\t%f\t',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{ix_part}(1:3));
                    fprintf(final_results_fid,'\t\t\t');
                    fprintf(final_results_fid,'%f\t%f\t%f\t',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_scores{ix_part}(3));
                end
                SQ_1_pos = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{1}(end-2:end);
                SQ_2_pos = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{2}(end-2:end);
                fprintf(final_results_fid,'%f\t',pdist([SQ_1_pos; SQ_2_pos]));
                SQ_1_angle = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{1}(6:8);
                SQ_2_angle = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{2}(6:8);
                vector_lambda_a_Z = eul2rotm_(SQ_1_angle,'ZYZ')*[0;0;1];
                vector_lambda_a_Z = vector_lambda_a_Z/norm(vector_lambda_a_Z);
                vector_lambda_b_Z = eul2rotm_(SQ_2_angle,'ZYZ')*[0;0;1];
                vector_lambda_b_Z = vector_lambda_b_Z/norm(vector_lambda_b_Z);
                fprintf(final_results_fid,'%f\t',subspace(vector_lambda_a_Z,vector_lambda_b_Z));

                if pdist([SQ_1_pos; SQ_2_pos]) < 0.001
                    fit_angle_center_parts = Inf;
                else
                    vec_between_center_parts = (SQ_2_pos - SQ_1_pos)';
                    vec_between_center_parts = vec_between_center_parts / norm( vec_between_center_parts );
                    fit_angle_center_parts = subspace(vector_lambda_a_Z(:),vec_between_center_parts);
                end
                fprintf(final_results_fid,'%f\t\t',fit_angle_center_parts);     
                fprintf(final_results_fid,'%d',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.n_rep);
                fprintf(final_results_fid,'\n');
                prev_rep_value=rep_values_sorted(ix_cluster);
            end
        end
    end        
    
    fprintf(final_results_fid,'\n');
    
    for ix_res=1:size(results,2)    
        rep_values = zeros(size(results{ix_res}.clustered_projections,2),1);
        for ix_cluster=1:size(results{ix_res}.clustered_projections,2)
            rep_values(ix_cluster) = results{ix_res}.clustered_projections{ix_cluster}.n_rep;
        end         
        [rep_values_sorted,rep_values_sorted_ixs] = sort(rep_values,'descend');        
        %[~,rep_values_sorted_ixs] = sort(rep_values_sorted_ixs);
        
        for ix_cluster=1:size(results{ix_res}.clustered_projections,2)
            fprintf(final_results_fid,'%s\t',results{ix_res}.pcl);
            
            for ix_part=1:2
                fprintf(final_results_fid,'%f\t%f\t%f\t',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{ix_part}(1:3));
                fprintf(final_results_fid,'\t\t\t');
                fprintf(final_results_fid,'%f\t%f\t%f\t',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_scores{ix_part}(3));
            end
            SQ_1_pos = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{1}(end-2:end);
            SQ_2_pos = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{2}(end-2:end);
            fprintf(final_results_fid,'%f\t',pdist([SQ_1_pos; SQ_2_pos]));
            SQ_1_angle = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{1}(6:8);
            SQ_2_angle = results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.part_fits{2}(6:8);
            vector_lambda_a_Z = eul2rotm_(SQ_1_angle,'ZYZ')*[0;0;1];
            vector_lambda_a_Z = vector_lambda_a_Z/norm(vector_lambda_a_Z);
            vector_lambda_b_Z = eul2rotm_(SQ_2_angle,'ZYZ')*[0;0;1];
            vector_lambda_b_Z = vector_lambda_b_Z/norm(vector_lambda_b_Z);
            fprintf(final_results_fid,'%f\t',subspace(vector_lambda_a_Z,vector_lambda_b_Z));

            if pdist([SQ_1_pos; SQ_2_pos]) < 0.001
                fit_angle_center_parts = Inf;
            else
                vec_between_center_parts = (SQ_2_pos - SQ_1_pos)';
                vec_between_center_parts = vec_between_center_parts / norm( vec_between_center_parts );
                fit_angle_center_parts = subspace(vector_lambda_a_Z(:),vec_between_center_parts);
            end
            fprintf(final_results_fid,'%f\t\t',fit_angle_center_parts);     
            fprintf(final_results_fid,'%d',results{ix_res}.clustered_projections{rep_values_sorted_ixs(ix_cluster)}.n_rep);
            fprintf(final_results_fid,'\n');
        end
    end

end
