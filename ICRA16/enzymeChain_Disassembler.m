function [chains,SQs] = enzymeChain_Disassembler(chains,SQs,prob_remove_SQ)
    i=1;
    while i<=size(chains,2)
        remove_SQ = randsample(1:round(1/prob_remove_SQ),1); 
        if remove_SQ == 1
            %if chain will be left with only one sq, remove whole chain
            if size(chains{i},1) == 1
                chains(i) = [];
            else
                SQs{end+1} = chains{1}{end};
                chains{i}(end) = [];
                i=i+1;
            end
        else
            i=i+1;
        end
    end
end