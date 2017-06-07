function [ N, C ] = Coloured2DHist( data, dims, dim2 )
    CheckNumericArraySize(data,[Inf Inf]);
    if exist('dim2','var')
        CheckIsScalar(dim2);
        CheckIsScalar(dims);
        dims = [dims dim2];
    end
    CheckNumericArraySize(dims,[1 2]);
    hist3([data(:,dims(1)) data(:,dims(2))],[50 50]);
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    set(gcf,'un','n','pos',[0,0,0.5,0.5]);figure(gcf) 
end

