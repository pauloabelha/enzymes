function fid = WriteResults( model, task, pcl_filename, n_proj, n_iter, results, root_folder )
    pcl_name = pcl_filename(1:end-4);
    
    filename = strcat(['result_',model,'_',task,'_onto_',pcl_name,'.txt']);
    filepath = strcat([root_folder '\' filename]);
    
    fid = fopen(filepath,'w');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath);
        error(msg);
    end
    
    fprintf(fid,'result_projection');
    fprintf(fid,'\n');
    fprintf(fid,'#Results file for model projection');
    fprintf(fid,'\n');
    fprintf(fid,'#Superquadric: a1 a2 a3 epsilon1 epsilon 2 euler1 euler2 euler3 taper1 taper2 bend1 bend2 pos_X pos_Y pos_Z');
    fprintf(fid,'\n');
    fprintf(fid,'#Order of scores for each pair of superquadrics: [size; proportion; fitting;  distance; angle Z axis; angle center] (0 to Inf; 0 means equal to model/task or perfect fit)');
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
    
    for i=1:size(results,2)
        fprintf(fid,'result');
        fprintf(fid,'\n');
        fprintf(fid,'n_best_chains %d',results{i}.n_best_chains);
        fprintf(fid,'\n');
        for j=1:results{i}.n_best_chains
            n_parts = size(results{i}.best_chains{j},2);
            fprintf(fid,'n_parts %d',n_parts);
            fprintf(fid,'\n');
            for k=1:n_parts
                fprintf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',results{i}.best_chains{j}{k});
                fprintf(fid,'\n');
                fprintf(fid,'%f %f %f',results{i}.best_part_scores{j}{k});
                fprintf(fid,'\n');
            end
            fprintf(fid,'%f %f %f %f %f %f',results{i}.best_scores{j});
            fprintf(fid,'\n');
        end        
        fprintf(fid,'size_error_message %d',size(results{i}.error,2));
        fprintf(fid,'\n');
        fprintf(fid,results{i}.error);
        fprintf(fid,'\n');
    end
end

