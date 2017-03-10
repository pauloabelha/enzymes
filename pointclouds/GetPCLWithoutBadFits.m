function [ P, SQs,SEGM_ERRORS_PCL_SQ, SEGM_ERRORS_SQ_PCL, E_REPRESENTATIVES, swiss_cheese ] = GetPCLWithoutBadFits( P, SEGM_ERRORS_PCL_SQ, SEGM_ERRORS_SQ_PCL )
    pcl_SQ_fit_treshold = 0.12;
    SQ_pcl_fit_treshold = 0.12;
    if ~exist('SEGM_ERRORS_PCL_SQ','var') && ~exist('SEGM_ERRORS_PCL_SQ','var')
        [ SQs_fit, ~, ~, ~, SEGM_ERRORS_PCL_SQ, SEGM_ERRORS_SQ_PCL ] = PCL2SQ( P.segms, 1, 1, 0, [1 1 1 0 1] );
    end    
%     disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
%     disp(SEGM_ERRORS_PCL_SQ);
%     disp(SEGM_ERRORS_SQ_PCL);
%     disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    good_segms = {};
    SQs = {};
    for i=1:size(P.segms,2)
        if SEGM_ERRORS_PCL_SQ(i) <= pcl_SQ_fit_treshold && SEGM_ERRORS_SQ_PCL(i) <= SQ_pcl_fit_treshold
            good_segms{end+1} = P.segms{i};
            SQs{end+1} = SQs_fit{i};
        end
    end    
    P_ = DownsamplePCL(P,5000);
    pcl1 = P_.v;
    E_REPRESENTATIVES = [];
    swiss_cheese = 0;
    for i=1:size(P.segms,2)
        P_.v = P_.segms{i}.v;
        P_.n = [];
        pcl2 = DownsamplePCL(P_,5000);
        pcl2 = pcl2.v;
        [~,~,~,~, E_REPRESENTATIVE] = PCLDist( pcl1,pcl2 );
        E_REPRESENTATIVES(end+1) = E_REPRESENTATIVE;
        if E_REPRESENTATIVE > 0.5 && SEGM_ERRORS_PCL_SQ(i) > 0.05
            swiss_cheese = 1;
        end
    end
    P.segms = good_segms;
end

