% composes (multiplies) a list of rotations
% (ignoring empty and translation matrices in the list
function [ transf ] = Compose3DRotations( transf_list )
    if ~iscell(transf_list)
        error('This function requires a cell array of transformation matrices (rotations of translations)');
    end
    transf = eye(3);
    for i=1:numel(transf_list)
        if ~isempty(transf_list{i}) && size(transf_list{i},1) == 3 && size(transf_list{i},2) == 3
            transf = transf_list{i}*transf;
        end
    end
end

