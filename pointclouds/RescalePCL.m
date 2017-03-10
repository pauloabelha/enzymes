% multiply the pcl points (including segms) with mult_rescale
% possibly adding a noise rescale_noise
function [ P ] = RescalePCL( P, mult_rescale, rescale_noise )
    if ~exist('rescale_noise','var')
        rescale_noise = 0;
    end
    P.v = P.v*mult_rescale;
    for i=1:numel(P.segms)
        P.segms{i}.v = P.segms{i}.v*(mult_rescale+rescale_noise);        
    end
end

