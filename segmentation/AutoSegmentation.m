function AutoSegmentation(root_folder, verbose)
    % print help
    if ischar(root_folder) && P == "--help"
        disp('Function AutoSegmentation');        
        disp('This function will automatically segment point clouds and filter the best options'); 
        disp('The code should have come with .mat files corresponding to each available Task Function file.');
        disp([char(9) 'e.g. IROS2018_TaskFunction_scraping_butter.mat']); 
        disp('Params:'); 
        disp([char(9) 'First param: filepath to the point cloud']); 
        disp([char(9) 'Second param: mass of the pcl']);
        disp([char(9) 'Third param: target object alignment vector (final vector to which the tool''s vector going from grasp centre to action centre should be aligned)']);
        disp([char(9) 'Fourth param: task name (works only with ''scraping_butter'' for now)']);
        disp([char(9) 'Fifth param: path to the trained Task Function file']);
        disp([char(9) 'Sixth param: flag for verbose and logging (default is 0)']);
        disp([char(9) 'Seventh param: flag for running in parallel (default is 0)']);
        disp('Written by Paulo Abelha'); 
        return;
    end


end

