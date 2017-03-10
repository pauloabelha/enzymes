function Print( msg, variables, fid, console )
    if fid == -1
        if console == 1
            fprintf(msg,variables);
        else
            msg = strcat('Could not open the file to print message: ',filepath);
            error(msg);
        end
    else
       if console == 1
           fprintf(msg,variables);
           fprintf(fid,msg,variables);
       else
           fprintf(fid,msg,variables);
       end        
    end
end

