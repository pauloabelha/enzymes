function [ X_balanced ] = ImproveTrainingData( X, Y, gpr, task )
    N = 5000;
    [ X_bridge ] = BridgeSampling( X, 1000, Y, 0.005 );
    X_bridge = [X; X_bridge];
    [ X_bridge ] = FilterSampledPTools( X, X_bridge );
    Y_bridge = gpr.predict(X_bridge);
    Y_bridge_categ = TaskCategorisation(Y_bridge,task);    
    min_a = Inf;
    for i=1:4
        a = sum(Y_bridge_categ==i);
        if a < min_a
            min_a = a;
        end
    end
    N = min_a*4;
    X_balanced = zeros(N,size(X,2));
    beg_ix = 1;
    end_ix = N/4;    
    for i=1:4
        a = 1:size(Y_bridge,1);
        a = a(Y_bridge_categ==i);
        ixs = randsample(a,min_a);
        X_balanced(beg_ix:end_ix,:) = X_bridge(ixs,:);
        beg_ix = beg_ix + N/4;
        end_ix = end_ix + N/4;
    end
end

