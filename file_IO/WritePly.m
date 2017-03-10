function WritePly( P, filepath_ply )
%
% Copyright (c) 2015 Paulo Abelha <p.abelha@abdn.ac.uk>
%
    fid = fopen(filepath_ply,'w+');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath_ply);
        error(msg);
    end
    fprintf(fid,'ply');
    fprintf(fid,'\n');
    fprintf(fid,'format ascii 1.0');
    fprintf(fid,'\n');
    fprintf(fid,'comment author Paulo Abelha (p.abelha at abdn ac uk)');
    fprintf(fid,'\n');
    fprintf(fid,'element vertex');
    fprintf(fid,' ');
    fprintf(fid,int2str(size(P.v,1)));
    fprintf(fid,'\n');
    fprintf(fid,'property float x');
    fprintf(fid,'\n');
    fprintf(fid,'property float y');
    fprintf(fid,'\n');
    fprintf(fid,'property float z');
    fprintf(fid,'\n');
    fprintf(fid,'property int segm');
    fprintf(fid,'\n');
    if isfield(P,'n') && size(P.n,1) > 0
        fprintf(fid,'property float nx');
        fprintf(fid,'\n');
        fprintf(fid,'property float ny');
        fprintf(fid,'\n');
        fprintf(fid,'property float nz');
        fprintf(fid,'\n');
    end
    if isfield(P,'c') && size(P.c,1) > 0
        fprintf(fid,'property uchar red');
        fprintf(fid,'\n');
        fprintf(fid,'property uchar green');
        fprintf(fid,'\n');
        fprintf(fid,'property uchar blue');
        fprintf(fid,'\n');
    end
    if isfield(P,'f') && size(P.f,1) > 0
        %put a 3 in front of every face line
        faces = [repmat(size(P.f,2),size(P.f,1),1) P.f];
        fprintf(fid,'element face');
        fprintf(fid,' ');
        fprintf(fid,int2str(size(P.f,1)));
        fprintf(fid,'\n');
        fprintf(fid,'property list uchar int vertex_indices');
        fprintf(fid,'\n');
    end    
    fprintf(fid,'end_header');
    fprintf(fid,'\n');    
    if isfield(P,'n') && size(P.n,1) == 0 && isfield(P,'f') && size(P.f,1) == 0 && isfield(P,'u') && size(P.u,1) == 0
        dlmwrite(filepath_ply,[P.v],'delimiter',' ','-append');
        return;
    end
    if isfield(P,'u') && size(P.u,1) > 0
        u_new = P.u;
    else
        u_new = ones(size(P.v,1),1);
    end
    P.u = u_new;    
    % if it has normals
    if isfield(P,'n') && size(P.n,1) > 0
        % if it has normals and faces
        if size(P.v,1) ~= size(P.n,1)
            warning(['Ignoring Normals - Number of normals (' num2str(size(P.n,1)) ') is different than number of points (' num2str(size(P.v,1)) ')']);
            P.n = zeros(size(P.v,1),3);
        end
        if isfield(P,'f') && size(P.f,1) > 0
            % if it has normals and faces and segments
            if isfield(P,'c') && size(P.u,1) > 0
                dlmwrite(filepath_ply,[P.v P.u P.n P.c],'delimiter',' ','-append');
                dlmwrite(filepath_ply,faces,'delimiter',' ','-append','precision','%d');
                fclose(fid);  
                return;
            end
            dlmwrite(filepath_ply,[P.v P.u P.n],'delimiter',' ','-append');
            dlmwrite(filepath_ply,faces,'delimiter',' ','-append','precision','%d');
            fclose(fid);
            return;
        end
        if isfield(P,'c') && size(P.u,1) > 0
            dlmwrite(filepath_ply,[P.v P.u P.n P.c],'delimiter',' ','-append');
            fclose(fid);  
            return;
        end
        dlmwrite(filepath_ply,[P.v P.u P.n],'delimiter',' ','-append');
        fclose(fid);
        return;        
    end
    % if it does not have normals
    % if it has faces
    if isfield(P,'f') && size(P.f,1) > 0
        % if it has faces and colour
        if isfield(P,'c') && size(P.c,1) > 0
            dlmwrite(filepath_ply,[P.v P.u P.c],'delimiter',' ','-append');
            dlmwrite(filepath_ply,faces,'delimiter',' ','-append','precision','%d');
            fclose(fid);  
            return;
        end
        dlmwrite(filepath_ply,[P.v P.u],'delimiter',' ','-append');
        dlmwrite(filepath_ply,faces,'delimiter',' ','-append','precision','%d');
        fclose(fid);
        return;
    end
     % if it has normals and faces and segments
    if isfield(P,'c') && size(P.c,1) > 0
        dlmwrite(filepath_ply,[P.v P.u P.c],'delimiter',' ','-append');
        fclose(fid);  
        return;
    end
    % if it only has points
    dlmwrite(filepath_ply,[P.v P.u],'delimiter',' ','-append');
    fclose(fid);
    return;
end

