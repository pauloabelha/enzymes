%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
%
%% Checks if input is a pointcloud object
%
% Inputs:
%   P - input to check whether it is a pointcloud object
% Outputs:
%   nothing if P passes the tests, and gives an error if it doesn't
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckIsPointCloudStruct( P )
    if ~exist('P','var')
        error('Function needs one param');
    end
    if ~isstruct( P )
        error('Pointcloud is not a struct');
    end
    required_fields = {'v', 'n', 'u', 'c', 'f', 'segms'};
    for i=1:size(required_fields,2)
        if ~isfield(P,required_fields{i})
            error(['Pointcloud needs to have ' required_fields{i} ' field']);
        end
    end
    CheckNumericArraySize(P.v,[Inf 3]);
    if ~isempty(P.n)
      CheckNumericArraySize(P.v,[Inf 3]);
    end
    CheckNumericArraySize(P.u,[Inf 1]);
    if isfield(P,'c') && ~isempty(P.c)
        CheckNumericArraySize(P.c,[Inf 3]);
    end
    if ~iscell(P.segms)
        error('Pointcloud''s ''segms'' field needs to be a cell array');
    end
    for i=1:size(P.segms,2)
        CheckNumericArraySize(P.segms{i}.v,[Inf 3]);
    end
end