function [ X_balanced ] = ImproveTrainingData( X, gpr, task )
    N = 5000;
    [ X_bridge ] = BridgeSampling( X, 100 );
    [ X_bridge ] = FilterSampledPTools( X, X_bridge );
    Y_bridge = gpr.predict(X_bridge);
    Y_bridge_categ = TaskCategorisation(Y_bridge,task);
    X_balanced = zeros(N,size(X,2));
    beg_ix = 1;
    end_ix = N/4;
    for i=1:4
        a = 1:size(Y_bridge,1);
        a = a(Y_bridge_categ==i);
        ixs = randsample(a,N/4);
        X_balanced(beg_ix:end_ix,:) = X_bridge(ixs,:);
        beg_ix = beg_ix + N/4;
        end_ix = end_ix + N/4;
    end
end

