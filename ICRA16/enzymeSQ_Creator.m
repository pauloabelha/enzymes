%Given a seed and a probability distribution over SQs, returns a fitted SQ
%pcl is a point cloud
%seed is a point in pcl (may be empty, in which case select random seed)
function [SQ_out, SQs] = enzymeSQ_Fitter( pcl, seed, SQs )
    if isempty(seed)
        seed = getSeedPointsCodelet(pcl,1,'default');
    end
    SQ_to_fit = 0;
    if isempty(SQs)
        [scale, shape] = SampleSQ();        
    else
        SQ_to_fit = randsample(size(SQs,1),1);
        scale = SQs{SQ_to_fit}(1:3);
        shape = SQs{SQ_to_fit}(4:5);
    end
    [~,partLambdas,~,partFinalScores] = PartFinder2( pcl, seed, [scale, shape], 0, 'verbose' );
    SQ_out = partLambdas(1,:);
    SQ_out(end+1) = partFinalScores(1,1); 
    if SQ_to_fit > 0
       SQs(SQ_to_fit) = [];
    end       
end

