%CHECKISSCALAR  checks if the input is a scalar
%   CheckIsScalar(N) returns:
%       if N is a scalar, nothing
%       else, an error
%   chars are not considered scalars

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
function CheckIsScalar( N )
    if ~exist('N','var')
        error('This function needs an input');
    end
    if ~isscalar(N) || ischar(N)
        error(['Input is not a scalar']);
    end
end

