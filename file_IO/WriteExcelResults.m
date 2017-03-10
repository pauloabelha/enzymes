function WriteExcelResult( final_results_fid, model, task, n_proj, n_iter, results  ) 
    fprintf(final_results_fid,'result_final');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'#Final results for winner clusters');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'model %s',model);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'task %s',task);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_proj %d',n_proj);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_iter %d',n_iter);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'#[pcl name; size(part 1); proportion(part 1); fitting(part 1);  size(part 2); proportion(part 2); fitting(part 3); distance; angle Z axis; angle center]');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'end_header');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'\n');
    
    for ix_result=1:size(results,2)
        max_n_rep = 0;
        ix_winner_cluster = 1;
        for i=1:size(results{ix_result}{1}.clustered_projections,2)
            if results{ix_result}{1}.clustered_projections{i}.n_rep > max_n_rep
                max_n_rep =  results{ix_result}{1}.clustered_projections{i}.n_rep;
                ix_winner_cluster = i;
            end
        end
        fprintf(final_results_fid,results{ix_result}{1}.pcl);
        fprintf(final_results_fid,' ');
        for ix_proj=1:size(results{ix_result}{1}.clustered_projections{i}.part_fits,2)
            fprintf(final_results_fid,'%f %f %f ',results{ix_result}{1}.clustered_projections{ix_winner_cluster}.part_scores{ix_proj});
        end
        fprintf(final_results_fid,'%f %f %f',results{ix_result}{1}.clustered_projections{ix_winner_cluster}.scores(end-2:end));
        fprintf(final_results_fid,'\n');
    end
end

