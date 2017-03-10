function [ F_score ] = ScoreFunction( score_function, task_score, model_score, score )
    if strcmp(task_score,'model')
        score_to_use = model_score;
    else
        score_to_use = task_score;
    end
    F_score = 0;
    diff_score = abs(score-score_to_use);
    switch score_function
        case 'linear' 
            F_score = abs(score - score_to_use);
        case 'quadratic' 
            %f(x) = x^2 - 2xm + m^2, where m = lowest_score_vec
            %this quadratic function makes the lowest_score the minimum point of a parabola
%             score_vec = (score.^2) - (2*score.*repmat(lowest_score_vec,size(score,1),1)) + repmat(lowest_score_vec.^2,size(score,1),1);             
            if diff_score < 1
                diff = 0;
                ix=0;
                while diff >= 0
                    ix=ix+1;
                    diff = (1/10^ix) - diff_score;                        
                end
                F_score = ((diff_score*(10^ix))^2)/(10^ix);
            else
                %f(x) = |x -m|^2
                F_score = diff_score^2;
            end
       case 'quadratic_linear' 
            %quadratic for values less than best and linear for greater
            if score < score_to_use                
                if diff_score < 1
                    diff = 0;
                    ix=0;
                    while diff >= 0
                        ix=ix+1;
                        diff = (1/10^ix) - diff_score;                        
                    end
                    F_score = ((diff_score*(10^ix))^2)/(10^ix);
                else
                    %f(x) = |x -m|^2
                    F_score = diff_score^2;
                end
            end
       case 'quadratic_linear_linear' 
            prop = 5;
            if score < score_to_use/prop  
                diff_score = abs(score-(score_to_use/prop));
                if diff_score < 1
                    diff = 0;
                    ix=0;
                    while diff >= 0
                        ix=ix+1;
                        diff = (1/10^ix) - diff_score;                        
                    end
                    F_score = ((diff_score*(10^ix))^2)/(10^ix);
                else
                    %f(x) = |x -m|^2
                    F_score = diff_score^2;
                end
            end
        case 'linear_quadratic' 
            %quadratic for values less than best and linear for greater
            if score > score_to_use                
                if diff_score < 1
                    diff = 0;
                    ix=0;
                    while diff >= 0
                        ix=ix+1;
                        diff = (1/10^ix) - diff_score;                        
                    end
                    F_score = ((diff_score*(10^ix))^2)/(10^ix);
                else
                    %f(x) = |x -m|^2
                    F_score = diff_score^2;
                end
            end
    end
end

