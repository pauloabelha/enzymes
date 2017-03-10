function part_scores = getPartScores( task_functions, source_tool, pcls, gamma1, gamma2)    
    part_scores = {};
    n_parts = 2;
    [parts, ~, ~, weights] = SHAPEparam(source_tool);
    scales = {};
    for i=1:n_parts
        [lambda_f,~,~,~,~] = SQparam(parts{i},0,0);
        if lambda_f(1,1) == 1
            scales{i} = lambda_f(2,1:3);
        else
            scales{i} = [0 0 0];
        end
    end
    
    segm_ix=1;
    
    for mode=1:size(pcls,2)
        for segm=1:size(pcls{mode}{2},2)
            if ~isempty(pcls{mode}{2}{segm}) && ~isempty(pcls{mode}{2}{segm}{1})
                for part=1:2
                    SQ = pcls{mode}{2}{segm}{2}{part}{1};
                    fit_score = pcls{mode}{2}{segm}{2}{part}{2}(end);
                    size_score = 0;    
                    for i=1:3
                        size_score = size_score + ScoreFunction( task_functions.size{part,i}, task_functions.size_score{part,i}, scales{part}(i), SQ(i) );
                    end
                    size_score = weights{1}(1)*size_score;
                                 
                    prop_score = ShapeScaleProportionScore( task_functions.shape_proportion{part},task_functions.shape_proportion_score,part, scales{part}, SQ(1:3) );
                    prop_score = weights{1}(2)*prop_score;

                    part_scores{part,segm_ix}(1) = size_score;
                    part_scores{part,segm_ix}(2) = prop_score;
                    part_scores{part,segm_ix}(3) = fit_score;                          
                end
                segm_ix=segm_ix+1;
            end            
        end        
    end    
end

