function [ swiss_cheese, P_cheeseless, SQs_cheeseless, SEGM_ERRORS_cheeseless, SEGM_ERRORS_SQ_PCL, SEGM_ERRORS_PCL_SQ, swiss_cheese_segm_labels ] = FitAndCheckSwissCheeseSegmentation( P, fit_threshold, plot_fig )
    swiss_cheese_segm_labels = [-1];
    if ~exist('plot_fig','var')
        plot_fig = 0;
    end
    P_cheeseless = P;
    P_ds = DownsamplePCL( P, 10000, 1 );
    [ SQs_fit, ~, SEGM_ERRORS, SEGM_ERRORS_PROP, SEGM_ERRORS_PCL_SQ, SEGM_ERRORS_SQ_PCL, SQs_pcls ] = PCL2SQ( P_ds, 8, plot_fig, 0, [1 1 0 0 0] );
    for i=1:size(SQs_fit,2)
        for j=i+1:size(SQs_fit,2)
            SQ_patch_ix = CheckPatchSegment( SQs_fit{i}, SQs_fit{j}, SQs_pcls{i}, SQs_pcls{j}  );
            if SQ_patch_ix > 0
                swiss_cheese = 0;
                repr_segms = {};
                SQs_cheeseless = {};
                SEGM_ERRORS_cheeseless = [];
                for k=1:size(P.segms,2)
                    if k ~= SQ_patch_ix
                        repr_segms{end+1} = P.segms{k};
                        SQs_cheeseless{end+1} = SQs_fit{k};
                        SEGM_ERRORS_cheeseless(end+1) = SEGM_ERRORS(k);
                    end               
                end
                P_cheeseless.segms = repr_segms;
                labels = unique(P.u);
                if SQ_patch_ix == 1
                    swiss_cheese_segm_labels = labels(i);
                else
                    swiss_cheese_segm_labels = labels(j);
                end
                return;
            end
        end
    end
    SQs_cheeseless = SQs_fit;
    SEGM_ERRORS = SEGM_ERRORS_SQ_PCL + SEGM_ERRORS_PCL_SQ;
    SEGM_ERRORS_cheeseless = SEGM_ERRORS;
%     for i=1:size(SQs_fit,2)
%         SEGM_ERRORS_cheeseless(i) = RankSQ(P_ds.segms{i}.v,SQs_fit{i});
%     end
    
    % get the "density" of each SQ fit (number of points in the segment divided by the SQ volume)
    % for this to work we need to assume the pcl has approximate uniform density    
    tot_vol_SQ = 0;
    for i=1:size(SQs_fit,2)
        tot_vol_SQ = tot_vol_SQ + VolumeSQ(SQs_fit{i});
    end    
    densities_SQs = zeros(size(SQs_fit,2),1);
    segm_prop = zeros(size(SQs_fit,2),1);
    for i=1:size(SQs_fit,2)
        segm_prop(i) = size(P.segms{i}.v,1)/size(P.v,1);
        vol_SQ_prop = VolumeSQ(SQs_fit{i})/tot_vol_SQ;
        densities_SQs(i) = segm_prop(i)/vol_SQ_prop;
    end
    mean_dev_densities_SQs = densities_SQs/mean(densities_SQs);
    prop_densities_SQs = densities_SQs/sum(densities_SQs);
    swisscheese_segm_ixs = zeros(size(SQs_fit,2),1);
    unique_Pu = unique(P.u);
    ix = 1;
    for i=1:size(SQs_fit,2)
       if (segm_prop(i) <= 0.05 || SEGM_ERRORS_cheeseless(i) >= fit_threshold) && mean_dev_densities_SQs(i) < 0.5
           swisscheese_segm_ixs(i) = 1;
           swiss_cheese_segm_labels(ix) = unique_Pu(i);
           ix = ix + 1;
       end        
    end
    swisscheese_segm_ixs = logical(swisscheese_segm_ixs);
    swiss_cheese = 0;
    % if a swiss cheese was found
    if sum(swisscheese_segm_ixs) > 0
        % if the remaining segms by themselves do represent well the pcl
         size_remain_segms = 0;
        for i=1:size(P.segms,2)
            if ~swisscheese_segm_ixs(i)
                size_remain_segms = size_remain_segms + size(P.segms{i}.v,1);
            end
        end
        if size_remain_segms/size(P.v,1) >= 0.9
            repr_segms = {};
            SQs_cheeseless = {};
            SEGM_ERRORS_cheeseless = [];
            for i=1:size(P.segms,2)
                if ~swisscheese_segm_ixs(i)
                    repr_segms{end+1} = P_cheeseless.segms{i};
                    SQs_cheeseless{end+1} = SQs_fit{i};
                    SEGM_ERRORS_cheeseless(end+1) = SEGM_ERRORS(i);
                end
            end
            P_cheeseless.segms = repr_segms;
        else
            swiss_cheese = 1;
            P_cheeseless = [];
        end
    end
%     
%     median_densities_SQs = median(densities_SQs);
%     possible_swisscheese_segm_ixs = zeros(size(SQs_fit,2),1);
%     for i=1:size(densities_SQs,1)
%         if abs(densities_SQs(i)-median_densities_SQs)
%             possible_swisscheese_segm_ixs(i) = 1;
%         end
%     end
%     
%     P_ = DownsamplePCL(P,5000);
%     pcl1 = P_.v;
%     E_REPRESENTATIVES = [];
%     highly_reprep_segms_ixs = zeros(size(P.segms,2),1);
%     for i=1:size(P.segms,2)
%         P_.v = P_.segms{i}.v;
%         P_.n = [];
%         pcl2 = DownsamplePCL(P_,5000);
%         pcl2 = pcl2.v;
%         [~,~,~,~, E_REPRESENTATIVE] = FitErrorBtwPointClouds( pcl1,pcl2 );
%         E_REPRESENTATIVES(end+1) = E_REPRESENTATIVE;
%         if E_REPRESENTATIVE > 0.5 && SEGM_ERRORS_PCL_SQ(i) > 0.05
%             highly_reprep_segms_ixs(i) = 1;
%         end
%     end
%     highly_reprep_segms_ixs = logical(highly_reprep_segms_ixs);
%     E_REPRESENTATIVE = sum(E_REPRESENTATIVES);
%     swiss_cheese = 0;
%     if E_REPRESENTATIVE > 1
%         pcl_rest = [];
%         for i=1:size(highly_reprep_segms_ixs,1)
%             if highly_reprep_segms_ixs(i) == 0
%                 pcl_rest = [pcl_rest; P.segms{i}.v];
%             end
%         end
%         if isempty(pcl_rest)
%             swiss_cheese = 1;
%         else
%             P_.v = pcl_rest;
%             P_.n = [];
%             pcl_rest = DownsamplePCL(P_,5000);
%             pcl_rest = pcl_rest.v;
%             [~,~,~,~, E_REPRESENTATIVE] = FitErrorBtwPointClouds( pcl1,pcl_rest );
%             if E_REPRESENTATIVE > 1
%                 swiss_cheese = 1;
%             end 
%         end
%         if ~swiss_cheese
%            segms = {};
%            SQs_cheeseless = {};
%            for i=1:size(P.segms,2)
%                if highly_reprep_segms_ixs(i) == 0
%                    segms{end+1} = P.segms{i};
%                    SQs_cheeseless{end+1} = SQs_fit{i};
%                end
%            end
%            P_cheeseless.segms = segms;
%         end
%     end
%     if swiss_cheese
%         P_cheeseless = [];
%     end
end

