% PCLOUD_READ_PLY('path_to_ply_file')
% OUTPUT
%   - P: a structure with the following fields:
%       - P.v:  the [Nx3] matrix containing point locations
%       - P.n: the [Nx3] matrix containing point normals
%

% Copyright (c) 2008 Andrea Tagliasacchi
% All Rights Reserved
% email: ata2@cs.sfu.ca 
% $Revision: 1.0$  Created on: 2008/08/05
function [P] = read_ply( fid, min_n_pts_segm, filepath )

if ~exist('filepath','var')
    filepath = '';
end

segms = {};
P = zeros( 0,3 );
%h = txtwaitbar('init', 'reading PLY file: ');



% spin until end of header
line = fgetl(fid);
curr_line=0;
n_properties=0;
has_faces = 0;
n_faces = 0;
there_is_prop_segm = 0;
there_is_prop_red = 0;
there_is_prop_green = 0;
there_is_prop_blue = 0;
ended_reading_vertex = 0;
while ~strcmp( line, 'end_header' );
    line = fgetl(fid);
    if length(line) >= 6 && strcmp( line(1:6), 'format' )
        if length(line) >= 27 &&  strcmp(line(8:27),'binary_little_endian' )
            % Open file            
            [P.v,P.n,P.c,P.f] = read_ply2(filepath);
            P.f = P.f - 1;
            P.u = GetSegmLabelsFromColour(P.c);
            P.segms = {};
            if isempty(P.u) && isempty(P.c)
                P.segms{end+1}.v = P.v;
                P.segms{end}.n = P.n;
            else
                P.segms = GetSegmsFromVU(P.v,P.n,P.u);
            end
            return;
        end
    end
    if length(line) >= 32 && strcmp( line(1:32), 'property list int vertex_indices' )
        start_faces = 0;        
    end
    if length(line) >= 38 && strcmp( line(1:38), 'property list uchar int vertex_indices' )
        start_faces = 1;        
    end
    if length(line) >= 12 && strcmp( line(1:12), 'element face' )
        ended_reading_vertex = 1;        
    end
    if length(line) >= 13 && strcmp( line(1:13), 'property list' )
        has_faces = 1;
    end
    if length(line)>12 && strcmp( line(1:12), 'element face' )
        n_faces = str2double(line(14:end));
    end
    if ~ended_reading_vertex        
        if length(line) >= 14 && strcmp( line(1:14), 'property float' )
            n_properties=n_properties+1;        
        end
        if length(line) >= 14 && strcmp( line(1:14), 'property uchar' )
            n_properties=n_properties+1;
        end
        if length(line) >= 12 && strcmp( line(1:12), 'property int' )
            n_properties=n_properties+1;
        end        
        
        if length(line) >= 17 && strcmp( line(1:17), 'property int segm' )
            there_is_prop_segm = 1;
            start_segm = n_properties;
        end
        if length(line) >= 18 && strcmp( line(1:18), 'property uchar red' )
            there_is_prop_red = 1;
            start_colour = n_properties;
        end
        if length(line) >= 20 && strcmp( line(1:20), 'property uchar green' )
            there_is_prop_green = 1;
        end
        if length(line) >= 19 && strcmp( line(1:19), 'property uchar blue' )
            there_is_prop_blue = 1;
        end
        if length(line)>14 && strcmp( line(1:14), 'element vertex' )
            N = str2double( line(15:end) );
            P.v  = zeros( N, 3 );
            P.n = zeros( N, 3 );
        end
        
        if length(line) >= 16 && strcmp( line(1:16), 'property float x' )
            start_vertex =  n_properties;      
        end
        if length(line) >= 17 && strcmp( line(1:17), 'property float nx' )
            start_normal =  n_properties;      
        end
    end
    curr_line=curr_line+1;
end
curr_line=curr_line+1;

if ~exist('start_vertex','var') || start_vertex < 1
    error('Could not find ''property float x'' that defines the start of vertexices');
end

M = dlmread(fopen(fid), ' ', [curr_line 0 N+curr_line-1 n_properties-1]);

P.v = M(:,start_vertex:start_vertex+2);

P.n = [];
if exist('start_normal','var')
   P.n = M(:,start_normal:start_normal+2); 
end

P.c = [];
if exist('start_colour','var')
   P.c = M(:,start_colour:start_colour+2); 
end

P.f = [];
if exist('start_faces','var')
   P.f = dlmread(fopen(fid), ' ', [N+curr_line start_faces N+curr_line+n_faces-1 start_faces+2]);
end

there_is_prop_colour = there_is_prop_red && there_is_prop_green && there_is_prop_blue;

P.u  =[];
if there_is_prop_segm
    P.u = M(:,start_segm); 
elseif there_is_prop_colour && ~there_is_prop_segm
    % if there is no segme prop, but there are colours, segment by colour    
        P.u = GetSegmLabelsFromColour(M(:,start_colour:start_colour+2));
else
    P.u = ones(size(P.v,1),1);
end

P.segms = GetSegmsFromVU(P.v,P.n,P.u);
new_segms = {};
for i=1:numel(P.segms)
    if size(P.segms{i}.v,1) >= min_n_pts_segm
        new_segms{end+1} = P.segms{i};
    end
end
P.segms = new_segms;

end

function segms = GetSegmsFromVU(V,N,U)
    segms = {};   
    if~isempty(U)
        % transform U to have ordered segm ixs
        old_ixs = unique(U);
        new_ixs = 1:numel(old_ixs);
        new_U = U;
        for i=1:numel(old_ixs)
           new_U(U==old_ixs(i)) = new_ixs(i); 
        end
        U = new_U;
        % get segms
        segms = cell(1,numel(unique(U)));
        for i=1:numel(segms)
            segms{i}.v = [];
            segms{i}.n = [];
        end
        for i=1:size(U,1)
            segms{U(i)}.v(end+1,:) = V(i,:);
            if ~isempty(N)
                segms{U(i)}.n(end+1,:) = N(i,:);
            end       
        end    
    end
end


function U = GetSegmLabelsFromColour(colours)
    U = zeros(size(colours,1),1);
    colour_set = [];
    for i=1:size(colours,1)
        curr_colour = colours(i,:);
        colour_exists = 0;
        for j=1:size(colour_set,1)
            if all(colour_set(j,:) == curr_colour)
                colour_exists = 1;
                segm_ix = j;
                break;
            end
        end   
        if ~colour_exists
            colour_set(end+1,:) = curr_colour;
            segm_ix = size(colour_set,1);
        end
        U(i) = segm_ix;
    end
end
