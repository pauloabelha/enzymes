function [ Y, Y_sds ] = TaskFunctionGPR( task_params, X  )    
    if iscell(task_params)
        gpr = task_params{1};
    else
        gpr = task_params;
    end
    dim_ixs = ones(1,size(gpr.ActiveSetVectors,2));
    if size(task_params,2) > 1
        dim_ixs = logical(task_params{2});
    else        
    end
    X = X(:,8:end);
    [Y,Y_sds] = gpr.predict(X);
end

