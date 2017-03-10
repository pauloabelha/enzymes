function [ SQs ] = ApplyTransfSQs( SQs, transf_list )
    was_cell = 1;
    if ~iscell(SQs)
       was_cell = 0;
       SQs = {SQs};
    end
    if ~iscell(transf_list)
       transf_list = {transf_list};
    end
    for i=1:numel(SQs)
        for t=1:numel(transf_list)
            T = transf_list{t};
            if size(T,1) == 3 && size(T,2) == 3
                SQs{i} = RotateSQWithRotMtx(SQs{i},T);
                %SQs{i}(6:8) = rotm2eul_(T*eul2rotm_(SQs{i}(6:8),'ZYZ'),'ZYZ');
                SQs{i}(end-2:end) = [T*SQs{i}(end-2:end)']';
            elseif size(T,1) == 4 && size(T,2) == 4
                temp = [SQs{i}(end-2:end) 1] * T';
                SQs{i}(end-2:end) = temp(1:3);
            else
                if ~isempty(T)
                    error(['Non-empty transformation #' num2str(t) ' is neither 3x3 nor 4x4']);
                end
            end       
        end
    end
    if ~was_cell
       SQs = SQs{1}; 
    end
end

