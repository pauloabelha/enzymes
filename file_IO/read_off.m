function P = read_off(filename)

    % read_off - read data from OFF file.
    %
    %   [vertex,face] = read_off(filename);
    %
    %   'vertex' is a 'nb.vert x 3' array specifying the position of the vertices.
    %   'face' is a 'nb.face x 3' array specifying the connectivity of the mesh.
    %
    %   Copyright (c) 2003 Gabriel Peyr�


    fid = fopen(filename,'r');
    if( fid==-1 )
        error('Can''t open the file.');
        return;
    end

    str = fgets(fid);
    % skip comments
    while (strcmp(str(1),'#'))
        str = fgets(fid);
    end
    if ~strcmp(str(1:3), 'OFF')
        error('The file is not a valid OFF one.');    
    end

    str = fgets(fid);
    [a,str] = strtok(str);
    nvert = str2num(a);
    [a,str] = strtok(str);
    nface = str2num(a);

    [A,cnt] = fscanf(fid,'%f %f %f', 3*nvert);
    if cnt~=3*nvert
        warning('Problem in reading vertices.');
    end
    A = reshape(A, 3, cnt/3);
    vertex = A;
    % read Face 1  1088 480 1022 0 0 255
    n_face_cols = 7;
    [A,cnt] = fscanf(fid,'%d %d %d %d\n', n_face_cols*nface);
    if cnt~=n_face_cols*nface
        warning('Problem in reading faces.');
    end
    A = reshape(A, n_face_cols, cnt/n_face_cols);
    face = A(2:4,:)+1;
    
    face_colours = A(5:7,:);

    fclose(fid);
    
    P.v = vertex';
    P.f = face';
    P.fc = face_colours';
    P.n = [];
    P.u = ones(size(P.v,1),1);
    P.c = [];
    P.segms{1}.v = P.v;    
end