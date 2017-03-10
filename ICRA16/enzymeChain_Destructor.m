function [chains,loose_SQs] = enzymeChain_Disassembler(chains,loose_SQs,prob_remove_SQ)
    ix_loose_SQ = 1;
    for i=1:size(chains,2)
        if prob_remove_SQ == 0
            remove_SQ = 1;
        else
            remove_SQ = randsample(1:round(1/prob_remove_SQ),1); 
        end
       if remove_SQ == 1
           loose_SQs{end+1} = chains{1}{end}(1:7);
           ix_loose_SQ = ix_loose_SQ+1;
           chains{1}(end) = [];
           if isempty(chains{1})
               chains(1) = [];
           end
       end
    end
end