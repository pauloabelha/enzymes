function [ transf ] = CombineTranfs( transf_list )
    transf = eye(4);
    for i=1:numel(transf_list)
        if isempty(transf_list{i})
            continue;
        end
        curr_transf = transf_list{i};
        if size(curr_transf,1) == 3 && size(curr_transf,2) == 3
            curr_transf = [[curr_transf [0;0;0]]; [0 0 0 1]];
        end
        transf = curr_transf*transf;
    end
end

