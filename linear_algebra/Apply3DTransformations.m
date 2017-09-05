function [ M_list ] = Apply3DTransformations( M_list, T_list, transp)
    if ~iscell(T_list)
        T_list = {T_list};
    end
    if ~exist('transp','var')
        transp=0;
    end
    for i=1:size(M_list,2)
        if ~isempty(M_list{i})
            for j=1:size(T_list,2)
                if size(T_list{j},1) == 3 && size(T_list{j},2) == 3
                    if transp
                        M_list{i} = M_list{i}*T_list{j}';
                    else                    
                        M_list{i} = (T_list{j}*M_list{i}')';
                    end
                elseif size(T_list{j},1) == 4 && size(T_list{j},2) == 4      
                    M_list{i} = T_list{j}*[M_list{i} ones(size(M_list{i},1),1)]';
                    M_list{i} = M_list{i}(1:3,:)';              
                else
                    if ~isempty(T_list{j})
                        error('One of the transformations is neither a 3x3 nor 4x4 matrix');
                    end
                end
            end
        end
    end
end

