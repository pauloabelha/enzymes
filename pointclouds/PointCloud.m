function [ P ] = PointCloud( V, N, F, U, C, segms )
    if ~exist('V','var')
        error('Pointcloud needs at least vertices to be constructed');
    end
    if iscell(V)
        segms = V;
        P.v = [];
        P.segms = {};
        P.u = [];
        for i=1:numel(segms)
            P.v = [P.v; segms{i}];
            P.segms{end+1}.v = segms{i};
            P.u = [P.u; repmat(i,size(segms{i},1),1)];
        end        
        return;
    else
        P.v = V;
    end
    if exist('N','var')
        P.n = N;
    else
        P.n = [];
    end
    if exist('F','var')
        P.f = F;
    else
        P.f = [];
    end
    if exist('U','var')
        P.u = U;
    else
        P.u = ones(size(P.v,1),1);
    end
    if exist('C','var')
        P.c = C;
    else
        P.c = [];
    end
    if ~exist('segms','var')
        [P.u, n_labels] = GetEquivalentSegmLabels(P.u);
        segms = cell(1,n_labels);
        for i=1:n_labels
            segms{i}.v = P.v(P.u==i,:);
        end   
        P.segms = segms;
    elseif exist('segms','var') && ~isempty(segms)
        if ~iscell(segms)
            error('Variable segms should be a cell array of pcls or structs cointaining .v and .n fields');
        end
        if isfield(segms{1},'v')
            P.segms = segms;
        else
           P.segms = {};
           for i=1:numel(segms)
               P.segms{end+1}.v = segms{i};
           end
        end
        if isempty(P.u)
           P.u = zeros(size(P.v,1),1);
           curr = 1;
           for i=0:numel(P.segms)-1
               P.u(curr:size(P.segms{i+1}.v,1)) = i;
               curr = size(P.segms{i+1}.v,1) + 1;
           end
        end
        P = AddColourToSegms(P);
    else
        P.segms = {};
        P.segms{end+1}.v = P.v;
        P.segms{end}.n = P.n;
    end
    CheckIsPointCloudStruct(P);
end

