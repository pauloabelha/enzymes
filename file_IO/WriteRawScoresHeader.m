function WriteRawScoresHeader( final_results_fid, results )

    model = results{1}.model;
    task = results{1}.task;
    n_proj = results{1}.n_proj;
    n_iter = results{1}.n_iter;
    
    fprintf(final_results_fid,'model\t%s',model);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'task\t%s',task);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_proj\t%d',n_proj);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'n_iter\t%d',n_iter);
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'SCORES\tsize_X1\tsize_Y1\tsize_Z1\tpropXY1\tpropXZ1\tpropYZ1\tfit2\tsize_X2\tsize_Y2\tsize_Z2\tpropXY2\tpropXZ2\tpropYZ2\tfit2\tdistance\tangleZ\tangleCenter\t\tn_rep');
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'\n');
    
    [parts, angles, distances, ~] = SHAPEparam(model);
    scales = {};
    for i=1:2
        [lambda_f,~,~,~,~] = SQparam(parts{i},0,0);
        if lambda_f(1,1) == 1
            scales{i} = lambda_f(2,1:3);
        else
            scales{i} = [0 0 0];
        end
    end
    [ task_functions ] = GetTaskFunctions( task );
    fprintf(final_results_fid,'MODEL\t');
    for i=1:2
        task_score = task_functions.size_score{1,i};
        if strcmp(task_score,'model')
            fprintf(final_results_fid,'%f\t%f\t%f\t',scales{i}); 
        else
            score = task_score;
        end
        fprintf(final_results_fid,'%f\t%f\t%f\t',scales{i}(1)/scales{i}(2),scales{i}(1)/scales{i}(3),scales{i}(2)/scales{i}(3)); 
        fprintf(final_results_fid,'\t');        
    end
    fprintf(final_results_fid,'%f\t',distances{1}{1});
    fprintf(final_results_fid,'%f\t',angles{1}{1});
    fprintf(final_results_fid,'%f',angles{1}{4});
    
    fprintf(final_results_fid,'\n');
    fprintf(final_results_fid,'\n');
end

