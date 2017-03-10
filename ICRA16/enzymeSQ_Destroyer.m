function [has_enzymes, new_SQs] = enzymeSQ_Destroyer( SQs, max_score )
    has_enzymes = false;
    new_ix = 1;
    for i=1:size(SQs,1)
        if SQs(i,end) <= max_score 
            new_SQs(new_ix,:) = SQs(i,:);
            new_ix = new_ix+1;
            has_enzymes = true;
        end
    end
    if has_enzymes == false
        new_SQs = [];
    end
end

