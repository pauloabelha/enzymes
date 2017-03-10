function WriteExcelResult( final_results_fid, result  ) 
    max_n_rep = 0;
    ix_winner_cluster = 1;
    if size(result.clustered_projections,2)>0
        for i=1:size(result.clustered_projections,2)
            if result.clustered_projections{i}.n_rep > max_n_rep
                max_n_rep =  result.clustered_projections{i}.n_rep;
                ix_winner_cluster = i;
            end
        end
        fprintf(final_results_fid,'%s\t',result.pcl);
        fprintf(final_results_fid,' ');
        for ix_proj=1:size(result.clustered_projections{i}.part_fits,2)
            fprintf(final_results_fid,'%f\t%f\t%f\t',result.clustered_projections{ix_winner_cluster}.part_scores{ix_proj});
        end
        fprintf(final_results_fid,'%f\t%f\t%f',result.clustered_projections{ix_winner_cluster}.scores(end-2:end));
        fprintf(final_results_fid,'\n');
    end
end

