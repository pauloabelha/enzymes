% By Paulo Abelha
% Gets the powerset of set S
function [ P ] = PowerSet( S )
    n = numel(S);
    x = 1:n;
    P = cell(1,2^n);
    p_ix = 2;
    for nn = 1:n
        a = combnk(x,nn);
        for j=1:size(a,1)
            P{p_ix} = a(j,:);
            p_ix = p_ix + 1;
        end
    end
end

