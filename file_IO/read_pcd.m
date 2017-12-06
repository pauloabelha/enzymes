function [P, segms] = read_pcd( fid, min_n_pts_segm, filename )
    P = zeros( 0,3 );
    %h = txtwaitbar('init', 'reading PLY file: ');

    % spin until end of header
    curr_row=0;
    max_iter = 1000;
    iter=0;
    while true
        iter=iter+1;
        if iter>=max_iter
            break;
        end
        line = fgetl(fid);
        % disp(line); % DEBUG
        if strcmp( line(1:4), 'TYPE' )
            n_cols = ceil(size(line(6:end),2)/2);
        end
        if strcmp( line(1:6), 'POINTS' )
            %get number of points
            n_points = str2double( line(8:end) );       
            %initialize points and normals matrices        
            P.v  = zeros( n_points, 3 );
            P.n = zeros( n_points, 3 );
            %skip one line that says DATA ascii and get points
            fgetl(fid);
            curr_row=curr_row+1;
            break;
        end
        curr_row=curr_row+1;
    end
    
    curr_row=curr_row+1;
    M = dlmread(filename, ' ', [curr_row 0 (curr_row+n_points)-1 n_cols-1]);
    segms = {};
    
    P.v = M(:,1:3);
    P.n = [];
    P.u = [];
    P.c = [];
    ix_col_segm = 0;
    switch(n_cols)           
        case 4
            if size(M(M(:,4)<0),1) > 1
                P.u = ones(size(M,1),1);
                ix_col_segm = 0;
            else
                P.u = M(:,4);
                ix_col_segm = 4;
            end
        case 6
            P.n = M(:,4:6);
        case 7
            ix_col_segm = 4;
            P.u = M(:,ix_col_segm);            
            P.n = M(:,5:7);        
    end
    
    if ix_col_segm > 0
        segm_ids = unique(M(:,ix_col_segm));
        %segm_ids = segm_ids(segm_ids~=0);
        if size(segm_ids,1) > 1
            ix_segm = 1;
            for i=1:size(segm_ids,1)
                P_segm.v = M(M(:,ix_col_segm)==segm_ids(i),1:3);
                P_segm.n = [];
                if n_cols >= 6
                    P_segm.n = M(M(:,ix_col_segm)==segm_ids(i),4:6);
                end
                if size(P_segm.v,1) >= min_n_pts_segm
                    segms{ix_segm} = P_segm;
                    ix_segm=ix_segm+1;
                end
            end
        end
    else
        segms{end+1}.v = P.v;
        segms{end}.n = P.n;
        P.u = zeros(size(P.v,1),1);
    end
    
    P.segms = segms;
end
