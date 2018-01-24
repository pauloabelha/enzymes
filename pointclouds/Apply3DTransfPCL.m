function [ Ps ] = Apply3DTransfPCL( Ps, T_list, transp)
    if ~exist('transp','var')
        transp = 0;
    end
    cell_P = 0;
    if ~iscell(Ps)
        Ps = {Ps};
        cell_P = 0;
    end
    for i=1:size(Ps,2)
        [pcl_and_normals] = Apply3DTransformations({Ps{i}.v,Ps{i}.n},T_list,transp);
        Ps{i}.v = pcl_and_normals{1};
        Ps{i}.n = pcl_and_normals{2};
        if isfield(Ps{i},'segms')
            for j=1:size(Ps{i}.segms,2)
                if isfield(Ps{i}.segms{j},'n')
                    pcl_and_normals = Apply3DTransformations({Ps{i}.segms{j}.v,Ps{i}.segms{j}.n},T_list);
                    Ps{i}.segms{j}.n = pcl_and_normals{2};
                else
                    pcl_and_normals = Apply3DTransformations({Ps{i}.segms{j}.v},T_list);
                end
                Ps{i}.segms{j}.v = pcl_and_normals{1};                
            end
        end
    end
    if ~cell_P
        Ps = Ps{1};
    end
end

