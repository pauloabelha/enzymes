function [ P ] = AddColourToSegms( P, colours )
    if ~isfield(P,'segms') ||  isempty(P.segms)
        segm.v = P.v;
        if isfield(P,'n')
           segm.n = P.n; 
        end
        P.segms = {segm};
    end
    if ~isfield(P,'u') ||  isempty(P.segms) || size(P.u,1) ~=  size(P.v,1)
        P.u = ones(size(P.v,1),1);        
    end
    if ~exist('colours','var')
        colours = [255 0 0; 0 255 0; 0 0 255; 64 0 64; 0 64 64; 64 64 0; 128 0 0; 0 128 0; 0 0 128];
    end
        colour_segms = [];
        ix_c=1;
        for j=1:size(P.segms,2)
%             if size(P.segms{j}.v,1) > .01*size(P.v,1)
                colour_segms(end+1,:) = colours(ix_c,:);
                ix_c = min(size(colours,1),ix_c+1);
%             else
%                 colour_segms(end+1,:) = [0 0 0];
%             end
        end
        unique_segms = unique(P.u);
        if size(unique_segms,1) ~= size(P.segms,2)
            new_unique_segms = [];
            for i=1:size(unique_segms,1)
                for j=1:size(P.segms,2)
                    if size(P.u(P.u==unique_segms(i)),1) == size(P.segms{j}.v,1)
                        new_unique_segms = [new_unique_segms; unique_segms(i)];
                        break;
                    end
                end
            end
            if isempty(new_unique_segms) || size(new_unique_segms,1) ~= size(P.segms,2)
                warning('There is incongruence between the segmentation labels and the number of segments in this pcl.');
            end
            unique_segms = new_unique_segms;
        end
        ix=1;
        P.c = zeros(size(P.u,1),3);
        for k=1:size(unique_segms,1)
            aux=P.u(P.u==unique_segms(k));
            P.c(P.u==unique_segms(k),:) = repmat(colour_segms(ix,:),size(aux,1),1);
            ix=ix+1;
        end
end

