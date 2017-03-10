function [ P ] = WriteModelPly( segms, pcl_filepath )

    P.v = SQsToPCL(segms);
    WritePly(P,pcl_filepath);
end

%         
%      
%     n_points = 0;
%     ix_new_segm=1;
%     for i=1:size(segms,2)
% %         if i ~= action_segm_ix
%             new_segms{ix_new_segm} = segms{i};
%             ix_new_segm = ix_new_segm+1;
%             n_points = n_points + size(segms{i}.v,1);
% %         end
%     end
%     SQs_pcl = [];
%     for i=1:size(new_segms,2)
%         SQs_pcl = [SQs_pcl; new_segms{i}.v];
%     end
%     
% %     action_pcl = SQ2Pcl_Archimedes( model.action.SQ, 10^8, model.action.type );
% %     action_pcl = action_pcl/model.action.PCA;
% %     
% %     new_pcl = [new_pcl; action_pcl];

