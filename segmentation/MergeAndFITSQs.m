function [ pcls_merged ] = MergeAndFITSQs( root_folder, output_folder )
    pcl_filenames = FindAllFilesOfType({'ply'}, root_folder);
    system(['mkdir ' root_folder output_folder]);
    pcls_merged = {};
    tot_toc = 0;
    for i=1:numel(pcl_filenames)
        tic;
        P = ReadPointCloud([root_folder pcl_filenames{i}]);
        n_segms = numel(P.segms);
        disp(['    Merging point cloud: ' pcl_filenames{i} ' with ' num2str(n_segms) ' segms']);   
        disp('        Fitting SQs to get error per segm...');
        [~, E, E_segms] = PCL2SQ( P, 1, 0, 0, [1 1 1 0 1] );
        disp(['        Error per segm: ' num2str(E/n_segms)]); 
        orig_E_per_segm = E/n_segms;
        min_E_per_segm = orig_E_per_segm;
        S = cell(1,n_segms);
        for j=1:n_segms
            S{j} = j;
        end
        Pw_set_segms = PowerSet( S );
        best_Pw_set_segms = {};
        E_per_segms = [];
        for j=1:numel(Pw_set_segms)            
            ix = (numel(Pw_set_segms)-j) + 1;            
            % construct merged pcl
            pcl = [];
            if size(Pw_set_segms{ix},2) < 2
                break;
            end
            disp(['        Merging segms: ' num2str(Pw_set_segms{ix})]);
            for k=1:size(Pw_set_segms{ix},2)
                pcl = [pcl; P.segms{Pw_set_segms{ix}(k)}.v];
            end
            % fit to merged pcl
            disp('        Fitting SQs to get total error...');
            [~, E] = PCL2SQ( pcl, 1, 0, 0, [1 1 1 0 1] );
            % get error of the merged segms
            n_new_segms = ((n_segms-size(Pw_set_segms{ix},2))+1);
            % get error of others (non-merged) segms
            E_others = 0;
            pcl_others = [];
            for k=1:n_segms
                if ~ismember(k,Pw_set_segms{ix})
                    E_others = E_others + E_segms(k);
                end
            end
            % get curr average error per segm            
            E_per_segm = (E + E_others)/n_new_segms;
            disp(['            Error per segm: ' num2str(E_per_segm)]);
            E_per_segms(end+1) = E_per_segm;            
            if E_per_segm < min_E_per_segm
                disp(['            Found better option with error per segm: ' num2str(E_per_segm)]);
                min_E_per_segm = E_per_segm;
                best_Pw_set_segms = Pw_set_segms{ix};
            end
        end
        if isempty(best_Pw_set_segms)
            disp('        No better segmentation found');
        else
            pcls_merged{end+1} = pcl_filenames{i};
            P_best = P;
            for j=2:size(best_Pw_set_segms,2)
                P_best = MergePointCloudSegments( P_best, best_Pw_set_segms(1), best_Pw_set_segms(j), 1 );
            end
            disp(['        Found better segmentation with ' num2str(numel(P_best.segms)) ' segms instead of ' num2str(numel(P.segms))]);
            disp('        Writing pointcloud...');
            WritePly(P_best,[root_folder output_folder pcl_filenames{i}]);
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(pcl_filenames));
    end
end
