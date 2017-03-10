function [ best_pcls, best_cut_point_slices, max_cut_belief, max_vol_prop ] = RotateSegmentDemocritus( pcl, slice_size )
    [ best_pcls, best_cut_point_slices, max_cut_belief ] = CutPCLDemocritus2( pcl, slice_size, 1 );
    pcls_vols = zeros(numel(best_pcls),1);
    for j=1:numel(best_pcls)
        pcls_vols(j) = PCLBoundingBoxVolume(best_pcls{j});
    end
    pcls_vols = sort(pcls_vols,'descend');
    vol_prop = 0;
    if numel(pcls_vols) > 1
        vol_prop = pcls_vols(2)/pcls_vols(1);
    end
    max_vol_prop = vol_prop/numel(pcls_vols)^2;
        
    n_tries = 60;
    angle_step = 2*pi/n_tries;

    tot_toc = 0;
    for i=1:n_tries
        tic;
        rot = GetRotMtx((i-1)*angle_step,'z');
        pcl_rot = pcl*rot;
        [ pcls, cut_point_slices, cut_belief ] = CutPCLDemocritus2( pcl_rot, slice_size, 0 );
        pcls_vols = zeros(numel(pcls),1);
        for j=1:numel(pcls)
            pcls_vols(j) = PCLBoundingBoxVolume(pcls{j});
        end
        pcls_vols = sort(pcls_vols,'descend');
        vol_prop = 0;
        if numel(pcls_vols) > 1
            vol_prop = pcls_vols(2)/pcls_vols(1);
        end
        vol_prop = vol_prop/numel(pcls_vols)^2;
%         figure('name',num2str(vol_prop));
%         PlotPCLS(pcls);        
%         close all;
        %if sum(cut_belief) > sum(max_cut_belief)
        if vol_prop > max_vol_prop
            max_vol_prop = vol_prop;       
            max_cut_belief = cut_belief;
            best_pcls = pcls;
            best_cut_point_slices = cut_point_slices;
        end
        tot_toc = DisplayEstimatedTimeOfLoop(tot_toc+toc,i,n_tries);
    end
end

