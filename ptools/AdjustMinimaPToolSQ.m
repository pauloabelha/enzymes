%% adjust SQ so that they have at least the ptool's mins
function [ SQ ] = AdjustMinimaPToolSQ( SQ )
    % size resolution (min acceptable size for SQ scale and shape)
    MIN_PTOOLS = [0.0001 0.0001 0.0001 0.1 0.1];  
    if ~isempty(SQ)
        for i=1:3
            SQ(i) = max(SQ(i),MIN_PTOOLS(i));
        end
    end
end

