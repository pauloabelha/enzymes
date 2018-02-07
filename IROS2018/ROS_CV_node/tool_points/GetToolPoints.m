function [ grasp_point, action_point ] = GetToolPoints( P, mass, proj_filepath )
    % print help
    if ischar(P) && P == "--help"
       disp('Function GetToolPoints');        
       disp('This function will get a tool''s requried points'); 
       disp('Only the first and second params are compulsory'); 
       disp([char(9) 'First param: filepath to the point cloud']); 
       disp([char(9) 'Second param: list of points passed in the followng syntax:']);
       disp([char(9) char(9) 'One point: "[0.1 0.1 0.1]"']);
       disp([char(9) char(9) 'Two point: "[0.1 0.1 0.1;0.2 0.2 0.2]"']);
       disp([char(9) char(9) 'Three point: "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) char(9) 'The double quote around the list of points is required']);
       disp([char(9) 'Third param: 1 or 0 for whether to print the edges to the terminal (default is 1)']);
       disp([char(9) 'Fourth param: 1 or 0 for whether to plot the results (default is 0)']);
       disp([char(9) 'Fifth param: 1 or 0 for whether to run the superquadric fitting in parallel (default is 0)']);
       disp([char(9) char(9) 'Setting the parallel param to 1 may incur in a long waiting time to create a parallel pool of cores']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2]" 0 1 0']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using two points, plot the results, and running serially']);
       disp('')
       disp('Example calls:');
       disp([char(9) './edge_detector ~/ToolWeb/bowl_2_3dwh.ply "[0.1 0.1 0.1;0.2 0.2 0.2;0.3 0.3 0.3]"']);
       disp([char(9) 'This will cal edge_detector on the given point cloud, using three points and print the edges to the terminal']);
       disp('')
       disp('Written by Paulo Abelha'); 
       edges = 0; min_dists = 0; SQ = 0;
       return;
    end
    %% check inputs
    try
        CheckIsPointCloudStruct(P);
    catch
        if ischar(P)
            P = ReadPointCloud(P);
        else
            PointCloud(P);
        end
    end
    load(proj_filepath);
    [ best_scores, best_categ_scores_mtx, best_ptools, best_ptool_maps ] = SeedProjection( P, mass, task, @TaskFunctionGPR, {gprs{end}, dims_ixs{end}}, 10, 1, 1 );             
    ptool_ix = 1;
    grasp_point = best_ptool_maps(ptool_ix, 1:3);
    action_point = grasp_point + (best_ptool_maps(ptool_ix, 4:6) * norm(best_ptools(ptool_ix, 19:21)));
    disp('Grasp point:');
    disp([char(9) num2str(grasp_point)]);
    disp('Action point:');
    disp([char(9) num2str(action_point)]);
    disp(['Affordance score: ']);
    disp([char(9) num2str(best_categ_scores_mtx(ptool_ix, :))]);
end

