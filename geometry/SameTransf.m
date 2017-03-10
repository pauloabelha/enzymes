% return true if T1 is the "same" transformation as T2
% where same is defined up to an epsilon diference
function [ equal, reason ] = SameTransf( T1, T2, verbose )
    if ~exist('verbose','var')
        verbose = 0;
    end
    epsilon = 2*eps;
    reason = '';
    %% transfs need to have same size
    if size(T1,1) ~= size(T2,1) 
        equal = false;
        if verbose
            reason = 'Size 1 is different';
            disp(reason);
        end
        return;
    end
    if size(T1,2) ~= size(T2,2) 
        equal = false;
        if verbose
            reason = 'Size 2 is different';
            disp(reason);
        end
        return;
    end
    %% check values
    for i=1:size(T1,1)
        for j=1:size(T1,2)
            if abs(T1(i,j) - T2(i,j)) > epsilon
                equal = false;
                reason = ['T1 ' num2str(i) ' is different than T2 ' num2str(j) ];
                if verbose
                    disp(reason);
                end
                return;
            end
        end
    end
    if verbose
        disp(reason);
    end
    equal = true;
end

