function [loose_SQs] = enzymeModel_SQGenerator(model,loose_SQs)
    if size(loose_SQs) == [1 0]
        loose_SQs = {};
    end

    [parts, ~, ~, ~] = SHAPEparam(model);

    %do it for first part
    [lambda_f,lambda_lower_def,lambda_upper_def,lambda_default,~,tapering] = SQparam(parts{1},0,0);
    
    j = 1;
    loose_SQs{end+1,j}{1} = lambda_f;
    loose_SQs{end,j}{2} = lambda_default;
    loose_SQs{end,j}{3} = lambda_lower_def;
    loose_SQs{end,j}{4} = lambda_upper_def;
    loose_SQs{end,j}{5} = tapering;

    j=j+1;    
    while j<=size(parts,2)
        [lambda_f,lambda_lower_def,lambda_upper_def,lambda_default,~,tapering] = SQparam(parts{j},0,0); 
        loose_SQs{end,j}{1} = lambda_f;
        loose_SQs{end,j}{2} = lambda_default;
        loose_SQs{end,j}{3} = lambda_lower_def;
        loose_SQs{end,j}{4} = lambda_upper_def;
        loose_SQs{end,j}{5} = tapering;
        j=j+1;
    end  
end