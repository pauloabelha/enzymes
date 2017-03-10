% checks whether there are any parameters in the SQ that are out-of-bound
function [ SQ_ok ] = CheckSQParams( SQ )
    SQ_ok = 1;
    EROR_SQ_WRONG_VALUE_RANGE = 'The superquadric has an out-of-bound value in parameter ';
    for i=1:3
       if SQ(i) <= 0.0001 
           SQ_ok = 0;
           error([EROR_SQ_WRONG_VALUE_RANGE num2str(i) ' (scale): ' num2str(SQ(i))]);
       end
    end
    % if it is a toroid
    if size(SQ,2) == 16
        if SQ(4) < 0
            SQ_ok = 0;
            error([EROR_SQ_WRONG_VALUE_RANGE num2str(i) ' (toroid thickness): ' num2str(SQ(i))]);
        end
        shape_ix_beg=5; shape_ix_end=6;
        orient_ix_beg=7; orient_ix_end=9;
        taper_ix_beg=10; taper_ix_end=11;
        bend_k_ix=12; bend_alpha_ix=13; 
    else
        shape_ix_beg=4; shape_ix_end=5;
        orient_ix_beg=6; orient_ix_end=8;
        taper_ix_beg=9; taper_ix_end=10;
        bend_k_ix=11; bend_alpha_ix=12; 
    end
    for i=shape_ix_beg:shape_ix_end
        if SQ(i) < 0.009 || SQ(i) > 2
            SQ_ok = 0;
            error([EROR_SQ_WRONG_VALUE_RANGE num2str(i) ' (shape): ' num2str(SQ(i))]);
        end
    end
    for i=orient_ix_beg:orient_ix_end
        if SQ(i) < -3.2 || SQ(i) > 3.2
            SQ_ok = 0;
            error([EROR_SQ_WRONG_VALUE_RANGE num2str(i) ' (orientation): ' num2str(SQ(i))]);
        end
    end
    for i=taper_ix_beg:taper_ix_end
        if SQ(i) < -1 || SQ(i) > 1
            SQ_ok = 0;
            error([EROR_SQ_WRONG_VALUE_RANGE num2str(i) ' (tapering): ' num2str(SQ(i))]);
        end
    end
    if SQ(bend_alpha_ix) < -pi || SQ(bend_alpha_ix) > pi
        SQ_ok = 0;
        error([EROR_SQ_WRONG_VALUE_RANGE num2str(11) ' (bending): ' num2str(SQ(11))]);
    end
    if SQ(bend_k_ix) < 0 || SQ(bend_k_ix) > 100
        SQ_ok = 0;
        error([EROR_SQ_WRONG_VALUE_RANGE num2str(12) ' (bending): ' num2str(SQ(12))]);
    end
end

