function WritePcd( P, filepath_pcd )
%
% Copyright (c) 2015 Paulo Abelha <p.abelha@abdn.ac.uk>
%
    fid = fopen(filepath_pcd,'w');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath_pcd);
        error(msg);
    end
    fprintf(fid,'# .PCD v0.7 - Point Cloud Data file format');
    fprintf(fid,'\n');
    fprintf(fid,'VERSION 0.7');

    fprintf(fid,'\n');
    if isempty(P.n)
        if isempty(P.u)                
            fprintf(fid,'FIELDS x y z');
            fprintf(fid,'\n');
            fprintf(fid,'SIZE 4 4 4');
            fprintf(fid,'\n');
            fprintf(fid,'TYPE F F F');
            fprintf(fid,'\n');
            fprintf(fid,'COUNT 1 1 1');            
        else                        
            fprintf(fid,'FIELDS x y z label');
            fprintf(fid,'\n');
            fprintf(fid,'SIZE 4 4 4 4');
            fprintf(fid,'\n');
            fprintf(fid,'TYPE F F F U');
            fprintf(fid,'\n');
            fprintf(fid,'COUNT 1 1 1 1');
            
        end
    else
        if isempty(P.u)
            fprintf(fid,'FIELDS x y z normal_x normal_y normal_z');
            fprintf(fid,'\n');
            fprintf(fid,'SIZE 4 4 4 4 4 4');
            fprintf(fid,'\n');
            fprintf(fid,'TYPE F F F F F F');
            fprintf(fid,'\n');
            fprintf(fid,'COUNT 1 1 1 1 1 1');            
        else            
            fprintf(fid,'FIELDS x y z label normal_x normal_y normal_z');
            fprintf(fid,'\n');
            fprintf(fid,'SIZE 4 4 4 4 4 4 4');
            fprintf(fid,'\n');
            fprintf(fid,'TYPE F F F U F F F');
            fprintf(fid,'\n');
            fprintf(fid,'COUNT 1 1 1 1 1 1 1');            
        end        
    end
    fprintf(fid,'\n');    
    fprintf(fid,'WIDTH ');    
    fprintf(fid,int2str(size(P.v,1)));
    fprintf(fid,'\n');
    fprintf(fid,'HEIGHT 1'); 
    fprintf(fid,'\n');   
    fprintf(fid,'VIEWPOINT 0 0 0 1 0 0 0');
    fprintf(fid,'\n');
    fprintf(fid,'POINTS ');    
    fprintf(fid,int2str(size(P.v,1)));
    fprintf(fid,'\n');    
    fprintf(fid,'DATA ascii');
    fprintf(fid,'\n');  
	dlmwrite(filepath_pcd,[P.v P.u P.n],'delimiter',' ','-append');
    fclose(fid);
end

