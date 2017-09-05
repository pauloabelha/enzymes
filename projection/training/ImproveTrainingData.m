function [ X_balanced ] = ImproveTrainingData( X, Y, task, gpr )
    [ ~, a, b, c ] = TaskCategorisation([],task);
    mins = [0 a b c];
    maxes = [a b c Inf];
    X_balanced = [];
    N = 5000;
    if exist('gpr','var')
        Y_ = gpr.predict(X);
        Y_(Y_<0) = 0;
    else
        Y_ = Y;
    end
    for i=1:4 
        X_filtered = X(Y_>=mins(i) & Y_<maxes(i),:);
        X_bridge = FilterSampledPTools(X, BridgeSampling( X_filtered, 1000 ));
        X_balanced = [X_balanced; X_bridge(randsample(size(X_bridge,1),N/4),:)];
    end
%     Y_bridge = gpr.predict(X_bridge);
%     Y_bridge_categ = TaskCategorisation(Y_bridge,task);    
%     min_a = Inf;
%     for i=1:4
%         a = sum(Y_bridge_categ==i);
%         if a < min_a
%             min_a = a;
%         end
%     end
%     N = min_a*4;
%     X_balanced = zeros(N,size(X,2));
%     beg_ix = 1;
%     end_ix = N/4;    
%     for i=1:4
%         a = 1:size(Y_bridge,1);
%         a = a(Y_bridge_categ==i);
%         ixs = randsample(a,min_a);
%         X_balanced(beg_ix:end_ix,:) = X_bridge(ixs,:);
%         beg_ix = beg_ix + N/4;
%         end_ix = end_ix + N/4;
%     end
end

