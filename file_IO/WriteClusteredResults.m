function [path_results_folder, filename] = WriteClusteredResults( model, task, pcl_filename, n_proj, n_iter, result, path_results_folder )
    pcl_name = pcl_filename(1:end-4);

    
    
    filename = strcat(['clustered_result_',model,'_',task,'_onto_',pcl_name,'.txt']);
    filepath = strcat([path_results_folder filename]);
    
    fid = fopen(filepath,'w');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath);
        error(msg);
    end
    
    fprintf(fid,'result_projection_clustered');
    fprintf(fid,'\n');
    fprintf(fid,'#Clustered results file for model projection');
    fprintf(fid,'\n');
    fprintf(fid,'#Superquadric: a1 a2 a3 epsilon1 epsilon 2 euler1 euler2 euler3 taper1 taper2 bend1 bend2 pos_X pos_Y pos_Z');
    fprintf(fid,'\n');
    fprintf(fid,'#Order of scores for each pair of superquadrics: [size; proportion; fitting;  distance; angle Z axis; angle center] (0 to Inf; 0 means equal to model/task or perfect fit)');
    fprintf(fid,'\n');
    fprintf(fid,'\n');
    fprintf(fid,'model %s',model);
    fprintf(fid,'\n');
    fprintf(fid,'task %s',task);
    fprintf(fid,'\n');
    fprintf(fid,'pcl %s',pcl_name);
    fprintf(fid,'\n');
    fprintf(fid,'n_proj %d',n_proj);
    fprintf(fid,'\n');
    fprintf(fid,'n_iter %d',n_iter);
    fprintf(fid,'\n');
    fprintf(fid,'end_header');
    fprintf(fid,'\n');
    
    for i=1:size(result.clustered_projections,2)
        fprintf(fid,'cluster');
        fprintf(fid,'\n');
        fprintf(fid,'n_instances %d',result.clustered_projections{i}.n_rep);
        fprintf(fid,'\n');
        for j=1:size(result.clustered_projections{i}.part_fits,2)
            fprintf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',result.clustered_projections{i}.part_fits{j});
            fprintf(fid,'\n');
            fprintf(fid,'%f %f %f',result.clustered_projections{i}.part_scores{j});
            fprintf(fid,'\n');
        end
        fprintf(fid,'%f %f %f %f %f %f',result.clustered_projections{i}.scores);
        fprintf(fid,'\n');
    end
    fclose(fid);
end

