function [ptools] = ExtractPTools(SQs, mass)
    v=1:numel(SQs);
    alt_ixs = nchoosek(v,2);
    temp = zeros(size(alt_ixs,1)*2,2)+1;
    for i=1:size(temp,1)       
       if mod(i,2) == 0
           temp(i,:) = [alt_ixs(round(i/2),2) alt_ixs(round(i/2),1)];
       else
           alt_ixs_ix = floor(i/2)+1;
           temp(i,:) = alt_ixs(alt_ixs_ix,:);
       end
    end
    alt_ixs = temp;
    max_n_alt = list_depth( SQs );
    ptools = [];
    for i=1:max_n_alt
        for j=1:size(alt_ixs,1)
            if numel(SQs{alt_ixs(j,1)}) < i || numel(SQs{alt_ixs(j,2)}) < i
                continue;
            end
            SQ_grasp = SQs{alt_ixs(j,1)}{i};
            SQ_action = SQs{alt_ixs(j,2)}{i};
            ptools(end+1,:) = ExtractPTool(SQ_grasp,SQ_action,mass);            
        end
    end
end