function [ score ] = ShapeScaleProportionScore( proportion_function, task_prop, part, model_prop, fit_scale )
    prop_to_use = zeros(3,1);
    for i=1:3
        if strcmp(task_prop{part,i},'model')
            prop_to_use(i) = model_prop(i);
        else
            prop_to_use(i) = task_prop{part,i};
        end
    end
    prop_std1 = prop_to_use(1)/prop_to_use(2);
    prop_std2 = prop_to_use(1)/prop_to_use(3);
    prop_std3 = prop_to_use(2)/prop_to_use(3);
    
    prop1 = fit_scale(1)/fit_scale(2);
    prop2 = fit_scale(1)/fit_scale(3);
    prop3 = fit_scale(2)/fit_scale(3);
    
    score1 = ScoreFunction( proportion_function, prop_std1, prop_std1, prop1 );
    score2 = ScoreFunction( proportion_function, prop_std2, prop_std2, prop2 );
    score3 = ScoreFunction( proportion_function, prop_std3, prop_std3, prop3 );
    
    score = score1+score2+score3;
end

