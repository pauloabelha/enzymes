function [SQs] = enzymeSQ_Destructor( SQs, max_score )
    i = 1;
    while i <= size(SQs,2)
        if SQs{i}(end) > max_score 
            SQs(i) = [];
        else
            i=i+1;
        end
    end
end

