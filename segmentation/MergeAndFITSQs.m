function [ pcls_merged, E_all, pcl_w_errors ] = MergeAndFITSQs( root_folder, output_folder )
    pcl_filenames = FindAllFilesOfType({'ply'}, root_folder);
    system(['mkdir ' root_folder output_folder]);
    pcls_merged = {};
    E_all = [];
    pcl_w_errors = {};
    tot_toc = 0;
    for i=1:numel(pcl_filenames)
        tic;
        try
            P = ReadPointCloud([root_folder pcl_filenames{i}]);      
            disp(['Processing pointcloud ' pcl_filenames{i}]);
            %% get fit error for all powerset of the set of segms        
            n_segms = numel(P.segms); 
            if n_segms == 1
                disp('    Pcl has only 1 segm; continuing loop...');
                continue;
            end
            disp(['    Getting ' num2str(2^n_segms) ' fit errors for the powerset of ' num2str(n_segms) ' segms...']);
            S = cell(1,n_segms);
            for j=1:n_segms
                S{j} = j;
            end        
            Pws = PowerSet( S );
            E_pws = [];
            for j=2:numel(Pws)
                E_pws = GetErrorForSegmSets(P.segms,Pws,j,E_pws);            
            end  
            disp(E_pws);
            %% get the fit error for all partitions of the powerset
            PI = AllPartitions( S );
            disp(['    Getting fit errors for all ' num2str(numel(PI)) ' partitions...']);        
            E_pi = zeros(1,numel(PI));
            % each partition
            for j=1:numel(PI)
                % each set of segms in a partition
                E_tot = 0;
                for k=1:numel(PI{j})  
                    set_segms = PI{j}{k};
                    pws_ix = GetPwsIx(Pws,set_segms);
                    E_tot = E_tot + E_pws(pws_ix);
                end
                E_pi(j) = E_tot;
                E_all(end+1) = E_tot;
            end
            disp(E_pi);
            % best partition
            [~,best_part_ix] = min(E_pi);
            % check if best partition is the original one
            if best_part_ix == numel(PI)
                disp('    No better segmentation found - best partition is the original (no merging) one');
            else
                disp(['    Better segmentation found at partition ' num2str(best_part_ix)]);
                disp('    Merging pcl...');
                P = GetMergedPCL(P,PI{best_part_ix});
                disp('    Writing merged ply...');
                WritePly(P,[root_folder output_folder pcl_filenames{i}]);
            end        
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,numel(pcl_filenames));
        catch
            pcl_w_errors{end+1} = pcl_filenames{i};
        end        
    end
end

function P = GetMergedPCL(P,part)
    merge_count = 0;
    for i=1:numel(part)
        set_segms = part{i};
        j = 1;
        while j + 1 <= numel(set_segms)            
            ix_segm1 = set_segms{j} - merge_count;
            ix_segm2 = set_segms{j+1} - merge_count;
            P = MergePointCloudSegments(P,ix_segm1,ix_segm2,1); 
            merge_count = merge_count + 1;
            j = j + 1;
        end
    end
end

function pws_ix = GetPwsIx(Pws,S)
    pws_ix = -1;
    for i=1:numel(Pws)
        if numel(Pws{i}) == numel(S)
            equal = 1;
            for j=1:numel(S)
                if ~ismember(S{j},Pws{i}{j})
                    equal = 0;
                    break;
                end
            end
            if equal
               pws_ix = i;
               break;
            end
        end
    end    
end

function [E_pws] = GetErrorForSegmSets(segms,Pws,pws_ix,E_pws)
    n_segms = numel(segms);
    % create E_array if necessary
    if ~exist('E_pws','var') || isempty(E_pws)
        E_pws = zeros(1,2^n_segms) - 1;
        E_pws(1) = 0;
    end
    if isempty(Pws{pws_ix})
        return;
    end
    found_ix = pws_ix;
    % get error for merged segms in S1
    if E_pws(found_ix) > 0
        E_merged = E_pws(found_ix);
    else
        % merge segms in set 1
        pcl = [];
        for i=1:size(Pws{pws_ix},2)
            pcl = [pcl; segms{Pws{pws_ix}{i}}.v]; 
        end
        % get error
        [~, E_pws(found_ix)] = PCL2SQ( pcl, 1, 0, 0, [1 1 1 0 1] );
    end    
end


