
dataset_root_folder = '~/artec_iros2017/';

pcl_filenames = FindAllFilesOfType({'ply'},dataset_root_folder);
tot_toc = 0;
for i=1:numel(pcl_filenames)
    tic;
    P = ReadPointCloud([dataset_root_folder pcl_filenames{i}]);
    SQs = PCL2SQ(P, 4);
    [~, P] = PlotSQs(SQs, 20000, 0, -1, 0);
    WritePly(P, [dataset_root_folder 'sqs/' pcl_filenames{i}]);
    DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(pcl_filenames),[pcl_filenames{i} ' ']);
end