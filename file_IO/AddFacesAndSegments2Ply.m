% add faces from one original ply to another (useful when faces are lost in conversions)
% normally used to get from a segmented pcd to a ply with faces form an
% original ply and segments form the pcd (adding colour to each segment)
function [ path_pcl_out ] = AddFacesAndSegments2Ply( pcl_orig, pcl_out )
    P_orig = ReadPointCloud(pcl_orig,0);
    P = ReadPointCloud(pcl_out,0);
    if size(P_orig.v ,1) ~= size(P.v,1)
        error('Point clouds have a different number of points.');
    end
    P.f = P_orig.f;
    if min(min(P.f)) > 0
       P.f = P_orig.f - 1;
    end    
    if ~isempty(P.segms)
        colours = [255 0 0; 0 255 0; 0 0 255; 64 0 64; 0 64 64; 64 64 0; 128 0 0; 0 128 0; 0 0 128];
        colour_segms = [];
        ix_c=1;
        for i=1:size(P.segms,2)
            if size(P.segms{i}.v,1) > .01*size(P_orig.v,1)
                colour_segms(end+1,:) = colours(ix_c,:);
                ix_c = ix_c+1;
            else
                colour_segms(end+1,:) = [0 0 0];
            end
        end
        unique_segms = unique(P.u);
        ix=1;
        P.c = zeros(size(P.u,1),3);
        for i=1:size(unique_segms,1)
            aux=P.u(P.u==unique_segms(i));
            P.c(P.u==unique_segms(i),:) = repmat(colour_segms(ix,:),size(aux,1),1);
            ix=ix+1;
        end   
    end
    path_pcl_out = strcat(pcl_out(1:end-4),'_out.ply');
    WritePly(P,path_pcl_out);
end

