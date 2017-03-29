function [ SQs, TOT_ERRORS, E_SEGMS, E1_SQs, E2_SQs, Ps ] = FilterCPCBySQFitting( root_folder, min_error )
    if exist('min_error','var')
        MIN_SEGM_ERROR = min_error;
    else
        MIN_SEGM_ERROR = 300;
    end
    pcl_filenames = FindAllFilesOfType( {'ply'}, root_folder );
    n_pcls = numel(pcl_filenames);
    Ps = cell(1,n_pcls);
    SQs = cell(1,n_pcls);
    TOT_ERRORS = zeros(n_pcls,1);
    E_SEGMS = zeros(n_pcls,5);
    E1_SQs = zeros(n_pcls,5);
    E2_SQs = zeros(n_pcls,5);
    tot_toc = 0;
    good_segm_folder = ['good_segmentations_' num2str(MIN_SEGM_ERROR) '/'];
    disp(['mkdir ' root_folder good_segm_folder]);
    system(['mkdir ' root_folder good_segm_folder]);    
    for i=1:n_pcls
        k = findstr('out',pcl_filenames{i});
        if ~isempty(k)
            tic;
            P = ReadPointCloud([root_folder pcl_filenames{i}]);
            Ps{i} = P;
            [ SQs{i}, TOT_ERRORS(i), E_SEGM, E1_SQ, E2_SQ ] = PCL2SQ( P, 2, 0, 0, [1 1 1 0 1] );   
            ixs_good_segms = E_SEGM <= MIN_SEGM_ERROR; 
            if all(ixs_good_segms)
                system(['cp ' root_folder pcl_filenames{i} ' ' root_folder good_segm_folder pcl_filenames{i}]);
                ConvertPointCloud([root_folder good_segm_folder], pcl_filenames{i}, 'ply');
                %system(['rm ' root_folder good_segm_folder pcl_filenames{i}]);
            else
                ConvertPointCloud(root_folder, pcl_filenames{i}, 'ply');
            end
            E_SEGMS(i,1:size(E_SEGM,2)) = E_SEGM;        
            E1_SQs(i,1:size(E1_SQ,2)) = E1_SQ;
            E2_SQs(i,1:size(E2_SQ,2)) = E2_SQ;
            if all(ixs_good_segms)
                str = 'Good';
            else
                str = 'Bad';
            end
            tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_pcls,[str ' segmentation (' pcl_filenames{i} ' errors: [' num2str(E_SEGM) '] min_error: ' num2str(MIN_SEGM_ERROR) '): ']);
        end
    end
end

