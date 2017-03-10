function [ pcl_filenames, pcl_cut_beliefs ] = SegmentDemocritusInFolder( root_folder, output_folder, slice_size )
    CheckIsChar(root_folder);
    if ~exist('ext','var')
        exts = {'ply'};
    end
    if ~exist('output_folder','var')
        output_folder = '';
    end
    system(['mkdir ' root_folder output_folder]);
    pcl_filenames = FindAllFilesOfType(exts,root_folder);
    pcl_cut_beliefs = cell(1,numel(pcl_filenames));
    tot_toc = 0;
    for i=1:size(pcl_filenames,2)
        tic;
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        tic;
        [ segms, ~, pcl_cut_beliefs{i} ] = CutPCLDemocritus2( P.v, slice_size );
%         segms = RecursiveDemocritus( P.v, slice_size );
        P.segms = {};
        P.u = zeros(size(P.v,1),1);
        prev = 0;
        new_points = zeros(size(P.v,1),3);
        for j=1:numel(segms)
            P.segms{end+1}.v = segms{j};
            P.u(prev+1:prev+size(segms{j},1)) = j;
            new_points(prev+1:prev+size(segms{j},1),:) = segms{j};
            prev = prev + size(segms{j},1);
        end     
        P.v = new_points;
        P = AddColourToSegms(P);
        P.f = [];
        WritePly(P,[root_folder output_folder pcl_filenames{i}]);
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2),['Segmenting in folder: ' root_folder pcl_filenames{i} ' Cut belief: ' num2str(pcl_cut_beliefs{i}) '  ' ]);        
    end
end

