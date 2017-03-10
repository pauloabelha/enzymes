function WriteObj( P, filepath )
%
% Copyright (c) 2015 Paulo Abelha <p.abelha@abdn.ac.uk>
%
    fid = fopen(filepath,'w+');
    if fid == -1
        msg = strcat('Could not open the file in the path: ',filepath);
        error(msg);
    end
    fprintf(fid,'# OBJ written by Paulo Abelha (p.abelha at abdn ac uk)');
    for i=1:size(P.v,1)
        fprintf(fid,'\n');
        fprintf(fid,'v %f %f %f',P.v(i,:));
    end
    for i=1:size(P.n,1)
        fprintf(fid,'\n');
        fprintf(fid,'n %f %f %f',P.n(i,:));
    end
    for i=1:size(P.f,1)
        fprintf(fid,'\n');
        fprintf(fid,'f %f////%f %f////%f %f////%f',P.f(i,1),P.f(i,1),P.f(i,2),P.f(i,2),P.f(i,3),P.f(i,3));
    end    
    fclose(fid);
end

