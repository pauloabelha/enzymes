%CHECKISCHAR  checks if the input is char
%   CheckIsScalar(N) returns:
%       if c is char, nothing
%       else, an error

% By Paulo Abelha (p.abelha@abdn.ac.uk) 2016
function CheckIsChar( c )
    if ~ischar(c)
        error('Input is not a char');
    end
end

