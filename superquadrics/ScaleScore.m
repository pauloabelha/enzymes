function [ scale_score_vec ] = ScaleScore( scale, score_function, score_mean )
    switch score_function
        case 'quadratic' 
            %f(x) = x^2 - 2m + m^2
            %this quadratic function makes the mean the minimum point of a parabola
            scale_score_vec = (scale.^2) - (scale.*2.*score_mean) + score_mean^2;
    end
end

