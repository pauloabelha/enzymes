% By Paulo Abelha
%
% Generates all partiions of a given set
%   Input S is the set as cell array
%   Output PI is a cell array with the partitions 
%   Output RGS are the visited restricted growth strings
%
% Based on the joriki's answer at Mah SE
% https://math.stackexchange.com/questions/222780/enumeration-of-partitions
% An algorithm for generating all partitions of n elements into k sets
% is given in Volume 4A of Knuth's The Art of Computer Programming
% (which was apparently finally published last year; I didn't know that).
% The subsection is available on his website as fascicle 3b; the algorithm
% is on page 27.
% 
% Donal Knuth's fascicle 3b (Algorithm H):
% http://www-cs-faculty.stanford.edu/~knuth/fasc3b.ps.gz
function [ PI, RGS ] = AllPartitions( S )
    %% check that we have at least two elements
    n = numel(S);
    if n < 2
        error('Set must have two or more elements');
    end    
    %% Donald Knuth's Algorith H
    % restricted growth strings
    RGS = [];
    % H1
    a = zeros(1,n);
    b = ones(1,n-1);
    m = 1;
    while true
        % H2
        RGS(end+1,:) = a;
        while a(n) ~= m            
            % H3
            a(n) = a(n) + 1;
            RGS(end+1,:) = a;
        end
        % H4
        j = n - 1;
        while a(j) == b(j)
           j = j - 1; 
        end
        % H5
        if j == 1
            break;
        else
            a(j) = a(j) + 1;
        end
        % H6
        m = b(j) + (a(j) == b (j));
        j = j + 1;
        while j < n 
            a(j) = 0;
            b(j) = m;
            j = j + 1;
        end
        a(n) = 0;
    end
    %% get partitions from the restricted growth stirngs
    PI = PartitionsFromRGS(S, RGS);
end

% get the partitions from the restricted growth strings
function PI = PartitionsFromRGS(S, RGS)
    n = numel(S);
    PI = cell(1,n);
    % make RGS start at 1 instead of 0
    RGS = RGS + 1;
    for i=1:size(RGS,1)
        n_sets = numel(unique(RGS(i,:)));
        part = cell(1,n_sets);
        for j=1:n
            part{RGS(i,j)}{end+1} = S{j};
        end
        PI{i} = part;
    end
end