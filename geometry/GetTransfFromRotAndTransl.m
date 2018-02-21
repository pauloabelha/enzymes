function [transf] = GetTransfFromRotAndTransl(rot, transl)
    transf=[[rot;[0 0 0]] [transl; 1]];
end

