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
    X = X(:,dim_ixs);
    N_cores_real = feature('numcores');
    N_cores = N_cores_real;
    if mod(size(X,1),N_cores_real) > 0
        N_cores = N_cores - 1;
    end    
    slice_size = floor(size(X,1)/N_cores_real);
    rest = mod(size(X,1),N_cores_real);
    if rest > 0
        Xs = cell(1,N_cores+1);
    else
        Xs = cell(1,N_cores);
    end    
    for i=1:N_cores
        Xs{i} = X(((i-1)*slice_size)+1:i*slice_size,:);
    end    
    if rest > 0
        i = i + 1;
        Xs{end} = X(((i-1)*slice_size)+1:end,:);
    end
    Ys = cell(1,N_cores_real);
    Y_sdss = Ys;
    parfor i=1:N_cores_real
        [Ys{i},Y_sdss{i}] = gpr.predict(Xs{i});
    end
    Y = concatcellarrayofmatrices(Ys,'row');
    Y_sds = concatcellarrayofmatrices(Y_sdss,'row');
end

