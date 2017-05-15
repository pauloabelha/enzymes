% return true if LT1 is the "same" list of transfs as LT2
% where same is defined up to an epsilon diference
function [ equal ] = SameTransfList( LT1, LT2, verbose )
    if ~exist('verbose','var')
        verbose = 0;
    end
    if numel(LT1) ~= numel(LT2)
        equal = false;
        return;
    end
    for i=1:numel(LT1)
        equal = SameTransf(LT1{i}, LT2{i}, verbose);
        if equal == false
            if verbose
               disp(['List member number ' num2str(i)]);
            end
            return;
        end
    end
end

