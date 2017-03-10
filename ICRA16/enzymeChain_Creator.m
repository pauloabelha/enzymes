function [chains, fitted_SQs] = enzymeChain_Creator(chains,fitted_SQs,prob_chaining)    
    for i=1:size(fitted_SQs,1)      
        %if sampled to create a pair, create a pair and remove SQ
        create_chain = randsample(1:round(1/prob_chaining),1);
        if create_chain == 1
            j = 1;
            chains{end+1} = cell(2,1);
            chains{end}{j} = fitted_SQs{i,j};
            j=j+1;
            while j<=size(fitted_SQs,2)        
                chains{end}{j} = fitted_SQs{i,j};  
                j=j+1;
            end   
            %erase every fitted SQs from the option i
            fitted_SQs(i,:) = [];
            if isempty(fitted_SQs)
                fitted_SQs = {};
            end
        end       
    end

%     i = 1;
%     %while there are SQs to fit
%     while i<=size(SQs,2)
%         chaining_occured = 0;
%         %if there are at least two more SQs to process, try creating a pair
%         %(new chain)
%         if i<size(SQs,2)
%             %if sampled to create a pair, create a pair and remove SQ
%             create_pair = randsample(1:round(1/prob_chaining),1);
%             if create_pair == 1
%                 chains{end+1} = cell(2,1);
%                 chains{end}{1} = SQs{i};
%                 chains{end}{2} = SQs{i+1};
%                 SQs(i) = [];
%                 SQs(i) = [];
%                 chaining_occured = 1;
%             end
%         end
%         %if a pair (new chain) wasn't created and there is at least one chain, 
%         %add an SQ to a chain and remove SQ
%         if ~chaining_occured && ~isempty(chains)      
%             ix_chain = randsample(size(chains,2),1);
%             increase_chain = randsample(1:round(size(chains{ix_chain},1)/(prob_chaining)),1);
%             if increase_chain == 1                
%                 chains{ix_chain}{end+1} = SQs{i};
%                 SQs(i) = [];
%                 chaining_occured = 1;
%             end
%         end
%         %if no chaining ocurred (pair creation or addition) go to the next SQ
%         if ~chaining_occured
%             i=i+1;
%         end
%     end
end

