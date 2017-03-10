%
% This function reads an obj file and returns a mesh structure
%
% function [M, status] = mesh_read_obj(filename)
%
% Input -
%   - filename: name of obj file to load
%
% Output -
%   - M: triangle mesh: M.vertices(i, :) represents the 3D coordinates
%   of vertex 'i', while M.faces(i, :) contains the indices of the three
%   vertices that compose face 'i'. If the mesh also has color
%   attributes, they are stored in M.FaceVertexCData
%   - status: this variable is 0 if the file was succesfuly opened, or 1
%   otherwise
%
%   The input mesh is similar to that read by the mesh_read_smf
%   function, but the way of specifying colors changes.
%
% See also mesh_read, mesh_read_smf
%
function P = read_obj(filename)
%
% Copyright (c) 2008, 2009, 2010 Oliver van Kaick <ovankaic@cs.sfu.ca>
% Copyright (c) 2015 Paulo Abelha <p.abelha@abdn.ac.uk>

    fid = fopen(filename);
    if fid == -1
        disp(['ERROR: could not open file "' filename '"']);
        return;
    end

    tline = fgetl(fid);
    i=0;
    while ischar(tline) 
        if ~isempty(tline) && strcmp(tline(1),'v');
            start_v=i;
            break;
        end
        i=i+1;
        tline = fgetl(fid);
    end
    while ischar(tline)
        if ~isempty(tline) && strcmp(tline(1),'n');
            end_v=i-1;
            start_n=i;
            n_of_vs = end_v-start_v;
            end_n=start_n+n_of_vs;
            start_f=end_n+1;
            break;
        end
        i=i+1;
        tline = fgetl(fid);
    end        
    end_f=i;
    fclose(fid);
    P.v = dlmread(filename, ' ', [start_v 1 end_v 3]);
    P.n = dlmread(filename, ' ', [start_n 1 end_n 3]);   
    P.f = dlmread(filename, '//', [start_f 1 end_f 3]);
end
