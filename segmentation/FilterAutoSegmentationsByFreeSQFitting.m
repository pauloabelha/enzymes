function [n_good_segmentations,n_segm_outcomes,segm_filenames] = FilterAutoSegmentationsByFreeSQFitting( root_folder, fit_threshold, folders, segm_folder, max_n_segms )
    if ~exist('max_n_segms','var')
        max_n_segms = 5;
    end
    
    segm_folder = [segm_folder(1:end-1) '_' num2str(fit_threshold) '/'];
    
    % whether to copy the well segmented pcls to a new folder
    copy_good_pcls = 1;
    if copy_good_pcls
        for i=1:size(folders,2)
            system(['mkdir ' root_folder folders{i} segm_folder]);
        end
    end
    
    tot_n_pcls = 0;
    for f=1:size(folders,2)
        % get the name of every pcl in the root folder
        pcl_filenames = FindAllFilesOfType( {'pcd'}, [root_folder folders{f}] );
        tot_n_pcls = tot_n_pcls + size(pcl_filenames,2);
    end

    pcl_names_good_segmentation = {};
    ix=0;
    ix_tot=0;
    for f=1:size(folders,2)
        % get the name of every pcl in the root folder
        pcl_filenames = FindAllFilesOfType( {'ply'}, [root_folder folders{f}] );
        initial_pcl_ix=1;
%         found_pcl=0;
%         for i=1:size(pcl_filenames,2)
%            if strcmp(pcl_name_to_start,pcl_filenames{i})
%                found_pcl=1;
%                initial_pcl_ix= i+1;
%                break;
%            end    
%         end
    %     if ~found_pcl         
    %         if ~new_folder
    %             new_folder = 1;
    %             continue;
    %         end
    %     end
        tot_toc = 0;
        n_good_segmentations = 0;
        for i=initial_pcl_ix:size(pcl_filenames,2)
            new_pcl_name = pcl_filenames{i};
            tic
            if ~isempty(findstr('out',pcl_filenames{i}))
                ix_tot=ix_tot+1;
                % read pcl
                try
                    P = ReadPointCloud([root_folder folders{f} pcl_filenames{i} ]);
                    if size(P.segms,2) > max_n_segms + 1
                        disp(['Pointcloud ' pcl_filenames{i} '  has more than ' num2str(max_n_segms+1) ' segments. Continuing processing']);
                        continue;
                    end
                catch E
                    msg = [E.message ' Could not read pointcloud ' root_folder folders{f} pcl_filenames{i} '. Continuing procesing...'];
                    warning(msg);
                    continue;
                end
                P = AddColourToSegms(P);
%                 segms = {};
%                 % downsample segms for faster SQ fitting and uniformity of fitting score
%                 for segm_ix=1:size(P.segms,2)
%                    segms{end+1} =  DownsamplePCL(P.segms{segm_ix},downsample_pcls);
%                 end
%                 P.segms = segms;
                try
                    [ swiss_cheese, P_cheeseless, ~, SEGM_ERRORS, ~, ~, swiss_cheese_segm_labels ] = FitAndCheckSwissCheeseSegmentation( P, fit_threshold);
                catch E
                    msg = [E.message ' Could not fit SQs to pointcloud ' root_folder folders{f} pcl_filenames{i} '. Continuing procesing...'];
                    warning(msg);
                    continue;
                end
                if swiss_cheese
                    %warning(['Segmentation of ' pcl_filenames{i} ' is too poor. Continuing procesing...']);
                    continue;
                else
                CheckIsPointCloudStruct(P_cheeseless);
                if size(P_cheeseless.segms,2) == 1 || size(P_cheeseless.segms,2) > max_n_segms
                    disp(['Pointcloud ' pcl_filenames{i} ' has either only 1 or more than ' num2str(max_n_segms) ' segments. Continuing processing']);
                    continue;
                end
                 
                if ~swiss_cheese && size(P_cheeseless.segms,2) ~= size(P.segms,2) && size(P_cheeseless.segms,2) > 1
                    warning(['One or more swiss cheese segments were removed from ' pcl_filenames{i} '. Fusing bad segments into good ones...']);
                    P_cheeseless = FuseSegmIntoOthers( P, swiss_cheese_segm_labels(1), 1 );
                    new_pcl_name = [pcl_filenames{i}(1:findstr(pcl_filenames{i},'_out')) 'out_' num2str(size(P_cheeseless.segms,2)) '_' pcl_filenames{i}(findstr(pcl_filenames{i},'_out')+5:end)];
                    WritePly(P_cheeseless,[root_folder folders{f} new_pcl_name]);
                    warning('Done fusing segments');
                end
                
                if size(P_cheeseless.segms,2) > max_n_segms
                    disp(['Pointcloud ' pcl_filenames{i} ' has more than ' num2str(max_n_segms) ' segments. Continuing processing']);
                    continue;
                end
                
                dlmwrite([root_folder folders{f} segm_folder 'segm_errors.txt'],SEGM_ERRORS,'delimiter','\t','-append');
                
                    n_good_segms = 0;
                    is_every_segm_good = 1;
                    for j=1:size(SEGM_ERRORS,2)
                       if SEGM_ERRORS(j) <= fit_threshold                       
                           n_good_segms=n_good_segms+1;
                       else
                           is_every_segm_good = 0;
                       end
                    end
                    
                    disp([folders{f} pcl_filenames{i} ' ' num2str(ix_tot) '/' num2str(size(pcl_filenames,2))]);
                    disp(SEGM_ERRORS);
                    % if the majority of segms are good (more than half)
                    %if n_good_segms >= 2;
                    if (size(SEGM_ERRORS,2) == 2 && n_good_segms > 0) || (size(SEGM_ERRORS,2) > 2 && n_good_segms > 2)
                        n_good_segmentations = n_good_segmentations + 1;
                        perc_good_segmentations = round((n_good_segmentations/i)*100);
                        disp(['Good segmentation found! Percentage of good segmentations ' num2str(perc_good_segmentations) ' %']);
                        pcl_names_good_segmentation{end+1} = new_pcl_name;                        
                        if copy_good_pcls
                            if size(P.segms,2) == size(P_cheeseless.segms,2)
                                system(['cp ' root_folder folders{f} pcl_names_good_segmentation{end} ' ' root_folder folders{f} segm_folder]);
                            else
                                WritePly(P_cheeseless,[root_folder folders{f} segm_folder pcl_names_good_segmentation{end}]); 
                            end     
                            if strcmp(pcl_names_good_segmentation{end}(end-2:end),'pcd')
                                % convert pcd to ply
                                if min(min(P.f)) > 0
                                   P.f = P_orig.f - 1;
                                end    
                                if ~isempty(P.segms)
                                    colours = [255 0 0; 0 255 0; 0 0 255; 64 0 64; 0 64 64; 64 64 0; 128 0 0; 0 128 0; 0 0 128];
                                    colour_segms = [];
                                    ix_c=1;
                                    for j=1:size(P.segms,2)
                                        if size(P.segms{j}.v,1) > .01*size(P.v,1)
                                            colour_segms(end+1,:) = colours(ix_c,:);
                                            ix_c = ix_c+1;
                                        else
                                            colour_segms(end+1,:) = [0 0 0];
                                        end
                                    end
                                    unique_segms = unique(P.u);
                                    ix=1;
                                    P.c = zeros(size(P.u,1),3);
                                    for k=1:size(unique_segms,1)
                                        aux=P.u(P.u==unique_segms(k));
                                        P.c(P.u==unique_segms(k),:) = repmat(colour_segms(ix,:),size(aux,1),1);
                                        ix=ix+1;
                                    end   
                                end
                                WritePly(P,[root_folder folders{f} segm_folder pcl_names_good_segmentation{end}(1:end-3) 'ply']);
                            end
                            %system(['rm ' root_folder folders{f} segm_folder pcl_filenames{i}(1:end-3) 'pcd']);
                            fileattrib([root_folder folders{f} segm_folder '/*'],'+w','a');
                        end
                    end
                end
                %disp(segm_errors);
            end
            perc_completed = ceil((i/size(pcl_filenames,2))*100);
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,size(pcl_filenames,2));
        end        
    end
    if n_good_segmentations < 1
        disp('No good segmentations were found :(');
        return;
    end
    [ n_segm_outcomes, segm_filenames ] = CountSegmentationOutcomes(root_folder,'ply',folders);
end

