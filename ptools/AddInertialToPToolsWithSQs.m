function [ ptools_inertia ] = AddInertialToPToolsWithSQs( ptools, task_name, SQs_segments )
    ptools_inertia = zeros(size(ptools,2),29);
    if exist('SQs_segments','var') && ~isempty(SQs_segments)
        use_SQs_segments = 1;
    else
        use_SQs_segments = 0;
    end
    parfor i=1:size(ptools,2)
        [SQs_ptool, transf_list ] = rotateSQs(ptools{i}.SQs, 1, 2, task_name);        
        if use_SQs_segments
            SQs = ApplyTransfSQs(SQs_segments,transf_list);
        else
            SQs = SQs_ptool;
        end
        [ centre_mass, I ] = CalcCompositeMomentInertia( SQs, ptools{i}.mass);
        ptools_inertia(i,:) = [getVector(ptools{i}) centre_mass diag(I)'];
    end
end

