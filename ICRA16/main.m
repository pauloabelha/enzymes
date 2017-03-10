
%get path to the point clouds folder in current folder (where main.m is)
full_main_file_path = mfilename('fullpath');
root_path = full_main_file_path(1:end-4);
pcl_filepath = strcat([root_path 'point_clouds']);

%get all pointcloud filenames
pcl_filenames = FindAllFilesOfType( {'ply' 'pcd'}, pcl_filepath );


%set flags
plot = 0;
print_console = 0;
n_proj = 1;
n_iter = 1;

%set slash and str_split compatibility (Windows, Linux, Matlab Version...)
matlab_version = version;
if strcmp(matlab_version(end-6:end-1),'R2015b')
    str_split = 'inv';
else
    str_split = 'normal';
end
if isunix
    slash = '/';
else
    slash = '\';
end

%define models and tasks to be used
%each model in models refers to its set (by position) in tasks
models = {'hammer'};
tasks = {{'hammering_nail'}};

%for every model and every task, find the best analogical fit
for model_ix=1:size(models,2)
    for task_ix=1:size(tasks{model_ix},2)
       final_results_filename = strcat(['final_result_' models{model_ix} '_' tasks{model_ix}{task_ix} '.txt']);
        final_results_filepath = strcat([root_path slash 'results' slash final_results_filename]);
        LoopProjectModel( models{model_ix}, tasks{model_ix}{task_ix}, pcl_filenames, n_proj, n_iter, plot, print_console, root_path, final_results_filepath, slash, str_split );
    end
end

 results = ReadResults('C:\Users\r02pa14\Dropbox\PhD\System\Enzymes_20150930\', '', str_split);
 for i=1:size(results,2)
    PlotResult(results{i},pcl_filepath,1,{'.b','.k'},{'r' 'g' 'b' 'y' 'c' 'w'},1000); 
 end

