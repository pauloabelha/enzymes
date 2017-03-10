function Obj2Ply(filepath_obj,filepath_ply)
%
% Copyright (c) 2015 Paulo Abelha <p.abelha@abdn.ac.uk>
%
    P = read_obj(filepath_obj,0);
    fid = fopen(filepath_ply,'w');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath_ply);
        error(msg);
    end
    fprintf(fid,'ply');
    fprintf(fid,'\n');
    fprintf(fid,'format ascii 1.0');
    fprintf(fid,'\n');
    fprintf(fid,'comment file created by Paulo Abelha (p.abelha at abdn ac uk');
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
    fprintf(fid,'property float nx');
    fprintf(fid,'\n');
    fprintf(fid,'property float ny');
    fprintf(fid,'\n');
    fprintf(fid,'property float nz');
    fprintf(fid,'\n');
    fprintf(fid,'end_header');
    fprintf(fid,'\n');
    
    dlmwrite(filepath_ply,[P.v P.v],'delimiter',' ','-append');
end
