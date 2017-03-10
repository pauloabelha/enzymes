function ptools = CheckIsPTool( ptools )

    CheckNumericArraySize(ptools,[Inf 23]);

    filtered_ptools = FilterPTools( ptools );
    if size(filtered_ptools,1) ~= size(ptools,1)
        error('One of the elements in the array is not a ptool');
    end

end

