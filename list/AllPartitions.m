% By Paulo Abelha
% based on the paper: https://academic.oup.com/comjnl/article/32/3/281/331557/Short-NoteA-Fast-Iterative-Algorithm-for
%
% Generates all partiions of a given set (input as a list)
%
% B is the set of all partitions (B for Bell number)
% https://en.wikipedia.org/wiki/Bell_number
function [ B ] = AllPartitions( S )
    B = PartitionRecur(S);
end

function R = PartitionRecur(S)
    if isempty(S)
        R = {{{}}};
        return;
    end
    elem = S(end);
    P = PartitionRecur(SetDifference(S,elem));
    R = {};
    for i=1:numel(P)
        list_of_set = P{i};
        list_of_set2 = list_of_set;
        list_of_set2{end+1} = {elem};
        R{end+1} = list_of_set2;
        for j=1:numel(P{i})
            R{end+1} = {[P{i}{j} elem]; list_of_set};
        end
    end
    return;
end

function U = union_cell_array(cell1,cell2)
    U = {};
    for i=1:numel(cell1)
        found_elem = 0;
        for j=1:numel(cell2)
            if cell1{i} == cell2{j}
                found_elem = 1;
                break;
            end
        end
        if ~found_elem
            
        end
    end
end
